-- Begin spackets_bnls.lua
--[[doc
    Message ID:    0x01

    Message Name:  BNLS_CDKEY

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        (BOOLEAN) Result

                   (DWORD) Client Token

                   (DWORD[9]) CD key data for SID_AUTH_CHECK

    Remarks:       Contains encryption result and data to be sent to Battle.net.

    Related:       [0x51] SID_AUTH_CHECK (C->S), [0x01] BNLS_CDKEY (C->S)

]]
[BNLS_CDKEY] = { -- 0x01
	uint32("Result", nil, Descs.YesNo),
	uint32("Client Token", base.HEX),
	array("CD key data for SID_AUTH_CHECK", uint32, 9),
},
--[[doc
    Message ID:    0x02

    Message Name:  BNLS_LOGONCHALLENGE

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft,
                   Starcraft Japanese

    Format:        (DWORD)[8] Data for SID_AUTH_ACCOUNTLOGON

    Remarks:       Contains data for SID_AUTH_ACCOUNTLOGON (0x53).

    Related:       [0x53] SID_AUTH_ACCOUNTLOGON (C->S), [0x02] BNLS_LOGONCHALLENGE (C->S)

]]
[BNLS_LOGONCHALLENGE] = { -- 0x02
	array("Data for SID_AUTH_ACCOUNTLOGON", uint32, 8),
},
--[[doc
    Message ID:    0x03

    Message Name:  BNLS_LOGONPROOF

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD)[5] Data for SID_AUTH_ACCOUNTLOGONPROOF

    Remarks:       Data for SID_AUTH_ACCOUNTLOGONPROOF (0x54).

    Related:       [0x54] SID_AUTH_ACCOUNTLOGONPROOF (C->S),
                   [0x03] BNLS_LOGONPROOF (C->S)

]]
[BNLS_LOGONPROOF] = { -- 0x03
	array("Data for SID_AUTH_ACCOUNTLOGONPROOF", uint32, 5),
},
--[[doc
    Message ID:      0x04

    Message Name:    BNLS_CREATEACCOUNT

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Starcraft, Starcraft Broodwar, Diablo II, Diablo, Warcraft III,
                     Warcraft III: The Frozen Throne

    Format:          (DWORD[16]) Data for Data for SID_AUTH_ACCOUNTCREATE (0x52).

    Remarks:         This message will give you data you need for SID_AUTH_ACCOUNTCREATE
                     (0x52). Related Links: [C>0x52] SID_AUTH_ACCOUNTCREATE, [C>0x04]
                     BNLS_CREATEACCOUNT

]]
[BNLS_CREATEACCOUNT] = { -- 0x04
	array("Data for Data for SID_AUTH_ACCOUNTCREATE", uint32, 16),
},
--[[doc
    Message ID:      0x05

    Message Name:    BNLS_CHANGECHALLENGE

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (DWORD[8]) Data for SID_AUTH_ACCOUNTCHANGE (0x55).

    Remarks:         This message will give you data you need for SID_AUTH_ACCOUNTCHANGE
                     (0x55). Related Links: [C>0x55] SID_AUTH_ACCOUNTCHANGE, [C>0x05]
                     BNLS_CHANGECHALLENGE

]]
[BNLS_CHANGECHALLENGE] = { -- 0x05
	array("Data for SID_AUTH_ACCOUNTCHANGE", uint32, 8),
},
--[[doc
    Message ID:      0x06

    Message Name:    BNLS_CHANGEPROOF

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Warcraft III, Warcraft III: The Frozen Throne

    Format:          (DWORD[21]) Data for SID_AUTH_ACCOUNTCHANGEPROOF (0x56).

    Remarks:         This message contains the data to send in SID_AUTH_ACCOUNTCHANGEPROOF
                     (0x56). Related Links: [C>0x56] SID_AUTH_ACCOUNTCHANGEPROOF, [C>0x06]
                     BNLS_CHANGEPROOF

]]
[BNLS_CHANGEPROOF] = { -- 0x06
	array("Data for SID_AUTH_ACCOUNTCHANGEPROOF", uint32, 21),
},
--[[doc
    Message ID:      0x07

    Message Name:    BNLS_UPGRADECHALLENGE

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Starcraft Shareware, Starcraft Japanese, Diablo Shareware, Diablo,
                     Warcraft II

    Format:          (BOOL) Success code.

    Remarks:         If the success code is TRUE, you may send SID_AUTH_ACCOUNTUPGRADE
                     (0x57).
                     Currently, no error conditions are defined, so this is always TRUE.
                     Related Links: [C>0x57] SID_AUTH_ACCOUNTUPGRADE, [C>0x07]
                     BNLS_UPGRADECHALLENGE

]]
[BNLS_UPGRADECHALLENGE] = { -- 0x07
	uint32("Success code", nil, Descs.YesNo),
},
--[[doc
    Message ID:      0x08

    Message Name:    BNLS_UPGRADEPROOF

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Warcraft III, Warcraft III: The Frozen Throne

    Format:          (DWORD[22]) Data for SID_AUTH_ACCOUNTUPGRADEPROOF (0x58).

    Remarks:         This message contains the data to send in SID_AUTH_ACCOUNTUPGRADEPROOF
                     (0x58). Related Links: [C>0x08] BNLS_UPGRADEPROOF

]]
[BNLS_UPGRADEPROOF] = { -- 0x08
	array("Data for SID_AUTH_ACCOUNTUPGRADEPROOF", uint32, 22),
},
--[[doc
    Message ID:      0x09

    Message Name:    BNLS_VERSIONCHECK

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (BOOLEAN) Success 
					 If Success is TRUE:
					 (DWORD) Version.
					 (DWORD) Checksum.
					 (STRING) Version check stat string.

    Remarks:         This message contains the information required for the specified
                     product.

                     Success is TRUE if successful, FALSE otherwise. If this is FALSE,
                     there is no more data in this message. Related Links: [C>0x09]
                     BNLS_VERSIONCHECK

]]
[BNLS_VERSIONCHECK] = { -- 0x09
	uint32("Success", nil, Descs.YesNo),
	uint32("Version"),
	uint32("Checksum"),
	stringz("Version check stat string"),
},
--[[doc
    Message ID:      0x0A

    Message Name:    BNLS_CONFIRMLOGON

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo, Diablo II

    Format:          (BOOLEAN) Success

    Remarks:         Success is TRUE if the server knows your password, FALSE otherwise. If
                     this is FALSE, the Battle.net connection should be closed by the
                     client. Related Links: [C>0x0A] BNLS_CONFIRMLOGON

]]
[BNLS_CONFIRMLOGON] = { -- 0x0A
	uint32("Success", nil, Descs.YesNo),
},
--[[doc
    Message ID:      0x0B

    Message Name:    BNLS_HASHDATA

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         All Products

    Format:         (DWORD[5]) The data hash.
					Optional:
					(DWORD) Cookie. Same as the cookie from the request.

    Remarks:         This message contains the hashed data. Related Links: [C>0x0B]
                     BNLS_HASHDATA

]]
[BNLS_HASHDATA] = { -- 0x0B
	array("The data hash.Optional:", uint32, 5),
	uint32("Cookie"),
},
--[[doc
    Message ID:      0x0C

    Message Name:    BNLS_CDKEY_EX

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         All Products

    Format:          (DWORD) Cookie. 
					 (BYTE) Number of CD-keys requested.
					 (BYTE) Number of successfully ecrypted CD-keys .
					 (DWORD) Bit mask .
					 
					 For each successful CD Key:
					 (DWORD) Client session key.
					 (DWORD[9]) CD-key data.

    Remarks:         When the flags don't contain CDKEY_OLD_STYLE_RESPONSES (0x08), the
                     response is this message.

                     Cookie is the same as the value sent to the server in the request.

                     The bit mask field contains the success code for each CD-key. Each bit
                     of the 32 bits in this DWORD is 1 for success or 0 for failure. The
                     least significant bit specifies the success code of the first CD-key
                     provided. Bits that exceed the amount of CD-keys provided are set to 0
                     Related Links: [C>0x0C] BNLS_CDKEY_EX

]]
[BNLS_CDKEY_EX] = { -- 0x0C
	uint32("Cookie"),
	uint8("Number of CD-keys requested"),
	uint8("Number of successfully ecrypted CD-keys"),
	uint32("Bit mask"),
	-- For each successful CD Key:
	uint32("Client session key"),
	array("CD-key data", uint32, 9),
},
--[[doc
    Message ID:      0x0D

    Message Name:    BNLS_CHOOSENLSREVISION

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (BOOLEAN) Success code. (32-bit)

    Remarks:         If the Success code is TRUE, the revision number was recognized by the
                     server and will be used. If it's FALSE, the revision number was
                     rejected by the server and this request is ignored.

                     NOTE: The default revision number is 1.
                     Therefore, if Battle.net reports a revision number of 1, this message
                     may be omitted. Related Links: [C>0x0D] BNLS_CHOOSENLSREVISION

]]
[BNLS_CHOOSENLSREVISION] = { -- 0x0D
	uint32("Success code", nil, Descs.YesNo),
},
--[[doc
    Message ID:      0x0E

    Message Name:    BNLS_AUTHORIZE

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Server code.

    Remarks:         If the bot ID isn't recognized by the server, then this message is
                     still sent as backwards compatibility with the previous version of
                     BNLS, which required authorization.

                     The client should calculate the checksum of the auth password and the
                     server code using the [BNLS Checksum Algorithm]. The result is sent in
                     BNLS_AUTHORIZEPROOF (0x0F). Related Links: [S>0x0F]
                     BNLS_AUTHORIZEPROOF, [C>0x0E] BNLS_AUTHORIZE

]]
[BNLS_AUTHORIZE] = { -- 0x0E
	uint32("Server code"),
},
--[[doc
    Message ID:      0x0F

    Message Name:    BNLS_AUTHORIZEPROOF

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         All Products

    Format:          (DWORD) Status code.

    Remarks:         If the client sent a valid account name, but the password checksum is
                     incorrect, the connection is terminated. Otherwise, this response is
                     sent. The following status codes are defined:

                     0x00: Authorized
                     0x01: Unauthorized

                     View consts: [pas cpp vb]

                     Authorized means the login was performed as a registered account.
                     Unauthorized means the bot ID provided was invalid, so an anonymous
                     login was performed instead.

                     This indicates a success condition, and the client is now allowed to
                     send other messages. More status codes may be added in the future.
                     Related Links: [C>0x0F] BNLS_AUTHORIZEPROOF

]]
[BNLS_AUTHORIZEPROOF] = { -- 0x0F
	uint32("Status code"),
},
--[[doc
    Message ID:      0x10

    Message Name:    BNLS_REQUESTVERSIONBYTE

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Productif Product is nonzero:(DWORD) Version byte

    Remarks:         On failure, Product is 0. On success, this is equal to the requested
                     Product.

                     If Product is 0, the Version byte DWORD is not included in the
                     message.

                     Possible values for Product: View consts: [pas cpp vb] Related Links:
                     [C>0x10] BNLS_REQUESTVERSIONBYTE

]]
[BNLS_REQUESTVERSIONBYTE] = { -- 0x10
	uint32{label="Product", key="prod"},
	oldwhen{
		-- condition=function(...) return arg[2].packet.prod ~= 0 end,
		condition = Cond.nequals("prod", 0),
		block = {
			uint32("Version byte", base.HEX)
		},
	}
},
--[[doc
    Message ID:      0x11

    Message Name:    BNLS_VERIFYSERVER

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (BOOLEAN) Success. (32-bit)

    Remarks:         If Success is TRUE, the signature matches the server's IP - if FALSE,
                     it does not. Related Links: [C>0x11] BNLS_VERIFYSERVER

]]
[BNLS_VERIFYSERVER] = { -- 0x11
	uint32("Success", nil, Descs.YesNo),
},
--[[doc
    Message ID:      0x12

    Message Name:    BNLS_RESERVESERVERSLOTS

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Number of slots reserved

    Remarks:         This may be equal to the number of slots requested, although it does
                     not necessarily have to be the same value.
                     Valid slot indicies are in the range of [0, Number of slots reserved -
                     1]. Each slot stores state information about a NLS checking operation.
                     A logon checking session must be finished on the same slot on which it
                     was started. If a logon checking session is abandoned before it is
                     completed, no special action is required. Starting a new logon
                     checking session on a slot overwrites all previous state information.
                     A logon checking session cannot be resumed if the connection to BNLS
                     is interrupted before it is completed. Related Links: [C>0x12]
                     BNLS_RESERVESERVERSLOTS

]]
[BNLS_RESERVESERVERSLOTS] = { -- 0x12
	uint32("Number of slots reserved"),
},
--[[doc
    Message ID:      0x13

    Message Name:    BNLS_SERVERLOGONCHALLENGE

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Warcraft III, Warcraft III: The Frozen Throne

    Format:          (DWORD) Slot index.(DWORD[16]) Data for server's SID_AUTH_ACCOUNTLOGON
                     (0x53) response.

    Remarks:         The slot index is returned since individual operations may be returned
                     in a different order than they are requested. This message can also be
                     used to calculate the server's SID_AUTH_ACCOUNTCHANGE (0x55) response.
                     Simply substitute the SID_AUTH_ACCOUNTLOGON (0x53) data with the
                     SID_AUTH_ACCOUNTCHANGE (0x55) data. Related Links: [C>0x13]
                     BNLS_SERVERLOGONCHALLENGE

]]
[BNLS_SERVERLOGONCHALLENGE] = { -- 0x13
	uint32("Slot index"),
	array("Data for server's SID_AUTH_ACCOUNTLOGON", uint32, 16),
},
--[[doc
    Message ID:      0x14

    Message Name:    BNLS_SERVERLOGONPROOF

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo, Diablo II

    Format:          (DWORD) Slot index.(BOOLEAN) Success. (32-bit)(DWORD[5]) Data server's
                     SID_AUTH_ACCOUNTLOGONPROOF (0x54) response.

    Remarks:         After this message is received, the logon checking sequence for a
                     particular logon session is complete. This message can also be used to
                     calculate the server's SID_AUTH_ACCOUNTCHANGEPROOF (0x56) response,
                     and check the client's change password request. Simply substitute the
                     SID_AUTH_ACCOUNTLOGONPROOF (0x54) data with the
                     SID_AUTH_ACCOUNTCHANGEPROOF (0x56) data.

                     If the Success code is TRUE, then the client's logon information was
                     valid. Otherwise, if it is FALSE, the client's logon information was
                     invalid, and the logon request must be denied. Related Links: [S>0x56]
                     SID_AUTH_ACCOUNTCHANGEPROOF, [S>0x54] SID_AUTH_ACCOUNTLOGONPROOF,
                     [C>0x14] BNLS_SERVERLOGONPROOF

]]
[BNLS_SERVERLOGONPROOF] = { -- 0x14
	uint32("Slot index"),
	uint32("Success", nil, Descs.YesNo),
	array("Data server's SID_AUTH_ACCOUNTLOGONPROOF (0x54) response", uint32, 5),
},
--[[doc
    Message ID:      0x18

    Message Name:    BNLS_VERSIONCHECKEX

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (BOOL) Success*(DWORD) Version.(DWORD) Checksum.(STRING) Version check
                     stat string.(DWORD) Cookie.(DWORD) The latest version code for this
                     product.

    Remarks:         * Success is TRUE if successful, FALSE otherwise. If this is FALSE,
                     the next DWORD is the provided cookie, following which the message
                     ends. Related Links: [C>0x18] BNLS_VERSIONCHECKEX

]]
[BNLS_VERSIONCHECKEX] = { -- 0x18
	uint32("Success", nil, Descs.YesNo),
	uint32("Version"),
	uint32("Checksum"),
	stringz("Version check"),
	uint32("Cookie"),
	uint32("The latest version code for this"),
},
--[[doc
    Message ID:    0x1A

    Message Name:  BNLS_VERSIONCHECKEX2

    Direction:     Server -> Client (Received)

    Used By:       Unknown

    Format:        (BOOL) Success*
                   (DWORD) Version.
                   (DWORD) Checksum.
                   (STRING) Version check stat string.
                   (DWORD) Cookie.
                   (DWORD) The latest version code for this product.

    Remarks:       * Success is TRUE if successful, FALSE otherwise. If this is FALSE,
                   the next DWORD is the provided cookie, following which the message
                   ends.

    Related:       [0x1A] BNLS_VERSIONCHECKEX2 (C->S)

]]
[BNLS_VERSIONCHECKEX2] = { -- 0x1A
	uint32("Success", nil, Descs.YesNo),
	version("Version"),
	uint32("Checksum", base.HEX),
	stringz("Version check stat string"),
	uint32("Cookie"),
	uint32("The latest version code for this product", base.HEX),
},
-- End spackets_bnls.lua
