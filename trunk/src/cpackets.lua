-- Packets from client to server
CPacketDescription = {
--[[doc
    Message ID:    0x00

    Message Name:  BNLS_NULL

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III, World of Warcraft

    Format:        [blank]

    Remarks:       This message is empty and may be used to keep the connection alive.
                   The client is not required to send this. There is no response from the
                   server.

                   If the connection to the BNLS server is idle for more than one minute,
                   the BNLS server will disconnect the client. To avoid that, use this
                   message.

]]
[BNLS_NULL] = { -- 0x00
},
--[[doc
    Message ID:    0x01

    Message Name:  BNLS_CDKEY

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III, World of Warcraft

    Format:        (DWORD) Server Token

                   (STRING) CD key

    Remarks:       This message will encrypt your CD-key, and will reply with the
                   properly encoded CD-key as it is supposed to be sent in the message
                   SID_AUTH_CHECK (0x51). It now works with CD-keys of all products.

    Related:       [0x50] SID_AUTH_INFO (S->C), [0x51] SID_AUTH_CHECK (C->S),
                   [0x01] BNLS_CDKEY (S->C)

]]
[BNLS_CDKEY] = { -- 0x01
	uint32("Server Token"),
	stringz("CD key"),
},
--[[doc
    Message ID:    0x02

    Message Name:  BNLS_LOGONCHALLENGE

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (STRING) Account name
                   (STRING) Password

    Remarks:       This message will give you data you need for SID_AUTH_ACCOUNTLOGON
                   (0x53). You must send this before you can send BNLS_LOGONPROOF (0x03).

    Related:       [0x53] SID_AUTH_ACCOUNTLOGON (S->C), [0x03] BNLS_LOGONPROOF (C->S),
                   [0x02] BNLS_LOGONCHALLENGE (S->C)

]]
[BNLS_LOGONCHALLENGE] = { -- 0x02
	stringz("Account name"),
	stringz("Password"),
},
--[[doc
    Message ID:    0x03

    Message Name:  BNLS_LOGONPROOF

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD)[16] Data from SID_AUTH_ACCOUNTLOGON

    Remarks:       This message will parse data from SID_AUTH_ACCOUNTLOGON (0x53) and
                   will reply with data to send in SID_AUTH_ACCOUNTLOGONPROOF (0x54). You
                   must send BNLS_LOGONCHALLENGE (0x02) before you can send this.

    Related:       [0x53] SID_AUTH_ACCOUNTLOGON (S->C),
                   [0x54] SID_AUTH_ACCOUNTLOGONPROOF (C->S),
                   [0x02] BNLS_LOGONCHALLENGE (C->S), [0x03] BNLS_LOGONPROOF (S->C)

]]
[BNLS_LOGONPROOF] = { -- 0x03
	uint32("[16] Data from SID_AUTH_ACCOUNTLOGON"),
},
--[[doc
    Message ID:      0x04

    Message Name:    BNLS_CREATEACCOUNT

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (STRING) Account name.(STRING) Account password.

    Remarks:         This message will request the data you need for SID_AUTH_ACCOUNTCREATE
                     (0x52). Related Links: [C>0x52] SID_AUTH_ACCOUNTCREATE, [S>0x04]
                     BNLS_CREATEACCOUNT

]]
[BNLS_CREATEACCOUNT] = { -- 0x04
	stringz("Account name."),
	stringz("Account password."),
},
--[[doc
    Message ID:      0x05

    Message Name:    BNLS_CHANGECHALLENGE

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (STRING) Account name.(STRING) Account old password.(STRING) Account
                     new password.

    Remarks:         This message will give you data you need for SID_AUTH_ACCOUNTCHANGE
                     (0x55). This message is used to change the password of an existing
                     account.
                     You must send this before you can send BNLS_CHANGEPROOF (0x06).
                     Related Links: [C>0x55] SID_AUTH_ACCOUNTCHANGE, [C>0x06]
                     BNLS_CHANGEPROOF, [S>0x05] BNLS_CHANGECHALLENGE

]]
[BNLS_CHANGECHALLENGE] = { -- 0x05
	stringz("Account name."),
	stringz("Account old password."),
	stringz("Account"),
},
--[[doc
    Message ID:      0x06

    Message Name:    BNLS_CHANGEPROOF

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo, Diablo II

    Format:          (DWORD[16]) Data from SID_AUTH_ACCOUNTCHANGE (0x55).

    Remarks:         This message will parse data from SID_AUTH_ACCOUNTCHANGE (0x55) and
                     will reply with data to send in SID_AUTH_ACCOUNTCHANGEPROOF (0x56).
                     You must send BNLS_CHANGECHALLENGE (0x05) before you can send this.
                     Related Links: [S>0x55] SID_AUTH_ACCOUNTCHANGE, [C>0x56]
                     SID_AUTH_ACCOUNTCHANGEPROOF, [C>0x05] BNLS_CHANGECHALLENGE, [S>0x06]
                     BNLS_CHANGEPROOF

]]
[BNLS_CHANGEPROOF] = { -- 0x06
	uint32{label="Data from SID_AUTH_ACCOUNTCHANGE", num=16},
},
--[[doc
    Message ID:      0x07

    Message Name:    BNLS_UPGRADECHALLENGE

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (STRING) Account name.(STRING) Account old password.(STRING) Account
                     new password. (May be identical to old password but still must be
                     provided.)

    Remarks:         This message will give you data you need for SID_AUTH_ACCOUNTUPGRADE
                     (0x57).
                     This message is used to upgrade an existing account from Old Logon
                     System to New Logon System.
                     You must send this before you can send BNLS_UPGRADEPROOF (0x08).

                     Important: You must send BNLS_LOGONCHALLENGE (0x02) or
                     BNLS_CHANGECHALLENGE (0x05) before sending this. Otherwise, the
                     results are meaningless.

                     Note: Since Old Logon System and New Logon System are incompatible,
                     you can change the password and upgrade the account at the same time.
                     This is not required - the old password and the new password may be
                     identical for this message. Related Links: [C>0x57]
                     SID_AUTH_ACCOUNTUPGRADE, [C>0x08] BNLS_UPGRADEPROOF, [C>0x02]
                     BNLS_LOGONCHALLENGE, [C>0x05] BNLS_CHANGECHALLENGE, [S>0x07]
                     BNLS_UPGRADECHALLENGE

]]
[BNLS_UPGRADECHALLENGE] = { -- 0x07
	stringz("Account name."),
	stringz("Account old password."),
	stringz("Account"),
},
--[[doc
    Message ID:      0x08

    Message Name:    BNLS_UPGRADEPROOF

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III, Warcraft III: The Frozen Throne

    Format:          (DWORD) Session key from SID_AUTH_ACCOUNTUPGRADE (0x57).

    Remarks:         This message will parse data from SID_AUTH_ACCOUNTUPGRADE (0x57) and
                     will reply with data to send in SID_AUTH_ACCOUNTUPGRADEPROOF (0x58).
                     You must send BNLS_UPGRADECHALLENGE (0x07) before you can send this.
                     Related Links: [S>0x57] SID_AUTH_ACCOUNTUPGRADE, [C>0x07]
                     BNLS_UPGRADECHALLENGE, [S>0x08] BNLS_UPGRADEPROOF

]]
[BNLS_UPGRADEPROOF] = { -- 0x08
	uint32("Session key from SID_AUTH_ACCOUNTUPGRADE"),
},
--[[doc
    Message ID:      0x09

    Message Name:    BNLS_VERSIONCHECK

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Unknown

    Format:          (DWORD) Product ID.
                     (DWORD) Version DLL digit
                     (STRING) Checksum formula.

    Remarks:         This message will request a fast version check. Now works with all
                     products.

                     Version DLL Digit must be in the range 0-7. (For example, for
                     IX86Ver1.mpq this is 1)

                     Valid ProductIDs are:

                     0x01: Starcraft
                     0x02: Starcraft: Broodwar
                     0x03: Warcraft II: BNE
                     0x04: Diablo II
                     0x05: Diablo II: LoD
                     0x06: Starcraft: Japanese
                     0x07: Warcraft III
                     0x08: Warcraft III: The Frozen Throne

                     If you are not using BNLS, and are instead using JBLS or something
                     equivalent, there are also:

                     0x09: Diablo Retail
                     0x0A: Diablo Shareware
                     0x0B: Starcraft Shareware

                     View consts: [pas cpp vb] Related Links: [S>0x09] BNLS_VERSIONCHECK

]]
[BNLS_VERSIONCHECK] = { -- 0x09
	uint32("Product ID."),
	uint32("Version DLL digit"),
	stringz("Checksum formula."),
},
--[[doc
    Message ID:      0x0A

    Message Name:    BNLS_CONFIRMLOGON

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         All Products

    Format:          (DWORD[5]) Password proof from Battle.net.

    Remarks:         This message will confirm that the server really knows your password.

                     This packet may only be used after "proof" messages: BNLS_LOGONPROOF
                     (0x03), BNLS_CHANGEPROOF (0x06), BNLS_UPGRADEPROOF (0x08). Related
                     Links: [C>0x03] BNLS_LOGONPROOF, [C>0x06] BNLS_CHANGEPROOF, [C>0x08]
                     BNLS_UPGRADEPROOF, [S>0x0A] BNLS_CONFIRMLOGON

]]
[BNLS_CONFIRMLOGON] = { -- 0x0A
	uint32{label="Password proof from Battle.net.", num=5},
},
--[[doc
    Message ID:      0x0B

    Message Name:    BNLS_HASHDATA

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (DWORD) Size of Data
                     (DWORD) Flags
                     (VOID) Data to be hashed.
                     Optional:
                     (DWORD) Client Key
                     (Double Hash only)(DWORD) Server Key
                     (Double Hash only)(DWORD) Cookie (Cookie Hash only)

    Remarks:         This message will calculate the hash of the given data.
                     The hashing algorithm used is the Battle.net standard hashing
                     algorithm also known as "Broken SHA-1"

                     The flags may be zero, or any bitwise combination of the defined
                     flags.
                     Currently, the following flags are defined:

                     0x01: Flags Unused
                     This flag has no effect.

                     0x02: Double Hash
                     If this flag is present, the server will calculate a double hash.
                     First it will calculate the hash of the data. Then it will prepend the
                     client key and the server key to the resulting hash, and calculate the
                     hash of the result. If this flag is present, the client key and server
                     key DWORDs must be specified in the request after the data.
                     This may be used to calculate password hashes for the "Old Logon
                     System".

                     0x04: Cookie Hash
                     If this flag is present, a cookie DWORD is specified in the request.
                     This is an application-defined value that is echoed back to the client
                     in the response.

                     View consts: [pas cpp vb] Related Links: [S>0x0B] BNLS_HASHDATA

]]
[BNLS_HASHDATA] = { -- 0x0B
	uint32("Size of Data"),
	uint32("Flags"),
	bytes("Data to be hashed."),
	uint32("Client Key"),
	uint32("Server Key"),
	uint32("Cookie"),
},
--[[doc
    Message ID:      0x0C

    Message Name:    BNLS_CDKEY_EX

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo, Diablo II

    Format:          (DWORD) Cookie. (BYTE) Number of CD-keys to encrypt.(DWORD)
                     Flags.(DWORD[]) Server session key(s), depending on flags.(DWORD[])
                     Client session key(s), depending on flags.(STRING[]) CD-keys. No
                     dashes or spaces.

    Remarks:         The Cookie has no special meaning to the server and will simply be
                     echoed to the client in the response. The client can use multiple
                     types of CD-keys in the same packet. The number of CD Keys to encrypt
                     should be between 1 and 32.

                     The flags may be zero, or any bitwise combination of the defined
                     flags.
                     Currently, the following flags are defined:

                     0x01: CDKEY_SAME_SESSION_KEY
                     0x02: CDKEY_GIVEN_SESSION_KEY
                     0x04: CDKEY_MULTI_SERVER_SESSION_KEYS
                     0x08: CDKEY_OLD_STYLE_RESPONSES

                     View consts: [pas cpp vb]

                     CDKEY_SAME_SESSION_KEY (0x01):
                     This flag specifies that all the returned CD-keys will use the same
                     client session key. When used in combination with
                     CDKEY_GIVEN_SESSION_KEY (0x02), a single client session key is
                     specified immediately after the server session key(s). When used
                     without CDKEY_GIVEN_SESSION_KEY (0x02), a client session key isn't
                     sent in the request, and the server will create one.
                     When not used, each CD-key gets its own client session key. This flag
                     has no effect if the amount of CD-keys to encrypt is 1.

                     CDKEY_GIVEN_SESSION_KEY (0x02):
                     This flag specifies that the client session keys to be used are
                     specified in the request. When used in combination with
                     CDKEY_SAME_SESSION_KEY (0x01), a single client session key is
                     specified immediately after the server session key(s). When used
                     without CDKEY_SAME_SESSION_KEY (0x01), an array of client session keys
                     (as many as the amount of CD-keys) is specified. When not used, client
                     session keys aren't included in the request.

                     CDKEY_MULTI_SERVER_SESSION_KEYS (0x04):
                     This flag specifies that each CD-key has its own server session key.
                     When specified, an array of server session keys (as many as the amount
                     of CD-keys) is specified. When not specified, a single server session
                     key is specified.
                     This flag has no effect if the amount of CD-keys to encrypt is 1.

                     CDKEY_OLD_STYLE_RESPONSES (0x08):
                     Specifies that the response to this packet is a number of BNLS_CDKEY
                     (0x01) responses, instead of a BNLS_CDKEY_EX (0x0c) response. The
                     responses are guaranteed to be in the order of the CD-keys' appearance
                     in the request. Note that when this flag is specified, the Cookie
                     cannot be echoed. (It must still be included in the request.)

                     Note: When using Lord of Destruction, two CD-keys are encrypted, and
                     they must share the same client session key. There are several ways to
                     do this. One way is to provide both CD-keys in this packet, using the
                     flag CDKEY_SAME_SESSION_KEY (0x01). Another way is to use BNLS_CDKEY
                     (0x01) to encrypt the first CD-key, then use this packet with the flag
                     CDKEY_GIVEN_SESSION_KEY (0x02) to encrypt the second CD-key with the
                     same client session key. Related Links: [S>0x01] BNLS_CDKEY, [S>0x0C]
                     BNLS_CDKEY_EX, [C>0x01] BNLS_CDKEY

]]
[BNLS_CDKEY_EX] = { -- 0x0C
	uint32("Cookie."),
	uint8("Number of CD-keys to encrypt."),
	uint32("Flags."),
	uint32{label="Server session key", todo="verify array length"},
	uint32{label="Client session key", todo="verify array length"},
	stringz{label="CD-keys. No", todo="verify array length"},
},
--[[doc
    Message ID:      0x0D

    Message Name:    BNLS_CHOOSENLSREVISION

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) NLS revision number.

    Remarks:         This message instructs the server which revision of NLS you want to
                     use.

                     The NLS revision number is given by Battle.net in SID_AUTH_INFO
                     (0x50). Related Links: [S>0x50] SID_AUTH_INFO, [S>0x0D]
                     BNLS_CHOOSENLSREVISION

]]
[BNLS_CHOOSENLSREVISION] = { -- 0x0D
	uint32("NLS revision number."),
},
--[[doc
    Message ID:      0x0E

    Message Name:    BNLS_AUTHORIZE

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Japanese, Diablo Shareware, Diablo,
                     Warcraft II

    Format:          (STRING) Bot ID.

    Remarks:         This message logs on to the BNLS server.

                     Note: The bot ID is not case sensitive, and is limited to 31
                     characters.

                     This message was used to let your bot log into the BNLS service. It is
                     no longer required. It may still be used, however. If you wish to
                     require your bot to login to BNLS to be able to work, you can change
                     your BNLS password and prevent your bot from logging in. Useful for
                     required patches and such.

                     To get a bot ID and password, ask Yoni or Skywing.

                     Note: As of June 28, 2004, BNLS IDs were no longer required to log
                     into BNLS; clients could completely bypass using messages
                     BNLS_AUTHORIZE and BNLS_AUTHORIZEPROOF to log on, and BNLS would
                     validate any client that logged in via these methods. On August 14,
                     2004, BNLS was again changed so that, while clients can still bypass
                     using messages BNLS_AUTHORIZE and BNLS_AUTHORIZEPROOF to log on,
                     clients that do support these messages will be validated against the
                     bot ID database, which allows those users who still own bot IDs to
                     disable old versions by changing the password on the account. Related
                     Links: [C>0x0E] BNLS_AUTHORIZE, [C>0x0F] BNLS_AUTHORIZEPROOF, [S>0x0E]
                     BNLS_AUTHORIZE

]]
[BNLS_AUTHORIZE] = { -- 0x0E
	stringz("Bot ID."),
},
--[[doc
    Message ID:      0x0F

    Message Name:    BNLS_AUTHORIZEPROOF

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft II

    Format:          (DWORD) Checksum.

    Remarks:         This is sent to the server when receiving the status code in
                     BNLS_AUTHORIZE (0x0E).

                     For more info, see the [BNLS Checksum Algorithm] document.

                     This message is no longer required. See BNLS_AUTHORIZE for more
                     information. Related Links: [S>0x0E] BNLS_AUTHORIZE, [C>0x0E]
                     BNLS_AUTHORIZE, [S>0x0F] BNLS_AUTHORIZEPROOF

]]
[BNLS_AUTHORIZEPROOF] = { -- 0x0F
	uint32("Checksum."),
},
--[[doc
    Message ID:      0x10

    Message Name:    BNLS_REQUESTVERSIONBYTE

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Japanese, Starcraft, Starcraft Broodwar,
                     Diablo Shareware, Diablo, Diablo II, Diablo, Warcraft II

    Format:          (DWORD) ProductID

    Remarks:         This message requests the latest version byte for a given product.
                     The version byte is sent to Battle.net in SID_AUTH_INFO (0x50).

                     Valid Product IDs are:

                     0x01: Starcraft
                     0x02: Starcraft Brood War
                     0x03: Warcraft II Battle.net Edition
                     0x04: Diablo II
                     0x05: Diablo II: Lord of Destruction
                     0x06: Starcraft Japanese
                     0x07: Warcraft III
                     0x08: Warcraft III: The Frozen Throne

                     View consts: [pas cpp vb] Related Links: [C>0x50] SID_AUTH_INFO,
                     [S>0x10] BNLS_REQUESTVERSIONBYTE

]]
[BNLS_REQUESTVERSIONBYTE] = { -- 0x10
	uint32("ProductID"),
},
--[[doc
    Message ID:    0x11

    Message Name:  BNLS_VERIFYSERVER

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Server IP
                   (BYTE[128]) Signature

    Remarks:       This message verifies a server's signature, which is based on the
                   server's IP. The signature is optionally (currently sent only with
                   Warcraft 3) sent in SID_AUTH_INFO (0x50).

    Related:       [0x11] BNLS_VERIFYSERVER (S->C), [0x50] SID_AUTH_INFO (S->C)

]]
[BNLS_VERIFYSERVER] = { -- 0x11
	uint32("Server IP"),
	uint8{label="Signature", num=128},
},
--[[doc
    Message ID:      0x12

    Message Name:    BNLS_RESERVESERVERSLOTS

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Number of slots to reserve

    Remarks:         This message reserves a number of slots for concurrent NLS checking
                     operations. No other NLS checking messages can be sent before this
                     message has been sent.This message cannot be sent more than once per
                     connection.

                     BNLS may limit the number of slots to a reasonable value. Related
                     Links: [S>0x12] BNLS_RESERVESERVERSLOTS

]]
[BNLS_RESERVESERVERSLOTS] = { -- 0x12
	uint32("Number of slots to reserve"),
},
--[[doc
    Message ID:      0x13

    Message Name:    BNLS_SERVERLOGONCHALLENGE

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Japanese, Diablo Shareware, Diablo,
                     Warcraft II

    Format:          (DWORD) Slot index.(DWORD) NLS revision number.(DWORD[16]) Data from
                     account database.(DWORD[8]) Data client's SID_AUTH_ACCOUNTLOGON (0x53)
                     request.

    Remarks:         This message initializes a new logon checking session and calculates
                     the values needed for the server's reply to SID_AUTH_ACCOUNTLOGON
                     (0x53).
                     BNLS_RESERVESERVERSLOTS(0x12) must be sent before this message to
                     reserve slots for logon checking sessions.

                     Both the slot indicies and the NLS revision number follow their
                     respective conventions covered in this documentation. The account
                     database data is first received from the client's
                     SID_AUTH_ACCOUNTCREATE (0x04) message. This information must be stored
                     by the server's account database for logon checking. If the account
                     database data is invalid, then the logon checking session will not
                     succeed.
                     This message initializes a slot with all the information required for
                     it to operate, including the NLS revision. Although BNLS supports
                     switching the NLS revision of a given slot, it can respond to requests
                     slightly faster if the same NLS revision is used for the same slots in
                     a given connection. Related Links: [S>0x53] SID_AUTH_ACCOUNTLOGON,
                     [C>0x12] BNLS_RESERVESERVERSLOTS, [C>0x52] SID_AUTH_ACCOUNTCREATE,
                     [S>0x13] BNLS_SERVERLOGONCHALLENGE

]]
[BNLS_SERVERLOGONCHALLENGE] = { -- 0x13
	uint32("Slot index."),
	uint32("NLS revision number."),
	uint32{label="Data from", num=16},
	uint32{label="Data client's SID_AUTH_ACCOUNTLOGON", num=8},
},
--[[doc
    Message ID:      0x14

    Message Name:    BNLS_SERVERLOGONPROOF

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         All Products

    Format:          (DWORD) Slot index.(DWORD[5]) Data from client's
                     SID_AUTH_ACCOUNTLOGONPROOF (0x54).(STRING) Client's account name.

    Remarks:         This message performs two operations. First, it checks if the client's
                     logon was successful. Second, it calculates the data for the server's
                     reply to SID_AUTH_ACCOUNTLOGONPROOF (0x54). If this data is not
                     correct, then the client will not accept the logon attempt as valid.
                     Related Links: [S>0x54] SID_AUTH_ACCOUNTLOGONPROOF, [S>0x14]
                     BNLS_SERVERLOGONPROOF

]]
[BNLS_SERVERLOGONPROOF] = { -- 0x14
	uint32("Slot index."),
	uint32{label="Data from client's", num=5},
	stringz("Client's account name."),
},
--[[doc
    Message ID:      0x18

    Message Name:    BNLS_VERSIONCHECKEX

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo, Diablo II

    Format:          (DWORD) Product ID.*(DWORD) Version DLL digit(DWORD) Flags.**(DWORD)
                     Cookie.(STRING) Checksum formula.

    Remarks:         This message will request a fast version check. Now works with all
                     products.
                     Version DLL Digit must be in the range 0-7. (For example, for
                     IX86Ver1.mpq this is 1)

                     * Valid Product IDs are:

                     0x01: Starcraft
                     0x02: Starcraft: Broodwar
                     0x03: Warcraft II: BNE
                     0x04: Diablo II
                     0x05: Diablo II: LoD
                     0x06: Starcraft: Japanese
                     0x07: Warcraft III
                     0x08: Warcraft III: The Frozen Throne

                     View consts: [pas cpp vb]

                     ** Currently there are no flags defined, this must be set to zero.
                     Related Links: [S>0x18] BNLS_VERSIONCHECKEX

]]
[BNLS_VERSIONCHECKEX] = { -- 0x18
	uint32("Product ID.*"),
	uint32("Version DLL digit"),
	uint32("Flags.**"),
	uint32("Cookie."),
	stringz("Checksum formula."),
},
--[[doc
    Message ID:    0x1A

    Message Name:  BNLS_VERSIONCHECKEX2

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Product ID.*
                   (DWORD) Flags.**
                   (DWORD) Cookie.
                   (ULONGLONG) Timestamp for version check archive.
                   (STRING) Version check archive filename.
                   (STRING) Checksum formula.

    Remarks:       This message will request a fast version check and parses the version
                   check filename so the client does not have to. Now works with all
                   products.

                   * Valid Product IDs are:

                   0x01: Starcraft
                   0x02: Starcraft: Broodwar
                   0x03: Warcraft II: BNE
                   0x04: Diablo II
                   0x05: Diablo II: LoD
                   0x06: Starcraft: Japanese
                   0x07: Warcraft III
                   0x08: Warcraft III: The Frozen Throne

                   View consts: [pas cpp vb]

                   ** Currently there are no flags defined, this must be set to zero.

    Related:       [0x1A] BNLS_VERSIONCHECKEX2 (S->C)

]]
[BNLS_VERSIONCHECKEX2] = { -- 0x1A
	uint32("Product ID.*"),
	uint32("Flags.**"),
	uint32("Cookie."),
	uint64("Timestamp for version check archive."),
	stringz("Version check archive filename."),
	stringz("Checksum formula."),
},
--[[doc
    Message ID:    0x01

    Message Name:  D2GS_WALKTOLOCATION

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Walk to a specified (X,Y) map coordinate.

    Related:       [0x03] D2GS_RUNTOLOCATION (C->S)

]]
[D2GS_WALKTOLOCATION] = { -- 0x01
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x02

    Message Name:  D2GS_WALKTOENTITY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) *Entity Type
                   (DWORD) Entity ID

                   *Entity Types
                   -------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Makes your character walk to the Entity specified in Entity ID.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x04] D2GS_RUNTOENTITY (C->S)

]]
[D2GS_WALKTOENTITY] = { -- 0x02
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x03

    Message Name:  D2GS_RUNTOLOCATION

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Run to a specified (X,Y) map coordinate.

    Related:       [0x01] D2GS_WALKTOLOCATION (C->S)

]]
[D2GS_RUNTOLOCATION] = { -- 0x03
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x04

    Message Name:  D2GS_RUNTOENTITY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) *Entity Type
                   (DWORD) Entity ID

                   *Entity Types
                   -------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Makes your character run to the Entity specified in Entity ID.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x02] D2GS_WALKTOENTITY (C->S)

]]
[D2GS_RUNTOENTITY] = { -- 0x04
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x05

    Message Name:  D2GS_LEFTSKILLONLOCATION

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Uses Left skill on specified (X,Y) map coordinate.

    Related:       [0x08] D2GS_LEFTSKILLONLOCATIONEX (C->S)

]]
[D2GS_LEFTSKILLONLOCATION] = { -- 0x05
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x06

    Message Name:  D2GS_LEFTSKILLONENTITY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) *Entity Type
                   (DWORD) Entity ID

                   *Entity Types
                   -------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your left skill on the Entity specefied in Entity ID.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x07] D2GS_LEFTSKILLONENTITYEX (C->S),
                   [0x09] D2GS_LEFTSKILLONENTITYEX2 (C->S),
                   [0x0A] D2GS_LEFTSKILLONENTITYEX3 (C->S)

]]
[D2GS_LEFTSKILLONENTITY] = { -- 0x06
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x07

    Message Name:  D2GS_LEFTSKILLONENTITYEX

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

    Remarks:       Uses your left skill on the Entity specefied in Entity ID, while
                   holding the hotkey for standing still(shift).

                   Entity types
                   ---------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x06] D2GS_LEFTSKILLONENTITY (C->S),
                   [0x09] D2GS_LEFTSKILLONENTITYEX2 (C->S),
                   [0x0A] D2GS_LEFTSKILLONENTITYEX3 (C->S)

]]
[D2GS_LEFTSKILLONENTITYEX] = { -- 0x07
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x08

    Message Name:  D2GS_LEFTSKILLONLOCATIONEX

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Uses Left skill on specified (X,Y) map coordinate.

                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x05] D2GS_LEFTSKILLONLOCATION (C->S)

]]
[D2GS_LEFTSKILLONLOCATIONEX] = { -- 0x08
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x09

    Message Name:  D2GS_LEFTSKILLONENTITYEX2

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) *Entity Type
                   (DWORD) Entity ID

                   *Entity Types
                   -------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your left skill on the Entity specified in Entity ID.

                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x06] D2GS_LEFTSKILLONENTITY (C->S),
                   [0x07] D2GS_LEFTSKILLONENTITYEX (C->S),
                   [0x0A] D2GS_LEFTSKILLONENTITYEX3 (C->S)

]]
[D2GS_LEFTSKILLONENTITYEX2] = { -- 0x09
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x0A

    Message Name:  D2GS_LEFTSKILLONENTITYEX3

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) *Entity Type
                   (DWORD) Entity ID

                   *Entity Types
                   -------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your left skill on the Entity specefied in Entity ID, while
                   holding the hotkey for standing still(shift).

                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

                   Refer to the D2GS Entity Types document for more information.

    Related:       [0x06] D2GS_LEFTSKILLONENTITY (C->S),
                   [0x07] D2GS_LEFTSKILLONENTITYEX (C->S),
                   [0x09] D2GS_LEFTSKILLONENTITYEX2 (C->S)

]]
[D2GS_LEFTSKILLONENTITYEX3] = { -- 0x0A
	uint32("*Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x0C

    Message Name:  D2GS_RIGHTSKILLONLOCATION

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Uses the currently selected skill at the specified location.

                   This packet is sent when the location is first clicked with the mouse.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x0F] D2GS_RIGHTSKILLONLOCATIONEX (C->S)

]]
[D2GS_RIGHTSKILLONLOCATION] = { -- 0x0C
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x0D

    Message Name:  D2GS_RIGHTSKILLONENTITY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your right skill on the Entity specefied in Entity ID

                   Refer to the D2GS Entity Types document for more information about
                   Entities

    Related:       [0x10] D2GS_RIGHTSKILLONENTITYEX2 (C->S)

]]
[D2GS_RIGHTSKILLONENTITY] = { -- 0x0D
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x0E

    Message Name:  D2GS_RIGHTSKILLONENTITYEX

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your right skill on the Entity specefied in Entity ID, while
                   holding the hotkey for standing still(shift).

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x0D] D2GS_RIGHTSKILLONENTITY (C->S),
                   [0x10] D2GS_RIGHTSKILLONENTITYEX2 (C->S),
                   [0x11] D2GS_RIGHTSKILLONENTITYEX3 (C->S)

]]
[D2GS_RIGHTSKILLONENTITYEX] = { -- 0x0E
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x0F

    Message Name:  D2GS_RIGHTSKILLONLOCATIONEX

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Uses the currently selected skill at the specified location.

                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x0C] D2GS_RIGHTSKILLONLOCATION (C->S)

]]
[D2GS_RIGHTSKILLONLOCATIONEX] = { -- 0x0F
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x10

    Message Name:  D2GS_RIGHTSKILLONENTITYEX2

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your right skill repeatedly on the Entity specefied in Entity ID.
                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x0D] D2GS_RIGHTSKILLONENTITY (C->S),
                   [0x11] D2GS_RIGHTSKILLONENTITYEX3 (C->S)

]]
[D2GS_RIGHTSKILLONENTITYEX2] = { -- 0x10
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x11

    Message Name:  D2GS_RIGHTSKILLONENTITYEX3

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity Types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your right skill on the Entity specefied in Entity ID, while
                   holding the hotkey for standing still(shift).

                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

    Related:       [0x0D] D2GS_RIGHTSKILLONENTITY (C->S),
                   [0x10] D2GS_RIGHTSKILLONENTITYEX2 (C->S)

]]
[D2GS_RIGHTSKILLONENTITYEX3] = { -- 0x11
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x13

    Message Name:  D2GS_INTERACTWITHENTITY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Interacts with the specified Entity.
                   For players and npc's, it will send a request to interact.
                   The interaction depends on the type of the unit or object.
                   For others it will trigger the object, for example using a shrine,
                   looting a corpse you have permission to loot, or opening and closing a
                   door.

                   This packet is always followed by other's that relate to the type of
                   interaction.

]]
[D2GS_INTERACTWITHENTITY] = { -- 0x13
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x14

    Message Name:  D2GS_OVERHEADMESSAGE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Unknown - 0x00, 0x00
                   (STRING) Message
                   (BYTE) Unused - 0x00
                   (WORD) Unknown - 0x00, 0x00

    Remarks:       This message is used when you'd like to put a message above a
                   character's head as used in the client as "![message]".

                   Restrictions: Total size of packet cannot be greater than 275 bytes.
                   Message cannot be greater than 255 bytes.

                   Please note: This message's official name is not known, and has been
                   invented.

                   Extra Info: The status of this information is: Public Colors can be
                   created by adding hex FF 63 and a character 30 to 3C.

                   Example:
                   To make red, use FF 63 31.

]]
[D2GS_OVERHEADMESSAGE] = { -- 0x14
	uint16("Unknown - 0x00, 0x00"),
	stringz("Message"),
	uint8("Unused - 0x00"),
	uint16("Unknown - 0x00, 0x00"),
},
--[[doc
    Message ID:    0x15

    Message Name:  D2GS_CHATMESSAGE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Message Type
                   (BYTE) Unknown
                   (STRING) Message
                   (BYTE) Unknown
                   *(WORD) Unknown - Only if normal chat
                   **(STRING) Player to whisper to - Only if whispering
                   **(BYTE) Unknown - Only if whispering

    Remarks:       Sends a chat message in the game.

                   Possible Message Types:
                   0x01 - Send to all
                   0x02 - Whisper

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_CHATMESSAGE] = { -- 0x15
	uint8("Message Type"),
	uint8("Unknown"),
	stringz("Message"),
	uint8("Unknown"),
	uint16("Unknown - Only if normal chat"),
	stringz("Player to whisper to - Only if whispering"),
	uint8("Unknown - Only if whispering"),
},
--[[doc
    Message ID:    0x16

    Message Name:  D2GS_PICKUPITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Unit Type
                   (DWORD) Unit ID
                   (DWORD) Action ID

    Remarks:       Pick up a ground item to cursor buffer/inventory.

                   Possible action IDs:
                   0x00 - Move item to inventory
                   0x01 - Move item to cursor buffer

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x13] D2GS_INTERACTWITHENTITY (C->S)

]]
[D2GS_PICKUPITEM] = { -- 0x16
	uint32("Unit Type"),
	uint32("Unit ID"),
	uint32("Action ID"),
},
--[[doc
    Message ID:    0x17

    Message Name:  D2GS_DROPITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID

    Remarks:       Drops the item in the player's cursor buffer to the ground.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_DROPITEM] = { -- 0x17
	uint32("Item ID"),
},
--[[doc
    Message ID:    0x18

    Message Name:  D2GS_ITEMTOBUFFER

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) X coordinate
                   (DWORD) Y coordinate
                   (DWORD) Buffer Type

                   Possible Buffer Types:
                   0x00 - Character's inventory (backpack)
                   0x01 - NPC and other Trade Windows
                   0x02 - Trade window
                   0x03 - Horadric Cube
                   0x04 - Stash

    Remarks:       Moves item from the player's cursor buffer to an inventory space.

                   Please note: This message's official name is not known, and has been
                   invented.

                   Inventory coordinates:
                   (0,0) - Top left
                   (9,3) - Bottom right

]]
[D2GS_ITEMTOBUFFER] = { -- 0x18
	uint32("Item ID"),
	uint32("X coordinate"),
	uint32("Y coordinate"),
	uint32("Buffer Type"),
},
--[[doc
    Message ID:    0x19

    Message Name:  D2GS_PICKUPBUFFERITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID

    Remarks:       Pickup an item from the possible buffers below, moving it to the
                   cursor buffer.

                   Possible Buffers:
                   0 - Inventory
                   1 - NPC Trade & Other player's Trade Window?
                   2 - Trade Screen
                   3 - Horadric Cube
                   4 - Stash

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_PICKUPBUFFERITEM] = { -- 0x19
	uint32("Item ID"),
},
--[[doc
    Message ID:    0x1A

    Message Name:  D2GS_ITEMTOBODY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) Body Location

    Remarks:       Moves item from player's cursor buffer to body location. Body
                   locations are identified by the line number in the data file
                   bodylocs.txt.

                   Possible Body Locations:
                   0x01 - Helm
                   0x02 - Amulet
                   0x03 - Armor
                   0x04 - Left-hand weapon
                   0x05 - Right-hand weapon
                   0x06 - Left-hand ring
                   0x07 - Right-hand ring
                   0x08 - Belt
                   0x09 - Boots
                   0x0A - Gloves

                   These values have been recorded for mercenary body locations, but
                   aren't confirmed: (Note, each location ID is prefixed with 0x61)
                   Example: 1A 64 00 00 00 61 02 00 00 (Move item 0x64 to Mercenary
                   Right-hand weapon)

                   0x01 - Mercenary Helm
                   0x02 - Mercenary Right-hand Weapon
                   0x03 - Mercenary Armor
                   0x04 - Mercenary Left-hand Weapon

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_ITEMTOBODY] = { -- 0x1A
	uint32("Item ID"),
	uint32("Body Location"),
},
--[[doc
    Message ID:    0x1B

    Message Name:  D2GS_SWAP2HANDEDITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   *(DWORD) Body Location

                   *0x04 is left hand
                   *0x05 is right hand

    Remarks:       Moves item from body location to player's cursor buffer.

                   Body locations are the same as in D2GS_ITEMTOBODY

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x1A] D2GS_ITEMTOBODY (C->S)

]]
[D2GS_SWAP2HANDEDITEM] = { -- 0x1B
	uint32("Item ID"),
	uint32("Body Location"),
},
--[[doc
    Message ID:    0x1C

    Message Name:  D2GS_PICKUPBODYITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Body Location

    Remarks:       Pickup an item from a Body Location to you're cursor buffer.

                   Possible Body Locations:
                   0x01 - Helm
                   0x02 - Amulet
                   0x03 - Armor
                   0x04 - Left-hand weapon
                   0x05 - Right-hand weapon
                   0x06 - Left-hand ring
                   0x07 - Right-hand ring
                   0x08 - Belt
                   0x09 - Boots
                   0x0A - Gloves

]]
[D2GS_PICKUPBODYITEM] = { -- 0x1C
	uint16("Body Location"),
},
--[[doc
    Message ID:    0x1D

    Message Name:  D2GS_SWITCHBODYITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) Body Location

    Remarks:       Swaps item in player's cursor buffer with item in the body location.

                   Possible Body Locations:
                   0x01 - Helm
                   0x02 - Amulet
                   0x03 - Armor
                   0x04 - Left-hand weapon
                   0x05 - Right-hand weapon
                   0x06 - Left-hand ring
                   0x07 - Right-hand ring
                   0x08 - Belt
                   0x09 - Boots
                   0x0A - Gloves

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x1A] D2GS_ITEMTOBODY (C->S)

]]
[D2GS_SWITCHBODYITEM] = { -- 0x1D
	uint32("Item ID"),
	uint32("Body Location"),
},
--[[doc
    Message ID:    0x1F

    Message Name:  D2GS_SWITCHINVENTORYITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID - Item to place in inventory (cursor buffer)
                   (DWORD) Item ID - Item to be replaced
                   (DWORD) X coordinate for replace
                   (DWORD) Y coordinate for replace

    Remarks:       Swaps the item in the player's cursor buffer with one in the player's
                   inventory. Please note:
                   This message's official name is not known, and has been invented.

]]
[D2GS_SWITCHINVENTORYITEM] = { -- 0x1F
	uint32("Item ID - Item to place in inventory"),
	uint32("Item ID - Item to be replaced"),
	uint32("X coordinate for replace"),
	uint32("Y coordinate for replace"),
},
--[[doc
    Message ID:    0x20

    Message Name:  D2GS_USEITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) X coordinate
                   (DWORD) Y coordinate

    Remarks:       Uses the specified item (such as a potion, town portal scroll, etc.).

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_USEITEM] = { -- 0x20
	uint32("Item ID"),
	uint32("X coordinate"),
	uint32("Y coordinate"),
},
--[[doc
    Message ID:    0x21

    Message Name:  D2GS_STACKITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID - Stack item
                   (DWORD) Item ID - Target item

    Remarks:       Stacks one item such as a key onto another item.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_STACKITEM] = { -- 0x21
	uint32("Item ID - Stack item"),
	uint32("Item ID - Target item"),
},
--[[doc
    Message ID:      0x22

    Message Name:    D2GS_REMOVESTACKITEM

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Item ID

    Remarks:         Removes an item from the stack Please note: This message's official
                     name is not known, and has been invented. The contents of this packet
                     may be incomplete or incorrect, and your comments and contributions
                     are requested.

]]
[D2GS_REMOVESTACKITEM] = { -- 0x22
	uint32("Item ID"),
},
--[[doc
    Message ID:    0x23

    Message Name:  D2GS_ITEMTOBELT

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) Belt Location

    Remarks:       Moves an item into the player's belt.

                   Extra Info: The status of this information is: Public Belt locations
                   start at 0x00 and go from right to left, starting at the lowest row
                   and moving across, then going up one row. For example, location 0x03
                   would be at the bottom right hand corner and location 0x0C would be at
                   the top left corner in a 4-slot belt. This can be calculated as
                   (row*4+column).

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_ITEMTOBELT] = { -- 0x23
	uint32("Item ID"),
	uint32("Belt Location"),
},
--[[doc
    Message ID:    0x24

    Message Name:  D2GS_REMOVEBELTITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID

    Remarks:       Moves the specified item from the belt to the player's cursor buffer.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_REMOVEBELTITEM] = { -- 0x24
	uint32("Item ID"),
},
--[[doc
    Message ID:    0x25

    Message Name:  D2GS_SWITCHBELTITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID - Cursor buffer
                   (DWORD) Item ID - Item to be replaced

    Remarks:       Replaces item in belt with item in player's cursor buffer.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_SWITCHBELTITEM] = { -- 0x25
	uint32("Item ID - Cursor buffer"),
	uint32("Item ID - Item to be replaced"),
},
--[[doc
    Message ID:      0x26

    Message Name:    D2GS_USEBELTITEM

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Item ID
                     (DWORD) Unknown - Possibly unused
                     (DWORD) Unknown - Possibly unused

    Remarks:         Uses the specified item in the player's belt.

                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_USEBELTITEM] = { -- 0x26
	uint32("Item ID"),
	uint32("Unknown - Possibly unused"),
	uint32("Unknown - Possibly unused"),
},
--[[doc
    Message ID:    0x28

    Message Name:  D2GS_INSERTSOCKETITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID - Item to place in socket
                   (DWORD) Item ID - Socketed item

    Remarks:       Inserts the specified item into a socketed item.

]]
[D2GS_INSERTSOCKETITEM] = { -- 0x28
	uint32("Item ID - Item to place in socket"),
	uint32("Item ID - Socketed item"),
},
--[[doc
    Message ID:    0x29

    Message Name:  D2GS_SCROLLTOTOME

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID - Scroll
                   (DWORD) Item ID - Tome

    Remarks:       Places a scroll into a tome of scrolls.

                   Note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_SCROLLTOTOME] = { -- 0x29
	uint32("Item ID - Scroll"),
	uint32("Item ID - Tome"),
},
--[[doc
    Message ID:    0x2A

    Message Name:  D2GS_ITEMTOCUBE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) Cube ID

    Remarks:       Moves item from player's cursor buffer into Horadric cube.

]]
[D2GS_ITEMTOCUBE] = { -- 0x2A
	uint32("Item ID"),
	uint32("Cube ID"),
},
--[[doc
    Message ID:      0x2D

    Message Name:    D2GS_UNSELECTOBJ

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          blank

    Remarks:         Unselects the selected object. Please note: This message's official
                     name is not known, and has been invented. The contents of this packet
                     may be incomplete or incorrect, and your comments and contributions
                     are requested.

]]
[D2GS_UNSELECTOBJ] = { -- 0x2D
},
--[[doc
    Message ID:    0x2F

    Message Name:  D2GS_NPCINIT

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Initiate an NPC sesstion, sent following:
                   C->S 0x13
                   It indicates that you are now interacting with an NPC, and a dialog
                   window is opened.

                   This is prior to any choices being made to talk or trade etc.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x32] D2GS_NPCBUY (C->S), [0x30] D2GS_NPCCANCEL (C->S),
                   [0x33] D2GS_NPCSELL (C->S), [0x38] D2GS_NPCTRADE (C->S)

]]
[D2GS_NPCINIT] = { -- 0x2F
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x30

    Message Name:  D2GS_NPCCANCEL

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) NPC ID

    Remarks:       Stops interacting with an NPC

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x32] D2GS_NPCBUY (C->S), [0x2F] D2GS_NPCINIT (C->S),
                   [0x33] D2GS_NPCSELL (C->S), [0x38] D2GS_NPCTRADE (C->S)

]]
[D2GS_NPCCANCEL] = { -- 0x30
	uint32("Entity Type"),
	uint32("NPC ID"),
},
--[[doc
    Message ID:    0x32

    Message Name:  D2GS_NPCBUY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) NPC ID - Unconfirmed
                   (DWORD) Item ID - Unconfirmed
                   (DWORD) Buffer Type - Unconfirmed
                   (DWORD) Cost

    Remarks:       Buys an item from a Non Player Character.

                   Possible Buffer Types:
                   0x00 - Regular (ordinary item)
                   0x02 - Gambled

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x2F] D2GS_NPCINIT (C->S), [0x30] D2GS_NPCCANCEL (C->S),
                   [0x33] D2GS_NPCSELL (C->S), [0x38] D2GS_NPCTRADE (C->S)

]]
[D2GS_NPCBUY] = { -- 0x32
	uint32("NPC ID - Unconfirmed"),
	uint32("Item ID - Unconfirmed"),
	uint32("Buffer Type - Unconfirmed"),
	uint32("Cost"),
},
--[[doc
    Message ID:    0x33

    Message Name:  D2GS_NPCSELL

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) NPC ID - Unconfirmed
                   (DWORD) Item ID - Unconfirmed
                   (DWORD) Buffer ID - Unconfirmed - Possible value 0x04
                   (DWORD) Cost

    Remarks:       Sell an item to a Non Player Character.

                   The Buffer ID refers to the windows in the NPC trade screen, depending
                   on what you are selling the Buffer ID will match the item type.
                   After selling the item it will appear in the given Buffer ID.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_NPCSELL] = { -- 0x33
	uint32("NPC ID - Unconfirmed"),
	uint32("Item ID - Unconfirmed"),
	uint32("Buffer ID - Unconfirmed - Possible value 0x04"),
	uint32("Cost"),
},
--[[doc
    Message ID:      0x38

    Message Name:    D2GS_NPCTRADE

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Trade Type - Unconfirmed
                     (DWORD) NPC ID - Unconfirmed
                     (DWORD) Unknown - Unconfirmed - Possible value 0x00

    Remarks:         This packet's use is currently unconfirmed.

                     Possible Trade Types:
                     0x01 - Trade
                     0x02 - Gamble

                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_NPCTRADE] = { -- 0x38
	uint32("Trade Type - Unconfirmed"),
	uint32("NPC ID - Unconfirmed"),
	uint32("Unknown - Unconfirmed - Possible value 0x00"),
},
--[[doc
    Message ID:    0x3F

    Message Name:  D2GS_CHARACTERPHRASE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Phrase ID

    Remarks:       All phrases sent to the server will be heard by all players in your
                   vicinity.

                   Phrase IDs: (Note: The deciding of which of the two phrases are used
                   is random)
                   [0x19] "Help!" / "Help me!"
                   [0x1A] "Follow me!" / "Come on!"
                   [0x1B] "This is yours." / "This is for you."
                   [0x1C] "Thanks!" / "Thank you."
                   [0x1D] "Uh, oops." / "Forgive me."
                   [0x1E] "Bye!" / "Good Bye!"
                   [0x1F] "Die!" / "Time to die!"
                   [0x20] "Run!" / "Run away!" Please note: This message's official name
                   is not known, and has been invented.

]]
[D2GS_CHARACTERPHRASE] = { -- 0x3F
	uint16("Phrase ID"),
},
--[[doc
    Message ID:      0x49

    Message Name:    D2GS_WAYPOINT

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (BYTE) Waypoint ID
                     (BYTE) Unknown - Appears to be random
                     (WORD) Unknown - 0x00
                     (BYTE) Level number
                     (WORD) Unknown - 0x00

    Remarks:         Requests to go to a waypoint if it was already activated.

                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_WAYPOINT] = { -- 0x49
	uint8("Waypoint ID"),
	uint8("Unknown - Appears to be random"),
	uint16("Unknown - 0x00"),
	uint8("Level number"),
	uint16("Unknown - 0x00"),
},
--[[doc
    Message ID:    0x4F

    Message Name:  D2GS_TRADE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Request ID
                   (WORD) Gold Amount

    Remarks:       This message should be used for manipulating the trading window, the
                   Horadric Cube item window, and the Stash window.

                   Possible Request ID's:
                   [0x02] Cancel trade request
                   [0x03] Accept trade request
                   [0x04] Press Accept button (accept)
                   [0x07] Press Accept button (unaccept) - This should be sent when
                   placing items in the trade window as well.
                   [0x08] Refresh window (See below for examples on usage)
                   [0x12] Close stash window
                   [0x13] Move gold (stash to inventory)
                   [0x14] Move gold (inventory to stash)
                   [0x17] Close Horadric Cube window

                   Examples of using Refresh ID:
                   Item has been picked up to mouse cursor buffer.
                   Item has been placed in the trade screen.
                   Accepted or closed a trade window.
                   Manual unclick of Accept button.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_TRADE] = { -- 0x4F
	uint32("Request ID"),
	uint16("Gold Amount"),
},
--[[doc
    Message ID:    0x50

    Message Name:  D2GS_DROPGOLD

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) PlayerID
                   (DWORD) GoldAmount

    Remarks:       Drops a pile of gold to the ground.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_DROPGOLD] = { -- 0x50
	uint32("PlayerID"),
	uint32("GoldAmount"),
},
--[[doc
    Message ID:    0x5E

    Message Name:  D2GS_PARTY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Action ID
                   (DWORD) Player ID

    Remarks:       Possible Action IDs:

                   0x06 - Invite player to party with you
                   0x07 - Cancel invite to player
                   0x08 - Accept invite from player
                   0x09 - Leave party

]]
[D2GS_PARTY] = { -- 0x5E
	uint16("Action ID"),
	uint32("Player ID"),
},
--[[doc
    Message ID:      0x61

    Message Name:    D2GS_POTIONTOMERCENARY

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (WORD) Unknown - 0x00

    Remarks:         Takes the potion your cursor holds and gives it to the mercenary.
                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_POTIONTOMERCENARY] = { -- 0x61
	uint16("Unknown - 0x00"),
},
--[[doc
    Message ID:      0x68

    Message Name:    D2GS_GAMELOGON

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) D2GS Server Hash
                     (WORD) D2GS Server Token
                     (BYTE) Character ID
                     (DWORD) Version byte (Currently 0x0B)
                     (DWORD) Unknown - Suggested Const (0xED5DCC50)
                     (DWORD) Unknown - Suggested Const (0x91A519B6)
                     (BYTE) Unknown - Suggested (0x00)
                     (STRING) Character name
                     (VOID) *See user-comment below

    Remarks:         Possible Character IDs:
                     0x00 - Amazon
                     0x01 - Sorceress
                     0x02 - Necromancer
                     0x03 - Paladin
                     0x04 - Barbarian
                     0x05 - Druid
                     0x06 - Assassin

                     The "Character name" field is a buffer of 15 characters with a
                     null-terminator. This string should always be filled with 15
                     characters (plus terminator), padded with 0's for unused bytes.

                     Note: If the character ID does not match the type of character you're
                     attempting to logon with, and the character is nealy created (with 0
                     play time), then that character will automatically be changed or
                     "morphed" into the character ID sent.
                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_GAMELOGON] = { -- 0x68
	uint32("D2GS Server Hash"),
	uint16("D2GS Server Token"),
	uint8("Character ID"),
	uint32("Version byte"),
	uint32("Unknown - Suggested Const"),
	uint32("Unknown - Suggested Const"),
	uint8("Unknown - Suggested"),
	stringz("Character name"),
	bytes("*See user-comment below"),
},
--[[doc
    Message ID:      0x6A

    Message Name:    D2GS_ENTERGAMEENVIRONMENT

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          blank

    Remarks:         This byte should be sent in order to start receiving in-game messages
                     and to interact with the world itself.

                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_ENTERGAMEENVIRONMENT] = { -- 0x6A
},
--[[doc
    Message ID:    0x6D

    Message Name:  D2GS_PING

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Tick Count
                   (DWORD) Null
                   (DWORD) Null

    Remarks:       This packet should be sent every five to seven seconds to avoid
                   timeout.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_PING] = { -- 0x6D
	uint32("Tick Count"),
	uint32("Null"),
	uint32("Null"),
},
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
	uint32("[2] MCP Chunk 1"),
	uint32("[12] MCP Chunk 2"),
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
                   0x40: Ladder Sending 0x05 or 0x06 in character class or 0x20 in
                   character flags while on D2DV will disconnect and temporarily
                   ban you from the realm. Likewise, sending 0x05 or 0x06 in
                   character class without setting 0x20 in character flags will
                   result in a disconnect and ban.

    Related:       [0x02] MCP_CHARCREATE (S->C)

]]
[MCP_CHARCREATE] = { -- 0x02
	uint32("Character class"),
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
	uint16("Request Id *"),
	uint32("Difficulty"),
	uint8("Unknown - 1"),
	uint8("Player difference **"),
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
	stringz("Search String *"),
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
	uint32("Number of characters to list."),
},
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
	stringz{label="Usernames to cycle", todo="maybe iterator"},
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

    Format:          (DWORD) CommandFor Command 0x00 (Login):(STRING) Account name(STRING)
                     Account passwordFor Command 0x01 (Change password):(STRING) Account
                     name(STRING) Old password(STRING) New passwordFor Command 0x02 (Create
                     account):(STRING) Account name(STRING) Account password

    Remarks:         Command values other than those listed are reserved for future use.

                     Possible CommandIDs:

                     0x00: Login
                     0x01: Change password
                     0x02: Create account Related Links: [S>0x0D] PACKET_ACCOUNT

]]
[PACKET_ACCOUNT] = { -- 0x0D
	uint32("CommandFor Command 0x00"),
	stringz("Account name"),
	stringz("Account passwordFor Command 0x01"),
	stringz("Account"),
	stringz("Old password"),
	stringz("New passwordFor Command 0x02"),
	stringz("Account name"),
	stringz("Account password"),
},
--[[doc
    Message ID:      0x10

    Message Name:    PACKET_CHATDROPOPTIONS

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (BYTE) SubcommandFor subcommand 0:(BYTE) Setting for broadcast(BYTE)
                     Setting for database(BYTE) Setting for whispers(BYTE) Refuse all
                     whispers

    Remarks:         This message is used to either notify or set your chat drop options.
                     The server may notify you of your chat drop options by sending
                     subcommand 0 without the four trailing value bytes.

                     Possible values:
                     0: Allow all chat to be received (Default)
                     1: Refuse chat from users not on an account
                     2: Refuse all chat Related Links: [S>0x10] PACKET_CHATDROPOPTIONS

]]
[PACKET_CHATDROPOPTIONS] = { -- 0x10
	uint8("SubcommandFor subcommand 0:"),
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
	uint32("UDP Token*"),
},
--[[doc
    Message ID:    0x00

    Message Name:  SID_NULL

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III,

    Format:        [blank]

    Remarks:       Keeps the connection alive. This message should be sent to the server
                   every 8 minutes (approximately).

    Related:       [0x00] SID_NULL (S->C)

]]
[SID_NULL] = { -- 0x00
},
--[[doc
    Message ID:    0x02

    Message Name:  SID_STOPADV

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        [blank]

    Remarks:       This message is sent to inform the server that a game should no longer
                   be advertised to other users. It is sent when a game starts, or when a
                   game is aborted (the host leaves).

                   All Battle.snp clients (DRTL, DSHR, STAR/SEXP, JSTR, SSHR, and W2BN)
                   always send this message when logging off, even if it not in a game.

]]
[SID_STOPADV] = { -- 0x02
},
--[[doc
    Message ID:    0x05

    Message Name:  SID_CLIENTID

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese

    Format:        (DWORD) Registration Version
                   (DWORD) Registration Authority
                   (DWORD) Account Number
                   (DWORD) Registration Token
                   (STRING) LAN Computer Name
                   (STRING) LAN Username

    Remarks:       This packet was used to ensure that the client's account number was
                   valid. All but the last two fields in this message are now ignored,
                   and may be set to zero.

                   The 'LAN Computer Name' field is the NetBIOS name of the computer. It
                   can be retrieved using the GetComputerName API.

                   The 'Lan Username' field is the name of the currently logged on user,
                   and may be retrieved using the GetUsername API.

                   The following information is historical:

                   The client would supply this data as issued by a Battle.net server. If
                   the Registration Version, Registration Authority, and Client Token
                   values equated to the account number supplied (Client ID), as
                   determined by an unknown formula, the server would respond with the
                   same values. If they were invalid, the server would assign new values.
                   Registration Version was always 1, Authority was the IP address of the
                   server that issued the account number. Thus, the Client Token was the
                   secret value, used to prove that the client really owned the account
                   in question.

    Related:       [0x05] SID_CLIENTID (S->C)

]]
[SID_CLIENTID] = { -- 0x05
	uint32("Registration Version"),
	uint32("Registration Authority"),
	uint32("Account Number"),
	uint32("Registration Token"),
	stringz("LAN Computer Name"),
	stringz("LAN Username"),
},
--[[doc
    Message ID:    0x06

    Message Name:  SID_STARTVERSIONING

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (DWORD) Platform ID
                   (DWORD) Product ID
                   (DWORD) Version Byte
                   (DWORD) Unknown (0)

    Remarks:       This message is sent to the server to start the process of checking
                   the game files. This message is part of the old logon process for
                   products before Starcraft.

    Related:       [0x06] SID_STARTVERSIONING (S->C)

]]
[SID_STARTVERSIONING] = { -- 0x06
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("Version Byte"),
	uint32("Unknown"),
},
--[[doc
    Message ID:    0x07

    Message Name:  SID_REPORTVERSION

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (DWORD) Platform ID
                   (DWORD) Product ID
                   (DWORD) Version Byte
                   (DWORD) EXE Version
                   (DWORD) EXE Hash
                   (STRING) EXE Information

    Remarks:       Contains CheckRevision response, version & EXE info.

    Related:       [0x07] SID_REPORTVERSION (S->C)

]]
[SID_REPORTVERSION] = { -- 0x07
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("Version Byte"),
	uint32("EXE Version"),
	uint32("EXE Hash"),
	stringz("EXE Information"),
},
--[[doc
    Message ID:    0x08

    Message Name:  SID_STARTADVEX

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware

    Format:        (BOOLEAN) Password protected (32-bit)
                   (DWORD) Unknown
                   (DWORD) Unknown
                   (DWORD) Unknown
                   (DWORD) Unknown
                   (DWORD) Port
                   (STRING) Game name
                   (STRING) Game password
                   (STRING) Game stats - flags, creator, statstring
                   (STRING) Map name - 0x0d terminated

    Remarks:       Creates a game in a manner similar to SID_STARTADVEX2 and
                   SID_STARTADVEX3. This is only used by Starcraft Shareware.

    Related:       [0x08] SID_STARTADVEX (S->C), [0x1A] SID_STARTADVEX2 (C->S),
                   [0x1C] SID_STARTADVEX3 (C->S)

]]
[SID_STARTADVEX] = { -- 0x08
	uint32{label="Password protected", desc=Descs.YesNo},
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Port"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game stats - flags, creator, statstring"),
	stringz("Map name - 0x0d terminated"),
},
--[[doc
    Message ID:      0x09

    Message Name:    SID_GETADVLISTEX

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                     Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:          (WORD) Product-specific condition 1
                     (WORD) Product-specific condition 2
                     (DWORD) Product-specific condition 3
                     (DWORD) Product-specific condition 4
                     (DWORD) List count
                     (STRING) Game name
                     (STRING) Game password
                     (STRING) Game stats

    Remarks:         Retrieves a list of games.

                     Condition 1:

                     For STAR/SEXP/SSHR/JSTR and W2BN, Condition 1 is used to specify
                     a game type. A value of 0 indicates that any type is acceptable.

                     Possible game types:
                     0x00: All

                     0x02: Melee

                     0x03: Free for all

                     0x04: one vs one

                     0x05: CTF

                     0x06: Greed

                     0x07: Slaughter

                     0x08: Sudden Death

                     0x09: Ladder

                     0x10: Iron man ladder

                     0x0A: Use Map Settings

                     0x0B: Team Melee

                     0x0C: Team FFA

                     0x0D: Team CTF

                     0x0F: Top vs Bottom
                     For DRTL/DSHR, Condition 1 is used to specify a 'level range'.
                     This ensures that clients receive a list of games containing
                     players whose experience is similar to their own.

                     Possible ranges:
                     0x00: Level 1

                     0x01: 2 - 3

                     0x02: 4 - 5

                     0x03: 6 - 7

                     0x04: 8 - 9

                     0x05: 10 - 12

                     0x06: 13 - 16

                     0x07: 17 - 19

                     0x08: 20 - 24

                     0x09: 25 - 29

                     0x0A: 30 - 34

                     0x0B: 35 - 39

                     0x0C: 40 - 47

                     0x0D: 48 - 50

                     For all other games, this can be set to 0x00.

                     Condition 2:

                     Unknown. Set to 0x00.

                     Condition 3:

                     For STAR/SEXP/SSHR/JSTR, Condition 3 is set to 0x30. For
                     DRTL/DSHR, Condition 3 is set to 0xFFFF by the game, but setting
                     it to 0x00 will disable any viewing limitations, letting you
                     view all games.

                     Condition 4:

                     Unknown. Set to 0x00.

                     List count:

                     By default, DRTL/DSHR set this to 0x19. This is the number of
                     games to list. For a full listing, it's safe to use 0xFF.

    Related:         [0x09] SID_GETADVLISTEX (S->C)

]]
[SID_GETADVLISTEX] = { -- 0x09
	uint16("Product-specific condition 1"),
	uint16("Product-specific condition 2"),
	uint32("Product-specific condition 3"),
	uint32("Product-specific condition 4"),
	uint32("List count"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game stats"),
},
--[[doc
    Message ID:    0x0A

    Message Name:  SID_ENTERCHAT

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (STRING) Username *
                   (STRING) Statstring **

    Remarks:       Joins Chat.

                   * Null on WAR3/W3XP.

                   ** Null on CDKey Products, except for D2DV and D2XP when on realm
                   characters..

    Related:       [0x0A] SID_ENTERCHAT (S->C)

]]
[SID_ENTERCHAT] = { -- 0x0A
	stringz("Username *"),
	stringz("Statstring **"),
},
--[[doc
    Message ID:    0x0B

    Message Name:  SID_GETCHANNELLIST

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Product ID

    Remarks:       Requests a list of channels that the client is permitted to enter.

                   In the past this packet returned a product list for the specified
                   Product ID, however, the Product ID field is now ignored -- it does
                   not need to be a valid Product ID, and can be set to zero. The list of
                   channels returned will be for the client's product, as specified
                   during the client's logon.

    Related:       [0x0B] SID_GETCHANNELLIST (S->C)

]]
[SID_GETCHANNELLIST] = { -- 0x0B
	uint32("Product ID"),
},
--[[doc
    Message ID:    0x0C

    Message Name:  SID_JOINCHANNEL

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Flags
                   (STRING) Channel

    Remarks:       Joins a channel after entering chat.
                   The flags field may contain the following values:
                   0x00: NoCreate join
                   0x01: First join
                   0x02: Forced join
                   0x05: D2 first join

                   NoCreate Join:
                   This will only join the channel specified if it is not empty,
                   and is used by clients when selecting a channel from the
                   channels menu. If the channel is empty, Battle.net sends a
                   SID_CHATEVENT of type EID_CHANNELDOESNOTEXIST, upon which
                   official clients prompt for confirmation that the user wishes to
                   create the channel, in which case, it resends this packet with
                   Flags set to Forced Join (0x02).

                   First Join:
                   Places user in a channel starting with their product and
                   country, followed by a number, ie 'Brood War GBR-1'. Also
                   automatically sends MOTD after entering the channel. When using
                   this type, the Channel variable has no effect, but must be
                   present anyway to avoid an IP ban. This is sent when first
                   logging onto Battle.net

                   Forced Join:
                   This is sent when leaving a game, and joins the specified
                   channel without an supplying an MOTD.

                   D2 First Join:
                   The same as First join, but is used for D2DV/D2XP clients.

    Related:       [0x0F] SID_CHATEVENT (S->C)

]]
[SID_JOINCHANNEL] = { -- 0x0C
	uint32("Flags"),
	stringz("Channel"),
},
--[[doc
    Message ID:    0x0E

    Message Name:  SID_CHATCOMMAND

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (STRING) Text

    Remarks:       Send text or a command to Battle.net using this packet.

                   For STAR/SEXP/SSHR/JSTR, Text is UTF-8 encoded (WIDESTRING).

                   It is generally accepted as unwise to send any character below a space
                   (0x20): this includes line feeds, carriage returns & control
                   characters. The maximum number of characters is 223 per message.

    Related:       [0x0F] SID_CHATEVENT (S->C)

]]
[SID_CHATCOMMAND] = { -- 0x0E
	stringz("Text"),
},
--[[doc
    Message ID:    0x10

    Message Name:  SID_LEAVECHAT

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        [blank]

    Remarks:       Leaves chat mode but does not disconnect. Generally sent when entering
                   a game. This is also sent by D2DV/D2XP when switching characters, and
                   by all products when logging off.

]]
[SID_LEAVECHAT] = { -- 0x10
},
--[[doc
    Message ID:    0x12

    Message Name:  SID_LOCALEINFO

    Direction:     Client -> Server (Sent)

    Used By:       Diablo Shareware, Warcraft II, Diablo

    Format:        (FILETIME) System time
                   (FILETIME) Local time
                   (DWORD) Timezone bias
                   (DWORD) SystemDefaultLCID
                   (DWORD) UserDefaultLCID
                   (DWORD) UserDefaultLangID
                   (STRING) Abbreviated language name
                   (STRING) Country name
                   (STRING) Abbreviated country name
                   (STRING) Country (English)

    Remarks:       Informs the server of the client's locale information. Much of this
                   functionality has been incorporated into SID_AUTH_INFO, and more
                   in-depth remarks can be found there.

    Related:       [0x50] SID_AUTH_INFO (C->S)

]]
[SID_LOCALEINFO] = { -- 0x12
	wintime("System time"),
	wintime("Local time"),
	uint32("Timezone bias"),
	uint32("SystemDefaultLCID"),
	uint32("UserDefaultLCID"),
	uint32("UserDefaultLangID"),
	stringz("Abbreviated language name"),
	stringz("Country name"),
	stringz("Abbreviated country name"),
	stringz("Country"),
},
--[[doc
    Message ID:    0x14

    Message Name:  SID_UDPPINGRESPONSE

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                   Starcraft, Starcraft Japanese, Diablo

    Format:        (DWORD) UDPCode

    Remarks:       Enables UDP support.

                   Server supplies code via UDP packet PKT_SERVERPING (0x05). Usually
                   'bnet'.

                   Not responding will give you a UDP Plug in chat.

    Related:       [0x05] PKT_SERVERPING (S->C)

]]
[SID_UDPPINGRESPONSE] = { -- 0x14
	uint32("UDPCode"),
},
--[[doc
    Message ID:    0x15

    Message Name:  SID_CHECKAD

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Platform ID
                   (DWORD) Product ID
                   (DWORD) ID of last displayed banner
                   (DWORD) Current time

    Remarks:       Requests ad banner information from battle.net.

    Related:       [0x15] SID_CHECKAD (S->C)

]]
[SID_CHECKAD] = { -- 0x15
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("ID of last displayed banner"),
	uint32("Current time"),
},
--[[doc
    Message ID:    0x16

    Message Name:  SID_CLICKAD

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Ad ID
                   (DWORD) Request type

    Remarks:       The clients send this when an ad is clicked.

                   Request Type is 0 if the client used SID_QUERYADURL to get the ad's
                   data, 1 otherwise.

    Related:       [0x41] SID_QUERYADURL (C->S)

]]
[SID_CLICKAD] = { -- 0x16
	uint32("Ad ID"),
	uint32("Request type"),
},
--[[doc
    Message ID:      0x18

    Message Name:    SID_REGISTRY

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Unknown

    Format:          (DWORD) Cookie
                     (STRING) Key Value

    Remarks:         Returns the requested registry value

    Related:         [0x18] SID_REGISTRY (S->C)

]]
[SID_REGISTRY] = { -- 0x18
	uint32("Cookie"),
	stringz("Key Value"),
},
--[[doc
    Message ID:      0x1A

    Message Name:    SID_STARTADVEX2

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Diablo Shareware, Diablo

    Format:          (DWORD) Password Protected
                     (DWORD) Unknown
                     (DWORD) Unknown
                     (DWORD) Unknown
                     (DWORD) Unknown
                     (DWORD) Port
                     (STRING) Game name
                     (STRING) Game password
                     (STRING) Unknown
                     (STRING) Game stats - Flags, Creator, Statstring

    Remarks:         This message is used by Diablo to create a game.

    Related:         [0x08] SID_STARTADVEX (C->S), [0x1C] SID_STARTADVEX3 (C->S)

]]
[SID_STARTADVEX2] = { -- 0x1A
	uint32("Password Protected"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Unknown"),
	uint32("Port"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Unknown"),
	stringz("Game stats - Flags, Creator, Statstring"),
},
--[[doc
    Message ID:      0x1B

    Message Name:    SID_GAMEDATAADDRESS

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Diablo

    Format:          (SOCKADDR) Address

    Remarks:         Specifies host & port that a game creator is using for a game.

]]
[SID_GAMEDATAADDRESS] = { -- 0x1B
	sockaddr("Address"),
},
--[[doc
    Message ID:      0x1C

    Message Name:    SID_STARTADVEX3

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                     Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                     Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:          (DWORD) State
                     (DWORD) Time since creation
                     (WORD) Game Type
                     (WORD) Parameter
                     (DWORD) Unknown (1F)
                     (DWORD) Ladder
                     (STRING) Game name
                     (STRING) Game password
                     (STRING) Game Statstring

    Remarks:         Used by clients to inform the server that a game has been created, or
                     that the state of a created game has changed.

                     Bitwise flags for State:
                     0x01: Game is private

                     0x02: Game is full

                     0x04: Game contains players (other than creator)

                     0x08: Game is in progress

                     Possible values for Game Type:
                     0x02: Melee

                     0x03: Free for All

                     0x04: 1 vs 1

                     0x09: Ladder

                     0x0A: Use Map Settings

                     0x0F: Top vs Bottom

                     0x10: Iron Man Ladder (W2BN only)

                     Possible values for Ladder:
                     0x00: Game is NonLadder

                     0x01: Game is Ladder

                     0x03: Game is Iron Man Ladder (W2BN only)

                     It could be that the ladder is bitwise as well, and that 0x02 means
                     Iron Man and 0x03 just means Iron Man + Ladder.

                     Parameter appears to be 1 for all games except Top vs Bottom, where it
                     seems to depend on the size of each team. More research will be needed
                     to confirm.

    Related:         [0x08] SID_STARTADVEX (C->S), [0x1A] SID_STARTADVEX2 (C->S),
                     [0x1C] SID_STARTADVEX3 (S->C), Game Statstrings

]]
[SID_STARTADVEX3] = { -- 0x1C
	uint32("State"),
	uint32("Time since creation"),
	uint16("Game Type"),
	uint16("Parameter"),
	uint32("Unknown"),
	uint32("Ladder"),
	stringz("Game name"),
	stringz("Game password"),
	stringz("Game Statstring"),
},
--[[doc
    Message ID:    0x1E

    Message Name:  SID_CLIENTID2

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft II, Starcraft Japanese, Diablo

    Format:        (DWORD) Server Version

                   For server version 1:
                   (DWORD) Registration Version

                   (DWORD) Registration Authority

                   For server version 0:
                   (DWORD) Registration Authority

                   (DWORD) Registration Version

                   (DWORD) Account Number
                   (DWORD) Registration Token
                   (STRING) LAN computer name
                   (STRING) LAN username

    Remarks:       See related link for more information.

    Related:       [0x05] SID_CLIENTID (C->S)

]]
[SID_CLIENTID2] = { -- 0x1E
	uint32("Server Version"),
	uint32("Registration Version"),
	uint32("Registration Authority"),
	uint32("Registration Authority"),
	uint32("Registration Version"),
	uint32("Account Number"),
	uint32("Registration Token"),
	stringz("LAN computer name"),
	stringz("LAN username"),
},
--[[doc
    Message ID:    0x1F

    Message Name:  SID_LEAVEGAME

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        [blank]

    Remarks:       Notifies Battle.net that you have left a game.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[SID_LEAVEGAME] = { -- 0x1F
},
--[[doc
    Message ID:    0x21

    Message Name:  SID_DISPLAYAD

    Direction:     Client -> Server (Sent)

    Used By:       Unknown

    Format:        (DWORD) Platform ID
                   (DWORD) Product ID
                   (DWORD) Ad ID
                   (STRING) Filename
                   (STRING) URL

    Remarks:       Sent when an ad is displayed. Perhaps for statistics?

                   Null strings are now sent in place of Filename and URL, since the need
                   to truncate long strings to 128 characters was causing inaccuracies.

]]
[SID_DISPLAYAD] = { -- 0x21
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("Ad ID"),
	stringz("Filename"),
	stringz("URL"),
},
--[[doc
    Message ID:    0x22

    Message Name:  SID_NOTIFYJOIN

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) Product ID *
                   (DWORD) Product version
                   (STRING) Game Name
                   (STRING) Game Password

    Remarks:       Notifies Battle.net that the client has joined a game. This is what
                   causes you to receive "Your friend _ entered a _ game called _." from
                   Battle.net if you are mutual friends with this client.

                   SID_LEAVECHAT (0x10) does not need to be sent after this, since this
                   does what LEAVECHAT does but with an added notification.

                   * This can be any valid Product ID, even if you are not connected with
                   that ID.

]]
[SID_NOTIFYJOIN] = { -- 0x22
	uint32("Product ID *"),
	uint32("Product version"),
	stringz("Game Name"),
	stringz("Game Password"),
},
--[[doc
    Message ID:    0x25

    Message Name:  SID_PING

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Ping Value

    Remarks:       Ping response. Ping Value is the DWORD received in the server's
                   initial ping message.

    Related:       [0x25] SID_PING (S->C)

]]
[SID_PING] = { -- 0x25
	uint32("Ping Value"),
},
--[[doc
    Message ID:      0x26

    Message Name:    SID_READUSERDATA

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                     Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                     Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:          (DWORD) Number of Accounts
                     (DWORD) Number of Keys
                     (DWORD) Request ID
                     (STRING)[] Requested Accounts
                     (STRING)[] Requested Keys

    Remarks:         Requests an extended profile.

                     Profile Keys: *

                     User Profiles:
                     profile\sex **

                     profile\age â€

                     profile\location

                     profile\description

                     Account Info:
                     System\Account Created

                     System\Last Logon

                     System\Last Logoff

                     System\Time Logged

                     Normal Games:
                     record\GAME\0\wins

                     record\GAME\0\losses

                     record\GAME\0\disconnects

                     record\GAME\0\last GAME

                     record\GAME\0\last GAME result

                     Ladder Games:
                     record\GAME\1\wins

                     record\GAME\1\losses

                     record\GAME\1\disconnects

                     record\GAME\1\last game

                     record\GAME\1\last game result

                     record\GAME\1\rating

                     record\GAME\1\high rating

                     DynKey\GAME\1\rank

                     IronMan Ladder Games: â€¡
                     record\GAME\3\wins

                     record\GAME\3\losses

                     record\GAME\3\disconnects

                     record\GAME\3\last game

                     record\GAME\3\last game result

                     record\GAME\3\rating

                     record\GAME\3\high rating

                     DynKey\GAME\3\rank

                     * This list is not complete, and could use adding to.

                     ** This field is defunct in STAR/SEXP/WAR3/W3XP.

                     â€  This field is defunct.

                     â€¡ W2BN only.

    Related:         [0x26] SID_READUSERDATA (S->C)

]]
[SID_READUSERDATA] = { -- 0x26
	uint32("Number of Accounts"),
	uint32("Number of Keys"),
	uint32("Request ID"),
	stringz("[] Requested Accounts"),
	stringz("[] Requested Keys"),
},
--[[doc
    Message ID:    0x27

    Message Name:  SID_WRITEUSERDATA

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Number of accounts
                   (DWORD) Number of keys
                   (STRING) [] Accounts to update
                   (STRING) [] Keys to update
                   (STRING) [] New values

    Remarks:       Updates the Client's profile.
                   Currently, the allowed keys for this are Sex, Location, and
                   Description. The maximum length for the values is 512, including the
                   null terminator.

                   See SID_READUSERDATA for more information.

    Related:       [0x26] SID_READUSERDATA (C->S)

]]
[SID_WRITEUSERDATA] = { -- 0x27
	uint32("Number of accounts"),
	uint32("Number of keys"),
	stringz("[] Accounts to update"),
	stringz("[] Keys to update"),
	stringz("[] New values"),
},
--[[doc
    Message ID:    0x29

    Message Name:  SID_LOGONRESPONSE

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Diablo Shareware, Warcraft II, Starcraft Japanese,
                   Diablo

    Format:        (DWORD) Client Token
                   (DWORD) Server Token
                   (DWORD) [5] Password Hash
                   (STRING) Username

    Remarks:       Contains Client's username & hashed password.

                   Battle.net password hashes are hashed twice. First, the password is
                   hashed by itsself, then the following data is hashed again and sent to
                   Battle.net:

                   Client Token
                   Server Token
                   First password hash (20 bytes)

                   Passwords should be converted to lower case before hashing.

    Related:       [0x29] SID_LOGONRESPONSE (S->C)

]]
[SID_LOGONRESPONSE] = { -- 0x29
	uint32("Client Token"),
	uint32("Server Token"),
	uint32("[5] Password Hash"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x2A

    Message Name:  SID_CREATEACCOUNT

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) [5] Hashed password
                   (STRING) Username

    Remarks:       Creates an account.

                   Usernames longer than 15 characters are truncated, and the password is
                   only hashed once (unlike SID_LOGONRESPONSE).

                   This packet is identical to SID_CREATEACCOUNT2, but the response is
                   limited to success/fail. Developers who wish to provide a reason for
                   account creation failure should use SID_CREATEACCOUNT2.

                   Currently, SID_CREATEACCOUNT2 may be used with any product, but the
                   protocol-correct packet to use depends on the product you are
                   emulating.

    Related:       [0x2A] SID_CREATEACCOUNT (S->C), [0x29] SID_LOGONRESPONSE (C->S),
                   [0x3D] SID_CREATEACCOUNT2 (C->S)

]]
[SID_CREATEACCOUNT] = { -- 0x2A
	uint32("[5] Hashed password"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x2B

    Message Name:  SID_SYSTEMINFO

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Starcraft,
                   Starcraft Japanese, Diablo

    Format:        (DWORD) Number of processors
                   (DWORD) Processor architecture
                   (DWORD) Processor level
                   (DWORD) Processor timing
                   (DWORD) Total physical memory
                   (DWORD) Total page file
                   (DWORD) Free disk space

    Remarks:       Contains system information. This packet was sent during the
                   connection process for STAR/SEXP/DRTL/DSHR clients prior to version
                   1.07. It is now only used by JSTR and SSHR. For information on how to
                   emulate this system, please see this topic.

]]
[SID_SYSTEMINFO] = { -- 0x2B
	uint32("Number of processors"),
	uint32("Processor architecture"),
	uint32("Processor level"),
	uint32("Processor timing"),
	uint32("Total physical memory"),
	uint32("Total page file"),
	uint32("Free disk space"),
},
--[[doc
    Message ID:    0x2C

    Message Name:  SID_GAMERESULT

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft,
                   Starcraft Japanese

    Format:        (DWORD) Game type
                   (DWORD) Number of results - always 8
                   (DWORD) [8] Results
                   (STRING) [8] Game players - always 8
                   (STRING) Map name
                   (STRING) Player score

    Remarks:       Contains end-of-game statistics. Player Score is a string containing
                   right-aligned lines separated by 0x0A. The positions in the 'Results'
                   array and the 'Players' array are equivalent.

                   Possible values for Game type:
                   0x00: Normal

                   0x01: Ladder

                   0x03: Ironman (W2BN only)

                   Possible values for Result:
                   0x00: No player

                   0x01: Win

                   0x02: Loss

                   0x03: Draw

                   0x04: Disconnect

]]
[SID_GAMERESULT] = { -- 0x2C
	uint32("Game type"),
	uint32("Number of results - always 8"),
	uint32("[8] Results"),
	stringz("[8] Game players - always 8"),
	stringz("Map name"),
	stringz("Player score"),
},
--[[doc
    Message ID:    0x2D

    Message Name:  SID_GETICONDATA

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                   Warcraft III: The Frozen Throne, Starcraft, Starcraft Japanese, Diablo,
                   Warcraft III

    Format:        [blank]

    Remarks:       Requests the filename & time of the default icons file for the current
                   game. This message must not be sent after recieving SID_ENTERCHAT or
                   Battle.net will terminate the connection.

    Related:       [0x2D] SID_GETICONDATA (S->C)

]]
[SID_GETICONDATA] = { -- 0x2D
},
--[[doc
    Message ID:    0x2E

    Message Name:  SID_GETLADDERDATA

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft II, Starcraft

    Format:        (DWORD) Product ID
                   (DWORD) League
                   (DWORD) Sort method
                   (DWORD) Starting rank
                   (DWORD) Number of ranks to list

    Remarks:       Requests ladder listing.

                   Sort methods:
                   0x00: Highest rating

                   0x01: Fastest climbers

                   0x02: Most wins on record

                   0x03: Most games played

    Related:       [0x2E] SID_GETLADDERDATA (S->C)

]]
[SID_GETLADDERDATA] = { -- 0x2E
	uint32("Product ID"),
	uint32("League"),
	uint32("Sort method"),
	uint32("Starting rank"),
	uint32("Number of ranks to list"),
},
--[[doc
    Message ID:    0x2F

    Message Name:  SID_FINDLADDERUSER

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft II, Starcraft

    Format:        (DWORD) League
                   (DWORD) Sort method
                   (STRING) Username

    Remarks:       Requests a user's status on ladder.

                   Sort method:
                   0x00: Highest rating

                   0x01: Unused

                   0x02: Most wins on record

                   0x03: Most games played

    Related:       [0x2F] SID_FINDLADDERUSER (S->C)

]]
[SID_FINDLADDERUSER] = { -- 0x2F
	uint32("League"),
	uint32("Sort method"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x30

    Message Name:  SID_CDKEY

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Japanese

    Format:        (DWORD) Spawn (0/1)
                   (STRING) CDKey
                   (STRING) Key Owner

    Remarks:       Contains unhashed CD key information.

    Related:       [0x30] SID_CDKEY (S->C)

]]
[SID_CDKEY] = { -- 0x30
	uint32("Spawn"),
	stringz("CDKey"),
	stringz("Key Owner"),
},
--[[doc
    Message ID:    0x31

    Message Name:  SID_CHANGEPASSWORD

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) Client Token
                   (DWORD) Server Token
                   (DWORD) [5] Old password hash
                   (DWORD) [5] New password hash
                   (STRING) Account name

    Remarks:       Changes Battle.net account password. This message must be sent before
                   sending SID_ENTERCHAT.

                   Passwords should be converted to lower case before hashing.

    Related:       [0x31] SID_CHANGEPASSWORD (S->C), [0x0A] SID_ENTERCHAT (C->S)

]]
[SID_CHANGEPASSWORD] = { -- 0x31
	uint32("Client Token"),
	uint32("Server Token"),
	uint32("[5] Old password hash"),
	uint32("[5] New password hash"),
	stringz("Account name"),
},
--[[doc
    Message ID:      0x32

    Message Name:    SID_CHECKDATAFILE

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft,
                     Starcraft Japanese

    Format:          (DWORD) [5] File checksum
                     (STRING) File name

    Remarks:         This message was used to check a digest of a game file. This message
                     is no longer used; developers should use the SID_CHECKDATAFILE2
                     message.

                     The digest is created by using the broken SHA-1 hash on the first
                     64-bytes of the (filesize % 64) times. This due to a bug in the
                     client.

    Related:         [0x3C] SID_CHECKDATAFILE2 (C->S), [0x32] SID_CHECKDATAFILE (S->C)

]]
[SID_CHECKDATAFILE] = { -- 0x32
	uint32("[5] File checksum"),
	stringz("File name"),
},
--[[doc
    Message ID:    0x33

    Message Name:  SID_GETFILETIME

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Warcraft III: The Frozen Throne, Starcraft,
                   Starcraft Japanese, Diablo, Diablo, Warcraft III

    Format:        (DWORD) Request ID
                   (DWORD) Unknown
                   (STRING) Filename

    Remarks:       This packet seems to request the current filetime for the specified
                   file. Purpose of first 2 DWORDs is unknown, however, both are echoed
                   back to the client by Battle.net and do not seem to affect the reply.
                   Because of this it is reasonable to assume that first DWORD at least
                   is a request ID of some kind. This is called into question, however,
                   by the fact that the replying packet also contains the requested
                   filename. The game (STAR/SEXP) always sends the same number in DWORD 1
                   for the file in question. DWORD 2 seems to be null.

                   Known codes for DWORD 1:
                   0x01: tos_usa.txt
                   0x03: bnserver-WAR3.ini
                   0x1A: tos_USA.txt
                   0x1B: bnserver.ini
                   0x1D: icons_STAR.bni
                   0x80000005: IX86ExtraWork.mpq
                   0x80000004: bnserver-D2DV.ini

    Related:       [0x33] SID_GETFILETIME (S->C)

]]
[SID_GETFILETIME] = { -- 0x33
	uint32("Request ID"),
	uint32("Unknown"),
	stringz("Filename"),
},
--[[doc
    Message ID:      0x34

    Message Name:    SID_QUERYREALMS

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Unused (0)
                     (DWORD) Unused (0)
                     (STRING) Unknown (empty)

    Remarks:         Requests a realm listing.

                     This packet is no longer used. SID_QUERYREALMS2 is used instead.

    Related:         [0x34] SID_QUERYREALMS (S->C), [0x40] SID_QUERYREALMS2 (C->S)

]]
[SID_QUERYREALMS] = { -- 0x34
	uint32("Unused"),
	uint32("Unused"),
	stringz("Unknown"),
},
--[[doc
    Message ID:    0x35

    Message Name:  SID_PROFILE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) Username

    Remarks:       This requests a profile for a user.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x35] SID_PROFILE (S->C)

]]
[SID_PROFILE] = { -- 0x35
	uint32("Cookie"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x36

    Message Name:  SID_CDKEY2

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft II

    Format:        (DWORD) Spawn (0/1)
                   (DWORD) Key Length
                   (DWORD) CDKey Product
                   (DWORD) CDKey Value1
                   (DWORD) Server Token
                   (DWORD) Client Token
                   (DWORD) [5] Hashed Data
                   (STRING) Key owner

    Remarks:       This packet is an updated version of SID_CDKEY (0x30), designed to
                   prevent CDKeys from being stolen, by sending them hashed instead of
                   plain-text.

                   The data that should be hashed is:

                   1. Client Token

                   2. Server Token

                   3. Key Product (from decoded CD key)

                   4. Key Value1 (from decoded CD key)

                   5. Key Value2 (from decoded CD key)

    Related:       [0x36] SID_CDKEY2 (S->C), [0x30] SID_CDKEY (C->S)

]]
[SID_CDKEY2] = { -- 0x36
	uint32("Spawn"),
	uint32("Key Length"),
	uint32("CDKey Product"),
	uint32("CDKey Value1"),
	uint32("Server Token"),
	uint32("Client Token"),
	uint32("[5] Hashed Data"),
	stringz("Key owner"),
},
--[[doc
    Message ID:    0x3A

    Message Name:  SID_LOGONRESPONSE2

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Client Token
                   (DWORD) Server Token
                   (DWORD) [5] Password Hash
                   (STRING) Username

    Remarks:       This packet is the same as SID_LOGONRESPONSE, but has additional
                   response codes.

    Related:       [0x3A] SID_LOGONRESPONSE2 (S->C), [0x29] SID_LOGONRESPONSE (C->S)

]]
[SID_LOGONRESPONSE2] = { -- 0x3A
	uint32("Client Token"),
	uint32("Server Token"),
	uint32("[5] Password Hash"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x3C

    Message Name:  SID_CHECKDATAFILE2

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Warcraft II, Starcraft,
                   Starcraft Japanese

    Format:        (DWORD) File size in bytes
                   (DWORD) File hash [5]
                   (STRING) Filename

    Remarks:       Verifies that a file is authentic, by producing a hash of that file
                   and sending it to the server for comparison to the original.

                   The hash is produced by hashing 64-byte chunks of the file. Each time
                   after the first, the result of the previous hash is used to initialize
                   & complete the current hash. The final chunk, which may be less than
                   64 bytes in length, is included in the operation.

    Related:       [0x3C] SID_CHECKDATAFILE2 (S->C)

]]
[SID_CHECKDATAFILE2] = { -- 0x3C
	uint32("File size in bytes"),
	uint32("File hash [5]"),
	stringz("Filename"),
},
--[[doc
    Message ID:    0x3D

    Message Name:  SID_CREATEACCOUNT2

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo

    Format:        (DWORD) [5] Password hash
                   (STRING) Username

    Remarks:       Creates a Battle.net account. Usernames longer than 15 characters are
                   truncated.

                   Passwords should be converted to lower case before hashing, and are
                   only hashed once (unlike SID_LOGONRESPONSE).

    Related:       [0x3D] SID_CREATEACCOUNT2 (S->C), [0x29] SID_LOGONRESPONSE (C->S)

]]
[SID_CREATEACCOUNT2] = { -- 0x3D
	uint32("[5] Password hash"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x3E

    Message Name:  SID_LOGONREALMEX

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Client Token
                   (DWORD) [5] Hashed realm password
                   (STRING) Realm title

    Remarks:       Realm password is always "password". The password hash is created the
                   same way the hash is for logging on to an account.

    Related:       [0x3E] SID_LOGONREALMEX (S->C)

]]
[SID_LOGONREALMEX] = { -- 0x3E
	uint32("Client Token"),
	uint32("[5] Hashed realm password"),
	stringz("Realm title"),
},
--[[doc
    Message ID:    0x40

    Message Name:  SID_QUERYREALMS2

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        [blank]

    Remarks:       Requests a realm listing.

    Related:       [0x40] SID_QUERYREALMS2 (S->C), [0x34] SID_QUERYREALMS (C->S)

]]
[SID_QUERYREALMS2] = { -- 0x40
},
--[[doc
    Message ID:    0x41

    Message Name:  SID_QUERYADURL

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Ad ID

    Remarks:       Requests the URL for an ad if none is given.

    Related:       [0x41] SID_QUERYADURL (S->C)

]]
[SID_QUERYADURL] = { -- 0x41
	uint32("Ad ID"),
},
--[[doc
    Message ID:      0x44

    Message Name:    SID_WARCRAFTGENERAL

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (BYTE) Subcommand ID

                     For subcommand 0x02 (Request ladder map listing):
                     (DWORD) Cookie

                     (BYTE) Number of types requested

                     (DWORD)[] Request data *

                     For subcommand 0x03 (Cancel ladder game search):
                     [blank]

                     For subcommand 0x04 (User stats request):
                     (DWORD) Cookie

                     (STRING) Account name

                     (DWORD) Product ID

                     For subcommand 0x08 (Clan stats request):
                     (DWORD) Cookie

                     (DWORD) Clan Tag

                     (DWORD) Product ID ('WAR3' or 'W3XP')

                     For subcommand 0x09 (Icon list request):
                     (DWORD) Cookie

                     For subcommand 0x0A (Change icon):
                     (DWORD) Icon

    Remarks:         This packet is used for multiple purposes on Warcraft III. Known and
                     validated purposes are listed here.

                     *Not fully known yet.

    Related:         [0x44] SID_WARCRAFTGENERAL (S->C)

]]
[SID_WARCRAFTGENERAL] = { -- 0x44
	uint8("Subcommand ID"),
	uint32("Cookie"),
	uint8("Number of types requested"),
	uint32("[] Request data *"),
	uint32("Cookie"),
	stringz("Account name"),
	uint32("Product ID"),
	uint32("Cookie"),
	uint32("Clan Tag"),
	uint32("Product ID"),
	uint32("Cookie"),
	uint32("Icon"),
},
--[[doc
    Message ID:    0x45

    Message Name:  SID_NETGAMEPORT

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (WORD) Port

    Remarks:       Sets the port used by the client for hosting WAR3/W3XP games. This
                   value is retreived from HKCU\Software\Blizzard Entertainment\Warcraft
                   III\Gameplay\netgameport, and is sent after the user logs on.

]]
[SID_NETGAMEPORT] = { -- 0x45
	uint16("Port"),
},
--[[doc
    Message ID:    0x46

    Message Name:  SID_NEWS_INFO

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Warcraft III: The Frozen Throne, Diablo, Warcraft III

    Format:        (DWORD) News timestamp

    Remarks:       Requests news and MOTD from battle.net.

                   The news timestamp specifies the starting date for the news. To
                   retrieve all available news entries, set this to zero. Timestamps are
                   given in C/Unix format -- that is, the number of seconds since January
                   1, 1970 0:00:00.000 -- and should be biased to UTC.

                   This message should be sent when you receive SID_ENTERCHAT. The
                   official client stops processing messages after the user joins a game
                   or enters a channel, and discards messages with more than 127 entries.

                   News can be requested for older products, but Battle.net will only
                   return the server's Message-of-the-Day. However, this behavior has not
                   been observed in official clients, and for an accurate protocol
                   emulation, its use is not recommended.

    Related:       [0x46] SID_NEWS_INFO (S->C), [0x0A] SID_ENTERCHAT (S->C)

]]
[SID_NEWS_INFO] = { -- 0x46
	uint32("News timestamp"),
},
--[[doc
    Message ID:    0x4B

    Message Name:  SID_EXTRAWORK

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (WORD) Game type
                   (WORD) Length
                   (STRING) Work returned data

    Remarks:       Response for both SID_OPTIONALWORK and SID_REQUIREDWORK.

                   Game type:

                   0x01: Diablo II

                   0x02: Warcraft III

                   0x03: Starcraft

                   0x04: World of Warcraft (Reason for this is not known, but most
                   recent libraries have included it)
                   Length:

                   The length is returned from the call to ExtraWork in the
                   ExtraWork DLL. Traditionally, the library responsible for all
                   ExtraWork requests has been IX86ExtraWork.dll.

                   Work returned data:

                   This data is based on a 1024-byte buffer. The call to ExtraWork
                   takes in a structure and returns the length and buffer based on
                   the game type.

    Related:       [0x4A] SID_OPTIONALWORK (S->C), [0x4C] SID_REQUIREDWORK (S->C)

]]
[SID_EXTRAWORK] = { -- 0x4B
	uint16("Game type"),
	uint16("Length"),
	stringz("Work returned data"),
},
--[[doc
    Message ID:    0x50

    Message Name:  SID_AUTH_INFO

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (DWORD) Protocol ID (0)
                   (DWORD) Platform ID
                   (DWORD) Product ID
                   (DWORD) Version Byte
                   (DWORD) Product language
                   (DWORD) Local IP for NAT compatibility*
                   (DWORD) Time zone bias*
                   (DWORD) Locale ID*
                   (DWORD) Language ID*
                   (STRING) Country abreviation
                   (STRING) Country

    Remarks:       Sends information about the Client to Battle.net.

                   *These fields can be set to zero without breaking logon.

                   Protocol ID:

                   Battle.net's current Protocol ID is 0.

                   Platform ID:

                   A DWORD specifying the client's platform (IX86, PMAC, XMAC,
                   etc).

                   Product ID:

                   A DWORD specifying the client's game.

                   Version:

                   The client's version byte.

                   Product Language:

                   This field is under investigation. It can safely be set to 0.

                   MPQ Locale ID:

                   This field is part of Blizzards multi-lingual MPQ system. Is
                   used to specify which version of an MPQ should be used when the
                   MPQ is available in multiple languages.

                   Local IP:

                   This is the local network IP of the client, in network byte
                   order.

                   Timezone bias:

                   The difference, in minutes, between UTC and local time. The
                   client calculates this value by subtracting the Local Time from
                   the System Time, having converted both to Filetime structures,
                   and then converting the resultant offset to minutes by diving it
                   by 600,000,000. If you wish to understand the mechanism
                   involved, read Microsoft's documentation on File times.

                   Language ID, Country Abbreviation, and Country:

                   These values can be retrieved by querying the system's locale
                   information.

                   Language ID can be retrieved using the GetUserDefaultLangID API.
                   Country Abbreviation & Country can be retrieved using the
                   GetLocaleInfo API to request the LOCALE_SABBREVCTRYNAME and
                   LOCALE_SENGCOUNTRY, respectively.

    Related:       [0x50] SID_AUTH_INFO (S->C)

]]
[SID_AUTH_INFO] = { -- 0x50
	uint32("Protocol ID"),
	uint32("Platform ID"),
	uint32("Product ID"),
	uint32("Version Byte"),
	uint32("Product language"),
	uint32("Local IP for NAT compatibility*"),
	uint32("Time zone bias*"),
	uint32("Locale ID*"),
	uint32("Language ID*"),
	stringz("Country abreviation"),
	stringz("Country"),
},
--[[doc
    Message ID:    0x51

    Message Name:  SID_AUTH_CHECK

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (DWORD) Client Token
                   (DWORD) EXE Version
                   (DWORD) EXE Hash
                   (DWORD) Number of CD-keys in this packet
                   (BOOLEAN) Spawn CD-key

                   For Each Key:

                   (DWORD) Key Length

                   (DWORD) CD-key's product value

                   (DWORD) CD-key's public value

                   (DWORD) Unknown (0)

                   (DWORD) [5] Hashed Key Data
                   (STRING) Exe Information
                   (STRING) CD-Key owner name

    Remarks:       Contains the EXE Version and Hash as reported by CheckRevision(), and
                   CDKey values. Spawn may only be used for STAR and W2BN.

                   The data that should be hashed for 'Hashed Key Data' is:

                   1. Client Token

                   2. Server Token

                   3. Key Product (from decoded CD key)

                   4. Key Public (from decoded CD key)

                   5. (DWORD) 0

                   6. Key Private (from decoded CD key)

    Related:       [0x51] SID_AUTH_CHECK (S->C)

]]
[SID_AUTH_CHECK] = { -- 0x51
	uint32("Client Token"),
	uint32("EXE Version"),
	uint32("EXE Hash"),
	uint32("Number of CD-keys in this packet"),
	uint32{label="Spawn CD-key", desc=Descs.YesNo},
	uint32("Key Length"),
	uint32("CD-key's product value"),
	uint32("CD-key's public value"),
	uint32("Unknown"),
	uint32("[5] Hashed Key Data"),
	stringz("Exe Information"),
	stringz("CD-Key owner name"),
},
--[[doc
    Message ID:    0x52

    Message Name:  SID_AUTH_ACCOUNTCREATE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) [32] Salt (s)
                   (BYTE) [32] Verifier (v)
                   (STRING) Username

    Remarks:       This message is sent to create an NLS-style account. It contains the
                   client's salt and verifier values, which are saved by the server for
                   use with future logons.

                   See the [NLS/SRP Protocol] page for more information.

    Related:       [0x52] SID_AUTH_ACCOUNTCREATE (S->C)

]]
[SID_AUTH_ACCOUNTCREATE] = { -- 0x52
	uint8("[32] Salt"),
	uint8("[32] Verifier"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x53

    Message Name:  SID_AUTH_ACCOUNTLOGON

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) [32] Client Key ('A')
                   (STRING) Username

    Remarks:       This message is sent to the server to initiate a logon. It consists of
                   the client's public key and their UserName.

                   The client's public key is a value calculated by the client and used
                   for a single logon. For more information, see [NLS/SRP Protocol].

    Related:       [0x53] SID_AUTH_ACCOUNTLOGON (S->C)

]]
[SID_AUTH_ACCOUNTLOGON] = { -- 0x53
	uint8("[32] Client Key"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x54

    Message Name:  SID_AUTH_ACCOUNTLOGONPROOF

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) [20] Client Password Proof (M1)

    Remarks:       This message is sent to the server after a successful
                   SID_AUTH_ACCOUNTLOGON. It contains the client's password proof. See
                   [NLS/SRP Protocol] for more information.

    Related:       [0x54] SID_AUTH_ACCOUNTLOGONPROOF (S->C),
                   [0x53] SID_AUTH_ACCOUNTLOGON (S->C)

]]
[SID_AUTH_ACCOUNTLOGONPROOF] = { -- 0x54
	uint8("[20] Client Password Proof"),
},
--[[doc
    Message ID:    0x55

    Message Name:  SID_AUTH_ACCOUNTCHANGE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) [32] Client key (A)
                   (STRING) Username

    Remarks:       This message is used to change the client's password.

    Related:       [0x55] SID_AUTH_ACCOUNTCHANGE (S->C)

]]
[SID_AUTH_ACCOUNTCHANGE] = { -- 0x55
	uint8("[32] Client key"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x56

    Message Name:  SID_AUTH_ACCOUNTCHANGEPROOF

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) [20] Old password proof
                   (BYTE) [32] New password's salt (s)
                   (BYTE) [32] New password's verifier (v)

    Remarks:       This message is sent after receiving a successful
                   SID_AUTH_ACCOUNTCHANGE message, and contains the proof for the
                   client's new password.

                   See [NLS/SRP Protocol] for more information.

    Related:       [0x56] SID_AUTH_ACCOUNTCHANGEPROOF (S->C),
                   [0x55] SID_AUTH_ACCOUNTCHANGE (S->C)

]]
[SID_AUTH_ACCOUNTCHANGEPROOF] = { -- 0x56
	uint8("[20] Old password proof"),
	uint8("[32] New password's salt"),
	uint8("[32] New password's verifier"),
},
--[[doc
    Message ID:      0x57

    Message Name:    SID_AUTH_ACCOUNTUPGRADE

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          [blank]

    Remarks:         This message is sent to upgrade an old account to an NLS-style
                     account. It should be sent when SID_AUTH_ACCOUNTLOGON or
                     SID_AUTH_ACCOUNTCHANGE indicates that an account upgrade is required.

    Related:         [0x57] SID_AUTH_ACCOUNTUPGRADE (S->C),
                     [0x53] SID_AUTH_ACCOUNTLOGON (S->C),
                     [0x55] SID_AUTH_ACCOUNTCHANGE (S->C),
                     [0x58] SID_AUTH_ACCOUNTUPGRADEPROOF (C->S)

]]
[SID_AUTH_ACCOUNTUPGRADE] = { -- 0x57
},
--[[doc
    Message ID:      0x58

    Message Name:    SID_AUTH_ACCOUNTUPGRADEPROOF

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (DWORD) Client Token
                     (DWORD) [5] Old Password Hash
                     (BYTE) [32] New Password Salt
                     (BYTE) [32] New Password Verifier

    Remarks:         Old Password Hash:
                     Broken SHA-1 Double password hash as seen in
                     SID_LOGONRESPONSE(2) OLS.

                     New Password Salt & Verifier:
                     Salt and Verifier values as seen in SID_AUTH_ACCOUNTCREATE.

                     Old Password is the account's current password. The New Password can
                     be the same as the Old Password, but it can be used to change the
                     password as well.

                     Basically this packet would convert the stored password hash to a new
                     one, and thus become NLS. However, this packet is no longer responded
                     to, and upgrading accounts is therefore impossible.(Note: If you have
                     an account in need of upgrading [created with SID_CREATEACCOUNT(2)],
                     you can let the account expire and recreate it with
                     SID_AUTH_ACCOUNTCREATE.)

    Related:         [0x58] SID_AUTH_ACCOUNTUPGRADEPROOF (S->C),
                     [0x57] SID_AUTH_ACCOUNTUPGRADE (C->S),
                     [0x57] SID_AUTH_ACCOUNTUPGRADE (S->C)

]]
[SID_AUTH_ACCOUNTUPGRADEPROOF] = { -- 0x58
	uint32("Client Token"),
	uint32("[5] Old Password Hash"),
	uint8("[32] New Password Salt"),
	uint8("[32] New Password Verifier"),
},
--[[doc
    Message ID:    0x59

    Message Name:  SID_SETEMAIL

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (STRING) Email Address

    Remarks:       Binds an email address to your account.

                   Sending this message is optional. However, you should only send it
                   when either you receive SID_SETEMAIL from the server or you receive
                   status 0x0E from SID_AUTH_ACCOUNTLOGONPROOF.

                   This packet used to be named SID_AUTH_RECONNECT, however Blizzard
                   never had it implemented, and so reused the packet ID for their email
                   system.

    Related:       [0x59] SID_SETEMAIL (S->C), [0x54] SID_AUTH_ACCOUNTLOGONPROOF (S->C)

]]
[SID_SETEMAIL] = { -- 0x59
	stringz("Email Address"),
},
--[[doc
    Message ID:    0x5A

    Message Name:  SID_RESETPASSWORD

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (STRING) Account Name
                   (STRING) Email Address

    Remarks:       Requests that Battle.net reset your password. This packet must be sent
                   before logon.

                   This message requires an email address because Battle.net has to prove
                   it's your account. Since this message must be sent before
                   SID_LOGONRESPONSE, SID_LOGONRESPONSE2, or SID_AUTH_ACCOUNTLOGON, you
                   must supply an e-mail address so Battle.net knows that you may have
                   ownership to it.

                   This packet used to be named SID_AUTH_RECONNECTPROOF, however Blizzard
                   never had it implemented, and so reused the packet ID for their email
                   system.

    Related:       [0x29] SID_LOGONRESPONSE (C->S), [0x3A] SID_LOGONRESPONSE2 (C->S),
                   [0x53] SID_AUTH_ACCOUNTLOGON (C->S)

]]
[SID_RESETPASSWORD] = { -- 0x5A
	stringz("Account Name"),
	stringz("Email Address"),
},
--[[doc
    Message ID:    0x5B

    Message Name:  SID_CHANGEEMAIL

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Diablo II, Warcraft III: The Frozen Throne,
                   Starcraft, Diablo, Warcraft III

    Format:        (STRING) Account Name
                   (STRING) Old Email Address
                   (STRING) New Email Address

    Remarks:       Requests Battle.net to change the email address bound to an account.
                   This packet must be sent before logon.

                   This packet used to be named SID_AUTH_DISCONNECT, however Blizzard
                   never had it implemented, and so reused the packet ID for their email
                   system.

]]
[SID_CHANGEEMAIL] = { -- 0x5B
	stringz("Account Name"),
	stringz("Old Email Address"),
	stringz("New Email Address"),
},
--[[doc
    Message ID:    0x5C

    Message Name:  SID_SWITCHPRODUCT

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne

    Format:        (DWORD) Product ID

    Remarks:       When logging onto WAR3, while having W3XP installed on your system;
                   the client sends two CDKey hashes in SID_AUTH_CHECK and uses 'W3XP' as
                   the Product Id in SID_AUTH_INFO. After a successful SID_AUTH_CHECK,
                   the client then sends this packet with the Product ID set to 'WAR3' to
                   make the switch from expansion to non-expansion.

]]
[SID_SWITCHPRODUCT] = { -- 0x5C
	uint32("Product ID"),
},
--[[doc
    Message ID:      0x5D

    Message Name:    SID_REPORTCRASH

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Warcraft III: The Frozen Throne, Diablo, Warcraft III

    Format:          (DWORD) 0x10A0027
                     (DWORD) Exception code
                     (DWORD) Unknown
                     (DWORD) Unknown

    Remarks:         When the game crashes, (usually) a file named Crashdump is created. If
                     this file exists at the next logon, the contents of it are sent to
                     Battle.net in this message.

                     The first DWORD for Diablo II is a constant value (version?), as seen
                     in Fog.dll.

                     All calls to Fog_10052 result in the output of Crashdump.

                     More research is required.

]]
[SID_REPORTCRASH] = { -- 0x5D
	uint32("0x10A0027"),
	uint32("Exception code"),
	uint32("Unknown"),
	uint32("Unknown"),
},
--[[doc
    Message ID:    0x5E

    Message Name:  SID_WARDEN

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        (VOID) Encrypted Packet

                   Contents of encrypted data
                   (BYTE) Packet Code

                   0x00 - Warden Module Info
                   (BYTE) Success (0x00 = Don't have the module, 0x01 = Have
                   the module)
                   0x01 - Warden Module Data
                   (BYTE) Success (0x00 = MD5 doesn't match, 0x01 = MD5
                   matches)
                   0x02 - Data Checker
                   (WORD) String Length

                   (DWORD) String Checksum

                   (VOID) String Data

                   MEM_CHECK:

                   (BYTE) Success (0x00 = Read data, 0x01 = Unable to
                   read)

                   (VOID) Data (0x00 only)
                   PAGE_CHECK_A:

                   (BYTE) Success (0x00 = SHA1s match, 0x01 = SHA1s don't
                   match)

                   (BYTE) IDXor
                   0x04 - Initialization
                   (DWORD)[4] Unknown

    Remarks:       The packet is encrypted via standard RC4 hashing, using one key for
                   outbound data and another for inbound. Its purpose is to return
                   executable data and checksum information from various Warden modules.
                   Full information on how to handle this packet may be found at the
                   Rudimentary Warden information topic.

                   Documentation provided by iago and Ringo.

    Related:       [0x5E] SID_WARDEN (S->C)

]]
[SID_WARDEN] = { -- 0x5E
	bytes("Encrypted Packet"),
	uint8("Packet Code"),
	uint8("Success"),
	uint8("Success"),
	uint16("String Length"),
	uint32("String Checksum"),
	bytes("String Data"),
	uint8("Success"),
	bytes("Data"),
	uint8("Success"),
	uint8("IDXor"),
	uint32("[4] Unknown"),
},
--[[doc
    Message ID:    0x60

    Message Name:  SID_GAMEPLAYERSEARCH

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       This message requests a list of players for an arranged team game.

    Related:       [0x60] SID_GAMEPLAYERSEARCH (S->C)

]]
[SID_GAMEPLAYERSEARCH] = { -- 0x60
},
--[[doc
    Message ID:    0x65

    Message Name:  SID_FRIENDSLIST

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        [blank]

    Remarks:       Requests a friends list.

    Related:       [0x65] SID_FRIENDSLIST (S->C)

]]
[SID_FRIENDSLIST] = { -- 0x65
},
--[[doc
    Message ID:    0x66

    Message Name:  SID_FRIENDSUPDATE

    Direction:     Client -> Server (Sent)

    Used By:       Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                   Warcraft III

    Format:        (BYTE) Friends list index

    Remarks:       Friends List index is 0-based. (i.e.: friend #1 on friends list would
                   have a value of 0 in this message, friend #2 would have a value of 1).
                   This message requests a check for your friend to see if there are any
                   updates. The server should immediately reply with SID_FRIENDUPDATE.

    Related:       [0x66] SID_FRIENDSUPDATE (S->C)

]]
[SID_FRIENDSUPDATE] = { -- 0x66
	uint8("Friends list index"),
},
--[[doc
    Message ID:    0x70

    Message Name:  SID_CLANFINDCANDIDATES

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) Clan Tag

    Remarks:       This message is sent to the server to check for viable candidates in
                   the channel and friend list, and also to check the availability of the
                   specified clan tag. If 9 or more candidates are found, the official
                   client prompted with a selection of users that he wants to invite to
                   start a clan.

    Related:       [0x70] SID_CLANFINDCANDIDATES (S->C)

]]
[SID_CLANFINDCANDIDATES] = { -- 0x70
	uint32("Cookie"),
	uint32("Clan Tag"),
},
--[[doc
    Message ID:    0x71

    Message Name:  SID_CLANINVITEMULTIPLE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) Clan name
                   (DWORD) Clan tag
                   (BYTE) Number of users to invite
                   (STRING) [] Usernames to invite

    Remarks:       This message is used to invite the initial 9 required members to a new
                   clan. The users specified in this packet will receive 0x72.

    Related:       [0x71] SID_CLANINVITEMULTIPLE (S->C),
                   [0x72] SID_CLANCREATIONINVITATION (S->C)

]]
[SID_CLANINVITEMULTIPLE] = { -- 0x71
	uint32("Cookie"),
	stringz("Clan name"),
	uint32("Clan tag"),
	uint8("Number of users to invite"),
	stringz("[] Usernames to invite"),
},
--[[doc
    Message ID:    0x72

    Message Name:  SID_CLANCREATIONINVITATION

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) Clan tag
                   (STRING) Inviter name
                   (BYTE) Status

    Remarks:       This message is used to reply to an invitation to create a new clan.

    Related:       [0x72] SID_CLANCREATIONINVITATION (S->C), Clan Message Codes

]]
[SID_CLANCREATIONINVITATION] = { -- 0x72
	uint32("Cookie"),
	uint32("Clan tag"),
	stringz("Inviter name"),
	uint8("Status"),
},
--[[doc
    Message ID:    0x73

    Message Name:  SID_CLANDISBAND

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie

    Remarks:       Disbands the clan of which the client is a member. You must be a
                   leader to send this packet.

    Related:       [0x73] SID_CLANDISBAND (S->C)

]]
[SID_CLANDISBAND] = { -- 0x73
	uint32("Cookie"),
},
--[[doc
    Message ID:    0x74

    Message Name:  SID_CLANMAKECHIEFTAIN

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) New Cheiftain

    Remarks:       Changes the clan's chieftain.

    Related:       [0x74] SID_CLANMAKECHIEFTAIN (S->C)

]]
[SID_CLANMAKECHIEFTAIN] = { -- 0x74
	uint32("Cookie"),
	stringz("New Cheiftain"),
},
--[[doc
    Message ID:    0x77

    Message Name:  SID_CLANINVITATION

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) Target User

    Remarks:       This message is used when a leader or officer invites a user to join
                   their clan.

    Related:       [0x77] SID_CLANINVITATION (S->C)

]]
[SID_CLANINVITATION] = { -- 0x77
	uint32("Cookie"),
	stringz("Target User"),
},
--[[doc
    Message ID:    0x78

    Message Name:  SID_CLANREMOVEMEMBER

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) Username

    Remarks:       Kick a member out of the clan. Only clan leaders and officers may
                   perform this action successfully. Members can only be removed if
                   they've been in the clan for over one week.

    Related:       [0x78] SID_CLANREMOVEMEMBER (S->C)

]]
[SID_CLANREMOVEMEMBER] = { -- 0x78
	uint32("Cookie"),
	stringz("Username"),
},
--[[doc
    Message ID:    0x79

    Message Name:  SID_CLANINVITATIONRESPONSE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) Clan tag
                   (STRING) Inviter
                   (BYTE) Response

    Remarks:       This packet is sent to accept or decline an invitation to a clan.

                   Response:
                   0x04: Decline

                   0x06: Accept

    Related:       [0x79] SID_CLANINVITATIONRESPONSE (S->C), Clan Message Codes

]]
[SID_CLANINVITATIONRESPONSE] = { -- 0x79
	uint32("Cookie"),
	uint32("Clan tag"),
	stringz("Inviter"),
	uint8("Response"),
},
--[[doc
    Message ID:    0x7A

    Message Name:  SID_CLANRANKCHANGE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) Username
                   (BYTE) New rank

    Remarks:       Used by leaders and officers to change the rank of a clan member.

                   New rank:

                   0x01: Initiate that has been in the clan for over one week 0x02:
                   Member 0x03: Officer

    Related:       [0x74] SID_CLANMAKECHIEFTAIN (C->S), [0x7A] SID_CLANRANKCHANGE (S->C)

]]
[SID_CLANRANKCHANGE] = { -- 0x7A
	uint32("Cookie"),
	stringz("Username"),
	uint8("New rank"),
},
--[[doc
    Message ID:    0x7B

    Message Name:  SID_CLANSETMOTD

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (STRING) MOTD

    Remarks:       Sets your clan's Message of the Day.

]]
[SID_CLANSETMOTD] = { -- 0x7B
	uint32("Cookie"),
	stringz("MOTD"),
},
--[[doc
    Message ID:    0x7C

    Message Name:  SID_CLANMOTD

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie

    Remarks:       Requests the clan's MOTD.

    Related:       [0x7C] SID_CLANMOTD (S->C)

]]
[SID_CLANMOTD] = { -- 0x7C
	uint32("Cookie"),
},
--[[doc
    Message ID:    0x7D

    Message Name:  SID_CLANMEMBERLIST

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie

    Remarks:       Requests a clan memberlist.

    Related:       [0x7D] SID_CLANMEMBERLIST (S->C), Clan Message Codes

]]
[SID_CLANMEMBERLIST] = { -- 0x7D
	uint32("Cookie"),
},
--[[doc
    Message ID:    0x82

    Message Name:  SID_CLANMEMBERINFORMATION

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Cookie
                   (DWORD) User's clan tag
                   (STRING) Username

    Remarks:       This packet requests information about a user and their current status
                   within their clan. If the user is in a clan, it'll return what clan
                   they're in, their rank, along with the time they joined it in a
                   FILETIME structure.

    Related:       [0x82] SID_CLANMEMBERINFORMATION (S->C), Clan Message Codes

]]
[SID_CLANMEMBERINFORMATION] = { -- 0x82
	uint32("Cookie"),
	uint32("User's clan tag"),
	stringz("Username"),
},
}
