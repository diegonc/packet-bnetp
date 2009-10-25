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
				local pdu_start = state.used
				state.bnet_node = root:add(p_bnetp, buf(state.used))

				local thread = coroutine.create(do_dissection)
				local r, need_more, missing = coroutine.resume(thread, state)
				if (r and (need_more == NEED_MORE)) then
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
					return
				elseif r and (need_more==ENOUGH) and (missing==REJECTED) then
					available = state.used
				elseif not r then
					error(need_more)
				end
				if state.bnet_node.set_len then
					state.bnet_node:set_len(state.used - pdu_start)
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
[0x7000] = "BNLS_NULL",
[0x7001] = "BNLS_CDKEY",
[0x7002] = "BNLS_LOGONCHALLENGE",
[0x7003] = "BNLS_LOGONPROOF",
[0x7004] = "BNLS_CREATEACCOUNT",
[0x7005] = "BNLS_CHANGECHALLENGE",
[0x7006] = "BNLS_CHANGEPROOF",
[0x7007] = "BNLS_UPGRADECHALLENGE",
[0x7008] = "BNLS_UPGRADEPROOF",
[0x7009] = "BNLS_VERSIONCHECK",
[0x700A] = "BNLS_CONFIRMLOGON",
[0x700B] = "BNLS_HASHDATA",
[0x700C] = "BNLS_CDKEY_EX",
[0x700D] = "BNLS_CHOOSENLSREVISION",
[0x700E] = "BNLS_AUTHORIZE",
[0x700F] = "BNLS_AUTHORIZEPROOF",
[0x7010] = "BNLS_REQUESTVERSIONBYTE",
[0x7011] = "BNLS_VERIFYSERVER",
[0x7012] = "BNLS_RESERVESERVERSLOTS",
[0x7013] = "BNLS_SERVERLOGONCHALLENGE",
[0x7014] = "BNLS_SERVERLOGONPROOF",
[0x7018] = "BNLS_VERSIONCHECKEX",
[0x701A] = "BNLS_VERSIONCHECKEX2",
[0x8010] = "D2GS_CHARTOOBJ",
[0x8019] = "D2GS_SMALLGOLDPICKUP",
[0x801D] = "D2GS_SETBYTEATTR",
[0x801E] = "D2GS_SETWORDATTR",
[0x801F] = "D2GS_SETDWORDATTR",
[0x8051] = "D2GS_WORLDOBJECT",
[0x805C] = "D2GS_COMPSTARTGAME",
[0x8077] = "D2GS_TRADEACTION",
[0x807A] = "D2GS_LOGONRESPONSE",
[0x8089] = "D2GS_UNIQUEEVENTS",
[0x80AF] = "D2GS_STARTLOGON",
[0x8101] = "D2GS_WALKTOLOCATION",
[0x8102] = "D2GS_WALKTOENTITY",
[0x8103] = "D2GS_RUNTOLOCATION",
[0x8104] = "D2GS_RUNTOENTITY",
[0x8105] = "D2GS_LEFTSKILLONLOCATION",
[0x8106] = "D2GS_LEFTSKILLONENTITY",
[0x8107] = "D2GS_LEFTSKILLONENTITYEX",
[0x8108] = "D2GS_LEFTSKILLONLOCATIONEX",
[0x8109] = "D2GS_LEFTSKILLONENTITYEX2",
[0x810A] = "D2GS_LEFTSKILLONENTITYEX3",
[0x810C] = "D2GS_RIGHTSKILLONLOCATION",
[0x810D] = "D2GS_RIGHTSKILLONENTITY",
[0x810E] = "D2GS_RIGHTSKILLONENTITYEX",
[0x810F] = "D2GS_RIGHTSKILLONLOCATIONEX",
[0x8110] = "D2GS_RIGHTSKILLONENTITYEX2",
[0x8111] = "D2GS_RIGHTSKILLONENTITYEX3",
[0x8113] = "D2GS_INTERACTWITHENTITY",
[0x8114] = "D2GS_OVERHEADMESSAGE",
[0x8115] = "D2GS_CHATMESSAGE",
[0x8116] = "D2GS_PICKUPITEM",
[0x8117] = "D2GS_DROPITEM",
[0x8118] = "D2GS_ITEMTOBUFFER",
[0x8119] = "D2GS_PICKUPBUFFERITEM",
[0x811A] = "D2GS_ITEMTOBODY",
[0x811B] = "D2GS_SWAP2HANDEDITEM",
[0x811C] = "D2GS_PICKUPBODYITEM",
[0x811D] = "D2GS_SWITCHBODYITEM",
[0x811F] = "D2GS_SWITCHINVENTORYITEM",
[0x8120] = "D2GS_USEITEM",
[0x8121] = "D2GS_STACKITEM",
[0x8122] = "D2GS_REMOVESTACKITEM",
[0x8123] = "D2GS_ITEMTOBELT",
[0x8124] = "D2GS_REMOVEBELTITEM",
[0x8125] = "D2GS_SWITCHBELTITEM",
[0x8126] = "D2GS_USEBELTITEM",
[0x8128] = "D2GS_INSERTSOCKETITEM",
[0x8129] = "D2GS_SCROLLTOTOME",
[0x812A] = "D2GS_ITEMTOCUBE",
[0x812D] = "D2GS_UNSELECTOBJ",
[0x812F] = "D2GS_NPCINIT",
[0x8130] = "D2GS_NPCCANCEL",
[0x8132] = "D2GS_NPCBUY",
[0x8133] = "D2GS_NPCSELL",
[0x8138] = "D2GS_NPCTRADE",
[0x813F] = "D2GS_CHARACTERPHRASE",
[0x8149] = "D2GS_WAYPOINT",
[0x814F] = "D2GS_TRADE",
[0x8150] = "D2GS_DROPGOLD",
[0x815E] = "D2GS_PARTY",
[0x8161] = "D2GS_POTIONTOMERCENARY",
[0x8168] = "D2GS_GAMELOGON",
[0x816A] = "D2GS_ENTERGAMEENVIRONMENT",
[0x816D] = "D2GS_PING",
[0x9001] = "MCP_STARTUP",
[0x9002] = "MCP_CHARCREATE",
[0x9003] = "MCP_CREATEGAME",
[0x9004] = "MCP_JOINGAME",
[0x9005] = "MCP_GAMELIST",
[0x9006] = "MCP_GAMEINFO",
[0x9007] = "MCP_CHARLOGON",
[0x900A] = "MCP_CHARDELETE",
[0x9011] = "MCP_REQUESTLADDERDATA",
[0x9012] = "MCP_MOTD",
[0x9013] = "MCP_CANCELGAMECREATE",
[0x9014] = "MCP_CREATEQUEUE",
[0x9017] = "MCP_CHARLIST",
[0x9018] = "MCP_CHARUPGRADE",
[0x9019] = "MCP_CHARLIST2",
[0xA000] = "PACKET_IDLE",
[0xA001] = "PACKET_LOGON",
[0xA002] = "PACKET_STATSUPDATE",
[0xA003] = "PACKET_DATABASE",
[0xA004] = "PACKET_MESSAGE",
[0xA005] = "PACKET_CYCLE",
[0xA006] = "PACKET_USERINFO",
[0xA007] = "PACKET_BROADCASTMESSAGE",
[0xA008] = "PACKET_COMMAND",
[0xA009] = "PACKET_CHANGEDBPASSWORD",
[0xA00A] = "PACKET_BOTNETVERSION",
[0xA00B] = "PACKET_BOTNETCHAT",
[0xA00D] = "PACKET_ACCOUNT",
[0xA010] = "PACKET_CHATDROPOPTIONS",
[0xB003] = "PKT_CLIENTREQ",
[0xB005] = "PKT_SERVERPING",
[0xB007] = "PKT_KEEPALIVE",
[0xB008] = "PKT_CONNTEST",
[0xB009] = "PKT_CONNTEST2",
[0xCE07] = "PACKET_USERLOGGINGOFF",
[0xFF00] = "SID_NULL",
[0xFF02] = "SID_STOPADV",
[0xFF04] = "SID_SERVERLIST",
[0xFF05] = "SID_CLIENTID",
[0xFF06] = "SID_STARTVERSIONING",
[0xFF07] = "SID_REPORTVERSION",
[0xFF08] = "SID_STARTADVEX",
[0xFF09] = "SID_GETADVLISTEX",
[0xFF0A] = "SID_ENTERCHAT",
[0xFF0B] = "SID_GETCHANNELLIST",
[0xFF0C] = "SID_JOINCHANNEL",
[0xFF0E] = "SID_CHATCOMMAND",
[0xFF0F] = "SID_CHATEVENT",
[0xFF10] = "SID_LEAVECHAT",
[0xFF12] = "SID_LOCALEINFO",
[0xFF13] = "SID_FLOODDETECTED",
[0xFF14] = "SID_UDPPINGRESPONSE",
[0xFF15] = "SID_CHECKAD",
[0xFF16] = "SID_CLICKAD",
[0xFF18] = "SID_REGISTRY",
[0xFF19] = "SID_MESSAGEBOX",
[0xFF1A] = "SID_STARTADVEX2",
[0xFF1B] = "SID_GAMEDATAADDRESS",
[0xFF1C] = "SID_STARTADVEX3",
[0xFF1D] = "SID_LOGONCHALLENGEEX",
[0xFF1E] = "SID_CLIENTID2",
[0xFF1F] = "SID_LEAVEGAME",
[0xFF21] = "SID_DISPLAYAD",
[0xFF22] = "SID_NOTIFYJOIN",
[0xFF25] = "SID_PING",
[0xFF26] = "SID_READUSERDATA",
[0xFF27] = "SID_WRITEUSERDATA",
[0xFF28] = "SID_LOGONCHALLENGE",
[0xFF29] = "SID_LOGONRESPONSE",
[0xFF2A] = "SID_CREATEACCOUNT",
[0xFF2B] = "SID_SYSTEMINFO",
[0xFF2C] = "SID_GAMERESULT",
[0xFF2D] = "SID_GETICONDATA",
[0xFF2E] = "SID_GETLADDERDATA",
[0xFF2F] = "SID_FINDLADDERUSER",
[0xFF30] = "SID_CDKEY",
[0xFF31] = "SID_CHANGEPASSWORD",
[0xFF32] = "SID_CHECKDATAFILE",
[0xFF33] = "SID_GETFILETIME",
[0xFF34] = "SID_QUERYREALMS",
[0xFF35] = "SID_PROFILE",
[0xFF36] = "SID_CDKEY2",
[0xFF3A] = "SID_LOGONRESPONSE2",
[0xFF3C] = "SID_CHECKDATAFILE2",
[0xFF3D] = "SID_CREATEACCOUNT2",
[0xFF3E] = "SID_LOGONREALMEX",
[0xFF3F] = "SID_STARTVERSIONING2",
[0xFF40] = "SID_QUERYREALMS2",
[0xFF41] = "SID_QUERYADURL",
[0xFF44] = "SID_WARCRAFTGENERAL",
[0xFF45] = "SID_NETGAMEPORT",
[0xFF46] = "SID_NEWS_INFO",
[0xFF4A] = "SID_OPTIONALWORK",
[0xFF4B] = "SID_EXTRAWORK",
[0xFF4C] = "SID_REQUIREDWORK",
[0xFF4E] = "SID_TOURNAMENT",
[0xFF50] = "SID_AUTH_INFO",
[0xFF51] = "SID_AUTH_CHECK",
[0xFF52] = "SID_AUTH_ACCOUNTCREATE",
[0xFF53] = "SID_AUTH_ACCOUNTLOGON",
[0xFF54] = "SID_AUTH_ACCOUNTLOGONPROOF",
[0xFF55] = "SID_AUTH_ACCOUNTCHANGE",
[0xFF56] = "SID_AUTH_ACCOUNTCHANGEPROOF",
[0xFF57] = "SID_AUTH_ACCOUNTUPGRADE",
[0xFF58] = "SID_AUTH_ACCOUNTUPGRADEPROOF",
[0xFF59] = "SID_SETEMAIL",
[0xFF5A] = "SID_RESETPASSWORD",
[0xFF5B] = "SID_CHANGEEMAIL",
[0xFF5C] = "SID_SWITCHPRODUCT",
[0xFF5D] = "SID_REPORTCRASH",
[0xFF5E] = "SID_WARDEN",
[0xFF60] = "SID_GAMEPLAYERSEARCH",
[0xFF65] = "SID_FRIENDSLIST",
[0xFF66] = "SID_FRIENDSUPDATE",
[0xFF67] = "SID_FRIENDSADD",
[0xFF68] = "SID_FRIENDSREMOVE",
[0xFF69] = "SID_FRIENDSPOSITION",
[0xFF70] = "SID_CLANFINDCANDIDATES",
[0xFF71] = "SID_CLANINVITEMULTIPLE",
[0xFF72] = "SID_CLANCREATIONINVITATION",
[0xFF73] = "SID_CLANDISBAND",
[0xFF74] = "SID_CLANMAKECHIEFTAIN",
[0xFF75] = "SID_CLANINFO",
[0xFF76] = "SID_CLANQUITNOTIFY",
[0xFF77] = "SID_CLANINVITATION",
[0xFF78] = "SID_CLANREMOVEMEMBER",
[0xFF79] = "SID_CLANINVITATIONRESPONSE",
[0xFF7A] = "SID_CLANRANKCHANGE",
[0xFF7B] = "SID_CLANSETMOTD",
[0xFF7C] = "SID_CLANMOTD",
[0xFF7D] = "SID_CLANMEMBERLIST",
[0xFF7E] = "SID_CLANMEMBERREMOVED",
[0xFF7F] = "SID_CLANMEMBERSTATUSCHANGE",
[0xFF81] = "SID_CLANMEMBERRANKCHANGE",
[0xFF82] = "SID_CLANMEMBERINFORMATION",
}
local Descs = {
	YesNo = {
		[1] = "Yes",
		[0] = "No",
	},
	
	ClientTag = {
		["SEXP"] = "S EXP",
	},

	GameStatus = {
		[0x00] = "OK",
		[0x01] = "Game doesn't exist",
		[0x02] = "Incorrect password",
		[0x03] = "Game full",
		[0x04] = "Game already started",
		[0x06] = "Too many server requests",
	},
	LocaleID = {
		[11276] = "French (Cameroon)",
		[1025] = "Arabic (Saudi Arabia)",
		[1026] = "Bulgarian",
		[1027] = "Catalan",
		[1028] = "Chinese (Taiwan)",
		[1029] = "Czech",
		[1030] = "Danish",
		[1031] = "German (Germany)",
		[1032] = "Greek",
		[1033] = "English (United States)",
		[1034] = "Spanish (Traditional Sort)",
		[1035] = "Finnish",
		[1036] = "French (France)",
		[1037] = "Hebrew",
		[1038] = "Hungarian",
		[1039] = "Icelandic",
		[1040] = "Italian (Italy)",
		[1041] = "Japanese",
		[1042] = "Korean",
		[1043] = "Dutch (Netherlands)",
		[1044] = "Norwegian (Bokmal)",
		[1045] = "Polish",
		[1046] = "Portuguese (Brazil)",
		[1047] = "Rhaeto-Romanic",
		[1048] = "Romanian",
		[1049] = "Russian",
		[1050] = "Croatian",
		[1051] = "Slovak",
		[1052] = "Albanian",
		[1053] = "Swedish",
		[1054] = "Thai",
		[1055] = "Turkish",
		[1056] = "Urdu",
		[1057] = "Indonesian",
		[1058] = "Ukrainian",
		[1059] = "Belarusian",
		[1060] = "Slovenian",
		[1061] = "Estonian",
		[1062] = "Latvian",
		[1063] = "Lithuanian",
		[1064] = "Tajik",
		[1065] = "Farsi",
		[1066] = "Vietnamese",
		[1070] = "Sorbian",
		[1067] = "Armenian",
		[1068] = "Azeri (Latin)",
		[1069] = "Basque",
		[1071] = "FYRO Macedonian",
		[1072] = "Sesotho",
		[1072] = "Sutu",
		[1073] = "Tsonga",
		[1074] = "Tswana",
		[1075] = "Venda",
		[1076] = "Xhosa",
		[1077] = "Zulu",
		[1078] = "Afrikaans",
		[1079] = "Georgian",
		[1080] = "Faroese",
		[1081] = "Hindi",
		[1082] = "Maltese",
		[1083] = "Sami Lappish",
		[1084] = "Gaelic Scotland",
		[1085] = "Yiddish",
		[1086] = "Malay (Malaysia)",
		[1087] = "Kazakh",
		[1088] = "Kyrgyz (Cyrillic)",
		[1089] = "Swahili",
		[1090] = "Turkmen",
		[1091] = "Uzbek (Latin)",
		[1092] = "Tatar",
		[1093] = "Bengali (India)",
		[1094] = "Punjabi",
		[1095] = "Gujarati",
		[1096] = "Oriya",
		[1097] = "Tamil",
		[1098] = "Telugu",
		[1099] = "Kannada",
		[1100] = "Malayalam",
		[1101] = "Assamese",
		[1102] = "Marathi",
		[1103] = "Sanskrit",
		[1104] = "Mongolian (Cyrillic)",
		[1105] = "Tibetan",
		[1106] = "Welsh",
		[1107] = "Khmer",
		[1108] = "Lao",
		[1109] = "Burmese",
		[1110] = "Galician",
		[1111] = "Konkani",
		[1112] = "Manipuri",
		[1113] = "Sindhi",
		[1114] = "Syriac",
		[1115] = "Sinhalese (Sri Lanka)",
		[1118] = "Amharic (Ethiopia)",
		[1120] = "Kashmiri",
		[1121] = "Nepali",
		[1122] = "Frisian (Netherlands)",
		[1124] = "Filipino",
		[1125] = "Divehi",
		[1126] = "Edo",
		[1136] = "Igbo (Nigeria)",
		[1140] = "Guarani (Paraguay)",
		[1142] = "Latin",
		[1143] = "Somali",
		[1153] = "Maori (New Zealand)",
		[1279] = "HID (Human Interface Device)",
		[2049] = "Arabic (Iraq)",
		[2052] = "Chinese (PRC)",
		[2055] = "German (Switzerland)",
		[2057] = "English (United Kingdom)",
		[2058] = "Spanish (Mexico)",
		[2060] = "French (Belgium)",
		[2064] = "Italian (Switzerland)",
		[2067] = "Dutch (Belgium)",
		[2068] = "Norwegian (Nynorsk)",
		[2070] = "Portuguese (Portugal)",
		[2072] = "Romanian (Moldova)",
		[2073] = "Russian (Moldova)",
		[2074] = "Serbian (Latin)",
		[2077] = "Swedish (Finland)",
		[2092] = "Azeri (Cyrillic)",
		[2108] = "Gaelic Ireland",
		[2110] = "Malay (Brunei Darussalam)",
		[2115] = "Uzbek (Cyrillic)",
		[2117] = "Bengali (Bangladesh)",
		[2128] = "Mongolian (Mongolia)",
		[3073] = "Arabic (Egypt)",
		[3076] = "Chinese (Hong Kong S.A.R.)",
		[3079] = "German (Austria)",
		[3081] = "English (Australia)",
		[3082] = "Spanish (International Sort)",
		[3084] = "French (Canada)",
		[3098] = "Serbian (Cyrillic)",
		[4097] = "Arabic (Libya)",
		[4100] = "Chinese (Singapore)",
		[4103] = "German (Luxembourg)",
		[4105] = "English (Canada)",
		[4106] = "Spanish (Guatemala)",
		[4108] = "French (Switzerland)",
		[4122] = "Croatian (Bosnia/Herzegovina)",
		[5121] = "Arabic (Algeria)",
		[5124] = "Chinese (Macau S.A.R.)",
		[5127] = "German (Liechtenstein)",
		[5129] = "English (New Zealand)",
		[5130] = "Spanish (Costa Rica)",
		[5132] = "French (Luxembourg)",
		[5146] = "Bosnian (Bosnia/Herzegovina)",
		[6145] = "Arabic (Morocco)",
		[6153] = "English (Ireland)",
		[6154] = "Spanish (Panama)",
		[6156] = "French (Monaco)",
		[7169] = "Arabic (Tunisia)",
		[7177] = "English (South Africa)",
		[7178] = "Spanish (Dominican Republic)",
		[7180] = "French (West Indies)",
		[8193] = "Arabic (Oman)",
		[8201] = "English (Jamaica)",
		[8202] = "Spanish (Venezuela)",
		[9217] = "Arabic (Yemen)",
		[9225] = "English (Caribbean)",
		[9226] = "Spanish (Colombia)",
		[9228] = "French (Congo, DRC)",
		[10241] = "Arabic (Syria)",
		[10249] = "English (Belize)",
		[10250] = "Spanish (Peru)",
		[10252] = "French (Senegal)",
		[11265] = "Arabic (Jordan)",
		[11273] = "English (Trinidad)",
		[11274] = "Spanish (Argentina)",
		[12289] = "Arabic (Lebanon)",
		[12297] = "English (Zimbabwe)",
		[12298] = "Spanish (Ecuador)",
		[12300] = "French (Cote d'Ivoire)",
		[13313] = "Arabic (Kuwait)",
		[13321] = "English (Philippines)",
		[13322] = "Spanish (Chile)",
		[13324] = "French (Mali)",
		[14337] = "Arabic (U.A.E.)",
		[14346] = "Spanish (Uruguay)",
		[14348] = "French (Morocco)",
		[15361] = "Arabic (Bahrain)",
		[15370] = "Spanish (Paraguay)",
		[16385] = "Arabic (Qatar)",
		[16393] = "English (India)",
		[16394] = "Spanish (Bolivia)",
		[17418] = "Spanish (El Salvador)",
		[18442] = "Spanish (Honduras)",
		[19466] = "Spanish (Nicaragua)",
		[20490] = "Spanish (Puerto Rico)",
	},
}

local Cond = {
	equals = function(key, value)
		return function(self, state)
			return state.packet[key] == value
		end
	end,
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
		local array = function(args)
			if args.of ~= uint32 and args.of ~= uint8 then
				error("Arrays of types other than uint32 or uint8 are not supported.")
			end
			args.of = args.of{alias="none"}
			args.length = args.of:size() * args.num
			args.dissect = function (self, state)
				local str = ""
				local isz = args.of:size()
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
				str = (string.gsub(str, "^(.*)%s*$", "%1")) 
				state.bnet_node:add(self.pf, state:read(args.length), str)
			end
			return stringz(args)
		end
		local flags = function(args)
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
				state.bnet_node = bn:add(self.pf, state:peek(self.size()))
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

SPacketDescription = {
[0x7001] = { 
	uint32{label="Result", desc=Descs.YesNo},
	uint32("Client Token", base.HEX),
	array{label="CD key data for SID_AUTH_CHECK", of=uint32, num=9},
},
[0x7002] = { 
	uint32("[8] Data for SID_AUTH_ACCOUNTLOGON"),
},
[0x7003] = { 
	uint32("[5] Data for SID_AUTH_ACCOUNTLOGONPROOF"),
},
[0x7004] = { 
	array{label="Data for Data for SID_AUTH_ACCOUNTCREATE", of=uint32, num=16},
},
[0x7005] = { 
	array{label="Data for SID_AUTH_ACCOUNTCHANGE", of=uint32, num=8},
},
[0x7006] = { 
	array{label="Data for SID_AUTH_ACCOUNTCHANGEPROOF", of=uint32, num=21},
},
[0x7007] = { 
	uint32{label="Success code.", desc=Descs.YesNo},
},
[0x7008] = { 
	array{label="Data for SID_AUTH_ACCOUNTUPGRADEPROOF", of=uint32, num=22},
},
[0x7009] = { 
	uint32{label="Success If Success is TRUE:", desc=Descs.YesNo},
	uint32("Version."),
	uint32("Checksum."),
	stringz("Version check stat string."),
},
[0x700A] = { 
	uint32{label="Success", desc=Descs.YesNo},
},
[0x700B] = { 
	array{label="The data hash.Optional:", of=uint32, num=5},
	uint32("Cookie. Same as the cookie"),
},
[0x700C] = { 
	uint32("Cookie."),
	uint8("Number of CD-keys requested."),
	uint8("Number of"),
	uint32("Bit mask .For each successful"),
	uint32("Client session key."),
	array{label="CD-key data.", of=uint32, num=9},
},
[0x700D] = { 
	uint32{label="Success code.", desc=Descs.YesNo},
},
[0x700E] = { 
	uint32("Server code."),
},
[0x700F] = { 
	uint32("Status code."),
},
[0x7010] = { 
	uint32{label="Product", key="prod"},
	when{
		condition=function(...) return arg[2].packet.prod ~= 0 end,
		block = {uint32("Version byte", base.HEX)},
	}
},
[0x7011] = { 
	uint32{label="Success.", desc=Descs.YesNo},
},
[0x7012] = { 
	uint32("Number of slots reserved"),
},
[0x7013] = { 
	uint32("Slot index."),
	array{label="Data for server's SID_AUTH_ACCOUNTLOGON", of=uint32, num=16},
},
[0x7014] = { 
	uint32("Slot index."),
	uint32{label="Success.", desc=Descs.YesNo},
	array{label="Data server's", of=uint32, num=5},
},
[0x7018] = { 
	uint32{label="Success*", desc=Descs.YesNo},
	uint32("Version."),
	uint32("Checksum."),
	stringz("Version check"),
	uint32("Cookie."),
	uint32("The latest version code for this"),
},
[0x701A] = { 
	uint32{label="Success*", desc=Descs.YesNo},
	version("Version."),
	uint32("Checksum.", base.HEX),
	stringz("Version check stat string."),
	uint32("Cookie.", base.HEX),
	uint32("The latest version code for this product.", base.HEX),
},
[0x8010] = { 
	uint8("Unknown"),
	uint32("Player ID"),
	uint8("Movement Type"),
	uint8("Destination Type"),
	uint32("Object ID"),
	uint16("X Coordinate"),
	uint16("Y Coordinate"),
},
[0x8019] = { 
	uint8("Amount"),
},
[0x801D] = { 
	uint8("Attribute"),
	uint8("Amount"),
},
[0x801E] = { 
	uint8("Attribute"),
	uint16("Amount"),
},
[0x801F] = { 
	uint8("Attribute - D2GS_SETWORDATTR"),
	uint32("Amount"),
},
[0x8051] = { 
	uint8("Object Type - Any information appreciated"),
	uint32("Object ID"),
	uint16("Object unique code"),
	uint16("X Coordinate"),
	uint16("Y Coordinate"),
	uint8("State *"),
	uint8("Interaction Condition"),
},
[0x805C] = { 
},
[0x8077] = { 
	uint8("Request Type"),
},
[0x807A] = { 
	uint32("Unknown - Possible acceptance/request ID"),
},
[0x8089] = { 
	uint8("EventId // see below,"),
},
[0x80AF] = { 
},
[0x9001] = { 
	uint32("Result"),
},
[0x9002] = { 
	uint32("Result"),
},
[0x9003] = { 
	uint16("Request Id"),
	uint16("Game token"),
	uint16("Unknown"),
	uint32("Result"),
},
[0x9004] = { 
	uint16("Request ID", base.HEX),
	uint16("Game token", base.HEX),
	uint16("Unknown", base.HEX),
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
[0x9005] = { 
	uint16("Request Id"),
	uint32("Index"),
	uint8("Number of players in game"),
	uint32("Status"),
	stringz("Game name"),
	stringz("Game description"),
},
[0x9006] = { 
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
[0x9007] = { 
	uint32("Result"),
},
[0x900A] = { 
	uint32("Result"),
},
[0x9011] = { 
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
[0x9012] = { 
	uint8("Unknown"),
	stringz("MOTD"),
},
[0x9014] = { 
	uint32("Position"),
},
[0x9017] = { 
	uint16("Number of characters requested"),
	uint32("Number of characters that exist on this account"),
	uint16("Number of characters returned"),
	stringz("Character name"),
	stringz("Character statstring"),
},
[0x9018] = { 
	uint32("Result"),
},
[0x9019] = { 
	uint16("Number of characters requested"),
	uint32("Number of characters that exist on this account"),
	uint16("Number of characters returned"),
	uint32("Expiration Date"),
	stringz("Character name"),
	stringz("Character statstring"),
},
[0xA000] = { 
},
[0xA001] = { 
	uint32("Result"),
},
[0xA002] = { 
	uint32("Result"),
},
[0xA003] = { 
	uint32("command"),
	stringz("usermask"),
	stringz("flags"),
	stringz("usermask"),
},
[0xA004] = { 
	stringz("User"),
	stringz("Command"),
},
[0xA005] = { 
	stringz("Channel"),
},
[0xA006] = { 
	uint32("Bot number"),
	stringz("Bot name"),
	stringz("Bot channel"),
	uint32("Bot server"),
	stringz("Unique account name"),
	stringz("Current database"),
},
[0xA00A] = { 
	uint32("Server Version"),
},
[0xA00B] = { 
	uint32("Command"),
	uint32("Action"),
	uint32("ID of source bot"),
	stringz("Message"),
},
[0xA00D] = { 
	uint32("Command"),
	uint32("Result"),
},
[0xA010] = { 
	uint8("SubcommandFor subcommand 0:"),
	uint8("Setting for broadcast"),
	uint8("Setting for database"),
	uint8("Setting for whispers"),
	uint8("Refuse all"),
},
[0xB005] = { 
	uint32("UDP Code"),
},
[0xCE07] = { 
	uint32("Bot id"),
},
[0xFF00] = { 
},
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
[0xFF05] = { 
	uint32("Registration Version", base.HEX),
	uint32("Registration Authority", base.HEX),
	uint32("Account Number", base.HEX),
	uint32("Registration Token", base.HEX),
},
[0xFF06] = { 
	wintime("MPQ Filetime"),
	stringz("MPQ Filename"),
	stringz("ValueString"),
},
[0xFF07] = { 
	uint32("Result", base.DEC, {
		[0x00] = "Failed version check",
		[0x01] = "Old game version",
		[0x02] = "Success",
		[0x03] = "Reinstall required",
	}),
	stringz("Patch path"),
},
[0xFF08] = { 
	uint32("Status", base.DEC, {
		[0x00] = "Failed",
		[0x01] = "Success",
	}),
},
[0xFF09] = { 
	uint32{label="Number of games", key="games"},
	when{condition=Cond.equals("games", 0),
		block = {
			uint32("Status", base.DEC, Descs.GameStatus)
		},
		otherwise = {
			iterator{label="Game Information", refkey="games", repeated={
				uint16("Game Type", base.HEX, {
					[0x02] = "Melee",
					[0x03] = "Free for all",
					[0x04] = "one vs one",
					[0x05] = "CTF",
					[0x06] = "Greed",
					[0x07] = "Slaughter",
					[0x08] = "Sudden Death",
					[0x09] = "Ladder",
					[0x10] = "Iron man ladder",
					[0x0A] = "Use Map Settings",
					[0x0B] = "Team Melee",
					[0x0C] = "Team FFA",
					[0x0D] = "Team CTF",
					[0x0F] = "Top vs Bottom",
				}),
				uint16("Parameter", base.HEX),
				uint32("Language ID", base.HEX),
				uint16("Address Family", base.DEC, {[2]="AF_INET"}),
				uint16{label="Port", big_endian=true},
				ipv4("Host's IP"),
				uint32("sin_zero"),
				uint32("sin_zero"),
				uint32("Status", base.DEC, Descs.GameStatus),
				uint32("Elapsed time"),
				stringz("Game name"),
				stringz("Game password"),
				stringz("Game statstring"),
			}},
		}
	},
},
[0xFF0A] = { 
	stringz("Unique name"),
	stringz("Statstring"),
	stringz("Account name"),
},
[0xFF0B] = { 
	iterator{
		alias="none",
		condition = function(self, state) return state.packet.chan ~="" end,
		repeated = {
			stringz{label="Channel name", key="chan"},
		}
	}
},
[0xFF0F] = { 
	uint32{label="Event ID", key="eid", base.DEX, desc={ 
		[0x01] = "EID_SHOWUSER: User in channel",
		[0x02] = "EID_JOIN: User joined channel",
		[0x03] = "EID_LEAVE: User left channel",
		[0x04] = "EID_WHISPER: Recieved whisper",
		[0x05] = "EID_TALK: Chat text",
		[0x06] = "EID_BROADCAST: Server broadcast",
		[0x07] = "EID_CHANNEL: Channel information",
		[0x09] = "EID_USERFLAGS: Flags update",
		[0x0A] = "EID_WHISPERSENT: Sent whisper",
		[0x0D] = "EID_CHANNELFULL: Channel full",
		[0x0E] = "EID_CHANNELDOESNOTEXIST: Channel doesn't exist",
		[0x0F] = "EID_CHANNELRESTRICTED: Channel is restricted",
		[0x12] = "EID_INFO: Information",
		[0x13] = "EID_ERROR: Error message",
		[0x17] = "EID_EMOTE: Emote",
	}},
	uint32("User's Flags", base.HEX),
	uint32("Ping"),
	ipv4("IP Address"),
	uint32("Account number", base.HEX),
	uint32("Registration Authority", base.HEX),
	stringz("Username"),
	when{ condition=Cond.equals("eid", 1),
		block = { stringz("Statstring") },
		otherwise = { stringz("Text") }
	}

	
},
[0xFF13] = { 
},
[0xFF15] = { 
	uint32("Ad ID", base.HEX),
	stringz{label="File extension", length=4},
	wintime("Local file time"),
	stringz("Filename"),
	stringz("Link URL"),
},
[0xFF18] = { 
	uint32("Cookie", base.HEX),
	uint32("HKEY", base.HEX, {
		[0x80000000] = "HKEY_CLASSES_ROOT",
		[0x80000001] = "HKEY_CURRENT_USER",
		[0x80000002] = "HKEY_LOCAL_MACHINE",
		[0x80000003] = "HKEY_USERS",
		[0x80000004] = "HKEY_PERFORMANCE_DATA",
		[0x80000005] = "HKEY_CURRENT_CONFIG",
		[0x80000006] = "HKEY_DYN_DATA",
	}),
	stringz("Registry path"),
	stringz("Registry key"),
},
[0xFF19] = { 
	uint32("Style"),
	stringz("Text"),
	stringz("Caption"),
},
[0xFF1C] = { 
	uint32("Status", base.DEC, {
		[0x00] ="Ok", 
		[0x01] = "Failed",
	}),
},
[0xFF1D] = { 
	uint32("UDP Token", base.HEX),
	uint32("Server Token", base.HEX),
},
[0xFF25] = { 
	uint32("Ping Value", base.HEX),
},
[0xFF26] = { 
	uint32{label="Number of accounts", key="numaccts"},
	uint32{label="Number of keys", key="numkeys"},
	uint32("Request ID"),
	iterator{label="Requested Account", refkey="numaccts", repeated={
		iterator{
			refkey="numkeys",
			repeated={stringz("Requested Key Value")},
			label="Key Values",
		},
	}},
},
[0xFF28] = { 
	uint32("Server Token", base.HEX),
},
[0xFF29] = { 
	uint32("Result", base.DEC, {
		[0x00] = "Invalid password",
		[0x01] = "Success",
	}),
},
[0xFF2A] = { 
	uint32("Result", base.DEC, {
		[0x00] = "Failed",
		[0x01] = "Success",
	}),
},
[0xFF2D] = { 
	wintime("Filetime"),
	stringz("Filename"),
},
[0xFF2E] = { 
	uint32("Ladder type", base.HEX),
	uint32("League", base.HEX),
	uint32("Sort method", base.DEC, {
		[0x00] = "Highest rating",
		[0x01] = "Fastest climbers",
		[0x02] = "Most wins on record",
		[0x03] = "Most games played",
	}),
	uint32("Starting rank", base.HEX),
	uint32{label="Number of ranks listed", key="ranks"},
	iterator{label="Rank", refkey="ranks", repeated={
		uint32("Wins"),
		uint32("Losses"),
		uint32("Disconnects"),
		uint32("Rating"),
		uint32("Rank"),
		uint32("Official wins"),
		uint32("Official losses"),
		uint32("Official disconnects"),
		uint32("Official rating"),
		uint32("Unknown", base.HEX),
		uint32("Official rank"),
		uint32("Unknown", base.HEX),
		uint32("Unknown", base.HEX),
		uint32("Highest rating"),
		uint32("Unknown", base.HEX),
		uint32("Season"),
		wintime("Last game time"),
		wintime("Official last game time"),
		stringz("Name"),
	}},
},
[0xFF2F] = { 
	uint32("Rank. Zero-based. 0xFFFFFFFF == Not ranked."),
},
[0xFF30] = { 
	uint32("Result", base.DEC, {
		[0x01] = "Ok",
		[0x02] = "Invalid key",
		[0x03] = "Bad product",
		[0x04] = "Banned",
		[0x05] = "In use",
	}),
	stringz("Key owner"),
},
[0xFF31] = { 
	uint32{label="Password change succeeded", desc=Descs.YesNo},
},
[0xFF32] = { 
	uint32("Status", base.DEC, {
		[0x00] = "Rejected",
		[0x01] = "Approved",
		[0x02] = "Ladder approved",
	}),
},
[0xFF33] = { 
	uint32("Request ID", base.HEX),
	uint32("Unknown", base.HEX),
	wintime("Last update time"),
	stringz("Filename"),
},
[0xFF34] = { 
	uint32("Unknown", base.HEX),
	uint32{label="Count", key="realms"},
	iterator{label="Realm", refkey="realms", repeated={
		uint32("Unknown", base.HEX),
		stringz("Realm title"),
		stringz("Realm description"),
	}},
},
[0xFF35] = { 
	uint32("Cookie", base.HEX),
	uint8{label="Success", key="status"},
	when{condition=Cond.equals("status", 0), block={
		stringz("Profile\\Description value"),
		stringz("Profile\\Location value"),
		uint32("Clan Tag"),
	}},
},
[0xFF36] = { 
	uint32("Result", base.DEC, {
		[0x01] = "Ok",
		[0x02] = "Invalid key",
		[0x03] = "Bad product",
		[0x04] = "Banned",
		[0x05] = "In use",
	}),
	stringz("Key owner"),
},
[0xFF3A] = { 
	uint32{label="Result", display=base.DEC, desc={
		[0x00] = "Success",
		[0x01] = "Account Does Not Exist",
		[0x02] = "Invalid Password",
		[0x06] = "Account Closed",
	}, key="res"},
	when{condition=Cond.equals("res", 6), block={
		stringz("Reason"),
	}},
},
[0xFF3C] = { 
	uint32("Result", base.DEC, {
		[0x00] = "Not approved",
		[0x01] = "Blizzard approved",
		[0x02] = "Approved for ladder",
	}),
},
[0xFF3D] = { 
	uint32("Status", base.DEC, {
		[0x00] = "Account created",
		[0x02] = "Name contained invalid characters",
		[0x03] = "Name contained a banned word",
		[0x04] = "Account already exists",
		[0x06] = "Name did not contain enough alphanumeric characters",
	}),
},
[0xFF3E] = { 
	uint32("MCP Cookie", base.HEX),
	uint32{label="MCP Status", key="status"},
	when{condition=Cond.equals("status", 0), block={
		array{of=uint32, label="MCP Chunk 1", num=2},
		ipv4("IP"),
		uint16{label="Port", big_endian=true},
		bytes{label="Padding", length=2},
		array{of=uint32, label="MCP Chunk 2", num=12},
		stringz("Battle.net unique name"),
	}},
},
[0xFF3F] = { 
	wintime("MPQ Filetime"),
	stringz("MPQ Filename"),
	stringz("ValueString"),
},
[0xFF40] = { 
	uint32("Unknown", base.HEX),
	uint32{label="Count", key="realms"},
	iterator{label="Realm", refkey="realms", repeated={
		uint32("Unknown", base.HEX),
		stringz("Realm title"),
		stringz("Realm description"),
	}},
},
[0xFF41] = { 
	uint32("Ad ID"),
	stringz("Ad URL"),
},
[0xFF44] = { 
	uint8{label="Subcommand ID", display=base.HEX, key="subcommand"},
	when{condition=Cond.equals("subcommand", 0x4), block = {
		uint32("Cookie", base.HEX),
		stringz{label="Icon ID", length=4},
		uint8{label="Number of ladder records", key="ladders"},
		iterator{label="Ladder Record", refkey="ladders", repeated={
			strdw("Ladder type"),
			uint16("Number of wins"),
			uint16("Number of losses"),
			uint8("Level"),
			uint8("Hours until XP decay"),
			uint16("Experience"),
			uint32("Rank"),
		}},
		uint8{label="Number of race records", key="races"},
		iterator{label="Race Record", refkey="races", repeated={
			uint16("Wins"),
			uint16("Losses"),
		}},
		uint8{label="Number of team records", key="teams"},
		iterator{label="Team Record", refkey="teams", repeated={
			strdw("Type of team"),
			uint16("Number of wins"),
			uint16("Number of losses"),
			uint8("Level"),
			uint8("Hours until XP decay"),
			uint16("Experience"),
			uint32("Rank"),
			wintime("Time of last game played"),
			uint8{label="Number of partners", key="partners"},
			iterator{label="Partners", refkey="partners", repeated={
				stringz("Names of partners"),
			}},
		}},
	}},
	when{condition=Cond.equals("subcommand", 0x8), block={
		uint32("Cookie", base.HEX),
		uint8{label="Number of ladder records", key="ladders"},
		iterator{label="Ladder Record", refkey="ladders", repeated={
			strdw("Ladder type"),
			uint16("Number of wins"),
			uint16("Number of losses"),
			uint8("Level"),
			uint8("Hours until XP decay"),
			uint16("Experience"),
			uint32("Rank"),
		}},
		uint8{label="Number of race records", key="races"},
		iterator{label="Race Record", refkey="races", repeated={
			uint16("Wins"),
			uint16("Losses"),
		}},
	}},
	when{condition=Cond.equals("subcommand", 0x9), block={
		uint32("Cookie", base.HEX),
		uint32("Unknown", base.HEX),
		uint8("Tiers"),
		uint8{label="Count (Number of Icons?)", key="icons"},
		iterator{label="Icon", refkey="icons", repeated={
			uint32("Icon", base.HEX),
			uint32("Name", base.HEX),
			uint8("Race", base.HEX),
			uint16("Wins required"),
			uint8("Unknown", base.HEX),
		}},
	}},
},
[0xFF46] = { 
	uint8{label="Number of entries", key="news" },
	posixtime("Last logon timestamp"),
	posixtime("Oldest news timestamp"),
	posixtime("Newest news timestamp"),
	iterator{label="News", refkey="news", repeated={
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
[0xFF4C] = { 
	stringz("ExtraWork MPQ FileName"),
},
[0xFF4E] = { 
	uint8("Unknown", base.HEX),
	uint8("Unknown, maybe number of non-null strings sent?", base.HEX),
	stringz("Description"),
	stringz("Unknown"),
	stringz("Website"),
	uint32("Unknown", base.HEX),
	stringz("Name"),
	stringz("Unknown"),
	stringz("Unknown"),
	stringz("Unknown"),
	array{label="Unknown", of=uint32, num=5},
},
[0xFF50] = { 
	uint32{label="Logon Type", key="logontype", desc={
		[0x00] = "Broken SHA-1 (STAR/SEXP/D2DV/D2XP)",
		[0x01] = "NLS Version 1",
		[0x02] = "NLS Version 2 (WAR3/W3XP)",
	}},
	uint32("Server Token", base.HEX),
	uint32("UDPValue", base.HEX),
	wintime("MPQ filetime"),
	stringz("IX86ver filename"),
	stringz("ValueString"),
	when{ condition = Cond.equals("logontype", 2),
		block = { bytes{label="Server signature", length=128}},
	},
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
[0xFF52] = { 
	uint32("Status", base.DEC, {
		[0x00] = "Successfully created account name.",
		[0x04] = "Name already exists.",
		[0x07] = "Name is too short/blank.",
		[0x08] = "Name contains an illegal character.",
		[0x09] = "Name contains an illegal word.",
		[0x0a] = "Name contains too few alphanumeric characters.",
		[0x0b] = "Name contains adjacent punctuation characters.",
		[0x0c] = "Name contains too many punctuation characters.",
	}),
},
[0xFF53] = { 
	uint32("Status", base.HEX, {
		[0x00] = "Logon accepted, requires proof.",
		[0x01] = "Account doesn't exist.",
		[0x05] = "Account requires upgrade.",
	}),
	array{of=uint8, num=32, label="Salt"},
	array{of=uint8, num=32, label="Server Key"},
},
[0xFF54] = { 
	uint32{label="Status", display=base.DEC, desc={
		[0x00] = "Logon successful.",
		[0x02] = "Incorrect password.",
		[0x0E] = "An email address should be registered for this account.",
		[0x0F] = "Custom error. A string at the end of this message contains the error.",
	}, key="status"},
	array{of=uint8, num=20, label="Server Password Proof"},
	when{condition=Cond.equals("status", 0x0F), block={
		stringz("Additional information")
	}},
},
[0xFF55] = { 
	uint32("Status", base.DEC, {
		[0x00] = "Change accepted, requires proof.",
		[0x01] = "Account doesn't exist.",
		[0x05] = "Account requires upgrade",
	}),
	array{of=uint8, num=32, label="Salt"},
	array{of=uint8, num=32, label="Server Key"}
},
[0xFF56] = { 
	uint32("Status code", base.DEC, {
		[0x00] = "Password changed.",
		[0x02] = "Incorrect old password.",
	}),
	array{of=uint8, num=20, label="Server password proof for old password"},
},
[0xFF57] = { 
	uint32("Status", base.DEC, {
		[0x00] = "Upgrade Request Accepted",
		[0x01] = "Upgrade Request Denied",
	}),
	uint32("Server Token", base.HEX),
},
[0xFF58] = { 
	uint32("Status", base.DEC, {
		[0x00] = "Password changed.",
		[0x02] = "Incorrect old password.",
	}),
	array{of=uint32, num=5, label="Password proof"},
},
[0xFF59] = { 
},
[0xFF5E] = { 
	bytes{label="Encrypted Packet",
		size=function(self, state) return state.packet.length end,
	},
},
[0xFF60] = { 
	uint8{label="Number of players", key="players"},
	iterator{alias="none", refkey="players", repeated={
		stringz("Player name"),
	}},
},
[0xFF65] = { 
	uint8{label="Number of Entries", key="friends"},
	iterator{label="Friend", refkey="friends", repeated={
		stringz("Account"),
		flags{of=uint8, label="Status", fields={
			{sname="Mutual", mask=0x01, desc=Descs.YesNo},
			{sname="DND", mask=0x02, desc=Descs.YesNo},
			{sname="Away", mask=0x04, desc=Descs.YesNo} 
		}},
		uint8("Location", base.DEC, {
			[0x00] = "Offline",
			[0x01] = "Not in chat",
			[0x02] = "In chat",
			[0x03] = "In a public game",
			[0x04] = "In a private game, and you are not that person's friend.",
			[0x05] = "In a private game, and you are that person's friend.",
		}),
		strdw("ProductID"),
		stringz("Location name"),
	}},
},
[0xFF66] = { 
	uint8("Entry number"),
	flags{of=uint8, label="Status", fields={
		{sname="Mutual", mask=0x01, desc=Descs.YesNo},
		{sname="DND", mask=0x02, desc=Descs.YesNo},
		{sname="Away", mask=0x04, desc=Descs.YesNo} 
	}},
	uint8("Location", base.DEC, {
		[0x00] = "Offline",
		[0x01] = "Not in chat",
		[0x02] = "In chat",
		[0x03] = "In a public game",
		[0x04] = "In a private game, and you are not that person's friend.",
		[0x05] = "In a private game, and you are that person's friend.",
	}),
	strdw("ProductID"),
	stringz("Location name"),
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
[0xFF68] = { 
	uint8("Entry Number"),
},
[0xFF69] = { 
	uint8("Old Position"),
	uint8("New Position"),
},
[0xFF70] = { 
	uint32("Cookie", base.HEX),
	uint8("Status", base.DEC, {
		[0x00] = "Successfully found candidate(s)",
		[0x01] = "Clan tag already taken",
		[0x08] = "Already in clan",
		[0x0a] = "Invalid clan tag specified",
	}),
	uint8{label="Number of potential candidates", key="names"},
	iterator{alias="none", refkey="names", repeted={
		stringz("Username"),
	}},
},
[0xFF71] = { 
	uint32("Cookie", base.HEX),
	uint8("Result", base.DEC, {
		[0x00] = "Everyone accepted",
		[0x04] = "Declined",
		[0x05] = "Not available",
	}),
	iterator{
		alias="none",
		condition = function(self, state) return state.packet.acc ~="" end,
		repeated = {
			stringz{label="Failed Account", key="acc"},
		}
	}
},
[0xFF72] = { 
	uint32("Cookie", base.HEX),
	uint32("Clan Tag"),
	stringz("Clan Name"),
	stringz("Inviter's username"),
	uint8{label="Number of users being invited", key="users"},
	iterator{refkey="users", label="Invited users", repeated={
		stringz("Name"),
	}},
},
[0xFF73] = { 
	uint32("Cookie"),
	uint8("Result"),
},
[0xFF74] = { 
	uint32("Cookie"),
	uint8("Status"),
},
[0xFF75] = { 
	uint8("Unknown"),
	uint32("Clan tag"),
	uint8("Rank"),
},
[0xFF76] = { 
	uint8("Status"),
},
[0xFF77] = { 
	uint32("Cookie"),
	uint8("Result"),
},
[0xFF78] = { 
	uint32("Cookie"),
	uint8("Status"),
},
[0xFF79] = { 
	uint32("Cookie"),
	uint32("Clan tag"),
	stringz("Clan name"),
	stringz("Inviter"),
},
[0xFF7A] = { 
	uint32("Cookie"),
	uint8("Status"),
},
[0xFF7C] = { 
	uint32("Cookie"),
	uint32("Unknown"),
	stringz("MOTD"),
},
[0xFF7D] = { 
	uint32("Cookie"),
	uint8("Number of Members"),
	stringz("Username"),
	uint8("Rank"),
	uint8("Online Status"),
	stringz("Location"),
},
[0xFF7E] = { 
	stringz("Clan member name"),
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
[0xFF81] = { 
	uint8("Old rank"),
	uint8("New rank"),
	stringz("Clan member who changed your rank"),
},
[0xFF82] = { 
	uint32("Cookie"),
	uint8("Status code"),
	stringz("Clan name"),
	uint8("User's rank"),
	wintime("Date joined"),
},
}
CPacketDescription = {
[0x7000] = { 
},
[0x7001] = { 
	uint32("Server Token"),
	stringz("CD key"),
},
[0x7002] = { 
	stringz("Account name"),
	stringz("Password"),
},
[0x7003] = { 
	uint32("[16] Data from SID_AUTH_ACCOUNTLOGON"),
},
[0x7004] = { 
	stringz("Account name."),
	stringz("Account password."),
},
[0x7005] = { 
	stringz("Account name."),
	stringz("Account old password."),
	stringz("Account"),
},
[0x7006] = { 
	array{of=uint32, label="Data from SID_AUTH_ACCOUNTCHANGE", num=16},
},
[0x7007] = { 
	stringz("Account name."),
	stringz("Account old password."),
	stringz("Account"),
},
[0x7008] = { 
	uint32("Session key from SID_AUTH_ACCOUNTUPGRADE"),
},
[0x7009] = { 
	uint32("Product ID."),
	uint32("Version DLL digit"),
	stringz("Checksum formula."),
},
[0x700A] = { 
	array{of=uint32, label="Password proof from Battle.net.", num=5},
},
[0x700B] = { 
	uint32("Size of Data"),
	uint32("Flags"),
	bytes("Data to be hashed."),
	uint32("Client Key"),
	uint32("Server Key"),
	uint32("Cookie"),
},
[0x700C] = { 
	uint32("Cookie."),
	uint8("Number of CD-keys to encrypt."),
	uint32("Flags."),
	uint32{label="Server session key", todo="verify array length"},
	uint32{label="Client session key", todo="verify array length"},
	stringz{label="CD-keys. No", todo="verify array length"},
},
[0x700D] = { 
	uint32("NLS revision number."),
},
[0x700E] = { 
	stringz("Bot ID."),
},
[0x700F] = { 
	uint32("Checksum."),
},
[0x7010] = { 
	uint32("ProductID"),
},
[0x7011] = { 
	uint32("Server IP"),
	array{of=uint8, label="Signature", num=128},
},
[0x7012] = { 
	uint32("Number of slots to reserve"),
},
[0x7013] = { 
	uint32("Slot index."),
	uint32("NLS revision number."),
	array{of=uint32, label="Data from", num=16},
	array{of=uint32, label="Data client's SID_AUTH_ACCOUNTLOGON", num=8},
},
[0x7014] = { 
	uint32("Slot index."),
	array{of=uint32, label="Data from client's", num=5},
	stringz("Client's account name."),
},
[0x7018] = { 
	uint32("Product ID.*"),
	uint32("Version DLL digit"),
	uint32("Flags.**"),
	uint32("Cookie."),
	stringz("Checksum formula."),
},
[0x701A] = { 
	uint32("Product ID.*"),
	uint32("Flags.**"),
	uint32("Cookie."),
	uint64("Timestamp for version check archive."),
	stringz("Version check archive filename."),
	stringz("Checksum formula."),
},
[0x8101] = { 
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0x8102] = { 
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
[0x8103] = { 
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0x8104] = { 
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
[0x8105] = { 
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0x8106] = { 
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
[0x8107] = { 
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x8108] = { 
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0x8109] = { 
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
[0x810A] = { 
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
[0x810C] = { 
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0x810D] = { 
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x810E] = { 
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x810F] = { 
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
[0x8110] = { 
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x8111] = { 
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x8113] = { 
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x8114] = { 
	uint16("Unknown - 0x00, 0x00"),
	stringz("Message"),
	uint8("Unused - 0x00"),
	uint16("Unknown - 0x00, 0x00"),
},
[0x8115] = { 
	uint8("Message Type"),
	uint8("Unknown"),
	stringz("Message"),
	uint8("Unknown"),
	uint16("Unknown - Only if normal chat"),
	stringz("Player to whisper to - Only if whispering"),
	uint8("Unknown - Only if whispering"),
},
[0x8116] = { 
	uint32("Unit Type"),
	uint32("Unit ID"),
	uint32("Action ID"),
},
[0x8117] = { 
	uint32("Item ID"),
},
[0x8118] = { 
	uint32("Item ID"),
	uint32("X coordinate"),
	uint32("Y coordinate"),
	uint32("Buffer Type"),
},
[0x8119] = { 
	uint32("Item ID"),
},
[0x811A] = { 
	uint32("Item ID"),
	uint32("Body Location"),
},
[0x811B] = { 
	uint32("Item ID"),
	uint32("Body Location"),
},
[0x811C] = { 
	uint16("Body Location"),
},
[0x811D] = { 
	uint32("Item ID"),
	uint32("Body Location"),
},
[0x811F] = { 
	uint32("Item ID - Item to place in inventory"),
	uint32("Item ID - Item to be replaced"),
	uint32("X coordinate for replace"),
	uint32("Y coordinate for replace"),
},
[0x8120] = { 
	uint32("Item ID"),
	uint32("X coordinate"),
	uint32("Y coordinate"),
},
[0x8121] = { 
	uint32("Item ID - Stack item"),
	uint32("Item ID - Target item"),
},
[0x8122] = { 
	uint32("Item ID"),
},
[0x8123] = { 
	uint32("Item ID"),
	uint32("Belt Location"),
},
[0x8124] = { 
	uint32("Item ID"),
},
[0x8125] = { 
	uint32("Item ID - Cursor buffer"),
	uint32("Item ID - Item to be replaced"),
},
[0x8126] = { 
	uint32("Item ID"),
	uint32("Unknown - Possibly unused"),
	uint32("Unknown - Possibly unused"),
},
[0x8128] = { 
	uint32("Item ID - Item to place in socket"),
	uint32("Item ID - Socketed item"),
},
[0x8129] = { 
	uint32("Item ID - Scroll"),
	uint32("Item ID - Tome"),
},
[0x812A] = { 
	uint32("Item ID"),
	uint32("Cube ID"),
},
[0x812D] = { 
},
[0x812F] = { 
	uint32("Entity Type"),
	uint32("Entity ID"),
},
[0x8130] = { 
	uint32("Entity Type"),
	uint32("NPC ID"),
},
[0x8132] = { 
	uint32("NPC ID - Unconfirmed"),
	uint32("Item ID - Unconfirmed"),
	uint32("Buffer Type - Unconfirmed"),
	uint32("Cost"),
},
[0x8133] = { 
	uint32("NPC ID - Unconfirmed"),
	uint32("Item ID - Unconfirmed"),
	uint32("Buffer ID - Unconfirmed - Possible value 0x04"),
	uint32("Cost"),
},
[0x8138] = { 
	uint32("Trade Type - Unconfirmed"),
	uint32("NPC ID - Unconfirmed"),
	uint32("Unknown - Unconfirmed - Possible value 0x00"),
},
[0x813F] = { 
	uint16("Phrase ID"),
},
[0x8149] = { 
	uint8("Waypoint ID"),
	uint8("Unknown - Appears to be random"),
	uint16("Unknown - 0x00"),
	uint8("Level number"),
	uint16("Unknown - 0x00"),
},
[0x814F] = { 
	uint32("Request ID"),
	uint16("Gold Amount"),
},
[0x8150] = { 
	uint32("PlayerID"),
	uint32("GoldAmount"),
},
[0x815E] = { 
	uint16("Action ID"),
	uint32("Player ID"),
},
[0x8161] = { 
	uint16("Unknown - 0x00"),
},
[0x8168] = { 
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
[0x816A] = { 
},
[0x816D] = { 
	uint32("Tick Count"),
	uint32("Null"),
	uint32("Null"),
},
[0x9001] = { 
	uint32("MCP Cookie"),
	uint32("MCP Status"),
	uint32("[2] MCP Chunk 1"),
	uint32("[12] MCP Chunk 2"),
	stringz("Battle.net Unique Name"),
},
[0x9002] = { 
	uint32("Character class"),
	uint16("Character flags"),
	stringz("Character name"),
},
[0x9003] = { 
	uint16("Request Id *"),
	uint32("Difficulty"),
	uint8("Unknown - 1"),
	uint8("Player difference **"),
	uint8("Maximum players"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game description"),
},
[0x9004] = { 
	uint16("Request ID"),
	stringz("Game name"),
	stringz("Game Password"),
},
[0x9005] = { 
	uint16("Request ID"),
	uint32("Unknown"),
	stringz("Search String *"),
},
[0x9006] = { 
	uint16("Request ID"),
	stringz("Game name"),
},
[0x9007] = { 
	stringz("Character name"),
},
[0x900A] = { 
	uint16("Unknown"),
	stringz("Character name"),
},
[0x9011] = { 
	uint8("Ladder type"),
	uint16("Starting position"),
},
[0x9012] = { 
},
[0x9013] = { 
},
[0x9017] = { 
	uint32("Number of characters to list"),
},
[0x9018] = { 
	stringz("Character Name"),
},
[0x9019] = { 
	uint32("Number of characters to list."),
},
[0xA000] = { 
},
[0xA001] = { 
	stringz("BotID"),
	stringz("Bot Password"),
},
[0xA002] = { 
	stringz("Unique username on Battle.net"),
	stringz("Current channel on Battle.net"),
	uint32("Battle.net server IP address"),
	stringz("DatabaseID"),
	uint32("Cycle status"),
},
[0xA003] = { 
	uint32("Command"),
	stringz("Usermask"),
	stringz("Flags"),
	stringz("Usermask"),
},
[0xA004] = { 
	stringz("User"),
	stringz("Command"),
},
[0xA005] = { 
	uint32("Count"),
	stringz{label="Usernames to cycle", todo="maybe iterator"},
},
[0xA006] = { 
},
[0xA007] = { 
	stringz("User"),
	stringz("Command"),
},
[0xA008] = { 
	uint32("Target BotID"),
	stringz("Sending User"),
	stringz("Command"),
},
[0xA009] = { 
	uint32("Password to change"),
	stringz("New password"),
},
[0xA00B] = { 
	uint32("Command"),
	uint32("Action"),
	uint32("For Command 2, ID of destination"),
	stringz("Message"),
},
[0xA00D] = { 
	uint32("CommandFor Command 0x00"),
	stringz("Account name"),
	stringz("Account passwordFor Command 0x01"),
	stringz("Account"),
	stringz("Old password"),
	stringz("New passwordFor Command 0x02"),
	stringz("Account name"),
	stringz("Account password"),
},
[0xA010] = { 
	uint8("SubcommandFor subcommand 0:"),
	uint8("Setting for broadcast"),
	uint8("Setting for database"),
	uint8("Setting for whispers"),
	uint8("Refuse all"),
},
[0xB003] = { 
	uint32("Code"),
},
[0xB007] = { 
	uint32("Tick count"),
},
[0xB008] = { 
	uint32("Server Token"),
},
[0xB009] = { 
	uint32("Server Token"),
	uint32("UDP Token*"),
},
[0xFF00] = { 
},
[0xFF02] = { 
},
[0xFF05] = { 
	uint32("Registration Version"),
	uint32("Registration Authority"),
	uint32("Account Number"),
	uint32("Registration Token"),
	stringz("LAN Computer Name"),
	stringz("LAN Username"),
},
[0xFF06] = { 
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("Version Byte"),
	uint32("Unknown"),
},
[0xFF07] = { 
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("Version Byte"),
	uint32("EXE Version"),
	uint32("EXE Hash"),
	stringz("EXE Information"),
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
[0xFF0A] = { 
	stringz("Username"),
	stringz("Statstring"),
},
[0xFF0B] = { 
	strdw("Product ID", nil, Descs.ClientTag),
},
[0xFF0C] = { 
	uint32("Flags", nil, {
		[0x00] = "NoCreate join",
		[0x01] = "First join",
		[0x02] = "Forced join",
		[0x05] = "D2 first join",
	}),
	stringz("Channel"),
},
[0xFF0E] = { 
	stringz("Text"),
},
[0xFF10] = { 
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
[0xFF14] = { 
	strdw("UDPCode"),
},
[0xFF15] = { 
	strdw("Platform ID"),
	strdw("Product ID"),
	uint32("ID of last displayed banner"),
	posixtime("Current time"),
},
[0xFF16] = { 
	uint32("Ad ID"),
	uint32("Request type"),
},
[0xFF18] = { 
	uint32("Cookie"),
	stringz("Key Value"),
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
[0xFF1B] = { 
	sockaddr("Address"),
},
[0xFF1C] = { 
	flags{of=uint32, label="State", fields={
		{sname="Game is private", mask=0x01, desc=Descs.YesNo},
		{sname="Game is full", mask=0x02, desc=Descs.YesNo},
		{sname="Game contains players (other than creator)", mask=0x04, desc=Descs.YesNo},
		{sname="Game is in progress", mask=0x08, desc=Descs.YesNo} 
	}},
	uint32("Time since creation"),
	uint16("Game Type", nil, {
		[0x02] = "Melee",
		[0x03] = "Free for All",
		[0x04] = "1 vs 1",
		[0x09] = "Ladder",
		[0x0A] = "Use Map Settings",
		[0x0F] = "Top vs Bottom",
		[0x10] = "Iron Man Ladder (W2BN only)",
	}),
	uint16("Parameter"),
	uint32("Unknown"),
	uint32("Ladder", nil, {
		[0x00] = "NonLadder",
		[0x01] = "Ladder",
		[0x03] = "Iron Man Ladder (W2BN only)",
	}),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game Statstring"),
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
[0xFF1F] = { 
},
[0xFF21] = { 
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("Ad ID"),
	stringz("Filename"),
	stringz("URL"),
},
[0xFF22] = { 
	uint32("Product ID *"),
	uint32("Product version"),
	stringz("Game Name"),
	stringz("Game Password"),
},
[0xFF25] = { 
	uint32("Ping Value", base.HEX),
},
[0xFF26] = { 
	uint32{label="Number of Accounts", key="numaccts"},
	uint32{label="Number of Keys", key="numkeys"},
	uint32("Request ID"),
	iterator{label="Requested Account", refkey="numaccts", repeated={
		stringz("Account"),
		iterator{label="Keys", refkey="numkeys", repeated={
			stringz("Key"),
		}}, 
		
	}},
		
},
[0xFF27] = { 
	uint32("Number of accounts"),
	uint32("Number of keys"),
	stringz("[] Accounts to update"),
	stringz("[] Keys to update"),
	stringz("[] New values"),
},
[0xFF29] = { 
	uint32("Client Token"),
	uint32("Server Token"),
	uint32("[5] Password Hash"),
	stringz("Username"),
},
[0xFF2A] = { 
	uint32("[5] Hashed password"),
	stringz("Username"),
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
[0xFF2C] = { 
	uint32("Game type"),
	uint32("Number of results - always 8"),
	uint32("[8] Results"),
	stringz("[8] Game players - always 8"),
	stringz("Map name"),
	stringz("Player score"),
},
[0xFF2D] = { 
},
[0xFF2E] = { 
	uint32("Product ID"),
	uint32("League"),
	uint32("Sort method"),
	uint32("Starting rank"),
	uint32("Number of ranks to list"),
},
[0xFF2F] = { 
	uint32("League"),
	uint32("Sort method"),
	stringz("Username"),
},
[0xFF30] = { 
	uint32("Spawn"),
	stringz("CDKey"),
	stringz("Key Owner"),
},
[0xFF31] = { 
	uint32("Client Token"),
	uint32("Server Token"),
	uint32("[5] Old password hash"),
	uint32("[5] New password hash"),
	stringz("Account name"),
},
[0xFF32] = { 
	uint32("[5] File checksum"),
	stringz("File name"),
},
[0xFF33] = { 
	uint32("Request ID"),
	uint32("Unknown"),
	stringz("Filename"),
},
[0xFF34] = { 
	uint32("Unused"),
	uint32("Unused"),
	stringz("Unknown"),
},
[0xFF35] = { 
	uint32("Cookie"),
	stringz("Username"),
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
[0xFF3A] = { 
	uint32("Client Token", base.HEX),
	uint32("Server Token", base.HEX),
	array{label="Password Hash", of=uint32, num=5},
	stringz("Username"),
},
[0xFF3C] = { 
	uint32("File size in bytes"),
	uint32("File hash [5]"),
	stringz("Filename"),
},
[0xFF3D] = { 
	uint32("[5] Password hash"),
	stringz("Username"),
},
[0xFF3E] = { 
	uint32("Client Token"),
	uint32("[5] Hashed realm password"),
	stringz("Realm title"),
},
[0xFF40] = { 
},
[0xFF41] = { 
	uint32("Ad ID"),
},
[0xFF44] = { 
	uint8{label="Subcommand ID", key="subcommand", desc={
		[0x02] = "Request ladder map listing",
		[0x03] = "Cancel ladder game search",
		[0x04] = "User stats request",
		[0x08] = "Clan stats request",
		[0x09] = "Icon list request",
		[0x0A] = "Change icon",
	}},
	when{ condition=Cond.equals("subcommand",0x02),
		block = {  
			uint32("Cookie"),
			uint8{label="Number of types requested",key="num"},
			iterator{label="Game Information", refkey="num", repeated={
				strdw("Request data"),
				uint32("Dword(0)"),
			}},
		},
	},
	when{ condition=Cond.equals("subcommand",0x03),
		block = {  },
	},
	when{ condition=Cond.equals("subcommand",0x09),	block = { 			
		uint32("Cookie"),
	}},
	when{ condition=Cond.equals("subcommand",0x0A),	block = { 			
		uint32("Icon"),
	}},
},
[0xFF45] = { 
	uint16("Port"),
},
[0xFF46] = { 
	uint32("News timestamp"),
},
[0xFF4B] = { 
	uint16("Game type"),
	uint16("Length"),
	stringz("Work returned data"),
},
[0xFF50] = { 
	uint32("Protocol ID"),
	strdw("Platform ID"),
	strdw("Product ID", nil, Descs.ClientTag),
	uint32("Version Byte", base.HEX),
	strdw("Product language"),
	ipv4("Local IP for NAT compatibility"),
	int32("Time zone bias"),
	uint32("Locale ID", nil, Descs.LocaleID),
	uint32("Language ID", nil, Descs.LocaleID),
	stringz("Country abreviation"),
	stringz("Country"),
},
[0xFF51] = { 
	uint32("Client Token", base.HEX),
	version("EXE Version"),
	uint32("EXE Hash", base.HEX),
	uint32{label="Number of CD-keys in this packet", key="cdkeys"},
	uint32("Spawn CD-key", nil, Descs.YesNo),
	iterator{label="CD-Key", refkey="cdkeys", repeated={
		uint32("Key Length"),
		uint32("CD-key's product value", base.HEX, {
				[0x01] = "STAR",
				[0x02] = "STAR",
				[0x17] = "STAR (26-character)",
				[0x06] = "D2DV",
				[0x18] = "D2DV (26-character)",
				[0x0A] = "D2XP",
				[0x19] = "D2XP (26-character)",
				[0x04] = "W2BN",
				[0x0E] = "WAR3",
				[0x12] = "W3XP",
		}),
		uint32("CD-key's public value", base.HEX),
		uint32("Unknown", base.HEX),
		array{of=uint32, num=5, label="Hashed Key Data"},
	}},
	stringz("Exe Information"),
	stringz("CD-Key owner name"),

},
[0xFF52] = { 
	uint8("[32] Salt"),
	uint8("[32] Verifier"),
	stringz("Username"),
},
[0xFF53] = { 
	array{label="Client Key", of=uint8, num=32},
	stringz("Username"),
},
[0xFF54] = { 
	array{label="Client Password Proof", of=uint8, num=20},
},
[0xFF55] = { 
	uint8("[32] Client key"),
	stringz("Username"),
},
[0xFF56] = { 
	uint8("[20] Old password proof"),
	uint8("[32] New password's salt"),
	uint8("[32] New password's verifier"),
},
[0xFF57] = { 
},
[0xFF58] = { 
	uint32("Client Token"),
	uint32("[5] Old Password Hash"),
	uint8("[32] New Password Salt"),
	uint8("[32] New Password Verifier"),
},
[0xFF59] = { 
	stringz("Email Address"),
},
[0xFF5A] = { 
	stringz("Account Name"),
	stringz("Email Address"),
},
[0xFF5B] = { 
	stringz("Account Name"),
	stringz("Old Email Address"),
	stringz("New Email Address"),
},
[0xFF5C] = { 
	uint32("Product ID"),
},
[0xFF5D] = { 
	uint32("0x10A0027"),
	uint32("Exception code"),
	uint32("Unknown"),
	uint32("Unknown"),
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
[0xFF60] = { 
},
[0xFF65] = { 
},
[0xFF66] = { 
	uint8("Friends list index"),
},
[0xFF70] = { 
	uint32("Cookie"),
	uint32("Clan Tag"),
},
[0xFF71] = { 
	uint32("Cookie"),
	stringz("Clan name"),
	uint32("Clan tag"),
	uint8("Number of users to invite"),
	stringz("[] Usernames to invite"),
},
[0xFF72] = { 
	uint32("Cookie"),
	uint32("Clan tag"),
	stringz("Inviter name"),
	uint8("Status"),
},
[0xFF73] = { 
	uint32("Cookie"),
},
[0xFF74] = { 
	uint32("Cookie"),
	stringz("New Cheiftain"),
},
[0xFF77] = { 
	uint32("Cookie"),
	stringz("Target User"),
},
[0xFF78] = { 
	uint32("Cookie"),
	stringz("Username"),
},
[0xFF79] = { 
	uint32("Cookie"),
	uint32("Clan tag"),
	stringz("Inviter"),
	uint8("Response"),
},
[0xFF7A] = { 
	uint32("Cookie"),
	stringz("Username"),
	uint8("New rank"),
},
[0xFF7B] = { 
	uint32("Cookie"),
	stringz("MOTD"),
},
[0xFF7C] = { 
	uint32("Cookie"),
},
[0xFF7D] = { 
	uint32("Cookie"),
},
[0xFF82] = { 
	uint32("Cookie"),
	uint32("User's clan tag"),
	stringz("Username"),
},
}
	end
end
