--[[doc
    Message ID:    0x01

    Message Name:  W3GS_PING_FROM_HOST

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       This is sent every 30 seconds to make sure that the client is still
                   responsive.

    Related:       [0x46] W3GS_PONG_TO_HOST (C->S)

]]
[W3GS_PING_FROM_HOST] = { -- 0x01
},
--[[doc
    Message ID:    0x04

    Message Name:  W3GS_SLOTINFOJOIN

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (WORD) Length of Slot Info
                   (BYTE) Number of slots
                   (BYTE)[] Slot data
                   (DWORD) Random seed
                   (BYTE) Game type
                   (BYTE) Number of player slots without observers
                   (BYTE) Player number
                   (DWORD) Port
                   (DWORD) External IP
                   (DWORD) Unknown (0)
                   (DWORD) Unknown (0)

                   For each slot:
                   (BYTE) Player number
                   (BYTE) Download status
                   (BYTE) Slot status
                   (BYTE) Computer status
                   (BYTE) Team
                   (BYTE) Color
                   (BYTE) Race
                   (BYTE) Computer type
                   (BYTE) Handicap

    Remarks:       This is sent to tell the client about the game slots, upon entry of
                   the lobby.

                   Download status is a percentage of their download progress. As such,
                   this value can only be between 0 and 100.

                   Slot statuses:
                   0x00 Open

                   0x01 Closed

                   0x02 Occupied
                   If the slot is a computer, then Computer will be 0x01, otherwise
                   it will be 0x00.

                   Available races:
                   0x01 Human

                   0x02 Orc

                   0x04 Night Elf

                   0x08 Undead

                   0x20 Random

                   0x40 Fixed
                   Computer types:
                   0x00 Easy

                   0x01 Normal / Human

                   0x02 Hard

    Related:       [0x1E] W3GS_REQJOIN (C->S)

]]
[W3GS_SLOTINFOJOIN] = { -- 0x04
	uint16("Length of Slot Info"),
	uint8("Number of slots"),
	uint8("[] Slot data"),
	uint32("Random seed"),
	uint8("Game type"),
	uint8("Number of player slots without observers"),
	uint8("Player number"),
	uint32("Port"),
	uint32("External IP"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint8("Player number"),
	uint8("Download status"),
	uint8("Slot status"),
	uint8("Computer status"),
	uint8("Team"),
	uint8("Color"),
	uint8("Race"),
	uint8("Computer type"),
	uint8("Handicap"),
},
--[[doc
    Message ID:    0x05

    Message Name:  W3GS_REJECTJOIN

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Reason

    Remarks:       This is sent in a response to a request to join the game lobby and
                   indicates that the request was denied.

                   Reasons:
                   0x09 REJECTJOIN_FULL

                   0x10 REJECTJOIN_STARTED

                   0x27 REJECTJOIN_WRONGPASSWORD

    Related:       [0x1E] W3GS_REQJOIN (C->S)

]]
[W3GS_REJECTJOIN] = { -- 0x05
	uint32("Reason"),
},
--[[doc
    Message ID:      0x06

    Message Name:    W3GS_PLAYERINFO

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Server -> Client (Received)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (DWORD) Player Counter
                     (BYTE) Player number
                     (STRING) Player name
                     (WORD) Unknown (1)
                     (WORD) AF_INET (2)
                     (WORD) Port
                     (DWORD) External IP
                     (DWORD) Unknown (0)
                     (DWORD) Unknown (0)
                     (WORD) AF_INET (2)
                     (WORD) Port
                     (DWORD) Internal IP
                     (DWORD) Unknown (0)
                     (DWORD) Unknown (0)

    Remarks:         Tells a client about a player's information.

                     The external and internal IP are always zero for the host.

                     NOTE: This packet needs a better structure in the Format. Until then,
                     you will have to deal with the unorganized fields.

]]
[W3GS_PLAYERINFO] = { -- 0x06
	uint32("Player Counter"),
	uint8("Player number"),
	stringz("Player name"),
	uint16("Unknown"),
	uint16("AF_INET"),
	uint16("Port"),
	uint32("External IP"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint16("AF_INET"),
	uint16("Port"),
	uint32("Internal IP"),
	uint32("Unknown"),
	uint32("Unknown"),
},
--[[doc
    Message ID:    0x07

    Message Name:  W3GS_PLAYERLEFT

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) Player number
                   (DWORD) Reason

    Remarks:       This is received from the game host when a player leaves.

                   Reasons:
                   0x01 PLAYERLEAVE_DISCONNECT

                   0x07 PLAYERLEAVE_LOST

                   0x08 PLAYERLEAVE_LOSTBUILDINGS

                   0x09 PLAYERLEAVE_WON

                   0x0A PLAYERLEAVE_DRAW

                   0x0B PLAYERLEAVE_OBSERVER

                   0x0D PLAYERLEAVE_LOBBY

]]
[W3GS_PLAYERLEFT] = { -- 0x07
	uint8("Player number"),
	uint32("Reason"),
},
--[[doc
    Message ID:    0x08

    Message Name:  W3GS_PLAYERLOADED

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) Player number

    Remarks:       Sent to all other clients in-game to notify that a player has finished
                   loading.

]]
[W3GS_PLAYERLOADED] = { -- 0x08
	uint8("Player number"),
},
--[[doc
    Message ID:    0x09

    Message Name:  W3GS_SLOTINFO

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (WORD) Length of Slot Info

                   Slot Info:
                   (BYTE) Player number
                   (BYTE) Download status
                   (BYTE) Slot status
                   (BYTE) Computer status
                   (BYTE) Team
                   (BYTE) Color
                   (BYTE) Race
                   (BYTE) Computer type
                   (BYTE) Handicap

    Remarks:       This is sent for slot updates.

                   The length of slot info should always be 0x0B.

    Related:       [0x04] W3GS_SLOTINFOJOIN (S->C)

]]
[W3GS_SLOTINFO] = { -- 0x09
	uint16("Length of Slot Info"),
	uint8("Player number"),
	uint8("Download status"),
	uint8("Slot status"),
	uint8("Computer status"),
	uint8("Team"),
	uint8("Color"),
	uint8("Race"),
	uint8("Computer type"),
	uint8("Handicap"),
},
--[[doc
    Message ID:    0x0A

    Message Name:  W3GS_COUNTDOWN_START

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       The game has begun the countdown to start.

                   The official clients countdown from 5 seconds, however it is possible
                   to use any time you wish. For example, the GHost++ bot uses 10 seconds
                   when auto-hosted, but 5 seconds when started using an administrative
                   command.

    Related:       [0x0B] W3GS_COUNTDOWN_END (S->C)

]]
[W3GS_COUNTDOWN_START] = { -- 0x0A
},
--[[doc
    Message ID:    0x0B

    Message Name:  W3GS_COUNTDOWN_END

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       The game has finished the countdown and has now started. Players
                   should see a loading screen for the map once this is received.

                   0x10 W3GS_COUNTDOWN_START should be received before this packet is,
                   even if there is no countdown.

    Related:       [0x0A] W3GS_COUNTDOWN_START (S->C)

]]
[W3GS_COUNTDOWN_END] = { -- 0x0B
},
--[[doc
    Message ID:    0x0C

    Message Name:  W3GS_INCOMING_ACTION

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (WORD) Send interval
                   (WORD) CRC-16 encryption

                   For each action:
                   (BYTE) Player number
                   (WORD) Length of action data
                   (VOID) Action data

    Remarks:       Informs the client about an action in-game.

    Related:       [0x26] W3GS_OUTGOING_ACTION (C->S)

]]
[W3GS_INCOMING_ACTION] = { -- 0x0C
	uint16("Send interval"),
	uint16("CRC-16 encryption"),
	uint8("Player number"),
	uint16 {"Length of action data", key="action_length"},
	bytes("Action data", "key", "action_length"),
},
--[[doc
    Message ID:    0x0F

    Message Name:  W3GS_CHAT_FROM_HOST

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) Player count
                   (BYTE)[] Player numbers that will receive the message
                   (BYTE) Player number that sent the message
                   (BYTE) Flags
                   (DWORD) Extra Flags
                   (STRING) Message

    Remarks:       This is sent to the clients to print a message on the screen from
                   another player.

]]
[W3GS_CHAT_FROM_HOST] = { -- 0x0F
	uint8("Player count"),
	uint8("[] Player numbers that will receive the message"),
	uint8("Player number that sent the message"),
	uint8("Flags"),
	uint32("Extra Flags"),
	stringz("Message"),
},
--[[doc
    Message ID:    0x1B

    Message Name:  W3GS_LEAVERES

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       This is the response to 0x21 W3GS_LEAVEREQ.

                   You will leave the game once the connection is terminated.

    Related:       [0x21] W3GS_LEAVEREQ (C->S)

]]
[W3GS_LEAVERES] = { -- 0x1B
},
--[[doc
    Message ID:    0x2F

    Message Name:  W3GS_SEARCHGAME

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Product
                   (DWORD) Version
                   (DWORD) Unknown

    Remarks:       This is a reply to a client's request for games.

    Related:       [0x2F] W3GS_SEARCHGAME (C->S)

]]
[W3GS_SEARCHGAME] = { -- 0x2F
	uint32("Product"),
	uint32("Version"),
	uint32("Unknown"),
},
--[[doc
    Message ID:    0x30

    Message Name:  W3GS_GAMEINFO

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Product
                   (DWORD) Host Counter
                   (DWORD) Players In Game
                   (STRING) Game name
                   (BYTE) Unknown (0)
                   (STRING) Statstring
                   (DWORD) Slots total
                   (BYTE)[] Game Type Info
                   (DWORD) Slots available
                   (DWORD) Time since creation
                   (WORD) Game Port

    Remarks:       This is sent every 5 seconds over a UDP broadcast to update the local
                   area network about the game.

                   This is also sent when a client clicks on the game in a list.

    Related:       [0x2F] W3GS_SEARCHGAME (C->S)

]]
[W3GS_GAMEINFO] = { -- 0x30
	uint32("Product"),
	uint32("Host Counter"),
	uint32("Players In Game"),
	stringz("Game name"),
	uint8("Unknown"),
	stringz("Statstring"),
	uint32("Slots total"),
	uint8("[] Game Type Info"),
	uint32("Slots available"),
	uint32("Time since creation"),
	uint16("Game Port"),
},
--[[doc
    Message ID:    0x31

    Message Name:  W3GS_CREATEGAME

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Product
                   (DWORD) Host Counter
                   (DWORD) Players In Game

    Remarks:       Notifies the local area network that a game was created.

]]
[W3GS_CREATEGAME] = { -- 0x31
	uint32("Product"),
	uint32("Host Counter"),
	uint32("Players In Game"),
},
--[[doc
    Message ID:    0x32

    Message Name:  W3GS_REFRESHGAME

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Host Counter
                   (DWORD) Players In Game
                   (DWORD) Slots available

    Remarks:       Notifies the local area network about a game (occurs every 5 seconds
                   or refresh slots).

]]
[W3GS_REFRESHGAME] = { -- 0x32
	uint32("Host Counter"),
	uint32("Players In Game"),
	uint32("Slots available"),
},
--[[doc
    Message ID:    0x33

    Message Name:  W3GS_DECREATEGAME

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Host Counter

    Remarks:       Notifies the local area network that a game is no longer being hosted.

]]
[W3GS_DECREATEGAME] = { -- 0x33
	uint32("Host Counter"),
},
--[[doc
    Message ID:    0x36

    Message Name:  W3GS_PONG_TO_OTHERS

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       This is sent in response to an echo from another client.

    Related:       [0x35] W3GS_PING_FROM_OTHERS (C->S)

]]
[W3GS_PONG_TO_OTHERS] = { -- 0x36
},
--[[doc
    Message ID:    0x3D

    Message Name:  W3GS_MAPCHECK

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Unknown
                   (STRING) File Path
                   (DWORD) File size
                   (DWORD) Map info
                   (DWORD) File CRC encryption
                   (DWORD) File SHA-1 hash

    Remarks:       This is sent from the game host to a client that just joined to check
                   if the client has the map.

                   The map info is the actual CRC and the other CRC is actually an "xoro"
                   value.

]]
[W3GS_MAPCHECK] = { -- 0x3D
	uint32("Unknown"),
	stringz("File Path"),
	uint32("File size"),
	uint32("Map info"),
	uint32("File CRC encryption"),
	uint32("File SHA-1 hash"),
},
--[[doc
    Message ID:    0x3F

    Message Name:  W3GS_STARTDOWNLOAD

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Unknown
                   (BYTE) Player number

    Remarks:       This tells the client that it is now in the downloading state and
                   should expect chunks of file data.

    Related:       [0x42] W3GS_MAPSIZE (C->S)

]]
[W3GS_STARTDOWNLOAD] = { -- 0x3F
	uint32("Unknown"),
	uint8("Player number"),
},
--[[doc
    Message ID:    0x43

    Message Name:  W3GS_MAPPART

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) To player number
                   (BYTE) From player number
                   (DWORD) Unknown (0x01)
                   (DWORD) Chunk position in file
                   (DWORD) CRC-32 encryption
                   (BYTE)[1442] Data

    Remarks:       This is received when you are downloading a map from the host.

                   You can calculate how many more chunks you have left based on the file
                   size and the chunk position in file. You are done downloading when the
                   chunk position in file (plus the size of the chunk) matches the file
                   size received in 0x42 W3GS_MAPSIZE.

                   If the data does not match the CRC-32, you should send the host 0x45
                   W3GS_MAPPARTNOTOK, otherwise you should always send 0x44
                   W3GS_MAPPARTOK in reply to this packet.

    Related:       [0x42] W3GS_MAPSIZE (C->S), [0x3F] W3GS_STARTDOWNLOAD (S->C),
                   [0x44] W3GS_MAPPARTOK (C->S)

]]
[W3GS_MAPPART] = { -- 0x43
	uint8("To player number"),
	uint8("From player number"),
	uint32("Unknown"),
	uint32("Chunk position in file"),
	uint32("CRC-32 encryption"),
	uint8("[1442] Data"),
},
--[[doc
    Message ID:    0x48

    Message Name:  W3GS_INCOMING_ACTION2

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (WORD) Send interval
                   (WORD) CRC-16 encryption

                   For each action:
                   (BYTE) Player number
                   (WORD) Length of action data
                   (VOID) Action data

    Remarks:       Informs the client about an action in-game.

                   This is used when there is not enough room inside 0x0C
                   W3GS_INCOMING_ACTION. If there are 1452 actions or more, then this
                   packet should be used instead.

    Related:       [0x0C] W3GS_INCOMING_ACTION (S->C)

]]
[W3GS_INCOMING_ACTION2] = { -- 0x48
	uint16("Send interval"),
	uint16("CRC-16 encryption"),
	uint8("Player number"),
	uint16("Length of action data"),
	bytes("Action data"),
},
--[[doc
    Message ID:      0x17

    Message Name:    SID_READMEMORY

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                     Starcraft, Starcraft Japanese, Diablo

    Format:          (DWORD) Request ID
                     (DWORD) Address
                     (DWORD) Length

    Remarks:         Rudimentary hack detection system. Was never used probably due to
                     terrible implementation with little security.

                     Yes, it is possible for a PvPGN server to read EVERYTHING that is in
                     the process' memory, including sensitive information such as your
                     CDKey.

                     Found at:
                     battle!1901D470h (as of 1.16.1)

    Related:         [0x17] SID_READMEMORY (C->S)

]]
[SID_READMEMORY] = { -- 0x17
	uint32("Request ID"),
	uint32("Address"),
	uint32("Length"),
},
--[[doc
    Message ID:      0x20

    Message Name:    SID_ANNOUNCEMENT

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                     Starcraft, Starcraft Japanese, Diablo

    Format:          (STRING) Text

    Remarks:         Very simply prints out text with the string at 1903B9FBh (the default
                     string, used anyway if the username field is NULL in the chat event
                     struct -- currently a single 0x7F char) as the username.

                     Used to send announcements and arbitrary messages to the user, but
                     this was soon superseded by SID_CHAT subcommands such as EID_INFO,
                     EID_ERROR, and EID_BROADCAST. Printed out with the same color and
                     style as an EID_BROADCAST.

                     Found at:
                     battle!1901DDA0h (as of 1.16.1)

    Related:         [0x0F] SID_CHATEVENT (S->C)

]]
[SID_ANNOUNCEMENT] = { -- 0x20
	stringz("Text"),
},
--[[doc
    Message ID:      0x23

    Message Name:    SID_WRITECOOKIE

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                     Starcraft, Starcraft Japanese, Diablo

    Format:          (DWORD) unknown/unparsed -- Flags, Request ID?
                     (DWORD) unknown/unparsed -- Timestamp?
                     (STRING) Registry key name
                     (STRING) Registry key value

    Remarks:         Much like a website cookie, simply stores some arbitrary string to a
                     'cookie jar' to save preferences et al. which can be retrieved later
                     by the server.

                     Not used because it was quickly discovered that storing preferences
                     produces less problems and were faster by storing them server-side,
                     associating them with the account. It is somewhat curious that these
                     packet IDs are close to SID_PROFILE/SID_WRITEPROFILE (0x26 & 0x27).

                     Found at: battle!190216FBh and battle!1901D660h, respectively.

    Related:         [0x24] SID_READCOOKIE (S->C), [0x24] SID_READCOOKIE (C->S),
                     [0x27] SID_WRITEUSERDATA (C->S)

]]
[SID_WRITECOOKIE] = { -- 0x23
	uint32("unknown/unparsed -- Flags, Request ID?"),
	uint32("unknown/unparsed -- Timestamp?"),
	stringz("Registry key name"),
	stringz("Registry key value"),
},
--[[doc
    Message ID:      0x24

    Message Name:    SID_READCOOKIE

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                     Starcraft, Diablo

    Format:          (DWORD) Echoed back, Request ID?
                     (DWORD) Echoed back, Timestamp?
                     (STRING) Registry key name

    Remarks:         Much like a website cookie, simply stores some arbitrary string to a
                     'cookie jar' to save preferences et al. which can be retrieved later
                     by the server.

                     Not used because it was quickly discovered that storing preferences
                     produces less problems and were faster by storing them server-side,
                     associating them with the account. It is somewhat curious that these
                     packet IDs are close to SID_PROFILE/SID_WRITEPROFILE (0x26 & 0x27).

                     Found at: battle!190216FBh and battle!1901D660h, respectively.

    Related:         [0x24] SID_READCOOKIE (C->S), [0x23] SID_WRITECOOKIE (S->C),
                     [0x26] SID_READUSERDATA (S->C)

]]
[SID_READCOOKIE] = { -- 0x24
	uint32("Echoed back, Request ID?"),
	uint32("Echoed back, Timestamp?"),
	stringz("Registry key name"),
},
