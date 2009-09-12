CPacketDescription = {
[MCP_CHARUPGRADE] = {
	stringz{label="Character Name", },
},
[SID_CHANGEEMAIL] = {
	stringz{label="Account Name", },
	stringz{label="Old Email Address", },
	stringz{label="New Email Address", },
},
[SID_AUTH_ACCOUNTCHANGE] = {
	uint8{label="[32] Client key", },
	stringz{label="Username", },
},
[SID_REGISTRY] = {
	uint32{label="Cookie", },
	stringz{label="Key Value", },
},
[PACKET_BROADCASTMESSAGE] = {
	stringz{label="User", },
	stringz{label="Command", },
},
[D2GS_RIGHTSKILLONLOCATIONEX] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[BNLS_CONFIRMLOGON] = {
	uint32{label="Password proof from Battle.net.", num=5},
},
[D2GS_SWITCHBELTITEM] = {
	uint32{label="Item ID - Cursor buffer", },
	uint32{label="Item ID - Item to be replaced", },
},
[MCP_CHARLIST] = {
	uint32{label="Number of characters to list", },
},
[SID_GETICONDATA] = {
},
[SID_WRITEUSERDATA] = {
	uint32{label="Number of accounts", },
	uint32{label="Number of keys", },
	stringz{label="[] Accounts to update", },
	stringz{label="[] Keys to update", },
	stringz{label="[] New values", },
},
[D2GS_SWITCHBODYITEM] = {
	uint32{label="Item ID", },
	uint32{label="Body Location", },
},
[D2GS_WALKTOLOCATION] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[SID_CLANDISBAND] = {
	uint32{label="Cookie", },
},
[MCP_CHARCREATE] = {
	uint32{label="Character class", },
	uint16{label="Character flags", },
	stringz{label="Character name", },
},
[D2GS_GAMELOGON] = {
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
[BNLS_CHANGECHALLENGE] = {
	stringz{label="Account name.", },
	stringz{label="Account old password.", },
	stringz{label="Account", },
},
[D2GS_SWITCHINVENTORYITEM] = {
	uint32{label="Item ID - Item to place in inventory", },
	uint32{label="Item ID - Item to be replaced", },
	uint32{label="X coordinate for replace", },
	uint32{label="Y coordinate for replace", },
},
[SID_CLICKAD] = {
	uint32{label="Ad ID", },
	uint32{label="Request type", },
},
[D2GS_PICKUPITEM] = {
	uint32{label="Unit Type", },
	uint32{label="Unit ID", },
	uint32{label="Action ID", },
},
[D2GS_DROPGOLD] = {
	uint32{label="PlayerID", },
	uint32{label="GoldAmount", },
},
[SID_CLANREMOVEMEMBER] = {
	uint32{label="Cookie", },
	stringz{label="Username", },
},
[SID_QUERYADURL] = {
	uint32{label="Ad ID", },
},
[SID_DISPLAYAD] = {
	uint32{label="Platform ID", },
	uint32{label="Product ID", },
	uint32{label="Ad ID", },
	stringz{label="Filename", },
	stringz{label="URL", },
},
[SID_LOGONREALMEX] = {
	uint32{label="Client Token", },
	uint32{label="[5] Hashed realm password", },
	stringz{label="Realm title", },
},
[SID_ENTERCHAT] = {
	stringz{label="Username *", },
	stringz{label="Statstring **", },
},
[D2GS_RIGHTSKILLONENTITYEX2] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[SID_CLANFINDCANDIDATES] = {
	uint32{label="Cookie", },
	uint32{label="Clan Tag", },
},
[BNLS_LOGONPROOF] = {
	uint32{label="[16] Data from SID_AUTH_ACCOUNTLOGON", },
},
[MCP_CHARLOGON] = {
	stringz{label="Character name", },
},
[BNLS_VERSIONCHECKEX] = {
	uint32{label="Product ID.*", },
	uint32{label="Version DLL digit", },
	uint32{label="Flags.**", },
	uint32{label="Cookie.", },
	stringz{label="Checksum formula.", },
},
[D2GS_LEFTSKILLONENTITYEX2] = {
	uint32{label="*Entity Type", },
	uint32{label="Entity ID", },
},
[D2GS_PICKUPBUFFERITEM] = {
	uint32{label="Item ID", },
},
[SID_CLANMEMBERINFORMATION] = {
	uint32{label="Cookie", },
	uint32{label="User's clan tag", },
	stringz{label="Username", },
},
[SID_STARTADVEX2] = {
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
[SID_SYSTEMINFO] = {
	uint32{label="Number of processors", },
	uint32{label="Processor architecture", },
	uint32{label="Processor level", },
	uint32{label="Processor timing", },
	uint32{label="Total physical memory", },
	uint32{label="Total page file", },
	uint32{label="Free disk space", },
},
[SID_CLANSETMOTD] = {
	uint32{label="Cookie", },
	stringz{label="MOTD", },
},
[D2GS_NPCCANCEL] = {
	uint32{label="Entity Type", },
	uint32{label="NPC ID", },
},
[D2GS_SCROLLTOTOME] = {
	uint32{label="Item ID - Scroll", },
	uint32{label="Item ID - Tome", },
},
[SID_CDKEY] = {
	uint32{label="Spawn", },
	stringz{label="CDKey", },
	stringz{label="Key Owner", },
},
[PACKET_STATSUPDATE] = {
	stringz{label="Unique username on Battle.net", },
	stringz{label="Current channel on Battle.net", },
	uint32{label="Battle.net server IP address", },
	stringz{label="DatabaseID", },
	uint32{label="Cycle status", },
},
[MCP_MOTD] = {
},
[D2GS_PARTY] = {
	uint16{label="Action ID", },
	uint32{label="Player ID", },
},
[SID_NULL] = {
},
[MCP_GAMEINFO] = {
	uint16{label="Request ID", },
	stringz{label="Game name", },
},
[MCP_CREATEGAME] = {
	uint16{label="Request Id *", },
	uint32{label="Difficulty", },
	uint8{label="Unknown - 1", },
	uint8{label="Player difference **", },
	uint8{label="Maximum players", },
	stringz{label="Game name", },
	stringz{label="Game password", },
	stringz{label="Game description", },
},
[BNLS_CDKEY] = {
	uint32{label="Server Token", },
	stringz{label="CD key", },
},
[BNLS_REQUESTVERSIONBYTE] = {
	uint32{label="ProductID", },
},
[BNLS_REQUESTVERSIONBYTE] = {
	uint32{label="ProductID", },
},
[BNLS_AUTHORIZEPROOF] = {
	uint32{label="Checksum.", },
},
[SID_GAMERESULT] = {
	uint32{label="Game type", },
	uint32{label="Number of results - always 8", },
	uint32{label="[8] Results", },
	stringz{label="[8] Game players - always 8", },
	stringz{label="Map name", },
	stringz{label="Player score", },
},
[D2GS_RIGHTSKILLONENTITY] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[SID_FRIENDSLIST] = {
},
[D2GS_LEFTSKILLONENTITY] = {
	uint32{label="*Entity Type", },
	uint32{label="Entity ID", },
},
[SID_CLANRANKCHANGE] = {
	uint32{label="Cookie", },
	stringz{label="Username", },
	uint8{label="New rank", },
},
[SID_NOTIFYJOIN] = {
	uint32{label="Product ID *", },
	uint32{label="Product version", },
	stringz{label="Game Name", },
	stringz{label="Game Password", },
},
[PKT_CONNTEST2] = {
	uint32{label="Server Token", },
	uint32{label="UDP Token*", },
},
[SID_AUTH_ACCOUNTUPGRADE] = {
},
[SID_GAMEDATAADDRESS] = {
	sockaddr{label="Address", },
},
[BNLS_UPGRADEPROOF] = {
	uint32{label="Session key from SID_AUTH_ACCOUNTUPGRADE", },
},
[D2GS_NPCINIT] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[PACKET_ACCOUNT] = {
	uint32{label="CommandFor Command 0x00", },
	stringz{label="Account name", },
	stringz{label="Account passwordFor Command 0x01", },
	stringz{label="Account", },
	stringz{label="Old password", },
	stringz{label="New passwordFor Command 0x02", },
	stringz{label="Account name", },
	stringz{label="Account password", },
},
[D2GS_CHARACTERPHRASE] = {
	uint16{label="Phrase ID", },
},
[BNLS_CREATEACCOUNT] = {
	stringz{label="Account name.", },
	stringz{label="Account password.", },
},
[D2GS_NPCBUY] = {
	uint32{label="NPC ID - Unconfirmed", },
	uint32{label="Item ID - Unconfirmed", },
	uint32{label="Buffer Type - Unconfirmed", },
	uint32{label="Cost", },
},
[SID_CLANINVITATIONRESPONSE] = {
	uint32{label="Cookie", },
	uint32{label="Clan tag", },
	stringz{label="Inviter", },
	uint8{label="Response", },
},
[MCP_JOINGAME] = {
	uint16{label="Request ID", },
	stringz{label="Game name", },
	stringz{label="Game Password", },
},
[SID_LOGONRESPONSE2] = {
	uint32{label="Client Token", },
	uint32{label="Server Token", },
	uint32{label="[5] Password Hash", },
	stringz{label="Username", },
},
[SID_CREATEACCOUNT2] = {
	uint32{label="[5] Password hash", },
	stringz{label="Username", },
},
[SID_JOINCHANNEL] = {
	uint32{label="Flags", },
	stringz{label="Channel", },
},
[PACKET_LOGON] = {
	stringz{label="BotID", },
	stringz{label="Bot Password", },
},
[D2GS_RUNTOLOCATION] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[SID_FINDLADDERUSER] = {
	uint32{label="League", },
	uint32{label="Sort method", },
	stringz{label="Username", },
},
[PKT_CONNTEST] = {
	uint32{label="Server Token", },
},
[BNLS_RESERVESERVERSLOTS] = {
	uint32{label="Number of slots to reserve", },
},
[SID_EXTRAWORK] = {
	uint16{label="Game type", },
	uint16{label="Length", },
	stringz{label="Work returned data", },
},
[SID_CLIENTID] = {
	uint32{label="Registration Version", },
	uint32{label="Registration Authority", },
	uint32{label="Account Number", },
	uint32{label="Registration Token", },
	stringz{label="LAN Computer Name", },
	stringz{label="LAN Username", },
},
[SID_NEWS_INFO] = {
	uint32{label="News timestamp", },
},
[SID_CHECKAD] = {
	uint32{label="Platform ID", },
	uint32{label="Product ID", },
	uint32{label="ID of last displayed banner", },
	uint32{label="Current time", },
},
[BNLS_VERIFYSERVER] = {
	uint32{label="Server IP", },
	uint8{label="Signature", num=128},
},
[BNLS_SERVERLOGONPROOF] = {
	uint32{label="Slot index.", },
	uint32{label="Data from client's", num=5},
	stringz{label="Client's account name.", },
},
[SID_FRIENDSUPDATE] = {
	uint8{label="Friends list index", },
},
[SID_CLANMAKECHIEFTAIN] = {
	uint32{label="Cookie", },
	stringz{label="New Cheiftain", },
},
[D2GS_SWAP2HANDEDITEM] = {
	uint32{label="Item ID", },
	uint32{label="Body Location", },
},
[SID_CLANINVITEMULTIPLE] = {
	uint32{label="Cookie", },
	stringz{label="Clan name", },
	uint32{label="Clan tag", },
	uint8{label="Number of users to invite", },
	stringz{label="[] Usernames to invite", },
},
[BNLS_VERSIONCHECKEX2] = {
	uint32{label="Product ID.*", },
	uint32{label="Flags.**", },
	uint32{label="Cookie.", },
	uint64{label="Timestamp for version check archive.", },
	stringz{label="Version check archive filename.", },
	stringz{label="Checksum formula.", },
},
[MCP_CHARLIST2] = {
	uint32{label="Number of characters to list.", },
},
[SID_LOGONRESPONSE] = {
	uint32{label="Client Token", },
	uint32{label="Server Token", },
	uint32{label="[5] Password Hash", },
	stringz{label="Username", },
},
[PACKET_MESSAGE] = {
	stringz{label="User", },
	stringz{label="Command", },
},
[SID_STARTADVEX3] = {
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
[D2GS_UNSELECTOBJ] = {
},
[SID_PING] = {
	uint32{label="Ping Value", },
},
[SID_AUTH_ACCOUNTCHANGEPROOF] = {
	uint8{label="[20] Old password proof", },
	uint8{label="[32] New password's salt", },
	uint8{label="[32] New password's verifier", },
},
[SID_STOPADV] = {
},
[SID_AUTH_ACCOUNTCREATE] = {
	uint8{label="[32] Salt", },
	uint8{label="[32] Verifier", },
	stringz{label="Username", },
},
[D2GS_DROPITEM] = {
	uint32{label="Item ID", },
},
[D2GS_REMOVEBELTITEM] = {
	uint32{label="Item ID", },
},
[SID_AUTH_INFO] = {
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
[SID_CHECKDATAFILE2] = {
	uint32{label="File size in bytes", },
	uint32{label="File hash [5]", },
	stringz{label="Filename", },
},
[D2GS_WAYPOINT] = {
	uint8{label="Waypoint ID", },
	uint8{label="Unknown - Appears to be random", },
	uint16{label="Unknown - 0x00", },
	uint8{label="Level number", },
	uint16{label="Unknown - 0x00", },
},
[D2GS_RIGHTSKILLONLOCATION] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[BNLS_CHOOSENLSREVISION] = {
	uint32{label="NLS revision number.", },
},
[D2GS_ITEMTOBELT] = {
	uint32{label="Item ID", },
	uint32{label="Belt Location", },
},
[SID_LOCALEINFO] = {
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
[SID_CLANINVITATION] = {
	uint32{label="Cookie", },
	stringz{label="Target User", },
},
[SID_CLANMEMBERLIST] = {
	uint32{label="Cookie", },
},
[SID_STARTADVEX] = {
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
[BNLS_HASHDATA] = {
	uint32{label="Size of Data", },
	uint32{label="Flags", },
	bytes{label="Data to be hashed.", },
	uint32{label="Client Key", },
	uint32{label="Server Key", },
	uint32{label="Cookie", },
},
[PACKET_IDLE] = {
},
[MCP_GAMELIST] = {
	uint16{label="Request ID", },
	uint32{label="Unknown", },
	stringz{label="Search String *", },
},
[D2GS_LEFTSKILLONLOCATIONEX] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[SID_GETLADDERDATA] = {
	uint32{label="Product ID", },
	uint32{label="League", },
	uint32{label="Sort method", },
	uint32{label="Starting rank", },
	uint32{label="Number of ranks to list", },
},
[D2GS_ENTERGAMEENVIRONMENT] = {
},
[D2GS_OVERHEADMESSAGE] = {
	uint16{label="Unknown - 0x00, 0x00", },
	stringz{label="Message", },
	uint8{label="Unused - 0x00", },
	uint16{label="Unknown - 0x00, 0x00", },
},
[SID_CREATEACCOUNT] = {
	uint32{label="[5] Hashed password", },
	stringz{label="Username", },
},
[BNLS_LOGONCHALLENGE] = {
	stringz{label="Account name", },
	stringz{label="Password", },
},
[PACKET_BOTNETCHAT] = {
	uint32{label="Command", },
	uint32{label="Action", },
	uint32{label="For Command 2, ID of destination", },
	stringz{label="Message", },
},
[SID_GAMEPLAYERSEARCH] = {
},
[BNLS_SERVERLOGONCHALLENGE] = {
	uint32{label="Slot index.", },
	uint32{label="NLS revision number.", },
	uint32{label="Data from", num=16},
	uint32{label="Data client's SID_AUTH_ACCOUNTLOGON", num=8},
},
[MCP_CANCELGAMECREATE] = {
},
[D2GS_ITEMTOBODY] = {
	uint32{label="Item ID", },
	uint32{label="Body Location", },
},
[SID_CLANCREATIONINVITATION] = {
	uint32{label="Cookie", },
	uint32{label="Clan tag", },
	stringz{label="Inviter name", },
	uint8{label="Status", },
},
[MCP_STARTUP] = {
	uint32{label="MCP Cookie", },
	uint32{label="MCP Status", },
	uint32{label="[2] MCP Chunk 1", },
	uint32{label="[12] MCP Chunk 2", },
	stringz{label="Battle.net Unique Name", },
},
[SID_QUERYREALMS2] = {
},
[SID_AUTH_ACCOUNTLOGON] = {
	uint8{label="[32] Client Key", },
	stringz{label="Username", },
},
[BNLS_CHANGEPROOF] = {
	uint32{label="Data from SID_AUTH_ACCOUNTCHANGE", num=16},
},
[D2GS_INTERACTWITHENTITY] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[PKT_CLIENTREQ] = {
	uint32{label="Code", },
},
[SID_SETEMAIL] = {
	stringz{label="Email Address", },
},
[MCP_CHARDELETE] = {
	uint16{label="Unknown", },
	stringz{label="Character name", },
},
[SID_QUERYREALMS] = {
	uint32{label="Unused", },
	uint32{label="Unused", },
	stringz{label="Unknown", },
},
[PACKET_CHATDROPOPTIONS] = {
	uint8{label="SubcommandFor subcommand 0:", },
	uint8{label="Setting for broadcast", },
	uint8{label="Setting for database", },
	uint8{label="Setting for whispers", },
	uint8{label="Refuse all", },
},
[D2GS_USEITEM] = {
	uint32{label="Item ID", },
	uint32{label="X coordinate", },
	uint32{label="Y coordinate", },
},
[SID_CHANGEPASSWORD] = {
	uint32{label="Client Token", },
	uint32{label="Server Token", },
	uint32{label="[5] Old password hash", },
	uint32{label="[5] New password hash", },
	stringz{label="Account name", },
},
[SID_LEAVECHAT] = {
},
[SID_LEAVEGAME] = {
},
[SID_CHECKDATAFILE] = {
	uint32{label="[5] File checksum", },
	stringz{label="File name", },
},
[BNLS_CDKEY_EX] = {
	uint32{label="Cookie.", },
	uint8{label="Number of CD-keys to encrypt.", },
	uint32{label="Flags.", },
	uint32{label="Server session key", todo="verify array length"},
	uint32{label="Client session key", todo="verify array length"},
	stringz{label="CD-keys. No", todo="verify array length"},
},
[D2GS_INSERTSOCKETITEM] = {
	uint32{label="Item ID - Item to place in socket", },
	uint32{label="Item ID - Socketed item", },
},
[SID_REPORTVERSION] = {
	uint32{label="Platform ID", },
	uint32{label="Product ID", },
	uint32{label="Version Byte", },
	uint32{label="EXE Version", },
	uint32{label="EXE Hash", },
	stringz{label="EXE Information", },
},
[SID_NETGAMEPORT] = {
	uint16{label="Port", },
},
[D2GS_PING] = {
	uint32{label="Tick Count", },
	uint32{label="Null", },
	uint32{label="Null", },
},
[D2GS_ITEMTOBUFFER] = {
	uint32{label="Item ID", },
	uint32{label="X coordinate", },
	uint32{label="Y coordinate", },
	uint32{label="Buffer Type", },
},
[BNLS_NULL] = {
},
[PACKET_COMMAND] = {
	uint32{label="Target BotID", },
	stringz{label="Sending User", },
	stringz{label="Command", },
},
[SID_READUSERDATA] = {
	uint32{label="Number of Accounts", },
	uint32{label="Number of Keys", },
	uint32{label="Request ID", },
	stringz{label="[] Requested Accounts", },
	stringz{label="[] Requested Keys", },
},
[SID_CDKEY2] = {
	uint32{label="Spawn", },
	uint32{label="Key Length", },
	uint32{label="CDKey Product", },
	uint32{label="CDKey Value1", },
	uint32{label="Server Token", },
	uint32{label="Client Token", },
	uint32{label="[5] Hashed Data", },
	stringz{label="Key owner", },
},
[SID_CHATCOMMAND] = {
	stringz{label="Text", },
},
[BNLS_VERSIONCHECK] = {
	uint32{label="Product ID.", },
	uint32{label="Version DLL digit", },
	stringz{label="Checksum formula.", },
},
[D2GS_STACKITEM] = {
	uint32{label="Item ID - Stack item", },
	uint32{label="Item ID - Target item", },
},
[D2GS_WALKTOENTITY] = {
	uint32{label="*Entity Type", },
	uint32{label="Entity ID", },
},
[PACKET_USERINFO] = {
},
[D2GS_POTIONTOMERCENARY] = {
	uint16{label="Unknown - 0x00", },
},
[SID_STARTVERSIONING] = {
	uint32{label="Platform ID", },
	uint32{label="Product ID", },
	uint32{label="Version Byte", },
	uint32{label="Unknown", },
},
[D2GS_NPCSELL] = {
	uint32{label="NPC ID - Unconfirmed", },
	uint32{label="Item ID - Unconfirmed", },
	uint32{label="Buffer ID - Unconfirmed - Possible value 0x04", },
	uint32{label="Cost", },
},
[SID_GETCHANNELLIST] = {
	uint32{label="Product ID", },
},
[SID_AUTH_ACCOUNTLOGONPROOF] = {
	uint8{label="[20] Client Password Proof", },
},
[D2GS_LEFTSKILLONLOCATION] = {
	uint16{label="X coordinate", },
	uint16{label="Y coordinate", },
},
[SID_CLIENTID2] = {
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
[SID_GETFILETIME] = {
	uint32{label="Request ID", },
	uint32{label="Unknown", },
	stringz{label="Filename", },
},
[SID_GETADVLISTEX] = {
	uint16{label="Product-specific condition 1", },
	uint16{label="Product-specific condition 2", },
	uint32{label="Product-specific condition 3", },
	uint32{label="Product-specific condition 4", },
	uint32{label="List count", },
	stringz{label="Game name", },
	stringz{label="Game password", },
	stringz{label="Game stats", },
},
[PKT_KEEPALIVE] = {
	uint32{label="Tick count", },
},
[D2GS_USEBELTITEM] = {
	uint32{label="Item ID", },
	uint32{label="Unknown - Possibly unused", },
	uint32{label="Unknown - Possibly unused", },
},
[D2GS_REMOVESTACKITEM] = {
	uint32{label="Item ID", },
},
[SID_WARCRAFTGENERAL] = {
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
[D2GS_NPCTRADE] = {
	uint32{label="Trade Type - Unconfirmed", },
	uint32{label="NPC ID - Unconfirmed", },
	uint32{label="Unknown - Unconfirmed - Possible value 0x00", },
},
[BNLS_UPGRADECHALLENGE] = {
	stringz{label="Account name.", },
	stringz{label="Account old password.", },
	stringz{label="Account", },
},
[SID_CLANMOTD] = {
	uint32{label="Cookie", },
},
[D2GS_RUNTOENTITY] = {
	uint32{label="*Entity Type", },
	uint32{label="Entity ID", },
},
[PACKET_DATABASE] = {
	uint32{label="Command", },
	stringz{label="Usermask", },
	stringz{label="Flags", },
	stringz{label="Usermask", },
},
[PACKET_CYCLE] = {
	uint32{label="Count", },
	stringz{label="Usernames to cycle", todo="maybe iterator"},
},
[PACKET_CHANGEDBPASSWORD] = {
	uint32{label="Password to change", },
	stringz{label="New password", },
},
[SID_RESETPASSWORD] = {
	stringz{label="Account Name", },
	stringz{label="Email Address", },
},
[SID_UDPPINGRESPONSE] = {
	uint32{label="UDPCode", },
},
[SID_AUTH_CHECK] = {
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
[SID_PROFILE] = {
	uint32{label="Cookie", },
	stringz{label="Username", },
},
[D2GS_ITEMTOCUBE] = {
	uint32{label="Item ID", },
	uint32{label="Cube ID", },
},
[BNLS_AUTHORIZE] = {
	stringz{label="Bot ID.", },
},
[D2GS_CHATMESSAGE] = {
	uint8{label="Message Type", },
	uint8{label="Unknown", },
	stringz{label="Message", },
	uint8{label="Unknown", },
	uint16{label="Unknown - Only if normal chat", },
	stringz{label="Player to whisper to - Only if whispering", },
	uint8{label="Unknown - Only if whispering", },
},
[SID_SWITCHPRODUCT] = {
	uint32{label="Product ID", },
},
[D2GS_LEFTSKILLONENTITYEX] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[D2GS_LEFTSKILLONENTITYEX3] = {
	uint32{label="*Entity Type", },
	uint32{label="Entity ID", },
},
[D2GS_RIGHTSKILLONENTITYEX3] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[D2GS_RIGHTSKILLONENTITYEX] = {
	uint32{label="Entity Type", },
	uint32{label="Entity ID", },
},
[D2GS_PICKUPBODYITEM] = {
	uint16{label="Body Location", },
},
[SID_WARDEN] = {
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
[SID_AUTH_ACCOUNTUPGRADEPROOF] = {
	uint32{label="Client Token", },
	uint32{label="[5] Old Password Hash", },
	uint8{label="[32] New Password Salt", },
	uint8{label="[32] New Password Verifier", },
},
[SID_REPORTCRASH] = {
	uint32{label="0x10A0027", },
	uint32{label="Exception code", },
	uint32{label="Unknown", },
	uint32{label="Unknown", },
},
[D2GS_TRADE] = {
	uint32{label="Request ID", },
	uint16{label="Gold Amount", },
},
[MCP_REQUESTLADDERDATA] = {
	uint8{label="Ladder type", },
	uint16{label="Starting position", },
},
}
