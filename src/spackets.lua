-- Packets from server to client
SPacketDescription = {
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
	uint32{label="Result", desc=Descs.YesNo},
	uint32("Client Token", base.HEX),
	array{label="CD key data for SID_AUTH_CHECK", of=uint32, num=9},
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
	uint32("[8] Data for SID_AUTH_ACCOUNTLOGON"),
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
	uint32("[5] Data for SID_AUTH_ACCOUNTLOGONPROOF"),
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
	array{label="Data for Data for SID_AUTH_ACCOUNTCREATE", of=uint32, num=16},
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
	array{label="Data for SID_AUTH_ACCOUNTCHANGE", of=uint32, num=8},
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
	array{label="Data for SID_AUTH_ACCOUNTCHANGEPROOF", of=uint32, num=21},
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
	uint32{label="Success code.", desc=Descs.YesNo},
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
	array{label="Data for SID_AUTH_ACCOUNTUPGRADEPROOF", of=uint32, num=22},
},
--[[doc
    Message ID:      0x09

    Message Name:    BNLS_VERSIONCHECK

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (BOOLEAN) Success If Success is TRUE:(DWORD) Version.(DWORD) Checksum.(STRING)
                     Version check stat string.

    Remarks:         This message contains the information required for the specified
                     product.

                     Success is TRUE if successful, FALSE otherwise. If this is FALSE,
                     there is no more data in this message. Related Links: [C>0x09]
                     BNLS_VERSIONCHECK

]]
[BNLS_VERSIONCHECK] = { -- 0x09
	uint32{label="Success If Success is TRUE:", desc=Descs.YesNo},
	uint32("Version."),
	uint32("Checksum."),
	stringz("Version check stat string."),
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
	uint32{label="Success", desc=Descs.YesNo},
},
--[[doc
    Message ID:      0x0B

    Message Name:    BNLS_HASHDATA

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         All Products

    Format:          (DWORD[5]) The data hash.Optional:(DWORD) Cookie. Same as the cookie
                     from the request.

    Remarks:         This message contains the hashed data. Related Links: [C>0x0B]
                     BNLS_HASHDATA

]]
[BNLS_HASHDATA] = { -- 0x0B
	array{label="The data hash.Optional:", of=uint32, num=5},
	uint32("Cookie. Same as the cookie"),
},
--[[doc
    Message ID:      0x0C

    Message Name:    BNLS_CDKEY_EX

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         All Products

    Format:          (DWORD) Cookie. (BYTE) Number of CD-keys requested.(BYTE) Number of
                     successfully ecrypted CD-keys .(DWORD) Bit mask .For each successful
                     CD Key:(DWORD) Client session key.(DWORD[9]) CD-key data.

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
	uint32("Cookie."),
	uint8("Number of CD-keys requested."),
	uint8("Number of"),
	uint32("Bit mask .For each successful"),
	uint32("Client session key."),
	array{label="CD-key data.", of=uint32, num=9},
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
	uint32{label="Success code.", desc=Descs.YesNo},
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
	uint32("Server code."),
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
	uint32("Status code."),
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
	when{
		condition=function(...) return arg[2].packet.prod ~= 0 end,
		block = {uint32("Version byte", base.HEX)},
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
	uint32{label="Success.", desc=Descs.YesNo},
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
	uint32("Slot index."),
	array{label="Data for server's SID_AUTH_ACCOUNTLOGON", of=uint32, num=16},
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
	uint32("Slot index."),
	uint32{label="Success.", desc=Descs.YesNo},
	array{label="Data server's", of=uint32, num=5},
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
	uint32{label="Success*", desc=Descs.YesNo},
	uint32("Version."),
	uint32("Checksum."),
	stringz("Version check"),
	uint32("Cookie."),
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
	uint32{label="Success*", desc=Descs.YesNo},
	version("Version."),
	uint32("Checksum.", base.HEX),
	stringz("Version check stat string."),
	uint32("Cookie.", base.HEX),
	uint32("The latest version code for this product.", base.HEX),
},
--[[doc
    Message ID:    0x10

    Message Name:  D2GS_CHARTOOBJ

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Unknown
                   (DWORD) Player ID
                   (BYTE) Movement Type
                   (BYTE) Destination Type
                   *(DWORD) Object ID
                   *(WORD) X Coordinate
                   *(WORD) Y Coordinate

    Remarks:       A character moves to an object within your view range.

                   * - These are what the player is moving to.

                   Possible values for Destination Type:
                   0x00 - Another player
                   0x01 - NPC or Monster
                   0x02 - Object such as Stash, Waypoint, or a Town Portal
                   0x04 - Item
                   0x05 - Doorway
                   Possible value for Movement Type:

                   0x18 - Run
                   0x00 - Walk Please note: This message's official name is not known,
                   and has been invented.

]]
[D2GS_CHARTOOBJ] = { -- 0x10
	uint8("Unknown"),
	uint32("Player ID"),
	uint8("Movement Type"),
	uint8("Destination Type"),
	uint32("Object ID"),
	uint16("X Coordinate"),
	uint16("Y Coordinate"),
},
--[[doc
    Message ID:    0x19

    Message Name:  D2GS_SMALLGOLDPICKUP

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Amount

    Remarks:       Sent when you pick up a BYTE (255) of gold(254 or less).

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_SMALLGOLDPICKUP] = { -- 0x19
	uint8("Amount"),
},
--[[doc
    Message ID:    0x1D

    Message Name:  D2GS_SETBYTEATTR

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Attribute
                   (BYTE) Amount

    Remarks:       Sets the current (base) amount of the specified attribute.

                   Note: Since these are only base amounts, items that give
                   increase/decrease the attribute should be added/subtracted to/from the
                   base value sent in the message.

                   Possible Attributes:

                   0x00 - Strength
                   0x01 - Energy
                   0x02 - Dexterity
                   0x03 - Vitality
                   0x04 - Stat remaining
                   0x05 - Skill remaining
                   0x0C - Level
                   0x0D - Experience
                   0x0E - Gold on Person
                   0x0F - Gold in Stash
                   0x10 - Defense
                   0x11 - Max Attack Damage
                   0x12 - Min Attack Damage
                   0x13 - Attack Rating
                   0x15 - Min Attack Damage
                   0x16 - Max Attack Damage
                   0x19 - Damage
                   0x1f - Defense
                   0x27 - Fire Resistance
                   0x28 - +Max Fire Resistance
                   0x29 - Cold Resistance
                   0x2A - +Max Cold Resistance
                   0x2B - Lightning Resistance
                   0x2C - +Max Lightning Resistance
                   0x2D - Poison Resistance
                   0x2E - +Max poison Resistance
                   0x31 - Add Fire Damage
                   0x33 - Add Lightning damage
                   0x35 - Add Damage for Weapon/Items probably (one of these may be cold
                   damage)
                   0x37 - Add Damage for Weapon/Items probably (one of these may be cold
                   damage)
                   0x3A - Add Poison Damage
                   0x4C - Add Max Health for Weapon/Items probably
                   0x4D - Add Max Mana for Weapons/Items probably
                   0xA2 - Add Max Stamina for Weapons/Items probably
                   0xA3 - Add Max Stamina for Weapons/Items probably
                   0xAB - Add to Defense

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_SETBYTEATTR] = { -- 0x1D
	uint8("Attribute"),
	uint8("Amount"),
},
--[[doc
    Message ID:    0x1E

    Message Name:  D2GS_SETWORDATTR

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Attribute
                   (WORD) Amount

    Remarks:       Sets the current (base) amount of the specified attribute.

                   Note: Since these are only base amounts, items that give
                   increase/decrease the attribute should be added/subtracted to/from the
                   base value sent in the message.

                   For attributes, see D2GS_SETBYTEATTR.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x1D] D2GS_SETBYTEATTR (S->C), [0x1E] D2GS_SETWORDATTR (S->C)

]]
[D2GS_SETWORDATTR] = { -- 0x1E
	uint8("Attribute"),
	uint16("Amount"),
},
--[[doc
    Message ID:    0x1F

    Message Name:  D2GS_SETDWORDATTR

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Attribute - D2GS_SETWORDATTR
                   (DWORD) Amount

    Remarks:       Updates an attribute and sets it to the value sent, 4 bytes max.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x1E] D2GS_SETWORDATTR (S->C)

]]
[D2GS_SETDWORDATTR] = { -- 0x1F
	uint8("Attribute - D2GS_SETWORDATTR"),
	uint32("Amount"),
},
--[[doc
    Message ID:      0x51

    Message Name:    D2GS_WORLDOBJECT

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (BYTE) Object Type - Any information appreciated
                     (DWORD) Object ID
                     (WORD) Object unique code
                     (WORD) X Coordinate
                     (WORD) Y Coordinate
                     (BYTE) State *
                     (BYTE) Interaction Condition

    Remarks:         Server-assigned coordinate, object ID, and state/interaction
                     properties.

                     States:
                     0x00 - Object's state can be changed. (Confirm?)
                     0x02 - Object's state cannot be changed with (0x13) interaction.
                     (Confirm?)

                     Interaction Conditions:
                     0x00 - General object. E.G.: Stash, chests, etc.
                     0x01 - Refresh shrine
                     0x02 - Health shrine
                     0x05 - Chest will catch fire (upon interaction)
                     0x08 - Monster contained within chest (sarcophagus)
                     0x0D - Mana recharge shrine
                     0x0E - Stamina shrine
                     0x0F - Experience shrine
                     0x13 - Fire shrine
                     0x80 - Chest is locked (State will be 0)

                     *If this value is 0, expect no packet 0x0E (status) to follow, if 2,
                     then there will be.

                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_WORLDOBJECT] = { -- 0x51
	uint8("Object Type - Any information appreciated"),
	uint32("Object ID"),
	uint16("Object unique code"),
	uint16("X Coordinate"),
	uint16("Y Coordinate"),
	uint8("State *"),
	uint8("Interaction Condition"),
},
--[[doc
    Message ID:      0x5C

    Message Name:    D2GS_(COMP)STARTGAME

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          Blank

    Remarks:         This packet is part of the logon sequence, not to be confused with the
                     other 0x5C.
                     This packet is originally received compressed, so the message ID will
                     correspond with [Protocol Headers] D2GS compressed format.
                     This message is received with the 'OK' that you can go ahead and enter
                     the gaming environment.

                     Please note: This message's official name is not known, and has been
                     invented.

    Related:         [0x6A] D2GS_ENTERGAMEENVIRONMENT (C->S)

]]
[D2GS_COMPSTARTGAME] = { -- 0x5C
},
--[[doc
    Message ID:    0x77

    Message Name:  D2GS_TRADEACTION

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Request Type

    Remarks:       A character is trading with you.

                   Possible Request Type values:
                   0x01 - Player requests trade initiation
                   0x05 - Player presses 'Accept'
                   0x06 - 'Accept' button disabled for both players
                   0x09 - Out of inventory space
                   0x0C - Player cancels trade
                   0x0D - You accepted the trade agreement
                   0x0E - Your 'Accept' button is disabled
                   0x0F - 'Accept' buttons re-enabled Please note: This message's
                   official name is not known, and has been invented.

]]
[D2GS_TRADEACTION] = { -- 0x77
	uint8("Request Type"),
},
--[[doc
    Message ID:      0x7A

    Message Name:    D2GS_LOGONRESPONSE

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Unknown - Possible acceptance/request ID

    Remarks:         This message is originally received compressed, so the message ID will
                     correspond with D2GS compressed format.

                     This message is received if your logon is accepted by the D2GS.

                     Please note: This message's official name is not known, and has been
                     invented.

    Related:         [0x68] D2GS_GAMELOGON (C->S)

]]
[D2GS_LOGONRESPONSE] = { -- 0x7A
	uint32("Unknown - Possible acceptance/request ID"),
},
--[[doc
    Message ID:      0x89

    Message Name:    D2GS_UNIQUEEVENTS

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (BYTE) EventId // see below,

                     Events known so far:
                     00 = Killed all the monsters in the den.
                     01 = Tristram portal opening for the first time.
                     03 = Staff being put into the oriface in act2
                     06 = Ammy being poped in clawviper temple.
                     07 = Summoner area? death or when the tome is clicked unsure which.
                     08 = Duriel just died
                     0b = Meph just died.
                     0c = The last seal in cs was hit diablo is now released.
                     0d = Diablo was killed or is dead.

    Remarks:         I'm sure there are many others by looking at the gaps here.

                     Note1: Unsure what to name this any suggestions will be taken into
                     account.
                     Note2: This seems to relate to various events that relate directly or
                     indirectly to key quest states//events.

]]
[D2GS_UNIQUEEVENTS] = { -- 0x89
	uint8("EventId // see below,"),
},
--[[doc
    Message ID:    0xAF

    Message Name:  D2GS_STARTLOGON

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        blank*

    Remarks:       Permission to initiate Game Server Logon.

                   * - Although this packet is blank, the data received will still be
                   compressed. Meaning the actual message size will be two bytes in
                   length. (See [Sizes & Types]) Please note: This message's official
                   name is not known, and has been invented.

]]
[D2GS_STARTLOGON] = { -- 0xAF
},
--[[doc
    Message ID:    0x01

    Message Name:  MCP_STARTUP

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Result

    Remarks:       Contains the return value from MCP Startup.

                   Known return values:
                   0x02, 0x0A-0x0D: Realm Unavailable: No Battle.net connection
                   detected.

                   0x7E: CDKey banned from realm play.

                   0x7F: Temporary IP ban \"Your connection has been temporarily
                   restricted from this realm. Please try to log in at another
                   time.\"

                   Else: Success.

    Related:       [0x01] MCP_STARTUP (C->S)

]]
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
		[0x00] = "Game joining succeeded.",
		[0x29] = "Password incorrect.",
		[0x2A] = "Game does not exist.",
		[0x2B] = "Game is full.",
		[0x2C] = "You do not meet the level requirements for this game.",
		[0x6E] = "A dead hardcore character cannot join a game.",
		[0x71] = "A non-hardcore character cannot join a game created by a Hardcore character.",
		[0x73] = "Unable to join a Nightmare game.",
		[0x74] = "Unable to join a Hell game.",
		[0x78] = "A non-expansion character cannot join a game created by an Expansion character.",
		[0x79] = "A Expansion character cannot join a game created by a non-expansion character.",
		[0x7D] = "A non-ladder character cannot join a game created by a Ladder character.",
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
	uint32("Status *"),
	uint32("Game Uptime"),
	uint16("Unknown"),
	uint8("Maximum players allowed"),
	uint8("Number of characters in the game"),
	uint8("[16] Classes of ingame characters **"),
	uint8("[16] Levels of ingame characters **"),
	uint8("Unused"),
	stringz("[16] Character names **"),
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
	uint8("[16] Character name"),
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
[SID_NULL] = { -- 0x00
},
--[[doc
    Message ID:      0x04

    Message Name:    SID_SERVERLIST

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                     Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:          (DWORD) Server version
                     (STRING) [] Server list

    Remarks:         Client should set the internal Battle.net server list from the
                     contents of this message.

                     This packet is supported by all Battle.snp games and Diablo II and its
                     expansion.

]]
[SID_SERVERLIST] = { -- 0x04
	uint32("Server version"),
	iterator{
		label="Server list",
 		alias="bytes",
 		condition = function(self, state) return state.packet.srvr ~="" end,
 		repeated = {
 			WProtoField.stringz{label="Server", key="srvr"},
 		},
 	}
},
--[[doc
    Message ID:    0x05

    Message Name:  SID_CLIENTID

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (DWORD) Registration Version
                   (DWORD) Registration Authority
                   (DWORD) Account Number
                   (DWORD) Registration Token

    Remarks:       The following information is historical:

                   This message used to be used to issue new values to the client for the
                   above fields. New values were issued when the values supplied in
                   SID_CLIENTID were found to be invalid.

                   Since these fields are no longer used, the server now sets them to
                   zero.

    Related:       [0x05] SID_CLIENTID (C->S)

]]
[SID_CLIENTID] = { -- 0x05
	uint32("Registration Version", base.HEX),
	uint32("Registration Authority", base.HEX),
	uint32("Account Number", base.HEX),
	uint32("Registration Token", base.HEX),
},
--[[doc
    Message ID:    0x06

    Message Name:  SID_STARTVERSIONING

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (FILETIME) MPQ Filetime
                   (STRING) MPQ Filename
                   (STRING) ValueString

    Remarks:       Contains CheckRevision values.

    Related:       [0x06] SID_STARTVERSIONING (C->S)

]]
[SID_STARTVERSIONING] = { -- 0x06
	wintime("MPQ Filetime"),
	stringz("MPQ Filename"),
	stringz("ValueString"),
},
--[[doc
    Message ID:    0x07

    Message Name:  SID_REPORTVERSION

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (DWORD) Result
                   (STRING) Patch path

    Remarks:       Reports success/failure on challenge.

                   Result:

                   0: Failed version check

                   1: Old game version

                   2: Success

                   3: Reinstall required

    Related:       [0x07] SID_REPORTVERSION (C->S)

]]
[SID_REPORTVERSION] = { -- 0x07
	uint32("Result", base.DEC, {
		[0x00] = "Failed version check",
		[0x01] = "Old game version",
		[0x02] = "Success",
		[0x03] = "Reinstall required",
	}),
	stringz("Patch path"),
},
--[[doc
    Message ID:    0x08

    Message Name:  SID_STARTADVEX

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware

    Format:        (DWORD) Status

    Remarks:       Status

                   0x00: Failed

                   0x01: Success

    Related:       [0x08] SID_STARTADVEX (C->S)

]]
[SID_STARTADVEX] = { -- 0x08
	uint32("Status", base.DEC, {
		[0x00] = "Failed",
		[0x01] = "Success",
	}),
},
--[[doc
    Message ID:    0x09

    Message Name:  SID_GETADVLISTEX

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo,
                   Warcraft III

    Format:        (DWORD) Number of games

                   If count is 0:
                   (DWORD) Status

                   Otherwise, games are listed thus:

                   For each list item:
                   (WORD) Game Type

                   (WORD) Parameter

                   (DWORD) Language ID

                   (WORD) Address Family (Always AF_INET)

                   (WORD) Port

                   (DWORD) Host's IP

                   (DWORD) sin_zero (0)

                   (DWORD) sin_zero (0)

                   (DWORD) Game Status

                   (DWORD) Elapsed time (in seconds)

                   (STRING) Game name

                   (STRING) Game password

                   (STRING) Game statstring

    Remarks:       Returns a list of available games and their information. Varies
                   depending on product.

                   Note that fields from Address Family to sin_zero form a sockaddr_in
                   structure.

                   Valid status codes:

                   0x00: OK

                   0x01: Game doesn't exist

                   0x02: Incorrect password

                   0x03: Game full

                   0x04: Game already started

                   0x06: Too many server requests

    Related:       [0x09] SID_GETADVLISTEX (C->S)

]]
[SID_GETADVLISTEX] = { -- 0x09
	uint32{label="Number of games", key="games"},
	when{condition=Cond.equals("games", 0),
		block = {
			uint32("Status", base.DEC, Descs.GameStatus)
		},
		otherwise = {
			iterator{label="Game Information", refkey="games", repeated={
				uint16("Game Type", base.HEX, {
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
				uint16("Parameter", base.HEX),
				uint32("Language ID", base.HEX),
				uint16("Address Family", base.DEC, {[2]="AF_INET"}),
				uint16{label="Port", big_endian=true},
				ipv4("Host's IP"),
				uint32("sin_zero"),
				uint32("sin_zero"),
				uint32("Status", base.DEC, Descs.GameStatus),
				uint32("Elapsed time"),
				stringz("Game name"),
				stringz("Game password"),
				stringz("Game statstring"),
			}},
		}
	},
},
--[[doc
    Message ID:    0x0A

    Message Name:  SID_ENTERCHAT

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo,
                   Warcraft III

    Format:        (STRING) Unique name
                   (STRING) Statstring
                   (STRING) Account name

    Remarks:       Contains Client product, realm, statstring, and is sent as the
                   response when the client sends SID_ENTERCHAT. Unique name is the users
                   unique name in chat (Which may be Arta, Arta#2, Arta#3, etc). Account
                   name is the users account name (Which in all 3 previous examples would
                   be Arta).

    Related:       [0x0A] SID_ENTERCHAT (C->S)

]]
[SID_ENTERCHAT] = { -- 0x0A
	stringz("Unique name"),
	stringz("Statstring"),
	stringz("Account name"),
},
--[[doc
    Message ID:    0x0B

    Message Name:  SID_GETCHANNELLIST

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (STRING) [] Channel names, each terminated by a null string.

    Remarks:       Contains a list of available channels.

                   For some reason, Diablo II adds extra data to the channel list (as can
                   be seen in game), and older clients list blocked channels, such as
                   Warez and Backstage.

    Related:       [0x0B] SID_GETCHANNELLIST (C->S)

]]
[SID_GETCHANNELLIST] = { -- 0x0B
	iterator{
		alias="none",
		condition = function(self, state) return state.packet.chan ~="" end,
		repeated = {
			stringz{label="Channel name", key="chan"},
		}
	}
},
--[[doc
    Message ID:    0x0F

    Message Name:  SID_CHATEVENT

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Event ID
                   (DWORD) User's Flags
                   (DWORD) Ping
                   (DWORD) IP Address (Defunct)
                   (DWORD) Account number (Defunct)
                   (DWORD) Registration Authority (Defunct)
                   (STRING) Username
                   (STRING) Text

    Remarks:       Contains all chat events.

                   For STAR/SEXP/SSHR/JSTR, Text is UTF-8 encoded (WIDESTRING).

                   Event IDs:
                   [0x01] EID_SHOWUSER: User in channel

                   [0x02] EID_JOIN: User joined channel

                   [0x03] EID_LEAVE: User left channel

                   [0x04] EID_WHISPER: Recieved whisper

                   [0x05] EID_TALK: Chat text

                   [0x06] EID_BROADCAST: Server broadcast

                   [0x07] EID_CHANNEL: Channel information

                   [0x09] EID_USERFLAGS: Flags update

                   [0x0A] EID_WHISPERSENT: Sent whisper

                   [0x0D] EID_CHANNELFULL: Channel full

                   [0x0E] EID_CHANNELDOESNOTEXIST: Channel doesn't exist

                   [0x0F] EID_CHANNELRESTRICTED: Channel is restricted

                   [0x12] EID_INFO: Information

                   [0x13] EID_ERROR: Error message

                   [0x17] EID_EMOTE: Emote

                   EID_SHOWUSER:
                   This is sent for each user who is already in a channel when you
                   join it, as opposed to EID_JOIN, which is sent when a user joins
                   a channel you have already joined. It is also sent when logged
                   on using D2XP/D2DV and a user requires an update to their
                   statstring - for example, by logging a different character onto
                   a realm.

                   EID_JOIN:
                   This is sent when a user enters the channel you are
                   currently in.

                   EID_LEAVE:
                   This is sent when a user exits the channel you are
                   currently in.

                   EID_WHISPER:
                   This is sent when a user whispers you.

                   EID_TALK:
                   This is sent when a user (excluding
                   self) in chat speaks.

                   EID_BROADCAST:
                   The username supplied for this event is
                   now always 'Battle.net'. Historically,
                   username contained the name of the
                   Battle.net Administrator who sent the
                   broadcast.

                   EID_CHANNEL:
                   The flags field for this event is used
                   and indicates what special conditions
                   exist for the channel in question. See
                   [Battle.net Flags] for more information.

                   EID_USERFLAGS:
                   This is sent to inform the client of an
                   update to one or more user's flags.
                   Battle.net usually sends this event for
                   every user in the channel, even if only
                   one user's flags have changed. This
                   behavior can be exploited to detect
                   invisible users, by performing an action
                   (such as an unsquelch) to provoke a
                   flags update. Users included in the
                   flags update whose presence has not been
                   indicated by EID_JOIN or EID_SHOWUSER
                   can then be added to the userlist as
                   invisible. Care should be taken,
                   however, to account for the possibility
                   that an asynchronous send error has
                   occurred. Should an EID_JOIN or
                   EID_SHOWUSER event occur for an
                   invisible user, they should be marked as
                   a normal user, not readded to the
                   userlist.

                   EID_WHISPERSENT:
                   The Flags and Ping fields in this packet
                   is equal to the originating user - the
                   one who sent the whisper. In other
                   words, EID_WHISPERSENT contains your
                   flags & ping, not those of the person
                   you whispered.

                   EID_CHANNELDOESNOTEXIST:
                   See info on NoCreate Join in
                   SID_JOINCHANNEL.

                   EID_CHANNELRESTRICTED:
                   This is sent when attempting
                   to join a channel which your
                   client is not allowed to
                   join.

                   EID_INFO:
                   This is information
                   supplied by
                   Battle.net. This text
                   is usually displayed
                   by clients in yellow.

                   EID_Error:
                   This is error
                   information
                   supplied by
                   Battle.net. This
                   text is usually
                   displayed by
                   clients in red.

                   EID_Emote:
                   This is
                   sent when
                   any user
                   (including
                   self) uses
                   the emote
                   feature in
                   chat.

    Related:       [0x0E] SID_CHATCOMMAND (C->S), [0x0C] SID_JOINCHANNEL (C->S)

]]
[SID_CHATEVENT] = { -- 0x0F
	uint32{label="Event ID", key="eid", base.DEX, desc={ -- TODO: hash name for base?
		[0x01] = "EID_SHOWUSER: User in channel",
		[0x02] = "EID_JOIN: User joined channel",
		[0x03] = "EID_LEAVE: User left channel",
		[0x04] = "EID_WHISPER: Recieved whisper",
		[0x05] = "EID_TALK: Chat text",
		[0x06] = "EID_BROADCAST: Server broadcast",
		[0x07] = "EID_CHANNEL: Channel information",
		[0x09] = "EID_USERFLAGS: Flags update",
		[0x0A] = "EID_WHISPERSENT: Sent whisper",
		[0x0D] = "EID_CHANNELFULL: Channel full",
		[0x0E] = "EID_CHANNELDOESNOTEXIST: Channel doesn't exist",
		[0x0F] = "EID_CHANNELRESTRICTED: Channel is restricted",
		[0x12] = "EID_INFO: Information",
		[0x13] = "EID_ERROR: Error message",
		[0x17] = "EID_EMOTE: Emote",
	}},
	uint32("User's Flags", base.HEX),
	uint32("Ping"),
	ipv4("IP Address"),
	uint32("Account number", base.HEX),
	uint32("Registration Authority", base.HEX),
	stringz("Username"),
	-- stringz("Text"),
	-- TODO: set compare (in)
	when{ condition=Cond.equals("eid", 1),
		block = { stringz("Statstring") },
		otherwise = { stringz("Text") }
	}

	
},
--[[doc
    Message ID:    0x13

    Message Name:  SID_FLOODDETECTED

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        [blank]

    Remarks:       Sent prior to a disconnect along with SID_MESSAGEBOX to indicate that
                   the client has flooded off.

    Related:       [0x19] SID_MESSAGEBOX (S->C)

]]
[SID_FLOODDETECTED] = { -- 0x13
},
--[[doc
    Message ID:    0x15

    Message Name:  SID_CHECKAD

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III, World of Warcraft

    Format:        (DWORD) Ad ID
                   (DWORD) File extension
                   (FILETIME) Local file time
                   (STRING) Filename
                   (STRING) Link URL

    Remarks:       Contains information needed to download and display an ad banner.

    Related:       [0x15] SID_CHECKAD (C->S)

]]
[SID_CHECKAD] = { -- 0x15
	uint32("Ad ID", base.HEX),
	stringz{label="File extension", length=4},
	wintime("Local file time"),
	stringz("Filename"),
	stringz("Link URL"),
},
--[[doc
    Message ID:      0x18

    Message Name:    SID_REGISTRY

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Unknown

    Format:          (DWORD) Cookie
                     (DWORD) HKEY
                     (STRING) Registry path
                     (STRING) Registry key

    Remarks:         HKEY is the registry key root.

                     The values are standard:
                     0x80000000: HKEY_CLASSES_ROOT

                     0x80000001: HKEY_CURRENT_USER

                     0x80000002: HKEY_LOCAL_MACHINE

                     0x80000003: HKEY_USERS

                     0x80000004: HKEY_PERFORMANCE_DATA

                     0x80000005: HKEY_CURRENT_CONFIG

                     0x80000006: HKEY_DYN_DATA

    Related:         [0x18] SID_REGISTRY (C->S)

]]
[SID_REGISTRY] = { -- 0x18
	uint32("Cookie", base.HEX),
	uint32("HKEY", base.HEX, {
		[0x80000000] = "HKEY_CLASSES_ROOT",
		[0x80000001] = "HKEY_CURRENT_USER",
		[0x80000002] = "HKEY_LOCAL_MACHINE",
		[0x80000003] = "HKEY_USERS",
		[0x80000004] = "HKEY_PERFORMANCE_DATA",
		[0x80000005] = "HKEY_CURRENT_CONFIG",
		[0x80000006] = "HKEY_DYN_DATA",
	}),
	stringz("Registry path"),
	stringz("Registry key"),
},
--[[doc
    Message ID:    0x19

    Message Name:  SID_MESSAGEBOX

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Style
                   (STRING) Text
                   (STRING) Caption

    Remarks:       Displays a message to the user. This message's fields are used as
                   parameters for the Win32 API MessageBox, and can be passed directly to
                   it. For more information about these parameters, see the documentation
                   for MessageBox at MSDN.

]]
[SID_MESSAGEBOX] = { -- 0x19
	uint32("Style"),
	stringz("Text"),
	stringz("Caption"),
},
--[[doc
    Message ID:    0x1C

    Message Name:  SID_STARTADVEX3

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) Status

    Remarks:       Possible values for Status:
                   0x00: Ok

                   0x01: Failed

    Related:       [0x1C] SID_STARTADVEX3 (C->S)

]]
[SID_STARTADVEX3] = { -- 0x1C
	uint32("Status", base.DEC, {
		[0x00] ="Ok", 
		[0x01] = "Failed",
	}),
},
--[[doc
    Message ID:    0x1D

    Message Name:  SID_LOGONCHALLENGEEX

    Direction:     Server -> Client (Received)

    Used By:       Warcraft II

    Format:        (DWORD) UDP Token
                   (DWORD) Server Token

    Remarks:       Informs the client of the UDP Token and the Server Token.

]]
[SID_LOGONCHALLENGEEX] = { -- 0x1D
	uint32("UDP Token", base.HEX),
	uint32("Server Token", base.HEX),
},
--[[doc
    Message ID:    0x25

    Message Name:  SID_PING

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Ping Value

    Remarks:       Used to calculate Client's ping. The received DWORD should be sent
                   directly back to Battle.net.

                   The ping displayed when in chat can be artificially inflated by
                   delaying before sending this packet, or deflated by responding before
                   requested.
                   Ping can be set to -1 (Strictly speaking, 0xFFFFFFFF, since ping is
                   unsigned) by not responding to this packet at all.

                   The received DWORD is not what determines your ping, but it is
                   actually a cookie for the Battle.net server. You should not ever
                   change the DWORD.

    Related:       [0x25] SID_PING (C->S)

]]
[SID_PING] = { -- 0x25
	uint32("Ping Value", base.HEX),
},
--[[doc
    Message ID:    0x26

    Message Name:  SID_READUSERDATA

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) Number of accounts
                   (DWORD) Number of keys
                   (DWORD) Request ID
                   (STRING) [] Requested Key Values

    Remarks:       Contains profile information as requested by the client.

    Related:       [0x26] SID_READUSERDATA (C->S)

]]
[SID_READUSERDATA] = { -- 0x26
	uint32{label="Number of accounts", key="numaccts"},
	uint32{label="Number of keys", key="numkeys"},
	uint32("Request ID"),
	-- TODO
	iterator{label="Requested Account", refkey="numaccts", repeated={
		iterator{
			refkey="numkeys",
			repeated={stringz("Requested Key Value")},
			label="Key Values",
		},
	}},
},
--[[doc
    Message ID:    0x28

    Message Name:  SID_LOGONCHALLENGE

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (DWORD) Server Token

    Remarks:       Contains server token.

]]
[SID_LOGONCHALLENGE] = { -- 0x28
	uint32("Server Token", base.HEX),
},
--[[doc
    Message ID:    0x29

    Message Name:  SID_LOGONRESPONSE

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (DWORD) Result

    Remarks:       Reports success/fail on password authentication.

                   Result:
                   0x00: Invalid password

                   0x01: Success

    Related:       [0x29] SID_LOGONRESPONSE (C->S)

]]
[SID_LOGONRESPONSE] = { -- 0x29
	uint32("Result", base.DEC, {
		[0x00] = "Invalid password",
		[0x01] = "Success",
	}),
},
--[[doc
    Message ID:    0x2A

    Message Name:  SID_CREATEACCOUNT

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) Result

    Remarks:       Results:

                   0x00: Fail

                   0x01: Success

                   Reports success/fail on account creation.

    Related:       [0x2A] SID_CREATEACCOUNT (C->S)

]]
[SID_CREATEACCOUNT] = { -- 0x2A
	uint32("Result", base.DEC, {
		[0x00] = "Failed",
		[0x01] = "Success",
	}),
},
--[[doc
    Message ID:    0x2D

    Message Name:  SID_GETICONDATA

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                   Warcraft III: The Frozen Throne, Starcraft, Starcraft Japanese, Diablo,
                   Warcraft III

    Format:        (FILETIME) Filetime
                   (STRING) Filename

    Remarks:       Returns filename and filetime of default icons file.

    Related:       [0x2D] SID_GETICONDATA (C->S)

]]
[SID_GETICONDATA] = { -- 0x2D
	wintime("Filetime"),
	stringz("Filename"),
},
--[[doc
    Message ID:      0x2E

    Message Name:    SID_GETLADDERDATA

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Server -> Client (Received)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft

    Format:          (DWORD) Ladder type
                     (DWORD) League
                     (DWORD) Sort method
                     (DWORD) Starting rank
                     (DWORD) Number of ranks listed (Count of items in list)

                     For each list item:
                     (DWORD) Wins

                     (DWORD) Losses

                     (DWORD) Disconnects

                     (DWORD) Rating

                     (DWORD) Rank

                     (DWORD) Official wins

                     (DWORD) Official losses

                     (DWORD) Official disconnects

                     (DWORD) Official rating

                     (DWORD) Unknown

                     (DWORD) Official rank

                     (DWORD) Unknown

                     (DWORD) Unknown

                     (DWORD) Highest rating

                     (DWORD) Unknown

                     (DWORD) Season

                     (FILETIME) Last game time

                     (FILETIME) Official last game time

                     (STRING) Name

    Remarks:         Contains the requested ladder data.

                     The unknowns are possibly iron man ranking/rating/high rank/high
                     rating, needs further investigation.

    Related:         [0x2E] SID_GETLADDERDATA (C->S)

]]
[SID_GETLADDERDATA] = { -- 0x2E
	uint32("Ladder type", base.HEX),
	uint32("League", base.HEX),
	uint32("Sort method", base.DEC, {
		[0x00] = "Highest rating",
		[0x01] = "Fastest climbers",
		[0x02] = "Most wins on record",
		[0x03] = "Most games played",
	}),
	uint32("Starting rank", base.HEX),
	uint32{label="Number of ranks listed", key="ranks"},
	iterator{label="Rank", refkey="ranks", repeated={
		uint32("Wins"),
		uint32("Losses"),
		uint32("Disconnects"),
		uint32("Rating"),
		uint32("Rank"),
		uint32("Official wins"),
		uint32("Official losses"),
		uint32("Official disconnects"),
		uint32("Official rating"),
		uint32("Unknown", base.HEX),
		uint32("Official rank"),
		uint32("Unknown", base.HEX),
		uint32("Unknown", base.HEX),
		uint32("Highest rating"),
		uint32("Unknown", base.HEX),
		uint32("Season"),
		wintime("Last game time"),
		wintime("Official last game time"),
		stringz("Name"),
	}},
},
--[[doc
    Message ID:    0x2F

    Message Name:  SID_FINDLADDERUSER

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Warcraft II, Starcraft

    Format:        (DWORD) Rank. Zero-based. 0xFFFFFFFF == Not ranked.

    Remarks:       Contains the rank of the user specified by the request.

    Related:       [0x2F] SID_FINDLADDERUSER (C->S)

]]
[SID_FINDLADDERUSER] = { -- 0x2F
	uint32("Rank. Zero-based. 0xFFFFFFFF == Not ranked."),
},
--[[doc
    Message ID:    0x30

    Message Name:  SID_CDKEY

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Japanese

    Format:        (DWORD) Result
                   (STRING) Key owner

    Remarks:       This packet is identical to SID_CDKEY (0x30)

                   Possible values for Result:
                   0x01: Ok

                   0x02: Invalid key

                   0x03: Bad product

                   0x04: Banned

                   0x05: In use
                   In addition, the Key Owner field has two special values:

                   * 'TOO MANY SPAWNS': Exceeded spawn limit for this CD-Key

                   * 'NO SPAWNING': Spawns are not supported for this CD-Key

    Related:       [0x30] SID_CDKEY (C->S), [0x36] SID_CDKEY2 (S->C)

]]
[SID_CDKEY] = { -- 0x30
	uint32("Result", base.DEC, {
		[0x01] = "Ok",
		[0x02] = "Invalid key",
		[0x03] = "Bad product",
		[0x04] = "Banned",
		[0x05] = "In use",
	}),
	stringz("Key owner"),
},
--[[doc
    Message ID:    0x31

    Message Name:  SID_CHANGEPASSWORD

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (BOOLEAN) Password change succeeded

    Remarks:       Reports sucess/fail for password change.

    Related:       [0x31] SID_CHANGEPASSWORD (C->S)

]]
[SID_CHANGEPASSWORD] = { -- 0x31
	uint32{label="Password change succeeded", desc=Descs.YesNo},
},
--[[doc
    Message ID:      0x32

    Message Name:    SID_CHECKDATAFILE

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft,
                     Starcraft Japanese

    Format:          (DWORD) Status

    Remarks:         This message is no longer used; developers should use the
                     SID_CHECKDATAFILE2 message.

                     Status:
                     0x00: Rejected

                     0x01: Approved

                     0x02: Ladder approved

    Related:         [0x3C] SID_CHECKDATAFILE2 (S->C), [0x32] SID_CHECKDATAFILE (C->S)

]]
[SID_CHECKDATAFILE] = { -- 0x32
	uint32("Status", base.DEC, {
		[0x00] = "Rejected",
		[0x01] = "Approved",
		[0x02] = "Ladder approved",
	}),
},
--[[doc
    Message ID:    0x33

    Message Name:  SID_GETFILETIME

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III, World of Warcraft

    Format:        (DWORD) Request ID
                   (DWORD) Unknown
                   (FILETIME) Last update time
                   (STRING) Filename

    Remarks:       Contains the latest filetime for the requested file. If the file does
                   not exist, the returned filetime is null.

    Related:       [0x33] SID_GETFILETIME (C->S)

]]
[SID_GETFILETIME] = { -- 0x33
	uint32("Request ID", base.HEX),
	uint32("Unknown", base.HEX),
	wintime("Last update time"),
	stringz("Filename"),
},
--[[doc
    Message ID:      0x34

    Message Name:    SID_QUERYREALMS

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Unknown
                     (DWORD) Count

                     For Each Realm:
                     (DWORD) Unknown

                     (STRING) Realm title

                     (STRING) Realm description

    Remarks:         Realm list.

                     The first Unknown is usually 0. The second [and subsequent] Unknown is
                     usually 1.

                     This packet is no longer used. SID_QUERYREALMS2 is used instead.

    Related:         [0x34] SID_QUERYREALMS (C->S)

]]
[SID_QUERYREALMS] = { -- 0x34
	uint32("Unknown", base.HEX),
	uint32{label="Count", key="realms"},
	iterator{label="Realm", refkey="realms", repeated={
		uint32("Unknown", base.HEX),
		stringz("Realm title"),
		stringz("Realm description"),
	}},
},
--[[doc
    Message ID:    0x35

    Message Name:  SID_PROFILE

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (BYTE) Success
                   (STRING) Profile\Description value
                   (STRING) Profile\Location value
                   (DWORD) Clan Tag

    Remarks:       If the status code is 0, the request was successful; otherwise, the
                   lookup failed and the message length will be five bytes long (not
                   counting the four byte header).

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x35] SID_PROFILE (C->S)

]]
[SID_PROFILE] = { -- 0x35
	uint32("Cookie", base.HEX),
	uint8{label="Success", key="status"},
	when{condition=Cond.equals("status", 0), block={
		stringz("Profile\\Description value"),
		stringz("Profile\\Location value"),
		uint32("Clan Tag"),
	}},
},
--[[doc
    Message ID:    0x36

    Message Name:  SID_CDKEY2

    Direction:     Server -> Client (Received)

    Used By:       Warcraft II

    Format:        (DWORD) Result
                   (STRING) Key owner

    Remarks:       This packet is identical to SID_CDKEY (0x30)

                   Possible values for Result:
                   0x01: OK

                   0x02: Invalid key

                   0x03: Bad product

                   0x04: Banned

                   0x05: In use
                   In addition, the Key Owner field has two special values:

                   * 'TOO MANY SPAWNS': Exceeded spawn limit for this CD-Key

                   * 'NO SPAWNING': Spawns are not supported for this CD-Key

    Related:       [0x36] SID_CDKEY2 (C->S), [0x30] SID_CDKEY (S->C)

]]
[SID_CDKEY2] = { -- 0x36
	uint32("Result", base.DEC, {
		[0x01] = "Ok",
		[0x02] = "Invalid key",
		[0x03] = "Bad product",
		[0x04] = "Banned",
		[0x05] = "In use",
	}),
	stringz("Key owner"),
},
--[[doc
    Message ID:    0x3A

    Message Name:  SID_LOGONRESPONSE2

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Result
                   (STRING) Reason

    Remarks:       Status:
                   0x00: Success

                   0x01: Account Does Not Exist

                   0x02: Invalid Password

                   0x06: Account Closed
                   The string containing the reason is only present when your account is
                   closed, if not, it should be empty.

    Related:       [0x3A] SID_LOGONRESPONSE2 (C->S)

]]
[SID_LOGONRESPONSE2] = { -- 0x3A
	uint32{label="Result", display=base.DEC, desc={
		[0x00] = "Success",
		[0x01] = "Account Does Not Exist",
		[0x02] = "Invalid Password",
		[0x06] = "Account Closed",
	}, key="res"},
	when{condition=Cond.equals("res", 6), block={
		stringz("Reason"),
	}},
},
--[[doc
    Message ID:    0x3C

    Message Name:  SID_CHECKDATAFILE2

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft,
                   Starcraft Japanese

    Format:        (DWORD) Result

    Remarks:       Result of file integrity query.

                   Result:
                   0x00: Not approved

                   0x01: Blizzard approved

                   0x02: Approved for ladder

    Related:       [0x3C] SID_CHECKDATAFILE2 (C->S)

]]
[SID_CHECKDATAFILE2] = { -- 0x3C
	uint32("Result", base.DEC, {
		[0x00] = "Not approved",
		[0x01] = "Blizzard approved",
		[0x02] = "Approved for ladder",
	}),
},
--[[doc
    Message ID:    0x3D

    Message Name:  SID_CREATEACCOUNT2

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) Status
                   (STRING) Account name suggestion

    Remarks:       Account creation result.

                   Result:
                   0x00: Account created

                   0x02: Name contained invalid characters

                   0x03: Name contained a banned word

                   0x04: Account already exists

                   0x06: Name did not contain enough alphanumeric characters

    Related:       [0x3D] SID_CREATEACCOUNT2 (C->S)

]]
[SID_CREATEACCOUNT2] = { -- 0x3D
	uint32("Status", base.DEC, {
		[0x00] = "Account created",
		[0x02] = "Name contained invalid characters",
		[0x03] = "Name contained a banned word",
		[0x04] = "Account already exists",
		[0x06] = "Name did not contain enough alphanumeric characters",
	}),
	-- stringz("Account name suggestion"),
},
--[[doc
    Message ID:    0x3E

    Message Name:  SID_LOGONREALMEX

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) MCP Cookie
                   (DWORD) MCP Status
                   (DWORD) [2] MCP Chunk 1
                   (DWORD) IP
                   (DWORD) Port
                   (DWORD) [12] MCP Chunk 2
                   (STRING) Battle.net unique name

    Remarks:       This packet supplies the data necessary to connect to an MCP server.
                   The cookie value is defined in the first DWORD of SID_LOGONREALMEX and
                   is simply returned by Battle.net. If the length of the message (not
                   including header) is greater than 8, the client should continue to
                   logon to the MCP. Otherwise, the Status field is interpreted as an
                   error code:

                   0x80000001: Realm is unavailable
                   0x80000002: Realm logon failed

                   Any other value indicates failure.

                   The first part of the MCP Chunk that must be sent to the MCP server
                   includes the Status and Cookie DWORDS, making MCP Chunk 1 the first 4
                   DWORDS of the packet.

                   There used to be a WORD at the end of this packet, which was
                   apparently random.

    Related:       [0x3E] SID_LOGONREALMEX (C->S), [0x01] MCP_STARTUP (C->S)

]]
[SID_LOGONREALMEX] = { -- 0x3E
	uint32("MCP Cookie", base.HEX),
	uint32{label="MCP Status", key="status"},
	when{condition=Cond.equals("status", 0), block={
		array{of=uint32, label="MCP Chunk 1", num=2},
		ipv4("IP"),
		uint16{label="Port", big_endian=true},
		bytes{label="Padding", length=2},
		array{of=uint32, label="MCP Chunk 2", num=12},
		stringz("Battle.net unique name"),
	}},
},
--[[doc
    Message ID:      0x3F

    Message Name:    SID_STARTVERSIONING2

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Unknown

    Format:          (FILETIME) MPQ Filetime
                     (STRING) MPQ Filename
                     (STRING) ValueString

    Remarks:         Contains CheckRevision values.

                     Has anyone seen this packet in use? It's currently being marked as
                     defunct, as I don't know of any clients that receive it.

    Related:         [0x06] SID_STARTVERSIONING (S->C)

]]
[SID_STARTVERSIONING2] = { -- 0x3F
	wintime("MPQ Filetime"),
	stringz("MPQ Filename"),
	stringz("ValueString"),
},
--[[doc
    Message ID:    0x40

    Message Name:  SID_QUERYREALMS2

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Unknown
                   (DWORD) Count

                   For Each Realm:
                   (DWORD) Unknown

                   (STRING) Realm title

                   (STRING) Realm description

    Remarks:       Realm list.

                   The first Unknown is usually 0. The second [and subsequent] Unknown is
                   usually 1.

    Related:       [0x40] SID_QUERYREALMS2 (C->S), [0x34] SID_QUERYREALMS (S->C)

]]
[SID_QUERYREALMS2] = { -- 0x40
	uint32("Unknown", base.HEX),
	uint32{label="Count", key="realms"},
	iterator{label="Realm", refkey="realms", repeated={
		uint32("Unknown", base.HEX),
		stringz("Realm title"),
		stringz("Realm description"),
	}},
},
--[[doc
    Message ID:    0x41

    Message Name:  SID_QUERYADURL

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Ad ID
                   (STRING) Ad URL

    Remarks:       Reports the Adbanner's URL. This message will only be received if the
                   client sent it to the server.

    Related:       [0x41] SID_QUERYADURL (C->S)

]]
[SID_QUERYADURL] = { -- 0x41
	uint32("Ad ID"),
	stringz("Ad URL"),
},
--[[doc
    Message ID:      0x44

    Message Name:    SID_WARCRAFTGENERAL

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Server -> Client (Received)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (BYTE) Subcommand ID

                     For subcommand 0x04 (User stats request):
                     (DWORD) Cookie

                     (DWORD) Icon ID (based on identifier; for example, \"Orc Peon\"
                     is 'opeo')

                     (BYTE) Number of ladder records to read; this will be between 0
                     and 3.

                     For each ladder record:
                     (DWORD) Ladder type; valid types are 'SOLO', 'TEAM', or
                     'FFA ' (where the last character of 'FFA ' is a space,
                     0x20).

                     (WORD) Number of wins

                     (WORD) Number of losses

                     (BYTE) Level

                     (BYTE) Hours until XP decay, if applicable*

                     (WORD) Experience

                     (DWORD) Rank (will be 0 if unranked)

                     (BYTE) Number of race records to read; this will be 5 for WAR3
                     and 6 for W3XP.

                     For each race record:
                     (WORD) Wins

                     (WORD) Losses

                     (BYTE) Number of team records to read.
                     For each team record:
                     (DWORD) Type of team; valid types are '2VS2', '3VS3', and
                     '4VS4'.

                     (WORD) Number of wins

                     (WORD) Number of losses

                     (BYTE) Level

                     (BYTE) Hours until XP decay, if applicable*

                     (WORD) Experience

                     (DWORD) Rank (will be 0 if unranked)

                     (FILETIME) Time of last game played

                     (BYTE) Number of partners

                     (STRING)[] Names of partners
                     For subcommand 0x08 (Clan stats request):
                     (DWORD) Cookie

                     (BYTE) Number of ladder records to read; this will be between 0
                     and 3.
                     For each ladder record:
                     (DWORD) Ladder type; valid types are 'SOLO', 'TEAM', or
                     'FFA ' (where the last character of 'FFA ' is a space,
                     0x20).

                     (WORD) Number of wins

                     (WORD) Number of losses

                     (BYTE) Level

                     (BYTE) Hours until XP decay, if applicable*

                     (WORD) Experience

                     (DWORD) Rank (will be 0 if unranked)

                     (BYTE) Number of race records to read; this will be 5 for WAR3
                     and 6 for W3XP.
                     For each race record:
                     (WORD) Wins

                     (WORD) Losses

                     For subcommand 0x09 (Icon list request):
                     (DWORD) Cookie

                     (DWORD) Unknown

                     (BYTE) Tiers

                     (BYTE) Count
                     For each Icon:
                     (DWORD) Icon

                     (DWORD) Name

                     (BYTE) Race

                     (WORD) Wins required

                     (BYTE) Unknown

    Remarks:         This message is still being researched!

                     This message is used for multiple purposes on Warcraft III. Known and
                     validated purposes are listed here.

                     * The field "Hours until XP decay" is unconfirmed; however, testing
                     numbers correspond to values expected within the "Days until XP decay"
                     displayed on the live Battle.net ladder website. It is also included
                     but unused (ignored) in the Clan Stats Request command (0x08).

    Related:         [0x44] SID_WARCRAFTGENERAL (C->S)

]]
[SID_WARCRAFTGENERAL] = { -- 0x44
	uint8{label="Subcommand ID", display=base.HEX, key="subcommand"},
	when{condition=Cond.equals("subcommand", 0x4), block = {
		uint32("Cookie", base.HEX),
		stringz{label="Icon ID", length=4},
		uint8{label="Number of ladder records", key="ladders"},
		iterator{label="Ladder Record", refkey="ladders", repeated={
			strdw("Ladder type"),
			uint16("Number of wins"),
			uint16("Number of losses"),
			uint8("Level"),
			uint8("Hours until XP decay"),
			uint16("Experience"),
			uint32("Rank"),
		}},
		uint8{label="Number of race records", key="races"},
		iterator{label="Race Record", refkey="races", repeated={
			uint16("Wins"),
			uint16("Losses"),
		}},
		uint8{label="Number of team records", key="teams"},
		iterator{label="Team Record", refkey="teams", repeated={
			strdw("Type of team"),
			uint16("Number of wins"),
			uint16("Number of losses"),
			uint8("Level"),
			uint8("Hours until XP decay"),
			uint16("Experience"),
			uint32("Rank"),
			wintime("Time of last game played"),
			uint8{label="Number of partners", key="partners"},
			iterator{label="Partners", refkey="partners", repeated={
				stringz("Names of partners"),
			}},
		}},
	}},
	when{condition=Cond.equals("subcommand", 0x8), block={
		uint32("Cookie", base.HEX),
		uint8{label="Number of ladder records", key="ladders"},
		iterator{label="Ladder Record", refkey="ladders", repeated={
			strdw("Ladder type"),
			uint16("Number of wins"),
			uint16("Number of losses"),
			uint8("Level"),
			uint8("Hours until XP decay"),
			uint16("Experience"),
			uint32("Rank"),
		}},
		uint8{label="Number of race records", key="races"},
		iterator{label="Race Record", refkey="races", repeated={
			uint16("Wins"),
			uint16("Losses"),
		}},
	}},
	when{condition=Cond.equals("subcommand", 0x9), block={
		uint32("Cookie", base.HEX),
		uint32("Unknown", base.HEX),
		uint8("Tiers"),
		uint8{label="Count (Number of Icons?)", key="icons"},
		iterator{label="Icon", refkey="icons", repeated={
			uint32("Icon", base.HEX),
			uint32("Name", base.HEX),
			uint8("Race", base.HEX),
			uint16("Wins required"),
			uint8("Unknown", base.HEX),
		}},
	}},
},
--[[doc
    Message ID:    0x46

    Message Name:  SID_NEWS_INFO

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Warcraft III: The Frozen Throne, Diablo, Warcraft III

    Format:        (BYTE) Number of entries
                   (DWORD) Last logon timestamp
                   (DWORD) Oldest news timestamp
                   (DWORD) Newest news timestamp

                   For each entry:

                   (DWORD) Timestamp

                   (STRING) News

    Remarks:       This packet contains news from battle.net. Timestamps are in C/Unix
                   format, biased for UTC.

                   Multiple separate news messages can be received. These should be
                   treated the same as if one message was sent with several news entries.

                   If the 'Timestamp' field for an entry is zero, then that entry is the
                   message of the day (and not a news entry in the normal respect).

    Related:       [0x46] SID_NEWS_INFO (C->S)

]]
[SID_NEWS_INFO] = { -- 0x46
	uint8{label="Number of entries", key="news" },
	posixtime("Last logon timestamp"),
	posixtime("Oldest news timestamp"),
	posixtime("Newest news timestamp"),
	iterator{label="News", refkey="news", repeated={
		posixtime{label="Timestamp", key="stamp"},
		when{
			condition=function(self, state) return state.packet.stamp == 0 end,
			block = { stringz("MOTD") },
			otherwise = {stringz("News")},
		},},
	},
},
--[[doc
    Message ID:    0x4A

    Message Name:  SID_OPTIONALWORK

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (STRING) MPQ Filename

    Remarks:       Using SID_GETFILETIME with request ID 0x80000005, the client should
                   download this file and call the ExtraWork function inside of it.
                   Generally, this message is used for the optional ExtraWork DLL.

                   The client will only execute this entirely if the registry key
                   HKCU\Software\Battle.net\Optimize\SysDesc [REG_DWORD] is set to 1.

    Related:       Battle.net's File Transfer Protocol Version 1, Battle.net's File
                   Transfer Protocol Version 2, [0x33] SID_GETFILETIME (C->S)

]]
[SID_OPTIONALWORK] = { -- 0x4A
	stringz("MPQ Filename"),
},
--[[doc
    Message ID:    0x4C

    Message Name:  SID_REQUIREDWORK

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (STRING) ExtraWork MPQ FileName

    Remarks:       Using SID_GETFILETIME with request ID 0x80000006, the client should
                   download the specified MPQ file, extract ExtraWork.dll and call the
                   ExtraWork function inside of it.

    Related:       Battle.net's File Transfer Protocol Version 1, Battle.net's File
                   Transfer Protocol Version 2, [0x33] SID_GETFILETIME (C->S)

]]
[SID_REQUIREDWORK] = { -- 0x4C
	stringz("ExtraWork MPQ FileName"),
},
--[[doc
    Message ID:      0x4E

    Message Name:    SID_TOURNAMENT

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Server -> Client (Received)

    Used By:         Starcraft Broodwar, Starcraft

    Format:          (BYTE) Unknown
                     (BYTE) Unknown, maybe number of non-null strings sent?
                     (STRING) Description
                     (STRING) Unknown
                     (STRING) Website
                     (DWORD) Unknown
                     (STRING) Name
                     (STRING) Unknown
                     (STRING) Unknown
                     (STRING) Unknown
                     (DWORD[5]) Unknown

    Remarks:         Research requested.
                     Sent after a successful logon to an account in a WCG tournament.
                     The 0x0C packet sent with 0x01 flags would automatically have the user
                     join channel WCG planetname #.

                     Packet Log
                     FF 4E 58 00

                     01

                     03

                     57 6F 72 6C 64 20 43 79 62 65 72 20 47 61 6D 65 73 20 28 53 61
                     74 75 72 6E 29 00

                     00

                     68 74 74 70 3A 2F 2F 77 77 77 2E 77 63 67 2E 63 6F 6D 00 57 43
                     47 00

                     00 00 00 00

                     80 07 01 00

                     00

                     00

                     00

                     00 01 01 00

                     02 02 00 00

                     00 00 01 05

                     00 00 00 00

                     32 00 00 00

]]
[SID_TOURNAMENT] = { -- 0x4E
	uint8("Unknown", base.HEX),
	uint8("Unknown, maybe number of non-null strings sent?", base.HEX),
	stringz("Description"),
	stringz("Unknown"),
	stringz("Website"),
	uint32("Unknown", base.HEX),
	stringz("Name"),
	stringz("Unknown"),
	stringz("Unknown"),
	stringz("Unknown"),
	array{label="Unknown", of=uint32, num=5},
},
--[[doc
    Message ID:    0x50

    Message Name:  SID_AUTH_INFO

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (DWORD) Logon Type
                   (DWORD) Server Token
                   (DWORD) UDPValue *
                   (FILETIME) MPQ filetime
                   (STRING) IX86ver filename
                   (STRING) ValueString

                   WAR3/W3XP Only:
                   (VOID) 128-byte Server signature

    Remarks:       Contains the Server Token, and the values used in CheckRevision.

                   Possible Logon Type values:

                   0x00: Broken SHA-1 (STAR/SEXP/D2DV/D2XP)0x01: NLS version 1
                   (War3Beta)

                   0x02: NLS Version 2 (WAR3/W3XP)

                   * UDPValue
                   No one really knows what this is, however, it is used in 2nd DWORD of
                   the UDP packet PKT_CONNTEST2. It is also the second part of MCP Chunk
                   1 in MCP_STARTUP.

    Related:       [0x50] SID_AUTH_INFO (C->S), [0x09] PKT_CONNTEST2 (C->S),
                   [0x01] MCP_STARTUP (C->S)

]]
[SID_AUTH_INFO] = { -- 0x50
	uint32{label="Logon Type", key="logontype", desc={
		[0x00] = "Broken SHA-1 (STAR/SEXP/D2DV/D2XP)",
		[0x01] = "NLS Version 1",
		[0x02] = "NLS Version 2 (WAR3/W3XP)",
	}},
	uint32("Server Token", base.HEX),
	uint32("UDPValue", base.HEX),
	wintime("MPQ filetime"),
	stringz("IX86ver filename"),
	stringz("ValueString"),
	when{ condition = Cond.equals("logontype", 2),
		block = { bytes{label="Server signature", length=128}},
	},
},
--[[doc
    Message ID:    0x51

    Message Name:  SID_AUTH_CHECK

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (DWORD) Result
                   (STRING) Additional Information

    Remarks:       Reports success/failure on version & CD Key check.

                   Result:
                   0x000: Passed challenge
                   0x100: Old game version (Additional info field supplies patch MPQ
                   filename)
                   0x101: Invalid version
                   0x102: Game version must be downgraded
                   (Additional info field supplies patch MPQ filename)
                   0x0NN: (where NN is the version code supplied in SID_AUTH_INFO):
                   Invalid version code (note that 0x100 is not set in this case).
                   0x200: Invalid CD key
                   0x201: CD key in use (Additional info field supplies name of user)
                   0x202: Banned key
                   0x203: Wrong product
                   The last 4 codes also apply to the second CDKey, as indicated by a
                   bitwise combination with 0x010.

                   If a patch file cannot be found, additional info is set to
                   'non-existent'. If either the executable size/date or the version code
                   is wrong, the server will typically return a failure status.

                   More:
                   While doing a little research on how Battle.net autoupdates it's
                   clients, I found that it (STAR, anyway) does not use the provisions of
                   the SID_AUTH login system to tell clients which update file to
                   download. Instead, it sends a SID_REPORTVERSION (from the previous
                   logon system) containing the equivalent error code and the name of the
                   patch file to download. This seems strange, and makes me think that
                   the part of Battle.net responsible for updating clients is isolated
                   from the part responsible for processing logon requests. If this is
                   the case, it makes sense that that system was never updated, since it
                   must still support legacy clients. In addition, this would explain why
                   most Blizzard clients retain obsolete packet processing code.

    Related:       [0x51] SID_AUTH_CHECK (C->S)

]]
[SID_AUTH_CHECK] = { -- 0x51
	uint32{label="Result", key="res", display = base.HEX, desc={
		[0x000] = "Passed challenge",
		[0x100] = "Old game version",
		[0x101] = "Invalid version",
		[0x102] = "Game version must be downgraded",
		-- ?? [0x0NN] = "(where NN is the version code supplied in SID_AUTH_INFO):
		-- Invalid version code (note that 0x100 is not set in this case)",
		[0x200] = "Invalid CD key",
		[0x201] = "CD key in use",
		[0x202] = "Banned key",
		[0x203] = "Wrong product",
		-- The last 4 codes also apply to the second CDKey, as indicated by a
		-- bitwise combination with 0x010.
		[0x210] = "Invalid second CD key",
		[0x211] = "Second CD key in use",
		[0x212] = "Banned second key",
		[0x213] = "Wrong product for second CD key",
	}},
	when{ -- TODO: Cond.in
		condition=function(self, state)
			return (state.packet.res == 0x100) or (state.packet.res == 0x102)
		end,
		block = { stringz("MPQ Filename") },
	},
	when{
		condition=function(self, state)
			return bit.band(state.packet.res, 0x201) == 0x201
		end,
		block = { stringz("Username") },
	},
},
--[[doc
    Message ID:    0x52

    Message Name:  SID_AUTH_ACCOUNTCREATE

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Status

    Remarks:       The message reports the success or failure of an account creation
                   attempt.

                   Status:

                   0x00: Successfully created account name.

                   0x04: Name already exists.

                   0x07: Name is too short/blank.

                   0x08: Name contains an illegal character.

                   0x09: Name contains an illegal word.

                   0x0a: Name contains too few alphanumeric characters.

                   0x0b: Name contains adjacent punctuation characters.

                   0x0c: Name contains too many punctuation characters.

                   Any other: Name already exists.

    Related:       [0x52] SID_AUTH_ACCOUNTCREATE (C->S)

]]
[SID_AUTH_ACCOUNTCREATE] = { -- 0x52
	uint32("Status", base.DEC, {
		[0x00] = "Successfully created account name.",
		[0x04] = "Name already exists.",
		[0x07] = "Name is too short/blank.",
		[0x08] = "Name contains an illegal character.",
		[0x09] = "Name contains an illegal word.",
		[0x0a] = "Name contains too few alphanumeric characters.",
		[0x0b] = "Name contains adjacent punctuation characters.",
		[0x0c] = "Name contains too many punctuation characters.",
	}),
},
--[[doc
    Message ID:    0x53

    Message Name:  SID_AUTH_ACCOUNTLOGON

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Status
                   (BYTE) [32] Salt (s)
                   (BYTE) [32] Server Key (B)

    Remarks:       Reports the success or failure of the logon request.

                   Possible status codes:

                   0x00: Logon accepted, requires proof.

                   0x01: Account doesn't exist.

                   0x05: Account requires upgrade.

                   Other: Unknown (failure).
                   See the [NLS/SRP Protocol] document for more information.

    Related:       [0x53] SID_AUTH_ACCOUNTLOGON (C->S)

]]
[SID_AUTH_ACCOUNTLOGON] = { -- 0x53
	uint32("Status", base.HEX, {
		[0x00] = "Logon accepted, requires proof.",
		[0x01] = "Account doesn't exist.",
		[0x05] = "Account requires upgrade.",
	}),
	array{of=uint8, num=32, label="Salt"},
	array{of=uint8, num=32, label="Server Key"},
},
--[[doc
    Message ID:    0x54

    Message Name:  SID_AUTH_ACCOUNTLOGONPROOF

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Status
                   (BYTE) [20] Server Password Proof (M2)
                   (STRING) Additional information

    Remarks:       Status

                   0x00: Logon successful.0x02: Incorrect password.

                   0x0E: An email address should be registered for this account.

                   0x0F: Custom error. A string at the end of this message contains
                   the error.
                   This message confirms the validity of the client password proof and
                   supplies the server password proof. See [NLS/SRP Protocol] for more
                   information.

    Related:       [0x54] SID_AUTH_ACCOUNTLOGONPROOF (C->S)

]]
[SID_AUTH_ACCOUNTLOGONPROOF] = { -- 0x54
	uint32{label="Status", display=base.DEC, desc={
		[0x00] = "Logon successful.",
		[0x02] = "Incorrect password.",
		[0x0E] = "An email address should be registered for this account.",
		[0x0F] = "Custom error. A string at the end of this message contains the error.",
	}, key="status"},
	array{of=uint8, num=20, label="Server Password Proof"},
	when{condition=Cond.equals("status", 0x0F), block={
		stringz("Additional information")
	}},
},
--[[doc
    Message ID:    0x55

    Message Name:  SID_AUTH_ACCOUNTCHANGE

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Status
                   (BYTE) [32] Salt (s)
                   (BYTE) [32] Server key (B)

    Remarks:       Reports success or failure on a password change operation.

                   Status Codes:

                   0x00: Change accepted, requires proof.

                   0x01: Account doesn't exist.

                   0x05: Account requires upgrade - see SID_AUTH_ACCOUNTUPGRADE

                   Other: Unknown (failure).
                   If an error occurs, the salt and server key values are set to zero.

    Related:       [0x55] SID_AUTH_ACCOUNTCHANGE (C->S),
                   [0x57] SID_AUTH_ACCOUNTUPGRADE (C->S)

]]
[SID_AUTH_ACCOUNTCHANGE] = { -- 0x55
	uint32("Status", base.DEC, {
		[0x00] = "Change accepted, requires proof.",
		[0x01] = "Account doesn't exist.",
		[0x05] = "Account requires upgrade",
	}),
	array{of=uint8, num=32, label="Salt"},
	array{of=uint8, num=32, label="Server Key"}
},
--[[doc
    Message ID:    0x56

    Message Name:  SID_AUTH_ACCOUNTCHANGEPROOF

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Status code
                   (BYTE) [20] Server password proof for old password (M2)

    Remarks:       This message reports success or failure for a password change
                   operation.

                   Status codes:

                   0x00: Password changed

                   0x02: Incorrect old password

    Related:       [0x56] SID_AUTH_ACCOUNTCHANGEPROOF (C->S)

]]
[SID_AUTH_ACCOUNTCHANGEPROOF] = { -- 0x56
	uint32("Status code", base.DEC, {
		[0x00] = "Password changed.",
		[0x02] = "Incorrect old password.",
	}),
	array{of=uint8, num=20, label="Server password proof for old password"},
},
--[[doc
    Message ID:      0x57

    Message Name:    SID_AUTH_ACCOUNTUPGRADE

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (DWORD) Status
                     (DWORD) Server Token

    Remarks:         Status Codes:

                     0x00: Upgrade request accepted.

                     Other: Upgrade request denied.

    Related:         [0x57] SID_AUTH_ACCOUNTUPGRADE (C->S),
                     [0x58] SID_AUTH_ACCOUNTUPGRADEPROOF (S->C),
                     [0x58] SID_AUTH_ACCOUNTUPGRADEPROOF (C->S)

]]
[SID_AUTH_ACCOUNTUPGRADE] = { -- 0x57
	uint32("Status", base.DEC, {
		[0x00] = "Upgrade Request Accepted",
		[0x01] = "Upgrade Request Denied",
	}),
	uint32("Server Token", base.HEX),
},
--[[doc
    Message ID:      0x58

    Message Name:    SID_AUTH_ACCOUNTUPGRADEPROOF

    Message Status:  DEFUNCT

    Direction:       Server -> Client (Received)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (DWORD) Status
                     (DWORD) [5] Password proof

    Remarks:         Status codes:

                     0x00: Password changed

                     0x02: Incorrect old password

    Related:         [0x57] SID_AUTH_ACCOUNTUPGRADE (S->C),
                     [0x57] SID_AUTH_ACCOUNTUPGRADE (C->S),
                     [0x58] SID_AUTH_ACCOUNTUPGRADEPROOF (C->S)

]]
[SID_AUTH_ACCOUNTUPGRADEPROOF] = { -- 0x58
	uint32("Status", base.DEC, {
		[0x00] = "Password changed.",
		[0x02] = "Incorrect old password.",
	}),
	array{of=uint32, num=5, label="Password proof"},
},
--[[doc
    Message ID:    0x59

    Message Name:  SID_SETEMAIL

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        [blank]

    Remarks:       Requests the client to bind an email address to the account.

                   See SID_SETEMAIL for more information.

    Related:       [0x59] SID_SETEMAIL (C->S)

]]
[SID_SETEMAIL] = { -- 0x59
},
--[[doc
    Message ID:    0x5E

    Message Name:  SID_WARDEN

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        (VOID) Encrypted Packet

                   Contents of encrypted data
                   (BYTE) Packet Code

                   0x00 - Warden Module Info
                   (DWORD)[4] MD5 Hash of the current Module

                   (DWORD)[4] Decryption key for Module

                   (DWORD) Length of Module
                   0x01 - Warden Module Data
                   (WORD) Length of data (without 3-byte header)

                   (VOID) Data
                   0x02 - Data Checker
                   (BYTE) String Length (Usually 0)

                   (VOID) String Data

                   (BYTE) Check ID

                   MEM_CHECK:

                   (BYTE) String Index (Usually 0)

                   (DWORD) Address

                   (BYTE) Length to Read
                   PAGE_CHECK_A:

                   (DWORD) Unknown (Seed?)

                   (DWORD)[5] SHA1

                   (DWORD) Address

                   (BYTE) Length to Read

                   (BYTE) IDXor
                   0x03 - Library Loader
                   (WORD) Length of data (without 7-byte header)

                   (DWORD) Checksum of data (without 7-byte header)

                   (BYTE) Unknown (0x01)

                   (BYTE) Unknown (Usually 0x00)

                   (BYTE) Unknown (Usually 0x01)

                   (STRING) Library Name

                   (DWORD) Funct1

                   (DWORD) Funct2

                   (DWORD) Funct3

                   (DWORD) Funct4
                   0x05 - Initialization
                   (DWORD)[5] Unknown

    Remarks:       This packet is received after successfully logging onto Battle.net and
                   usually after receiving the first initial chat events. If the client
                   does not respond to this packet, the client gets dropped two minutes
                   later (give or take about 10 seconds).

                   The packet is encrypted via standard RC4 hashing, using one key for
                   outbound data and another for inbound. Its purpose is to download and
                   execute Warden modules. Full information on how to handle this packet
                   may be found at the Rudimentary Warden information topic.

                   Documentation provided by iago and Ringo.

    Related:       [0x5E] SID_WARDEN (C->S)

]]
[SID_WARDEN] = { -- 0x5E
	bytes{label="Encrypted Packet",
		size=function(self, state) return state.packet.length end,
	},
--[[TODO
	uint8("Packet Code"),
	uint32("[4] MD5 Hash of the current Module"),
	uint32("[4] Decryption key for Module"),
	uint32("Length of Module"),
	uint16("Length of data"),
	bytes("Data"),
	uint8("String Length"),
	bytes("String Data"),
	uint8("Check ID"),
	uint8("String Index"),
	uint32("Address"),
	uint8("Length to Read"),
	uint32("Unknown"),
	uint32("[5] SHA1"),
	uint32("Address"),
	uint8("Length to Read"),
	uint8("IDXor"),
	uint16("Length of data"),
	uint32("Checksum of data"),
	uint8("Unknown"),
	uint8("Unknown"),
	uint8("Unknown"),
	stringz("Library Name"),
	uint32("Funct1"),
	uint32("Funct2"),
	uint32("Funct3"),
	uint32("Funct4"),
	uint32("[5] Unknown"),
]]
},
--[[doc
    Message ID:    0x60

    Message Name:  SID_GAMEPLAYERSEARCH

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) Number of players
                   (STRING) [] Player names

    Remarks:       Returns a list of available players for an arranged team ladder game.
                   Players who are considered available: have no away message on, are
                   mutual friends in the chat environment, or non-friend listed users in
                   the same channel as you.

    Related:       [0x60] SID_GAMEPLAYERSEARCH (C->S)

]]
[SID_GAMEPLAYERSEARCH] = { -- 0x60
	uint8{label="Number of players", key="players"},
	iterator{alias="none", refkey="players", repeated={
		stringz("Player name"),
	}},
},
--[[doc
    Message ID:    0x65

    Message Name:  SID_FRIENDSLIST

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        (BYTE) Number of Entries
                   For each entry:
                   (STRING) Account
                   (BYTE) Status
                   (BYTE) Location
                   (DWORD) ProductID
                   (STRING) Location name

    Remarks:       This packet contains the current user's Friends List. If the friend is
                   offline, their ProductID is 0. Location is only supplied when it is
                   relevant - for example, if Status is set to offline (0x00), the
                   location string will be empty.

                   Possible bitwise values for Status:
                   0x01: Mutual
                   0x02: DND
                   0x04: Away
                   Possible values for Location:
                   0x00: Offline
                   0x01: Not in chat
                   0x02: In chat
                   0x03: In a public game
                   0x04: In a private game, and you are not that person's friend.
                   0x05: In a private game, and you are that person's friend.

                   Whether you are a particular user's friend causes different behavior
                   when receiving information about the type of game the user is in (this
                   is true when receiving friend updates, too). When the Location field
                   is 0x04, the user is in a password-protected game, and you are not on
                   that user's friends list. When it is 0x05, the user is in a
                   password-protected game, and you are on that user's friends list.

                   For example, let's say MyndFyre is logging on and Arta[vL] is on his
                   friends list. Arta[vL] is also in a password-protected game. MyndFyre
                   is not on Arta[vL]'s friends list. MyndFyre will receive location 0x04
                   for Arta[vL] and the Channel parameter will be a NULL string. And, if
                   MyndFyre were to type in /f l, Battle.net would respond with
                   SID_CHATEVENT saying "1. Arta[vL] is in a private game."

                   On the other hand, if Arta[vL] had listed MyndFyre as a friend, then
                   on logon, MyndFyre will receive location 0x05 for Arta[vL] and the
                   name of the password-protected game will come through the Channel
                   parameter of the message. If MyndFyre were to type in /f l, Battle.net
                   would respond with "1. Arta[vL] is in the private game vL."

    Related:       [0x0F] SID_CHATEVENT (S->C), [0x65] SID_FRIENDSLIST (C->S)

]]
[SID_FRIENDSLIST] = { -- 0x65
	uint8{label="Number of Entries", key="friends"},
	iterator{label="Friend", refkey="friends", repeated={
		stringz("Account"),
		flags{of=uint8, label="Status", fields={
			{sname="Mutual", mask=0x01, desc=Descs.YesNo},
			{sname="DND", mask=0x02, desc=Descs.YesNo},
			{sname="Away", mask=0x04, desc=Descs.YesNo} 
		}},
		uint8("Location", base.DEC, {
			[0x00] = "Offline",
			[0x01] = "Not in chat",
			[0x02] = "In chat",
			[0x03] = "In a public game",
			[0x04] = "In a private game, and you are not that person's friend.",
			[0x05] = "In a private game, and you are that person's friend.",
		}),
		strdw("ProductID"),
		stringz("Location name"),
	}},
},
--[[doc
    Message ID:    0x66

    Message Name:  SID_FRIENDSUPDATE

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        (BYTE) Entry number
                   (BYTE) Friend Location
                   (BYTE) Friend Status
                   (DWORD) ProductID
                   (STRING) Location

    Remarks:       Sent to clients supporting this packet when the friendlisted account's
                   Status changes. The first friend is always entry 0.

                   Note that there is a Battle.net server bug in which when you are
                   automatically sent this packet, the Product ID is your own Product ID
                   instead of your friend's. So if you were to be using WAR3, for
                   example, and a friend signs on using SEXP, the Product ID in this
                   packet will be WAR3. To receive the *correct* Product ID for the user,
                   you may request another update for this user (by sending 0x66 back to
                   the server with the same Entry Number), or request the full list
                   again.

                   In addition, this packet is not sent to you automatically if the
                   friendship is not mutual.

    Related:       [0x66] SID_FRIENDSUPDATE (C->S), [0x65] SID_FRIENDSLIST (S->C)

]]
[SID_FRIENDSUPDATE] = { -- 0x66
	uint8("Entry number"),
	flags{of=uint8, label="Status", fields={
		{sname="Mutual", mask=0x01, desc=Descs.YesNo},
		{sname="DND", mask=0x02, desc=Descs.YesNo},
		{sname="Away", mask=0x04, desc=Descs.YesNo} 
	}},
	uint8("Location", base.DEC, {
		[0x00] = "Offline",
		[0x01] = "Not in chat",
		[0x02] = "In chat",
		[0x03] = "In a public game",
		[0x04] = "In a private game, and you are not that person's friend.",
		[0x05] = "In a private game, and you are that person's friend.",
	}),
	strdw("ProductID"),
	stringz("Location name"),
},
--[[doc
    Message ID:    0x67

    Message Name:  SID_FRIENDSADD

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        (STRING) Account
                   (BYTE) Friend Type
                   (BYTE) Friend Status
                   (DWORD) ProductID
                   (STRING) Location

    Remarks:       Sent to clients supporting this packet when an account is added to the
                   client's friendlist. New friends are appended to the list.

                   Values and meanings for Friend Type:

                   0x00: Non-mutual
                   0x01: Mutual
                   0x02: Nonmutual, DND
                   0x03: Mutual, DND
                   0x04: Nonmutual, Away
                   0x05: Mutual, Away

                   Value and meanings for Friend Status:

                   0x00: Offline
                   0x02: In chat
                   0x03: In public game
                   0x05: In private game

                   See SID_FRIENDSLIST for more information.

    Related:       [0x65] SID_FRIENDSLIST (S->C)

]]
[SID_FRIENDSADD] = { -- 0x67
	stringz("Account"),
	uint8("Friend Type", base.DEC, {
		[0x00] = "Non-mutual",
		[0x01] = "Mutual",
		[0x02] = "Nonmutual, DND",
		[0x03] = "Mutual, DND",
		[0x04] = "Nonmutual, Away",
		[0x05] = "Mutual, Away",
	}),
	uint8("Friend Status", base.DEC, {
		[0x00] = "Offline",
		[0x02] = "In chat",
		[0x03] = "In public game",
		[0x05] = "In private game",
	}),
	uint32("ProductID", base.HEX),
	stringz("Location"),
},
--[[doc
    Message ID:    0x68

    Message Name:  SID_FRIENDSREMOVE

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        (BYTE) Entry Number

    Remarks:       Sent to clients supporting this packet when an entry is removed from
                   the client's friendlist. Accounts positioned after the specified Entry
                   Number in the friendlist are moved up by one.

                   See SID_FRIENDSLIST for more information.

    Related:       [0x65] SID_FRIENDSLIST (S->C)

]]
[SID_FRIENDSREMOVE] = { -- 0x68
	uint8("Entry Number"),
},
--[[doc
    Message ID:    0x69

    Message Name:  SID_FRIENDSPOSITION

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        (BYTE) Old Position
                   (BYTE) New Position

    Remarks:       Sent to clients supporting this packet when a friend is promoted or
                   demoted the friend's list.

                   See SID_FRIENDSLIST for more information.

    Related:       [0x65] SID_FRIENDSLIST (S->C)

]]
[SID_FRIENDSPOSITION] = { -- 0x69
	uint8("Old Position"),
	uint8("New Position"),
},
--[[doc
    Message ID:    0x70

    Message Name:  SID_CLANFINDCANDIDATES

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (BYTE) Status
                   (BYTE) Number of potential candidates
                   (STRING) [] Usernames

    Remarks:       Contains the list of potential candidates.

                   Valid Status codes:

                   0x00: Successfully found candidate(s) 0x01: Clan tag already
                   taken 0x08: Already in clan 0x0a: Invalid clan tag specified

    Related:       [0x70] SID_CLANFINDCANDIDATES (C->S), Clan Message Codes

]]
[SID_CLANFINDCANDIDATES] = { -- 0x70
	uint32("Cookie", base.HEX),
	uint8("Status", base.DEC, {
		[0x00] = "Successfully found candidate(s)",
		[0x01] = "Clan tag already taken",
		[0x08] = "Already in clan",
		[0x0a] = "Invalid clan tag specified",
	}),
	uint8{label="Number of potential candidates", key="names"},
	iterator{alias="none", refkey="names", repeted={
		stringz("Username"),
	}},
},
--[[doc
    Message ID:    0x71

    Message Name:  SID_CLANINVITEMULTIPLE

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (BYTE) Result
                   (STRING) [] Failed account names

    Remarks:       Multiple invitation response.

                   Result:

                   0x00: Success (everyone accepted) 0x04: Declined 0x05: Not
                   available (not in channel or already in a clan)

                   Failed account names:

                   A list of accountnames which failed to accept the invitation
                   successfully. On complete success, this is null.

    Related:       [0x71] SID_CLANINVITEMULTIPLE (C->S), Clan Message Codes

]]
[SID_CLANINVITEMULTIPLE] = { -- 0x71
	uint32("Cookie", base.HEX),
	uint8("Result", base.DEC, {
		[0x00] = "Everyone accepted",
		[0x04] = "Declined",
		[0x05] = "Not available",
	}),
	iterator{
		alias="none",
		condition = function(self, state) return state.packet.acc ~="" end,
		repeated = {
			stringz{label="Failed Account", key="acc"},
		}
	}
},
--[[doc
    Message ID:    0x72

    Message Name:  SID_CLANCREATIONINVITATION

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) Clan Tag
                   (STRING) Clan Name
                   (STRING) Inviter's username
                   (BYTE) Number of users being invited
                   (STRING) [] List of users being invited

    Remarks:       Received when a user is inviting you to create a new clan on
                   Battle.net.

    Related:       [0x72] SID_CLANCREATIONINVITATION (C->S)

]]
[SID_CLANCREATIONINVITATION] = { -- 0x72
	uint32("Cookie", base.HEX),
	uint32("Clan Tag"),
	stringz("Clan Name"),
	stringz("Inviter's username"),
	uint8{label="Number of users being invited", key="users"},
	iterator{refkey="users", label="Invited users", repeated={
		stringz("Name"),
	}},
},
--[[doc
    Message ID:    0x73

    Message Name:  SID_CLANDISBAND

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (BYTE) Result

    Remarks:       Result:

                   0x00: Successfully disbanded the clan 0x02: Cannot quit clan,
                   not one week old yet 0x07: Not authorized to disband the clan

    Related:       [0x73] SID_CLANDISBAND (C->S), Clan Message Codes

]]
[SID_CLANDISBAND] = { -- 0x73
	uint32("Cookie"),
	uint8("Result"),
},
--[[doc
    Message ID:    0x74

    Message Name:  SID_CLANMAKECHIEFTAIN

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (BYTE) Status

    Remarks:       Notifies the sending client of the success/failure of its request.
                   Status:

                   0x00: Success 0x02: Can't change until clan is a week old 0x04:
                   Declined 0x05: Failed 0x07: Not Authorized 0x08: Not Allowed

    Related:       [0x74] SID_CLANMAKECHIEFTAIN (C->S), Clan Message Codes

]]
[SID_CLANMAKECHIEFTAIN] = { -- 0x74
	uint32("Cookie"),
	uint8("Status"),
},
--[[doc
    Message ID:    0x75

    Message Name:  SID_CLANINFO

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) Unknown (0)
                   (DWORD) Clan tag
                   (BYTE) Rank

    Remarks:       This message is received when logging on, if you're a member of a
                   clan. It is also sent when you join a clan.

                   Possible values for Rank:

                   0x00: Initiate that has been in the clan for less than one week
                   0x01: Initiate that has been in the clan for over one week 0x02:
                   Member 0x03: Officer 0x04: Leader

    Related:       Clan Message Codes

]]
[SID_CLANINFO] = { -- 0x75
	uint8("Unknown"),
	uint32("Clan tag"),
	uint8("Rank"),
},
--[[doc
    Message ID:    0x76

    Message Name:  SID_CLANQUITNOTIFY

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) Status

    Remarks:       The only known status code for this packet is 0x01 (Removed from
                   clan).

    Related:       Clan Message Codes

]]
[SID_CLANQUITNOTIFY] = { -- 0x76
	uint8("Status"),
},
--[[doc
    Message ID:    0x77

    Message Name:  SID_CLANINVITATION

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (BYTE) Result

    Remarks:       This packet is sent to inform the client of the reply to an
                   invitation.

                   Result:

                   0x00: Invitation accepted 0x04: Invitation declined 0x05: Failed
                   to invite user 0x09: Clan is full

    Related:       [0x77] SID_CLANINVITATION (C->S)

]]
[SID_CLANINVITATION] = { -- 0x77
	uint32("Cookie"),
	uint8("Result"),
},
--[[doc
    Message ID:    0x78

    Message Name:  SID_CLANREMOVEMEMBER

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (BYTE) Status

    Remarks:       Response when removing a member from your clan.

                   Status constants:

                   0x00: Removed 0x01: Removal failed 0x02: Can not be removed yet
                   0x07: Not authorized to remove 0x08: Not allowed to remove

    Related:       [0x78] SID_CLANREMOVEMEMBER (C->S), Clan Message Codes

]]
[SID_CLANREMOVEMEMBER] = { -- 0x78
	uint32("Cookie"),
	uint8("Status"),
},
--[[doc
    Message ID:    0x79

    Message Name:  SID_CLANINVITATIONRESPONSE

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) Clan tag
                   (STRING) Clan name
                   (STRING) Inviter

    Remarks:       This packet is recieved when someone invites you to join a clan.

    Related:       [0x79] SID_CLANINVITATIONRESPONSE (C->S), Clan Message Codes

]]
[SID_CLANINVITATIONRESPONSE] = { -- 0x79
	uint32("Cookie"),
	uint32("Clan tag"),
	stringz("Clan name"),
	stringz("Inviter"),
},
--[[doc
    Message ID:    0x7A

    Message Name:  SID_CLANRANKCHANGE

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (BYTE) Status

    Remarks:       This message returns the result of the clan rank change request.

                   Result:

                   0x00: Successfully changed rank 0x01: Failed to change rank
                   0x02: Cannot change user's rank yet 0x07: Not authorized to
                   change user rank * 0x08: Not allowed to change user rank **

                   * This will be received when you are not a shaman/chieftain and you're
                   trying to change the rank of another user.

                   ** This will be received when you are trying to change rank of someone
                   who is higher than you, i.e. chieftain, or an initiate.

    Related:       [0x7A] SID_CLANRANKCHANGE (C->S), Clan Message Codes

]]
[SID_CLANRANKCHANGE] = { -- 0x7A
	uint32("Cookie"),
	uint8("Status"),
},
--[[doc
    Message ID:    0x7C

    Message Name:  SID_CLANMOTD

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) Unknown (0)
                   (STRING) MOTD

    Remarks:       This message contains the clan's Message of the Day.

    Related:       [0x7C] SID_CLANMOTD (C->S)

]]
[SID_CLANMOTD] = { -- 0x7C
	uint32("Cookie"),
	uint32("Unknown"),
	stringz("MOTD"),
},
--[[doc
    Message ID:    0x7D

    Message Name:  SID_CLANMEMBERLIST

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (BYTE) Number of Members
                   For each member:

                   (STRING) Username (BYTE) Rank (BYTE) Online Status (STRING)
                   Location

    Remarks:       Contains the members of a clan.

                   Online Status:

                   0x00: Offline 0x01: Online

                   Rank:

                   0x00: Initiate that has been in the clan for less than one week
                   0x01: Initiate that has been in the clan for over one week 0x02:
                   Member 0x03: Officer 0x04: Leader

                   Location:

                   Where the user is, i.e., game name, channel name, or this may be
                   null if the user is not online.

    Related:       [0x7D] SID_CLANMEMBERLIST (C->S), Clan Message Codes

]]
[SID_CLANMEMBERLIST] = { -- 0x7D
	uint32("Cookie"),
	uint8("Number of Members"),
	stringz("Username"),
	uint8("Rank"),
	uint8("Online Status"),
	stringz("Location"),
},
--[[doc
    Message ID:    0x7E

    Message Name:  SID_CLANMEMBERREMOVED

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (STRING) Clan member name

    Remarks:       Notifies the members of a clan that a user has been removed.

]]
[SID_CLANMEMBERREMOVED] = { -- 0x7E
	stringz("Clan member name"),
},
--[[doc
    Message ID:    0x7F

    Message Name:  SID_CLANMEMBERSTATUSCHANGE

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (STRING) Username
                   (BYTE) Rank
                   (BYTE) Status
                   (STRING) Location

    Remarks:       This message is received when a member changes their status (by going
                   online, offline, being promoted, etc).

                   Username:

                   The name of the member whose status is changing (by going
                   online, offline, being promoted, etc).

                   Rank:

                   0x00: Initiate that has been in the clan for less than one week
                   0x01: Initiate that has been in the clan for over one week 0x02:
                   Member 0x03: Officer 0x04: Leader

                   Status:

                   0x00: Offline 0x01: Online (not in either channel or game) 0x02:
                   In a channel 0x03: In a public game 0x05: In a private game

                   Location:

                   This field is where the user is, i.e., game name, channel name.

    Related:       Clan Message Codes

]]
[SID_CLANMEMBERSTATUSCHANGE] = { -- 0x7F
	stringz("Username"),
	uint8("Rank", base.DEC, {
		[0x00] = "Initiate that has been in the clan for less than one week",
		[0x01] = "Initiate that has been in the clan for over one week",
		[0x02] = "Member",
		[0x03] = "Officer",
		[0x04] = "Leader",
	}),
	uint8("Status", base.DEC, {
		[0x00] = "Offline",
		[0x01] = "Online (not in either channel or game)",
		[0x02] = "In a channel",
		[0x03] = "In a public game",
		[0x05] = "In a private game)",
	}),
	stringz("Location"),
},
--[[doc
    Message ID:    0x81

    Message Name:  SID_CLANMEMBERRANKCHANGE

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) Old rank
                   (BYTE) New rank
                   (STRING) Clan member who changed your rank

    Remarks:       Received from the server when a user is promoted or demoted.

                   For information about the allowed values for the old and new rank
                   fields, see [Clan Message Codes].

    Related:       Clan Message Codes

]]
[SID_CLANMEMBERRANKCHANGE] = { -- 0x81
	uint8("Old rank"),
	uint8("New rank"),
	stringz("Clan member who changed your rank"),
},
--[[doc
    Message ID:    0x82

    Message Name:  SID_CLANMEMBERINFORMATION

    Direction:     Server -> Client (Received)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (BYTE) Status code
                   (STRING) Clan name
                   (BYTE) User's rank
                   (FILETIME) Date joined

    Remarks:       Status code:
                   This message follows the same status codes as listed on the Clan
                   Message Codes page.

                   0x00 = success

                   0x0C = user not found in that clan

    Related:       [0x82] SID_CLANMEMBERINFORMATION (C->S), Clan Message Codes

]]
[SID_CLANMEMBERINFORMATION] = { -- 0x82
	uint32("Cookie"),
	uint8("Status code"),
	stringz("Clan name"),
	uint8("User's rank"),
	wintime("Date joined"),
},
}
