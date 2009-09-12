do
	local
		packet_names,
		noop_handler,
		handlers_by_type,
		pid_label,
		CPacketDescription,
		SPacketDescription,
		dissect_packet


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
	local f_data = ProtoField.bytes("","Unhandled Packet Data")
	
	p_bnetp.fields = {
		f_type,
		f_pid,  
		f_plen, 
		f_data, 
	}

	local function State()
		return {
			["bnet_node"] = nil,
			["buf"] = nil,
			["pkt"] = nil,
			["used"] = 0,
			["packet"] = {},

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
		}
	end

	local function do_dissection(state)
		local handler = handlers_by_type[state:peek(1):uint()]
		if handler then
			state.bnet_node:add(f_type, state:read(1))
			handler(state)
			return ENOUGH, ACCEPTED
		else
			return ENOUGH, REJECTED
		end
	end

	function p_bnetp.dissector(buf,pkt,root)
		if pkt.columns.protocol then
			pkt.columns.protocol:set("BNETP")
		end

		if pkt.columns.info then
			pkt.columns.info:clear()
		end

		if root then
			local state = State()
			local available = buf:len()

			state.buf = buf
			state.pkt = pkt
			pkt.desegment_len = 0

			info ("dissector: start to process pdus")

			while state.used < available do
				state.bnet_node = root:add(p_bnetp, buf(state.used))

				local thread = coroutine.create(do_dissection)
				local r, need_more, missing = coroutine.resume(thread, state)
				if (r and (need_more == NEED_MORE)) then
					if missing then
						pkt.desegment_len = missing
					else
						pkt.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
					end
					pkt.desegment_offset = 0
					info ("dissector: requesting data -" 
							.. " r: " .. tostring(r)
							.. " need_more: " .. tostring(need_more)
							.. " missing: " .. tostring(missing)
							.. " deseg_len: " .. tostring(pkt.desegment_len))
					return
				elseif r and (need_more==ENOUGH) and (missing==REJECTED) then
					available = state.used
				elseif not r then
					error(need_more)
				end
			end
			if state.used > available then
				error("Used more data than available.")
			end
			info ("dissector: finished processing pdus")
			return state.used
		end
	end

	local udp_encap_table = DissectorTable.get("udp.port")
	local tcp_encap_table = DissectorTable.get("tcp.port")
	tcp_encap_table:add(6112,p_bnetp)


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
			state.packet.length = state:peek(2):le_uint() -2
			state.packet.start = state.used
			state:request(state.packet.length)

			state.bnet_node:add_le(f_plen, state:read(2))

			local pdesc
			if state.pkt.src_port == 6112 then
				pdesc = SPacketDescription[type_pid]
			else
				pdesc = CPacketDescription[type_pid]
			end

			if pdesc then
				dissect_packet(state, pdesc)
			else
				state:error("Unssuported packet: " .. packet_names[type_pid])
			end

			local remaining = state.packet.length -
				(state.used - state.packet.start)
			if remaining > 0 then
				state.bnet_node:add(f_data, state:read(remaining))
			end
		end,
	}

	function dissect_packet(state, pdesc)
		for k,v in pairs(pdesc) do
			if v.key and v.value then
				state.packet[v.key] = v:value(state)
			end
			if not v.dissect then
				local size = v:size(state)
				if v.big_endian then
					state.bnet_node:add(v.pf, state:read(size))
				else
					state.bnet_node:add_le(v.pf, state:read(size))
				end
			else
				v:dissect(state)
			end
		end
	end

	local typemap = {
		["bytes"] = {
			["size"] = function(self, state)
				return self.length
			end,
			["length"] = 1,
		},
		["uint64"] = {
			["size"] = function(...) return 8 end,
		},
		["uint32"] = {
			size = function(...) return 4 end,
			value = function (self, state)
				local val = state:peek(self.size())
				return val:le_uint()
			end,
		},
		["uint16"] = {
			["size"] = function(...) return 2 end,
		},
		["uint8"]  = {
			["size"] = function(...) return 1 end,
		},
		["int64"]  = {
			["size"] = function(...) return 8 end,
		},
		["int32"]  = {
			["size"] = function(...) return 4 end,
		},
		["int16"]  = {
			["size"] = function(...) return 2 end,
		},
		["int8"]   = {
			["size"] = function(...) return 1 end,
		},
		["ipv4"]   = {
			["size"] = function(...) return 4 end,
			big_endian = true,
		},
		["stringz"] = {
			["alias"] = "string",
			["size"] = function(self, state)
				if (self.length == nil) or (self.length < 0) then
					local eos = self.eos or 0 
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
				local buf = state:read(size):tvb()

				if self.reversed then
					local tmp = ByteArray.new()
					tmp:set_size(size)
					for i=size - 1, 0, -1 do
						tmp:set_index(size - i - 1,
							buf(i, 1):uint())
					end
					buf = tmp:tvb("Reversed String")
				end

				state.bnet_node:add(self.pf, buf())
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
			["alias"] = "uint64",
			dissect = function(self, state)
				local size = self.size(state:tvb())
				local node = state.bnet_node:add(self.pf, state:peek(8))
				local epoch = 0xd53e8000 + (0x100000000 * 0x019db1de)
				local filetime = state:read(4):le_uint()
					+ (0x100000000 * state:read(4):le_uint())
				if filetime > epoch then
					node:append_text(os.date(" %c", (filetime - epoch) * 1E-7))
				end
			end,
		},
		["posixtime"] = {
			["size"] = function(...) return 4 end,
			["alias"] = "uint32",
			dissect = function(self, state)
				local node = state.bnet_node:add(self.pf, state:peek(4))
				local unixtime = os.date(" %c", state:read(4):le_uint())
				node:append_text(unixtime)
			end,
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
			priv = {}, 
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

	local function make_args_table(args, ...)
		if type(args) ~= "table" then
			args = {label=args}
			args.display = arg[1]
			args.desc = arg[2]
		end
		return args
	end

	local WProtoField = {}
	setmetatable(WProtoField, {
		__index = function(t,k)
				return function (args, ...)
					local typeinfo = typemap[k]
					
					if typeinfo then
						args = make_args_table(args, unpack(arg))
						local tmp = {}
						local field = ProtoField[args.alias or typeinfo.alias or k]
						if field then
							tmp.pf = field("",
								args.label,
								args.display,
								args.desc,
								unpack(args.params or {}))
						end
						args.label = nil
						args.desc = nil
						args.display = nil
						args.params = nil
						for k,v in pairs(args) do
							tmp[k] = v
						end
						for k,v in pairs(typeinfo) do
							if tmp[k] == nil then
								tmp[k] = v
							end
						end
						local n = table.getn(p_bnetp.fields) + 1
						p_bnetp.fields[n] = tmp.pf
						return tmp
					end
					error("unsupported field type: " .. k)
				end
		end,
		__newindex = function (t,k,v)
          error("attempt to update a read-only table", 2)
        end
	})

packet_names = {
[0x700E] = "BNLS_AUTHORIZE",
[0x700F] = "BNLS_AUTHORIZEPROOF",
[0x7001] = "BNLS_CDKEY",
[0x700C] = "BNLS_CDKEY_EX",
[0x7005] = "BNLS_CHANGECHALLENGE",
[0x7006] = "BNLS_CHANGEPROOF",
[0x700D] = "BNLS_CHOOSENLSREVISION",
[0x700A] = "BNLS_CONFIRMLOGON",
[0x7004] = "BNLS_CREATEACCOUNT",
[0x700B] = "BNLS_HASHDATA",
[0x7002] = "BNLS_LOGONCHALLENGE",
[0x7003] = "BNLS_LOGONPROOF",
[0x7000] = "BNLS_NULL",
[0x7010] = "BNLS_REQUESTVERSIONBYTE",
[0x7012] = "BNLS_RESERVESERVERSLOTS",
[0x7013] = "BNLS_SERVERLOGONCHALLENGE",
[0x7014] = "BNLS_SERVERLOGONPROOF",
[0x7007] = "BNLS_UPGRADECHALLENGE",
[0x7008] = "BNLS_UPGRADEPROOF",
[0x7011] = "BNLS_VERIFYSERVER",
[0x7009] = "BNLS_VERSIONCHECK",
[0x7018] = "BNLS_VERSIONCHECKEX",
[0x701A] = "BNLS_VERSIONCHECKEX2",
[0x715C] = "D2GS_COMPSTARTGAME",
[0x713F] = "D2GS_CHARACTERPHRASE",
[0x7110] = "D2GS_CHARTOOBJ",
[0x7115] = "D2GS_CHATMESSAGE",
[0x7150] = "D2GS_DROPGOLD",
[0x7117] = "D2GS_DROPITEM",
[0x716A] = "D2GS_ENTERGAMEENVIRONMENT",
[0x7168] = "D2GS_GAMELOGON",
[0x7128] = "D2GS_INSERTSOCKETITEM",
[0x7113] = "D2GS_INTERACTWITHENTITY",
[0x7123] = "D2GS_ITEMTOBELT",
[0x711A] = "D2GS_ITEMTOBODY",
[0x7118] = "D2GS_ITEMTOBUFFER",
[0x712A] = "D2GS_ITEMTOCUBE",
[0x7106] = "D2GS_LEFTSKILLONENTITY",
[0x7107] = "D2GS_LEFTSKILLONENTITYEX",
[0x7109] = "D2GS_LEFTSKILLONENTITYEX2",
[0x710A] = "D2GS_LEFTSKILLONENTITYEX3",
[0x7105] = "D2GS_LEFTSKILLONLOCATION",
[0x7108] = "D2GS_LEFTSKILLONLOCATIONEX",
[0x717A] = "D2GS_LOGONRESPONSE",
[0x7132] = "D2GS_NPCBUY",
[0x7130] = "D2GS_NPCCANCEL",
[0x712F] = "D2GS_NPCINIT",
[0x7133] = "D2GS_NPCSELL",
[0x7138] = "D2GS_NPCTRADE",
[0x7114] = "D2GS_OVERHEADMESSAGE",
[0x715E] = "D2GS_PARTY",
[0x711C] = "D2GS_PICKUPBODYITEM",
[0x7119] = "D2GS_PICKUPBUFFERITEM",
[0x7116] = "D2GS_PICKUPITEM",
[0x716D] = "D2GS_PING",
[0x7161] = "D2GS_POTIONTOMERCENARY",
[0x7124] = "D2GS_REMOVEBELTITEM",
[0x7122] = "D2GS_REMOVESTACKITEM",
[0x710D] = "D2GS_RIGHTSKILLONENTITY",
[0x710E] = "D2GS_RIGHTSKILLONENTITYEX",
[0x7110] = "D2GS_RIGHTSKILLONENTITYEX2",
[0x7111] = "D2GS_RIGHTSKILLONENTITYEX3",
[0x710C] = "D2GS_RIGHTSKILLONLOCATION",
[0x710F] = "D2GS_RIGHTSKILLONLOCATIONEX",
[0x7104] = "D2GS_RUNTOENTITY",
[0x7103] = "D2GS_RUNTOLOCATION",
[0x7129] = "D2GS_SCROLLTOTOME",
[0x711D] = "D2GS_SETBYTEATTR",
[0x711F] = "D2GS_SETDWORDATTR",
[0x711E] = "D2GS_SETWORDATTR",
[0x7119] = "D2GS_SMALLGOLDPICKUP",
[0x7121] = "D2GS_STACKITEM",
[0x71AF] = "D2GS_STARTLOGON",
[0x711B] = "D2GS_SWAP2HANDEDITEM",
[0x7125] = "D2GS_SWITCHBELTITEM",
[0x711D] = "D2GS_SWITCHBODYITEM",
[0x711F] = "D2GS_SWITCHINVENTORYITEM",
[0x714F] = "D2GS_TRADE",
[0x7177] = "D2GS_TRADEACTION",
[0x7189] = "D2GS_UNIQUEEVENTS",
[0x712D] = "D2GS_UNSELECTOBJ",
[0x7126] = "D2GS_USEBELTITEM",
[0x7120] = "D2GS_USEITEM",
[0x7102] = "D2GS_WALKTOENTITY",
[0x7101] = "D2GS_WALKTOLOCATION",
[0x7149] = "D2GS_WAYPOINT",
[0x7151] = "D2GS_WORLDOBJECT",
[0x7213] = "MCP_CANCELGAMECREATE",
[0x7202] = "MCP_CHARCREATE",
[0x720A] = "MCP_CHARDELETE",
[0x7217] = "MCP_CHARLIST",
[0x7219] = "MCP_CHARLIST2",
[0x7207] = "MCP_CHARLOGON",
[0x7218] = "MCP_CHARUPGRADE",
[0x7203] = "MCP_CREATEGAME",
[0x7214] = "MCP_CREATEQUEUE",
[0x7206] = "MCP_GAMEINFO",
[0x7205] = "MCP_GAMELIST",
[0x7204] = "MCP_JOINGAME",
[0x7212] = "MCP_MOTD",
[0x7211] = "MCP_REQUESTLADDERDATA",
[0x7201] = "MCP_STARTUP",
[0x730D] = "PACKET_ACCOUNT",
[0x730B] = "PACKET_BOTNETCHAT",
[0x730A] = "PACKET_BOTNETVERSION",
[0x7307] = "PACKET_BROADCASTMESSAGE",
[0x7309] = "PACKET_CHANGEDBPASSWORD",
[0x7310] = "PACKET_CHATDROPOPTIONS",
[0x7308] = "PACKET_COMMAND",
[0x7305] = "PACKET_CYCLE",
[0x7303] = "PACKET_DATABASE",
[0x7300] = "PACKET_IDLE",
[0x7301] = "PACKET_LOGON",
[0x7304] = "PACKET_MESSAGE",
[0x7302] = "PACKET_STATSUPDATE",
[0x7306] = "PACKET_USERINFO",
[0x7307] = "PACKET_USERLOGGINGOFF",
[0x7403] = "PKT_CLIENTREQ",
[0x7408] = "PKT_CONNTEST",
[0x7409] = "PKT_CONNTEST2",
[0x7407] = "PKT_KEEPALIVE",
[0x7405] = "PKT_SERVERPING",
[0xFF55] = "SID_AUTH_ACCOUNTCHANGE",
[0xFF56] = "SID_AUTH_ACCOUNTCHANGEPROOF",
[0xFF52] = "SID_AUTH_ACCOUNTCREATE",
[0xFF53] = "SID_AUTH_ACCOUNTLOGON",
[0xFF54] = "SID_AUTH_ACCOUNTLOGONPROOF",
[0xFF57] = "SID_AUTH_ACCOUNTUPGRADE",
[0xFF58] = "SID_AUTH_ACCOUNTUPGRADEPROOF",
[0xFF51] = "SID_AUTH_CHECK",
[0xFF50] = "SID_AUTH_INFO",
[0xFF30] = "SID_CDKEY",
[0xFF36] = "SID_CDKEY2",
[0xFF5B] = "SID_CHANGEEMAIL",
[0xFF31] = "SID_CHANGEPASSWORD",
[0xFF0E] = "SID_CHATCOMMAND",
[0xFF0F] = "SID_CHATEVENT",
[0xFF15] = "SID_CHECKAD",
[0xFF32] = "SID_CHECKDATAFILE",
[0xFF3C] = "SID_CHECKDATAFILE2",
[0xFF72] = "SID_CLANCREATIONINVITATION",
[0xFF73] = "SID_CLANDISBAND",
[0xFF70] = "SID_CLANFINDCANDIDATES",
[0xFF75] = "SID_CLANINFO",
[0xFF77] = "SID_CLANINVITATION",
[0xFF79] = "SID_CLANINVITATIONRESPONSE",
[0xFF71] = "SID_CLANINVITEMULTIPLE",
[0xFF74] = "SID_CLANMAKECHIEFTAIN",
[0xFF82] = "SID_CLANMEMBERINFORMATION",
[0xFF7D] = "SID_CLANMEMBERLIST",
[0xFF81] = "SID_CLANMEMBERRANKCHANGE",
[0xFF7E] = "SID_CLANMEMBERREMOVED",
[0xFF7F] = "SID_CLANMEMBERSTATUSCHANGE",
[0xFF7C] = "SID_CLANMOTD",
[0xFF76] = "SID_CLANQUITNOTIFY",
[0xFF7A] = "SID_CLANRANKCHANGE",
[0xFF78] = "SID_CLANREMOVEMEMBER",
[0xFF7B] = "SID_CLANSETMOTD",
[0xFF16] = "SID_CLICKAD",
[0xFF05] = "SID_CLIENTID",
[0xFF1E] = "SID_CLIENTID2",
[0xFF2A] = "SID_CREATEACCOUNT",
[0xFF3D] = "SID_CREATEACCOUNT2",
[0xFF21] = "SID_DISPLAYAD",
[0xFF0A] = "SID_ENTERCHAT",
[0xFF4B] = "SID_EXTRAWORK",
[0xFF2F] = "SID_FINDLADDERUSER",
[0xFF13] = "SID_FLOODDETECTED",
[0xFF67] = "SID_FRIENDSADD",
[0xFF65] = "SID_FRIENDSLIST",
[0xFF69] = "SID_FRIENDSPOSITION",
[0xFF68] = "SID_FRIENDSREMOVE",
[0xFF66] = "SID_FRIENDSUPDATE",
[0xFF1B] = "SID_GAMEDATAADDRESS",
[0xFF60] = "SID_GAMEPLAYERSEARCH",
[0xFF2C] = "SID_GAMERESULT",
[0xFF09] = "SID_GETADVLISTEX",
[0xFF0B] = "SID_GETCHANNELLIST",
[0xFF33] = "SID_GETFILETIME",
[0xFF2D] = "SID_GETICONDATA",
[0xFF2E] = "SID_GETLADDERDATA",
[0xFF0C] = "SID_JOINCHANNEL",
[0xFF10] = "SID_LEAVECHAT",
[0xFF1F] = "SID_LEAVEGAME",
[0xFF12] = "SID_LOCALEINFO",
[0xFF28] = "SID_LOGONCHALLENGE",
[0xFF1D] = "SID_LOGONCHALLENGEEX",
[0xFF3E] = "SID_LOGONREALMEX",
[0xFF29] = "SID_LOGONRESPONSE",
[0xFF3A] = "SID_LOGONRESPONSE2",
[0xFF19] = "SID_MESSAGEBOX",
[0xFF45] = "SID_NETGAMEPORT",
[0xFF46] = "SID_NEWS_INFO",
[0xFF22] = "SID_NOTIFYJOIN",
[0xFF00] = "SID_NULL",
[0xFF4A] = "SID_OPTIONALWORK",
[0xFF25] = "SID_PING",
[0xFF35] = "SID_PROFILE",
[0xFF41] = "SID_QUERYADURL",
[0xFF34] = "SID_QUERYREALMS",
[0xFF40] = "SID_QUERYREALMS2",
[0xFF26] = "SID_READUSERDATA",
[0xFF18] = "SID_REGISTRY",
[0xFF5D] = "SID_REPORTCRASH",
[0xFF07] = "SID_REPORTVERSION",
[0xFF4C] = "SID_REQUIREDWORK",
[0xFF5A] = "SID_RESETPASSWORD",
[0xFF04] = "SID_SERVERLIST",
[0xFF59] = "SID_SETEMAIL",
[0xFF08] = "SID_STARTADVEX",
[0xFF1A] = "SID_STARTADVEX2",
[0xFF1C] = "SID_STARTADVEX3",
[0xFF06] = "SID_STARTVERSIONING",
[0xFF3F] = "SID_STARTVERSIONING2",
[0xFF02] = "SID_STOPADV",
[0xFF5C] = "SID_SWITCHPRODUCT",
[0xFF2B] = "SID_SYSTEMINFO",
[0xFF4E] = "SID_TOURNAMENT",
[0xFF14] = "SID_UDPPINGRESPONSE",
[0xFF44] = "SID_WARCRAFTGENERAL",
[0xFF5E] = "SID_WARDEN",
[0xFF27] = "SID_WRITEUSERDATA",
}
local Descs = {
	YesNo = {
		[1] = "Yes",
		[0] = "No",
	},
}

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
		local version = function(arg)
			arg.big_endian = false
			return ipv4(arg)
		end
		local strdw = function(args,...)
			args = make_args_table(args, unpack(arg))
			args.reversed = true
			args.length = 4
			return stringz(args)
		end
		local array = function(arg)
			arg.repeated = arg.of
			arg.of = nil
			arg.priv = {size = arg.size}
			arg.size = nil
			arg.initialize = function (self, state)
				self.priv.index = 0
				self.priv.bn = state.bnet_node
				state.bnet_node = self.priv.bn:add(self.pf, state:peek(1))
				self.priv.start = state.used
			end
			arg.condition = function (self, state)
				return (self.priv.index < self.priv.size)
			end
			arg.iteration = function (self, state)
				dissect_packet(state, self.repeated)
				self.priv.index = self.priv.index + 1
			end
			arg.finalize = function (self, state)
				if state.bnet_node.set_len then
					state.bnet_node:set_len(state.used - self.priv.start)
				end
				state.bnet_node = self.priv.bn
			end
			return iterator(arg)
		end

SPacketDescription = {
[0xFF04] = {
	uint32{label="Server version", },
	iterator{
		label="Server list"
 		alias="bytes",
 		condition = function(self, state) return state.packet.srvr ~="" end,
 		repeated = {
 			WProtoField.stringz{label="Server", key="srvr"},
 		} 
 	}
},
[0xFF46] = {
	uint8{label="Number of entries", key="news" },
	unixtime{label="Last logon timestamp", },
	unixtime{label="Oldest news timestamp", },
	unixtime{label="Newest news timestamp", },
	iterator{alias="none", refkey="news", repeated={
		unixtime{label="Timestamp", key="stamp"},
		when{
			condition=function(self, state) return state.packet.stamp == 0 end,
			block = { stringz("MOTD") },
			otherwise = {stringz("News")},
		},
	}
},
[0xFF4A] = {
	stringz{label="MPQ Filename", },
},
[0x700A] = {
	uint32{label="Success", desc=Descs.YesNo},
},
[0xFF51] = {
	uint32{label="Result", },
	stringz{label="Additional Information", },
},
[0x7204] = {
	uint16{label="Request ID", },
	uint16{label="Game token", },
	uint16{label="Unknown", },
	uint32{label="IP of D2GS Server", },
	uint32{label="Game hash", },
	uint32{label="Result", },
},
[0xFF26] = {
	uint32{label="Number of accounts", },
	uint32{label="Number of keys", },
	uint32{label="Request ID", },
	stringz{label="[] Requested Key Values", },
},
[0x7005] = {
	uint32{label="Data for SID_AUTH_ACCOUNTCHANGE", num=8},
},
[0xFF7F] = {
	stringz{label="Username", },
	uint8{label="Rank", },
	uint8{label="Status", },
	stringz{label="Location", },
},
[0xFF69] = {
	uint8{label="Old Position", },
	uint8{label="New Position", },
},
[0xFF67] = {
	stringz{label="Account", },
	uint8{label="Friend Type", },
	uint8{label="Friend Status", },
	uint32{label="ProductID", },
	stringz{label="Location", },
},
[0xFF2D] = {
	wintime{label="Filetime", },
	stringz{label="Filename", },
},
[0x7001] = {
	uint32{label="Result", desc=Descs.YesNo},
	uint32{label="Client Token", },
	uint32{label="CD key data for SID_AUTH_CHECK", num=9},
},
[0x7305] = {
	stringz{label="Channel", },
},
[0x701A] = {
	uint32{label="Success*", desc=Descs.YesNo},
	uint32{label="Version.", },
	uint32{label="Checksum.", },
	stringz{label="Version check stat string.", },
	uint32{label="Cookie.", },
	uint32{label="The latest version code for this product.", },
},
[0xFF06] = {
	wintime{label="MPQ Filetime", },
	stringz{label="MPQ Filename", },
	stringz{label="ValueString", },
},
[0x7010] = {
	uint32{label="Productif Product is nonzero:", },
	uint32{label="Version byte", },
},
[0xFF52] = {
	uint32{label="Status", },
},
[0x7304] = {
	stringz{label="User", },
	stringz{label="Command", },
},
[0x7177] = {
	uint8{label="Request Type", },
},
[0xFF50] = {
	uint32{label="Logon Type", },
	uint32{label="Server Token", },
	uint32{label="UDPValue *", },
	wintime{label="MPQ filetime", },
	stringz{label="IX86ver filename", },
	stringz{label="ValueString", },
	bytes{label="128-byte Server signature", },
},
[0x7151] = {
	uint8{label="Object Type - Any information appreciated", },
	uint32{label="Object ID", },
	uint16{label="Object unique code", },
	uint16{label="X Coordinate", },
	uint16{label="Y Coordinate", },
	uint8{label="State *", },
	uint8{label="Interaction Condition", },
},
[0xFF08] = {
	uint32{label="Status", },
},
[0xFF75] = {
	uint8{label="Unknown", },
	uint32{label="Clan tag", },
	uint8{label="Rank", },
},
[0xFF65] = {
	uint8{label="Number of Entries", },
	stringz{label="Account", },
	uint8{label="Status", },
	uint8{label="Location", },
	uint32{label="ProductID", },
	stringz{label="Location name", },
},
[0xFF72] = {
	uint32{label="Cookie", },
	uint32{label="Clan Tag", },
	stringz{label="Clan Name", },
	stringz{label="Inviter's username", },
	uint8{label="Number of users being invited", },
	stringz{label="[] List of users being invited", },
},
[0xFF82] = {
	uint32{label="Cookie", },
	uint8{label="Status code", },
	stringz{label="Clan name", },
	uint8{label="User's rank", },
	wintime{label="Date joined", },
},
[0xFF28] = {
	uint32{label="Server Token", },
},
[0x7206] = {
	uint16{label="Request ID", },
	uint32{label="Status *", },
	uint32{label="Game Uptime", },
	uint16{label="Unknown", },
	uint8{label="Maximum players allowed", },
	uint8{label="Number of characters in the game", },
	uint8{label="[16] Classes of ingame characters **", },
	uint8{label="[16] Levels of ingame characters **", },
	uint8{label="Unused", },
	stringz{label="[16] Character names **", },
},
[0xFF25] = {
	uint32{label="Ping Value", },
},
[0x7405] = {
	uint32{label="UDP Code", },
},
[0x7014] = {
	uint32{label="Slot index.", },
	uint32{label="Success.", desc=Descs.YesNo},
	uint32{label="Data server's", num=5},
},
[0xFF1C] = {
	uint32{label="Status", },
},
[0xFF4C] = {
	stringz{label="ExtraWork MPQ FileName", },
},
[0x7004] = {
	uint32{label="Data for Data for SID_AUTH_ACCOUNTCREATE", num=16},
},
[0xFF36] = {
	uint32{label="Result", },
	stringz{label="Key owner", },
},
[0xFF0A] = {
	stringz{label="Unique name", },
	stringz{label="Statstring", },
	stringz{label="Account name", },
},
[0xFF30] = {
	uint32{label="Result", },
	stringz{label="Key owner", },
},
[0x7219] = {
	uint16{label="Number of characters requested", },
	uint32{label="Number of characters that exist on this account", },
	uint16{label="Number of characters returned", },
	uint32{label="Expiration Date", },
	stringz{label="Character name", },
	stringz{label="Character statstring", },
},
[0xFF33] = {
	uint32{label="Request ID", },
	uint32{label="Unknown", },
	wintime{label="Last update time", },
	stringz{label="Filename", },
},
[0x700F] = {
	uint32{label="Status code.", },
},
[0x7310] = {
	uint8{label="SubcommandFor subcommand 0:", },
	uint8{label="Setting for broadcast", },
	uint8{label="Setting for database", },
	uint8{label="Setting for whispers", },
	uint8{label="Refuse all", },
},
[0x7306] = {
	uint32{label="Bot number", },
	stringz{label="Bot name", },
	stringz{label="Bot channel", },
	uint32{label="Bot server", },
	stringz{label="Unique account name", },
	stringz{label="Current database", },
},
[0x7008] = {
	uint32{label="Data for SID_AUTH_ACCOUNTUPGRADEPROOF", num=22},
},
[0x7006] = {
	uint32{label="Data for SID_AUTH_ACCOUNTCHANGEPROOF", num=21},
},
[0x7301] = {
	uint32{label="Result", },
},
[0x730B] = {
	uint32{label="Command", },
	uint32{label="Action", },
	uint32{label="ID of source bot", },
	stringz{label="Message", },
},
[0x700D] = {
	uint32{label="Success code.", desc=Descs.YesNo},
},
[0xFF53] = {
	uint32{label="Status", },
	uint8{label="[32] Salt", },
	uint8{label="[32] Server Key", },
},
[0xFF77] = {
	uint32{label="Cookie", },
	uint8{label="Result", },
},
[0x7009] = {
	uint32{label="Success If Success is TRUE:", desc=Descs.YesNo},
	uint32{label="Version.", },
	uint32{label="Checksum.", },
	stringz{label="Version check stat string.", },
},
[0xFF7D] = {
	uint32{label="Cookie", },
	uint8{label="Number of Members", },
	stringz{label="Username", },
	uint8{label="Rank", },
	uint8{label="Online Status", },
	stringz{label="Location", },
},
[0xFF58] = {
	uint32{label="Status", },
	uint32{label="[5] Password proof", },
},
[0xFF31] = {
	uint32{label="Password change succeeded", desc=Descs.YesNo},
},
[0x711D] = {
	uint8{label="Attribute", },
	uint8{label="Amount", },
},
[0x711E] = {
	uint8{label="Attribute", },
	uint16{label="Amount", },
},
[0xFF59] = {
},
[0xFF2A] = {
	uint32{label="Result", },
},
[0x7307] = {
	uint32{label="Bot id", },
},
[0x7110] = {
	uint8{label="Unknown", },
	uint32{label="Player ID", },
	uint8{label="Movement Type", },
	uint8{label="Destination Type", },
	uint32{label="Object ID", },
	uint16{label="X Coordinate", },
	uint16{label="Y Coordinate", },
},
[0xFF79] = {
	uint32{label="Cookie", },
	uint32{label="Clan tag", },
	stringz{label="Clan name", },
	stringz{label="Inviter", },
},
[0x7217] = {
	uint16{label="Number of characters requested", },
	uint32{label="Number of characters that exist on this account", },
	uint16{label="Number of characters returned", },
	stringz{label="Character name", },
	stringz{label="Character statstring", },
},
[0xFF3E] = {
	uint32{label="MCP Cookie", },
	uint32{label="MCP Status", },
	uint32{label="[2] MCP Chunk 1", },
	uint32{label="IP", },
	uint32{label="Port", },
	uint32{label="[12] MCP Chunk 2", },
	stringz{label="Battle.net unique name", },
},
[0x7011] = {
	uint32{label="Success.", desc=Descs.YesNo},
},
[0xFF60] = {
	uint8{label="Number of players", },
	stringz{label="[] Player names", },
},
[0xFF13] = {
},
[0x7303] = {
	uint32{label="command", },
	stringz{label="usermask", },
	stringz{label="flags", },
	stringz{label="usermask", },
},
[0x71AF] = {
},
[0x7202] = {
	uint32{label="Result", },
},
[0xFF7A] = {
	uint32{label="Cookie", },
	uint8{label="Status", },
},
[0xFF35] = {
	uint32{label="Cookie", },
	uint8{label="Success", },
	stringz{label="Profile\\Description value", },
	stringz{label="Profile\\Location value", },
	uint32{label="Clan Tag", },
},
[0xFF2E] = {
	uint32{label="Ladder type", },
	uint32{label="League", },
	uint32{label="Sort method", },
	uint32{label="Starting rank", },
	uint32{label="Number of ranks listed", },
	uint32{label="Wins", },
	uint32{label="Losses", },
	uint32{label="Disconnects", },
	uint32{label="Rating", },
	uint32{label="Rank", },
	uint32{label="Official wins", },
	uint32{label="Official losses", },
	uint32{label="Official disconnects", },
	uint32{label="Official rating", },
	uint32{label="Unknown", },
	uint32{label="Official rank", },
	uint32{label="Unknown", },
	uint32{label="Unknown", },
	uint32{label="Highest rating", },
	uint32{label="Unknown", },
	uint32{label="Season", },
	wintime{label="Last game time", },
	wintime{label="Official last game time", },
	stringz{label="Name", },
},
[0xFF3D] = {
	uint32{label="Status", },
	stringz{label="Account name suggestion", },
},
[0xFF68] = {
	uint8{label="Entry Number", },
},
[0x717A] = {
	uint32{label="Unknown - Possible acceptance/request ID", },
},
[0xFF09] = {
	uint32{label="Number of games", },
	uint32{label="Status", },
	uint16{label="Game Type", },
	uint16{label="Parameter", },
	uint32{label="Language ID", },
	uint16{label="Address Family", },
	uint16{label="Port", },
	uint32{label="Host's IP", },
	uint32{label="sin_zero", },
	uint32{label="sin_zero", },
	uint32{label="Game Status", },
	uint32{label="Elapsed time", },
	stringz{label="Game name", },
	stringz{label="Game password", },
	stringz{label="Game statstring", },
},
[0x7119] = {
	uint8{label="Amount", },
},
[0xFF15] = {
	uint32{label="Ad ID", },
	uint32{label="File extension", },
	wintime{label="Local file time", },
	stringz{label="Filename", },
	stringz{label="Link URL", },
},
[0x715C] = {
},
[0xFF40] = {
	uint32{label="Unknown", },
	uint32{label="Count", },
	uint32{label="Unknown", },
	stringz{label="Realm title", },
	stringz{label="Realm description", },
},
[0xFF70] = {
	uint32{label="Cookie", },
	uint8{label="Status", },
	uint8{label="Number of potential candidates", },
	stringz{label="[] Usernames", },
},
[0xFF71] = {
	uint32{label="Cookie", },
	uint8{label="Result", },
	stringz{label="[] Failed account names", },
},
[0xFF1D] = {
	uint32{label="UDP Token", },
	uint32{label="Server Token", },
},
[0xFF41] = {
	uint32{label="Ad ID", },
	stringz{label="Ad URL", },
},
[0xFF44] = {
	uint8{label="Subcommand ID", },
	uint32{label="Cookie", },
	uint32{label="Icon ID", },
	uint8{label="Number of ladder records to read; this will be between 0", },
	uint32{label="Ladder type; valid types are 'SOLO', 'TEAM', or", },
	uint16{label="Number of wins", },
	uint16{label="Number of losses", },
	uint8{label="Level", },
	uint8{label="Hours until XP decay, if applicable*", },
	uint16{label="Experience", },
	uint32{label="Rank", },
	uint8{label="Number of race records to read; this will be 5 for WAR3", },
	uint16{label="Wins", },
	uint16{label="Losses", },
	uint8{label="Number of team records to read.", },
	uint32{label="Type of team; valid types are '2VS2', '3VS3', and", },
	uint16{label="Number of wins", },
	uint16{label="Number of losses", },
	uint8{label="Level", },
	uint8{label="Hours until XP decay, if applicable*", },
	uint16{label="Experience", },
	uint32{label="Rank", },
	wintime{label="Time of last game played", },
	uint8{label="Number of partners", },
	stringz{label="[] Names of partners", },
	uint32{label="Cookie", },
	uint8{label="Number of ladder records to read; this will be between 0", },
	uint32{label="Ladder type; valid types are 'SOLO', 'TEAM', or", },
	uint16{label="Number of wins", },
	uint16{label="Number of losses", },
	uint8{label="Level", },
	uint8{label="Hours until XP decay, if applicable*", },
	uint16{label="Experience", },
	uint32{label="Rank", },
	uint8{label="Number of race records to read; this will be 5 for WAR3", },
	uint16{label="Wins", },
	uint16{label="Losses", },
	uint32{label="Cookie", },
	uint32{label="Unknown", },
	uint8{label="Tiers", },
	uint8{label="Count", },
	uint32{label="Icon", },
	uint32{label="Name", },
	uint8{label="Race", },
	uint16{label="Wins required", },
	uint8{label="Unknown", },
},
[0xFF7E] = {
	stringz{label="Clan member name", },
},
[0x711F] = {
	uint8{label="Attribute - D2GS_SETWORDATTR", },
	uint32{label="Amount", },
},
[0xFF74] = {
	uint32{label="Cookie", },
	uint8{label="Status", },
},
[0xFF76] = {
	uint8{label="Status", },
},
[0xFF0F] = {
	uint32{label="Event ID", },
	uint32{label="User's Flags", },
	uint32{label="Ping", },
	uint32{label="IP Address", },
	uint32{label="Account number", },
	uint32{label="Registration Authority", },
	stringz{label="Username", },
	stringz{label="Text", },
},
[0x7214] = {
	uint32{label="Position", },
},
[0x7302] = {
	uint32{label="Result", },
},
[0xFF57] = {
	uint32{label="Status", },
	uint32{label="Server Token", },
},
[0x7300] = {
},
[0xFF29] = {
	uint32{label="Result", },
},
[0xFF3C] = {
	uint32{label="Result", },
},
[0xFF7C] = {
	uint32{label="Cookie", },
	uint32{label="Unknown", },
	stringz{label="MOTD", },
},
[0xFF34] = {
	uint32{label="Unknown", },
	uint32{label="Count", },
	uint32{label="Unknown", },
	stringz{label="Realm title", },
	stringz{label="Realm description", },
},
[0x7212] = {
	uint8{label="Unknown", },
	stringz{label="MOTD", },
},
[0x7002] = {
	uint32{label="[8] Data for SID_AUTH_ACCOUNTLOGON", },
},
[0xFF54] = {
	uint32{label="Status", },
	uint8{label="[20] Server Password Proof", },
	stringz{label="Additional information", },
},
[0xFF3F] = {
	wintime{label="MPQ Filetime", },
	stringz{label="MPQ Filename", },
	stringz{label="ValueString", },
},
[0x7207] = {
	uint32{label="Result", },
},
[0x7218] = {
	uint32{label="Result", },
},
[0xFF05] = {
	uint32{label="Registration Version", },
	uint32{label="Registration Authority", },
	uint32{label="Account Number", },
	uint32{label="Registration Token", },
},
[0xFF19] = {
	uint32{label="Style", },
	stringz{label="Text", },
	stringz{label="Caption", },
},
[0x7007] = {
	uint32{label="Success code.", desc=Descs.YesNo},
},
[0x7003] = {
	uint32{label="[5] Data for SID_AUTH_ACCOUNTLOGONPROOF", },
},
[0x7203] = {
	uint16{label="Request Id", },
	uint16{label="Game token", },
	uint16{label="Unknown", },
	uint32{label="Result", },
},
[0x7211] = {
	uint8{label="Ladder type", },
	uint16{label="Total response size", },
	uint16{label="Current message size", },
	uint16{label="Total size of unreceived messages", },
	uint16{label="Rank of first entry", },
	uint16{label="Unknown", },
	uint32{label="Number of entries", },
	uint32{label="Unknown", },
	uint64{label="Character experience", },
	uint8{label="Character Flags", },
	uint8{label="Character title", },
	uint16{label="Character level", },
	uint8{label="[16] Character name", },
},
[0x7012] = {
	uint32{label="Number of slots reserved", },
},
[0x700C] = {
	uint32{label="Cookie.", },
	uint8{label="Number of CD-keys requested.", },
	uint8{label="Number of", },
	uint32{label="Bit mask .For each successful", },
	uint32{label="Client session key.", },
	uint32{label="CD-key data.", num=9},
},
[0xFF0B] = {
	stringz{label="[] Channel names, each terminated by a null string.", },
},
[0x730D] = {
	uint32{label="Command", },
	uint32{label="Result", },
},
[0x7205] = {
	uint16{label="Request Id", },
	uint32{label="Index", },
	uint8{label="Number of players in game", },
	uint32{label="Status", },
	stringz{label="Game name", },
	stringz{label="Game description", },
},
[0x7018] = {
	uint32{label="Success*", desc=Descs.YesNo},
	uint32{label="Version.", },
	uint32{label="Checksum.", },
	stringz{label="Version check", },
	uint32{label="Cookie.", },
	uint32{label="The latest version code for this", },
},
[0xFF00] = {
},
[0x7201] = {
	uint32{label="Result", },
},
[0xFF78] = {
	uint32{label="Cookie", },
	uint8{label="Status", },
},
[0xFF3A] = {
	uint32{label="Result", },
	stringz{label="Reason", },
},
[0xFF56] = {
	uint32{label="Status code", },
	uint8{label="[20] Server password proof for old password", },
},
[0x700B] = {
	uint32{label="The data hash.Optional:", num=5},
	uint32{label="Cookie. Same as the cookie", },
},
[0xFF66] = {
	uint8{label="Entry number", },
	uint8{label="Friend Location", },
	uint8{label="Friend Status", },
	uint32{label="ProductID", },
	stringz{label="Location", },
},
[0x730A] = {
	uint32{label="Server Version", },
},
[0xFF18] = {
	uint32{label="Cookie", },
	uint32{label="HKEY", },
	stringz{label="Registry path", },
	stringz{label="Registry key", },
},
[0xFF2F] = {
	uint32{label="Rank. Zero-based. 0xFFFFFFFF == Not ranked.", },
},
[0xFF81] = {
	uint8{label="Old rank", },
	uint8{label="New rank", },
	stringz{label="Clan member who changed your rank", },
},
[0x700E] = {
	uint32{label="Server code.", },
},
[0xFF32] = {
	uint32{label="Status", },
},
[0xFF73] = {
	uint32{label="Cookie", },
	uint8{label="Result", },
},
[0x7013] = {
	uint32{label="Slot index.", },
	uint32{label="Data for server's SID_AUTH_ACCOUNTLOGON", num=16},
},
[0xFF55] = {
	uint32{label="Status", },
	uint8{label="[32] Salt", },
	uint8{label="[32] Server key", },
},
[0x720A] = {
	uint32{label="Result", },
},
[0xFF07] = {
	uint32{label="Result", },
	stringz{label="Patch path", },
},
[0xFF5E] = {
	bytes{label="Encrypted Packet", },
	uint8{label="Packet Code", },
	uint32{label="[4] MD5 Hash of the current Module", },
	uint32{label="[4] Decryption key for Module", },
	uint32{label="Length of Module", },
	uint16{label="Length of data", },
	bytes{label="Data", },
	uint8{label="String Length", },
	bytes{label="String Data", },
	uint8{label="Check ID", },
	uint8{label="String Index", },
	uint32{label="Address", },
	uint8{label="Length to Read", },
	uint32{label="Unknown", },
	uint32{label="[5] SHA1", },
	uint32{label="Address", },
	uint8{label="Length to Read", },
	uint8{label="IDXor", },
	uint16{label="Length of data", },
	uint32{label="Checksum of data", },
	uint8{label="Unknown", },
	uint8{label="Unknown", },
	uint8{label="Unknown", },
	stringz{label="Library Name", },
	uint32{label="Funct1", },
	uint32{label="Funct2", },
	uint32{label="Funct3", },
	uint32{label="Funct4", },
	uint32{label="[5] Unknown", },
},
[0xFF4E] = {
	uint8{label="Unknown", },
	uint8{label="Unknown, maybe number of non-null strings sent?", },
	stringz{label="Description", },
	stringz{label="Unknown", },
	stringz{label="Website", },
	uint32{label="Unknown", },
	stringz{label="Name", },
	stringz{label="Unknown", },
	stringz{label="Unknown", },
	stringz{label="Unknown", },
	uint32{label="Unknown", num=5},
},
[0x7189] = {
	uint8{label="EventId // see below,", },
},
}
CPacketDescription = {
[0x7218] = {
	stringz{label="Character Name", },
},
[0xFF5B] = {
	stringz{label="Account Name", },
	stringz{label="Old Email Address", },
	stringz{label="New Email Address", },
},
[0xFF55] = {
	uint8{label="[32] Client key", },
	stringz{label="Username", },
},
[0xFF18] = {
	uint32{label="Cookie", },
	stringz{label="Key Value", },
},
[0x7307] = {
	stringz{label="User", },
	stringz{label="Command", },
},
[0x710F] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[0x700A] = {
	uint32{label="Password proof from Battle.net.", num=5},
},
[0x7125] = {
	uint32{label="Item ID - Cursor buffer", },
	uint32{label="Item ID - Item to be replaced", },
},
[0x7217] = {
	uint32{label="Number of characters to list", },
},
[0xFF2D] = {
},
[0xFF27] = {
	uint32{label="Number of accounts", },
	uint32{label="Number of keys", },
	stringz{label="[] Accounts to update", },
	stringz{label="[] Keys to update", },
	stringz{label="[] New values", },
},
[0x711D] = {
	uint32{label="Item ID", },
	uint32{label="Body Location", },
},
[0x7101] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[0xFF73] = {
	uint32{label="Cookie", },
},
[0x7202] = {
	uint32{label="Character class", },
	uint16{label="Character flags", },
	stringz{label="Character name", },
},
[0x7168] = {
	uint32{label="D2GS Server Hash", },
	uint16{label="D2GS Server Token", },
	uint8{label="Character ID", },
	uint32{label="Version byte", },
	uint32{label="Unknown - Suggested Const", },
	uint32{label="Unknown - Suggested Const", },
	uint8{label="Unknown - Suggested", },
	stringz{label="Character name", },
	bytes{label="*See user-comment below", },
},
[0x7005] = {
	stringz{label="Account name.", },
	stringz{label="Account old password.", },
	stringz{label="Account", },
},
[0x711F] = {
	uint32{label="Item ID - Item to place in inventory", },
	uint32{label="Item ID - Item to be replaced", },
	uint32{label="X coordinate for replace", },
	uint32{label="Y coordinate for replace", },
},
[0xFF16] = {
	uint32{label="Ad ID", },
	uint32{label="Request type", },
},
[0x7116] = {
	uint32{label="Unit Type", },
	uint32{label="Unit ID", },
	uint32{label="Action ID", },
},
[0x7150] = {
	uint32{label="PlayerID", },
	uint32{label="GoldAmount", },
},
[0xFF78] = {
	uint32{label="Cookie", },
	stringz{label="Username", },
},
[0xFF41] = {
	uint32{label="Ad ID", },
},
[0xFF21] = {
	uint32{label="Platform ID", },
	uint32{label="Product ID", },
	uint32{label="Ad ID", },
	stringz{label="Filename", },
	stringz{label="URL", },
},
[0xFF3E] = {
	uint32{label="Client Token", },
	uint32{label="[5] Hashed realm password", },
	stringz{label="Realm title", },
},
[0xFF0A] = {
	stringz{label="Username *", },
	stringz{label="Statstring **", },
},
[0x7110] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[0xFF70] = {
	uint32{label="Cookie", },
	uint32{label="Clan Tag", },
},
[0x7003] = {
	uint32{label="[16] Data from SID_AUTH_ACCOUNTLOGON", },
},
[0x7207] = {
	stringz{label="Character name", },
},
[0x7018] = {
	uint32{label="Product ID.*", },
	uint32{label="Version DLL digit", },
	uint32{label="Flags.**", },
	uint32{label="Cookie.", },
	stringz{label="Checksum formula.", },
},
[0x7109] = {
	uint32{label="*Entity Type", },
	uint32{label="Entity ID", },
},
[0x7119] = {
	uint32{label="Item ID", },
},
[0xFF82] = {
	uint32{label="Cookie", },
	uint32{label="User's clan tag", },
	stringz{label="Username", },
},
[0xFF1A] = {
	uint32{label="Password Protected", },
	uint32{label="Unknown", },
	uint32{label="Unknown", },
	uint32{label="Unknown", },
	uint32{label="Unknown", },
	uint32{label="Port", },
	stringz{label="Game name", },
	stringz{label="Game password", },
	stringz{label="Unknown", },
	stringz{label="Game stats - Flags, Creator, Statstring", },
},
[0xFF2B] = {
	uint32{label="Number of processors", },
	uint32{label="Processor architecture", },
	uint32{label="Processor level", },
	uint32{label="Processor timing", },
	uint32{label="Total physical memory", },
	uint32{label="Total page file", },
	uint32{label="Free disk space", },
},
[0xFF7B] = {
	uint32{label="Cookie", },
	stringz{label="MOTD", },
},
[0x7130] = {
	uint32{label="Entity Type", },
	uint32{label="NPC ID", },
},
[0x7129] = {
	uint32{label="Item ID - Scroll", },
	uint32{label="Item ID - Tome", },
},
[0xFF30] = {
	uint32{label="Spawn", },
	stringz{label="CDKey", },
	stringz{label="Key Owner", },
},
[0x7302] = {
	stringz{label="Unique username on Battle.net", },
	stringz{label="Current channel on Battle.net", },
	uint32{label="Battle.net server IP address", },
	stringz{label="DatabaseID", },
	uint32{label="Cycle status", },
},
[0x7212] = {
},
[0x715E] = {
	uint16{label="Action ID", },
	uint32{label="Player ID", },
},
[0xFF00] = {
},
[0x7206] = {
	uint16{label="Request ID", },
	stringz{label="Game name", },
},
[0x7203] = {
	uint16{label="Request Id *", },
	uint32{label="Difficulty", },
	uint8{label="Unknown - 1", },
	uint8{label="Player difference **", },
	uint8{label="Maximum players", },
	stringz{label="Game name", },
	stringz{label="Game password", },
	stringz{label="Game description", },
},
[0x7001] = {
	uint32{label="Server Token", },
	stringz{label="CD key", },
},
[0x7010] = {
	uint32{label="ProductID", },
},
[0x7010] = {
	uint32{label="ProductID", },
},
[0x700F] = {
	uint32{label="Checksum.", },
},
[0xFF2C] = {
	uint32{label="Game type", },
	uint32{label="Number of results - always 8", },
	uint32{label="[8] Results", },
	stringz{label="[8] Game players - always 8", },
	stringz{label="Map name", },
	stringz{label="Player score", },
},
[0x710D] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[0xFF65] = {
},
[0x7106] = {
	uint32{label="*Entity Type", },
	uint32{label="Entity ID", },
},
[0xFF7A] = {
	uint32{label="Cookie", },
	stringz{label="Username", },
	uint8{label="New rank", },
},
[0xFF22] = {
	uint32{label="Product ID *", },
	uint32{label="Product version", },
	stringz{label="Game Name", },
	stringz{label="Game Password", },
},
[0x7409] = {
	uint32{label="Server Token", },
	uint32{label="UDP Token*", },
},
[0xFF57] = {
},
[0xFF1B] = {
	sockaddr{label="Address", },
},
[0x7008] = {
	uint32{label="Session key from SID_AUTH_ACCOUNTUPGRADE", },
},
[0x712F] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[0x730D] = {
	uint32{label="CommandFor Command 0x00", },
	stringz{label="Account name", },
	stringz{label="Account passwordFor Command 0x01", },
	stringz{label="Account", },
	stringz{label="Old password", },
	stringz{label="New passwordFor Command 0x02", },
	stringz{label="Account name", },
	stringz{label="Account password", },
},
[0x713F] = {
	uint16{label="Phrase ID", },
},
[0x7004] = {
	stringz{label="Account name.", },
	stringz{label="Account password.", },
},
[0x7132] = {
	uint32{label="NPC ID - Unconfirmed", },
	uint32{label="Item ID - Unconfirmed", },
	uint32{label="Buffer Type - Unconfirmed", },
	uint32{label="Cost", },
},
[0xFF79] = {
	uint32{label="Cookie", },
	uint32{label="Clan tag", },
	stringz{label="Inviter", },
	uint8{label="Response", },
},
[0x7204] = {
	uint16{label="Request ID", },
	stringz{label="Game name", },
	stringz{label="Game Password", },
},
[0xFF3A] = {
	uint32{label="Client Token", },
	uint32{label="Server Token", },
	uint32{label="[5] Password Hash", },
	stringz{label="Username", },
},
[0xFF3D] = {
	uint32{label="[5] Password hash", },
	stringz{label="Username", },
},
[0xFF0C] = {
	uint32{label="Flags", },
	stringz{label="Channel", },
},
[0x7301] = {
	stringz{label="BotID", },
	stringz{label="Bot Password", },
},
[0x7103] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[0xFF2F] = {
	uint32{label="League", },
	uint32{label="Sort method", },
	stringz{label="Username", },
},
[0x7408] = {
	uint32{label="Server Token", },
},
[0x7012] = {
	uint32{label="Number of slots to reserve", },
},
[0xFF4B] = {
	uint16{label="Game type", },
	uint16{label="Length", },
	stringz{label="Work returned data", },
},
[0xFF05] = {
	uint32{label="Registration Version", },
	uint32{label="Registration Authority", },
	uint32{label="Account Number", },
	uint32{label="Registration Token", },
	stringz{label="LAN Computer Name", },
	stringz{label="LAN Username", },
},
[0xFF46] = {
	uint32{label="News timestamp", },
},
[0xFF15] = {
	uint32{label="Platform ID", },
	uint32{label="Product ID", },
	uint32{label="ID of last displayed banner", },
	uint32{label="Current time", },
},
[0x7011] = {
	uint32{label="Server IP", },
	uint8{label="Signature", num=128},
},
[0x7014] = {
	uint32{label="Slot index.", },
	uint32{label="Data from client's", num=5},
	stringz{label="Client's account name.", },
},
[0xFF66] = {
	uint8{label="Friends list index", },
},
[0xFF74] = {
	uint32{label="Cookie", },
	stringz{label="New Cheiftain", },
},
[0x711B] = {
	uint32{label="Item ID", },
	uint32{label="Body Location", },
},
[0xFF71] = {
	uint32{label="Cookie", },
	stringz{label="Clan name", },
	uint32{label="Clan tag", },
	uint8{label="Number of users to invite", },
	stringz{label="[] Usernames to invite", },
},
[0x701A] = {
	uint32{label="Product ID.*", },
	uint32{label="Flags.**", },
	uint32{label="Cookie.", },
	uint64{label="Timestamp for version check archive.", },
	stringz{label="Version check archive filename.", },
	stringz{label="Checksum formula.", },
},
[0x7219] = {
	uint32{label="Number of characters to list.", },
},
[0xFF29] = {
	uint32{label="Client Token", },
	uint32{label="Server Token", },
	uint32{label="[5] Password Hash", },
	stringz{label="Username", },
},
[0x7304] = {
	stringz{label="User", },
	stringz{label="Command", },
},
[0xFF1C] = {
	uint32{label="State", },
	uint32{label="Time since creation", },
	uint16{label="Game Type", },
	uint16{label="Parameter", },
	uint32{label="Unknown", },
	uint32{label="Ladder", },
	stringz{label="Game name", },
	stringz{label="Game password", },
	stringz{label="Game Statstring", },
},
[0x712D] = {
},
[0xFF25] = {
	uint32{label="Ping Value", },
},
[0xFF56] = {
	uint8{label="[20] Old password proof", },
	uint8{label="[32] New password's salt", },
	uint8{label="[32] New password's verifier", },
},
[0xFF02] = {
},
[0xFF52] = {
	uint8{label="[32] Salt", },
	uint8{label="[32] Verifier", },
	stringz{label="Username", },
},
[0x7117] = {
	uint32{label="Item ID", },
},
[0x7124] = {
	uint32{label="Item ID", },
},
[0xFF50] = {
	uint32{label="Protocol ID", },
	uint32{label="Platform ID", },
	uint32{label="Product ID", },
	uint32{label="Version Byte", },
	uint32{label="Product language", },
	uint32{label="Local IP for NAT compatibility*", },
	uint32{label="Time zone bias*", },
	uint32{label="Locale ID*", },
	uint32{label="Language ID*", },
	stringz{label="Country abreviation", },
	stringz{label="Country", },
},
[0xFF3C] = {
	uint32{label="File size in bytes", },
	uint32{label="File hash [5]", },
	stringz{label="Filename", },
},
[0x7149] = {
	uint8{label="Waypoint ID", },
	uint8{label="Unknown - Appears to be random", },
	uint16{label="Unknown - 0x00", },
	uint8{label="Level number", },
	uint16{label="Unknown - 0x00", },
},
[0x710C] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[0x700D] = {
	uint32{label="NLS revision number.", },
},
[0x7123] = {
	uint32{label="Item ID", },
	uint32{label="Belt Location", },
},
[0xFF12] = {
	wintime{label="System time", },
	wintime{label="Local time", },
	uint32{label="Timezone bias", },
	uint32{label="SystemDefaultLCID", },
	uint32{label="UserDefaultLCID", },
	uint32{label="UserDefaultLangID", },
	stringz{label="Abbreviated language name", },
	stringz{label="Country name", },
	stringz{label="Abbreviated country name", },
	stringz{label="Country", },
},
[0xFF77] = {
	uint32{label="Cookie", },
	stringz{label="Target User", },
},
[0xFF7D] = {
	uint32{label="Cookie", },
},
[0xFF08] = {
	uint32{label="Password protected", desc=Descs.YesNo},
	uint32{label="Unknown", },
	uint32{label="Unknown", },
	uint32{label="Unknown", },
	uint32{label="Unknown", },
	uint32{label="Port", },
	stringz{label="Game name", },
	stringz{label="Game password", },
	stringz{label="Game stats - flags, creator, statstring", },
	stringz{label="Map name - 0x0d terminated", },
},
[0x700B] = {
	uint32{label="Size of Data", },
	uint32{label="Flags", },
	bytes{label="Data to be hashed.", },
	uint32{label="Client Key", },
	uint32{label="Server Key", },
	uint32{label="Cookie", },
},
[0x7300] = {
},
[0x7205] = {
	uint16{label="Request ID", },
	uint32{label="Unknown", },
	stringz{label="Search String *", },
},
[0x7108] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[0xFF2E] = {
	uint32{label="Product ID", },
	uint32{label="League", },
	uint32{label="Sort method", },
	uint32{label="Starting rank", },
	uint32{label="Number of ranks to list", },
},
[0x716A] = {
},
[0x7114] = {
	uint16{label="Unknown - 0x00, 0x00", },
	stringz{label="Message", },
	uint8{label="Unused - 0x00", },
	uint16{label="Unknown - 0x00, 0x00", },
},
[0xFF2A] = {
	uint32{label="[5] Hashed password", },
	stringz{label="Username", },
},
[0x7002] = {
	stringz{label="Account name", },
	stringz{label="Password", },
},
[0x730B] = {
	uint32{label="Command", },
	uint32{label="Action", },
	uint32{label="For Command 2, ID of destination", },
	stringz{label="Message", },
},
[0xFF60] = {
},
[0x7013] = {
	uint32{label="Slot index.", },
	uint32{label="NLS revision number.", },
	uint32{label="Data from", num=16},
	uint32{label="Data client's SID_AUTH_ACCOUNTLOGON", num=8},
},
[0x7213] = {
},
[0x711A] = {
	uint32{label="Item ID", },
	uint32{label="Body Location", },
},
[0xFF72] = {
	uint32{label="Cookie", },
	uint32{label="Clan tag", },
	stringz{label="Inviter name", },
	uint8{label="Status", },
},
[0x7201] = {
	uint32{label="MCP Cookie", },
	uint32{label="MCP Status", },
	uint32{label="[2] MCP Chunk 1", },
	uint32{label="[12] MCP Chunk 2", },
	stringz{label="Battle.net Unique Name", },
},
[0xFF40] = {
},
[0xFF53] = {
	uint8{label="[32] Client Key", },
	stringz{label="Username", },
},
[0x7006] = {
	uint32{label="Data from SID_AUTH_ACCOUNTCHANGE", num=16},
},
[0x7113] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[0x7403] = {
	uint32{label="Code", },
},
[0xFF59] = {
	stringz{label="Email Address", },
},
[0x720A] = {
	uint16{label="Unknown", },
	stringz{label="Character name", },
},
[0xFF34] = {
	uint32{label="Unused", },
	uint32{label="Unused", },
	stringz{label="Unknown", },
},
[0x7310] = {
	uint8{label="SubcommandFor subcommand 0:", },
	uint8{label="Setting for broadcast", },
	uint8{label="Setting for database", },
	uint8{label="Setting for whispers", },
	uint8{label="Refuse all", },
},
[0x7120] = {
	uint32{label="Item ID", },
	uint32{label="X coordinate", },
	uint32{label="Y coordinate", },
},
[0xFF31] = {
	uint32{label="Client Token", },
	uint32{label="Server Token", },
	uint32{label="[5] Old password hash", },
	uint32{label="[5] New password hash", },
	stringz{label="Account name", },
},
[0xFF10] = {
},
[0xFF1F] = {
},
[0xFF32] = {
	uint32{label="[5] File checksum", },
	stringz{label="File name", },
},
[0x700C] = {
	uint32{label="Cookie.", },
	uint8{label="Number of CD-keys to encrypt.", },
	uint32{label="Flags.", },
	uint32{label="Server session key", todo="verify array length"},
	uint32{label="Client session key", todo="verify array length"},
	stringz{label="CD-keys. No", todo="verify array length"},
},
[0x7128] = {
	uint32{label="Item ID - Item to place in socket", },
	uint32{label="Item ID - Socketed item", },
},
[0xFF07] = {
	uint32{label="Platform ID", },
	uint32{label="Product ID", },
	uint32{label="Version Byte", },
	uint32{label="EXE Version", },
	uint32{label="EXE Hash", },
	stringz{label="EXE Information", },
},
[0xFF45] = {
	uint16{label="Port", },
},
[0x716D] = {
	uint32{label="Tick Count", },
	uint32{label="Null", },
	uint32{label="Null", },
},
[0x7118] = {
	uint32{label="Item ID", },
	uint32{label="X coordinate", },
	uint32{label="Y coordinate", },
	uint32{label="Buffer Type", },
},
[0x7000] = {
},
[0x7308] = {
	uint32{label="Target BotID", },
	stringz{label="Sending User", },
	stringz{label="Command", },
},
[0xFF26] = {
	uint32{label="Number of Accounts", },
	uint32{label="Number of Keys", },
	uint32{label="Request ID", },
	stringz{label="[] Requested Accounts", },
	stringz{label="[] Requested Keys", },
},
[0xFF36] = {
	uint32{label="Spawn", },
	uint32{label="Key Length", },
	uint32{label="CDKey Product", },
	uint32{label="CDKey Value1", },
	uint32{label="Server Token", },
	uint32{label="Client Token", },
	uint32{label="[5] Hashed Data", },
	stringz{label="Key owner", },
},
[0xFF0E] = {
	stringz{label="Text", },
},
[0x7009] = {
	uint32{label="Product ID.", },
	uint32{label="Version DLL digit", },
	stringz{label="Checksum formula.", },
},
[0x7121] = {
	uint32{label="Item ID - Stack item", },
	uint32{label="Item ID - Target item", },
},
[0x7102] = {
	uint32{label="*Entity Type", },
	uint32{label="Entity ID", },
},
[0x7306] = {
},
[0x7161] = {
	uint16{label="Unknown - 0x00", },
},
[0xFF06] = {
	uint32{label="Platform ID", },
	uint32{label="Product ID", },
	uint32{label="Version Byte", },
	uint32{label="Unknown", },
},
[0x7133] = {
	uint32{label="NPC ID - Unconfirmed", },
	uint32{label="Item ID - Unconfirmed", },
	uint32{label="Buffer ID - Unconfirmed - Possible value 0x04", },
	uint32{label="Cost", },
},
[0xFF0B] = {
	uint32{label="Product ID", },
},
[0xFF54] = {
	uint8{label="[20] Client Password Proof", },
},
[0x7105] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[0xFF1E] = {
	uint32{label="Server Version", },
	uint32{label="Registration Version", },
	uint32{label="Registration Authority", },
	uint32{label="Registration Authority", },
	uint32{label="Registration Version", },
	uint32{label="Account Number", },
	uint32{label="Registration Token", },
	stringz{label="LAN computer name", },
	stringz{label="LAN username", },
},
[0xFF33] = {
	uint32{label="Request ID", },
	uint32{label="Unknown", },
	stringz{label="Filename", },
},
[0xFF09] = {
	uint16{label="Product-specific condition 1", },
	uint16{label="Product-specific condition 2", },
	uint32{label="Product-specific condition 3", },
	uint32{label="Product-specific condition 4", },
	uint32{label="List count", },
	stringz{label="Game name", },
	stringz{label="Game password", },
	stringz{label="Game stats", },
},
[0x7407] = {
	uint32{label="Tick count", },
},
[0x7126] = {
	uint32{label="Item ID", },
	uint32{label="Unknown - Possibly unused", },
	uint32{label="Unknown - Possibly unused", },
},
[0x7122] = {
	uint32{label="Item ID", },
},
[0xFF44] = {
	uint8{label="Subcommand ID", },
	uint32{label="Cookie", },
	uint8{label="Number of types requested", },
	uint32{label="[] Request data *", },
	uint32{label="Cookie", },
	stringz{label="Account name", },
	uint32{label="Product ID", },
	uint32{label="Cookie", },
	uint32{label="Clan Tag", },
	uint32{label="Product ID", },
	uint32{label="Cookie", },
	uint32{label="Icon", },
},
[0x7138] = {
	uint32{label="Trade Type - Unconfirmed", },
	uint32{label="NPC ID - Unconfirmed", },
	uint32{label="Unknown - Unconfirmed - Possible value 0x00", },
},
[0x7007] = {
	stringz{label="Account name.", },
	stringz{label="Account old password.", },
	stringz{label="Account", },
},
[0xFF7C] = {
	uint32{label="Cookie", },
},
[0x7104] = {
	uint32{label="*Entity Type", },
	uint32{label="Entity ID", },
},
[0x7303] = {
	uint32{label="Command", },
	stringz{label="Usermask", },
	stringz{label="Flags", },
	stringz{label="Usermask", },
},
[0x7305] = {
	uint32{label="Count", },
	stringz{label="Usernames to cycle", todo="maybe iterator"},
},
[0x7309] = {
	uint32{label="Password to change", },
	stringz{label="New password", },
},
[0xFF5A] = {
	stringz{label="Account Name", },
	stringz{label="Email Address", },
},
[0xFF14] = {
	uint32{label="UDPCode", },
},
[0xFF51] = {
	uint32{label="Client Token", },
	uint32{label="EXE Version", },
	uint32{label="EXE Hash", },
	uint32{label="Number of CD-keys in this packet", },
	uint32{label="Spawn CD-key", desc=Descs.YesNo},
	uint32{label="Key Length", },
	uint32{label="CD-key's product value", },
	uint32{label="CD-key's public value", },
	uint32{label="Unknown", },
	uint32{label="[5] Hashed Key Data", },
	stringz{label="Exe Information", },
	stringz{label="CD-Key owner name", },
},
[0xFF35] = {
	uint32{label="Cookie", },
	stringz{label="Username", },
},
[0x712A] = {
	uint32{label="Item ID", },
	uint32{label="Cube ID", },
},
[0x700E] = {
	stringz{label="Bot ID.", },
},
[0x7115] = {
	uint8{label="Message Type", },
	uint8{label="Unknown", },
	stringz{label="Message", },
	uint8{label="Unknown", },
	uint16{label="Unknown - Only if normal chat", },
	stringz{label="Player to whisper to - Only if whispering", },
	uint8{label="Unknown - Only if whispering", },
},
[0xFF5C] = {
	uint32{label="Product ID", },
},
[0x7107] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[0x710A] = {
	uint32{label="*Entity Type", },
	uint32{label="Entity ID", },
},
[0x7111] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[0x710E] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[0x711C] = {
	uint16{label="Body Location", },
},
[0xFF5E] = {
	bytes{label="Encrypted Packet", },
	uint8{label="Packet Code", },
	uint8{label="Success", },
	uint8{label="Success", },
	uint16{label="String Length", },
	uint32{label="String Checksum", },
	bytes{label="String Data", },
	uint8{label="Success", },
	bytes{label="Data", },
	uint8{label="Success", },
	uint8{label="IDXor", },
	uint32{label="[4] Unknown", },
},
[0xFF58] = {
	uint32{label="Client Token", },
	uint32{label="[5] Old Password Hash", },
	uint8{label="[32] New Password Salt", },
	uint8{label="[32] New Password Verifier", },
},
[0xFF5D] = {
	uint32{label="0x10A0027", },
	uint32{label="Exception code", },
	uint32{label="Unknown", },
	uint32{label="Unknown", },
},
[0x714F] = {
	uint32{label="Request ID", },
	uint16{label="Gold Amount", },
},
[0x7211] = {
	uint8{label="Ladder type", },
	uint16{label="Starting position", },
},
}
	end
end
