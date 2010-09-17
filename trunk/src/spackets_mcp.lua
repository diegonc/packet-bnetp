-- Begin spackets_mcp.lua
[MCP_STARTUP] = { -- 0x01
	uint32("Result"),
},
--[[doc
    Message ID:    0x02

    Message Name:  MCP_CHARCREATE

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Result

    Remarks:       The return value for character creation.

                   Known values:
                   0x00: Success

                   0x14: Character already exists, or maximum number of characters
                   (currently 8) reached.

                   0x15: Invalid name

    Related:       [0x02] MCP_CHARCREATE (C->S)

]]
[MCP_CHARCREATE] = { -- 0x02
	uint32("Result"),
},
--[[doc
    Message ID:    0x03

    Message Name:  MCP_CREATEGAME

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Request Id
                   (WORD) Game token
                   (WORD) Unknown (0)
                   (DWORD) Result

    Remarks:       Result:
                   0x00: Game creation succeeded. This does NOT automatically join
                   the game - the client must also send packet MCP_JOINGAME.

                   0x1E: Invalid game name.

                   0x1F: Game already exists.

                   0x20: Game servers are down.

                   0x6E: A dead hardcore character cannot create games.

    Related:       [0x03] MCP_CREATEGAME (C->S), [0x04] MCP_JOINGAME (C->S)

]]
[MCP_CREATEGAME] = { -- 0x03
	uint16("Request Id"),
	uint16("Game token"),
	uint16("Unknown"),
	uint32("Result"),
},
--[[doc
    Message ID:    0x04

    Message Name:  MCP_JOINGAME

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Request ID
                   (WORD) Game token
                   (WORD) Unknown (0)
                   (DWORD) IP of D2GS Server
                   (DWORD) Game hash
                   (DWORD) Result

    Remarks:       Possible values for result:
                   0x00: Game joining succeeded. In this case, Diablo 2 terminates
                   the connection with the MCP and initiates the connection with
                   the D2GS.

                   0x29: Password incorrect.

                   0x2A: Game does not exist.

                   0x2B: Game is full.

                   0x2C: You do not meet the level requirements for this game.

                   0x6E: A dead hardcore character cannot join a game.

                   0x71: A non-hardcore character cannot join a game created by a
                   Hardcore character.

                   0x73: Unable to join a Nightmare game.

                   0x74: Unable to join a Hell game.

                   0x78: A non-expansion character cannot join a game created by an
                   Expansion character.

                   0x79: A Expansion character cannot join a game created by a
                   non-expansion character.

                   0x7D: A non-ladder character cannot join a game created by a
                   Ladder character.

    Related:       [0x04] MCP_JOINGAME (C->S)

]]
[MCP_JOINGAME] = { -- 0x04
	uint16("Request ID", base.HEX),
	uint16("Game token", base.HEX),
	uint16("Unknown", base.HEX),
	ipv4("IP of D2GS Server"),
	uint32("Game hash"),
	uint32("Result", base.HEX, {
		[0x00] = "Game joining succeeded",
		[0x29] = "Password incorrect",
		[0x2A] = "Game does not exist",
		[0x2B] = "Game is full",
		[0x2C] = "You do not meet the level requirements for this game",
		[0x6E] = "A dead hardcore character cannot join a game",
		[0x71] = "A non-hardcore character cannot join a game created by a Hardcore character",
		[0x73] = "Unable to join a Nightmare game",
		[0x74] = "Unable to join a Hell game",
		[0x78] = "A non-expansion character cannot join a game created by an Expansion character",
		[0x79] = "A Expansion character cannot join a game created by a non-expansion character",
		[0x7D] = "A non-ladder character cannot join a game created by a Ladder character",
	}),
},
--[[doc
    Message ID:    0x05

    Message Name:  MCP_GAMELIST

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Request Id
                   (DWORD) Index
                   (BYTE) Number of players in game
                   (DWORD) Status
                   (STRING) Game name
                   (STRING) Game description

    Remarks:       Instead of receiving a single response that has a list of all the
                   games, the client will receive this packet once for every game listed
                   by the server.

                   Request Id:
                   Like a cookie. This value will be whatever you sent the server
                   in MCP_GAMELIST.

                   Index:
                   The game's index on the server.

                   Number of players in game:
                   Self explanatory.

                   Status:
                   0x00300004: Game is available to join

                   0xFFFFFFFF: Server is down

    Related:       [0x05] MCP_GAMELIST (C->S)

]]
[MCP_GAMELIST] = { -- 0x05
	uint16("Request Id"),
	uint32("Index"),
	uint8("Number of players in game"),
	uint32("Status"),
	stringz("Game name"),
	stringz("Game description"),
},
--[[doc
    Message ID:    0x06

    Message Name:  MCP_GAMEINFO

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Request ID
                   (DWORD) Status *
                   (DWORD) Game Uptime (seconds)
                   (WORD) Unknown
                   (BYTE) Maximum players allowed
                   (BYTE) Number of characters in the game
                   (BYTE) [16] Classes of ingame characters **
                   (BYTE) [16] Levels of ingame characters **
                   (BYTE) Unused (0)
                   (STRING) [16] Character names **

    Remarks:       * Usually 0x00300004, but rarely 0. If it is 0, the packet contains no
                   useful information and the server is probably down.

                   ** Internally, there are 16 character slots, but the last 8 are always
                   empty.
                   This value sometimes includes some empty character slots.
                   Then, some empty strings are added to the end of the packet.
                   To determine the number of characters really in the game:

                   CharsInGameReal = CharsInGameFake - AmountOfEmptyCharNames;

                   Byte N here refers to character in slot N, or 0 if the slot is empty.

    Related:       [0x06] MCP_GAMEINFO (C->S)

]]
[MCP_GAMEINFO] = { -- 0x06
	uint16("Request ID"),
	uint32("Status"),
	uint32("Game Uptime"),
	uint16("Unknown"),
	uint8("Maximum players allowed"),
	uint8("Number of characters in the game"),
	array("Classes of ingame characters", uint8, 16),
	array("Levels of ingame characters", uint8, 16),
	uint8("Unused"),
	stringz("[16] Character names"),
},
--[[doc
    Message ID:    0x07

    Message Name:  MCP_CHARLOGON

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Result

    Remarks:       Logon response.

                   Known values:
                   0x00: Success

                   0x46: Player not found

                   0x7A: Logon failed

                   0x7B: Character expired

    Related:       [0x07] MCP_CHARLOGON (C->S)

]]
[MCP_CHARLOGON] = { -- 0x07
	uint32("Result"),
},
--[[doc
    Message ID:    0x0A

    Message Name:  MCP_CHARDELETE

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Result

    Remarks:       Deletion response.

                   Known values:

                   (Diablo II v1.10 or later)
                   0x00: Success

                   0x49: Character doesn't exist

                   (Diablo II v1.09 or earlier)
                   0x00: Character doesn't exist

                   0x49: Success

    Related:       [0x0A] MCP_CHARDELETE (C->S)

]]
[MCP_CHARDELETE] = { -- 0x0A
	uint32("Result"),
},
--[[doc
    Message ID:    0x11

    Message Name:  MCP_REQUESTLADDERDATA

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Ladder type
                   The 10-byte header:
                   (WORD) Total response size

                   (WORD) Current message size

                   (WORD) Total size of unreceived messages

                   (WORD) Rank of first entry

                   (WORD) Unknown (0)

                   Message data:
                   (DWORD)Number of entries

                   (DWORD)Unknown (0x10)

                   For each entry:
                   (QWORD) Character experience

                   (BYTE) Character Flags

                   (BYTE) Character title

                   (WORD) Character level

                   (BYTE) [16] Character name

    Remarks:       Total Response Size:
                   The size of the entire batch of SID_REQUESTLADDERDATA messages,
                   excluding their headers and first bytes.

                   Current Message Size:
                   The size of the current message, excluding its header and first
                   byte.

                   Total size of unreceived messages:
                   The total size of all the unreceived messages in the batch,
                   excluding their headers and first bytes. In the last packet,
                   this value is 0, since there are no unreceived messages.

                   Rank of first entry:
                   Always zero, except in the last message. In the last message,
                   this specifies the zero-based rank of the first entry. (For
                   example if this is 17 in the last packet, then ladder entries
                   18-33 were retrieved.)

                   Character Flags:
                   0x00: Amazon

                   0x01: Sorceress

                   0x02: Necromancer

                   0x03: Paladin

                   0x04: Barbarian

                   0x05: Druid

                   0x06: Assassin

                   +0x60 to this field if it's a living hardcore character.

                   +0x70 to this field if it's a dead hardcore character.

                   The character is softcore by default.

                   Character Name:
                   The character name is always 16 bytes. If the name is shorter
                   than 16 bytes, the string is padded with nulls. The last byte is
                   always null, since character names are limited to 15 chars.

                   General Remarks:
                   The server may respond to this packet with one or more of these
                   messages. The client must not handle the data until the last
                   packet in the batch is received.

                   The messages' data should be concatenated backwards. For
                   example, if 3 packets were received, then the data buffer should
                   contain the data of the 3rd packet, followed by the data of the
                   2nd packet, followed by the data of the 1st packet. Only after
                   the last packet was received, the data buffer should be parsed.

                   Important note: If the entry is the last entry in the packet,
                   the character name might be smaller than 16 bytes.In this case,
                   the client MUST add null bytes to the end of the packet, BEFORE
                   adding it to the data buffer.

                   Ladder packets are NOT SENT IN ANY ORDER - They are often sent
                   completely out of order and must be placed back into the proper
                   order. You have to infer the sequencing based on the 'how big'
                   fields in the 10 byte header.

    Related:       [0x11] MCP_REQUESTLADDERDATA (C->S)

]]
[MCP_REQUESTLADDERDATA] = { -- 0x11
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
	array("Character name", uint8, 16),
},
--[[doc
    Message ID:    0x12

    Message Name:  MCP_MOTD

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Unknown
                   (STRING) MOTD

    Remarks:       Contains the realm's MOTD. The Byte at the beginning is apparently
                   ignored.

    Related:       [0x12] MCP_MOTD (C->S)

]]
[MCP_MOTD] = { -- 0x12
	uint8("Unknown"),
	stringz("MOTD"),
},
--[[doc
    Message ID:    0x14

    Message Name:  MCP_CREATEQUEUE

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Position

    Remarks:       Position in line to create a game.

]]
[MCP_CREATEQUEUE] = { -- 0x14
	uint32("Position"),
},
--[[doc
    Message ID:    0x17

    Message Name:  MCP_CHARLIST

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Number of characters requested
                   (DWORD) Number of characters that exist on this account
                   (WORD) Number of characters returned

                   For each character:
                   (STRING) Character name

                   (STRING) Character statstring

    Remarks:       Lists characters.

                   The statstrings in this packet do not contain the product or character
                   name. Everything else is the same as a character statstring you would
                   receive from a character entering the channel.

    Related:       [0x17] MCP_CHARLIST (C->S)

]]
[MCP_CHARLIST] = { -- 0x17
	uint16("Number of characters requested"),
	uint32("Number of characters that exist on this account"),
	uint16("Number of characters returned"),
	stringz("Character name"),
	stringz("Character statstring"),
},
--[[doc
    Message ID:    0x18

    Message Name:  MCP_CHARUPGRADE

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Result

    Remarks:       Converts a non-expansion character to expansion.

                   Known return values:
                   0x00: Success

                   0x46: Character not found

                   0x7A: Upgrade failed

                   0x7B: Character is expired

                   0x7C: Already expansion character

    Related:       [0x18] MCP_CHARUPGRADE (C->S)

]]
[MCP_CHARUPGRADE] = { -- 0x18
	uint32("Result"),
},
--[[doc
    Message ID:    0x19

    Message Name:  MCP_CHARLIST2

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Number of characters requested
                   (DWORD) Number of characters that exist on this account
                   (WORD) Number of characters returned

                   For each character:
                   (DWORD) Expiration Date

                   (STRING) Character name

                   (STRING) Character statstring

    Remarks:       Lists characters.

                   The expiration date is a second count. To determine when the character
                   will expire, add this time to January 1 00:00:00 UTC 1970 and
                   determine the difference between that value and now (all in seconds).

                   The statstrings in this packet do not contain the product or character
                   name. Everything else is the same as a character statstring you would
                   receive from a character entering the channel.

    Related:       [0x19] MCP_CHARLIST2 (C->S)

]]
[MCP_CHARLIST2] = { -- 0x19
	uint16("Number of characters requested"),
	uint32("Number of characters that exist on this account"),
	uint16("Number of characters returned"),
	uint32("Expiration Date"),
	stringz("Character name"),
	stringz("Character statstring"),
},
-- End spackets_mcp.lua
