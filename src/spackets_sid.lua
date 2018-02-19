-- Begin spackets_sid.lua
-- Battle.net Messages
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
 			stringz{"Server", key="srvr"},
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
	uint32("Result", nil, {
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
	uint32("Status", nil, {
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
--[[doc	from SCGP client
	Select Case m_Game(i).GameType
        Case 2, 3, 4, 5, 8 'melee / ffa / 1 on 1 / CTF / suddenDeath
            Select Case m_Game(i).Penalty
                Case 1:     m_InfoB(8) = "Melee Disc"
                Case 2:     m_InfoB(8) = "Loss"
            End Select
        Case 6 'Greed
            m_InfoA(8) = "Resources:"
            Select Case m_Game(i).Penalty
                Case 1:     m_InfoB(8) = 2500
                Case 2:     m_InfoB(8) = 5000
                Case 3:     m_InfoB(8) = 7500
                Case 4:     m_InfoB(8) = 10000
            End Select
        Case 7 'Slaughter
            m_InfoA(8) = "Minutes:"
            Select Case m_Game(i).Penalty
                Case 1:     m_InfoB(8) = 15
                Case 2:     m_InfoB(8) = 30
                Case 3:     m_InfoB(8) = 45
                Case 4:     m_InfoB(8) = 60
                Case Else:  m_InfoB(8) = "Unlimited"
            End Select
        Case 9 'Ladder
            Select Case m_Game(i).Penalty
                Case 1:     m_InfoB(8) = "Ladder Disc"
                Case 2:     m_InfoB(8) = "Ladder Loss + Disc"
            End Select
        Case &HA 'UMS
            Select Case m_Game(i).Penalty
                Case 1, 2:  m_InfoB(8) = "Draw"
            End Select
        Case &HB, &HC, &HD 'Team melee / team FFA / team CTF
            m_InfoA(8) = "Teams:"
            Select Case m_Game(i).Penalty
                Case 1:     m_InfoB(8) = 2
                Case 2:     m_InfoB(8) = 3
                Case 3:     m_InfoB(8) = 4
            End Select
        Case &HF 'Top vs Bottom
            m_InfoA(8) = "Teams:"
            If (m_InfoB(9) = "?") Then
                i2 = 8
            Else
                i2 = CInt(m_InfoB(9))
            End If
            If (m_Game(i).Penalty < 1) Or (m_Game(i).Penalty > 7) Then
                m_InfoB(8) = "? vs ?"
            Else
                m_InfoB(8) = m_Game(i).Penalty & " vs " & (i2 - m_Game(i).Penalty)
            End If
        Case Else 'Unknown
            m_InfoA(8) = "???????:"
            m_InfoB(8) = "?"
    End Select
--]]


[SID_GETADVLISTEX] = { -- 0x09
	uint32{"Number of games", key="games"},
	when{Cond.equals("games", 0),
		block = {
			uint32("Status", nil, Descs.GameStatus)
		},
		otherwise = {
			-- error in description?
			-- pvpgn sux? but how starcraft handles both formats?
			iterator{label="Game Information", refkey="games", repeated={
				-- XXX: dirty PvPGN hack
				-- for pvpgn, must be 0 or 1
				-- for battle.net, must be >= 2
				uint16{key="key", getvalueonly=true},
				when{Cond.inlist("key", {0,1}), {
					uint32("Unknown (PvPGN)"), -- seems to be bool32 - only on pvpgn
				}},
				uint16{"Game Type", nil, {
					[0x02] = "Melee",
					[0x03] = "Free for all",
					[0x04] = "one vs one",
					[0x05] = "CTF",
					[0x06] = "Greed",
					[0x07] = "Slaughter",
					[0x08] = "Sudden Death",
					[0x09] = "Ladder",
					[0x0A] = "Use Map Settings",
					[0x0B] = "Team Melee",
					[0x0C] = "Team FFA",
					[0x0D] = "Team CTF",
					[0x0F] = "Top vs Bottom",
					[0x10] = "Iron man ladder",
				}, key = "gametype"},
				-- source:unverified
				casewhen{ 
				{Cond.inlist("gametype", {2, 3, 4, 5, 8}), { -- melee / ffa / 1 on 1 / CTF / suddenDeath
					uint16("Penalty", nil, {
						[1] = "Melee Disc",
						[2] = "Loss",
					})
				}},
				{Cond.equals("gametype", 6), { -- Greed
					uint16("Resources", nil, {
						[1] = 2500,
						[2] = 5000,
						[3] = 7500,
						[4] = 10000,
					})
				}},
				{Cond.equals("gametype", 7), { -- Slaughter
					uint16("Minutes", nil, {
						[1] = 15,
						[2] = 30,
						[3] = 45,
						[4] = 60,
						-- ["default"] = "Unlimited",
					})
				}},
				{Cond.equals("gametype", 9), { -- Ladder
					uint16("Penalty", nil, {
						[1] = "Ladder Disc",
						[2] = "Ladder Loss + Disc",
					})
				}},
				{Cond.equals("gametype", 0xA), { -- UMS
					uint16("Penalty", nil, {
						[1] = "Draw",
						[2] = "Draw",
					})
				}},
				{Cond.inlist("gametype", {0xB,0xC,0xD}), { -- Team melee / team FFA / team CTF
					uint16("Teams", nil, {
						[1] = 2,
						[2] = 3,
						[3] = 4,
					})
				}},
				{Cond.equals("gametype", 0xF), { -- Top vs Bottom
					uint16("Teams", nil, { -- TODO: x vs the rest?
						[1] = "1 vs all",
						[2] = "2 vs all",
						[3] = "3 vs all",
						[4] = "4 vs all",
						[5] = "5 vs all",
						[6] = "6 vs all",
						[7] = "7 vs all",
					})
				}},
				-- default block
				{Cond.always(), { 
					uint16("Parameter", base.HEX) 
				}}
				},
				when{Cond.neg(Cond.inlist("key", {0,1}) ), {
					uint32("Language ID", nil, Descs.LocaleID), -- only on bnet - comment out for pvpgn
				}},
				--sockaddr("Game Host"),
				sockaddr(),
				uint32("Status", nil, Descs.GameStatus),
				uint32("Elapsed time (sec)"),
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
		--condition = function(self, state) return state.packet.chan ~="" end,
		condition = Cond.nequals("chan", "", "notempty"),
		evaluate_packet_before_condition = true,
		repeated = {
			stringz{"Channel name", key="chan"},
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
                   See info on NoCreate Join in SID_JOINCHANNEL.

                   EID_CHANNELRESTRICTED:
                   This is sent when attempting to join a channel which your
                   client is not allowed to join.

                   EID_INFO:
                   This is information supplied by Battle.net. This text
                   is usually displayed by clients in yellow.

                   EID_Error:
                   This is error information supplied by Battle.net. This
                   text is usually displayed by clients in red.

                   EID_Emote:
                   This is sent when any user (including self) uses the emote
                   feature in chat.

    Related:       [0x0E] SID_CHATCOMMAND (C->S), [0x0C] SID_JOINCHANNEL (C->S)
--]]
--[[doc
	
		Battle.net Flags

		User Flags:

		Since the game retrieves these flags automatically from the corresponding game icon file, they are liable to change.
		0x00000001: Blizzard Representative
		0x00000002: Channel Operator
		0x00000004: Speaker
		0x00000008: Battle.net Administrator
		0x00000010: No UDP Support
		0x00000020: Squelched
		0x00000040: Special Guest
		0x00000080: This flag has not been seen, however, it is logical to assume that it was once used since it is in the middle of a sequence.
		0x00000100: Beep Enabled (Defunct)
		0x00000200: PGL Player (Defunct)
		0x00000400: PGL Official (Defunct)
		0x00000800: KBK Player (Defunct)
		0x00001000: WCG Official
		0x00002000: KBK Singles (Defunct)
		0x00002000: KBK Player (Defunct)
		0x00010000: KBK Beginner (Defunct)
		0x00020000: White KBK (1 bar) (Defunct)
		0x00100000: GF Official
		0x00200000: GF Player
		0x02000000: PGL Player

		Order of implementation: SQUELCHED, BLIZZREP, ADMIN, SPEAKER, GUEST, PGLOFFICIAL, WCGOFFICIAL, GFOFFICIAL, CHANNELOP, PGLPLAYER, WCGPLAYER, KBKPLAYER, KBKBEGINNER, KBKWHITE, GFPLAYER, BEEPENABLED, NOUDP.
		
		
		Channel Flags:
		
		0x00001: Public Channel
		0x00002: Moderated
		0x00004: Restricted
		0x00008: Silent
		0x00010: System
		0x00020: Product-Specific
		0x01000: Globally Accessible
		0x04000: Redirected
		0x08000: Chat
		0x10000: Tech Support

]]
[SID_CHATEVENT] = { -- 0x0F
	uint32{"Event ID", key="eid", filter="eid", nil, {
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
	casewhen{
		{Cond.equals("eid", 7), { -- Channel information
			flags{of=uint32, label="Channel Flags", fields=Fields.ChannelFlags},
		}},
		{Cond.always(), { 		-- Otherwise
			flags{of=uint32, label="User's Flags", fields=Fields.UserFlags},
		}},
	},
	uint32("Ping"),
	ipv4("IP Address (Defunct)"),
	uint32("Account number (Defunct)", base.HEX),
	uint32("Registration Authority (Defunct)", base.HEX),
	stringz("Username"),
	-- statstring: 1,2,9,
	-- empty: 3,
	-- text: 5,18
	-- channel name: 7
	casewhen{ 
		{Cond.inlist("eid", {1,2,9}), {
			stringz("Statstring"),
		}},
		{Cond.equals("eid", 7), {
			stringz("Channel name"),
		}},
		{Cond.always(), {
			stringz("Text"),
		}},
	},
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
	stringz{"File extension", length=4},
	wintime("Local file time"),
	stringz("Filename"),
	stringz("Link URL"),
},


--[[doc
    Message ID:    0x17

    Message Name:  SID_READMEMORY

    Direction:     Server -> Client (Received)

    Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                   Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo, 

    Format:        (DWORD) Request ID
                   (DWORD) Address
                   (DWORD) Length

    Remarks:       Rudimentary hack detection system. Was never used probably due to terrible implementation with little security. Yes, it is possible for a PvPGN server to read _EVERYTHING_ that is in the process' memory, including sensitive information such as your CDKey.

	Source: http://darkblizz.org/Forum2/starcraft/the-lost-packets/msg19580
]]
[SID_READMEMORY] = { -- 0x17
	uint32("Request ID"),
	uint32("Address", base.HEX),
	uint32("Length"),
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
	uint32("Cookie"),
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
	uint32("Status", nil, {
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
    Message ID:    0x20

    Message Name:  SID_ANNOUNCEMENT

    Direction:     Server -> Client (Received)

    Format:        (STRING) Text

    Purpose:       Very simply prints out text with the string at 1903B9FBh (the default string, used anyway if the username field is NULL in the chat event struct -- currently a single 0x7F char) as the username. Used to send announcements and arbitrary messages to the user, but this was soon superseded by SID_CHAT subcommands such as EID_INFO, EID_ERROR, and EID_BROADCAST. Printed out with the same color and style as an EID_BROADCAST.
]]
[SID_ANNOUNCEMENT] = { -- 0x20
	stringz("Text"),
},

--[[doc
    Message ID:    0x23

    Message Name:  SID_WRITECOOKIE

    Direction:     Server -> Client (Received)

    Format:        (DWORD) unknown/unparsed -- Flags, Request ID?
                   (DWORD) unknown/unparsed -- Timestamp?
                   (STRING) Registry key name
                   (STRING) Registry key value

    Purpose:       Much like a website cookie, simply stores some arbitrary string to a 'cookie jar' to save preferences et al. which can be retrieved later by the server. Not used because it was quickly discovered that storing preferences produces less problems and were faster by storing them server-side, associating them with the account. It is somewhat curious that these packet IDs are close to SID_PROFILE/SID_WRITEPROFILE (0x26 & 0x27).
	
	Source: http://darkblizz.org/Forum2/starcraft/the-lost-packets/msg19580
]]
[SID_WRITECOOKIE] = { -- 0x23
	uint32("Flags, Request ID?"),
	uint32("Timestamp?"),
	stringz("Registry key name"),
	stringz("Registry key value"),
},

--[[doc
    Message ID:    0x24

    Message Name:  SID_READCOOKIE

    Direction:     Server -> Client (Received)

    Format:        (DWORD) Echoed back, Request ID?
                   (DWORD) Echoed back, Timestamp?
                   (STRING) Registry key name

    Purpose:       Much like a website cookie, simply stores some arbitrary string to a 'cookie jar' to save preferences et al. which can be retrieved later by the server. Not used because it was quickly discovered that storing preferences produces less problems and were faster by storing them server-side, associating them with the account. It is somewhat curious that these packet IDs are close to SID_PROFILE/SID_WRITEPROFILE (0x26 & 0x27).
	
	Source: http://darkblizz.org/Forum2/starcraft/the-lost-packets/msg19580
]]
[SID_READCOOKIE] = { -- 0x24
	uint32("Request ID?"),
	uint32("Timestamp?"),
	stringz("Registry key name"),
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
	uint32{"Number of accounts", key="numaccts"},
	uint32{"Number of keys", key="numkeys"},
	uint32("Request ID"),
	iterator{label="Requested Account", refkey="numaccts", repeated={
		iterator{alias="none", label="Key Values", refkey="numkeys", repeated={
			stringz("Requested Key Value"),
		}},
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
	uint32("Result", nil, {
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
	uint32("Result", nil, {
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
	uint32("Sort method", nil, {
		[0x00] = "Highest rating",
		[0x01] = "Fastest climbers",
		[0x02] = "Most wins on record",
		[0x03] = "Most games played",
	}),
	uint32("Starting rank", base.HEX),
	uint32{"Number of ranks listed", key="ranks"},
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
	uint32("Rank. Zero-based. 0xFFFFFFFF == Not ranked"),
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
	uint32("Result", nil, {
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
	uint32("Password change succeeded", nil, Descs.YesNo),
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
	uint32("Status", nil, {
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
	uint32("Request ID"),
	uint32("Unknown"),
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
	uint32{"Count", key="realms"},
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
	uint32("Cookie"),
	uint8{"Success", nil, Descs.YesNo, key="status"},
	when{Cond.equals("status", 0), {
		stringz("Profile\\Description value"),
		stringz("Profile\\Location value"),
		strdw("Clan Tag"),
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
	uint32("Result", nil, {
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
	uint32{"Result", nil, {
		[0x00] = "Success",
		[0x01] = "Account Does Not Exist",
		[0x02] = "Invalid Password",
		[0x06] = "Account Closed",
	}, key="res"},
	when{Cond.equals("res", 6), {
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
	uint32("Result", nil, {
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
	uint32("Status", nil, {
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
	uint32("MCP Cookie"),
	uint32{"MCP Status", key="status"},
	when{Cond.equals("status", 0), {
		array("MCP Chunk 1", uint32, 2),
		ipv4("IP"),
		uint16{"Port", big_endian=true},
		array("Padding", uint8, 2),
		array("MCP Chunk 2", uint32, 12),
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
	uint32{"Count", key="realms"},
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

	
	SID_WARCRAFTGENERAL

WID_GAMESEARCH 0x00 SEND
	(DWORD)	Cookie
	(DWORD)	Unknown
	(BYTE) 	Unknown
	(BYTE)	Type
		0x00: 1vs1
		0x01: 2vs2
		0x02: 3vs3
		0x03: 4vs4
		0x04: Free for All
	(WORD) Enabled Maps (every bit is one map, from 0x0000 to 0x0FFF)
	(WORD) Unknown
	(BYTE) Unknown
	(DWORD) TickCount
	(DWORD) Race
		0x00000001: Human
		0x00000002: Orc
		0x00000004: Night Elf
		0x00000008: Undead
		0x00000020: Random

WID_GAMESEARCH 0x00 RECV
	(DWORD) Cookie
	(BYTE) Status
		0x00: Search Started
		0x04: Banned CD Key

WID_MAPLIST 0x02 SEND
	(DWORD) Cookie
	(BYTE) Requests
	(DWORD) ID
	(DWORD) Checksum

WID_MAPLIST 0x02 RECV
	(DWORD) Cookie
	(Byte) Responses
	(DWORD) ID
	(DWORD) Checksum
	(WORD) Decompressed Len
	(WORD) Compressed Len
	(VOID) Compressed Data
	(BYTE) Remaining Packets

WID_CANCELSEARCH 0x03 SEND
	-Empty

WID_CANCELSEARCH 0x03 RECV
	(DWORD) Cookie from WID_GAMESEARCH

WID_USERRECORD 0x04 SEND
	(DWORD) Cookie
	(STRING) Account
	(DWORD) Product

WID_USERRECORD 0x04 RECV
	(DWORD) Cookie
	(DWORD) Icon ID
	(BYTE) Ladder Records
	(DWORD) Ladder Type
	(WORD) Wins
	(WORD) Losses
	(BYTE) Level
	(BYTE) Unknown
	(WORD) Experience
	(DWORD) Rank
	(BYTE) Race Records
	(WORD) Wins
	(WORD) Losses
	(BYTE) Team Records
	(DWORD) Ladder Type
	(WORD) Wins
	(WORD) Losses
	(BYTE) Level
	(BYTE) Unknown
	(WORD) Experience
	(DWORD) Rank
	(FILETIME) Last Game
	(BYTE) Partners
	 (STRING) Partner Account

WID_TOURNAMENT 0x07 SEND
	(DWORD) Cookie

WID_TOURNAMENT 0x07 RECV
	(DWORD) Cookie
	(BYTE) Status
		0x00 No Tournament
		0x01 Starting Soon
		0x02 Ending Soon
		0x03 Started
		0x04 Last Call
	(FILETIME) Time of Status
	(WORD) Unknown
	(WORD) Unknown
	(BYTE) Wins
	(BYTE) Losses
	(BYTE) Draws
	(BYTE) Unknown
	(BYTE) Unknown
	(BYTE) Unknown
	(BYTE) Unknown

WID_CLANRECORD 0x08 SEND
	(DWORD) Cookie
	(DWORD) Clan Tag
	(DWORD) Product

WID_CLANRECORD 0x08 RECV
	(DWORD) Cookie
	(BYTE) Ladder Records
	(DWORD) Ladder Type
	(WORD) Wins
	(WORD) Losses
	(BYTE) Level
	(BYTE) Unknown
	(WORD) Experience
	(DWORD) Rank
	(BYTE) Race Records
	(WORD) Wins
	(WORD) Losses

WID_ICONLIST 0x09 SEND
	(DWORD) Cookie

WID_ICONLIST 0x09 RECV
	(DWORD) Cookie
	(DWORD) Unknown
	(BYTE) Tiers
	(BYTE) Icons
	(DWORD) Icon
	(DWORD) Name
	(BYTE) Race
	(WORD) Required Wins
	(BYTE) Unknown

WID_SETICON 0x0A SEND
	(DWORD) Icon 
]]
[SID_WARCRAFTGENERAL] = { -- 0x44
	uint8{"Subcommand ID", key="subcommand", filter="wid", nil, Descs.WarcraftGeneralSubcommandId},
	--[[doc
		WID_GAMESEARCH 0x00 RECV
		(DWORD) Cookie
		(BYTE) Status
			0x00: Search Started
			0x04: Banned CD Key
	]]
	-- Subcommand ID 0: Game search?
	when{Cond.equals("subcommand", 0), {
		uint32("Cookie"),
		uint8("Status", nil, {
			[0x00] = "Search Started",
			[0x04] = "Banned CD Key",
		}),
	}},
	
	--[[doc
		WID_MAPLIST 0x02 RECV
			(DWORD) Cookie
			(Byte) Responses
			(DWORD) ID
			(DWORD) Checksum
			(WORD) Decompressed Len
			(WORD) Compressed Len
			(VOID) Compressed Data
			(BYTE) Remaining Packets
	]]
	-- Subcommand ID 2: Request ladder map listing
	when{Cond.equals("subcommand", 2), {
		uint32("Cookie"),
		uint8("Responses"),
		strdw("ID", Descs.WarcraftGeneralRequestType),
		uint32("Checksum", base.HEX),
		uint16("Decompressed Len"),
		uint16("Compressed Len"),
		-- TODO: length as refkey
		-- array("Compressed Data", uint8,
		uint8("Remaining Packets"),
	}},
	
	--[[doc
	WID_USERRECORD 0x04 RECV
		(DWORD) Cookie
		(DWORD) Icon ID
		(BYTE) Ladder Records
		(DWORD) Ladder Type
		(WORD) Wins
		(WORD) Losses
		(BYTE) Level
		(BYTE) Unknown
		(WORD) Experience
		(DWORD) Rank
		(BYTE) Race Records
		(WORD) Wins
		(WORD) Losses
		(BYTE) Team Records
		(DWORD) Ladder Type
		(WORD) Wins
		(WORD) Losses
		(BYTE) Level
		(BYTE) Unknown
		(WORD) Experience
		(DWORD) Rank
		(FILETIME) Last Game
		(BYTE) Partners
		(STRING) Partner Account
	]]
	-- Subcommand ID 4: User stats request
	when{Cond.equals("subcommand", 4), {
		uint32("Cookie"),
		strdw("Icon ID", Descs.W3IconNames),
		uint8{"Number of ladder records", key="ladders"},
		iterator{label="Ladder Record", refkey="ladders", repeated={
			strdw("Ladder type", Descs.W3LadderType),
			uint16("Number of wins"),
			uint16("Number of losses"),
			uint8("Level"),
			uint8("Hours until XP decay"),
			uint16("Experience"),
			uint32("Rank"),
		}},
		uint8{"Number of race records", key="races"},
		iterator{label="Race Record", refkey="races", repeated={
			uint16("Wins"),
			uint16("Losses"),
		}},
		uint8{"Number of team records", key="teams"},
		iterator{label="Team Record", refkey="teams", repeated={
			strdw("Type of team", Descs.W3TeamType),
			uint16("Number of wins"),
			uint16("Number of losses"),
			uint8("Level"),
			uint8("Hours until XP decay"),
			uint16("Experience"),
			uint32("Rank"),
			wintime("Time of last game played"),
			uint8{"Number of partners", key="partners"},
			iterator{label="Partners", refkey="partners", repeated={
				stringz("Names of partners"),
			}},
		}},
	}},
	
	--[[doc
	WID_TOURNAMENT 0x07 RECV
		(DWORD) Cookie
		(BYTE) Status
			0x00 No Tournament
			0x01 Starting Soon
			0x02 Ending Soon
			0x03 Started
			0x04 Last Call
		(FILETIME) Time of Status
		(WORD) Unknown
		(WORD) Unknown
		(BYTE) Wins
		(BYTE) Losses
		(BYTE) Draws
		(BYTE) Unknown
		(BYTE) Unknown
		(BYTE) Unknown
		(BYTE) Unknown
	]]
	-- Subcommand ID 7: WID_TOURNAMENT
	when{Cond.equals("subcommand", 7), {
		uint32("Cookie"),
		uint8("Status", nil, {
			[0x00] = "No Tournament",
			[0x01] = "Starting Soon",
			[0x02] = "Ending Soon",
			[0x03] = "Started",
			[0x04] = "Last Call",
		}),
		wintime("Time of Status"),
		uint16("Unknown"),
		uint16("Unknown"),
		uint8("Wins"),
		uint8("Losses"),
		uint8("Draws"),
		uint8("Unknown"),
		uint8("Unknown"),
		uint8("Unknown"),
		uint8("Unknown"),
	}},
	
	-- Subcommand ID 8: Clan stats request
	when{Cond.equals("subcommand", 8), {
		uint32("Cookie"),
		uint8{"Number of ladder records", key="ladders"},
		iterator{label="Ladder Record", refkey="ladders", repeated={
			strdw("Ladder type", Descs.W3LadderType),
			uint16("Number of wins"),
			uint16("Number of losses"),
			uint8("Level"),
			uint8("Hours until XP decay"),
			uint16("Experience"),
			uint32("Rank"),
		}},
		uint8{"Number of race records", key="races"},
		iterator{label="Race Record", refkey="races", repeated={
			uint16("Wins"),
			uint16("Losses"),
		}},
	}},
	
	--[[doc
	WID_ICONLIST 0x09 RECV
		(DWORD) Cookie
		(DWORD) Unknown
		(BYTE) Tiers
		(BYTE) Icons
		(DWORD) Icon
		(DWORD) Name
		(BYTE) Race
		(WORD) Required Wins
		(BYTE) Unknown
	--]]
	-- Subcommand ID 9: Icon list request
	when{Cond.equals("subcommand", 9), {
		uint32("Cookie"),
		uint32("Unknown", base.HEX),
		uint8("Tiers"),
		uint8{"Number of Icons", key="icons"},
		iterator{label="Icon", refkey="icons", repeated={
			strdw("Icon", Descs.W3Icon),
			strdw("Name", Descs.W3IconNames),
			uint8("Race", nil, Descs.W3Races),
			uint16("Wins required"),
			uint8("Unknown", base.HEX),
		}},
	}},
},

--[[doc
    Message ID:    0x43

    Message Name:  SID_WARCRAFTSOMETHING

    Direction:     Server -> Client (Received)

    Format:        (DWORD) Unknown (0)
	
    Purpose:       Unknown. I am unable to disassemble Warcraft 3's game.dll without a lot of trouble, and therefore I have limited knowledge of it. It has been seen once, after SID_LOGONPROOF (0x54) in the NLS logon sequence.
	
	source: http://darkblizz.org/Forum2/starcraft/the-lost-packets/msg19580
]]
[ SID_WARCRAFTSOMETHING] = { -- 0x43
	uint32("Unknown (0)"),
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
	uint8{"Number of entries", key="news" },
	posixtime("Last logon timestamp"),
	posixtime("Oldest news timestamp"),
	posixtime("Newest news timestamp"),
	iterator{label="News", refkey="news", repeated={
		posixtime{"Timestamp", key="stamp"},
		when{Cond.equals("stamp", 0),
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
	array("Unknown", uint32, 5),
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
	uint32{"Logon Type", key="logontype", nil, {
		[0x00] = "Broken SHA-1 (STAR/SEXP/D2DV/D2XP)",
		[0x01] = "NLS Version 1",
		[0x02] = "NLS Version 2 (WAR3/W3XP)",
	}},
	uint32("Server Token", base.HEX),
	uint32("UDPValue", base.HEX),
	wintime("MPQ filetime"),
	stringz("IX86ver filename"),
	stringz("ValueString"),
	when{Cond.equals("logontype", 2), {
		 array("Server signature", uint8, 128),
	}},
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
[SID_AUTH_CHECK] = { -- 0xff51
	uint32{"Result", key="res", base.HEX, {
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
	
	casewhen{ 
		{Cond.inlist("res", {0x100, 0x102}), {
			stringz("MPQ Filename"),
		}},
		{Cond.inlist("res", {0x201, 0x211}), {
			stringz("Username"),
		}},
		{Cond.always(), {
			stringz("Additional Information"),
		}},
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
	uint32("Status", nil, {
		[0x00] = "Successfully created account name",
		[0x04] = "Name already exists",
		[0x07] = "Name is too short/blank",
		[0x08] = "Name contains an illegal character",
		[0x09] = "Name contains an illegal word",
		[0x0a] = "Name contains too few alphanumeric characters",
		[0x0b] = "Name contains adjacent punctuation characters",
		[0x0c] = "Name contains too many punctuation characters",
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
	uint32("Status", nil, {
		[0x00] = "Logon accepted, requires proof",
		[0x01] = "Account doesn't exist",
		[0x05] = "Account requires upgrade",
	}),
	array("Salt", uint8, 32),
	array("Server Key", uint8, 32),
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

                   0x00: Logon successful.
				   0x02: Incorrect password.
                   0x0E: An email address should be registered for this account.
                   0x0F: Custom error. A string at the end of this message contains
                   the error.
				   
                   This message confirms the validity of the client password proof and
                   supplies the server password proof. See [NLS/SRP Protocol] for more
                   information.

    Related:       [0x54] SID_AUTH_ACCOUNTLOGONPROOF (C->S)

]]
[SID_AUTH_ACCOUNTLOGONPROOF] = { -- 0x54
	uint32{"Status", key="status", nil, {
		[0x00] = "Logon successful",
		[0x02] = "Incorrect password",
		[0x0E] = "An email address should be registered for this account",
		[0x0F] = "Custom error. A string at the end of this message contains the error",
	}},
	array("Server Password Proof", uint8, 20),
	when{Cond.equals("status", 0xF), {
		stringz("Additional information"),
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
	uint32("Status", nil, {
		[0x00] = "Change accepted, requires proof",
		[0x01] = "Account doesn't exist",
		[0x05] = "Account requires upgrade",
	}),
	array("Salt", uint8, 32),
	array("Server Key", uint8, 32),
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
	uint32("Status code", nil, {
		[0x00] = "Password changed",
		[0x02] = "Incorrect old password",
	}),
	array("Server password proof for old password", uint8, 20),
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
	uint32("Status", nil, {
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
	uint32("Status", nil, {
		[0x00] = "Password changed",
		[0x02] = "Incorrect old password",
	}),
	array("Password proof", uint32, 5),
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
	uint8{"Number of players", key="players"},
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
	uint8{"Number of Entries", key="friends"},
	iterator{label="Friend", refkey="friends", repeated={
		stringz("Account"),
		flags{of=uint8, label="Status", fields={
			{sname="Mutual", mask=0x01, desc=Descs.YesNo},
			{sname="DND", mask=0x02, desc=Descs.YesNo},
			{sname="Away", mask=0x04, desc=Descs.YesNo} 
		}},
		uint8("Location", nil, Descs.OnlineStatus),
		strdw("ProductID", Descs.ClientTag),
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
	uint8("Location", nil, Descs.OnlineStatus),
	strdw("ProductID", Descs.ClientTag),
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
	uint8("Friend Type", nil, {
		[0x00] = "Non-mutual",
		[0x01] = "Mutual",
		[0x02] = "Nonmutual, DND",
		[0x03] = "Mutual, DND",
		[0x04] = "Nonmutual, Away",
		[0x05] = "Mutual, Away",
	}),
	uint8("Friend Status", nil, {
		[0x00] = "Offline",
		[0x02] = "In chat",
		[0x03] = "In public game",
		[0x05] = "In private game",
	}),
	strdw("ProductID", Descs.ClientTag),
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

                   0x00: Successfully found candidate(s) 
				   0x01: Clan tag already taken 
				   0x08: Already in clan 
				   0x0a: Invalid clan tag specified

    Related:       [0x70] SID_CLANFINDCANDIDATES (C->S), Clan Message Codes

]]
[SID_CLANFINDCANDIDATES] = { -- 0x70
	uint32("Cookie"),
	uint8("Status", nil, {
		[0x00] = "Successfully found candidate(s)",
		[0x01] = "Clan tag already taken",
		[0x08] = "Already in clan",
		[0x0a] = "Invalid clan tag specified",
	}),
	uint8{"Number of potential candidates", key="names"},
	iterator{alias="none", refkey="names", repeated={
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
	uint32("Cookie"),
	uint8("Result", nil, {
		[0x00] = "Everyone accepted",
		[0x04] = "Declined",
		[0x05] = "Not available",
	}),
	-- condition = function(self, state) return state.packet.acc ~="" end,
	iterator{alias="none", condition = Cond.nequals("acc", ""), repeated = {
		stringz{"Failed Account", key="acc"},
	}}
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
	uint32("Cookie"),
	strdw("Clan Tag"),
	stringz("Clan Name"),
	stringz("Inviter's username"),
	uint8{"Number of users being invited", key="users"},
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

                   0x00: Success 
				   0x02: Can't change until clan is a week old 
				   0x04: Declined 
				   0x05: Failed 
				   0x07: Not Authorized 
				   0x08: Not Allowed

    Related:       [0x74] SID_CLANMAKECHIEFTAIN (C->S), Clan Message Codes

]]
[SID_CLANMAKECHIEFTAIN] = { -- 0x74
	uint32("Cookie"),
	uint8("Status", nil, {
		[0x00] = "Success",
		[0x02] = "Can't change until clan is a week old",
		[0x04] = "Declined",
		[0x05] = "Failed",
		[0x07] = "Not Authorized",
		[0x08] = "Not Allowed",
	}),
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
                   0x01: Initiate that has been in the clan for over one week 
				   0x02: Member 
				   0x03: Officer 
				   0x04: Leader

    Related:       Clan Message Codes

]]
[SID_CLANINFO] = { -- 0x75
	uint8("Unknown"),
	strdw("Clan tag"),
	uint8("Rank", nil, Descs.ClanRank),
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

                   0x00: Invitation accepted 
				   0x04: Invitation declined 
				   0x05: Failed to invite user 
				   0x09: Clan is full

    Related:       [0x77] SID_CLANINVITATION (C->S)

]]
[SID_CLANINVITATION] = { -- 0x77
	uint32("Cookie"),
	uint8("Result", nil, {
		[0x00] = "Invitation accepted",
		[0x04] = "Invitation declined",
		[0x05] = "Failed to invite user",
		[0x09] = "Clan is full",
	}),
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

                   0x00: Removed 
				   0x01: Removal failed 
				   0x02: Can not be removed yet
                   0x07: Not authorized to remove 
				   0x08: Not allowed to remove

    Related:       [0x78] SID_CLANREMOVEMEMBER (C->S), Clan Message Codes

]]
[SID_CLANREMOVEMEMBER] = { -- 0x78
	uint32("Cookie"),
	uint8("Status", nil, {
		[0x00] = "Removed",
		[0x01] = "Removal failed",
		[0x02] = "Can not be removed yet",
		[0x07] = "Not authorized to remove",
		[0x08] = "Not allowed to remove",
	}),
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
	strdw("Clan tag"),
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

                   0x00: Successfully changed rank 
				   0x01: Failed to change rank
                   0x02: Cannot change user's rank yet 
				   0x07: Not authorized to change user rank * 
				   0x08: Not allowed to change user rank **

                   * This will be received when you are not a shaman/chieftain and you're
                   trying to change the rank of another user.

                   ** This will be received when you are trying to change rank of someone
                   who is higher than you, i.e. chieftain, or an initiate.

    Related:       [0x7A] SID_CLANRANKCHANGE (C->S), Clan Message Codes

]]
[SID_CLANRANKCHANGE] = { -- 0x7A
	uint32("Cookie"),
	uint8("Status", nil, {
		[0x00] = "Successfully changed rank",
		[0x01] = "Failed to change rank",
		[0x02] = "Cannot change user's rank yet",
		[0x07] = "Not authorized to change user rank",
		[0x08] = "Not allowed to change user rank",
	}),
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

                   0x00: Offline 
				   0x01: Online

                   Rank:

                   0x00: Initiate that has been in the clan for less than one week
                   0x01: Initiate that has been in the clan for over one week 
				   0x02: Member 
				   0x03: Officer 
				   0x04: Leader

                   Location:

                   Where the user is, i.e., game name, channel name, or this may be
                   null if the user is not online.

    Related:       [0x7D] SID_CLANMEMBERLIST (C->S), Clan Message Codes

]]
[SID_CLANMEMBERLIST] = { -- 0x7D
	uint32("Cookie"),
	uint8("Number of Members"),
	stringz("Username"),
	uint8("Rank", nil, Descs.ClanRank),
	uint8("Online Status", nil, {
		[0x00] = "Offline",
		[0x01] = "Online",
	}),
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
                   0x01: Initiate that has been in the clan for over one week 
				   0x02: Member 
				   0x03: Officer 
				   0x04: Leader

                   Status:

                   0x00: Offline 0x01: Online (not in either channel or game) 0x02:
                   In a channel 0x03: In a public game 0x05: In a private game

                   Location:

                   This field is where the user is, i.e., game name, channel name.

    Related:       Clan Message Codes

]]
[SID_CLANMEMBERSTATUSCHANGE] = { -- 0x7F
	stringz("Username"),
	uint8("Rank", nil, Descs.ClanRank),
	uint8("Status", nil, {
		[0x00] = "Offline",
		[0x01] = "Online (not in either channel or game)",
		[0x02] = "In a channel",
		[0x03] = "In a public game",
		[0x05] = "In a private game",
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
	uint8("Old rank", nil, Descs.ClanRank),
	uint8("New rank", nil, Descs.ClanRank),
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
-- End spackets_sid.lua
