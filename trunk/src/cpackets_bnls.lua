-- Begin cpackets_bnls.lua
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
	array("Data from SID_AUTH_ACCOUNTLOGON", uint32, 16),
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
	stringz("Account name"),
	stringz("Account password"),
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
	stringz("Account name"),
	stringz("Account old password"),
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
	array("Data from SID_AUTH_ACCOUNTCHANGE", uint32, 16),
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
	stringz("Account name"),
	stringz("Account old password"),
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
	strdw("Product ID", Descs.ClientTag),
	uint32("Version DLL digit"),
	stringz("Checksum formula"),
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
	array("Password proof from Battle.net", uint32, 5),
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
	bytes("Data to be hashed"),
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

    Format:          (DWORD) Cookie. 
					 (BYTE) Number of CD-keys to encrypt.
					 (DWORD) Flags.
					 (DWORD[]) Server session key(s), depending on flags.
					 (DWORD[]) Client session key(s), depending on flags.
					 (STRING[]) CD-keys. No dashes or spaces.

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
	uint32("Cookie"),
	uint8("Number of CD-keys to encrypt"),
	uint32("Flags"),
	uint32("Server session key"), 		-- todo: verify array length
	uint32("Client session key"), -- todo: verify array length
	stringz("CD-keys No"), 				-- todo: verify array length
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
	uint32("NLS revision number"),
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
	stringz("Bot ID"),
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
	uint32("Checksum"),
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
	strdw("ProductID", Descs.ClientTag),
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
	array("Signature", uint8, 128),
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
	uint32("Slot index"),
	uint32("NLS revision number"),
	array("Data from account database", uint32, 16),
	array("Data client's SID_AUTH_ACCOUNTLOGON", uint32, 8),
},
--[[doc
    Message ID:      0x14

    Message Name:    BNLS_SERVERLOGONPROOF

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         All Products

    Format:          (DWORD) Slot index.
					 (DWORD[5]) Data from client's SID_AUTH_ACCOUNTLOGONPROOF (0x54).
					 (STRING) Client's account name.

    Remarks:         This message performs two operations. First, it checks if the client's
                     logon was successful. Second, it calculates the data for the server's
                     reply to SID_AUTH_ACCOUNTLOGONPROOF (0x54). If this data is not
                     correct, then the client will not accept the logon attempt as valid.
                     Related Links: [S>0x54] SID_AUTH_ACCOUNTLOGONPROOF, [S>0x14]
                     BNLS_SERVERLOGONPROOF

]]
[BNLS_SERVERLOGONPROOF] = { -- 0x14
	uint32("Slot index"),
	array("Data from client's SID_AUTH_ACCOUNTLOGONPROOF (0x54)", uint32, 5),
	stringz("Client's account name"),
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
	strdw("Product ID", Descs.ClientTag),
	uint32("Version DLL digit"),
	uint32("Flags"),
	uint32("Cookie"),
	stringz("Checksum formula"),
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
	strdw("Product ID", Descs.ClientTag),
	uint32("Flags"),
	uint32("Cookie"),
	uint64("Timestamp for version check archive"),
	stringz("Version check archive filename"),
	stringz("Checksum formula"),
},
-- End cpackets_bnls.lua
