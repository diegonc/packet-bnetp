#include "banner.lua"
do
	-- Plugin configurable parameters.
	local Config = {
		server_port = 6112,
		lite = false,
	}

	-- Forward declarations
	local
		packet_names,
		noop_handler,
		handlers_by_type,
		pid_label,
		CPacketDescription,
		SPacketDescription,
		dissect_packet

	-- To disable debugging output and improve dissector speed uncomment
	-- the folowing line.
	--local info = function(...) end

	-- A BitOp library replacement is needed for the wireshark's stable version
	--     http://lua-users.org/wiki/BitUtils
	-- 32-bit only
	local bit = bit or {
		band = function(a, b)
			local c = 0
			for i = 0, 31 do
				if (a % 2 == 1) then
					if ( b % 2 == 1) then
						c = c + 2 ^ i
						b = b - 1
					end
					a = a - 1
				else
					if (b % 2 == 1) then
						b = b - 1
					end
				end
				a = a / 2
				b = b / 2
			end
			return c
		end
	}

	-- Constants for TCP reassembly and packet rejecting
	local ENOUGH    = false
	local NEED_MORE = true
	local ACCEPTED  = true
	local REJECTED  = false

	local p_bnetp = Proto("bnetp","Battle.net Protocol");

	local f_type = ProtoField.uint8("bnetp.type","Header Type",base.HEX, {
		[0x1] = "Game protocol request",
		[0x2] = "FTP protocol request",
		[0x3] = "Chat protocol request",
		[0xF7] = "W3IGP",
		[0xFF] = "BNCS",
	})
	local f_pid  = ProtoField.uint8("bnetp.pid")
	local f_plen = ProtoField.uint16("bnetp.plen","Packet Length",base.DEC)
	local f_data = ProtoField.bytes("bnetp.unhandled","Unhandled Packet Data")
	
	p_bnetp.fields = {
		-- Header fields
		--     Type
		f_type,
		--     Packet Info
		f_pid,  -- Packet id field
		f_plen, -- Packet length field
		f_data, -- Generic packet data field
	}

	local function State(...)
		local base = {}
		if arg and type(arg[1]) == "table" then
			base = arg[1]
		end
		return {
			["root_node"] = base.root_node or nil,
			["bnet_node"] = base.bnet_node or nil,
			["buf"] =  base.buf or nil,
			["pkt"] = base.pkt or nil,
			["used"] = base.used or 0,
			["packet"] = base.packet or {},

			["peek"] = function(o, count)
				o:request(count)
				return o.buf(o.used, count)
			end,
			["read"] = function(o, count)
				local tmp = o:peek(count)
				o.used = o.used + count
				return tmp
			end,
			["request"] = function(o, count)
				local missing = count - (o.buf:len() - o.used)
				info ("request: "
					.. o.buf:len() .. " "
					.. o.used .. " "
					.. count .. " "
					.. missing)
				if (missing > 0) then
					coroutine.yield(NEED_MORE, missing)
				end
			end,
			["tvb"] = function(o) return o.buf(o.used):tvb() end,
			["error"] = function(o, str)
				o.bnet_node:add_expert_info(PI_DEBUG, PI_NOTE, str)
			end,
			["tail"] = function(o)
				local tmp = State()
				tmp.buf = o:tvb()
				tmp.bnet_node = o.bnet_node
				tmp.packet = o.packet
				tmp.pkt = o.pkt
				return tmp
			end,
		}
	end

	local function do_dissection(state)
		-- Port pair looks good. Looking up a handler
		local handler = handlers_by_type[state:peek(1):uint()]
		if handler then
			-- record offset where pdu starts
			local pdu_start = state.used
			-- add protocol node
			state.bnet_node = state.root_node:add(p_bnetp, state.buf(state.used))
			-- add packet type field
			state.bnet_node:add(f_type, state:read(1))

			-- invoke handler
			handler(state)

			-- fix the length of the pdu
			if state.bnet_node.set_len then
				state.bnet_node:set_len(state.used - pdu_start)
			end
			return ENOUGH, ACCEPTED
		else
			-- If no handler is found the packet is rejected.
			return ENOUGH, REJECTED
		end
	end

	function p_bnetp.dissector(buf,pkt,root)
		local rejected = false

		-- Column's text cannot be queried, only written.
		-- It is cleared here to avoid keeping data from previous
		-- dissector in case it is written by this one.
		-- Ideally it should be retored to the old value if it is
		-- not used by this dissector.
		if pkt.columns.info then
			pkt.columns.info:clear()
		end

		if root then
			local state = State()
			local available = buf:len()

			state.buf = buf
			state.pkt = pkt
			state.root_node = root
			pkt.desegment_len = 0

			-- Check port pair
			if (state.pkt.src_port == state.pkt.match) then
				state.isServerPacket = true
			elseif (state.pkt.dst_port == state.pkt.match) then
				state.isServerPacket = false
			else -- is this ever executed?
				return 0
			end

			info ("dissector: start to process pdus")

			while state.used < available do
				local pdu_start = state.used
				local thread = coroutine.create(do_dissection)
				local r, need_more, missing = coroutine.resume(thread, state)
				if (r and (need_more == NEED_MORE)) then
					state:error("This is an incomplete packet. Refer to next pdu")
					if missing then
						pkt.desegment_len = missing
					else
						pkt.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
					end
					pkt.desegment_offset = pdu_start
					info ("dissector: requesting data -" 
							.. " r: " .. tostring(r)
							.. " need_more: " .. tostring(need_more)
							.. " missing: " .. tostring(missing)
							.. " deseg_len: " .. tostring(pkt.desegment_len))
					available  = pdu_start
					state.used = pdu_start
				elseif r and (need_more==ENOUGH) and (missing==REJECTED) then
					-- Packet was rejected. Make the loop end.
					rejected = true
					available = state.used
				elseif not r then
					error(need_more)
				end
			end
			if state.used > available then
				error("Used more data than available.")
			end
			info ("dissector: finished processing pdus")

			-- Set columns text
			if not rejected then
				if pkt.columns.protocol then
					pkt.columns.protocol:set("BNETP")
				end
				if pkt.columns.info then
					if state.isServerPacket then
						pkt.columns.info:preppend("S>")
					else
						pkt.columns.info:preppend("C>")
					end
				end
			end
			return state.used
		else
			-- Are we ever called with a nil root?
			info ("p_bnetp dissector called with a nil root node.")
		end
	end


	-- Protocol stuff

	noop_handler = function (state) return end

	pid_label = function (pid, name)
		return string.format("Packet ID: %s (0x%02x)", name, pid)
	end

	handlers_by_type = {
		[0x1] = noop_handler,
		[0x2] = noop_handler,
		[0x3] = noop_handler,
		[0xF7] = function (state)
			state.bnet_node:add(f_pid, state:read(1))
			local len = state:peek(2):le_uint()
			state.bnet_node:add_le(f_plen, state:read(2))
			state.bnet_node:add(f_data, state:read(len - 4))
		end,
		[0xFF] = function (state) 
			local pid = state:peek(1):uint()
			local type_pid = ((0xFF * 256) + pid)
			local pidnode = state.bnet_node:add(f_pid, state:read(1))
			pidnode:set_text(pid_label(pid,packet_names[type_pid]))
			
			if state.isServerPacket then
				state.bnet_node:append_text(" S>")
			else
				state.bnet_node:append_text(" C>")
			end
			do
				local infomsg =  string.format(" %s (0x%02x)", packet_names[type_pid],  pid)
				state.bnet_node:append_text(infomsg)
				state.pkt.columns.info:append(infomsg)
			end
			
			-- The size found in the packet includes headers, so consumed bytes
			-- are substracted when requesting more data.
			-- todo: packet length is not considered a header field ?
			--       meanwhile packet.length includes the length field(+2 bytes)
			state.packet.length = state:peek(2):le_uint() -2
			-- Record used bytes before dissecting.
			state.packet.start = state.used
			-- Request at least len extra bytes at once.
			state:request(state.packet.length)

			state.bnet_node:add_le(f_plen, state:read(2))

			-- Allocate a new State object to catch invalid package decriptions
			local substate = State(state)
			-- Constrain its buffer to the packet area
			substate.buf = state.buf(state.used, state.packet.length - 2):tvb()
			substate.used = 0

			local pdesc
			if state.isServerPacket then
				-- process server packet
				pdesc = SPacketDescription[type_pid]
			else
				-- process client packet
				pdesc = CPacketDescription[type_pid]
			end

			local worker = coroutine.create(function (st, pd)
				if Config.lite then return end
				if pd then
					dissect_packet(st, pd)
				else
					st:error("Unssuported packet: " .. packet_names[type_pid])
				end
			end)

			-- launch worker in substate and catch its return value
			local r, need_more, missing = coroutine.resume(worker, substate, pdesc)
			if (r and (need_more == NEED_MORE)) then
				state:error("packet is too short to complete dissection.")
			elseif not r then
				error(need_more)
			end

			-- Update the state
			state.used = state.used + substate.used
			-- Check if any data remains unhandled.
			local remaining = state.packet.length -
				(state.used - state.packet.start)
			if remaining > 0 then
				state.bnet_node:add(f_data, state:read(remaining))
			end
		end,
	}

	-- Packet dissector
	function dissect_packet(state, pdesc)
		for k,v in pairs(pdesc) do
			if v.key and v.value then
				state.packet[v.key] = v:value(state)
			elseif v.key then
				state:error(v.key .. " key creation requested on a field type "
					.. "without a value method.")
			end
			if v.dissect then
				v:dissect(state)
			elseif v.pf then -- XXX: getvalueonly: the cursor is advanced only
				local size = v:size(state)      -- if a field was created.
				if v.big_endian then
					state.bnet_node:add(v.pf, state:read(size))
				else
					state.bnet_node:add_le(v.pf, state:read(size))
				end
			end
		end
	end

	-- Supported data types
	local typemap = {
		["bytes"] = {
			["size"] = function(self, state)
				return self.length
			end,
			["length"] = 1,
		},
		["uint64"] = {
			["size"] = function(...) return 8 end,
			value = function (self, state)
				local val = state:peek(self.size())
				if self.big_endian then
					return val:uint64()
				end
				return val:le_uint64()
			end,
		},
		["uint32"] = {
			size = function(...) return 4 end,
			value = function (self, state)
				local val = state:peek(self.size())
				if self.big_endian then
					return val:uint()
				end
				return val:le_uint()
			end,
		},
		["uint16"] = {
			["size"] = function(...) return 2 end,
			value = function (self, state)
				local val = state:peek(self.size())
				if self.big_endian then
					return val:uint()
				end
				return val:le_uint()
			end,
		},
		["uint8"]  = {
			["size"] = function(...) return 1 end,
			value = function (self, state)
				local val = state:peek(self.size())
				if self.big_endian then
					return val:uint()
				end
				return val:le_uint()
			end,
		},
		["int64"]  = {
			["size"] = function(...) return 8 end,
			value = function (self, state)
				local val = state:peek(self.size())
				if self.big_endian then
					return val:int64()
				end
				return val:le_int64()
			end,
		},
		["int32"]  = {
			["size"] = function(...) return 4 end,
			value = function (self, state)
				local val = state:peek(self.size())
				if self.big_endian then
					return val:int()
				end
				return val:le_int()
			end,
		},
		["int16"]  = {
			["size"] = function(...) return 2 end,
			value = function (self, state)
				local val = state:peek(self.size())
				if self.big_endian then
					return val:int()
				end
				return val:le_int()
			end,
		},
		["int8"]   = {
			["size"] = function(...) return 1 end,
			value = function (self, state)
				local val = state:peek(self.size())
				if self.big_endian then
					return val:int()
				end
				return val:le_int()
			end,
		},
		["ipv4"]   = {
			["size"] = function(...) return 4 end,
			big_endian = true,
		},
		["stringz"] = {
			["alias"] = "string",
			["size"] = function(self, state)
				if (self.length == nil) or (self.length < 0) then
					local eos = self.eos or 0 -- end of string
					local buf = state:tvb()
					local n = 0
					while (n < buf:len()) and (buf(n,1):uint() ~= eos) do
						n = n + 1
					end
					return n + 1
				else
					return self.length
				end
			end,
			["length"] = -1,
			dissect = function(self, state)
				local size = self:size(state)
				local str = state:peek(size):string()

				if self.reversed then
					str = string.reverse(str)
				end

				state.bnet_node:add(self.pf, state:read(size), str)
			end,
			value = function (self, state)
				local val = state:peek(self:size(state))
				return val:string()
			end,
		},
		["sockaddr"] = {
			["size"] = function(...) return 16 end,
			["alias"] = "bytes",
		},
		["filetime"] = {
			["size"] = function(...) return 8 end,
			["alias"] = "string",
			dissect = function(self, state)
				local size = self.size(state:tvb())
				local node = state.bnet_node:add(self.pf, state:peek(8), "")
				-- POSIX epoch filetime
				local epoch = 0xd53e8000 + (0x100000000 * 0x019db1de)
				-- Read filetime
				local filetime = state:read(4):le_uint()
					+ (0x100000000 * state:read(4):le_uint())
				-- Convert to POSIX time if possible
				if filetime > epoch then
					-- Append text form of date to the node label.
					node:append_text(os.date("%c", (filetime - epoch) * 1E-7))
				end
			end,
		},
		["posixtime"] = {
			["size"] = function(...) return 4 end,
			["alias"] = "string",
			dissect = function(self, state)
				local node = state.bnet_node:add(self.pf, state:peek(4), "")
				local unixtime = os.date("%c", state:read(4):le_uint())
				-- Append text form of date to the node label.
				node:append_text(unixtime)
			end,
			value = function (self, state) return state:peek(4):uint() end,
		},
		iterator = {
			alias = "bytes",
			dissect = function(self, state)
				self:initialize(state)
				while self:condition(state) do
					self:iteration(state)
				end
				self:finalize(state)
			end,
			initialize = function (self, state)
				if self.refkey then
					self.priv.count = state.packet[self.refkey]
				end
				self.priv.bn = state.bnet_node
			end,
			condition = function (self, state)
				return (self.priv.count > 0)
			end,
			iteration = function (self, state)
				local start = state.used
				if self.pf then
					state.bnet_node = self.priv.bn:add(self.pf, state:peek(1))
				end
				dissect_packet(state, self.repeated)
				if self.pf and state.bnet_node.set_len then
					state.bnet_node:set_len(state.used - start)
				end
				if self.refkey then
					self.priv.count = self.priv.count - 1
				end
			end,
			finalize = function (self, state)
				state.bnet_node = self.priv.bn
			end,
			priv = {}, -- iterator state
		},
		when = {
			alias = "none",
			dissect = function(self, state)
				if self:condition(state) then
					dissect_packet(state, self.block)
				elseif self.otherwise then
					dissect_packet(state, self.otherwise)
				end
			end,
		},
	}

	--[[ make_args_table
	--
	--	Builds a table to be used by WProtoField.
	--	Positional parameters are moved to their corresponding named parameter.
	--
	--	This should be called in either of the following forms:
	--		* Positional: make_args_table(arg1,arg2, ... )
	--		* Mixed: make_args_table { arg1, arg2, name1=value1, ... }
	--
	--	They can be diferentiated because arg1 must always be a string
	--	in the positional form. (field label)
	--
	--	In mixed form, named parameters overwrite their corresponding
	--	positional parameter.
	--]]
	local function make_args_table_with_positional_map(pmap, ...)
		local args = {}
		local size = table.getn(arg)
		if size > 0 then
			local orig = arg
			if type(arg[1]) == "table"  then
				-- Mixed
				orig = arg[1]
				size = table.getn(orig)
			elseif type(arg[1]) ~= "string"  then
				error("make_args_table called with wrong arguments types.")
			end
			-- Process positional parameters
			for i=1, table.getn(pmap) do
				args[pmap[i]] = orig[i]
			end
			if size > table.getn(pmap) then
				args[pmap.unpacked or "params"] = { n=(size - table.getn(pmap)), unpack(orig, table.getn(pmap)) }
			end
			-- Wipe positional parameters
			-- for i=1, size do
			--	orig[i] = nil
			-- end
			-- Copy named parameters if any. Avoid positional ones.
			for k,v in pairs(orig) do
				if type(k) ~= "number" then
					args[k] = v
				end
			end
		end	
		return args
	end
	
	local function make_args_table(...)
		return make_args_table_with_positional_map({
			"label",
			"display",
			"desc",
			["unpacked"] = "params",}, unpack(arg))
	end

	local function verify_field_args(args)
		local valid = true
		local reason
		if (not args.label) or (type(args.label) ~= "string") then
			valid = false
			reason = "Missing or non string label"
		elseif args.label == "" then
			valid = false
			reason = "Empty label found"
		end
		if args.display and (type(args.display) ~= "number") then
			valid = false
			reason = "Display value was found to be an invalid base type"
		end

		if not valid then
			local str = reason .. " while processing this field description:\n{\n"
			for k,v in pairs(args) do
				str = str .. "\t"
				if type(k) ~= "number" then
					str = str .. tostring(k) .. " = "
				end
				str = str .. tostring(v) .. ",\n"
			end
			str = str .. "}\n"
			error(str .. package.loaded.debug.traceback())
		end
	end

	-- ProtoField wrapper
	local WProtoField = {}
	setmetatable(WProtoField, {
		__index = function(t,k)
				return function (...)
					local typeinfo = typemap[k]
					
					if typeinfo then
						local args = make_args_table(unpack(arg))
						local tmp = {}
						local field = nil
						-- XXX: this getvalueonly thing is pretty hackish
						--      no node is added to the tree unless an alias is
						--      explicitly given.
						if (not args.getvalueonly) or args.alias then
							field = ProtoField[args.alias or typeinfo.alias or k]
						end
						-- TODO: some fields do not expect display
						-- and desc argument
						if field then
							verify_field_args(args)
							tmp.pf = field("",
								args.label,
								args.display,
								args.desc,
								unpack(args.params or {}))
						end
						-- Remove ProtoField arguments
						args.label = nil
						args.desc = nil
						args.display = nil
						args.params = nil
						-- Copy other fields to the returned value
						for k,v in pairs(args) do
							tmp[k] = v
						end
						-- Grant access to the type methods
						-- through the return value
						for k,v in pairs(typeinfo) do
							if tmp[k] == nil then
								tmp[k] = v
							end
						end
						-- Add the field to the protocol field list
						if tmp.pf then
							local n = table.getn(p_bnetp.fields) + 1
							p_bnetp.fields[n] = tmp.pf
						end
						return tmp
					end
					error("unsupported field type: " .. k)
				end
		end,
		__newindex = function (t,k,v)
          error("attempt to update a read-only table", 2)
        end
	})

	#include "constants.lua"
	#include "valuemaps.lua"

	do
		local bytes = WProtoField.bytes
		local uint64 = WProtoField.uint64
		local uint32 = WProtoField.uint32
		local uint16 = WProtoField.uint16
		local uint8 = WProtoField.uint8
		local int64 = WProtoField.int64
		local int32 = WProtoField.int32
		local int16 = WProtoField.int16
		local int8 = WProtoField.int8
		local ipv4 = WProtoField.ipv4
		local stringz = WProtoField.stringz
		local sockaddr = WProtoField.sockaddr
		local wintime = WProtoField.filetime
		local posixtime = WProtoField.posixtime
		local iterator = WProtoField.iterator
		local when = WProtoField.when
		local version = function(...)
			local args = make_args_table(unpack(arg))
			args.big_endian = false
			return ipv4(args)
		end
		local strdw = function(...)
			local args = make_args_table_with_positional_map(
				{"label", "desc"}, unpack(arg))
			args.reversed = true
			args.length = 4
			args.priv = { desc = args.desc }
			args.desc = nil
			args.dissect = function(self, state)
				local size = self:size(state)
				local str = state:peek(size):string()

				if self.reversed then
					str = string.reverse(str)
				end

				-- TODO: generalize lua based value/string maps
				if self.priv.desc and self.priv.desc[str] then
					str = self.priv.desc[str] .. " (" .. str .. ")"
				end
				state.bnet_node:add(self.pf, state:read(size), str)
			end
			return stringz(args)
		end
		local array = function(...)
			local args = make_args_table_with_positional_map(
				{"label", "of", "num"}, unpack(arg))
			if args.of ~= uint32 and args.of ~= uint8 then
				error("Arrays of types other than uint32 or uint8 are not supported.")
			end
			args.of = args.of{alias="none"}
			args.length = args.of:size() * args.num
			args.dissect = function (self, state)
				local str = ""
				local isz = args.of:size()
				-- local fmt = "%0" .. (isz * 2) .. "X "
				local fmt = ""
				if isz == 1 
					then fmt = "%02X"
					else fmt = "%08X "
				end
				local tail = state:tail()
				for i=0, self.num - 1 do
					str = str .. string.format(fmt,
						args.of:value(tail))
					tail:read(isz)
				end
				-- trim trailing space
				str = (string.gsub(str, "^(.*)%s*$", "%1")) 
				state.bnet_node:add(self.pf, state:read(args.length), str)
			end
			return stringz(args)
		end
		local flags = function(...)
			local args = make_args_table(unpack(arg))
			local tmp = args.of(args)
			local fields = {}
			
			for k,v in pairs(tmp.fields) do
				local pfarg = {}
				pfarg.label = v.label or v.sname
				pfarg.display = v.display
				pfarg.desc = v.desc
				pfarg.params = { v.mask }
				fields[k] = tmp.of(pfarg)
			end
			tmp.fields = fields
			tmp.dissect = function(self, state)
				local infostr = ""
				local bn = state.bnet_node
				if self.big_endian then
					state.bnet_node = bn:add(self.pf, state:peek(self.size()))
				else
					state.bnet_node = bn:add_le(self.pf, state:peek(self.size()))
				end
				for k,v in pairs(self.fields) do
					local tail = state:tail()
					local block = { v }
					dissect_packet(tail, block)
					if v.sname and v.sname ~= "" then
						infostr = infostr .. v.sname .. ", "
					end
				end
				state.bnet_node = bn
				state:read(self.size())
				if infostr ~= "" then
					infostr = (string.gsub(infostr, "^(.*),%s*$", "%1"))
					state.bnet_node:append_text(" (" .. infostr .. ")")
				end
			end
			return tmp
		end

		#include "spackets.lua"
		#include "cpackets.lua"
	end

	-- After all the initialization is finished, register plugin
	-- to default port.
	local udp_encap_table = DissectorTable.get("udp.port")
	local tcp_encap_table = DissectorTable.get("tcp.port")
	--udp_encap_table:add(6112,p_bnetp)
	tcp_encap_table:add(Config.server_port,p_bnetp)
end
