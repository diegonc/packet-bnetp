-- Begin cpackets_pkt.lua
-- Battle.net UDP Messages
[PKT_CLIENTREQ] = { -- 0x03
	uint32("Code"),
},
--[[doc
    Message ID:    0x07

    Message Name:  PKT_KEEPALIVE

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (DWORD) Tick count

    Remarks:       This packet is used to keep firewalls happy and improve NAT support.
                   It should be sent every 3-5 minutes.

]]
[PKT_KEEPALIVE] = { -- 0x07
	uint32("Tick count"),
},
--[[doc
    Message ID:    0x08

    Message Name:  PKT_CONNTEST

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft II, Starcraft

    Format:        (DWORD) Server Token

    Remarks:       This packet is sent to establish that the client supports UDP. In
                   particular, when the client is using a non-standard port (e.g. not
                   port 6112), this message is used to tell the server where it should
                   send PKT_CONNTEST messages.

                   This message should be sent in response to SID_LOGONCHALLENGE.

    Related:       [0x28] SID_LOGONCHALLENGE (S->C)

]]
[PKT_CONNTEST] = { -- 0x08
	uint32("Server Token"),
},
--[[doc
    Message ID:    0x09

    Message Name:  PKT_CONNTEST2

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (DWORD) Server Token
                   (DWORD) UDP Token*

    Remarks:       This packet is sent to establish that the client supports UDP. In
                   particular, when the client is using a non-standard port (e.g. not
                   port 6112), this message is used to tell the server where it should
                   send PKT_CONNTEST2 messages.

                   * UDP Value is received from Battle.net in DWORD 3 of SID_AUTH_INFO,
                   or DWORD 1 of SID_LOGONCHALLENGEEX.

                   This message should be sent in response to either SID_LOGONCHALLENGEEX
                   or SID_AUTH_INFO.

    Related:       [0x50] SID_AUTH_INFO (S->C), [0x1D] SID_LOGONCHALLENGEEX (S->C)

]]
[PKT_CONNTEST2] = { -- 0x09
	uint32("Server Token"),
	uint32("UDP Token"),
},
-- End cpackets_pkt.lua
