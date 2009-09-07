-- Packets from client to server
CPacketDescription = {
	[SID_AUTH_INFO] = {
		WProtoField.uint32("","Protocol ID",base.DEC),
		WProtoField.stringz{label="Platform ID", reversed=true, length=4},
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
		WProtoField.ipv4{label="EXE Version"},
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
		WProtoField.stringz{label="Map name", eos=0xd},
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
		WProtoField.filetime("","System time"),
		WProtoField.filetime("","Local time"),
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
		WProtoField.posixtime("","Current time"),
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
		-- TODO: array
		WProtoField.uint32("","[0] Password Hash", base.HEX),
		WProtoField.uint32("","[1] Password Hash", base.HEX),
		WProtoField.uint32("","[2] Password Hash", base.HEX),
		WProtoField.uint32("","[3] Password Hash", base.HEX),
		WProtoField.uint32("","[4] Password Hash", base.HEX),
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
		uint32("","Client Token", base.HEX),
		version{label="EXE Version", display=base.HEX},
		uint32("","EXE Hash", base.HEX),
		uint32{label="Number of CD-keys in this packet", key="cdkeys"},
		uint32("","Spawn CD-key"),
		iterator{label="CD-Key", refkey="cdkeys", repeated={
			uint32("","CD-key length"),
			uint32("","Product ID", base.DEC, {
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
			uint32("","Public value", base.HEX),
			uint32("","Unknown (0)"),
			-- TODO: array
			uint32("","Hashed data [0]", base.HEX),
			uint32("","Hashed data [1]", base.HEX),
			uint32("","Hashed data [2]", base.HEX),
			uint32("","Hashed data [3]", base.HEX),
			uint32("","Hashed data [4]", base.HEX),
		}},
		stringz("","Exe Information"),
		stringz("","CD Key owner name"),
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
