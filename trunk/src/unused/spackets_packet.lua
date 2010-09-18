-- Begin spackets_packet.lua
-- BotNet Messages
--[[doc
    Message ID:    0x00

    Message Name:  PACKET_IDLE

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        [blank]

    Remarks:       BotNet sends this to the client when the connection has been idle. No
                   response is needed.

    Related:       [0x00] PACKET_IDLE (C->S)

]]
[PACKET_IDLE] = { -- 0x00
},
--[[doc
    Message ID:    0x01

    Message Name:  PACKET_LOGON

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        (DWORD) Result

    Remarks:       Possible values:
                   0: Failed
                   1: Succeeded

    Related:       [0x01] PACKET_LOGON (C->S)

]]
[PACKET_LOGON] = { -- 0x01
	uint32("Result"),
},
--[[doc
    Message ID:    0x02

    Message Name:  PACKET_STATSUPDATE

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        (DWORD) Result

    Remarks:       Possible values:
                   0: Failed
                   1: Succeeded

    Related:       [0x02] PACKET_STATSUPDATE (C->S)

]]
[PACKET_STATSUPDATE] = { -- 0x02
	uint32("Result"),
},
--[[doc
    Message ID:    0x03

    Message Name:  PACKET_DATABASE

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        (DWORD) command

                   Command 2:
                   (STRING) usermask
                   (STRING) flags

                   Command 3:
                   (STRING) usermask

    Remarks:       Response to C>0x03.

                   Possible values for Command:
                   2: New access list user/modify existing access list user.
                   3: Remove a database entry

    Related:       [0x03] PACKET_DATABASE (C->S)

]]
[PACKET_DATABASE] = { -- 0x03
	uint32("command"),
	stringz("usermask"),
	stringz("flags"),
	stringz("usermask"),
},
--[[doc
    Message ID:    0x04

    Message Name:  PACKET_MESSAGE

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        (STRING) User
                   (STRING) Command

    Remarks:       Command from bot on current database.

    Related:       [0x04] PACKET_MESSAGE (C->S)

]]
[PACKET_MESSAGE] = { -- 0x04
	stringz("User"),
	stringz("Command"),
},
--[[doc
    Message ID:    0x05

    Message Name:  PACKET_CYCLE

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        (STRING) Channel

    Remarks:       Contains encryption result and data to be sent to Battle.net.

    Related:       [0x05] PACKET_CYCLE (C->S)

]]
[PACKET_CYCLE] = { -- 0x05
	stringz("Channel"),
},
--[[doc
    Message ID:    0x06

    Message Name:  PACKET_USERINFO

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        (DWORD) Bot number
                   (STRING) Bot name
                   (STRING) Bot channel
                   (DWORD) Bot server

                   Added in Revision 0x02:
                   (STRING) Unique account name

                   Added in Revision 0x03:
                   (STRING) Current database

    Remarks:       This packet is sent to request a list of all users currently logged
                   onto the BotNet.

    Related:       [0x06] PACKET_USERINFO (C->S)

]]
[PACKET_USERINFO] = { -- 0x06
	uint32("Bot number"),
	stringz("Bot name"),
	stringz("Bot channel"),
	uint32("Bot server"),
	stringz("Unique account name"),
	stringz("Current database"),
},
--[[doc
    Message ID:      0x0A

    Message Name:    PACKET_BOTNETVERSION

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Starcraft, Starcraft Broodwar, Warcraft III,
                     Warcraft III: The Frozen Throne

    Format:          (DWORD) Server Version

    Remarks:         Version information:
                     Version 1 supports all packets 0x00 through 0x0B.
                     Version 2 supports messages 0x0C and 0x0D.
                     Version 3 adds the 'Database' field to PACKET_USERINFO (0x06).

                     Version 4 is currently under development by [vL]Kp. It contains
                     significant improvements over Version 3, including measures to make it
                     easier for bot developers to troubleshoot their clients. A test
                     version of the server is running at www.valhallalegends.com on port
                     0x5554 . Additions to the Botnet protocol will not be documented here
                     until they are finalised, however, current documentation can be found
                     here. It is subject to change without notice. Developers should feel
                     free to add support for for Version 4 to their bots, are welcome to
                     use the test server and are encouraged to provide feedback. Related
                     Links: [S>0x06] PACKET_USERINFO

]]
[PACKET_BOTNETVERSION] = { -- 0x0A
	uint32("Server Version"),
},
--[[doc
    Message ID:      0x0B

    Message Name:    PACKET_BOTNETCHAT

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Command(DWORD) Action(DWORD) ID of source bot(STRING) Message

    Remarks:         Possible Command values:
                     0: Message to all bots
                     1: Message to bots on current database
                     2: Message from a bot specified by ID.

                     Possible Action values:
                     0: Talk
                     1: Emote Related Links: [C>0x0B] PACKET_BOTNETCHAT

]]
[PACKET_BOTNETCHAT] = { -- 0x0B
	uint32("Command"),
	uint32("Action"),
	uint32("ID of source bot"),
	stringz("Message"),
},
--[[doc
    Message ID:      0x0D

    Message Name:    PACKET_ACCOUNT

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Command(DWORD) Result (0: Failed, 1: Succeeded)

    Remarks:         Command indicates the commandID that's being responded to. Related
                     Links: [C>0x0D] PACKET_ACCOUNT

]]
[PACKET_ACCOUNT] = { -- 0x0D
	uint32("Command"),
	uint32("Result"),
},
--[[doc
    Message ID:      0x10

    Message Name:    PACKET_CHATDROPOPTIONS

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Unknown

    Format:          (BYTE) SubcommandFor subcommand 0:(BYTE) Setting for broadcast(BYTE)
                     Setting for database(BYTE) Setting for whispers(BYTE) Refuse all
                     whispers

    Remarks:         This message is only received if it is first sent to the server.

                     Possible values:
                     0: Allow all chat to be received (Default)
                     1: Refuse chat from users not on an account
                     2: Refuse all chat Related Links: [C>0x10] PACKET_CHATDROPOPTIONS

]]
[PACKET_CHATDROPOPTIONS] = { -- 0x10
	uint8("SubcommandFor subcommand 0:"),
	uint8("Setting for broadcast"),
	uint8("Setting for database"),
	uint8("Setting for whispers"),
	uint8("Refuse all"),
},
--[[doc
    Message ID:    0x05

    Message Name:  PKT_SERVERPING

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        (DWORD) UDP Code

    Remarks:       This packet contains the UDP code to be sent to Battle.net in
                   SID_UDPPINGRESPONSE (0x14).

    Related:       [0x14] SID_UDPPINGRESPONSE (C->S)

]]
-- End spackets_packet.lua
