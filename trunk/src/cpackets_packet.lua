-- Begin cpackets_packet.lua
--[[doc
    Message ID:    0x00

    Message Name:  PACKET_IDLE

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        [blank]

    Remarks:       There is no response to this packet. You should send it once every 2-3
                   minutes.

    Related:       [0x00] PACKET_IDLE (S->C)

]]
[PACKET_IDLE] = { -- 0x00
},
--[[doc
    Message ID:    0x01

    Message Name:  PACKET_LOGON

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (STRING) BotID
                   (STRING) Bot Password

    Remarks:       This message is sent in order to identify the client to the Botnet
                   server. In order to get a BotID and password, contact Skywing[vL] by
                   visiting op [vL] on Battle.net (USEast).

    Related:       [0x01] PACKET_LOGON (S->C)

]]
[PACKET_LOGON] = { -- 0x01
	stringz("BotID"),
	stringz("Bot Password"),
},
--[[doc
    Message ID:    0x02

    Message Name:  PACKET_STATSUPDATE

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (STRING) Unique username on Battle.net
                   (STRING) Current channel on Battle.net
                   (DWORD) Battle.net server IP address
                   (STRING) DatabaseID
                   (DWORD) Cycle status (0: Not Cycling, 1: Cycling)

    Remarks:       This should be sent when any of the values in the format change.

                   The DatabaseID field also includes database password - use the format:
                   'name password'.

                   With the demise of Operators in private channels, Cycling is now
                   defunct.

                   The Username and Channel fields in this packet cannot be blank, and
                   are limited to 16 characters in length, including the null-terminator.
                   There is currently no provision in the protocol to notify Botnet that
                   you are not logged on. The generally accepted standard is to set
                   Server IP to the last Battle.net server you successfully connected to,
                   Channel to '', and Username to the last username the client used to
                   log onto Battle.net.

                   The DatabaseID field may be blank, in which case Botnet places the
                   user in the Public Database.

    Related:       [0x02] PACKET_STATSUPDATE (S->C)

]]
[PACKET_STATSUPDATE] = { -- 0x02
	stringz("Unique username on Battle.net"),
	stringz("Current channel on Battle.net"),
	uint32("Battle.net server IP address"),
	stringz("DatabaseID"),
	uint32("Cycle status"),
},
--[[doc
    Message ID:    0x03

    Message Name:  PACKET_DATABASE

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (DWORD) Command

                   Commands 1 & 2:
                   (STRING) Usermask

                   Command 3:
                   (STRING) Flags
                   (STRING) Usermask

    Remarks:       Possible values for Command:
                   1: request user database
                   2: add a database entry/modify a database entry
                   3: remove a database entry

    Related:       [0x03] PACKET_DATABASE (S->C)

]]
[PACKET_DATABASE] = { -- 0x03
	uint32("Command"),
	stringz("Usermask"),
	stringz("Flags"),
	stringz("Usermask"),
},
--[[doc
    Message ID:    0x04

    Message Name:  PACKET_MESSAGE

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (STRING) User
                   (STRING) Command

    Remarks:       Send command to bots on current database.

    Related:       [0x04] PACKET_MESSAGE (S->C)

]]
[PACKET_MESSAGE] = { -- 0x04
	stringz("User"),
	stringz("Command"),
},
--[[doc
    Message ID:    0x05

    Message Name:  PACKET_CYCLE

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (DWORD) Count
                   (STRINGLIST) Usernames to cycle

    Remarks:       Possible values for Command:
                   1: request user database
                   2: add a database entry/modify a database entry
                   3: remove a database entry

    Related:       [0x05] PACKET_CYCLE (S->C)

]]
[PACKET_CYCLE] = { -- 0x05
	uint32("Count"),
	stringz("Usernames to cycle"), -- TODO: maybe iterator
},
--[[doc
    Message ID:    0x06

    Message Name:  PACKET_USERINFO

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        [blank]

    Remarks:       This packet is sent to request a list of all users currently logged
                   onto the BotNet.

    Related:       [0x06] PACKET_USERINFO (S->C)

]]
[PACKET_USERINFO] = { -- 0x06
},
--[[doc
    Message ID:    0x07

    Message Name:  PACKET_BROADCASTMESSAGE

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (STRING) User
                   (STRING) Command

    Remarks:       Sends command to all bots on the BotNet. This functionality can only
                   be used by Administrators. If a user without Administrator privileges
                   sends this message, it is treated as PACKET_MESSAGE (0x04).

                   When a bot sends this packet, other bots recieve 0x04.

    Related:       [0x07] PACKET_USERLOGGINGOFF (S->C), [0x04] PACKET_MESSAGE (C->S)

]]
[PACKET_BROADCASTMESSAGE] = { -- 0x07
	stringz("User"),
	stringz("Command"),
},
--[[doc
    Message ID:    0x08

    Message Name:  PACKET_COMMAND

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (DWORD) Target BotID
                   (STRING) Sending User
                   (STRING) Command

    Remarks:       This packet is used to send a command to a specific client on the
                   Botnet. It results in PACKET_MESSAGE (0x04) being sent to the
                   specified client.

    Related:       [0x04] PACKET_MESSAGE (C->S)

]]
[PACKET_COMMAND] = { -- 0x08
	uint32("Target BotID"),
	stringz("Sending User"),
	stringz("Command"),
},
--[[doc
    Message ID:      0x09

    Message Name:    PACKET_CHANGEDBPASSWORD

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III, Warcraft III: The Frozen Throne

    Format:          (DWORD) Password to change (0: Read Only, 1: Full, 2: Restricted)(STRING)
                     New password

    Remarks:         Requires full access to the database.

]]
[PACKET_CHANGEDBPASSWORD] = { -- 0x09
	uint32("Password to change"),
	stringz("New password"),
},
--[[doc
    Message ID:      0x0B

    Message Name:    PACKET_BOTNETCHAT

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III, Warcraft III: The Frozen Throne

    Format:          (DWORD) Command(DWORD) Action(DWORD) For Command 2, ID of destination
                     bot - otherwise, ignored(STRING) Message

    Remarks:         Sends chat to Botnet as defined by the following fields:

                     Allowed Command values:
                     0: Message to all bots
                     1: Message to bots on current database
                     2: Message to bot specified by ID. Messages to a non-existant ID are
                     silently ignored.

                     Allowed Action values:
                     0: Talk
                     1: Emote Related Links: [S>0x0B] PACKET_BOTNETCHAT

]]
[PACKET_BOTNETCHAT] = { -- 0x0B
	uint32("Command"),
	uint32("Action"),
	uint32("For Command 2, ID of destination"),
	stringz("Message"),
},
--[[doc
    Message ID:      0x0D

    Message Name:    PACKET_ACCOUNT

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Command
					 For Command 0x00 (Login):
						 (STRING) Account name
						 (STRING) Account password
					 For Command 0x01 (Change password):
						 (STRING) Account name
						 (STRING) Old password
						 (STRING) New password
					 For Command 0x02 (Create account):
						 (STRING) Account name
						 (STRING) Account password

    Remarks:         Command values other than those listed are reserved for future use.

                     Possible CommandIDs:

                     0x00: Login
                     0x01: Change password
                     0x02: Create account 
					 
					 Related Links: [S>0x0D] PACKET_ACCOUNT

]]
[PACKET_ACCOUNT] = { -- 0x0D
	uint32("Command"),
	stringz("Account name"),
	stringz("Account password"),
	stringz("Account"),
	stringz("Old password"),
	stringz("New password"),
	stringz("Account name"),
	stringz("Account password"),
},
--[[doc
    Message ID:      0x10

    Message Name:    PACKET_CHATDROPOPTIONS

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (BYTE) Subcommand
	                 For subcommand 0:
					 (BYTE) Setting for broadcast
					 (BYTE) Setting for database
					 (BYTE) Setting for whispers
					 (BYTE) Refuse all whispers

    Remarks:         This message is used to either notify or set your chat drop options.
                     The server may notify you of your chat drop options by sending
                     subcommand 0 without the four trailing value bytes.

                     Possible values:
                     0: Allow all chat to be received (Default)
                     1: Refuse chat from users not on an account
                     2: Refuse all chat Related Links: [S>0x10] PACKET_CHATDROPOPTIONS

]]
[PACKET_CHATDROPOPTIONS] = { -- 0x10
	uint8("Subcommand"),
	uint8("Setting for broadcast"),
	uint8("Setting for database"),
	uint8("Setting for whispers"),
	uint8("Refuse all"),
},
--[[doc
    Message ID:    0x03

    Message Name:  PKT_CLIENTREQ

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft,
                   Starcraft Japanese

    Format:        (DWORD) Code

    Remarks:       This message is used to determine the latency to a game on Battle.net.

                   If code is zero, then the message is a ping request from another
                   client (and this client should respond with a PKT_CLIENTREQ using a
                   non-zero code). Otherwise, the message is a ping response.

                   In previous versions of UDP enabled clients they would use
                   GetTickCount() as the return value (the recieving end would then do
                   math on that value to get the latency).
                   Clients now use 0x01 for the value and do all the math locally, this
                   resolves time zone issues and other stuffs.

]]
-- End cpackets_packet.lua
