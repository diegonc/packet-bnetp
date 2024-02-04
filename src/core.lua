#include "banner.lua"
do
	-- Plugin configurable parameters.
	local Config = {
		-- default port (you can add another port with "Decode as...")
		server_port = 6112,
		-- lite mode - decode only packet headers
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

	-- XXX Lua 5.2 moved the unpack function to the table namespace.
	local unpack = unpack or table.unpack

	-- To disable debugging output and improve dissector speed uncomment
	-- the folowing line.
	local info = function(...) end

	-- A BitOp library replacement is needed for wireshark's stable version
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
	local f_pid  = ProtoField.uint8("bnetp.pid", "Packet ID")
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
		local arg = {...}
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
		-- Ideally it should be restored to the old value if it is
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
					-- XXX older versions of Wireshark did not provide the can_desegment field
					if pkt.can_desegment == nil or pkt.can_desegment > 0 then
						pkt.desegment_len = missing or DESEGMENT_ONE_MORE_SEGMENT
						pkt.desegment_offset = pdu_start
						info ("dissector: requesting data -"
							.. " r: " .. tostring(r)
							.. " need_more: " .. tostring(need_more)
							.. " missing: " .. tostring(missing)
							.. " deseg_len: " .. tostring(pkt.desegment_len))
					else
						state:error("Desegmentation required but not allowed by parent dissector.")
					end
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
			-- Segment doesn't start with a known pattern,
			-- reject whole segment
			if rejected and state.used == 0 then
				return 0
			end
			-- Some packets, either complete or not, were
			-- found in the segment, accept it as ours
			return buf:len()
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

	do
		local bncs_like_header = function(protocol_id)
			return function (state)
				local pid = state:peek(1):uint()
				local type_pid = ((protocol_id * 256) + pid)
				local pidnode = state.bnet_node:add(f_pid, state:read(1))
				local packet_name = packet_names[type_pid] or "Unknown Packet"

				pidnode:set_text(pid_label(pid,packet_name))
				
				if state.isServerPacket then
					state.bnet_node:append_text(" S>")
				else
					state.bnet_node:append_text(" C>")
				end
				do
					local infomsg =  string.format(" %s (0x%02x)", packet_name,  pid)
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
						st:error("Unssuported packet: " .. packet_name)
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
			end
		end

		handlers_by_type = {
			[0x1] = function (state) 
				state.pkt.columns.info:append(" GAME_PROTOCOL")		
				state.bnet_node:append_text(", Game Protocol byte")
			end,
			[0x2] = function (state) 
				state.pkt.columns.info:append(" FTP_PROTOCOL")
				state.bnet_node:append_text(", FTP Protocol byte")
			end,
			[0x3] = function (state) 
				state.pkt.columns.info:append(" CHAT_PROTOCOL")
				state.bnet_node:append_text(", Chat Protocol byte")
			end,
			[0xF7] = bncs_like_header(0xF7),
			[0xFF] = bncs_like_header(0xFF),
		}
	end

	local function check_table(t, pdesc)
		if type(t) ~= "table" then
			local str = "Wrong packet description {\n"
			for k,v in pairs(pdesc) do
				str = str .. "\t"
				if type(k) ~= "number" then
					str = str .. tostring(k) .. " = "
				end
				str = str .. tostring(v) .. ",\n"
			end
			str = str .. "}\n"
			str = str .. package.loaded.debug.traceback()
			print (str)
			error(str)
		end
	end
	-- Packet dissector
	function dissect_packet(state, pdesc)
		for k,v in pairs(pdesc) do
			check_table(v, pdesc)
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

	--[[ make_args_table
	--
	--	Builds a table to be used by create_proto_field().
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
		local arg = {...}
		local args = {}
		local size = #arg
		if size > 0 then
			local orig = arg
			if type(arg[1]) == "table"  then
				-- Mixed
				orig = arg[1]
				size = #orig
			elseif type(arg[1]) ~= "string"  then
				error("make_args_table called with wrong arguments types.")
			end
			-- Process positional parameters
			local pmap_size = #pmap
			for i=1, pmap_size do
				args[pmap[i]] = orig[i]
			end
			if size > pmap_size then
				args[pmap.unpacked or "params"] = {
					n=(size - pmap_size),
					unpack(orig, pmap_size)
				}
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
		local arg = {...}
		return make_args_table_with_positional_map({
			"label",
			"display",
			"desc",
			["unpacked"] = "params",},
			unpack(arg)
		)
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

	local function add_filter_prefix(filter)
		if filter == nil or string.find(filter, "^bnetp%.")
			then return filter
			else return "bnetp." .. filter
		end
	end

	-- ProtoField wrapper
	--   * Wireshar base types
	local wireshark_base_types = {
		bytes  = true,
		uint64 = true, uint32 = true, uint16 = true, uint8  = true,
		int64  = true, int32  = true, int16  = true, int8   = true,
		ipv4   = true,
		string = true,
		none   = true,
	}
	--   * Creates proto fields and registers it automatically.
	local function create_proto_field(template, instance)
		if type(template) ~= "table" or type(instance) ~= "table" then
			error ("invalid parameters "
			.. "template: " .. type(template)
			.. " instance: " .. type(instance) .. " "
			.. package.loaded.debug.traceback())
		end
		local typename = instance.protofield_type or template.protofield_type
					
		if wireshark_base_types[typename] then
			local tmp = {}
			local field = nil
			-- XXX: this getvalueonly thing is pretty hackish
			--      no node is added to the tree unless an alias is
			--      explicitly given.
			if (not instance.getvalueonly) or instance.protofield_type then
				-- Since version 1.10.6, Wireshark no longer provides
				-- a "none" field in ProtoField, field remains nil in
				-- such case.
				-- TODO: TEST
				if typename ~= "none" then
					field = ProtoField[typename] 
				end
			end

			--XXX: A filter string is required in newer versions of Wireshark.
			-- We use 'anythingelse' as default if none is provided.
			if (instance.filter == nil) then
				instance.filter = "anythingelse"
			end

			-- TODO: some fields do not expect display
			-- and desc argument
			if field then
				verify_field_args(instance)
				tmp.pf = field(add_filter_prefix(instance.filter) or "",
					instance.label,
					instance.display,
					instance.desc,
					unpack(instance.params or {})
				)
			end
			-- Remove ProtoField arguments
			instance.label = nil
			instance.desc = nil
			instance.display = nil
			instance.params = nil
			-- Copy other fields to the returned value
			for k,v in pairs(instance) do
				tmp[k] = v
			end
			-- Grant access to the type methods
			-- through the return value
			for k,v in pairs(template) do
				if tmp[k] == nil then
					tmp[k] = v
				end
			end
			-- Add the field to the protocol field list
			if tmp.pf then
				local n = # (p_bnetp.fields) + 1
				p_bnetp.fields[n] = tmp.pf
			end
			return tmp
		end
		error("unsupported field type: " .. tostring(typename)
			.." " .. package.loaded.debug.traceback())
	end

	-- XXX Wireshark eventually moved to Lua 5.2 which no longer has
	-- getfenv/setfenv functions.
	-- TODO: does the global environment get clobbered in Lua 5.2?
	-- 2018-02: To remove conditional code, give up and clobber environment
	---- Avoid clobbering global environment
	--local global_environment = getfenv(1)
	--setfenv(1, setmetatable({}, {__index = global_environment}))


	#include "constants.lua"
	#include "valuemaps.lua"
	#include "checkedtable.lua"
	#include "api/bytes.lua"
	#include "api/integer.lua"
	#include "api/ipv4.lua"
	#include "api/stringz.lua"
	#include "api/time.lua"
	#include "api/iterator.lua"
	#include "api/when.lua"
	#include "api/version.lua"
	#include "api/strdw.lua"
	#include "api/array.lua"
	#include "api/flags.lua"
	#include "api/sockaddr.lua"
	#include "api/slot.lua"
	
	-- Packets from server to client
	SPacketDescription = {
	#include "spackets_sid.lua"
	#include "spackets_w3gs.lua"
	}
	
	-- Packets from client to server
	CPacketDescription = {
	#include "cpackets_sid.lua"
	#include "cpackets_w3gs.lua"
	}

	-- XXX Wireshark eventually moved to Lua 5.2 which no longer has
	-- getfenv/setfenv functions.
	-- TODO: does the global environment get clobbered in Lua 5.2?
	-- 2018-02: To remove conditional code, give up and clobber environment
	--setfenv(1, global_environment)

	-- After all the initialization is finished, register plugin
	-- to default port.
	local udp_encap_table = DissectorTable.get("udp.port")
	local tcp_encap_table = DissectorTable.get("tcp.port")
	udp_encap_table:add(6112,p_bnetp)
	tcp_encap_table:add(Config.server_port,p_bnetp)
end
