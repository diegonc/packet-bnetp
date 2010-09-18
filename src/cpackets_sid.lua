-- Begin cpackets_sid.lua
-- Battle.net Messages
--[[doc
    Message ID:    0x00

    Message Name:  SID_NULL

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III,

    Format:        [blank]

    Remarks:       Keeps the connection alive. This message should be sent to the server
                   every 8 minutes (approximately).

    Related:       [0x00] SID_NULL (S->C)

]]
[SID_NULL] = { -- 0x00
},
--[[doc
    Message ID:    0x02

    Message Name:  SID_STOPADV

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        [blank]

    Remarks:       This message is sent to inform the server that a game should no longer
                   be advertised to other users. It is sent when a game starts, or when a
                   game is aborted (the host leaves).

                   All Battle.snp clients (DRTL, DSHR, STAR/SEXP, JSTR, SSHR, and W2BN)
                   always send this message when logging off, even if it not in a game.

]]
[SID_STOPADV] = { -- 0x02
},
--[[doc
    Message ID:    0x05

    Message Name:  SID_CLIENTID

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese

    Format:        (DWORD) Registration Version
                   (DWORD) Registration Authority
                   (DWORD) Account Number
                   (DWORD) Registration Token
                   (STRING) LAN Computer Name
                   (STRING) LAN Username

    Remarks:       This packet was used to ensure that the client's account number was
                   valid. All but the last two fields in this message are now ignored,
                   and may be set to zero.

                   The 'LAN Computer Name' field is the NetBIOS name of the computer. It
                   can be retrieved using the GetComputerName API.

                   The 'Lan Username' field is the name of the currently logged on user,
                   and may be retrieved using the GetUsername API.

                   The following information is historical:

                   The client would supply this data as issued by a Battle.net server. If
                   the Registration Version, Registration Authority, and Client Token
                   values equated to the account number supplied (Client ID), as
                   determined by an unknown formula, the server would respond with the
                   same values. If they were invalid, the server would assign new values.
                   Registration Version was always 1, Authority was the IP address of the
                   server that issued the account number. Thus, the Client Token was the
                   secret value, used to prove that the client really owned the account
                   in question.

    Related:       [0x05] SID_CLIENTID (S->C)

]]
[SID_CLIENTID] = { -- 0x05
	uint32("Registration Version"),
	uint32("Registration Authority"),
	uint32("Account Number"),
	uint32("Registration Token"),
	stringz("LAN Computer Name"),
	stringz("LAN Username"),
},
--[[doc
    Message ID:    0x06

    Message Name:  SID_STARTVERSIONING

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (DWORD) Platform ID
                   (DWORD) Product ID
                   (DWORD) Version Byte
                   (DWORD) Unknown (0)

    Remarks:       This message is sent to the server to start the process of checking
                   the game files. This message is part of the old logon process for
                   products before Starcraft.

    Related:       [0x06] SID_STARTVERSIONING (S->C)

]]
[SID_STARTVERSIONING] = { -- 0x06
	strdw("Platform ID", Descs.PlatformID),
	strdw("Product ID", Descs.ClientTag),
	uint32("Version Byte"),
	uint32("Unknown"),
},
--[[doc
    Message ID:    0x07

    Message Name:  SID_REPORTVERSION

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (DWORD) Platform ID
                   (DWORD) Product ID
                   (DWORD) Version Byte
                   (DWORD) EXE Version
                   (DWORD) EXE Hash
                   (STRING) EXE Information

    Remarks:       Contains CheckRevision response, version & EXE info.

    Related:       [0x07] SID_REPORTVERSION (S->C)

]]
[SID_REPORTVERSION] = { -- 0x07
	strdw("Platform ID", Descs.PlatformID),
	strdw("Product ID", Descs.ClientTag),
	uint32("Version Byte"),
	uint32("EXE Version"),
	uint32("EXE Hash"),
	stringz("EXE Information"),
},
--[[doc
    Message ID:    0x08

    Message Name:  SID_STARTADVEX

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware

    Format:        (BOOLEAN) Password protected (32-bit)
                   (DWORD) Unknown
                   (DWORD) Unknown
                   (DWORD) Unknown
                   (DWORD) Unknown
                   (DWORD) Port
                   (STRING) Game name
                   (STRING) Game password
                   (STRING) Game stats - flags, creator, statstring
                   (STRING) Map name - 0x0d terminated

    Remarks:       Creates a game in a manner similar to SID_STARTADVEX2 and
                   SID_STARTADVEX3. This is only used by Starcraft Shareware.

    Related:       [0x08] SID_STARTADVEX (S->C), [0x1A] SID_STARTADVEX2 (C->S),
                   [0x1C] SID_STARTADVEX3 (C->S)

]]
[SID_STARTADVEX] = { -- 0x08
	uint32("Password protected", nil, Descs.YesNo),
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
--[[doc
    Message ID:      0x09

    Message Name:    SID_GETADVLISTEX

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                     Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:          (WORD) Product-specific condition 1
                     (WORD) Product-specific condition 2
                     (DWORD) Product-specific condition 3
                     (DWORD) Product-specific condition 4
                     (DWORD) List count
                     (STRING) Game name
                     (STRING) Game password
                     (STRING) Game stats

    Remarks:         Retrieves a list of games.

                     Condition 1:

                     For STAR/SEXP/SSHR/JSTR and W2BN, Condition 1 is used to specify
                     a game type. A value of 0 indicates that any type is acceptable.

                     Possible game types:
                     0x00: All

                     0x02: Melee

                     0x03: Free for all

                     0x04: one vs one

                     0x05: CTF

                     0x06: Greed

                     0x07: Slaughter

                     0x08: Sudden Death

                     0x09: Ladder

                     0x10: Iron man ladder

                     0x0A: Use Map Settings

                     0x0B: Team Melee

                     0x0C: Team FFA

                     0x0D: Team CTF

                     0x0F: Top vs Bottom
                     For DRTL/DSHR, Condition 1 is used to specify a 'level range'.
                     This ensures that clients receive a list of games containing
                     players whose experience is similar to their own.

                     Possible ranges:
                     0x00: Level 1

                     0x01: 2 - 3

                     0x02: 4 - 5

                     0x03: 6 - 7

                     0x04: 8 - 9

                     0x05: 10 - 12

                     0x06: 13 - 16

                     0x07: 17 - 19

                     0x08: 20 - 24

                     0x09: 25 - 29

                     0x0A: 30 - 34

                     0x0B: 35 - 39

                     0x0C: 40 - 47

                     0x0D: 48 - 50

                     For all other games, this can be set to 0x00.

                     Condition 2:

                     Unknown. Set to 0x00.

                     Condition 3:

                     For STAR/SEXP/SSHR/JSTR, Condition 3 is set to 0x30. For
                     DRTL/DSHR, Condition 3 is set to 0xFFFF by the game, but setting
                     it to 0x00 will disable any viewing limitations, letting you
                     view all games.

                     Condition 4:

                     Unknown. Set to 0x00.

                     List count:

                     By default, DRTL/DSHR set this to 0x19. This is the number of
                     games to list. For a full listing, it's safe to use 0xFF.

    Related:         [0x09] SID_GETADVLISTEX (S->C)

]]
[SID_GETADVLISTEX] = { -- 0x09
	uint16("For STAR/SEXP/SSHR/JSTR and W2BN - game type", nil, {
		[0x00] = "All",
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
	--[[ for DRTL/DSHR - level range
	{
		[0x00] = "Level 1",
		[0x01] = "2 - 3",
		[0x02] = "4 - 5",
		[0x03] = "6 - 7",
		[0x04] = "8 - 9",
		[0x05] = "10 - 12",
		[0x06] = "13 - 16",
		[0x07] = "17 - 19",
		[0x08] = "20 - 24",
		[0x09] = "25 - 29",
		[0x0A] = "30 - 34",
		[0x0B] = "35 - 39",
		[0x0C] = "40 - 47",
		[0x0D] = "48 - 50",
	} --]]
	uint16("Product-specific condition 2 (unknown, 0)"),
	uint32("Product-specific condition 3"),
	uint32("Product-specific condition 4 (unknown, 0)"),
	uint32("List count"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game stats"),
},
--[[doc
    Message ID:    0x0A

    Message Name:  SID_ENTERCHAT

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (STRING) Username *
                   (STRING) Statstring **

    Remarks:       Joins Chat.

                   * Null on WAR3/W3XP.

                   ** Null on CDKey Products, except for D2DV and D2XP when on realm
                   characters..

    Related:       [0x0A] SID_ENTERCHAT (S->C)

]]
[SID_ENTERCHAT] = { -- 0x0A
	stringz("Username"),
	stringz("Statstring"),
},
--[[doc
    Message ID:    0x0B

    Message Name:  SID_GETCHANNELLIST

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Product ID

    Remarks:       Requests a list of channels that the client is permitted to enter.

                   In the past this packet returned a product list for the specified
                   Product ID, however, the Product ID field is now ignored -- it does
                   not need to be a valid Product ID, and can be set to zero. The list of
                   channels returned will be for the client's product, as specified
                   during the client's logon.

    Related:       [0x0B] SID_GETCHANNELLIST (S->C)

]]
[SID_GETCHANNELLIST] = { -- 0x0B
	strdw("Product ID", Descs.ClientTag),
},
--[[doc
    Message ID:    0x0C

    Message Name:  SID_JOINCHANNEL

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Flags
                   (STRING) Channel

    Remarks:       Joins a channel after entering chat.
                   The flags field may contain the following values:
                   0x00: NoCreate join
                   0x01: First join
                   0x02: Forced join
                   0x05: D2 first join

                   NoCreate Join:
                   This will only join the channel specified if it is not empty,
                   and is used by clients when selecting a channel from the
                   channels menu. If the channel is empty, Battle.net sends a
                   SID_CHATEVENT of type EID_CHANNELDOESNOTEXIST, upon which
                   official clients prompt for confirmation that the user wishes to
                   create the channel, in which case, it resends this packet with
                   Flags set to Forced Join (0x02).

                   First Join:
                   Places user in a channel starting with their product and
                   country, followed by a number, ie 'Brood War GBR-1'. Also
                   automatically sends MOTD after entering the channel. When using
                   this type, the Channel variable has no effect, but must be
                   present anyway to avoid an IP ban. This is sent when first
                   logging onto Battle.net

                   Forced Join:
                   This is sent when leaving a game, and joins the specified
                   channel without an supplying an MOTD.

                   D2 First Join:
                   The same as First join, but is used for D2DV/D2XP clients.

    Related:       [0x0F] SID_CHATEVENT (S->C)

]]
[SID_JOINCHANNEL] = { -- 0x0C
	uint32("Flags", nil, {
		[0x00] = "NoCreate join",
		[0x01] = "First join",
		[0x02] = "Forced join",
		[0x05] = "D2 first join",
	}),
	stringz("Channel"),
},
--[[doc
    Message ID:    0x0E

    Message Name:  SID_CHATCOMMAND

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (STRING) Text

    Remarks:       Send text or a command to Battle.net using this packet.

                   For STAR/SEXP/SSHR/JSTR, Text is UTF-8 encoded (WIDESTRING).

                   It is generally accepted as unwise to send any character below a space
                   (0x20): this includes line feeds, carriage returns & control
                   characters. The maximum number of characters is 223 per message.

    Related:       [0x0F] SID_CHATEVENT (S->C)

]]
[SID_CHATCOMMAND] = { -- 0x0E
	stringz("Text"),
},
--[[doc
    Message ID:    0x10

    Message Name:  SID_LEAVECHAT

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        [blank]

    Remarks:       Leaves chat mode but does not disconnect. Generally sent when entering
                   a game. This is also sent by D2DV/D2XP when switching characters, and
                   by all products when logging off.

]]
[SID_LEAVECHAT] = { -- 0x10
},
--[[doc
    Message ID:    0x12

    Message Name:  SID_LOCALEINFO

    Direction:     Client -> Server (Sent)

    Used By:       Diablo Shareware, Warcraft II, Diablo

    Format:        (FILETIME) System time
                   (FILETIME) Local time
                   (DWORD) Timezone bias
                   (DWORD) SystemDefaultLCID
                   (DWORD) UserDefaultLCID
                   (DWORD) UserDefaultLangID
                   (STRING) Abbreviated language name
                   (STRING) Country name
                   (STRING) Abbreviated country name
                   (STRING) Country (English)

    Remarks:       Informs the server of the client's locale information. Much of this
                   functionality has been incorporated into SID_AUTH_INFO, and more
                   in-depth remarks can be found there.

    Related:       [0x50] SID_AUTH_INFO (C->S)

]]
[SID_LOCALEINFO] = { -- 0x12
	wintime("System time"),
	wintime("Local time"),
	uint32("Timezone bias"),
	uint32("SystemDefaultLCID"),
	uint32("UserDefaultLCID"),
	uint32("UserDefaultLangID"),
	stringz("Abbreviated language name"),
	stringz("Country name"),
	stringz("Abbreviated country name"),
	stringz("Country (English)"),
},
--[[doc
    Message ID:    0x14

    Message Name:  SID_UDPPINGRESPONSE

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                   Starcraft, Starcraft Japanese, Diablo

    Format:        (DWORD) UDPCode

    Remarks:       Enables UDP support.

                   Server supplies code via UDP packet PKT_SERVERPING (0x05). Usually
                   'bnet'.

                   Not responding will give you a UDP Plug in chat.

    Related:       [0x05] PKT_SERVERPING (S->C)

]]
[SID_UDPPINGRESPONSE] = { -- 0x14
	--[[doc   or maybe uint32-hex? ]]
	strdw("UDPCode"),
},
--[[doc
    Message ID:    0x15

    Message Name:  SID_CHECKAD

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Platform ID
                   (DWORD) Product ID
                   (DWORD) ID of last displayed banner
                   (DWORD) Current time

    Remarks:       Requests ad banner information from battle.net.

    Related:       [0x15] SID_CHECKAD (S->C)

]]
[SID_CHECKAD] = { -- 0x15
	strdw("Platform ID", Descs.PlatformID),
	strdw("Product ID", Descs.ClientTag),
	uint32("ID of last displayed banner"),
	posixtime("Current time"),
},
--[[doc
    Message ID:    0x16

    Message Name:  SID_CLICKAD

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Ad ID
                   (DWORD) Request type

    Remarks:       The clients send this when an ad is clicked.

                   Request Type is 0 if the client used SID_QUERYADURL to get the ad's
                   data, 1 otherwise.

    Related:       [0x41] SID_QUERYADURL (C->S)

]]
[SID_CLICKAD] = { -- 0x16
	uint32("Ad ID"),
	uint32("Request type", nil, {
		[0] = "Client used SID_QUERYADURL",
		[1] = "Client did not use SID_QUERYADURL",
	}),
},

--[[doc
    Message ID:    0x17

    Message Name:  SID_READMEMORY

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo, 

    Format:        (DWORD) Request ID
                   (VOID)  Memory

    Remarks:       Rudimentary hack detection system. Was never used probably due to terrible implementation with little security. Yes, it is possible for a PvPGN server to read _EVERYTHING_ that is in the process' memory, including sensitive information such as your CDKey.

	Source: http://darkblizz.org/Forum2/starcraft/the-lost-packets/msg19580
]]
[SID_READMEMORY] = { -- 0x17
	uint32("Request ID"),
	bytes("Memory"), -- TODO: bytes till packet end
},

--[[doc
    Message ID:      0x18

    Message Name:    SID_REGISTRY

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Unknown

    Format:          (DWORD) Cookie
                     (STRING) Key Value

    Remarks:         Returns the requested registry value

    Related:         [0x18] SID_REGISTRY (S->C)

]]
[SID_REGISTRY] = { -- 0x18
	uint32("Cookie"),
	stringz("Key Value"),
},
--[[doc
    Message ID:      0x1A

    Message Name:    SID_STARTADVEX2

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Diablo Shareware, Diablo

    Format:          (DWORD) Password Protected
                     (DWORD) Unknown
                     (DWORD) Unknown
                     (DWORD) Unknown
                     (DWORD) Unknown
                     (DWORD) Port
                     (STRING) Game name
                     (STRING) Game password
                     (STRING) Unknown
                     (STRING) Game stats - Flags, Creator, Statstring

    Remarks:         This message is used by Diablo to create a game.

    Related:         [0x08] SID_STARTADVEX (C->S), [0x1C] SID_STARTADVEX3 (C->S)

]]
[SID_STARTADVEX2] = { -- 0x1A
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
--[[doc
    Message ID:      0x1B

    Message Name:    SID_GAMEDATAADDRESS

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Diablo

    Format:          (SOCKADDR) Address

    Remarks:         Specifies host & port that a game creator is using for a game.

]]
[SID_GAMEDATAADDRESS] = { -- 0x1B
	sockaddr("Address"),
},
--[[doc
    Message ID:      0x1C

    Message Name:    SID_STARTADVEX3

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                     Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                     Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:          (DWORD) State
                     (DWORD) Time since creation
                     (WORD) Game Type
                     (WORD) Parameter
                     (DWORD) Unknown (1F)
                     (DWORD) Ladder
                     (STRING) Game name
                     (STRING) Game password
                     (STRING) Game Statstring

    Remarks:         Used by clients to inform the server that a game has been created, or
                     that the state of a created game has changed.

                     Bitwise flags for State:
                     0x01: Game is private

                     0x02: Game is full

                     0x04: Game contains players (other than creator)

                     0x08: Game is in progress

                     Possible values for Game Type:
                     0x02: Melee

                     0x03: Free for All

                     0x04: 1 vs 1

                     0x09: Ladder

                     0x0A: Use Map Settings

                     0x0F: Top vs Bottom

                     0x10: Iron Man Ladder (W2BN only)

                     Possible values for Ladder:
                     0x00: Game is NonLadder

                     0x01: Game is Ladder

                     0x03: Game is Iron Man Ladder (W2BN only)

                     It could be that the ladder is bitwise as well, and that 0x02 means
                     Iron Man and 0x03 just means Iron Man + Ladder.

                     Parameter appears to be 1 for all games except Top vs Bottom, where it
                     seems to depend on the size of each team. More research will be needed
                     to confirm.

    Related:         [0x08] SID_STARTADVEX (C->S), [0x1A] SID_STARTADVEX2 (C->S),
                     [0x1C] SID_STARTADVEX3 (S->C), Game Statstrings

]]
[SID_STARTADVEX3] = { -- 0x1C
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
--[[doc
    Message ID:    0x1E

    Message Name:  SID_CLIENTID2

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft II, Starcraft Japanese, Diablo

    Format:        (DWORD) Server Version

                   For server version 1:
                   (DWORD) Registration Version

                   (DWORD) Registration Authority

                   For server version 0:
                   (DWORD) Registration Authority

                   (DWORD) Registration Version

                   (DWORD) Account Number
                   (DWORD) Registration Token
                   (STRING) LAN computer name
                   (STRING) LAN username

    Remarks:       See related link for more information.

    Related:       [0x05] SID_CLIENTID (C->S)

]]
[SID_CLIENTID2] = { -- 0x1E
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
--[[doc
    Message ID:    0x1F

    Message Name:  SID_LEAVEGAME

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        [blank]

    Remarks:       Notifies Battle.net that you have left a game.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[SID_LEAVEGAME] = { -- 0x1F
},
--[[doc
    Message ID:    0x21

    Message Name:  SID_DISPLAYAD

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (DWORD) Platform ID
                   (DWORD) Product ID
                   (DWORD) Ad ID
                   (STRING) Filename
                   (STRING) URL

    Remarks:       Sent when an ad is displayed. Perhaps for statistics?

                   Null strings are now sent in place of Filename and URL, since the need
                   to truncate long strings to 128 characters was causing inaccuracies.

]]
[SID_DISPLAYAD] = { -- 0x21
	strdw("Platform ID", Descs.PlatformID),
	strdw("Product ID", Descs.ClientTag),
	uint32("Ad ID"),
	stringz("Filename"),
	stringz("URL"),
},
--[[doc
    Message ID:    0x22

    Message Name:  SID_NOTIFYJOIN

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) Product ID *
                   (DWORD) Product version
                   (STRING) Game Name
                   (STRING) Game Password

    Remarks:       Notifies Battle.net that the client has joined a game. This is what
                   causes you to receive "Your friend _ entered a _ game called _." from
                   Battle.net if you are mutual friends with this client.

                   SID_LEAVECHAT (0x10) does not need to be sent after this, since this
                   does what LEAVECHAT does but with an added notification.

                   * This can be any valid Product ID, even if you are not connected with
                   that ID.

]]
[SID_NOTIFYJOIN] = { -- 0x22
	strdw("Product ID", Descs.ClientTag),
	uint32("Product version"),
	stringz("Game Name"),
	stringz("Game Password"),
},

--[[doc
    Message ID:    0x24

    Message Name:  SID_READCOOKIE

    Direction:     Server -> Client (Received)

    Format:        (DWORD) First DWORD from S -> C
                   (DWORD) Second DWORD from S -> C
                   (STRING) Registry key name
                   (STRING) Registry key value
	
    Purpose:       Much like a website cookie, simply stores some arbitrary string to a 'cookie jar' to save preferences et al. which can be retrieved later by the server. Not used because it was quickly discovered that storing preferences produces less problems and were faster by storing them server-side, associating them with the account. It is somewhat curious that these packet IDs are close to SID_PROFILE/SID_WRITEPROFILE (0x26 & 0x27).
]]
[SID_READCOOKIE] = { -- 0x24
	uint32("First DWORD from S -> C"),
	uint32("Second DWORD from S -> C"),
	stringz("Registry key name"),
	stringz("Registry key value"),
},

--[[doc
    Message ID:    0x25

    Message Name:  SID_PING

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Ping Value

    Remarks:       Ping response. Ping Value is the DWORD received in the server's
                   initial ping message.

    Related:       [0x25] SID_PING (S->C)

]]
[SID_PING] = { -- 0x25
	uint32("Ping Value", base.HEX),
},
--[[doc
    Message ID:      0x26

    Message Name:    SID_READUSERDATA

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                     Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                     Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:          (DWORD) Number of Accounts
                     (DWORD) Number of Keys
                     (DWORD) Request ID
                     (STRING)[] Requested Accounts
                     (STRING)[] Requested Keys

    Remarks:         Requests an extended profile.

                     Profile Keys: *

                     User Profiles:
                     profile\sex **

                     profile\age â€

                     profile\location

                     profile\description

                     Account Info:
                     System\Account Created

                     System\Last Logon

                     System\Last Logoff

                     System\Time Logged

                     Normal Games:
                     record\GAME\0\wins

                     record\GAME\0\losses

                     record\GAME\0\disconnects

                     record\GAME\0\last GAME

                     record\GAME\0\last GAME result

                     Ladder Games:
                     record\GAME\1\wins

                     record\GAME\1\losses

                     record\GAME\1\disconnects

                     record\GAME\1\last game

                     record\GAME\1\last game result

                     record\GAME\1\rating

                     record\GAME\1\high rating

                     DynKey\GAME\1\rank

                     IronMan Ladder Games: â€¡
                     record\GAME\3\wins

                     record\GAME\3\losses

                     record\GAME\3\disconnects

                     record\GAME\3\last game

                     record\GAME\3\last game result

                     record\GAME\3\rating

                     record\GAME\3\high rating

                     DynKey\GAME\3\rank

                     * This list is not complete, and could use adding to.

                     ** This field is defunct in STAR/SEXP/WAR3/W3XP.

                     â€  This field is defunct.

                     â€¡ W2BN only.

    Related:         [0x26] SID_READUSERDATA (S->C)

]]
[SID_READUSERDATA] = { -- 0x26
	uint32{"Number of Accounts", key="numaccts"},
	uint32{"Number of Keys", key="numkeys"},
	uint32("Request ID"),
	iterator{alias="none", label="Requested Account", refkey="numaccts", repeated={
		stringz("Account"),
	}},
	iterator{alias="none", label="Keys", refkey="numkeys", repeated={
		stringz("Key"),
	}}, 
},
--[[doc
    Message ID:    0x27

    Message Name:  SID_WRITEUSERDATA

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Number of accounts
                   (DWORD) Number of keys
                   (STRING) [] Accounts to update
                   (STRING) [] Keys to update
                   (STRING) [] New values

    Remarks:       Updates the Client's profile.
                   Currently, the allowed keys for this are Sex, Location, and
                   Description. The maximum length for the values is 512, including the
                   null terminator.

                   See SID_READUSERDATA for more information.

    Related:       [0x26] SID_READUSERDATA (C->S)

]]
[SID_WRITEUSERDATA] = { -- 0x27
	uint32{label="Number of accounts", key="numaccts"},	-- TODO: it works?
	uint32{label="Number of keys", key="numkeys"},
	iterator{label="Accounts to update", refkey="numaccts", repeated={
		stringz("Account" --[[,{[""] = "Own account",}]]),
	}},
	iterator{label="Keys to update", refkey="numkeys", repeated={
		stringz("Key"),
	}},
	iterator{label="New values", refkey="numkeys", repeated={
		stringz("New value"),
	}},
},
--[[doc
    Message ID:    0x29

    Message Name:  SID_LOGONRESPONSE

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (DWORD) Client Token
                   (DWORD) Server Token
                   (DWORD) [5] Password Hash
                   (STRING) Username

    Remarks:       Contains Client's username & hashed password.

                   Battle.net password hashes are hashed twice. First, the password is
                   hashed by itsself, then the following data is hashed again and sent to
                   Battle.net:

                   Client Token
                   Server Token
                   First password hash (20 bytes)

                   Passwords should be converted to lower case before hashing.

    Related:       [0x29] SID_LOGONRESPONSE (S->C)

]]
[SID_LOGONRESPONSE] = { -- 0x29
	uint32("Client Token"),
	uint32("Server Token"),
	array("Password Hash", uint32, 5),
	stringz("Username"),
},
--[[doc
    Message ID:    0x2A

    Message Name:  SID_CREATEACCOUNT

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) [5] Hashed password
                   (STRING) Username

    Remarks:       Creates an account.

                   Usernames longer than 15 characters are truncated, and the password is
                   only hashed once (unlike SID_LOGONRESPONSE).

                   This packet is identical to SID_CREATEACCOUNT2, but the response is
                   limited to success/fail. Developers who wish to provide a reason for
                   account creation failure should use SID_CREATEACCOUNT2.

                   Currently, SID_CREATEACCOUNT2 may be used with any product, but the
                   protocol-correct packet to use depends on the product you are
                   emulating.

    Related:       [0x2A] SID_CREATEACCOUNT (S->C), [0x29] SID_LOGONRESPONSE (C->S),
                   [0x3D] SID_CREATEACCOUNT2 (C->S)

]]
[SID_CREATEACCOUNT] = { -- 0x2A
	array("Hashed password", uint32, 5),
	stringz("Username"),
},
--[[doc
    Message ID:    0x2B

    Message Name:  SID_SYSTEMINFO

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Starcraft,
                   Starcraft Japanese, Diablo

    Format:        (DWORD) Number of processors
                   (DWORD) Processor architecture
                   (DWORD) Processor level
                   (DWORD) Processor timing
                   (DWORD) Total physical memory
                   (DWORD) Total page file
                   (DWORD) Free disk space

    Remarks:       Contains system information. This packet was sent during the
                   connection process for STAR/SEXP/DRTL/DSHR clients prior to version
                   1.07. It is now only used by JSTR and SSHR. For information on how to
                   emulate this system, please see this topic.

]]
[SID_SYSTEMINFO] = { -- 0x2B
	uint32("Number of processors"),
	uint32("Processor architecture"),
	uint32("Processor level"),
	uint32("Processor timing"),
	uint32("Total physical memory"),
	uint32("Total page file"),
	uint32("Free disk space"),
},
--[[doc
    Message ID:    0x2C

    Message Name:  SID_GAMERESULT

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft,
                   Starcraft Japanese

    Format:        (DWORD) Game type
                   (DWORD) Number of results - always 8
                   (DWORD) [8] Results
                   (STRING) [8] Game players - always 8
                   (STRING) Map name
                   (STRING) Player score

    Remarks:       Contains end-of-game statistics. Player Score is a string containing
                   right-aligned lines separated by 0x0A. The positions in the 'Results'
                   array and the 'Players' array are equivalent.

                   Possible values for Game type:
                   0x00: Normal

                   0x01: Ladder

                   0x03: Ironman (W2BN only)

                   Possible values for Result:
                   0x00: No player

                   0x01: Win

                   0x02: Loss

                   0x03: Draw

                   0x04: Disconnect

]]
[SID_GAMERESULT] = { -- 0x2C
	uint32("Game type", nil, {
		[0x00] = "Normal",
		[0x01] = "Ladder",
		[0x03] = "Ironman (W2BN only)",
	}),
	uint32{label="Number of results (always 8)", key="numresults"},
	iterator{label="Game results", refkey="numresults", repeated={
		uint32("Result", nil, {
			[0x01] = "Win",
			[0x02] = "Loss",
			[0x03] = "Draw",
			[0x04] = "Disconnect",
		}),
	}},
	iterator{label="Players", refkey="numresults", repeated={
		stringz("Player"),	
	}},
	stringz("Map name"),
	stringz("Player score"),
},
--[[doc
    Message ID:    0x2D

    Message Name:  SID_GETICONDATA

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                   Warcraft III: The Frozen Throne, Starcraft, Starcraft Japanese, Diablo,
                   Warcraft III

    Format:        [blank]

    Remarks:       Requests the filename & time of the default icons file for the current
                   game. This message must not be sent after recieving SID_ENTERCHAT or
                   Battle.net will terminate the connection.

    Related:       [0x2D] SID_GETICONDATA (S->C)

]]
[SID_GETICONDATA] = { -- 0x2D
},
--[[doc
    Message ID:    0x2E

    Message Name:  SID_GETLADDERDATA

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft II, Starcraft

    Format:        (DWORD) Product ID
                   (DWORD) League
                   (DWORD) Sort method
                   (DWORD) Starting rank
                   (DWORD) Number of ranks to list

    Remarks:       Requests ladder listing.

                   Sort methods:
                   0x00: Highest rating

                   0x01: Fastest climbers

                   0x02: Most wins on record

                   0x03: Most games played

    Related:       [0x2E] SID_GETLADDERDATA (S->C)

]]
[SID_GETLADDERDATA] = { -- 0x2E
	strdw("Product ID", Descs.ClientTag),
	uint32("League"),
	uint32("Sort method", nil, {
		[0x00] = "Highest rating",
		[0x01] = "Fastest climbers",
		[0x02] = "Most wins on record",
		[0x03] = "Most games played",
	}),
	uint32("Starting rank"),
	uint32("Number of ranks to list"),
},
--[[doc
    Message ID:    0x2F

    Message Name:  SID_FINDLADDERUSER

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft II, Starcraft

    Format:        (DWORD) League
                   (DWORD) Sort method
                   (STRING) Username

    Remarks:       Requests a user's status on ladder.

                   Sort method:
                   0x00: Highest rating

                   0x01: Unused

                   0x02: Most wins on record

                   0x03: Most games played

    Related:       [0x2F] SID_FINDLADDERUSER (S->C)

]]
[SID_FINDLADDERUSER] = { -- 0x2F
	uint32("League"),
	uint32("Sort method", nil, {
		[0x00] = "Highest rating",
		[0x01] = "Unused",
		[0x02] = "Most wins on record",
		[0x03] = "Most games played",
	}),
	stringz("Username"),
},
--[[doc
    Message ID:    0x30

    Message Name:  SID_CDKEY

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Japanese

    Format:        (DWORD) Spawn (0/1)
                   (STRING) CDKey
                   (STRING) Key Owner

    Remarks:       Contains unhashed CD key information.

    Related:       [0x30] SID_CDKEY (S->C)

]]
[SID_CDKEY] = { -- 0x30
	uint32("Spawn"),
	stringz("CDKey"),
	stringz("Key Owner"),
},
--[[doc
    Message ID:    0x31

    Message Name:  SID_CHANGEPASSWORD

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) Client Token
                   (DWORD) Server Token
                   (DWORD) [5] Old password hash
                   (DWORD) [5] New password hash
                   (STRING) Account name

    Remarks:       Changes Battle.net account password. This message must be sent before
                   sending SID_ENTERCHAT.

                   Passwords should be converted to lower case before hashing.

    Related:       [0x31] SID_CHANGEPASSWORD (S->C), [0x0A] SID_ENTERCHAT (C->S)

]]
[SID_CHANGEPASSWORD] = { -- 0x31
	uint32("Client Token"),
	uint32("Server Token"),
	array("Old hashed password", uint32, 5),
	array("New password hash", uint32, 5),
	stringz("Account name"),
},
--[[doc
    Message ID:      0x32

    Message Name:    SID_CHECKDATAFILE

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft,
                     Starcraft Japanese

    Format:          (DWORD) [5] File checksum
                     (STRING) File name

    Remarks:         This message was used to check a digest of a game file. This message
                     is no longer used; developers should use the SID_CHECKDATAFILE2
                     message.

                     The digest is created by using the broken SHA-1 hash on the first
                     64-bytes of the (filesize % 64) times. This due to a bug in the
                     client.

    Related:         [0x3C] SID_CHECKDATAFILE2 (C->S), [0x32] SID_CHECKDATAFILE (S->C)

]]
[SID_CHECKDATAFILE] = { -- 0x32
	array("File checksum", uint32, 5),
	stringz("File name"),
},
--[[doc
    Message ID:    0x33

    Message Name:  SID_GETFILETIME

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Request ID
                   (DWORD) Unknown
                   (STRING) Filename

    Remarks:       This packet seems to request the current filetime for the specified
                   file. Purpose of first 2 DWORDs is unknown, however, both are echoed
                   back to the client by Battle.net and do not seem to affect the reply.
                   Because of this it is reasonable to assume that first DWORD at least
                   is a request ID of some kind. This is called into question, however,
                   by the fact that the replying packet also contains the requested
                   filename. The game (STAR/SEXP) always sends the same number in DWORD 1
                   for the file in question. DWORD 2 seems to be null.

                   Known codes for DWORD 1:
                   0x01: tos_usa.txt
                   0x03: bnserver-WAR3.ini
                   0x1A: tos_USA.txt
                   0x1B: bnserver.ini
                   0x1D: icons_STAR.bni
                   0x80000005: IX86ExtraWork.mpq
                   0x80000004: bnserver-D2DV.ini

    Related:       [0x33] SID_GETFILETIME (S->C)

]]
[SID_GETFILETIME] = { -- 0x33
	uint32("Request ID"),
	uint32("Unknown"),
	stringz("Filename"),
},
--[[doc
    Message ID:      0x34

    Message Name:    SID_QUERYREALMS

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Unused (0)
                     (DWORD) Unused (0)
                     (STRING) Unknown (empty)

    Remarks:         Requests a realm listing.

                     This packet is no longer used. SID_QUERYREALMS2 is used instead.

    Related:         [0x34] SID_QUERYREALMS (S->C), [0x40] SID_QUERYREALMS2 (C->S)

]]
[SID_QUERYREALMS] = { -- 0x34
	uint32("Unused"),
	uint32("Unused"),
	stringz("Unknown"),
},
--[[doc
    Message ID:    0x35

    Message Name:  SID_PROFILE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) Username

    Remarks:       This requests a profile for a user.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x35] SID_PROFILE (S->C)

]]
[SID_PROFILE] = { -- 0x35
	uint32("Cookie"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x36

    Message Name:  SID_CDKEY2

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft II

    Format:        (DWORD) Spawn (0/1)
                   (DWORD) Key Length
                   (DWORD) CDKey Product
                   (DWORD) CDKey Value1
                   (DWORD) Server Token
                   (DWORD) Client Token
                   (DWORD) [5] Hashed Data
                   (STRING) Key owner

    Remarks:       This packet is an updated version of SID_CDKEY (0x30), designed to
                   prevent CDKeys from being stolen, by sending them hashed instead of
                   plain-text.

                   The data that should be hashed is:

                   1. Client Token

                   2. Server Token

                   3. Key Product (from decoded CD key)

                   4. Key Value1 (from decoded CD key)

                   5. Key Value2 (from decoded CD key)

    Related:       [0x36] SID_CDKEY2 (S->C), [0x30] SID_CDKEY (C->S)

]]
[SID_CDKEY2] = { -- 0x36
	uint32("Spawn"),
	uint32("Key Length"),
	uint32("CDKey Product"),
	uint32("CDKey Value1"),
	uint32("Server Token"),
	uint32("Client Token"),
	array("Hashed Data", uint32, 5),
	stringz("Key owner"),
},
--[[doc
    Message ID:    0x3A

    Message Name:  SID_LOGONRESPONSE2

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Client Token
                   (DWORD) Server Token
                   (DWORD) [5] Password Hash
                   (STRING) Username

    Remarks:       This packet is the same as SID_LOGONRESPONSE, but has additional
                   response codes.

    Related:       [0x3A] SID_LOGONRESPONSE2 (S->C), [0x29] SID_LOGONRESPONSE (C->S)

]]
[SID_LOGONRESPONSE2] = { -- 0x3A
	uint32("Client Token", base.HEX),
	uint32("Server Token", base.HEX),
	array("Password Hash", uint32, 5),
	stringz("Username"),
},
--[[doc
    Message ID:    0x3C

    Message Name:  SID_CHECKDATAFILE2

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft,
                   Starcraft Japanese

    Format:        (DWORD) File size in bytes
                   (DWORD) File hash [5]
                   (STRING) Filename

    Remarks:       Verifies that a file is authentic, by producing a hash of that file
                   and sending it to the server for comparison to the original.

                   The hash is produced by hashing 64-byte chunks of the file. Each time
                   after the first, the result of the previous hash is used to initialize
                   & complete the current hash. The final chunk, which may be less than
                   64 bytes in length, is included in the operation.

    Related:       [0x3C] SID_CHECKDATAFILE2 (S->C)

]]
[SID_CHECKDATAFILE2] = { -- 0x3C
	uint32("File size in bytes"),
	array("File hash", uint32, 5),
	stringz("Filename"),
},
--[[doc
    Message ID:    0x3D

    Message Name:  SID_CREATEACCOUNT2

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) [5] Password hash
                   (STRING) Username

    Remarks:       Creates a Battle.net account. Usernames longer than 15 characters are
                   truncated.

                   Passwords should be converted to lower case before hashing, and are
                   only hashed once (unlike SID_LOGONRESPONSE).

    Related:       [0x3D] SID_CREATEACCOUNT2 (S->C), [0x29] SID_LOGONRESPONSE (C->S)

]]
[SID_CREATEACCOUNT2] = { -- 0x3D
	array("Password hash", uint32, 5),
	stringz("Username"),
},
--[[doc
    Message ID:    0x3E

    Message Name:  SID_LOGONREALMEX

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Client Token
                   (DWORD) [5] Hashed realm password
                   (STRING) Realm title

    Remarks:       Realm password is always "password". The password hash is created the
                   same way the hash is for logging on to an account.

    Related:       [0x3E] SID_LOGONREALMEX (S->C)

]]
[SID_LOGONREALMEX] = { -- 0x3E
	uint32("Client Token"),
	array("Hashed realm password", uint32, 5),
	stringz("Realm title"),
},
--[[doc
    Message ID:    0x40

    Message Name:  SID_QUERYREALMS2

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        [blank]

    Remarks:       Requests a realm listing.

    Related:       [0x40] SID_QUERYREALMS2 (S->C), [0x34] SID_QUERYREALMS (C->S)

]]
[SID_QUERYREALMS2] = { -- 0x40
},
--[[doc
    Message ID:    0x41

    Message Name:  SID_QUERYADURL

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Ad ID

    Remarks:       Requests the URL for an ad if none is given.

    Related:       [0x41] SID_QUERYADURL (S->C)

]]
[SID_QUERYADURL] = { -- 0x41
	uint32("Ad ID"),
},
--[[doc
    Message ID:      0x44

    Message Name:    SID_WARCRAFTGENERAL

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (BYTE) Subcommand ID

                     For subcommand 0x02 (Request ladder map listing):
                     (DWORD) Cookie

                     (BYTE) Number of types requested

                     (DWORD)[] Request data *

                     For subcommand 0x03 (Cancel ladder game search):
                     [blank]

                     For subcommand 0x04 (User stats request):
                     (DWORD) Cookie

                     (STRING) Account name

                     (DWORD) Product ID

                     For subcommand 0x08 (Clan stats request):
                     (DWORD) Cookie

                     (DWORD) Clan Tag

                     (DWORD) Product ID ('WAR3' or 'W3XP')

                     For subcommand 0x09 (Icon list request):
                     (DWORD) Cookie

                     For subcommand 0x0A (Change icon):
                     (DWORD) Icon

    Remarks:         This packet is used for multiple purposes on Warcraft III. Known and
                     validated purposes are listed here.

                     *Not fully known yet.

    Related:         [0x44] SID_WARCRAFTGENERAL (S->C)
]]
--[[doc
		SID_WARCRAFTGENERAL

WID_GAMESEARCH 0x00 SEND
	(DWORD)	Cookie
	(DWORD)	Unknown
	(BYTE) 	Unknown
	(BYTE)	Type
		0x00: 1vs1
		0x01: 2vs2
		0x02: 3vs3
		0x03: 4vs4
		0x04: Free for All
	(WORD) Enabled Maps (every bit is one map, from 0x0000 to 0x0FFF)
	(WORD) Unknown
	(BYTE) Unknown
	(DWORD) TickCount
	(DWORD) Race
		0x00000001: Human
		0x00000002: Orc
		0x00000004: Night Elf
		0x00000008: Undead
		0x00000020: Random

WID_GAMESEARCH 0x00 RECV
	(DWORD) Cookie
	(BYTE) Status
		0x00: Search Started
		0x04: Banned CD Key

WID_MAPLIST 0x02 SEND
	(DWORD) Cookie
	(BYTE) Requests
	(DWORD) ID
	(DWORD) Checksum

WID_MAPLIST 0x02 RECV
	(DWORD) Cookie
	(Byte) Responses
	(DWORD) ID
	(DWORD) Checksum
	(WORD) Decompressed Len
	(WORD) Compressed Len
	(VOID) Compressed Data
	(BYTE) Remaining Packets

WID_CANCELSEARCH 0x03 SEND
	-Empty

WID_CANCELSEARCH 0x03 RECV
	(DWORD) Cookie from WID_GAMESEARCH

WID_USERRECORD 0x04 SEND
	(DWORD) Cookie
	(STRING) Account
	(DWORD) Product

WID_USERRECORD 0x04 RECV
	(DWORD) Cookie
	(DWORD) Icon ID
	(BYTE) Ladder Records
	(DWORD) Ladder Type
	(WORD) Wins
	(WORD) Losses
	(BYTE) Level
	(BYTE) Unknown
	(WORD) Experience
	(DWORD) Rank
	(BYTE) Race Records
	(WORD) Wins
	(WORD) Losses
	(BYTE) Team Records
	(DWORD) Ladder Type
	(WORD) Wins
	(WORD) Losses
	(BYTE) Level
	(BYTE) Unknown
	(WORD) Experience
	(DWORD) Rank
	(FILETIME) Last Game
	(BYTE) Partners
	(STRING) Partner Account

WID_TOURNAMENT 0x07 SEND
	(DWORD) Cookie

WID_TOURNAMENT 0x07 RECV
	(DWORD) Cookie
	(BYTE) Status
		0x00 No Tournament
		0x01 Starting Soon
		0x02 Ending Soon
		0x03 Started
		0x04 Last Call
	(FILETIME) Time of Status
	(WORD) Unknown
	(WORD) Unknown
	(BYTE) Wins
	(BYTE) Losses
	(BYTE) Draws
	(BYTE) Unknown
	(BYTE) Unknown
	(BYTE) Unknown
	(BYTE) Unknown

WID_CLANRECORD 0x08 SEND
	(DWORD) Cookie
	(DWORD) Clan Tag
	(DWORD) Product

WID_CLANRECORD 0x08 RECV
	(DWORD) Cookie
	(BYTE) Ladder Records
	(DWORD) Ladder Type
	(WORD) Wins
	(WORD) Losses
	(BYTE) Level
	(BYTE) Unknown
	(WORD) Experience
	(DWORD) Rank
	(BYTE) Race Records
	(WORD) Wins
	(WORD) Losses

WID_ICONLIST 0x09 SEND
	(DWORD) Cookie

WID_ICONLIST 0x09 RECV
	(DWORD) Cookie
	(DWORD) Unknown
	(BYTE) Tiers
	(BYTE) Icons
	(DWORD) Icon
	(DWORD) Name
	(BYTE) Race
	(WORD) Required Wins
	(BYTE) Unknown

WID_SETICON 0x0A SEND
	(DWORD) Icon 

]]
[SID_WARCRAFTGENERAL] = { -- 0x44
	uint8{"Subcommand ID", key="subcommand", nil, Descs.WarcraftGeneralSubcommandId},
	--[[doc
		WID_GAMESEARCH 0x00 SEND
		(DWORD)	Cookie
		(DWORD)	Unknown
		(BYTE) 	Unknown
		(BYTE)	Type
			0x00: 1vs1
			0x01: 2vs2
			0x02: 3vs3
			0x03: 4vs4
			0x04: Free for All
		(WORD) Enabled Maps (every bit is one map, from 0x0000 to 0x0FFF)
		(WORD) Unknown
		(BYTE) Unknown
		(DWORD) TickCount
		(DWORD) Race
			0x00000001: Human
			0x00000002: Orc
			0x00000004: Night Elf
			0x00000008: Undead
			0x00000020: Random
	]]
	-- Subcommand ID 0: Game search?
	when{Cond.equals("subcommand", 0), {
		uint32("Cookie"),
		uint32("Unknown"),
		uint8("Unknown"),
		uint8("Type", nil, {
			[0x00] = "1vs1",
			[0x01] = "2vs2",
			[0x02] = "3vs3",
			[0x03] = "4vs4",
			[0x04] = "Free for All",
		}),
		uint16("Enabled Maps (every bit is one map, from 0x0000 to 0x0FFF)"),
		uint16("Unknown"),
		uint8("Unknown"),
		uint32("TickCount"),
		flags{label="Race", of=uint32, fields={
			{sname="Human",     mask=0x01, desc=Descs.YesNo},
			{sname="Orc",       mask=0x02, desc=Descs.YesNo},
			{sname="Night Elf", mask=0x04, desc=Descs.YesNo},
			{sname="Undead",    mask=0x08, desc=Descs.YesNo},
			{sname="Random",    mask=0x20, desc=Descs.YesNo},
		}},
	}},
	
	-- Subcommand ID 2: Request ladder map listing
	when{Cond.equals("subcommand", 2), { 
		uint32("Cookie"),
		uint8{label="Number of types requested",key="num"},
		iterator{label="Game Information", refkey="num", repeated={
			strdw("Request data", Descs.WarcraftGeneralRequestType),
			-- seems to be dword(0)
			-- seems this is another war3 datatype, double strdw :)
			uint32("Dword(0)"),
		}},
	}},
	
	-- Subcommand ID 3: WID_CANCELSEARCH
	when{Cond.equals("subcommand", 3),
		{  },
	},
	
	-- Subcommand ID 4: User stats request
	when{Cond.equals("subcommand", 4), {  
		uint32("Cookie"),
		stringz("Username"),
		strdw("Product ID", Descs.ClientTag),
	}},
	
	-- Subcommand ID 7: WID_TOURNAMENT
	when{Cond.equals("subcommand", 7), {  
		uint32("Cookie"),
	}},
	
	-- Subcommand ID 8: Clan stats request
	when{Cond.equals("subcommand", 8), { 
		uint32("Cookie"),
		stringz("Account name"),
		-- TODO: "' in strings?
		strdw("Product ID (WAR3 or W3XP)", Descs.ClientTag), 
	}}, 
	
	-- Subcommand ID 9: Icon list request
	when{Cond.equals("subcommand", 9), { 			
		uint32("Cookie"),
	}},
	
	-- Subcommand ID 10: Change icon
	when{Cond.equals("subcommand", 0x0A), { 			
		strdw("Icon", Descs.W3Icon),
	}},
},
--[[doc
    Message ID:    0x45

    Message Name:  SID_NETGAMEPORT

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (WORD) Port

    Remarks:       Sets the port used by the client for hosting WAR3/W3XP games. This
                   value is retreived from HKCU\Software\Blizzard Entertainment\Warcraft
                   III\Gameplay\netgameport, and is sent after the user logs on.

]]
[SID_NETGAMEPORT] = { -- 0x45
	uint16("Port"),
},
--[[doc
    Message ID:    0x46

    Message Name:  SID_NEWS_INFO

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Warcraft III: The Frozen Throne, Diablo, Warcraft III

    Format:        (DWORD) News timestamp

    Remarks:       Requests news and MOTD from battle.net.

                   The news timestamp specifies the starting date for the news. To
                   retrieve all available news entries, set this to zero. Timestamps are
                   given in C/Unix format -- that is, the number of seconds since January
                   1, 1970 0:00:00.000 -- and should be biased to UTC.

                   This message should be sent when you receive SID_ENTERCHAT. The
                   official client stops processing messages after the user joins a game
                   or enters a channel, and discards messages with more than 127 entries.

                   News can be requested for older products, but Battle.net will only
                   return the server's Message-of-the-Day. However, this behavior has not
                   been observed in official clients, and for an accurate protocol
                   emulation, its use is not recommended.

    Related:       [0x46] SID_NEWS_INFO (S->C), [0x0A] SID_ENTERCHAT (S->C)

]]
[SID_NEWS_INFO] = { -- 0x46
	posixtime("News timestamp"),
},
--[[doc
    Message ID:    0x4B

    Message Name:  SID_EXTRAWORK

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (WORD) Game type
                   (WORD) Length
                   (STRING) Work returned data

    Remarks:       Response for both SID_OPTIONALWORK and SID_REQUIREDWORK.

                   Game type:

                   0x01: Diablo II

                   0x02: Warcraft III

                   0x03: Starcraft

                   0x04: World of Warcraft (Reason for this is not known, but most
                   recent libraries have included it)
                   Length:

                   The length is returned from the call to ExtraWork in the
                   ExtraWork DLL. Traditionally, the library responsible for all
                   ExtraWork requests has been IX86ExtraWork.dll.

                   Work returned data:

                   This data is based on a 1024-byte buffer. The call to ExtraWork
                   takes in a structure and returns the length and buffer based on
                   the game type.

    Related:       [0x4A] SID_OPTIONALWORK (S->C), [0x4C] SID_REQUIREDWORK (S->C)

]]
[SID_EXTRAWORK] = { -- 0x4B
	uint16("Game type"),
	uint16("Length"),
	stringz("Work returned data"),
},
--[[doc
    Message ID:    0x50

    Message Name:  SID_AUTH_INFO

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (DWORD) Protocol ID (0)
                   (DWORD) Platform ID
                   (DWORD) Product ID
                   (DWORD) Version Byte
                   (DWORD) Product language
                   (DWORD) Local IP for NAT compatibility*
                   (DWORD) Time zone bias*
                   (DWORD) Locale ID*
                   (DWORD) Language ID*
                   (STRING) Country abreviation
                   (STRING) Country

    Remarks:       Sends information about the Client to Battle.net.

                   *These fields can be set to zero without breaking logon.

                   Protocol ID:

                   Battle.net's current Protocol ID is 0.

                   Platform ID:

                   A DWORD specifying the client's platform (IX86, PMAC, XMAC,
                   etc).

                   Product ID:

                   A DWORD specifying the client's game.

                   Version:

                   The client's version byte.

                   Product Language:

                   This field is under investigation. It can safely be set to 0.

                   MPQ Locale ID:

                   This field is part of Blizzards multi-lingual MPQ system. Is
                   used to specify which version of an MPQ should be used when the
                   MPQ is available in multiple languages.

                   Local IP:

                   This is the local network IP of the client, in network byte
                   order.

                   Timezone bias:

                   The difference, in minutes, between UTC and local time. The
                   client calculates this value by subtracting the Local Time from
                   the System Time, having converted both to Filetime structures,
                   and then converting the resultant offset to minutes by diving it
                   by 600,000,000. If you wish to understand the mechanism
                   involved, read Microsoft's documentation on File times.

                   Language ID, Country Abbreviation, and Country:

                   These values can be retrieved by querying the system's locale
                   information.

                   Language ID can be retrieved using the GetUserDefaultLangID API.
                   Country Abbreviation & Country can be retrieved using the
                   GetLocaleInfo API to request the LOCALE_SABBREVCTRYNAME and
                   LOCALE_SENGCOUNTRY, respectively.

    Related:       [0x50] SID_AUTH_INFO (S->C)

]]
[SID_AUTH_INFO] = { -- 0x50
	uint32("Protocol ID (0)"),
	strdw("Platform ID", Descs.PlatformID),
	strdw("Product ID", Descs.ClientTag),
	uint32("Version Byte", base.HEX),
	strdw("Product language", Descs.LangId),
	ipv4("Local IP for NAT compatibility"),
	int32("Time zone bias", nil, Descs.TimeZoneBias),
	uint32("Locale ID", nil, Descs.LocaleID),
	uint32("Language ID", nil, Descs.LocaleID),
	stringz("Country abreviation"),
	stringz("Country"),
},
--[[doc
    Message ID:    0x51

    Message Name:  SID_AUTH_CHECK

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (DWORD) Client Token
                   (DWORD) EXE Version
                   (DWORD) EXE Hash
                   (DWORD) Number of CD-keys in this packet
                   (BOOLEAN) Spawn CD-key

                   For Each Key:
                   (DWORD) Key Length
                   (DWORD) CD-key's product value
                   (DWORD) CD-key's public value
                   (DWORD) Unknown (0)
                   (DWORD) [5] Hashed Key Data

                   (STRING) Exe Information
                   (STRING) CD-Key owner name

    Remarks:       Contains the EXE Version and Hash as reported by CheckRevision(), and
                   CDKey values. Spawn may only be used for STAR and W2BN.

                   The data that should be hashed for 'Hashed Key Data' is:

                   1. Client Token

                   2. Server Token

                   3. Key Product (from decoded CD key)

                   4. Key Public (from decoded CD key)

                   5. (DWORD) 0

                   6. Key Private (from decoded CD key)

    Related:       [0x51] SID_AUTH_CHECK (S->C)

]]
[SID_AUTH_CHECK] = { -- 0x51
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
		uint32("Unknown (0)"),
		array("Hashed Key Data", uint32, 5),
	}},
	stringz("Exe Information"),
	stringz("CD-Key owner name"),

},
--[[doc
    Message ID:    0x52

    Message Name:  SID_AUTH_ACCOUNTCREATE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) [32] Salt (s)
                   (BYTE) [32] Verifier (v)
                   (STRING) Username

    Remarks:       This message is sent to create an NLS-style account. It contains the
                   client's salt and verifier values, which are saved by the server for
                   use with future logons.

                   See the [NLS/SRP Protocol] page for more information.

    Related:       [0x52] SID_AUTH_ACCOUNTCREATE (S->C)

]]
[SID_AUTH_ACCOUNTCREATE] = { -- 0x52
	array("Salt", uint8, 32),
	array("Verifier", uint8, 32),
	stringz("Username"),
},
--[[doc
    Message ID:    0x53

    Message Name:  SID_AUTH_ACCOUNTLOGON

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) [32] Client Key ('A')
                   (STRING) Username

    Remarks:       This message is sent to the server to initiate a logon. It consists of
                   the client's public key and their UserName.

                   The client's public key is a value calculated by the client and used
                   for a single logon. For more information, see [NLS/SRP Protocol].

    Related:       [0x53] SID_AUTH_ACCOUNTLOGON (S->C)

]]
[SID_AUTH_ACCOUNTLOGON] = { -- 0x53
	array("Client Key", uint8, 32),
	stringz("Username"),
},
--[[doc
    Message ID:    0x54

    Message Name:  SID_AUTH_ACCOUNTLOGONPROOF

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) [20] Client Password Proof (M1)

    Remarks:       This message is sent to the server after a successful
                   SID_AUTH_ACCOUNTLOGON. It contains the client's password proof. See
                   [NLS/SRP Protocol] for more information.

    Related:       [0x54] SID_AUTH_ACCOUNTLOGONPROOF (S->C),
                   [0x53] SID_AUTH_ACCOUNTLOGON (S->C)

]]
[SID_AUTH_ACCOUNTLOGONPROOF] = { -- 0x54
	array("Client Password Proof", uint8, 20),
},
--[[doc
    Message ID:    0x55

    Message Name:  SID_AUTH_ACCOUNTCHANGE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) [32] Client key (A)
                   (STRING) Username

    Remarks:       This message is used to change the client's password.

    Related:       [0x55] SID_AUTH_ACCOUNTCHANGE (S->C)

]]
[SID_AUTH_ACCOUNTCHANGE] = { -- 0x55
	array("Client key", uint8, 32),
	stringz("Username"),
},
--[[doc
    Message ID:    0x56

    Message Name:  SID_AUTH_ACCOUNTCHANGEPROOF

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) [20] Old password proof
                   (BYTE) [32] New password's salt (s)
                   (BYTE) [32] New password's verifier (v)

    Remarks:       This message is sent after receiving a successful
                   SID_AUTH_ACCOUNTCHANGE message, and contains the proof for the
                   client's new password.

                   See [NLS/SRP Protocol] for more information.

    Related:       [0x56] SID_AUTH_ACCOUNTCHANGEPROOF (S->C),
                   [0x55] SID_AUTH_ACCOUNTCHANGE (S->C)

]]
[SID_AUTH_ACCOUNTCHANGEPROOF] = { -- 0x56
	array("Old password proof", uint8, 20),
	array("New password's salt", uint8, 32),
	array("New password's verifier", uint8, 32),
},
--[[doc
    Message ID:      0x57

    Message Name:    SID_AUTH_ACCOUNTUPGRADE

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          [blank]

    Remarks:         This message is sent to upgrade an old account to an NLS-style
                     account. It should be sent when SID_AUTH_ACCOUNTLOGON or
                     SID_AUTH_ACCOUNTCHANGE indicates that an account upgrade is required.

    Related:         [0x57] SID_AUTH_ACCOUNTUPGRADE (S->C),
                     [0x53] SID_AUTH_ACCOUNTLOGON (S->C),
                     [0x55] SID_AUTH_ACCOUNTCHANGE (S->C),
                     [0x58] SID_AUTH_ACCOUNTUPGRADEPROOF (C->S)

]]
[SID_AUTH_ACCOUNTUPGRADE] = { -- 0x57
},
--[[doc
    Message ID:      0x58

    Message Name:    SID_AUTH_ACCOUNTUPGRADEPROOF

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (DWORD) Client Token
                     (DWORD) [5] Old Password Hash
                     (BYTE) [32] New Password Salt
                     (BYTE) [32] New Password Verifier

    Remarks:         Old Password Hash:
                     Broken SHA-1 Double password hash as seen in
                     SID_LOGONRESPONSE(2) OLS.

                     New Password Salt & Verifier:
                     Salt and Verifier values as seen in SID_AUTH_ACCOUNTCREATE.

                     Old Password is the account's current password. The New Password can
                     be the same as the Old Password, but it can be used to change the
                     password as well.

                     Basically this packet would convert the stored password hash to a new
                     one, and thus become NLS. However, this packet is no longer responded
                     to, and upgrading accounts is therefore impossible.(Note: If you have
                     an account in need of upgrading [created with SID_CREATEACCOUNT(2)],
                     you can let the account expire and recreate it with
                     SID_AUTH_ACCOUNTCREATE.)

    Related:         [0x58] SID_AUTH_ACCOUNTUPGRADEPROOF (S->C),
                     [0x57] SID_AUTH_ACCOUNTUPGRADE (C->S),
                     [0x57] SID_AUTH_ACCOUNTUPGRADE (S->C)

]]
[SID_AUTH_ACCOUNTUPGRADEPROOF] = { -- 0x58
	uint32("Client Token"),
	array("Old Password Hash", uint32, 5),
	array("New Password Salt", uint8, 32),
	array("New Password Verifier", uint8, 32),
},
--[[doc
    Message ID:    0x59

    Message Name:  SID_SETEMAIL

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (STRING) Email Address

    Remarks:       Binds an email address to your account.

                   Sending this message is optional. However, you should only send it
                   when either you receive SID_SETEMAIL from the server or you receive
                   status 0x0E from SID_AUTH_ACCOUNTLOGONPROOF.

                   This packet used to be named SID_AUTH_RECONNECT, however Blizzard
                   never had it implemented, and so reused the packet ID for their email
                   system.

    Related:       [0x59] SID_SETEMAIL (S->C), [0x54] SID_AUTH_ACCOUNTLOGONPROOF (S->C)

]]
[SID_SETEMAIL] = { -- 0x59
	stringz("Email Address"),
},
--[[doc
    Message ID:    0x5A

    Message Name:  SID_RESETPASSWORD

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (STRING) Account Name
                   (STRING) Email Address

    Remarks:       Requests that Battle.net reset your password. This packet must be sent
                   before logon.

                   This message requires an email address because Battle.net has to prove
                   it's your account. Since this message must be sent before
                   SID_LOGONRESPONSE, SID_LOGONRESPONSE2, or SID_AUTH_ACCOUNTLOGON, you
                   must supply an e-mail address so Battle.net knows that you may have
                   ownership to it.

                   This packet used to be named SID_AUTH_RECONNECTPROOF, however Blizzard
                   never had it implemented, and so reused the packet ID for their email
                   system.

    Related:       [0x29] SID_LOGONRESPONSE (C->S), [0x3A] SID_LOGONRESPONSE2 (C->S),
                   [0x53] SID_AUTH_ACCOUNTLOGON (C->S)

]]
[SID_RESETPASSWORD] = { -- 0x5A
	stringz("Account Name"),
	stringz("Email Address"),
},
--[[doc
    Message ID:    0x5B

    Message Name:  SID_CHANGEEMAIL

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (STRING) Account Name
                   (STRING) Old Email Address
                   (STRING) New Email Address

    Remarks:       Requests Battle.net to change the email address bound to an account.
                   This packet must be sent before logon.

                   This packet used to be named SID_AUTH_DISCONNECT, however Blizzard
                   never had it implemented, and so reused the packet ID for their email
                   system.

]]
[SID_CHANGEEMAIL] = { -- 0x5B
	stringz("Account Name"),
	stringz("Old Email Address"),
	stringz("New Email Address"),
},
--[[doc
    Message ID:    0x5C

    Message Name:  SID_SWITCHPRODUCT

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne

    Format:        (DWORD) Product ID

    Remarks:       When logging onto WAR3, while having W3XP installed on your system;
                   the client sends two CDKey hashes in SID_AUTH_CHECK and uses 'W3XP' as
                   the Product Id in SID_AUTH_INFO. After a successful SID_AUTH_CHECK,
                   the client then sends this packet with the Product ID set to 'WAR3' to
                   make the switch from expansion to non-expansion.

]]
[SID_SWITCHPRODUCT] = { -- 0x5C
	strdw("Product ID", Descs.ClientTag),
},
--[[doc
    Message ID:      0x5D

    Message Name:    SID_REPORTCRASH

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Warcraft III: The Frozen Throne, Diablo, Warcraft III

    Format:          (DWORD) 0x10A0027
                     (DWORD) Exception code
                     (DWORD) Unknown
                     (DWORD) Unknown

    Remarks:         When the game crashes, (usually) a file named Crashdump is created. If
                     this file exists at the next logon, the contents of it are sent to
                     Battle.net in this message.

                     The first DWORD for Diablo II is a constant value (version?), as seen
                     in Fog.dll.

                     All calls to Fog_10052 result in the output of Crashdump.

                     More research is required.

]]
[SID_REPORTCRASH] = { -- 0x5D
	uint32("0x10A0027"),
	uint32("Exception code"),
	uint32("Unknown"),
	uint32("Unknown"),
},
--[[doc
    Message ID:    0x5E

    Message Name:  SID_WARDEN

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        (VOID) Encrypted Packet

                   Contents of encrypted data
                   (BYTE) Packet Code

                   0x00 - Warden Module Info
                   (BYTE) Success (0x00 = Don't have the module, 0x01 = Have the module)
                   
				   0x01 - Warden Module Data
                   (BYTE) Success (0x00 = MD5 doesn't match, 0x01 = MD5 matches)
                   
				   0x02 - Data Checker
                   (WORD) String Length
				   (DWORD) String Checksum
				   (VOID) String Data

                   MEM_CHECK:

                   (BYTE) Success (0x00 = Read data, 0x01 = Unable to read)

                   (VOID) Data (0x00 only)
                   PAGE_CHECK_A:

                   (BYTE) Success (0x00 = SHA1s match, 0x01 = SHA1s don't match)

                   (BYTE) IDXor
                   0x04 - Initialization
                   (DWORD)[4] Unknown

    Remarks:       The packet is encrypted via standard RC4 hashing, using one key for
                   outbound data and another for inbound. Its purpose is to return
                   executable data and checksum information from various Warden modules.
                   Full information on how to handle this packet may be found at the
                   Rudimentary Warden information topic.

                   Documentation provided by iago and Ringo.

    Related:       [0x5E] SID_WARDEN (S->C)

]]
[SID_WARDEN] = { -- 0x5E
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
	array("Unknown", uint32, 4),
},
--[[doc
    Message ID:    0x60

    Message Name:  SID_GAMEPLAYERSEARCH

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       This message requests a list of players for an arranged team game.

    Related:       [0x60] SID_GAMEPLAYERSEARCH (S->C)

]]
[SID_GAMEPLAYERSEARCH] = { -- 0x60
},
--[[doc
    Message ID:    0x65

    Message Name:  SID_FRIENDSLIST

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        [blank]

    Remarks:       Requests a friends list.

    Related:       [0x65] SID_FRIENDSLIST (S->C)

]]
[SID_FRIENDSLIST] = { -- 0x65
},
--[[doc
    Message ID:    0x66

    Message Name:  SID_FRIENDSUPDATE

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        (BYTE) Friends list index

    Remarks:       Friends List index is 0-based. (i.e.: friend #1 on friends list would
                   have a value of 0 in this message, friend #2 would have a value of 1).
                   This message requests a check for your friend to see if there are any
                   updates. The server should immediately reply with SID_FRIENDUPDATE.

    Related:       [0x66] SID_FRIENDSUPDATE (S->C)

]]
[SID_FRIENDSUPDATE] = { -- 0x66
	uint8("Friends list index"),
},
--[[doc
    Message ID:    0x70

    Message Name:  SID_CLANFINDCANDIDATES

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) Clan Tag

    Remarks:       This message is sent to the server to check for viable candidates in
                   the channel and friend list, and also to check the availability of the
                   specified clan tag. If 9 or more candidates are found, the official
                   client prompted with a selection of users that he wants to invite to
                   start a clan.

    Related:       [0x70] SID_CLANFINDCANDIDATES (S->C)

]]
[SID_CLANFINDCANDIDATES] = { -- 0x70
	uint32("Cookie"),
	strdw("Clan Tag"),
},
--[[doc
    Message ID:    0x71

    Message Name:  SID_CLANINVITEMULTIPLE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) Clan name
                   (DWORD) Clan tag
                   (BYTE) Number of users to invite
                   (STRING) [] Usernames to invite

    Remarks:       This message is used to invite the initial 9 required members to a new
                   clan. The users specified in this packet will receive 0x72.

    Related:       [0x71] SID_CLANINVITEMULTIPLE (S->C),
                   [0x72] SID_CLANCREATIONINVITATION (S->C)

]]
[SID_CLANINVITEMULTIPLE] = { -- 0x71
	uint32("Cookie"),
	stringz("Clan name"),
	strdw("Clan tag"),
	uint8{"Number of users to invite", key="numusers"},
	iterator{label="Usernames to invite", refkey="numusers", repeated={
		stringz("Account"),
	}},
	-- stringz("[] Usernames to invite"),
},
--[[doc
    Message ID:    0x72

    Message Name:  SID_CLANCREATIONINVITATION

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) Clan tag
                   (STRING) Inviter name
                   (BYTE) Status

    Remarks:       This message is used to reply to an invitation to create a new clan.

    Related:       [0x72] SID_CLANCREATIONINVITATION (S->C), Clan Message Codes

]]
[SID_CLANCREATIONINVITATION] = { -- 0x72
	uint32("Cookie"),
	strdw("Clan tag"),
	stringz("Inviter name"),
	uint8("Status"),
},
--[[doc
    Message ID:    0x73

    Message Name:  SID_CLANDISBAND

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie

    Remarks:       Disbands the clan of which the client is a member. You must be a
                   leader to send this packet.

    Related:       [0x73] SID_CLANDISBAND (S->C)

]]
[SID_CLANDISBAND] = { -- 0x73
	uint32("Cookie"),
},
--[[doc
    Message ID:    0x74

    Message Name:  SID_CLANMAKECHIEFTAIN

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) New Cheiftain

    Remarks:       Changes the clan's chieftain.

    Related:       [0x74] SID_CLANMAKECHIEFTAIN (S->C)

]]
[SID_CLANMAKECHIEFTAIN] = { -- 0x74
	uint32("Cookie"),
	stringz("New Cheiftain"),
},
--[[doc
    Message ID:    0x77

    Message Name:  SID_CLANINVITATION

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) Target User

    Remarks:       This message is used when a leader or officer invites a user to join
                   their clan.

    Related:       [0x77] SID_CLANINVITATION (S->C)

]]
[SID_CLANINVITATION] = { -- 0x77
	uint32("Cookie"),
	stringz("Target User"),
},
--[[doc
    Message ID:    0x78

    Message Name:  SID_CLANREMOVEMEMBER

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) Username

    Remarks:       Kick a member out of the clan. Only clan leaders and officers may
                   perform this action successfully. Members can only be removed if
                   they've been in the clan for over one week.

    Related:       [0x78] SID_CLANREMOVEMEMBER (S->C)

]]
[SID_CLANREMOVEMEMBER] = { -- 0x78
	uint32("Cookie"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x79

    Message Name:  SID_CLANINVITATIONRESPONSE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) Clan tag
                   (STRING) Inviter
                   (BYTE) Response

    Remarks:       This packet is sent to accept or decline an invitation to a clan.

                   Response:
                   0x04: Decline

                   0x06: Accept

    Related:       [0x79] SID_CLANINVITATIONRESPONSE (S->C), Clan Message Codes

]]
[SID_CLANINVITATIONRESPONSE] = { -- 0x79
	uint32("Cookie"),
	strdw("Clan tag"),
	stringz("Inviter"),
	uint8("Response"),
},
--[[doc
    Message ID:    0x7A

    Message Name:  SID_CLANRANKCHANGE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) Username
                   (BYTE) New rank

    Remarks:       Used by leaders and officers to change the rank of a clan member.

                   New rank:

                   0x01: Initiate that has been in the clan for over one week 0x02:
                   Member 0x03: Officer

    Related:       [0x74] SID_CLANMAKECHIEFTAIN (C->S), [0x7A] SID_CLANRANKCHANGE (S->C)

]]
[SID_CLANRANKCHANGE] = { -- 0x7A
	uint32("Cookie"),
	stringz("Username"),
	uint8("New rank"),
},
--[[doc
    Message ID:    0x7B

    Message Name:  SID_CLANSETMOTD

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) MOTD

    Remarks:       Sets your clan's Message of the Day.

]]
[SID_CLANSETMOTD] = { -- 0x7B
	uint32("Cookie"),
	stringz("MOTD"),
},
--[[doc
    Message ID:    0x7C

    Message Name:  SID_CLANMOTD

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie

    Remarks:       Requests the clan's MOTD.

    Related:       [0x7C] SID_CLANMOTD (S->C)

]]
[SID_CLANMOTD] = { -- 0x7C
	uint32("Cookie"),
},
--[[doc
    Message ID:    0x7D

    Message Name:  SID_CLANMEMBERLIST

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie

    Remarks:       Requests a clan memberlist.

    Related:       [0x7D] SID_CLANMEMBERLIST (S->C), Clan Message Codes

]]
[SID_CLANMEMBERLIST] = { -- 0x7D
	uint32("Cookie"),
},
--[[doc
    Message ID:    0x82

    Message Name:  SID_CLANMEMBERINFORMATION

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) User's clan tag
                   (STRING) Username

    Remarks:       This packet requests information about a user and their current status
                   within their clan. If the user is in a clan, it'll return what clan
                   they're in, their rank, along with the time they joined it in a
                   FILETIME structure.

    Related:       [0x82] SID_CLANMEMBERINFORMATION (S->C), Clan Message Codes

]]
[SID_CLANMEMBERINFORMATION] = { -- 0x82
	uint32("Cookie"),
	strdw("User's clan tag"),
	stringz("Username"),
},
-- End cpackets_sid.lua
