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
		WProtoField.filetime("","MPQ Filetime",base.HEX),
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
		WProtoField.filetime("","MPQ Filetime"),
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
		WProtoField.filetime("","Local file time"),
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
		WProtoField.filetime("","Filetime"),
		WProtoField.stringz("","Filename"),
	},
	[SID_GETFILETIME] = {
		WProtoField.uint32("","Request ID"),
		WProtoField.uint32("","Unknown"),
		WProtoField.filetime("","Last update time"),
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
		WProtoField.filetime("","Date joined"),
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
