do
	-- Forward declarations
	local
		packet_names,
		noop_handler,
		handlers_by_type,
		pid_label,
		CPacketDescription,
		SPacketDescription,
		dissect_packet

	--local info = function(...) end

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
	local f_data = ProtoField.bytes("bnetp.plen","Unhandled Packet Data")
	
	p_bnetp.fields = {
		-- Header fields
		--     Type
		f_type,
		--     Packet Info
		f_pid,  -- Packet id field
		f_plen, -- Packet length field
		f_data, -- Generic packet data field
	}

	function State()
		return {
			["bnet_node"] = nil,
			["buf"] = nil,
			["pkt"] = nil,
			["used"] = 0,

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

	function do_dissection(state)
		local handler = handlers_by_type[state:peek(1):uint()]
		if handler then
			state.bnet_node:add(f_type, state:read(1))
			handler(state)
			return ENOUGH, ACCEPTED
		else
			-- If no handler is found the packet is rejected.
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
					-- Packet was rejected. Make the loop end.
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
	udp_encap_table:add(6112,p_bnetp)
	tcp_encap_table:add(6112,p_bnetp)

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
			-- The size found in the packet includes headers, so consumed bytes
			-- are substracted when requesting more data.
			local len = state:peek(2):le_uint() -2
			-- Record used bytes before dissecting.
			local start = state.used
			-- Request at least len extra bytes at once.
			state:request(len)

			state.bnet_node:add_le(f_plen, state:read(2))

			local pdesc
			if state.pkt.src_port == 6112 then
				-- process server packet
				pdesc = SPacketDescription[type_pid]
			else
				-- process client packet
				pdesc = CPacketDescription[type_pid]
			end

			if pdesc then
				dissect_packet(state, pdesc)
			else
				state:error("Unssuported packet: " .. packet_names[type_pid])
			end

			-- Check if any data remains unhandled.
			local remaining = len - (state.used - start)
			if remaining > 0 then
				state.bnet_node:add(f_data, state:read(remaining))
			end
		end,
	}

	-- Packet dissector
	function dissect_packet(state, pdesc)
		for k,v in pairs(pdesc) do
			if not v.dissect then
				local size = v.size(state:tvb())
				state.bnet_node:add_le(v.pf, state:read(size))
			else
				v:dissect(state)
			end
		end
	end

	packet_names = {
		-- Battle.net Messages Names
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

	local SID_NULL = 0xFF00
	local SID_STOPADV = 0xFF02
	local SID_SERVERLIST = 0xFF04
	local SID_CLIENTID = 0xFF05
	local SID_STARTVERSIONING = 0xFF06
	local SID_REPORTVERSION = 0xFF07
	local SID_STARTADVEX = 0xFF08
	local SID_GETADVLISTEX = 0xFF09
	local SID_ENTERCHAT = 0xFF0A
	local SID_GETCHANNELLIST = 0xFF0B
	local SID_JOINCHANNEL = 0xFF0C
	local SID_CHATCOMMAND = 0xFF0E
	local SID_CHATEVENT = 0xFF0F
	local SID_LEAVECHAT = 0xFF10
	local SID_LOCALEINFO = 0xFF12
	local SID_FLOODDETECTED = 0xFF13
	local SID_UDPPINGRESPONSE = 0xFF14
	local SID_CHECKAD = 0xFF15
	local SID_CLICKAD = 0xFF16
	local SID_REGISTRY = 0xFF18
	local SID_MESSAGEBOX = 0xFF19
	local SID_STARTADVEX2 = 0xFF1A
	local SID_GAMEDATAADDRESS = 0xFF1B
	local SID_STARTADVEX3 = 0xFF1C
	local SID_LOGONCHALLENGEEX = 0xFF1D
	local SID_CLIENTID2 = 0xFF1E
	local SID_LEAVEGAME = 0xFF1F
	local SID_DISPLAYAD = 0xFF21
	local SID_NOTIFYJOIN = 0xFF22
	local SID_PING = 0xFF25
	local SID_READUSERDATA = 0xFF26
	local SID_WRITEUSERDATA = 0xFF27
	local SID_LOGONCHALLENGE = 0xFF28
	local SID_LOGONRESPONSE = 0xFF29
	local SID_CREATEACCOUNT = 0xFF2A
	local SID_SYSTEMINFO = 0xFF2B
	local SID_GAMERESULT = 0xFF2C
	local SID_GETICONDATA = 0xFF2D
	local SID_GETLADDERDATA = 0xFF2E
	local SID_FINDLADDERUSER = 0xFF2F
	local SID_CDKEY = 0xFF30
	local SID_CHANGEPASSWORD = 0xFF31
	local SID_CHECKDATAFILE = 0xFF32
	local SID_GETFILETIME = 0xFF33
	local SID_QUERYREALMS = 0xFF34
	local SID_PROFILE = 0xFF35
	local SID_CDKEY2 = 0xFF36
	local SID_LOGONRESPONSE2 = 0xFF3A
	local SID_CHECKDATAFILE2 = 0xFF3C
	local SID_CREATEACCOUNT2 = 0xFF3D
	local SID_LOGONREALMEX = 0xFF3E
	local SID_STARTVERSIONING2 = 0xFF3F
	local SID_QUERYREALMS2 = 0xFF40
	local SID_QUERYADURL = 0xFF41
	local SID_WARCRAFTGENERAL = 0xFF44
	local SID_NETGAMEPORT = 0xFF45
	local SID_NEWS_INFO = 0xFF46
	local SID_OPTIONALWORK = 0xFF4A
	local SID_EXTRAWORK = 0xFF4B
	local SID_REQUIREDWORK = 0xFF4C
	local SID_TOURNAMENT = 0xFF4E
	local SID_AUTH_INFO = 0xFF50
	local SID_AUTH_CHECK = 0xFF51
	local SID_AUTH_ACCOUNTCREATE = 0xFF52
	local SID_AUTH_ACCOUNTLOGON = 0xFF53
	local SID_AUTH_ACCOUNTLOGONPROOF = 0xFF54
	local SID_AUTH_ACCOUNTCHANGE = 0xFF55
	local SID_AUTH_ACCOUNTCHANGEPROOF = 0xFF56
	local SID_AUTH_ACCOUNTUPGRADE = 0xFF57
	local SID_AUTH_ACCOUNTUPGRADEPROOF = 0xFF58
	local SID_SETEMAIL = 0xFF59
	local SID_RESETPASSWORD = 0xFF5A
	local SID_CHANGEEMAIL = 0xFF5B
	local SID_SWITCHPRODUCT = 0xFF5C
	local SID_REPORTCRASH = 0xFF5D
	local SID_WARDEN = 0xFF5E
	local SID_GAMEPLAYERSEARCH = 0xFF60
	local SID_FRIENDSLIST = 0xFF65
	local SID_FRIENDSUPDATE = 0xFF66
	local SID_FRIENDSADD = 0xFF67
	local SID_FRIENDSREMOVE = 0xFF68
	local SID_FRIENDSPOSITION = 0xFF69
	local SID_CLANFINDCANDIDATES = 0xFF70
	local SID_CLANINVITEMULTIPLE = 0xFF71
	local SID_CLANCREATIONINVITATION = 0xFF72
	local SID_CLANDISBAND = 0xFF73
	local SID_CLANMAKECHIEFTAIN = 0xFF74
	local SID_CLANINFO = 0xFF75
	local SID_CLANQUITNOTIFY = 0xFF76
	local SID_CLANINVITATION = 0xFF77
	local SID_CLANREMOVEMEMBER = 0xFF78
	local SID_CLANINVITATIONRESPONSE = 0xFF79
	local SID_CLANRANKCHANGE = 0xFF7A
	local SID_CLANSETMOTD = 0xFF7B
	local SID_CLANMOTD = 0xFF7C
	local SID_CLANMEMBERLIST = 0xFF7D
	local SID_CLANMEMBERREMOVED = 0xFF7E
	local SID_CLANMEMBERSTATUSCHANGE = 0xFF7F
	local SID_CLANMEMBERRANKCHANGE = 0xFF81
	local SID_CLANMEMBERINFORMATION = 0xFF82

	-- Supported data types
	local typemap = {
		["uint64"] = {
			["size"] = function(...) return 8 end,
		},
		["uint32"] = {
			["size"] = function(...) return 4 end,
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
			dissect = function(self, state)
				local size = self.size(state:tvb())
				state.bnet_node:add(self.pf, state:read(size))
			end,
		},
		["stringz"] = {
			["size"] = function(...)
				local buf = arg[1]
				return string.format("%s", buf(0):string()):len() + 1
			end,
		},
		["sockaddr"] = {
			["size"] = function(...) return 16 end,
			["alias"] = "bytes",
		},
	}

	-- ProtoField wrapper
	local WProtoField = {}
	setmetatable(WProtoField, {
		__index = function(t,k)
				return function (...)
					local typeinfo = typemap[k]
					local field = (typeinfo and (
						(typeinfo.alias and ProtoField[typeinfo.alias]) or	
						(ProtoField[k])))

					if typeinfo and field then
						local tmp = {
							["pf"] = field(unpack(arg)),
							["size"]=typeinfo.size,
							["dissect"]=typeinfo.dissect,
						}
						-- Add the field to the protocol field list
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

	-- Packets form server to client
	SPacketDescription = {
		[SID_AUTH_INFO] = {
			WProtoField.uint32("","Logon Type",base.DEC, {
				[0x00] = "Broken SHA-1 (STAR/SEXP/D2DV/D2XP)",
				[0x01] = "NLS version 1 (War3Beta)",
				[0x02] = "NLS Version 2 (WAR3/W3XP)",
			}),
			WProtoField.uint32("","Server Token",base.HEX),
			WProtoField.uint32("","UDPValue",base.HEX),
			WProtoField.uint64("","MPQ Filetime",base.HEX),
			WProtoField.stringz("","IX86 Filename"),
			WProtoField.stringz("","Value String"),
		},
		[SID_NULL] = {},
		[SID_SERVERLIST] = {
			WProtoField.uint32("","Server version"),
			WProtoField.stringz("","[] Server list"),
		},
		[SID_CLIENTID] = {
			WProtoField.uint32("","Registration Version"),
			WProtoField.uint32("","Registration Authority"),
			WProtoField.uint32("","Account Number"),
			WProtoField.uint32("","Registration Token"),
		},
		[SID_STARTVERSIONING] = {
			WProtoField.uint64("","MPQ Filetime"),
			WProtoField.stringz("","MPQ Filename"),
			WProtoField.stringz("","ValueString"),
		},
		[SID_REPORTVERSION] = {
			WProtoField.uint32("","Result"),
			WProtoField.stringz("","Patch path"),
		},
		[SID_STARTADVEX] = {
			WProtoField.uint32("","Status"),
		},
		[SID_GETADVLISTEX] = {
			WProtoField.uint32("","Number of games"),
		},
		[SID_ENTERCHAT] = {
			WProtoField.stringz("","Unique name"),
			WProtoField.stringz("","Statstring"),
			WProtoField.stringz("","Account name"),
		},
		[SID_GETCHANNELLIST] = {
			WProtoField.stringz("","[TODO: array] Channel names"),
		},
		[SID_CHATEVENT] = {
			WProtoField.uint32("","Event ID", base.HEX, {
				[0x01] = "EID_USERSHOW",
				[0x02] = "EID_USERJOIN",
				[0x03] = "EID_USERLEAVE",
				[0x04] = "EID_WHISPERRECEIVED",
				[0x06] = "EID_BROADCAST",
				[0x05] = "EID_USERTALK",
				[0x07] = "EID_CHANNEL",
				[0x09] = "EID_USERUPDATE",
				[0x0A] = "EID_WHISPERSENT",
				[0x0D] = "EID_CHANNELFULL",
				[0x0E] = "EID_CHANNELDOESNOTEXIST",
				[0x0F] = "EID_CHANNELRESTRICTED",
				[0x12] = "EID_INFO",
				[0x13] = "EID_ERROR",
				[0x17] = "EID_EMOTE",
			}),
			WProtoField.uint32("","User's Flags"),
			WProtoField.uint32("","Ping"),
			WProtoField.uint32("","IP Address (Defunct)"),
			WProtoField.uint32("","Account number (Defunct)", base.HEX),
			WProtoField.uint32("","Registration Authority (Defunct)", base.HEX),
			WProtoField.stringz("","Username"),
			WProtoField.stringz("","Text"),
		},
		[SID_FLOODDETECTED] = {},
		[SID_CHECKAD] = {
			WProtoField.uint32("","Ad ID"),
			WProtoField.uint32("","File extension"),
			WProtoField.uint64("","Local file time"),
			WProtoField.stringz("","Filename"),
			WProtoField.stringz("","Link URL"),
		},
		[SID_REGISTRY] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint32("","HKEY"),
			WProtoField.stringz("","Registry path"),
			WProtoField.stringz("","Registry key"),
		},
		[SID_MESSAGEBOX] = {
			WProtoField.uint32("","Style"),
			WProtoField.stringz("","Text"),
			WProtoField.stringz("","Caption"),
		},
		[SID_STARTADVEX3] = {
			WProtoField.uint32("","Status"),
		},
		[SID_LOGONCHALLENGEEX] = {
			WProtoField.uint32("","UDP Token"),
			WProtoField.uint32("","Server Token"),
		},
		[SID_PING] = {
			WProtoField.uint32("","Ping Value", base.HEX),
		},
		[SID_READUSERDATA] = {
			WProtoField.uint32("","Number of accounts"),
			WProtoField.uint32("","Number of keys"),
			WProtoField.uint32("","Request ID"),
			WProtoField.stringz("","[TODO: array] Requested Key Values"),
		},
		[SID_LOGONCHALLENGE] = {
			WProtoField.uint32("","Server Token"),
		},
		[SID_LOGONRESPONSE] = {
			WProtoField.uint32("","Result"),
		},
		[SID_CREATEACCOUNT] = {
			WProtoField.uint32("","Result"),
		},
		[SID_GETICONDATA] = {
			WProtoField.uint64("","Filetime"),
			WProtoField.stringz("","Filename"),
		},
		[SID_GETFILETIME] = {
			WProtoField.uint32("","Request ID"),
			WProtoField.uint32("","Unknown"),
			WProtoField.uint64("","Last update time"),
			WProtoField.stringz("","Filename"),
		},
		[SID_QUERYREALMS] = {
			WProtoField.uint32("","Unknown"),
			WProtoField.uint32("","Count"),
		},
		[SID_PROFILE] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint8("","Success"),
			WProtoField.stringz("","ProfileDescription value"),
			WProtoField.stringz("","ProfileLocation value"),
			WProtoField.uint32("","Clan Tag"),
		},
		[SID_CDKEY2] = {
			WProtoField.uint32("","Result"),
			WProtoField.stringz("","Key owner"),
		},
		[SID_LOGONRESPONSE2] = {
			WProtoField.uint32("","Result", base.HEX, {
				[0x00] = "Login successful",
				[0x01] = "Account does not exist",
				[0x02] = "Invalid password",
				-- [0x06] = "Account closed"	-- TODO
			}),
			WProtoField.stringz("","Reason"),
		},
		[SID_CHECKDATAFILE2] = {
			WProtoField.uint32("","Result"),
		},
		[SID_NEWS_INFO] = {
			WProtoField.uint8("","Number of entries"),
			WProtoField.uint32("","Last logon timestamp"),
			WProtoField.uint32("","Oldest news timestamp"),
			WProtoField.uint32("","Newest news timestamp"),
		},
		[SID_OPTIONALWORK] = {
			WProtoField.stringz("","MPQ Filename"),
		},
		[SID_REQUIREDWORK] = {
			WProtoField.stringz("","ExtraWork MPQ FileName"),
		},
		[SID_TOURNAMENT] = {
			WProtoField.uint8("","Unknown"),
			WProtoField.uint8("","Unknown, maybe number of non-null strings sent?"),
			WProtoField.stringz("","Description"),
			WProtoField.stringz("","Unknown"),
			WProtoField.stringz("","Website"),
			WProtoField.uint32("","Unknown"),
			WProtoField.stringz("","Name"),
			WProtoField.stringz("","Unknown"),
			WProtoField.stringz("","Unknown"),
			WProtoField.stringz("","Unknown"),
			WProtoField.uint32("","(TODO [5]) Unknown"),
		},
		[SID_AUTH_CHECK] = {
			WProtoField.uint32("","Result", base.HEX, { -- TODO -xpeh
				[0x000] = "Passed challenge",
				[0x100] = "Old game version (Additional info field supplies patch MPQ filename)",
				[0x101] = "Invalid version",
				[0x102] = "Game version must be downgraded (Additional info field supplies patch MPQ filename)",
				-- 0x0NN: (where NN is the version code supplied in SID_AUTH_INFO): Invalid version code (note that 0x100 is not set in this case).
				[0x200] = "Invalid CD key ",
				[0x201] = "CD key in use (Additional info field supplies name of user)",
				[0x202] = "Banned key",
				[0x203] = "Wrong product",
				-- The last 4 codes also apply to the second cdkey, as indicated by a bitwise combination with 0x010.  
			}),
			WProtoField.stringz("","Additional Information"),
		},
		[SID_AUTH_ACCOUNTCREATE] = {
			WProtoField.uint32("","Status"),
		},
		[SID_AUTH_ACCOUNTLOGON] = {
			WProtoField.uint32("","Status"),
			WProtoField.uint8("","(TODO [32]) Salt (s)"),
			WProtoField.uint8("","(TODO [32]) Server Key (B)"),
		},
		[SID_AUTH_ACCOUNTLOGONPROOF] = {
			WProtoField.uint32("","Status"),
			WProtoField.uint8("","(TODO [20]) Server Password Proof (M2)"),
			WProtoField.stringz("","Additional information"),
		},
		[SID_AUTH_ACCOUNTCHANGE] = {
			WProtoField.uint32("","Status"),
			WProtoField.uint8("","[32] Salt (s)"),
			WProtoField.uint8("","[32] Server key (B)"),
		},
		[SID_AUTH_ACCOUNTCHANGEPROOF] = {
			WProtoField.uint32("","Status code"),
			WProtoField.uint8("","[20] Server password proof for old password (M2)"),
		},
		[SID_AUTH_ACCOUNTUPGRADE] = {
			WProtoField.uint32("","Status"),
			WProtoField.uint32("","Server Token"),
		},
		[SID_AUTH_ACCOUNTUPGRADEPROOF] = {
			WProtoField.uint32("","Status"),
			WProtoField.uint32("","[5] Password proof"),
		},
		[SID_WARDEN] = {},
		[SID_GAMEPLAYERSEARCH] = {
			WProtoField.uint8("","Number of players"),
			WProtoField.stringz("","[] Player names"),
		},
		[SID_FRIENDSLIST] = {
			WProtoField.uint8("","Number of Entries"),
		},
		[SID_FRIENDSUPDATE] = {
			WProtoField.uint8("","Entry number"),
			WProtoField.uint8("","Friend Location"),
			WProtoField.uint8("","Friend Status"),
			WProtoField.uint32("","ProductID"),
			WProtoField.stringz("","Location"),
		},
		[SID_FRIENDSADD] = {
			WProtoField.stringz("","Account"),
			WProtoField.uint8("","Friend Type"),
			WProtoField.uint8("","Friend Status"),
			WProtoField.uint32("","ProductID"),
			WProtoField.stringz("","Location"),
		},
		[SID_FRIENDSREMOVE] = {
			WProtoField.uint8("","Entry Number"),
		},
		[SID_FRIENDSPOSITION] = {
			WProtoField.uint8("","Old Position"),
			WProtoField.uint8("","New Position"),
		},
		[SID_CLANFINDCANDIDATES] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint8("","Status"),
			WProtoField.uint8("","Number of potential candidates"),
			WProtoField.stringz("","[] Usernames"),
		},
		[SID_CLANINVITEMULTIPLE] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint8("","Result"),
			WProtoField.stringz("","[] Failed account names"),
		},
		[SID_CLANCREATIONINVITATION] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint32("","Clan Tag"),
			WProtoField.stringz("","Clan Name"),
			WProtoField.stringz("","Inviter's username"),
			WProtoField.uint8("","Number of users being invited"),
			WProtoField.stringz("","[] List of users being invited"),
		},
		[SID_CLANDISBAND] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint8("","Result"),
		},
		[SID_CLANMAKECHIEFTAIN] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint8("","Status"),
		},
		[SID_CLANINFO] = {
			WProtoField.uint8("","Unknown (0)"),
			WProtoField.uint32("","Clan tag"),
			WProtoField.uint8("","Rank"),
		},
		[SID_CLANQUITNOTIFY] = {
			WProtoField.uint8("","Status"),
		},
		[SID_CLANINVITATION] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint8("","Result"),
		},
		[SID_CLANREMOVEMEMBER] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint8("","Status"),
		},
		[SID_CLANINVITATIONRESPONSE] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint32("","Clan tag"),
			WProtoField.stringz("","Clan name"),
			WProtoField.stringz("","Inviter"),
		},
		[SID_CLANRANKCHANGE] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint8("","Status"),
		},
		[SID_CLANMOTD] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint32("","Unknown (0)"),
			WProtoField.stringz("","MOTD"),
		},
		[SID_CLANMEMBERLIST] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint8("","Number of Members"),
			WProtoField.stringz("","Username"),
			WProtoField.uint8("","Rank"),
			WProtoField.uint8("","Online Status"),
			WProtoField.stringz("","Location"),
		},
		[SID_CLANMEMBERREMOVED] = {
			WProtoField.stringz("","Clan member name"),
		},
		[SID_CLANMEMBERSTATUSCHANGE] = {
			WProtoField.stringz("","Username"),
			WProtoField.uint8("","Rank"),
			WProtoField.uint8("","Status"),
			WProtoField.stringz("","Location"),
		},
		[SID_CLANMEMBERRANKCHANGE] = {
			WProtoField.uint8("","Old rank"),
			WProtoField.uint8("","New rank"),
			WProtoField.stringz("","Clan member who changed your rank"),
		},
		[SID_CLANMEMBERINFORMATION] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint8("","Status code"),
			WProtoField.stringz("","Clan name"),
			WProtoField.uint8("","User's rank"),
			WProtoField.uint64("","Date joined"),
		},
--[[ TODO: unsupported packets follow.
		[PKT_SERVERPING] = {
			WProtoField.uint32("","UDP Code"),
		},
		[MCP_STARTUP] = {
			WProtoField.uint32("","Result"),
		},
		[MCP_CHARCREATE] = {
			WProtoField.uint32("","Result"),
		},
		[MCP_CREATEGAME] = {
			WProtoField.uint16("","Request Id"),
			WProtoField.uint16("","Game token"),
			WProtoField.uint16("","Unknown (0)"),
			WProtoField.uint32("","Result"),
		},
		[MCP_JOINGAME] = {
			WProtoField.uint16("","Request ID"),
			WProtoField.uint16("","Game token"),
			WProtoField.uint16("","Unknown (0)"),
			WProtoField.uint32("","IP of D2GS Server"),
			WProtoField.uint32("","Game hash"),
			WProtoField.uint32("","Result"),
		},
		[MCP_GAMELIST] = {
			WProtoField.uint16("","Request Id"),
			WProtoField.uint32("","Index"),
			WProtoField.uint8("","Number of players in game"),
			WProtoField.uint32("","Status"),
			WProtoField.stringz("","Game name"),
			WProtoField.stringz("","Game description"),
		},
		[MCP_GAMEINFO] = {
			WProtoField.uint16("","Request ID"),
			WProtoField.uint32("","Status *"),
			WProtoField.uint32("","Game Uptime (seconds)"),
			WProtoField.uint16("","Unknown"),
			WProtoField.uint8("","Maximum players allowed"),
			WProtoField.uint8("","Number of characters in the game"),
			WProtoField.uint8("","[16] Classes of ingame characters **"),
			WProtoField.uint8("","[16] Levels of ingame characters **"),
			WProtoField.uint8("","Unused (0)"),
			WProtoField.stringz("","[16] Character names **"),
		},
		[MCP_CHARLOGON] = {
			WProtoField.uint32("","Result"),
		},
		[MCP_CHARDELETE] = {
			WProtoField.uint32("","Result"),
		},
		[MCP_REQUESTLADDERDATA] = {
			WProtoField.uint8("","Ladder type"),
			WProtoField.uint16("","Total response size"),
			WProtoField.uint16("","Current message size"),
			WProtoField.uint16("","Total size of unreceived messages"),
			WProtoField.uint16("","Rank of first entry"),
			WProtoField.uint16("","Unknown (0) Message data:"),
			WProtoField.uint32("","Number of entries"),
			WProtoField.uint32("","Unknown (0x10)"),
		},
		[MCP_MOTD] = {
			WProtoField.uint8("","Unknown"),
			WProtoField.stringz("","MOTD"),
		},
		[MCP_CREATEQUEUE] = {
			WProtoField.uint32("","Position"),
		},
		[MCP_CHARLIST] = {
			WProtoField.uint16("","Number of characters requested"),
			WProtoField.uint32("","Number of characters that exist on this account"),
			WProtoField.uint16("","Number of characters returned"),
		},
		[MCP_CHARUPGRADE] = {
			WProtoField.uint32("","Result"),
		},
		[MCP_CHARLIST2] = {
			WProtoField.uint16("","Number of characters requested"),
			WProtoField.uint32("","Number of characters that exist on this account"),
			WProtoField.uint16("","Number of characters returned"),
		},
		[D2GS_CHARTOOBJ] = {
			WProtoField.uint8("","Unknown"),
			WProtoField.uint32("","Player ID"),
			WProtoField.uint8("","Movement Type"),
			WProtoField.uint8("","Destination Type"),
			WProtoField.uint32("","Object ID"),
			WProtoField.uint16("","X Coordinate"),
			WProtoField.uint16("","Y Coordinate"),
		},
		[D2GS_SMALLGOLDPICKUP] = {
			WProtoField.uint8("","Amount"),
		},
		[D2GS_SETBYTEATTR] = {
			WProtoField.uint8("","Attribute"),
			WProtoField.uint8("","Amount"),
		},
		[D2GS_SETWORDATTR] = {
			WProtoField.uint8("","Attribute"),
			WProtoField.uint16("","Amount"),
		},
		[D2GS_SETDWORDATTR] = {
			WProtoField.uint8("","Attribute - D2GS_SETWORDATTR"),
			WProtoField.uint32("","Amount"),
		},
		[D2GS_WORLDOBJECT] = {
			WProtoField.uint8("","Object Type - Any information appreciated"),
			WProtoField.uint32("","Object ID"),
			WProtoField.uint16("","Object unique code"),
			WProtoField.uint16("","X Coordinate"),
			WProtoField.uint16("","Y Coordinate"),
			WProtoField.uint8("","State *"),
			WProtoField.uint8("","Interaction Condition"),
		},
		????????? [D2GS_(COMP)STARTGAME] = {}, ?????????????????
		[D2GS_TRADEACTION] = {
			WProtoField.uint8("","Request Type"),
		},
		[D2GS_LOGONRESPONSE] = {
			WProtoField.uint32("","Unknown - Possible acceptance/request ID"),
		},
		[D2GS_UNIQUEEVENTS] = {
			WProtoField.uint8("","EventId // see below,"),
		},
		[D2GS_STARTLOGON] = {
		},
		[PACKET_IDLE] = {},
		[PACKET_LOGON] = {
			WProtoField.uint32("","Result"),
		},
		[PACKET_STATSUPDATE] = {
			WProtoField.uint32("","Result"),
		},
		[PACKET_DATABASE] = {
			WProtoField.uint32("","command"),
		},
		[BNLS_AUTHORIZEPROOF] = {
			WProtoField.uint32("","Status code."),
		},
		[BNLS_REQUESTVERSIONBYTE] = {
			WProtoField.uint32("","Product"),
		},
		[BNLS_VERIFYSERVER] = {
			WProtoField.uint32("","Success. (32-bit)"),
		},
		[BNLS_RESERVESERVERSLOTS] = {
			WProtoField.uint32("","Number of slots reserved"),
		},
		[BNLS_SERVERLOGONCHALLENGE] = {
			WProtoField.uint32("","Slot index."),
			WProtoField.uint32("","[16] Data for server's SID_AUTH_ACCOUNTLOGON (0x53) response."),
		},
		[BNLS_SERVERLOGONPROOF] = {
			WProtoField.uint32("","Slot index."),
			WProtoField.uint32("","Success. (32-bit)"),
			WProtoField.uint32("","[5] Data server's SID_AUTH_ACCOUNTLOGONPROOF (0x54) response."),
		},
		[BNLS_VERSIONCHECKEX] = {
			WProtoField.uint32("","Success*"),
			WProtoField.uint32("","Version."),
			WProtoField.uint32("","Checksum."),
			WProtoField.stringz("","Version check stat string."),
			WProtoField.uint32("","Cookie."),
			WProtoField.uint32("","The latest version code for this product."),
		},
		[BNLS_VERSIONCHECKEX2] = {
			WProtoField.uint32("","Success*"),
			WProtoField.uint32("","Version."),
			WProtoField.uint32("","Checksum."),
			WProtoField.stringz("","Version check stat string."),
			WProtoField.uint32("","Cookie."),
			WProtoField.uint32("","The latest version code for this product."),
		},
--]]
	}

	-- Packets form client to server
	CPacketDescription = {
		[SID_AUTH_INFO] = {
			WProtoField.uint32("","Protocol ID",base.DEC),
			WProtoField.uint32("","Platform ID",base.HEX),
			WProtoField.uint32("","Product ID",base.HEX),
			WProtoField.uint32("","Version Byte",base.HEX),
			WProtoField.uint32("","Product Laguage",base.HEX),
			WProtoField.ipv4("","Local IP"),
			WProtoField.int32("","Timezone Bias"),
			WProtoField.uint32("","Locale ID", base.HEX),
			WProtoField.uint32("","Language ID", base.HEX),
			WProtoField.stringz("","Country Abbreviation"),
			WProtoField.stringz("","Country"),
		},
		[SID_NULL] = {},
		[SID_STOPADV] = {},
		[SID_CLIENTID] = {
			WProtoField.uint32("","Registration Version"),
			WProtoField.uint32("","Registration Authority"),
			WProtoField.uint32("","Account Number"),
			WProtoField.uint32("","Registration Token"),
			WProtoField.stringz("","LAN Computer Name"),
			WProtoField.stringz("","LAN Username"),
		},
		[SID_STARTVERSIONING] = {
			WProtoField.uint32("","Platform ID"),
			WProtoField.uint32("","Product ID"),
			WProtoField.uint32("","Version Byte"),
			WProtoField.uint32("","Unknown (0)"),
		},
		[SID_REPORTVERSION] = {
			WProtoField.uint32("","Platform ID"),
			WProtoField.uint32("","Product ID"),
			WProtoField.uint32("","Version Byte"),
			WProtoField.uint32("","EXE Version"),
			WProtoField.uint32("","EXE Hash"),
			WProtoField.stringz("","EXE Information"),
		},
		[SID_STARTADVEX] = {
			WProtoField.uint32("","Password protected (32-bit)"),
			WProtoField.uint32("","Unknown"),
			WProtoField.uint32("","Unknown"),
			WProtoField.uint32("","Unknown"),
			WProtoField.uint32("","Unknown"),
			WProtoField.uint32("","Port"),
			WProtoField.stringz("","Game name"),
			WProtoField.stringz("","Game password"),
			WProtoField.stringz("","Game stats - flags, creator, statstring"),
			WProtoField.stringz("","Map name - 0x0d terminated"),
		},
		[SID_GETADVLISTEX] = {
			WProtoField.uint16("","Product-specific condition 1"),
			WProtoField.uint16("","Product-specific condition 2"),
			WProtoField.uint32("","Product-specific condition 3"),
			WProtoField.uint32("","Product-specific condition 4"),
			WProtoField.uint32("","List count"),
			WProtoField.stringz("","Game name"),
			WProtoField.stringz("","Game password"),
			WProtoField.stringz("","Game stats"),
		},
		[SID_ENTERCHAT] = {
			WProtoField.stringz("","Username"),
			WProtoField.stringz("","Statstring"),
		},
		[SID_GETCHANNELLIST] = {
			WProtoField.uint32("","Product ID"),
		},
		[SID_JOINCHANNEL] = {
			WProtoField.uint32("","Flags"),
			WProtoField.stringz("","Channel"),
		},
		[SID_CHATCOMMAND] = {
			WProtoField.stringz("","Text"),
		},
		[SID_LEAVECHAT] = {},
		[SID_LOCALEINFO] = {
			WProtoField.uint64("","System time"),
			WProtoField.uint64("","Local time"),
			WProtoField.uint32("","Timezone bias"),
			WProtoField.uint32("","SystemDefaultLCID"),
			WProtoField.uint32("","UserDefaultLCID"),
			WProtoField.uint32("","UserDefaultLangID"),
			WProtoField.stringz("","Abbreviated language name"),
			WProtoField.stringz("","Country name"),
			WProtoField.stringz("","Abbreviated country name"),
			WProtoField.stringz("","Country (English)"),
		},
		[SID_UDPPINGRESPONSE] = {
			WProtoField.uint32("","UDPCode"),
		},
		[SID_CHECKAD] = {
			WProtoField.uint32("","Platform ID"),
			WProtoField.uint32("","Product ID"),
			WProtoField.uint32("","ID of last displayed banner"),
			WProtoField.uint32("","Current time"),
		},
		[SID_CLICKAD] = {
			WProtoField.uint32("","Ad ID"),
			WProtoField.uint32("","Request type"),
		},
		[SID_REGISTRY] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.stringz("","Key Value"),
		},
		[SID_STARTADVEX2] = {
			WProtoField.uint32("","Password Protected"),
			WProtoField.uint32("","Unknown"),
			WProtoField.uint32("","Unknown"),
			WProtoField.uint32("","Unknown"),
			WProtoField.uint32("","Unknown"),
			WProtoField.uint32("","Port"),
			WProtoField.stringz("","Game name"),
			WProtoField.stringz("","Game password"),
			WProtoField.stringz("","Unknown"),
			WProtoField.stringz("","Game stats - Flags, Creator, Statstring"),
		},
		[SID_GAMEDATAADDRESS] = {
			WProtoField.sockaddr("","Address"),
		},
		[SID_STARTADVEX3] = {
			WProtoField.uint32("","State"),
			WProtoField.uint32("","Time since creation"),
			WProtoField.uint16("","Game Type"),
			WProtoField.uint16("","Parameter"),
			WProtoField.uint32("","Unknown (1F)"),
			WProtoField.uint32("","Ladder"),
			WProtoField.stringz("","Game name"),
			WProtoField.stringz("","Game password"),
			WProtoField.stringz("","Game Statstring"),
		},
		[SID_CLIENTID2] = {
			WProtoField.uint32("","[TODO: Broken] Server Version"),
		},
		[SID_LEAVEGAME] = {},
		[SID_DISPLAYAD] = {
			WProtoField.uint32("","Platform ID"),
			WProtoField.uint32("","Product ID"),
			WProtoField.uint32("","Ad ID"),
			WProtoField.stringz("","Filename"),
			WProtoField.stringz("","URL"),
		},
		[SID_NOTIFYJOIN] = {
			WProtoField.uint32("","Product ID *"),
			WProtoField.uint32("","Product version"),
			WProtoField.stringz("","Game Name"),
			WProtoField.stringz("","Game Password"),
		},
		[SID_PING] = {
			WProtoField.uint32("","Ping Value", base.HEX),
		},
		[SID_READUSERDATA] = {
			WProtoField.uint32("","Number of Accounts"),
			WProtoField.uint32("","Number of Keys"),
			WProtoField.uint32("","Request ID"),
			WProtoField.stringz("","[] Requested Accounts"),
			WProtoField.stringz("","[] Requested Keys"),
		},
		[SID_WRITEUSERDATA] = {
			WProtoField.uint32("","Number of accounts"),
			WProtoField.uint32("","Number of keys"),
			WProtoField.stringz("","[] Accounts to update"),
			WProtoField.stringz("","[] Keys to update"),
			WProtoField.stringz("","[] New values"),
		},
		[SID_LOGONRESPONSE] = {
			WProtoField.uint32("","Client Token", base.HEX),
			WProtoField.uint32("","Server Token", base.HEX),
			WProtoField.uint32("","[5] Password Hash", base.HEX),
			WProtoField.stringz("","Username"),
		},
		[SID_CREATEACCOUNT] = {
			WProtoField.uint32("","[5] Hashed password"),
			WProtoField.stringz("","Username"),
		},
		[SID_SYSTEMINFO] = {
			WProtoField.uint32("","Number of processors"),
			WProtoField.uint32("","Processor architecture"),
			WProtoField.uint32("","Processor level"),
			WProtoField.uint32("","Processor timing"),
			WProtoField.uint32("","Total physical memory"),
			WProtoField.uint32("","Total page file"),
			WProtoField.uint32("","Free disk space"),
		},
		[SID_GAMERESULT] = {
			WProtoField.uint32("","Game type"),
			WProtoField.uint32("","Number of results - always 8"),
			WProtoField.uint32("","[8] Results"),
			WProtoField.stringz("","[8] Game players - always 8"),
			WProtoField.stringz("","Map name"),
			WProtoField.stringz("","Player score"),
		},
		[SID_GETICONDATA] = {},
		[SID_CHECKDATAFILE] = {
			WProtoField.uint32("","[5] File checksum"),
			WProtoField.stringz("","File name"),
		},
		[SID_GETFILETIME] = {
			WProtoField.uint32("","Request ID"),
			WProtoField.uint32("","Unknown"),
			WProtoField.stringz("","Filename"),
		},
		[SID_QUERYREALMS] = {
			WProtoField.uint32("","Unused (0)"),
			WProtoField.uint32("","Unused (0)"),
			WProtoField.stringz("","Unknown (empty)"),
		},
		[SID_PROFILE] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.stringz("","Username"),
		},
		[SID_CDKEY2] = {
			WProtoField.uint32("","Spawn (0/1)"),
			WProtoField.uint32("","Key Length"),
			WProtoField.uint32("","CDKey Product"),
			WProtoField.uint32("","CDKey Value1"),
			WProtoField.uint32("","Server Token"),
			WProtoField.uint32("","Client Token"),
			WProtoField.uint32("","[5] Hashed Data"),
			WProtoField.stringz("","Key owner"),
		},
		[SID_LOGONRESPONSE2] = {
			WProtoField.uint32("","Client Token", base.HEX),
			WProtoField.uint32("","Server Token", base.HEX),
			WProtoField.uint32("","[5] Password Hash"),
			WProtoField.stringz("","Username"),
		},
		[SID_CHECKDATAFILE2] = {
			WProtoField.uint32("","File size in bytes"),
			WProtoField.uint32("","File hash [5]"),
			WProtoField.stringz("","Filename"),
		},
		[SID_WARCRAFTGENERAL] = {
			WProtoField.uint8("","Subcommand ID"),
		},
		[SID_NETGAMEPORT] = {
			WProtoField.uint16("","Port"),
		},
		[SID_NEWS_INFO] = {
			WProtoField.uint32("","News timestamp"),
		},
		[SID_EXTRAWORK] = {
			WProtoField.uint16("","Game type"),
			WProtoField.uint16("","Length"),
			WProtoField.stringz("","Work returned data"),
		},
		[SID_AUTH_CHECK] = {
			WProtoField.uint32("","Client Token", base.HEX),
			WProtoField.uint32("","EXE Version", base.HEX),  -- TODO: game version
			WProtoField.uint32("","EXE Hash", base.HEX),
			WProtoField.uint32("","Number of CD-keys in this packet"),
			WProtoField.uint32("","Spawn CD-key"),
			-- EDIT
			WProtoField.uint32("","CD-key length"),
			WProtoField.uint32("","Product ID"),
			WProtoField.uint32("","Public value", base.HEX),
		},
		[SID_AUTH_ACCOUNTCREATE] = {
			WProtoField.uint8("","[32] Salt (s)"),
			WProtoField.uint8("","[32] Verifier (v)"),
			WProtoField.stringz("","Username"),
		},
		[SID_AUTH_ACCOUNTLOGON] = {
			WProtoField.uint8("","[32] Client Key ('A')"),
			WProtoField.stringz("","Username"),
		},
		[SID_AUTH_ACCOUNTCHANGE] = {
			WProtoField.uint8("","[32] Client key (A)"),
			WProtoField.stringz("","Username"),
		},
		[SID_AUTH_ACCOUNTCHANGEPROOF] = {
			WProtoField.uint8("","[20] Old password proof"),
			WProtoField.uint8("","[32] New password's salt (s)"),
			WProtoField.uint8("","[32] New password's verifier (v)"),
		},
		[SID_AUTH_ACCOUNTUPGRADE] = {},
		[SID_AUTH_ACCOUNTUPGRADEPROOF] = {
			WProtoField.uint32("","Client Token", base.HEX),
			WProtoField.uint32("","[5] Old Password Hash"),
			WProtoField.uint8("","[32] New Password Salt"),
			WProtoField.uint8("","[32] New Password Verifier"),
		},
		[SID_REPORTCRASH] = {
			WProtoField.uint32("","0x10A0027"),
			WProtoField.uint32("","Exception code"),
			WProtoField.uint32("","Unknown"),
			WProtoField.uint32("","Unknown"),
		},
		[SID_WARDEN] = {},
		[SID_GAMEPLAYERSEARCH] = {},
		[SID_FRIENDSLIST] = {},
		[SID_FRIENDSUPDATE] = {
			WProtoField.uint8("","Friends list index"),
		},
		[SID_CLANFINDCANDIDATES] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint32("","Clan Tag"),
		},
		[SID_CLANINVITEMULTIPLE] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.stringz("","Clan name"),
			WProtoField.uint32("","Clan tag"),
			WProtoField.uint8("","Number of users to invite"),
			WProtoField.stringz("","[] Usernames to invite"),
		},
		[SID_CLANCREATIONINVITATION] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint32("","Clan tag"),
			WProtoField.stringz("","Inviter name"),
			WProtoField.uint8("","Status"),
		},
		[SID_CLANDISBAND] = {
			WProtoField.uint32("","Cookie"),
		},
		[SID_CLANMAKECHIEFTAIN] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.stringz("","New Cheiftain"),
		},
		[SID_CLANINVITATION] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.stringz("","Target User"),
		},
		[SID_CLANREMOVEMEMBER] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.stringz("","Username"),
		},
		[SID_CLANINVITATIONRESPONSE] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint32("","Clan tag"),
			WProtoField.stringz("","Inviter"),
			WProtoField.uint8("","Response"),
		},
		[SID_CLANRANKCHANGE] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.stringz("","Username"),
			WProtoField.uint8("","New rank"),
		},
		[SID_CLANSETMOTD] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.stringz("","MOTD"),
		},
		[SID_CLANMOTD] = {
			WProtoField.uint32("","Cookie"),
		},
		[SID_CLANMEMBERLIST] = {
			WProtoField.uint32("","Cookie"),
		},
		[SID_CLANMEMBERINFORMATION] = {
			WProtoField.uint32("","Cookie"),
			WProtoField.uint32("","User's clan tag"),
			WProtoField.stringz("","Username"),
		},
--[[ TODO: unsupported packets follow.
		[PKT_CLIENTREQ] = {
			WProtoField.uint32("","Code"),
		},
		[PKT_KEEPALIVE] = {
			WProtoField.uint32("","Tick count"),
		},
		[PKT_CONNTEST] = {
			WProtoField.uint32("","Server Token"),
		},
		[PKT_CONNTEST2] = {
			WProtoField.uint32("","Server Token"),
			WProtoField.uint32("","UDP Token*"),
		},
		[MCP_STARTUP] = {
			WProtoField.uint32("","MCP Cookie"),
			WProtoField.uint32("","MCP Status"),
			WProtoField.uint32("","[2] MCP Chunk 1"),
			WProtoField.uint32("","[12] MCP Chunk 2"),
			WProtoField.stringz("","Battle.net Unique Name"),
		},
		[MCP_CHARCREATE] = {
			WProtoField.uint32("","Character class"),
			WProtoField.uint16("","Character flags"),
			WProtoField.stringz("","Character name"),
		},
		[MCP_CREATEGAME] = {
			WProtoField.uint16("","Request Id *"),
			WProtoField.uint32("","Difficulty"),
			WProtoField.uint8("","Unknown - 1"),
			WProtoField.uint8("","Player difference **"),
			WProtoField.uint8("","Maximum players"),
			WProtoField.stringz("","Game name"),
			WProtoField.stringz("","Game password"),
			WProtoField.stringz("","Game description"),
		},
		[MCP_JOINGAME] = {
			WProtoField.uint16("","Request ID"),
			WProtoField.stringz("","Game name"),
			WProtoField.stringz("","Game Password"),
		},
		[MCP_GAMELIST] = {
			WProtoField.uint16("","Request ID"),
			WProtoField.uint32("","Unknown (0)"),
			WProtoField.stringz("","Search String *"),
		},
		[MCP_GAMEINFO] = {
			WProtoField.uint16("","Request ID"),
			WProtoField.stringz("","Game name"),
		},
		[MCP_CHARLOGON] = {
			WProtoField.stringz("","Character name"),
		},
		[MCP_CHARDELETE] = {
			WProtoField.uint16("","Unknown (0)"),
			WProtoField.stringz("","Character name"),
		},
		[MCP_REQUESTLADDERDATA] = {
			WProtoField.uint8("","Ladder type"),
			WProtoField.uint16("","Starting position"),
		},
		[MCP_MOTD] = {},
		[MCP_CANCELGAMECREATE] = {},
		[MCP_CHARLIST] = {
			WProtoField.uint32("","Number of characters to list"),
		},
		[MCP_CHARUPGRADE] = {
			WProtoField.stringz("","Character Name"),
		},
		[MCP_CHARLIST2] = {
			WProtoField.uint32("","Number of characters to list."),
		},
		[D2GS_WALKTOLOCATION] = {
			WProtoField.uint16("","X coordinate"),
			WProtoField.uint16("","Y coordinate"),
		},
		[D2GS_WALKTOENTITY] = {
			WProtoField.uint32("","*Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_RUNTOLOCATION] = {
			WProtoField.uint16("","X coordinate"),
			WProtoField.uint16("","Y coordinate"),
		},
		[D2GS_RUNTOENTITY] = {
			WProtoField.uint32("","*Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_LEFTSKILLONLOCATION] = {
			WProtoField.uint16("","X coordinate"),
			WProtoField.uint16("","Y coordinate"),
		},
		[D2GS_LEFTSKILLONENTITY] = {
			WProtoField.uint32("","*Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_LEFTSKILLONENTITYEX] = {
			WProtoField.uint32("","Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_LEFTSKILLONLOCATIONEX] = {
			WProtoField.uint16("","X coordinate"),
			WProtoField.uint16("","Y coordinate"),
		},
		[D2GS_LEFTSKILLONENTITYEX2] = {
			WProtoField.uint32("","*Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_LEFTSKILLONENTITYEX3] = {
			WProtoField.uint32("","*Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_RIGHTSKILLONLOCATION] = {
			WProtoField.uint16("","X coordinate"),
			WProtoField.uint16("","Y coordinate"),
		},
		[D2GS_RIGHTSKILLONENTITY] = {
			WProtoField.uint32("","Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_RIGHTSKILLONENTITYEX] = {
			WProtoField.uint32("","Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_RIGHTSKILLONLOCATIONEX] = {
			WProtoField.uint16("","X coordinate"),
			WProtoField.uint16("","Y coordinate"),
		},
		[D2GS_RIGHTSKILLONENTITYEX2] = {
			WProtoField.uint32("","Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_RIGHTSKILLONENTITYEX3] = {
			WProtoField.uint32("","Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_INTERACTWITHENTITY] = {
			WProtoField.uint32("","Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_OVERHEADMESSAGE] = {
			WProtoField.uint16("","Unknown - 0x00, 0x00"),
			WProtoField.stringz("","Message"),
			WProtoField.uint8("","Unused - 0x00"),
			WProtoField.uint16("","Unknown - 0x00, 0x00"),
		},
		[D2GS_CHATMESSAGE] = {
			WProtoField.uint8("","Message Type"),
			WProtoField.uint8("","Unknown"),
			WProtoField.stringz("","Message"),
			WProtoField.uint8("","Unknown"),
			WProtoField.uint16("","Unknown - Only if normal chat"),
			WProtoField.stringz("","Player to whisper to - Only if whispering"),
			WProtoField.uint8("","Unknown - Only if whispering"),
		},
		[D2GS_PICKUPITEM] = {
			WProtoField.uint32("","Unit Type"),
			WProtoField.uint32("","Unit ID"),
			WProtoField.uint32("","Action ID"),
		},
		[D2GS_DROPITEM] = {
			WProtoField.uint32("","Item ID"),
		},
		[D2GS_ITEMTOBUFFER] = {
			WProtoField.uint32("","Item ID"),
			WProtoField.uint32("","X coordinate"),
			WProtoField.uint32("","Y coordinate"),
			WProtoField.uint32("","Buffer Type"),
		},
		[D2GS_PICKUPBUFFERITEM] = {
			WProtoField.uint32("","Item ID"),
		},
		[D2GS_ITEMTOBODY] = {
			WProtoField.uint32("","Item ID"),
			WProtoField.uint32("","Body Location"),
		},
		[D2GS_SWAP2HANDEDITEM] = {
			WProtoField.uint32("","Item ID"),
			WProtoField.uint32("","Body Location"),
		},
		[D2GS_PICKUPBODYITEM] = {
			WProtoField.uint16("","Body Location"),
		},
		[D2GS_SWITCHBODYITEM] = {
			WProtoField.uint32("","Item ID"),
			WProtoField.uint32("","Body Location"),
		},
		[D2GS_SWITCHINVENTORYITEM] = {
			WProtoField.uint32("","Item ID - Item to place in inventory (cursor buffer)"),
			WProtoField.uint32("","Item ID - Item to be replaced"),
			WProtoField.uint32("","X coordinate for replace"),
			WProtoField.uint32("","Y coordinate for replace"),
		},
		[D2GS_USEITEM] = {
			WProtoField.uint32("","Item ID"),
			WProtoField.uint32("","X coordinate"),
			WProtoField.uint32("","Y coordinate"),
		},
		[D2GS_STACKITEM] = {
			WProtoField.uint32("","Item ID - Stack item"),
			WProtoField.uint32("","Item ID - Target item"),
		},
		[D2GS_REMOVESTACKITEM] = {
			WProtoField.uint32("","Item ID"),
		},
		[D2GS_ITEMTOBELT] = {
			WProtoField.uint32("","Item ID"),
			WProtoField.uint32("","Belt Location"),
		},
		[D2GS_REMOVEBELTITEM] = {
			WProtoField.uint32("","Item ID"),
		},
		[D2GS_SWITCHBELTITEM] = {
			WProtoField.uint32("","Item ID - Cursor buffer"),
			WProtoField.uint32("","Item ID - Item to be replaced"),
		},
		[D2GS_USEBELTITEM] = {
			WProtoField.uint32("","Item ID"),
			WProtoField.uint32("","Unknown - Possibly unused"),
			WProtoField.uint32("","Unknown - Possibly unused"),
		},
		[D2GS_INSERTSOCKETITEM] = {
			WProtoField.uint32("","Item ID - Item to place in socket"),
			WProtoField.uint32("","Item ID - Socketed item"),
		},
		[D2GS_SCROLLTOTOME] = {
			WProtoField.uint32("","Item ID - Scroll"),
			WProtoField.uint32("","Item ID - Tome"),
		},
		[D2GS_ITEMTOCUBE] = {
			WProtoField.uint32("","Item ID"),
			WProtoField.uint32("","Cube ID"),
		},
		[D2GS_UNSELECTOBJ] = {},
		[D2GS_NPCINIT] = {
			WProtoField.uint32("","Entity Type"),
			WProtoField.uint32("","Entity ID"),
		},
		[D2GS_NPCCANCEL] = {
			WProtoField.uint32("","Entity Type"),
			WProtoField.uint32("","NPC ID"),
		},
		[D2GS_NPCBUY] = {
			WProtoField.uint32("","NPC ID - Unconfirmed"),
			WProtoField.uint32("","Item ID - Unconfirmed"),
			WProtoField.uint32("","Buffer Type - Unconfirmed"),
			WProtoField.uint32("","Cost"),
		},
		[D2GS_NPCSELL] = {
			WProtoField.uint32("","NPC ID - Unconfirmed"),
			WProtoField.uint32("","Item ID - Unconfirmed"),
			WProtoField.uint32("","Buffer ID - Unconfirmed - Possible value 0x04"),
			WProtoField.uint32("","Cost"),
		},
		[D2GS_NPCTRADE] = {
			WProtoField.uint32("","Trade Type - Unconfirmed"),
			WProtoField.uint32("","NPC ID - Unconfirmed"),
			WProtoField.uint32("","Unknown - Unconfirmed - Possible value 0x00"),
		},
		[D2GS_CHARACTERPHRASE] = {
			WProtoField.uint16("","Phrase ID"),
		},
		[D2GS_WAYPOINT] = {
			WProtoField.uint8("","Waypoint ID"),
			WProtoField.uint8("","Unknown - Appears to be random"),
			WProtoField.uint16("","Unknown - 0x00"),
			WProtoField.uint8("","Level number"),
			WProtoField.uint16("","Unknown - 0x00"),
		},
		[D2GS_TRADE] = {
			WProtoField.uint32("","Request ID"),
			WProtoField.uint16("","Gold Amount"),
		},
		[D2GS_DROPGOLD] = {
			WProtoField.uint32("","PlayerID"),
			WProtoField.uint32("","GoldAmount"),
		},
		[D2GS_PARTY] = {
			WProtoField.uint16("","Action ID"),
			WProtoField.uint32("","Player ID"),
		},
		[D2GS_POTIONTOMERCENARY] = {
			WProtoField.uint16("","Unknown - 0x00"),
		},
		[D2GS_GAMELOGON] = {
			WProtoField.uint32("","D2GS Server Hash"),
			WProtoField.uint16("","D2GS Server Token"),
			WProtoField.uint8("","Character ID"),
			WProtoField.uint32("","Version byte (Currently 0x0B)"),
			WProtoField.uint32("","Unknown - Suggested Const (0xED5DCC50)"),
			WProtoField.uint32("","Unknown - Suggested Const (0x91A519B6)"),
			WProtoField.uint8("","Unknown - Suggested (0x00)"),
			WProtoField.stringz("","Character name"),
		},
		[D2GS_ENTERGAMEENVIRONMENT] = {
		},
		[D2GS_PING] = {
			WProtoField.uint32("","Tick Count"),
			WProtoField.uint32("","Null"),
			WProtoField.uint32("","Null"),
		},
		[PACKET_IDLE] = {},
		[PACKET_LOGON] = {
			WProtoField.stringz("","BotID"),
			WProtoField.stringz("","Bot Password"),
		},
		[PACKET_STATSUPDATE] = {
			WProtoField.stringz("","Unique username on Battle.net"),
			WProtoField.stringz("","Current channel on Battle.net"),
			WProtoField.uint32("","Battle.net server IP address"),
			WProtoField.stringz("","DatabaseID"),
			WProtoField.uint32("","Cycle status (0: Not Cycling, 1: Cycling)"),
		},
		[PACKET_DATABASE] = {
			WProtoField.uint32("","Command"),
		},
		[BNLS_AUTHORIZEPROOF] = {
			WProtoField.uint32("","Checksum."),
		},
		[BNLS_REQUESTVERSIONBYTE] = {
			WProtoField.uint32("","ProductID"),
		},
		[BNLS_REQUESTVERSIONBYTE] = {
			WProtoField.uint32("","ProductID"),
		},
		[BNLS_VERIFYSERVER] = {
			WProtoField.uint32("","Server IP"),
			WProtoField.uint8("","[128] Signature"),
		},
		[BNLS_RESERVESERVERSLOTS] = {
			WProtoField.uint32("","Number of slots to reserve"),
		},
		[BNLS_SERVERLOGONCHALLENGE] = {
			WProtoField.uint32("","Slot index."),
			WProtoField.uint32("","NLS revision number."),
			WProtoField.uint32("","[16] Data from account database."),
			WProtoField.uint32("","[8] Data client's SID_AUTH_ACCOUNTLOGON (0x53) request."),
		},
		[BNLS_SERVERLOGONPROOF] = {
			WProtoField.uint32("","Slot index."),
			WProtoField.uint32("","[5] Data from client's SID_AUTH_ACCOUNTLOGONPROOF (0x54)."),
			WProtoField.stringz("","Client's account name."),
		},
		[BNLS_VERSIONCHECKEX] = {
			WProtoField.uint32("","Product ID.*"),
			WProtoField.uint32("","Version DLL digit"),
			WProtoField.uint32("","Flags.**"),
			WProtoField.uint32("","Cookie."),
			WProtoField.stringz("","Checksum formula."),
		},
		[BNLS_VERSIONCHECKEX2] = {
			WProtoField.uint32("","Product ID.*"),
			WProtoField.uint32("","Flags.**"),
			WProtoField.uint32("","Cookie."),
			WProtoField.uint64("","Timestamp for version check archive."),
			WProtoField.stringz("","Version check archive filename."),
			WProtoField.stringz("","Checksum formula."),
		},
--]]
	}
end
