-- Begin cpackets_mcp.lua
--[[doc
    Message ID:      0x01

    Message Name:    MCP_STARTUP

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) MCP Cookie
                     (DWORD) MCP Status
                     (DWORD) [2] MCP Chunk 1
                     (DWORD) [12] MCP Chunk 2
                     (STRING) Battle.net Unique Name

    Remarks:         This packet authenticates the client with the MCP and allows character
                     querying and logon to proceed.
                     All 16 DWORDs (Cookie, Status, Chunk 1, and Chunk 2) are received from
                     the server via SID_LOGONREALMEX.

                     Not much information is known about the DWORD values, other than that
                     they're received from the server. The following information needs
                     work:

                     MCP Cookie: Client Token

                     MCP Status: Unknown

                     MCP Chunk 1 [01]: Server IP (BNCS)

                     MCP Chunk 1 [02]: UDP Value *

                     MCP Chunk 2 [01]: Unknown

                     MCP Chunk 2 [02]: Unknown

                     MCP Chunk 2 [03]: Something to do with the gateway

                     MCP Chunk 2 [04]: Product (D2DV/D2XP)

                     MCP Chunk 2 [05]: Platform (IX86/PMAC/XMAC)

                     MCP Chunk 2 [06]: Unknown

                     MCP Chunk 2 [07]: Language ID (1033 [0x409] for enUS)

                     MCP Chunk 2 [08]: Unknown

                     MCP Chunk 2 [09]: Unknown

                     MCP Chunk 2 [10]: Unknown

                     MCP Chunk 2 [11]: Unknown

                     MCP Chunk 2 [12]: Unknown
                     This is purely speculation, but as there are 5 unknown DWORDs at the
                     end of this chunk, it is possible that it is actually a hash of
                     something.

                     * UDPValue: No one really knows what this is, however, it is used in
                     2nd DWORD of the UDP packet PKT_CONNTEST2. The client receives it in
                     SID_AUTH_INFO.

    Related:         [0x01] MCP_STARTUP (S->C), [0x3E] SID_LOGONREALMEX (S->C),
                     [0x50] SID_AUTH_INFO (S->C), [0x09] PKT_CONNTEST2 (C->S)

]]
[MCP_STARTUP] = { -- 0x01
	uint32("MCP Cookie"),
	uint32("MCP Status"),
	array("MCP Chunk 1", uint32, 2),
	array("MCP Chunk 2", uint32, 12),
	stringz("Battle.net Unique Name"),
},
--[[doc
    Message ID:    0x02

    Message Name:  MCP_CHARCREATE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Character class
                   (WORD) Character flags
                   (STRING) Character name

    Remarks:       Creates a character on the Realm.

                   Character Classes are the same as in D2 users' Statstrings:

                   0x00: Amazon 0x01: Sorceress 0x02: Necromancer 0x03: Paladin
                   0x04: Barbarian 0x05: Druid 0x06: Assassin

                   Flag values should be OR'd together. The only flags that can be set
                   for character creation are classic, hardcore, expansion, and ladder,
                   but the other flags are included here for completeness:

                   0x00: Classic
                   0x04: Hardcore
                   0x08: Dead
                   0x20: Expansion
                   0x40: Ladder 
				   
				   Sending 0x05 or 0x06 in character class or 0x20 in
                   character flags while on D2DV will disconnect and temporarily
                   ban you from the realm. Likewise, sending 0x05 or 0x06 in
                   character class without setting 0x20 in character flags will
                   result in a disconnect and ban.

    Related:       [0x02] MCP_CHARCREATE (S->C)

]]
[MCP_CHARCREATE] = { -- 0x02
	uint32("Character class", nil, {
		[0x00] = "Amazon", 
		[0x01] = "Sorceress", 
		[0x02] = "Necromancer", 
		[0x03] = "Paladin",
		[0x04] = "Barbarian", 
		[0x05] = "Druid", 
		[0x06] = "Assassin",
	}),
	uint16("Character flags"),
	stringz("Character name"),
},
--[[doc
    Message ID:    0x03

    Message Name:  MCP_CREATEGAME

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Request Id *
                   (DWORD) Difficulty
                   (BYTE) Unknown - 1
                   (BYTE) Player difference **
                   (BYTE) Maximum players
                   (STRING) Game name
                   (STRING) Game password
                   (STRING) Game description

    Remarks:       Difficulty:
                   0x0000: Normal

                   0x1000: Nightmare

                   0x2000: Hell
                   * This value starts at 0x02 at first game creation, and increments by
                   0x02 each consecutive game creation.

                   ** A value of 0xFF indicates that the game is not restricted by
                   character difference.

                   Before sending the game name and password, Diablo II automatically
                   changes their case. For example if the string "aBc DeF" is typed in
                   Diablo II, then the string sent is "Abc Def". This does not apply to
                   the game description.

    Related:       [0x03] MCP_CREATEGAME (S->C)

]]
[MCP_CREATEGAME] = { -- 0x03
	uint16("Request Id"),
	uint32("Difficulty"),
	uint8("Unknown - 1"),
	uint8("Player difference"),
	uint8("Maximum players"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game description"),
},
--[[doc
    Message ID:    0x04

    Message Name:  MCP_JOINGAME

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Request ID
                   (STRING) Game name
                   (STRING) Game Password

    Remarks:       This must be sent after a successful game creation.

    Related:       [0x04] MCP_JOINGAME (S->C)

]]
[MCP_JOINGAME] = { -- 0x04
	uint16("Request ID"),
	stringz("Game name"),
	stringz("Game Password"),
},
--[[doc
    Message ID:    0x05

    Message Name:  MCP_GAMELIST

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Request ID
                   (DWORD) Unknown (0)
                   (STRING) Search String *

    Remarks:       Requests a game listing.

                   * Normally blank. If a non-empty string is sent, games will be
                   returned that include this string in their names. This is not used by
                   the client, but still exists.

    Related:       [0x05] MCP_GAMELIST (S->C)

]]
[MCP_GAMELIST] = { -- 0x05
	uint16("Request ID"),
	uint32("Unknown"),
	stringz("Search String"),
},
--[[doc
    Message ID:    0x06

    Message Name:  MCP_GAMEINFO

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Request ID
                   (STRING) Game name

    Remarks:       Requests information about a game.

    Related:       [0x06] MCP_GAMEINFO (S->C)

]]
[MCP_GAMEINFO] = { -- 0x06
	uint16("Request ID"),
	stringz("Game name"),
},
--[[doc
    Message ID:    0x07

    Message Name:  MCP_CHARLOGON

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (STRING) Character name

    Remarks:       Logs onto the realm.

                   Note that attempting to log on using an expansion character on D2DV
                   will result in an IPBan by both Battle.net and the Realm.

    Related:       [0x07] MCP_CHARLOGON (S->C)

]]
[MCP_CHARLOGON] = { -- 0x07
	stringz("Character name"),
},
--[[doc
    Message ID:    0x0A

    Message Name:  MCP_CHARDELETE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Unknown (0)
                   (STRING) Character name

    Remarks:       Deletes a character.

    Related:       [0x0A] MCP_CHARDELETE (S->C)

]]
[MCP_CHARDELETE] = { -- 0x0A
	uint16("Unknown"),
	stringz("Character name"),
},
--[[doc
    Message ID:    0x11

    Message Name:  MCP_REQUESTLADDERDATA

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Ladder type
                   (WORD) Starting position

    Remarks:       This will request 16 ladder entries, starting at a zero-based location
                   specified in 'Starting position'. For example if this is 0, then
                   ladder entries 1-16 are retrieved. If this is 17, then ladder entries
                   18-33 are retrieved. Note: The values that Diablo 2 sends for this are
                   always perfectly divisible by 16. This might be a requirement.

                   Possible ladder types:
                   0x00: standard hardcore overall ladder

                   0x01: standard hardcore amazon ladder

                   0x02: standard hardcore sorceress ladder

                   0x03: standard hardcore necromancer ladder

                   0x04: standard hardcore paladin ladder

                   0x05: standard hardcore barbarian ladder

                   0x09: standard softcore overall ladder

                   0x0A: standard softcore amazon ladder

                   0x0B: standard softcore sorceress ladder

                   0x0C: standard softcore necromancer ladder

                   0x0D: standard softcore paladin ladder

                   0x0E: standard softcore barbarian ladder

                   0x13: expansion hardcore overall ladder

                   0x14: expansion hardcore amazon ladder

                   0x15: expansion hardcore sorceress ladder

                   0x16: expansion hardcore necromancer ladder

                   0x17: expansion hardcore paladin ladder

                   0x18: expansion hardcore barbarian ladder

                   0x19: expansion hardcore druid ladder

                   0x1A: expansion hardcore assassin ladder

                   0x1B: expansion softcore overall ladder

                   0x1C: expansion softcore amazon ladder

                   0x1D: expansion softcore sorceress ladder

                   0x1E: expansion softcore necromancer ladder

                   0x1F: expansion softcore paladin ladder

                   0x20: expansion softcore barbarian ladder

                   0x21: expansion softcore druid ladder

                   0x22: expansion softcore assassin ladder

    Related:       [0x11] MCP_REQUESTLADDERDATA (S->C)

]]
[MCP_REQUESTLADDERDATA] = { -- 0x11
	uint8("Ladder type"),
	uint16("Starting position"),
},
--[[doc
    Message ID:    0x12

    Message Name:  MCP_MOTD

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        [blank]

    Remarks:       Requests the realm's MOTD.

    Related:       [0x12] MCP_MOTD (S->C)

]]
[MCP_MOTD] = { -- 0x12
},
--[[doc
    Message ID:    0x13

    Message Name:  MCP_CANCELGAMECREATE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        [blank]

    Remarks:       Notifies the server that you want to cancel the creation of your game.

]]
[MCP_CANCELGAMECREATE] = { -- 0x13
},
--[[doc
    Message ID:    0x17

    Message Name:  MCP_CHARLIST

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Number of characters to list

    Remarks:       Requests a character list.

    Related:       [0x17] MCP_CHARLIST (S->C)

]]
[MCP_CHARLIST] = { -- 0x17
	uint32("Number of characters to list"),
},
--[[doc
    Message ID:    0x18

    Message Name:  MCP_CHARUPGRADE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (STRING) Character Name

    Remarks:       Converts a non-expansion character to expansion.

    Related:       [0x18] MCP_CHARUPGRADE (S->C)

]]
[MCP_CHARUPGRADE] = { -- 0x18
	stringz("Character Name"),
},
--[[doc
    Message ID:    0x19

    Message Name:  MCP_CHARLIST2

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Number of characters to list.

    Remarks:       Requests a character list.

                   Up to a maximum of 8 characters can be requested.

    Related:       [0x19] MCP_CHARLIST2 (S->C)

]]
[MCP_CHARLIST2] = { -- 0x19
	uint32("Number of characters to list"),
},
-- End cpackets_mcp.lua
