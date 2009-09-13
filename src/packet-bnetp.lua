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
			elseif v.key then
				state:error(v.key .. " key creation requested on a field type "
					.. "without a value method.")
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
			value = function (self, state)
				local val = state:peek(self.size())
				return val:le_uint()
			end,
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
				local epoch = 0xd53e8000 + (0x100000000 * 0x019db1de)
				local filetime = state:read(4):le_uint()
					+ (0x100000000 * state:read(4):le_uint())
				if filetime > epoch then
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
		local when = WProtoField.when
		local version = function(args, ...)
			args = make_args_table(args, unpack(arg))
			args.big_endian = false
			return ipv4(args)
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
	uint32("Server version"),
	iterator{
		label="Server list",
 		alias="bytes",
 		condition = function(self, state) return state.packet.srvr ~="" end,
 		repeated = {
 			WProtoField.stringz{label="Server", key="srvr"},
 		},
 	}
},
[0xFF46] = {
	uint8{label="Number of entries", key="news" },
	posixtime("Last logon timestamp"),
	posixtime("Oldest news timestamp"),
	posixtime("Newest news timestamp"),
	iterator{
		label="News",
		refkey="news", repeated={
		posixtime{label="Timestamp", key="stamp"},
		when{
			condition=function(self, state) return state.packet.stamp == 0 end,
			block = { stringz("MOTD") },
			otherwise = {stringz("News")},
		},},
	},
},
[0xFF4A] = {
	stringz("MPQ Filename"),
},
[0x700A] = {
	uint32{label="Success", desc=Descs.YesNo},
},
[0xFF51] = {
	uint32{label="Result", key="res", display = base.HEX, desc={
		[0x000] = "Passed challenge",
		[0x100] = "Old game version",
		[0x101] = "Invalid version",
		[0x102] = "Game version must be downgraded",
		[0x200] = "Invalid CD key",
		[0x201] = "CD key in use",
		[0x202] = "Banned key",
		[0x203] = "Wrong product",
		[0x210] = "Invalid CD key",
		[0x211] = "CD key in use",
		[0x212] = "Banned key",
		[0x213] = "Wrong product",
	}},
	when{
		condition=function(self, state)
			return (state.packet.res == 0x100) or (state.packet.res == 0x102)
		end,
		block = { stringz("MPQ Filename") },
	},
	when{
		condition=function(self, state)
			return bit.band(state.packet.res, 0x201) == 0x201
		end,
		block = { stringz("Username") },
	},
},
[0x7204] = {
	uint16("Request ID"),
	uint16("Game token"),
	uint16("Unknown"),
	ipv4("IP of D2GS Server"),
	uint32("Game hash"),
	uint32("Result", base.HEX, {
		[0x00] = "Game joining succeeded.",
		[0x29] = "Password incorrect.",
		[0x2A] = "Game does not exist.",
		[0x2B] = "Game is full.",
		[0x2C] = "You do not meet the level requirements for this game.",
		[0x6E] = "A dead hardcore character cannot join a game.",
		[0x71] = "A non-hardcore character cannot join a game created by a Hardcore character.",
		[0x73] = "Unable to join a Nightmare game.",
		[0x74] = "Unable to join a Hell game.",
		[0x78] = "A non-expansion character cannot join a game created by an Expansion character.",
		[0x79] = "A Expansion character cannot join a game created by a non-expansion character.",
		[0x7D] = "A non-ladder character cannot join a game created by a Ladder character.",
	}),
},
[0xFF26] = {
	uint32("Number of accounts"),
	uint32{label="Number of keys", key="numkeys"},
	uint32("Request ID"),
	iterator{
		refkey="numkeys",
		repeated={stringz("Requested Key Value")},
		label="Key Values",
	},
},
[0x7005] = {
	uint32{label="Data for SID_AUTH_ACCOUNTCHANGE", display=base.HEX, num=8},
},
[0xFF7F] = {
	stringz("Username"),
	uint8("Rank", base.DEC, {
		[0x00] = "Initiate that has been in the clan for less than one week",
		[0x01] = "Initiate that has been in the clan for over one week",
		[0x02] = "Member",
		[0x03] = "Officer",
		[0x04] = "Leader",
	}),
	uint8("Status", base.DEC, {
		[0x00] = "Offline",
		[0x01] = "Online (not in either channel or game)",
		[0x02] = "In a channel",
		[0x03] = "In a public game",
		[0x05] = "In a private game)",
	}),
	stringz("Location"),
},
[0xFF69] = {
	uint8("Old Position"),
	uint8("New Position"),
},
[0xFF67] = {
	stringz("Account"),
	uint8("Friend Type", base.DEC, {
		[0x00] = "Non-mutual",
		[0x01] = "Mutual",
		[0x02] = "Nonmutual, DND",
		[0x03] = "Mutual, DND",
		[0x04] = "Nonmutual, Away",
		[0x05] = "Mutual, Away",
	}),
	uint8("Friend Status", base.DEC, {
		[0x00] = "Offline",
		[0x02] = "In chat",
		[0x03] = "In public game",
		[0x05] = "In private game",
	}),
	uint32("ProductID", base.HEX),
	stringz("Location"),
},
[0xFF2D] = {
	wintime("Filetime"),
	stringz("Filename"),
},
[0x7001] = {
	uint32{label="Result", desc=Descs.YesNo},
	uint32("Client Token", base.HEX),
	uint32{label="CD key data for SID_AUTH_CHECK", num=9},
},
[0x7305] = {
	stringz("Channel"),
},
[0x701A] = {
	uint32{label="Success*", desc=Descs.YesNo},
	version("Version."),
	uint32("Checksum.", base.HEX),
	stringz("Version check stat string."),
	uint32("Cookie.", base.HEX),
	uint32("The latest version code for this product.", base.HEX),
},
[0xFF06] = {
	wintime("MPQ Filetime"),
	stringz("MPQ Filename"),
	stringz("ValueString"),
},
[0x7010] = {
	uint32{label="Product", key="prod"},
	when{
		condition=function(...) return arg[2].packet.prod ~= 0 end,
		block = {uint32("Version byte", base.HEX)},
	}
},
[0xFF52] = {
	uint32("Status"),
},
[0x7304] = {
	stringz("User"),
	stringz("Command"),
},
[0x7177] = {
	uint8("Request Type"),
},
[0xFF50] = {
	uint32("Logon Type"),
	uint32("Server Token"),
	uint32("UDPValue *"),
	wintime("MPQ filetime"),
	stringz("IX86ver filename"),
	stringz("ValueString"),
	bytes("128-byte Server signature"),
},
[0x7151] = {
	uint8("Object Type - Any information appreciated"),
	uint32("Object ID"),
	uint16("Object unique code"),
	uint16("X Coordinate"),
	uint16("Y Coordinate"),
	uint8("State *"),
	uint8("Interaction Condition"),
},
[0xFF08] = {
	uint32("Status"),
},
[0xFF75] = {
	uint8("Unknown"),
	uint32("Clan tag"),
	uint8("Rank"),
},
[0xFF65] = {
	uint8("Number of Entries"),
	stringz("Account"),
	uint8("Status"),
	uint8("Location"),
	uint32("ProductID"),
	stringz("Location name"),
},
[0xFF72] = {
	uint32("Cookie"),
	uint32("Clan Tag"),
	stringz("Clan Name"),
	stringz("Inviter's username"),
	uint8("Number of users being invited"),
	stringz("[] List of users being invited"),
},
[0xFF82] = {
	uint32("Cookie"),
	uint8("Status code"),
	stringz("Clan name"),
	uint8("User's rank"),
	wintime("Date joined"),
},
[0xFF28] = {
	uint32("Server Token"),
},
[0x7206] = {
	uint16("Request ID"),
	uint32("Status *"),
	uint32("Game Uptime"),
	uint16("Unknown"),
	uint8("Maximum players allowed"),
	uint8("Number of characters in the game"),
	uint8("[16] Classes of ingame characters **"),
	uint8("[16] Levels of ingame characters **"),
	uint8("Unused"),
	stringz("[16] Character names **"),
},
[0xFF25] = {
	uint32("Ping Value"),
},
[0x7405] = {
	uint32("UDP Code"),
},
[0x7014] = {
	uint32("Slot index."),
	uint32{label="Success.", desc=Descs.YesNo},
	uint32{label="Data server's", num=5},
},
[0xFF1C] = {
	uint32("Status"),
},
[0xFF4C] = {
	stringz("ExtraWork MPQ FileName"),
},
[0x7004] = {
	uint32{label="Data for Data for SID_AUTH_ACCOUNTCREATE", num=16},
},
[0xFF36] = {
	uint32("Result"),
	stringz("Key owner"),
},
[0xFF0A] = {
	stringz("Unique name"),
	stringz("Statstring"),
	stringz("Account name"),
},
[0xFF30] = {
	uint32("Result"),
	stringz("Key owner"),
},
[0x7219] = {
	uint16("Number of characters requested"),
	uint32("Number of characters that exist on this account"),
	uint16("Number of characters returned"),
	uint32("Expiration Date"),
	stringz("Character name"),
	stringz("Character statstring"),
},
[0xFF33] = {
	uint32("Request ID"),
	uint32("Unknown"),
	wintime("Last update time"),
	stringz("Filename"),
},
[0x700F] = {
	uint32("Status code."),
},
[0x7310] = {
	uint8("SubcommandFor subcommand 0:"),
	uint8("Setting for broadcast"),
	uint8("Setting for database"),
	uint8("Setting for whispers"),
	uint8("Refuse all"),
},
[0x7306] = {
	uint32("Bot number"),
	stringz("Bot name"),
	stringz("Bot channel"),
	uint32("Bot server"),
	stringz("Unique account name"),
	stringz("Current database"),
},
[0x7008] = {
	uint32{label="Data for SID_AUTH_ACCOUNTUPGRADEPROOF", num=22},
},
[0x7006] = {
	uint32{label="Data for SID_AUTH_ACCOUNTCHANGEPROOF", num=21},
},
[0x7301] = {
	uint32("Result"),
},
[0x730B] = {
	uint32("Command"),
	uint32("Action"),
	uint32("ID of source bot"),
	stringz("Message"),
},
[0x700D] = {
	uint32{label="Success code.", desc=Descs.YesNo},
},
[0xFF53] = {
	uint32("Status"),
	uint8("[32] Salt"),
	uint8("[32] Server Key"),
},
[0xFF77] = {
	uint32("Cookie"),
	uint8("Result"),
},
[0x7009] = {
	uint32{label="Success If Success is TRUE:", desc=Descs.YesNo},
	uint32("Version."),
	uint32("Checksum."),
	stringz("Version check stat string."),
},
[0xFF7D] = {
	uint32("Cookie"),
	uint8("Number of Members"),
	stringz("Username"),
	uint8("Rank"),
	uint8("Online Status"),
	stringz("Location"),
},
[0xFF58] = {
	uint32("Status"),
	uint32("[5] Password proof"),
},
[0xFF31] = {
	uint32{label="Password change succeeded", desc=Descs.YesNo},
},
[0x711D] = {
	uint8("Attribute"),
	uint8("Amount"),
},
[0x711E] = {
	uint8("Attribute"),
	uint16("Amount"),
},
[0xFF59] = {
},
[0xFF2A] = {
	uint32("Result"),
},
[0x7307] = {
	uint32("Bot id"),
},
[0x7110] = {
	uint8("Unknown"),
	uint32("Player ID"),
	uint8("Movement Type"),
	uint8("Destination Type"),
	uint32("Object ID"),
	uint16("X Coordinate"),
	uint16("Y Coordinate"),
},
[0xFF79] = {
	uint32("Cookie"),
	uint32("Clan tag"),
	stringz("Clan name"),
	stringz("Inviter"),
},
[0x7217] = {
	uint16("Number of characters requested"),
	uint32("Number of characters that exist on this account"),
	uint16("Number of characters returned"),
	stringz("Character name"),
	stringz("Character statstring"),
},
[0xFF3E] = {
	uint32("MCP Cookie"),
	uint32("MCP Status"),
	uint32("[2] MCP Chunk 1"),
	uint32("IP"),
	uint32("Port"),
	uint32("[12] MCP Chunk 2"),
	stringz("Battle.net unique name"),
},
[0x7011] = {
	uint32{label="Success.", desc=Descs.YesNo},
},
[0xFF60] = {
	uint8("Number of players"),
	stringz("[] Player names"),
},
[0xFF13] = {
},
[0x7303] = {
	uint32("command"),
	stringz("usermask"),
	stringz("flags"),
	stringz("usermask"),
},
[0x71AF] = {
},
[0x7202] = {
	uint32("Result"),
},
[0xFF7A] = {
	uint32("Cookie"),
	uint8("Status"),
},
[0xFF35] = {
	uint32("Cookie"),
	uint8("Success"),
	stringz("Profile\\Description value"),
	stringz("Profile\\Location value"),
	uint32("Clan Tag"),
},
[0xFF2E] = {
	uint32("Ladder type"),
	uint32("League"),
	uint32("Sort method"),
	uint32("Starting rank"),
	uint32("Number of ranks listed"),
	uint32("Wins"),
	uint32("Losses"),
	uint32("Disconnects"),
	uint32("Rating"),
	uint32("Rank"),
	uint32("Official wins"),
	uint32("Official losses"),
	uint32("Official disconnects"),
	uint32("Official rating"),
	uint32("Unknown"),
	uint32("Official rank"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Highest rating"),
	uint32("Unknown"),
	uint32("Season"),
	wintime("Last game time"),
	wintime("Official last game time"),
	stringz("Name"),
},
[0xFF3D] = {
	uint32("Status"),
	stringz("Account name suggestion"),
},
[0xFF68] = {
	uint8("Entry Number"),
},
[0x717A] = {
	uint32("Unknown - Possible acceptance/request ID"),
},
[0xFF09] = {
	uint32("Number of games"),
	uint32("Status"),
	uint16("Game Type"),
	uint16("Parameter"),
	uint32("Language ID"),
	uint16("Address Family"),
	uint16("Port"),
	uint32("Host's IP"),
	uint32("sin_zero"),
	uint32("sin_zero"),
	uint32("Game Status"),
	uint32("Elapsed time"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game statstring"),
},
[0x7119] = {
	uint8("Amount"),
},
[0xFF15] = {
	uint32("Ad ID"),
	uint32("File extension"),
	wintime("Local file time"),
	stringz("Filename"),
	stringz("Link URL"),
},
[0x715C] = {
},
[0xFF40] = {
	uint32("Unknown"),
	uint32("Count"),
	uint32("Unknown"),
	stringz("Realm title"),
	stringz("Realm description"),
},
[0xFF70] = {
	uint32("Cookie"),
	uint8("Status"),
	uint8("Number of potential candidates"),
	stringz("[] Usernames"),
},
[0xFF71] = {
	uint32("Cookie"),
	uint8("Result"),
	stringz("[] Failed account names"),
},
[0xFF1D] = {
	uint32("UDP Token"),
	uint32("Server Token"),
},
[0xFF41] = {
	uint32("Ad ID"),
	stringz("Ad URL"),
},
[0xFF44] = {
	uint8("Subcommand ID"),
	uint32("Cookie"),
	uint32("Icon ID"),
	uint8("Number of ladder records to read; this will be between 0"),
	uint32("Ladder type; valid types are 'SOLO', 'TEAM', or"),
	uint16("Number of wins"),
	uint16("Number of losses"),
	uint8("Level"),
	uint8("Hours until XP decay, if applicable*"),
	uint16("Experience"),
	uint32("Rank"),
	uint8("Number of race records to read; this will be 5 for WAR3"),
	uint16("Wins"),
	uint16("Losses"),
	uint8("Number of team records to read."),
	uint32("Type of team; valid types are '2VS2', '3VS3', and"),
	uint16("Number of wins"),
	uint16("Number of losses"),
	uint8("Level"),
	uint8("Hours until XP decay, if applicable*"),
	uint16("Experience"),
	uint32("Rank"),
	wintime("Time of last game played"),
	uint8("Number of partners"),
	stringz("[] Names of partners"),
	uint32("Cookie"),
	uint8("Number of ladder records to read; this will be between 0"),
	uint32("Ladder type; valid types are 'SOLO', 'TEAM', or"),
	uint16("Number of wins"),
	uint16("Number of losses"),
	uint8("Level"),
	uint8("Hours until XP decay, if applicable*"),
	uint16("Experience"),
	uint32("Rank"),
	uint8("Number of race records to read; this will be 5 for WAR3"),
	uint16("Wins"),
	uint16("Losses"),
	uint32("Cookie"),
	uint32("Unknown"),
	uint8("Tiers"),
	uint8("Count"),
	uint32("Icon"),
	uint32("Name"),
	uint8("Race"),
	uint16("Wins required"),
	uint8("Unknown"),
},
[0xFF7E] = {
	stringz("Clan member name"),
},
[0x711F] = {
	uint8("Attribute - D2GS_SETWORDATTR"),
	uint32("Amount"),
},
[0xFF74] = {
	uint32("Cookie"),
	uint8("Status"),
},
[0xFF76] = {
	uint8("Status"),
},
[0xFF0F] = {
	uint32("Event ID"),
	uint32("User's Flags"),
	uint32("Ping"),
	uint32("IP Address"),
	uint32("Account number"),
	uint32("Registration Authority"),
	stringz("Username"),
	stringz("Text"),
},
[0x7214] = {
	uint32("Position"),
},
[0x7302] = {
	uint32("Result"),
},
[0xFF57] = {
	uint32("Status"),
	uint32("Server Token"),
},
[0x7300] = {
},
[0xFF29] = {
	uint32("Result"),
},
[0xFF3C] = {
	uint32("Result"),
},
[0xFF7C] = {
	uint32("Cookie"),
	uint32("Unknown"),
	stringz("MOTD"),
},
[0xFF34] = {
	uint32("Unknown"),
	uint32("Count"),
	uint32("Unknown"),
	stringz("Realm title"),
	stringz("Realm description"),
},
[0x7212] = {
	uint8("Unknown"),
	stringz("MOTD"),
},
[0x7002] = {
	uint32("[8] Data for SID_AUTH_ACCOUNTLOGON"),
},
[0xFF54] = {
	uint32("Status"),
	uint8("[20] Server Password Proof"),
	stringz("Additional information"),
},
[0xFF3F] = {
	wintime("MPQ Filetime"),
	stringz("MPQ Filename"),
	stringz("ValueString"),
},
[0x7207] = {
	uint32("Result"),
},
[0x7218] = {
	uint32("Result"),
},
[0xFF05] = {
	uint32("Registration Version"),
	uint32("Registration Authority"),
	uint32("Account Number"),
	uint32("Registration Token"),
},
[0xFF19] = {
	uint32("Style"),
	stringz("Text"),
	stringz("Caption"),
},
[0x7007] = {
	uint32{label="Success code.", desc=Descs.YesNo},
},
[0x7003] = {
	uint32("[5] Data for SID_AUTH_ACCOUNTLOGONPROOF"),
},
[0x7203] = {
	uint16("Request Id"),
	uint16("Game token"),
	uint16("Unknown"),
	uint32("Result"),
},
[0x7211] = {
	uint8("Ladder type"),
	uint16("Total response size"),
	uint16("Current message size"),
	uint16("Total size of unreceived messages"),
	uint16("Rank of first entry"),
	uint16("Unknown"),
	uint32("Number of entries"),
	uint32("Unknown"),
	uint64("Character experience"),
	uint8("Character Flags"),
	uint8("Character title"),
	uint16("Character level"),
	uint8("[16] Character name"),
},
[0x7012] = {
	uint32("Number of slots reserved"),
},
[0x700C] = {
	uint32("Cookie."),
	uint8("Number of CD-keys requested."),
	uint8("Number of"),
	uint32("Bit mask .For each successful"),
	uint32("Client session key."),
	uint32{label="CD-key data.", num=9},
},
[0xFF0B] = {
	stringz("[] Channel names, each terminated by a null string."),
},
[0x730D] = {
	uint32("Command"),
	uint32("Result"),
},
[0x7205] = {
	uint16("Request Id"),
	uint32("Index"),
	uint8("Number of players in game"),
	uint32("Status"),
	stringz("Game name"),
	stringz("Game description"),
},
[0x7018] = {
	uint32{label="Success*", desc=Descs.YesNo},
	uint32("Version."),
	uint32("Checksum."),
	stringz("Version check"),
	uint32("Cookie."),
	uint32("The latest version code for this"),
},
[0xFF00] = {
},
[0x7201] = {
	uint32("Result"),
},
[0xFF78] = {
	uint32("Cookie"),
	uint8("Status"),
},
[0xFF3A] = {
	uint32("Result"),
	stringz("Reason"),
},
[0xFF56] = {
	uint32("Status code"),
	uint8("[20] Server password proof for old password"),
},
[0x700B] = {
	uint32{label="The data hash.Optional:", num=5},
	uint32("Cookie. Same as the cookie"),
},
[0xFF66] = {
	uint8("Entry number"),
	uint8("Friend Location"),
	uint8("Friend Status"),
	uint32("ProductID"),
	stringz("Location"),
},
[0x730A] = {
	uint32("Server Version"),
},
[0xFF18] = {
	uint32("Cookie"),
	uint32("HKEY"),
	stringz("Registry path"),
	stringz("Registry key"),
},
[0xFF2F] = {
	uint32("Rank. Zero-based. 0xFFFFFFFF == Not ranked."),
},
[0xFF81] = {
	uint8("Old rank"),
	uint8("New rank"),
	stringz("Clan member who changed your rank"),
},
[0x700E] = {
	uint32("Server code."),
},
[0xFF32] = {
	uint32("Status"),
},
[0xFF73] = {
	uint32("Cookie"),
	uint8("Result"),
},
[0x7013] = {
	uint32("Slot index."),
	uint32{label="Data for server's SID_AUTH_ACCOUNTLOGON", num=16},
},
[0xFF55] = {
	uint32("Status"),
	uint8("[32] Salt"),
	uint8("[32] Server key"),
},
[0x720A] = {
	uint32("Result"),
},
[0xFF07] = {
	uint32("Result"),
	stringz("Patch path"),
},
[0xFF5E] = {
	bytes("Encrypted Packet"),
	uint8("Packet Code"),
	uint32("[4] MD5 Hash of the current Module"),
	uint32("[4] Decryption key for Module"),
	uint32("Length of Module"),
	uint16("Length of data"),
	bytes("Data"),
	uint8("String Length"),
	bytes("String Data"),
	uint8("Check ID"),
	uint8("String Index"),
	uint32("Address"),
	uint8("Length to Read"),
	uint32("Unknown"),
	uint32("[5] SHA1"),
	uint32("Address"),
	uint8("Length to Read"),
	uint8("IDXor"),
	uint16("Length of data"),
	uint32("Checksum of data"),
	uint8("Unknown"),
	uint8("Unknown"),
	uint8("Unknown"),
	stringz("Library Name"),
	uint32("Funct1"),
	uint32("Funct2"),
	uint32("Funct3"),
	uint32("Funct4"),
	uint32("[5] Unknown"),
},
[0xFF4E] = {
	uint8("Unknown"),
	uint8("Unknown, maybe number of non-null strings sent?"),
	stringz("Description"),
	stringz("Unknown"),
	stringz("Website"),
	uint32("Unknown"),
	stringz("Name"),
	stringz("Unknown"),
	stringz("Unknown"),
	stringz("Unknown"),
	uint32{label="Unknown", num=5},
},
[0x7189] = {
	uint8("EventId // see below,"),
},
}
CPacketDescription = {
[0x7218] = {
	stringz("Character Name"),
},
[0xFF5B] = {
	stringz("Account Name"),
	stringz("Old Email Address"),
	stringz("New Email Address"),
},
[0xFF55] = {
	uint8("[32] Client key"),
	stringz("Username"),
},
[0xFF18] = {
	uint32("Cookie"),
	stringz("Key Value"),
},
[0x7307] = {
	stringz("User"),
	stringz("Command"),
},
[0x710F] = {
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0x700A] = {
	uint32{label="Password proof from Battle.net.", num=5},
},
[0x7125] = {
	uint32("Item ID - Cursor buffer"),
	uint32("Item ID - Item to be replaced"),
},
[0x7217] = {
	uint32("Number of characters to list"),
},
[0xFF2D] = {
},
[0xFF27] = {
	uint32("Number of accounts"),
	uint32("Number of keys"),
	stringz("[] Accounts to update"),
	stringz("[] Keys to update"),
	stringz("[] New values"),
},
[0x711D] = {
	uint32("Item ID"),
	uint32("Body Location"),
},
[0x7101] = {
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0xFF73] = {
	uint32("Cookie"),
},
[0x7202] = {
	uint32("Character class"),
	uint16("Character flags"),
	stringz("Character name"),
},
[0x7168] = {
	uint32("D2GS Server Hash"),
	uint16("D2GS Server Token"),
	uint8("Character ID"),
	uint32("Version byte"),
	uint32("Unknown - Suggested Const"),
	uint32("Unknown - Suggested Const"),
	uint8("Unknown - Suggested"),
	stringz("Character name"),
	bytes("*See user-comment below"),
},
[0x7005] = {
	stringz("Account name."),
	stringz("Account old password."),
	stringz("Account"),
},
[0x711F] = {
	uint32("Item ID - Item to place in inventory"),
	uint32("Item ID - Item to be replaced"),
	uint32("X coordinate for replace"),
	uint32("Y coordinate for replace"),
},
[0xFF16] = {
	uint32("Ad ID"),
	uint32("Request type"),
},
[0x7116] = {
	uint32("Unit Type"),
	uint32("Unit ID"),
	uint32("Action ID"),
},
[0x7150] = {
	uint32("PlayerID"),
	uint32("GoldAmount"),
},
[0xFF78] = {
	uint32("Cookie"),
	stringz("Username"),
},
[0xFF41] = {
	uint32("Ad ID"),
},
[0xFF21] = {
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("Ad ID"),
	stringz("Filename"),
	stringz("URL"),
},
[0xFF3E] = {
	uint32("Client Token"),
	uint32("[5] Hashed realm password"),
	stringz("Realm title"),
},
[0xFF0A] = {
	stringz("Username *"),
	stringz("Statstring **"),
},
[0x7110] = {
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0xFF70] = {
	uint32("Cookie"),
	uint32("Clan Tag"),
},
[0x7003] = {
	uint32("[16] Data from SID_AUTH_ACCOUNTLOGON"),
},
[0x7207] = {
	stringz("Character name"),
},
[0x7018] = {
	uint32("Product ID.*"),
	uint32("Version DLL digit"),
	uint32("Flags.**"),
	uint32("Cookie."),
	stringz("Checksum formula."),
},
[0x7109] = {
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
[0x7119] = {
	uint32("Item ID"),
},
[0xFF82] = {
	uint32("Cookie"),
	uint32("User's clan tag"),
	stringz("Username"),
},
[0xFF1A] = {
	uint32("Password Protected"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Port"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Unknown"),
	stringz("Game stats - Flags, Creator, Statstring"),
},
[0xFF2B] = {
	uint32("Number of processors"),
	uint32("Processor architecture"),
	uint32("Processor level"),
	uint32("Processor timing"),
	uint32("Total physical memory"),
	uint32("Total page file"),
	uint32("Free disk space"),
},
[0xFF7B] = {
	uint32("Cookie"),
	stringz("MOTD"),
},
[0x7130] = {
	uint32("Entity Type"),
	uint32("NPC ID"),
},
[0x7129] = {
	uint32("Item ID - Scroll"),
	uint32("Item ID - Tome"),
},
[0xFF30] = {
	uint32("Spawn"),
	stringz("CDKey"),
	stringz("Key Owner"),
},
[0x7302] = {
	stringz("Unique username on Battle.net"),
	stringz("Current channel on Battle.net"),
	uint32("Battle.net server IP address"),
	stringz("DatabaseID"),
	uint32("Cycle status"),
},
[0x7212] = {
},
[0x715E] = {
	uint16("Action ID"),
	uint32("Player ID"),
},
[0xFF00] = {
},
[0x7206] = {
	uint16("Request ID"),
	stringz("Game name"),
},
[0x7203] = {
	uint16("Request Id *"),
	uint32("Difficulty"),
	uint8("Unknown - 1"),
	uint8("Player difference **"),
	uint8("Maximum players"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game description"),
},
[0x7001] = {
	uint32("Server Token"),
	stringz("CD key"),
},
[0x7010] = {
	uint32("ProductID"),
},
[0x7010] = {
	uint32("ProductID"),
},
[0x700F] = {
	uint32("Checksum."),
},
[0xFF2C] = {
	uint32("Game type"),
	uint32("Number of results - always 8"),
	uint32("[8] Results"),
	stringz("[8] Game players - always 8"),
	stringz("Map name"),
	stringz("Player score"),
},
[0x710D] = {
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0xFF65] = {
},
[0x7106] = {
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
[0xFF7A] = {
	uint32("Cookie"),
	stringz("Username"),
	uint8("New rank"),
},
[0xFF22] = {
	uint32("Product ID *"),
	uint32("Product version"),
	stringz("Game Name"),
	stringz("Game Password"),
},
[0x7409] = {
	uint32("Server Token"),
	uint32("UDP Token*"),
},
[0xFF57] = {
},
[0xFF1B] = {
	sockaddr("Address"),
},
[0x7008] = {
	uint32("Session key from SID_AUTH_ACCOUNTUPGRADE"),
},
[0x712F] = {
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x730D] = {
	uint32("CommandFor Command 0x00"),
	stringz("Account name"),
	stringz("Account passwordFor Command 0x01"),
	stringz("Account"),
	stringz("Old password"),
	stringz("New passwordFor Command 0x02"),
	stringz("Account name"),
	stringz("Account password"),
},
[0x713F] = {
	uint16("Phrase ID"),
},
[0x7004] = {
	stringz("Account name."),
	stringz("Account password."),
},
[0x7132] = {
	uint32("NPC ID - Unconfirmed"),
	uint32("Item ID - Unconfirmed"),
	uint32("Buffer Type - Unconfirmed"),
	uint32("Cost"),
},
[0xFF79] = {
	uint32("Cookie"),
	uint32("Clan tag"),
	stringz("Inviter"),
	uint8("Response"),
},
[0x7204] = {
	uint16("Request ID"),
	stringz("Game name"),
	stringz("Game Password"),
},
[0xFF3A] = {
	uint32("Client Token"),
	uint32("Server Token"),
	uint32("[5] Password Hash"),
	stringz("Username"),
},
[0xFF3D] = {
	uint32("[5] Password hash"),
	stringz("Username"),
},
[0xFF0C] = {
	uint32("Flags"),
	stringz("Channel"),
},
[0x7301] = {
	stringz("BotID"),
	stringz("Bot Password"),
},
[0x7103] = {
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0xFF2F] = {
	uint32("League"),
	uint32("Sort method"),
	stringz("Username"),
},
[0x7408] = {
	uint32("Server Token"),
},
[0x7012] = {
	uint32("Number of slots to reserve"),
},
[0xFF4B] = {
	uint16("Game type"),
	uint16("Length"),
	stringz("Work returned data"),
},
[0xFF05] = {
	uint32("Registration Version"),
	uint32("Registration Authority"),
	uint32("Account Number"),
	uint32("Registration Token"),
	stringz("LAN Computer Name"),
	stringz("LAN Username"),
},
[0xFF46] = {
	uint32("News timestamp"),
},
[0xFF15] = {
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("ID of last displayed banner"),
	uint32("Current time"),
},
[0x7011] = {
	uint32("Server IP"),
	uint8{label="Signature", num=128},
},
[0x7014] = {
	uint32("Slot index."),
	uint32{label="Data from client's", num=5},
	stringz("Client's account name."),
},
[0xFF66] = {
	uint8("Friends list index"),
},
[0xFF74] = {
	uint32("Cookie"),
	stringz("New Cheiftain"),
},
[0x711B] = {
	uint32("Item ID"),
	uint32("Body Location"),
},
[0xFF71] = {
	uint32("Cookie"),
	stringz("Clan name"),
	uint32("Clan tag"),
	uint8("Number of users to invite"),
	stringz("[] Usernames to invite"),
},
[0x701A] = {
	uint32("Product ID.*"),
	uint32("Flags.**"),
	uint32("Cookie."),
	uint64("Timestamp for version check archive."),
	stringz("Version check archive filename."),
	stringz("Checksum formula."),
},
[0x7219] = {
	uint32("Number of characters to list."),
},
[0xFF29] = {
	uint32("Client Token"),
	uint32("Server Token"),
	uint32("[5] Password Hash"),
	stringz("Username"),
},
[0x7304] = {
	stringz("User"),
	stringz("Command"),
},
[0xFF1C] = {
	uint32("State"),
	uint32("Time since creation"),
	uint16("Game Type"),
	uint16("Parameter"),
	uint32("Unknown"),
	uint32("Ladder"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game Statstring"),
},
[0x712D] = {
},
[0xFF25] = {
	uint32("Ping Value"),
},
[0xFF56] = {
	uint8("[20] Old password proof"),
	uint8("[32] New password's salt"),
	uint8("[32] New password's verifier"),
},
[0xFF02] = {
},
[0xFF52] = {
	uint8("[32] Salt"),
	uint8("[32] Verifier"),
	stringz("Username"),
},
[0x7117] = {
	uint32("Item ID"),
},
[0x7124] = {
	uint32("Item ID"),
},
[0xFF50] = {
	uint32("Protocol ID"),
	strdw("Platform ID"),
	strdw("Product ID"),
	uint32("Version Byte"),
	strdw("Product language"),
	ipv4("Local IP for NAT compatibility"),
	uint32("Time zone bias"),
	uint32("Locale ID"),
	uint32("Language ID"),
	stringz("Country abreviation"),
	stringz("Country"),
},
[0xFF3C] = {
	uint32("File size in bytes"),
	uint32("File hash [5]"),
	stringz("Filename"),
},
[0x7149] = {
	uint8("Waypoint ID"),
	uint8("Unknown - Appears to be random"),
	uint16("Unknown - 0x00"),
	uint8("Level number"),
	uint16("Unknown - 0x00"),
},
[0x710C] = {
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0x700D] = {
	uint32("NLS revision number."),
},
[0x7123] = {
	uint32("Item ID"),
	uint32("Belt Location"),
},
[0xFF12] = {
	wintime("System time"),
	wintime("Local time"),
	uint32("Timezone bias"),
	uint32("SystemDefaultLCID"),
	uint32("UserDefaultLCID"),
	uint32("UserDefaultLangID"),
	stringz("Abbreviated language name"),
	stringz("Country name"),
	stringz("Abbreviated country name"),
	stringz("Country"),
},
[0xFF77] = {
	uint32("Cookie"),
	stringz("Target User"),
},
[0xFF7D] = {
	uint32("Cookie"),
},
[0xFF08] = {
	uint32{label="Password protected", desc=Descs.YesNo},
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Port"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game stats - flags, creator, statstring"),
	stringz("Map name - 0x0d terminated"),
},
[0x700B] = {
	uint32("Size of Data"),
	uint32("Flags"),
	bytes("Data to be hashed."),
	uint32("Client Key"),
	uint32("Server Key"),
	uint32("Cookie"),
},
[0x7300] = {
},
[0x7205] = {
	uint16("Request ID"),
	uint32("Unknown"),
	stringz("Search String *"),
},
[0x7108] = {
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0xFF2E] = {
	uint32("Product ID"),
	uint32("League"),
	uint32("Sort method"),
	uint32("Starting rank"),
	uint32("Number of ranks to list"),
},
[0x716A] = {
},
[0x7114] = {
	uint16("Unknown - 0x00, 0x00"),
	stringz("Message"),
	uint8("Unused - 0x00"),
	uint16("Unknown - 0x00, 0x00"),
},
[0xFF2A] = {
	uint32("[5] Hashed password"),
	stringz("Username"),
},
[0x7002] = {
	stringz("Account name"),
	stringz("Password"),
},
[0x730B] = {
	uint32("Command"),
	uint32("Action"),
	uint32("For Command 2, ID of destination"),
	stringz("Message"),
},
[0xFF60] = {
},
[0x7013] = {
	uint32("Slot index."),
	uint32("NLS revision number."),
	uint32{label="Data from", num=16},
	uint32{label="Data client's SID_AUTH_ACCOUNTLOGON", num=8},
},
[0x7213] = {
},
[0x711A] = {
	uint32("Item ID"),
	uint32("Body Location"),
},
[0xFF72] = {
	uint32("Cookie"),
	uint32("Clan tag"),
	stringz("Inviter name"),
	uint8("Status"),
},
[0x7201] = {
	uint32("MCP Cookie"),
	uint32("MCP Status"),
	uint32("[2] MCP Chunk 1"),
	uint32("[12] MCP Chunk 2"),
	stringz("Battle.net Unique Name"),
},
[0xFF40] = {
},
[0xFF53] = {
	uint8("[32] Client Key"),
	stringz("Username"),
},
[0x7006] = {
	uint32{label="Data from SID_AUTH_ACCOUNTCHANGE", num=16},
},
[0x7113] = {
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x7403] = {
	uint32("Code"),
},
[0xFF59] = {
	stringz("Email Address"),
},
[0x720A] = {
	uint16("Unknown"),
	stringz("Character name"),
},
[0xFF34] = {
	uint32("Unused"),
	uint32("Unused"),
	stringz("Unknown"),
},
[0x7310] = {
	uint8("SubcommandFor subcommand 0:"),
	uint8("Setting for broadcast"),
	uint8("Setting for database"),
	uint8("Setting for whispers"),
	uint8("Refuse all"),
},
[0x7120] = {
	uint32("Item ID"),
	uint32("X coordinate"),
	uint32("Y coordinate"),
},
[0xFF31] = {
	uint32("Client Token"),
	uint32("Server Token"),
	uint32("[5] Old password hash"),
	uint32("[5] New password hash"),
	stringz("Account name"),
},
[0xFF10] = {
},
[0xFF1F] = {
},
[0xFF32] = {
	uint32("[5] File checksum"),
	stringz("File name"),
},
[0x700C] = {
	uint32("Cookie."),
	uint8("Number of CD-keys to encrypt."),
	uint32("Flags."),
	uint32{label="Server session key", todo="verify array length"},
	uint32{label="Client session key", todo="verify array length"},
	stringz{label="CD-keys. No", todo="verify array length"},
},
[0x7128] = {
	uint32("Item ID - Item to place in socket"),
	uint32("Item ID - Socketed item"),
},
[0xFF07] = {
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("Version Byte"),
	uint32("EXE Version"),
	uint32("EXE Hash"),
	stringz("EXE Information"),
},
[0xFF45] = {
	uint16("Port"),
},
[0x716D] = {
	uint32("Tick Count"),
	uint32("Null"),
	uint32("Null"),
},
[0x7118] = {
	uint32("Item ID"),
	uint32("X coordinate"),
	uint32("Y coordinate"),
	uint32("Buffer Type"),
},
[0x7000] = {
},
[0x7308] = {
	uint32("Target BotID"),
	stringz("Sending User"),
	stringz("Command"),
},
[0xFF26] = {
	uint32("Number of Accounts"),
	uint32("Number of Keys"),
	uint32("Request ID"),
	stringz("[] Requested Accounts"),
	stringz("[] Requested Keys"),
},
[0xFF36] = {
	uint32("Spawn"),
	uint32("Key Length"),
	uint32("CDKey Product"),
	uint32("CDKey Value1"),
	uint32("Server Token"),
	uint32("Client Token"),
	uint32("[5] Hashed Data"),
	stringz("Key owner"),
},
[0xFF0E] = {
	stringz("Text"),
},
[0x7009] = {
	uint32("Product ID."),
	uint32("Version DLL digit"),
	stringz("Checksum formula."),
},
[0x7121] = {
	uint32("Item ID - Stack item"),
	uint32("Item ID - Target item"),
},
[0x7102] = {
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
[0x7306] = {
},
[0x7161] = {
	uint16("Unknown - 0x00"),
},
[0xFF06] = {
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("Version Byte"),
	uint32("Unknown"),
},
[0x7133] = {
	uint32("NPC ID - Unconfirmed"),
	uint32("Item ID - Unconfirmed"),
	uint32("Buffer ID - Unconfirmed - Possible value 0x04"),
	uint32("Cost"),
},
[0xFF0B] = {
	uint32("Product ID"),
},
[0xFF54] = {
	uint8("[20] Client Password Proof"),
},
[0x7105] = {
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0xFF1E] = {
	uint32("Server Version"),
	uint32("Registration Version"),
	uint32("Registration Authority"),
	uint32("Registration Authority"),
	uint32("Registration Version"),
	uint32("Account Number"),
	uint32("Registration Token"),
	stringz("LAN computer name"),
	stringz("LAN username"),
},
[0xFF33] = {
	uint32("Request ID"),
	uint32("Unknown"),
	stringz("Filename"),
},
[0xFF09] = {
	uint16("Product-specific condition 1"),
	uint16("Product-specific condition 2"),
	uint32("Product-specific condition 3"),
	uint32("Product-specific condition 4"),
	uint32("List count"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game stats"),
},
[0x7407] = {
	uint32("Tick count"),
},
[0x7126] = {
	uint32("Item ID"),
	uint32("Unknown - Possibly unused"),
	uint32("Unknown - Possibly unused"),
},
[0x7122] = {
	uint32("Item ID"),
},
[0xFF44] = {
	uint8("Subcommand ID"),
	uint32("Cookie"),
	uint8("Number of types requested"),
	uint32("[] Request data *"),
	uint32("Cookie"),
	stringz("Account name"),
	uint32("Product ID"),
	uint32("Cookie"),
	uint32("Clan Tag"),
	uint32("Product ID"),
	uint32("Cookie"),
	uint32("Icon"),
},
[0x7138] = {
	uint32("Trade Type - Unconfirmed"),
	uint32("NPC ID - Unconfirmed"),
	uint32("Unknown - Unconfirmed - Possible value 0x00"),
},
[0x7007] = {
	stringz("Account name."),
	stringz("Account old password."),
	stringz("Account"),
},
[0xFF7C] = {
	uint32("Cookie"),
},
[0x7104] = {
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
[0x7303] = {
	uint32("Command"),
	stringz("Usermask"),
	stringz("Flags"),
	stringz("Usermask"),
},
[0x7305] = {
	uint32("Count"),
	stringz{label="Usernames to cycle", todo="maybe iterator"},
},
[0x7309] = {
	uint32("Password to change"),
	stringz("New password"),
},
[0xFF5A] = {
	stringz("Account Name"),
	stringz("Email Address"),
},
[0xFF14] = {
	uint32("UDPCode"),
},
[0xFF51] = {
	uint32("Client Token"),
	uint32("EXE Version"),
	uint32("EXE Hash"),
	uint32("Number of CD-keys in this packet"),
	uint32{label="Spawn CD-key", desc=Descs.YesNo},
	uint32("Key Length"),
	uint32("CD-key's product value"),
	uint32("CD-key's public value"),
	uint32("Unknown"),
	uint32("[5] Hashed Key Data"),
	stringz("Exe Information"),
	stringz("CD-Key owner name"),
},
[0xFF35] = {
	uint32("Cookie"),
	stringz("Username"),
},
[0x712A] = {
	uint32("Item ID"),
	uint32("Cube ID"),
},
[0x700E] = {
	stringz("Bot ID."),
},
[0x7115] = {
	uint8("Message Type"),
	uint8("Unknown"),
	stringz("Message"),
	uint8("Unknown"),
	uint16("Unknown - Only if normal chat"),
	stringz("Player to whisper to - Only if whispering"),
	uint8("Unknown - Only if whispering"),
},
[0xFF5C] = {
	uint32("Product ID"),
},
[0x7107] = {
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x710A] = {
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
[0x7111] = {
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x710E] = {
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x711C] = {
	uint16("Body Location"),
},
[0xFF5E] = {
	bytes("Encrypted Packet"),
	uint8("Packet Code"),
	uint8("Success"),
	uint8("Success"),
	uint16("String Length"),
	uint32("String Checksum"),
	bytes("String Data"),
	uint8("Success"),
	bytes("Data"),
	uint8("Success"),
	uint8("IDXor"),
	uint32("[4] Unknown"),
},
[0xFF58] = {
	uint32("Client Token"),
	uint32("[5] Old Password Hash"),
	uint8("[32] New Password Salt"),
	uint8("[32] New Password Verifier"),
},
[0xFF5D] = {
	uint32("0x10A0027"),
	uint32("Exception code"),
	uint32("Unknown"),
	uint32("Unknown"),
},
[0x714F] = {
	uint32("Request ID"),
	uint16("Gold Amount"),
},
[0x7211] = {
	uint8("Ladder type"),
	uint16("Starting position"),
},
}
	end
end
