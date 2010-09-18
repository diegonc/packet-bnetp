-- Begin spackets_pkt.lua
-- Battle.net UDP Messages
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
[PKT_SERVERPING] = { -- 0x05
	uint32("UDP Code"),
},
--[[doc
    Message ID:    0x07

    Message Name:  PACKET_USERLOGGINGOFF

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        (DWORD) Bot id

    Remarks:       This message is sent from the server when another client has
                   disconnected from the BotNet.

    Related:       [0x07] PACKET_BROADCASTMESSAGE (C->S)

]]
[PACKET_USERLOGGINGOFF] = { -- 0x07
	uint32("Bot id"),
},
--[[doc
    Message ID:    0x00

    Message Name:  SID_NULL

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        [blank]

    Remarks:       Keeps the connection alive. Clients do not need to respond to this
                   message.

    Related:       [0x00] SID_NULL (C->S)

]]
-- End spackets_pkt.lua
