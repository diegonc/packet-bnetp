--[[doc
    Message ID:    0x1E

    Message Name:  W3GS_REQJOIN

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Host Counter (Game ID)
                   (DWORD) Entry Key (used in LAN)
                   (BYTE) Unknown
                   (WORD) Listen Port
                   (DWORD) Peer Key
                   (STRING) Player name
                   (DWORD) Unknown
                   (WORD) Internal Port
                   (DWORD) Internal IP

    Remarks:       A client sends this to the host to enter the game lobby.

                   The internal IP uses the Windows sockaddr_in structure.

    Related:       [0x05] W3GS_REJECTJOIN (S->C), [0x04] W3GS_SLOTINFOJOIN (S->C),
                   [0x06] W3GS_PLAYERINFO (S->C), [0x3D] W3GS_MAPCHECK (S->C)

]]
[W3GS_REQJOIN] = { -- 0x1E
	uint32("Host Counter"),
	uint32("Entry Key"),
	uint8("Unknown"),
	uint16("Listen Port"),
	uint32("Peer Key"),
	stringz("Player name"),
	uint32("Unknown"),
	uint16("Internal Port"),
	uint32("Internal IP"),
},
--[[doc
    Message ID:    0x21

    Message Name:  W3GS_LEAVEREQ

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Reason

    Remarks:       A client requests to leave.

                   Reasons:
                   0x01 PLAYERLEAVE_DISCONNECT

                   0x07 PLAYERLEAVE_LOST

                   0x08 PLAYERLEAVE_LOSTBUILDINGS

                   0x09 PLAYERLEAVE_WON

                   0x0A PLAYERLEAVE_DRAW

                   0x0B PLAYERLEAVE_OBSERVER

                   0x0D PLAYERLEAVE_LOBBY

    Related:       [0x1E] W3GS_REQJOIN (C->S), [0x1B] W3GS_LEAVERES (S->C)

]]
[W3GS_LEAVEREQ] = { -- 0x21
	uint32("Reason"),
},
--[[doc
    Message ID:    0x23

    Message Name:  W3GS_GAMELOADED_SELF

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       The client sends this to the host when they have finished loading the
                   map.

    Related:       [0x08] W3GS_PLAYERLOADED (S->C), [0x0B] W3GS_COUNTDOWN_END (S->C)

]]
[W3GS_GAMELOADED_SELF] = { -- 0x23
},
--[[doc
    Message ID:    0x26

    Message Name:  W3GS_OUTGOING_ACTION

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) CRC-32 encryption
                   (VOID) Action data

    Remarks:       A client sends this to the game host to execute an action in-game.

    Related:       [0x0C] W3GS_INCOMING_ACTION (S->C)

]]
[W3GS_OUTGOING_ACTION] = { -- 0x26
	uint32("CRC-32 encryption"),
	bytes("Action data"),
},
--[[doc
    Message ID:    0x27

    Message Name:  W3GS_OUTGOING_KEEPALIVE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Unknown

    Remarks:       This is sent to the host from each client.

                   The unknown value may be a checksum and is also used in replays.

]]
[W3GS_OUTGOING_KEEPALIVE] = { -- 0x27
	uint32("Unknown"),
},
--[[doc
    Message ID:    0x28

    Message Name:  W3GS_CHAT_TO_HOST

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) Total

                   For each total:
                   (BYTE) To player number
                   (BYTE) From player number
                   (BYTE) Flags
                   For Flag 0x10:

                   (STRING) Message

                   For Flag 0x11:

                   (BYTE) Team

                   For Flag 0x12:

                   (BYTE) Color

                   For Flag 0x13:

                   (BYTE) Race

                   For Flag 0x14:

                   (BYTE) Handicap

                   For Flag 0x20:

                   (DWORD) Extra Flags

                   (STRING) Message

    Remarks:       This is sent from the client to the host to send a message to the
                   other clients.

    Related:       [0x0F] W3GS_CHAT_FROM_HOST (S->C)

]]
[W3GS_CHAT_TO_HOST] = { -- 0x28
	uint8("Total"),
	uint8("To player number"),
	uint8("From player number"),
	uint8("Flags"),
	stringz("Message"),
	uint8("Team"),
	uint8("Color"),
	uint8("Race"),
	uint8("Handicap"),
	uint32("Extra Flags"),
	stringz("Message"),
},
--[[doc
    Message ID:    0x2F

    Message Name:  W3GS_SEARCHGAME

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Product
                   (DWORD) Version
                   (DWORD) Unknown (0)

    Remarks:       This is sent to the entire local area network to detect games.

                   Product is either WAR3 or W3XP.

    Related:       [0x30] W3GS_GAMEINFO (S->C)

]]
[W3GS_SEARCHGAME] = { -- 0x2F
	uint32("Product"),
	uint32("Version"),
	uint32("Unknown"),
},
--[[doc
    Message ID:    0x35

    Message Name:  W3GS_PING_FROM_OTHERS

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       Client requests an echo from another client (occurs every 10 seconds).

    Related:       [0x36] W3GS_PONG_TO_OTHERS (S->C)

]]
[W3GS_PING_FROM_OTHERS] = { -- 0x35
},
--[[doc
    Message ID:      0x37

    Message Name:    W3GS_CLIENTINFO

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (DWORD) Player Counter
                     (DWORD) Unknown (0)
                     (BYTE) Player number
                     (BYTE)[5] Unknown

    Remarks:         A client sends this to another client to gain information about self
                     when connected.

                     The first byte in the second unknown is possibly the status of the
                     player.

                     Packet Log:
                     F7 37 12 00
                     02 00 00 00
                     00 00 00 00
                     06
                     FF 5E 00 00 00

]]
[W3GS_CLIENTINFO] = { -- 0x37
	uint32("Player Counter"),
	uint32("Unknown"),
	uint8("Player number"),
	uint8("[5] Unknown"),
},
--[[doc
    Message ID:    0x3F

    Message Name:  W3GS_STARTDOWNLOAD

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       A client sends this to the host to initiate a map download.

    Related:       [0x3D] W3GS_MAPCHECK (S->C)

]]
[W3GS_STARTDOWNLOAD] = { -- 0x3F
},
--[[doc
    Message ID:    0x42

    Message Name:  W3GS_MAPSIZE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Unknown
                   (BYTE) Size Flag
                   (DWORD) Map Size

    Remarks:       This is sent from the client to tell the host about the map file on
                   the client's local system.

]]
[W3GS_MAPSIZE] = { -- 0x42
	uint32("Unknown"),
	uint8("Size Flag"),
	uint32("Map Size"),
},
--[[doc
    Message ID:    0x44

    Message Name:  W3GS_MAPPARTOK

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) To player number
                   (BYTE) From player number
                   (DWORD) Unknown
                   (DWORD) Chunk position in file

    Remarks:       The client sends this when it has successfully received a chunk of the
                   map file from the host client.

    Related:       [0x43] W3GS_MAPPART (S->C)

]]
[W3GS_MAPPARTOK] = { -- 0x44
	uint8("To player number"),
	uint8("From player number"),
	uint32("Unknown"),
	uint32("Chunk position in file"),
},
--[[doc
    Message ID:      0x45

    Message Name:    W3GS_MAPPARTNOTOK

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          [unknown]

    Remarks:         More research is required.

                     This is sent when downloading a map in reply to 0x43 W3GS_MAPPART and
                     a chunk of the map file does not match its CRC encryption.

    Related:         [0x43] W3GS_MAPPART (S->C), [0x44] W3GS_MAPPARTOK (C->S)

]]
[W3GS_MAPPARTNOTOK] = { -- 0x45
},
--[[doc
    Message ID:    0x46

    Message Name:  W3GS_PONG_TO_HOST

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) tickCount

    Remarks:       This is sent in response to 0x01 W3GS_HOSTECHOREQ.

                   The tickCount value is from GetTickCount().

                   Ping = (GetTickCount()-tickCount)/2
                   For the local area network, it can be 0.

    Related:       [0x01] W3GS_PING_FROM_HOST (S->C)

]]
[W3GS_PONG_TO_HOST] = { -- 0x46
	uint32("tickCount"),
},
--[[doc
    Message ID:      0x17

    Message Name:    SID_READMEMORY

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                     Starcraft, Starcraft Japanese, Diablo

    Format:          (DWORD) Request ID
                     (VOID) Memory

    Remarks:         Rudimentary hack detection system. Was never used probably due to
                     terrible implementation with little security.

                     Yes, it is possible for a PvPGN server to read EVERYTHING that is in
                     the process' memory, including sensitive information such as your
                     CDKey.

                     Found at:
                     battle!1901D470h (as of 1.16.1)

    Related:         [0x17] SID_READMEMORY (S->C)

]]
[SID_READMEMORY] = { -- 0x17
	uint32("Request ID"),
	bytes("Memory"),
},
--[[doc
    Message ID:      0x24

    Message Name:    SID_READCOOKIE

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                     Starcraft, Starcraft Japanese, Diablo

    Format:          (DWORD) First DWORD from S -> C
                     (DWORD) Second DWORD from S -> C
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

    Related:         [0x24] SID_READCOOKIE (S->C), [0x23] SID_WRITECOOKIE (S->C),
                     [0x26] SID_READUSERDATA (C->S)

]]
[SID_READCOOKIE] = { -- 0x24
	uint32("First DWORD from S -> C"),
	uint32("Second DWORD from S -> C"),
	stringz("Registry key name"),
	stringz("Registry key value"),
},
