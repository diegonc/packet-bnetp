local X = require('xproto')
local p = X.protocol('bnetp', 'Battle.net Protocol',
  { key = 'tcp.port', value = 6112 })

--[[
  `request_packet_data` is a custom DSL construct that
  calls the `request` method on the state object to perform
  reassembly of TCP PDUs all in one place.
--]]
p.api.request_packet_data = function(proto, ...)
  local args = proto.utils.make_args_table_with_positional_map(
    { 'keyref', 'already_consumed' },
    ...
  )

  if not args.keyref or type(args.keyref) ~= 'string' then
    error('keyref parameter is a required value of type string'
      .. package.loaded.debug.traceback()
    )
  end

  if args.already_consumed and type(args.already_consumed) ~= 'number' then
    error('already_consumed parameter is an optional number'
      .. package.loaded.debug.traceback()
    )
  end

  return {
    args = args,
    dissect = function(self, state)
      local plen = state.packet[self.args.keyref]
      state:request(plen - (self.args.already_consumed or 0))
    end
  }
end

p:entrypoint {
  p:lookahead_uint8_check(0xFF),
  p:begin_packet(),
  p:uint8 {
    label = 'Header Type',
    display = base.HEX,
    key = 'type',
    filter = 'type'
  },
  p:uint8 {
    'Packet ID',
    base.HEX,
    -- Server/Client packet names are symmetric,
    -- pick any one collection
    p.descs.client_packets,
    key = 'pid',
    filter = 'pid'
  },
  p:uint16 {
    label = 'Packet Length',
    display = base.DEC,
    key = 'plen',
    filter = 'plen'
  },
  -- Before jumping to the corresponding packet description,
  -- request all the data in this packet.
  --
  -- This is done for perfomace and also because `stringz`
  -- can only request one byte at a time and some kind of
  -- Wireshark reassembly limit is reached before the whole
  -- packet can be dissected successfuly.
  p:request_packet_data('plen', 4),
  p:jump {
    ref = 'pid',
    ccollection = 'client_packets',
    scollection = 'server_packets'
  },
  p:consume('plen'),
  p:end_packet('plen')
}

p:collection {
  name = 'client_packets',
  packets = {
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
    {
      id = 0x00,
      name = 'SID_NULL',
      def = {},
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
    {
      id = 0x02,
      name = 'SID_STOPADV',
      def = {},
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
    {
      id = 0x05,
      name = 'SID_CLIENTID',
      def = {
        p:uint32("Registration Version"),
        p:uint32("Registration Authority"),
        p:uint32("Account Number"),
        p:uint32("Registration Token"),
        p:stringz("LAN Computer Name"),
        p:stringz("LAN Username"),
      },
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
    {
      id = 0x06,
      name = 'SID_STARTVERSIONING',
      def = {
        p:strdw("Platform ID", p.descs.PlatformID),
        p:strdw("Product ID", p.descs.ClientTag),
        p:uint32("Version Byte"),
        p:uint32("Unknown"),
      },
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
    {
      id = 0x07,
      name = 'SID_REPORTVERSION',
      def = {
        p:strdw("Platform ID", p.descs.PlatformID),
        p:strdw("Product ID", p.descs.ClientTag),
        p:uint32("Version Byte"),
        p:uint32("EXE Version"),
        p:uint32("EXE Hash"),
        p:stringz("EXE Information"),
      },
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
    {
      id = 0x08,
      name = 'SID_STARTADVEX',
      def = {
        p:uint32("Password protected", nil, p.descs.YesNo),
        p:uint32("Unknown"),
        p:uint32("Unknown"),
        p:uint32("Unknown"),
        p:uint32("Unknown"),
        p:uint32("Port"),
        p:stringz("Game name"),
        p:stringz("Game password"),
        p:stringz("Game stats - flags, creator, statstring"),
        p:stringz("Map name - 0x0d terminated"),
      },
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
    {
      id = 0x09,
      name = 'SID_GETADVLISTEX',
      def = {
        p:uint16('For STAR/SEXP/SSHR/JSTR and W2BN - game type', nil, p.descs.GameType),
        p:uint16('Product-specific condition 2 (unknown, 0)'),
        p:uint32('Product-specific condition 3'),
        p:uint32('Product-specific condition 4 (unkown, 0)'),
        p:uint32('List count'),
        p:stringz('Game name'),
        p:stringz('Game password'),
        p:stringz('Game stats'),
      },
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
    {
      id = 0x0A,
      name = 'SID_ENTERCHAT',
      def = {
        p:stringz("Username"),
        p:stringz("Statstring"),
      },
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
    {
      id = 0x0B,
      name = 'SID_GETCHANNELLIST',
      def = {
        p:strdw("Product ID", p.descs.ClientTag),
      },
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
    {
      id = 0x0C,
      name = 'SID_JOINCHANNEL',
      def = {
        p:uint32("Flags", nil, {
          [0x00] = "NoCreate join",
          [0x01] = "First join",
          [0x02] = "Forced join",
          [0x05] = "D2 first join",
        }),
        p:stringz("Channel"),
      },
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
    {
      id = 0x0E,
      name = 'SID_CHATCOMMAND',
      def = {
        p:stringz("Text"),
      },
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
    {
      id = 0x10,
      name = 'SID_LEAVECHAT',
      def = {},
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
    {
      id = 0x12,
      name = 'SID_LOCALEINFO',
      def = {
        p:wintime("System time"),
        p:wintime("Local time"),
        p:uint32("Timezone bias"),
        p:uint32("SystemDefaultLCID"),
        p:uint32("UserDefaultLCID"),
        p:uint32("UserDefaultLangID"),
        p:stringz("Abbreviated language name"),
        p:stringz("Country name"),
        p:stringz("Abbreviated country name"),
        p:stringz("Country (English)"),
      },
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
    {
      id = 0x14,
      name = 'SID_UDPPINGRESPONSE',
      def = {
        --[[doc   or maybe uint32-hex? ]]
	      p:strdw("UDPCode"),
      },
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
    {
      id = 0x15,
      name = 'SID_CHECKAD',
      def = {
        p:strdw("Platform ID", p.descs.PlatformID),
        p:strdw("Product ID", p.descs.ClientTag),
        p:uint32("ID of last displayed banner"),
        p:posixtime("Current time"),
      },
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
    {
      id = 0x16,
      name = 'SID_CLICKAD',
      def = {
        p:uint32("Ad ID"),
        p:uint32("Request type", nil, {
          [0] = "Client used SID_QUERYADURL",
          [1] = "Client did not use SID_QUERYADURL",
        }),
      },
    },
    --[[doc
        Message ID:    0x17

        Message Name:  SID_READMEMORY

        Direction:     Client -> Server (Sent)

        Used By:       Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Diablo II,
                      Warcraft II, Starcraft, Starcraft Japanese, Diablo, Diablo, 

        Format:        (DWORD) Request ID
                      (VOID)  Memory

        Remarks:       Rudimentary hack detection system. Was never used probably due to terrible implementation with little security. Yes, it is possible for a PvPGN server to read _EVERYTHING_ that is in the process' memory, including sensitive information such as your CDKey.

      Source: http://darkblizz.org/Forum2/starcraft/the-lost-packets/msg19580
    ]]
    {
      id = 0x17,
      name = 'SID_READMEMORY',
      def = {
        p:uint32("Request ID"),
        p:consume("plen", "Memory", 'memory'),
      },
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
    {
      id = 0x18,
      name = 'SID_REGISTRY',
      def = {
        p:uint32("Cookie"),
        p:stringz("Key Value"),
      },
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
    {
      id = 0x1A,
      name = 'SID_STARTADVEX2',
      def = {
        p:uint32("Password Protected"),
        p:uint32("Unknown"),
        p:uint32("Unknown"),
        p:uint32("Unknown"),
        p:uint32("Unknown"),
        p:uint32("Port"),
        p:stringz("Game name"),
        p:stringz("Game password"),
        p:stringz("Unknown"),
        p:stringz("Game stats - Flags, Creator, Statstring"),
      },
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
    {
      id = 0x1B,
      name = 'SID_GAMEDATAADDRESS',
      def = {
        p:sockaddr("Address"),
      },
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
    {
      id = 0x1C,
      name = 'SID_STARTADVEX3',
      def = {
        p:flags('State', p.uint32, {
          { 'Game is private',                            0x01, p.descs.YesNo },
          { 'Game is full',                               0x02, p.descs.YesNo },
          { 'Game contains players (other than creator)', 0x04, p.descs.YesNo },
          { 'Game is in progress',                        0x08, p.descs.YesNo },
        }),
        p:uint32('Time since creation'),
        p:uint16('Game Type', nil, {
          [0x02] = 'Melee',
          [0x03] = 'Free for All',
          [0x04] = '1 vs 1',
          [0x09] = 'Ladder',
          [0x0A] = 'Use Map Settings',
          [0x0F] = 'Top vs Bottom',
          [0x10] = 'Iron Man Ladder (W2BN only)',
        }),
        p:uint16('Parameter'),
        p:uint32('Unknown'),
        p:uint32('Ladder', nil, {
          [0x00] = 'NonLadder',
          [0x01] = 'Ladder',
          [0x03] = 'Iron Man Ladder (W2BN only)',
        }),
        p:stringz('Game name'),
        p:stringz('Game password'),
        p:stringz('Game statstring')
      },
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
    {
      id = 0x1E,
      name = 'SID_CLIENTID2',
      def = {
        p:uint32("Server Version"),
        p:uint32("Registration Version"),
        p:uint32("Registration Authority"),
        p:uint32("Registration Authority"),
        p:uint32("Registration Version"),
        p:uint32("Account Number"),
        p:uint32("Registration Token"),
        p:stringz("LAN computer name"),
        p:stringz("LAN username"),
      },
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
    {
      id = 0x1F,
      name = 'SID_LEAVEGAME',
      def = {},
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
    {
      id = 0x21,
      name = 'SID_DISPLAYAD',
      def = {
        p:strdw("Platform ID", p.descs.PlatformID),
        p:strdw("Product ID", p.descs.ClientTag),
        p:uint32("Ad ID"),
        p:stringz("Filename"),
        p:stringz("URL"),
      },
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
    {
      id = 0x22,
      name = 'SID_NOTIFYJOIN',
      def = {
        p:strdw("Product ID", p.descs.ClientTag),
        p:uint32("Product version"),
        p:stringz("Game Name"),
        p:stringz("Game Password"),
      },
    },
    --[[doc
        Message ID:    0x24

        Message Name:  SID_READCOOKIE

        Direction:     Server -> Client (Received)

        Format:        (DWORD) First DWORD from S -> C
                      (DWORD) Second DWORD from S -> C
                      (STRING) Registry key name
                      (STRING) Registry key value
      
        Purpose:       Much like a website cookie, simply stores some arbitrary string to a 'cookie jar' to save preferences et al. which can be retrieved later by the server. Not used because it was quickly discovered that storing preferences produces less problems and were faster by storing them server-side, associating them with the account. It is somewhat curious that these packet IDs are close to SID_PROFILE/SID_WRITEPROFILE (0x26 & 0x27).
    ]]
    {
      id = 0x24,
      name = 'SID_READCOOKIE',
      def = {
        p:uint32("First DWORD from S -> C"),
        p:uint32("Second DWORD from S -> C"),
        p:stringz("Registry key name"),
        p:stringz("Registry key value"),
      },
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
    {
      id = 0x25,
      name = 'SID_PING',
      def = {
        p:uint32('Ping Value', base.HEX)
      },
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

                        profile\age �

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

                        IronMan Ladder Games: ‡
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

                        �  This field is defunct.

                        ‡ W2BN only.

        Related:         [0x26] SID_READUSERDATA (S->C)

    ]]
    {
      id = 0x26,
      name = 'SID_READUSERDATA',
      def = {
        p:uint32{"Number of Accounts", key="numaccts"},
        p:uint32{"Number of Keys", key="numkeys"},
        p:uint32("Request ID"),
        p:iterator{alias="none", label="Requested Account", refkey="numaccts", repeated={
          p:stringz("Account"),
        }},
        p:iterator{alias="none", label="Keys", refkey="numkeys", repeated={
          p:stringz("Key"),
        }},
      },
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
    {
      id = 0x27,
      name = 'SID_WRITEUSERDATA',
      def = {
        p:uint32{label="Number of accounts", key="numaccts"},	-- TODO: it works?
        p:uint32{label="Number of keys", key="numkeys"},
        p:iterator{label="Accounts to update", refkey="numaccts", repeated={
          p:stringz("Account" --[[,{[""] = "Own account",}]]),
        }},
        p:iterator{label="Keys to update", refkey="numkeys", repeated={
          p:stringz("Key"),
        }},
        p:iterator{label="New values", refkey="numkeys", repeated={
          p:stringz("New value"),
        }},
      },
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
    {
      id = 0x29,
      name = 'SID_LOGONRESPONSE',
      def = {
        p:uint32("Client Token"),
        p:uint32("Server Token"),
        p:array("Password Hash", p.uint32, 5),
        p:stringz("Username"),
      },
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
    {
      id = 0x2A,
      name = 'SID_CREATEACCOUNT',
      def = {
        p:array("Hashed password", p.uint32, 5),
        p:stringz("Username"),
      },
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
    {
      id = 0x2B,
      name = 'SID_SYSTEMINFO',
      def = {
        p:uint32("Number of processors"),
        p:uint32("Processor architecture"),
        p:uint32("Processor level"),
        p:uint32("Processor timing"),
        p:uint32("Total physical memory"),
        p:uint32("Total page file"),
        p:uint32("Free disk space"),
      },
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
    {
      id = 0x2C,
      name = 'SID_GAMERESULT',
      def = {
        p:uint32("Game type", nil, {
          [0x00] = "Normal",
          [0x01] = "Ladder",
          [0x03] = "Ironman (W2BN only)",
        }),
        p:uint32{label="Number of results (always 8)", key="numresults"},
        p:iterator{label="Game results", refkey="numresults", repeated={
          p:uint32("Result", nil, {
            [0x01] = "Win",
            [0x02] = "Loss",
            [0x03] = "Draw",
            [0x04] = "Disconnect",
          }),
        }},
        p:iterator{label="Players", refkey="numresults", repeated={
          p:stringz("Player"),
        }},
        p:stringz("Map name"),
        p:stringz("Player score"),
      },
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
    {
      id = 0x2D,
      name = 'SID_GETICONDATA',
      def = {},
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
    {
      id = 0x2E,
      name = 'SID_GETLADDERDATA',
      def = {
        p:strdw("Product ID", p.descs.ClientTag),
        p:uint32("League"),
        p:uint32("Sort method", nil, {
          [0x00] = "Highest rating",
          [0x01] = "Fastest climbers",
          [0x02] = "Most wins on record",
          [0x03] = "Most games played",
        }),
        p:uint32("Starting rank"),
        p:uint32("Number of ranks to list"),
      },
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
    {
      id = 0x2F,
      name = 'SID_FINDLADDERUSER',
      def = {
        p:uint32("League"),
        p:uint32("Sort method", nil, {
          [0x00] = "Highest rating",
          [0x01] = "Unused",
          [0x02] = "Most wins on record",
          [0x03] = "Most games played",
        }),
        p:stringz("Username"),
      },
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
    {
      id = 0x30,
      name = 'SID_CDKEY',
      def = {
        p:uint32("Spawn"),
        p:stringz("CDKey"),
        p:stringz("Key Owner"),
      },
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
    {
      id = 0x31,
      name = 'SID_CHANGEPASSWORD',
      def = {
        p:uint32("Client Token"),
        p:uint32("Server Token"),
        p:array("Old hashed password", p.uint32, 5),
        p:array("New password hash", p.uint32, 5),
        p:stringz("Account name"),
      },
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
    {
      id = 0x32,
      name = 'SID_CHECKDATAFILE',
      def = {
        p:array("File checksum", p.uint32, 5),
        p:stringz("File name"),
      },
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
    {
      id = 0x33,
      name = 'SID_GETFILETIME',
      def = {
        p:uint32('Request ID', base.HEX),
        p:uint32('Unknown', base.HEX),
        p:stringz('Filename')
      }
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
    {
      id = 0x34,
      name = 'SID_QUERYREALMS',
      def = {
        p:uint32("Unused"),
        p:uint32("Unused"),
        p:stringz("Unknown"),
      },
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
    {
      id = 0x35,
      name = 'SID_PROFILE',
      def = {
        p:uint32("Cookie"),
        p:stringz("Username"),
      },
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
    {
      id = 0x36,
      name = 'SID_CDKEY2',
      def = {
        p:uint32("Spawn"),
        p:uint32("Key Length"),
        p:uint32("CDKey Product"),
        p:uint32("CDKey Value1"),
        p:uint32("Server Token"),
        p:uint32("Client Token"),
        p:array("Hashed Data", p.uint32, 5),
        p:stringz("Key owner"),
      },
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
    {
      id = 0x3A,
      name = 'SID_LOGONRESPONSE2',
      def = {
        p:uint32("Client Token", base.HEX),
        p:uint32("Server Token", base.HEX),
        p:array("Password Hash", p.uint32, 5),
        p:stringz("Username"),
      },
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
    {
      id = 0x3C,
      name = 'SID_CHECKDATAFILE2',
      def = {
        p:uint32("File size in bytes"),
        p:array("File hash", p.uint32, 5),
        p:stringz("Filename"),
      },
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
    {
      id = 0x3D,
      name = 'SID_CREATEACCOUNT2',
      def = {
        p:array("Password hash", p.uint32, 5),
        p:stringz("Username"),
      },
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
    {
      id = 0x3E,
      name = 'SID_LOGONREALMEX',
      def = {
        p:uint32("Client Token"),
        p:array("Hashed realm password", p.uint32, 5),
        p:stringz("Realm title"),
      },
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
    {
      id = 0x40,
      name = 'SID_QUERYREALMS2',
      def = {},
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
    {
      id = 0x41,
      name = 'SID_QUERYADURL',
      def = {
        p:uint32("Ad ID"),
      },
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
    --[[doc
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
    {
      id = 0x44,
      name = 'SID_WARCRAFTGENERAL',
      def =  {
        p:uint8{"Subcommand ID", key="subcommand", nil, p.descs.WarcraftGeneralSubcommandId},
        --[[doc
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
        ]]
        -- Subcommand ID 0: Game search?
        p:when{p.conditions.keyEquals("subcommand", 0), {
          p:uint32("Cookie"),
          p:uint32("Unknown"),
          p:uint8("Unknown"),
          p:uint8("Type", nil, {
            [0x00] = "1vs1",
            [0x01] = "2vs2",
            [0x02] = "3vs3",
            [0x03] = "4vs4",
            [0x04] = "Free for All",
          }),
          p:uint16("Enabled Maps (every bit is one map, from 0x0000 to 0x0FFF)"),
          p:uint16("Unknown"),
          p:uint8("Unknown"),
          p:uint32("TickCount"),
          p:flags{label="Race", of=p.uint32, fields={
            {"Human",     0x01, p.descs.YesNo},
            {"Orc",       0x02, p.descs.YesNo},
            {"Night Elf", 0x04, p.descs.YesNo},
            {"Undead",    0x08, p.descs.YesNo},
            {"Random",    0x20, p.descs.YesNo},
          }},
        }},

        -- Subcommand ID 2: Request ladder map listing
        p:when{p.conditions.keyEquals("subcommand", 2), {
          p:uint32("Cookie"),
          p:uint8{label="Number of types requested",key="num"},
          p:iterator{label="Game Information", refkey="num", repeated={
            p:strdw("Request data", p.descs.WarcraftGeneralRequestType),
            -- seems to be dword(0)
            -- seems this is another war3 datatype, double strdw :)
            p:uint32("Dword(0)"),
          }},
        }},

        -- Subcommand ID 3: WID_CANCELSEARCH
        p:when{p.conditions.keyEquals("subcommand", 3), {}},

        -- Subcommand ID 4: User stats request
        p:when{p.conditions.keyEquals("subcommand", 4), {
          p:uint32("Cookie"),
          p:stringz("Username"),
          p:strdw("Product ID", p.descs.ClientTag),
        }},

        -- Subcommand ID 7: WID_TOURNAMENT
        p:when{p.conditions.keyEquals("subcommand", 7), {
          p:uint32("Cookie"),
        }},

        -- Subcommand ID 8: Clan stats request
        p:when{p.conditions.keyEquals("subcommand", 8), {
          p:uint32("Cookie"),
          p:stringz("Account name"),
          -- TODO: "' in strings?
          p:strdw("Product ID (WAR3 or W3XP)", p.descs.ClientTag),
        }},

        -- Subcommand ID 9: Icon list request
        p:when{p.conditions.keyEquals("subcommand", 9), {
          p:uint32("Cookie"),
        }},

        -- Subcommand ID 10: Change icon
        p:when{p.conditions.keyEquals("subcommand", 0x0A), {
          p:strdw("Icon", p.descs.W3Icon),
        }},
      },
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
    {
      id = 0x45,
      name = 'SID_NETGAMEPORT',
      def = {
        p:uint16("Port"),
      },
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
    {
      id = 0x46,
      name = 'SID_NEWS_INFO',
      def = {
        p:posixtime('News timestamp'),
      },
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
    {
      id = 0x4B,
      name = 'SID_EXTRAWORK',
      def = {
        p:uint16("Game type"),
        p:uint16("Length"),
        p:stringz("Work returned data"),
      },
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
    {
      id = 0x50,
      name = 'SID_AUTH_INFO',
      def = {
        p:uint32('Protoco ID'),
        p:strdw('Plaform ID', p.descs.PlatformID),
        p:strdw('Product ID', p.descs.ClientTag),
        p:uint32('Version Byte', base.HEX),
        p:strdw('Product Language', p.descs.LangId),
        p:ipv4('Local IP for NAT compatibility'),
        p:int32('Time zone bias', nil, p.descs.TimeZoneBias),
        p:uint32('Locale ID', nil, p.descs.LocaleID),
        p:uint32('Language ID', nil, p.descs.LocaleID),
        p:stringz('Country abbreviation'),
        p:stringz('Country'),
      },
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
    {
      id = 0x51,
      name = 'SID_AUTH_CHECK',
      def = {
        p:uint32('Client Token', base.HEX),
        p:version('EXE Version'),
        p:uint32('EXE Hash', base.HEX),
        p:uint32 {
          'Number of CD-keys',
          key = 'cdkeys',
        },
        p:uint32('Spawn CD-Key', nil, p.descs.YesNo),
        p:iterator('CD-Key', 'cdkeys', {
          p:uint32('Key Length'),
          p:uint32('CD-Key\'s product value', base.HEX, {
            [0x01] = 'STAR',
            [0x02] = 'STAR',
            [0x17] = 'STAR (26-character)',
            [0x06] = 'D2DV',
            [0x18] = 'D2DV (26-character)',
            [0x0A] = 'D2XP',
            [0x19] = 'D2XP (26-character)',
            [0x04] = 'W2BN',
            [0x0E] = 'WAR3',
            [0x12] = 'W3XP',
          }),
          p:uint32('CD-Key\'s public value', base.HEX),
          p:uint32('Unknown (0)'),
          p:bytes('Hashed Key Data', 20)
        }),
        p:stringz('Exe Information'),
        p:stringz('CD-Key owner name'),
      },
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
    {
      id = 0x52,
      name = 'SID_AUTH_ACCOUNTCREATE',
      def = {
        p:bytes('Salt', 32),
        p:array('Verifier', p.uint8, 32),
        p:stringz('Username'),
      },
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
    {
      id = 0x53,
      name = 'SID_AUTH_ACCOUNTLOGON',
      def = {
        p:array("Client Key", p.uint8, 32),
        p:stringz("Username"),
      },
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
    {
      id = 0x54,
      name = 'SID_AUTH_ACCOUNTLOGONPROOF',
      def = {
        p:array("Client Password Proof", p.uint8, 20),
      },
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
    {
      id = 0x55,
      name = 'SID_AUTH_ACCOUNTCHANGE',
      def = {
        p:array("Client key", p.uint8, 32),
        p:stringz("Username"),
      },
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
    {
      id = 0x56,
      name = 'SID_AUTH_ACCOUNTCHANGEPROOF',
      def = {
        p:array("Old password proof", p.uint8, 20),
        p:array("New password's salt", p.uint8, 32),
        p:array("New password's verifier", p.uint8, 32),
      },
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
    {
      id = 0x57,
      name = 'SID_AUTH_ACCOUNTUPGRADE',
      def = {},
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
    {
      id = 0x58,
      name = 'SID_AUTH_ACCOUNTUPGRADEPROOF',
      def = {
        p:uint32("Client Token"),
        p:array("Old Password Hash", p.uint32, 5),
        p:array("New Password Salt", p.uint8, 32),
        p:array("New Password Verifier", p.uint8, 32),
      },
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
    {
      id = 0x59,
      name = 'SID_SETEMAIL',
      def = {
        p:stringz("Email Address"),
      },
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
    {
      id = 0x5A,
      name = 'SID_RESETPASSWORD',
      def = {
        p:stringz("Account Name"),
        p:stringz("Email Address"),
      },
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
    {
      id = 0x5B,
      name = 'SID_CHANGEEMAIL',
      def = {
        p:stringz("Account Name"),
        p:stringz("Old Email Address"),
        p:stringz("New Email Address"),
      },
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
    {
      id = 0x5C,
      name = 'SID_SWITCHPRODUCT',
      def = {
        p:strdw("Product ID", p.descs.ClientTag),
      },
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
    {
      id = 0x5D,
      name = 'SID_REPORTCRASH',
      def = {
        p:uint32("0x10A0027"),
        p:uint32("Exception code"),
        p:uint32("Unknown"),
        p:uint32("Unknown"),
      },
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
                      (BYTE) Success (0x00 = Don't have the module, 0x01 = Have the module)
                      
              0x01 - Warden Module Data
                      (BYTE) Success (0x00 = MD5 doesn't match, 0x01 = MD5 matches)
                      
              0x02 - Data Checker
                      (WORD) String Length
              (DWORD) String Checksum
              (VOID) String Data

                      MEM_CHECK:

                      (BYTE) Success (0x00 = Read data, 0x01 = Unable to read)

                      (VOID) Data (0x00 only)
                      PAGE_CHECK_A:

                      (BYTE) Success (0x00 = SHA1s match, 0x01 = SHA1s don't match)

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
    {
      id = 0x5E,
      name = 'SID_WARDEN',
      def = {
        p:consume("plen", "Encrypted Packet", "warden_encrypted_packet"),
      },
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
    {
      id = 0x60,
      name = 'SID_GAMEPLAYERSEARCH',
      def = {},
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
    {
      id = 0x65,
      name = 'SID_FRIENDSLIST',
      def = {},
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
    {
      id = 0x66,
      name = 'SID_FRIENDSUPDATE',
      def = {
        p:uint8("Friends list index"),
      },
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
    {
      id = 0x70,
      name = 'SID_CLANFINDCANDIDATES',
      def = {
        p:uint32("Cookie"),
        p:strdw("Clan Tag"),
      },
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
    {
      id = 0x71,
      name = 'SID_CLANINVITEMULTIPLE',
      def = {
        p:uint32("Cookie"),
        p:stringz("Clan name"),
        p:strdw("Clan tag"),
        p:uint8{"Number of users to invite", key="numusers"},
        p:iterator{label="Usernames to invite", refkey="numusers", repeated={
          p:stringz("Account"),
        }},
      },
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
    {
      id = 0x72,
      name = 'SID_CLANCREATIONINVITATION',
      def = {
        p:uint32("Cookie"),
        p:strdw("Clan tag"),
        p:stringz("Inviter name"),
        p:uint8("Status"),
      },
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
    {
      id = 0x73,
      name = 'SID_CLANDISBAND',
      def = {
        p:uint32("Cookie"),
      },
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
    {
      id = 0x74,
      name = 'SID_CLANMAKECHIEFTAIN',
      def = {
        p:uint32("Cookie"),
        p:stringz("New Cheiftain"),
      },
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
    {
      id = 0x77,
      name = 'SID_CLANINVITATION',
      def = {
        p:uint32("Cookie"),
        p:stringz("Target User"),
      },
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
    {
      id = 0x78,
      name = 'SID_CLANREMOVEMEMBER',
      def = {
        p:uint32("Cookie"),
        p:stringz("Username"),
      },
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
    {
      id = 0x79,
      name = 'SID_CLANINVITATIONRESPONSE',
        p:uint32("Cookie"),
        p:strdw("Clan tag"),
        p:stringz("Inviter"),
        p:uint8("Response", nil, {
          [0x04] = 'Decline',
          [0x06] = 'Accept',
        }),
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

                      0x01: Initiate that has been in the clan for over one week
                      0x02: Member
                      0x03: Officer

        Related:       [0x74] SID_CLANMAKECHIEFTAIN (C->S), [0x7A] SID_CLANRANKCHANGE (S->C)

    ]]
    {
      id = 0x7A,
      name = 'SID_CLANRANKCHANGE',
      def = {
        p:uint32("Cookie"),
        p:stringz("Username"),
        p:uint8("New rank", nil, {
          [0x01] = 'Initiate',
          [0x02] = 'Member',
          [0x03] = 'Officer',
        }),
      },
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
    {
      id = 0x7B,
      name = 'SID_CLANSETMOTD',
      def = {
        p:uint32("Cookie"),
        p:stringz("MOTD"),
      },
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
    {
      id = 0x7C,
      name = 'SID_CLANMOTD',
      def = {
        p:uint32("Cookie"),
      },
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
    {
      id = 0x7D,
      name = 'SID_CLANMEMBERLIST',
      def = {
        p:uint32("Cookie"),
      },
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
    {
      id = 0x82,
      name = 'SID_CLANMEMBERINFORMATION',
      def = {
        p:uint32("Cookie"),
        p:strdw("User's clan tag"),
        p:stringz("Username"),
      },
    },
  }
}

p:collection {
  name = 'server_packets',
  packets = {
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
    {
      id = 0x00,
      name = 'SID_NULL',
      def = {}
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
    {
      id = 0x04,
      name = 'SID_SERVERLIST',
      def = {
        p:uint32("Server version"),
        p:iterator{
          label="Server list",
           alias="bytes",
           condition = p.conditions.neg(p.conditions.keyEquals("srvr", "")),
           repeated = {
             p:stringz{"Server", key="srvr"},
           },
         },
      },
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
    {
      id = 0x05,
      name = 'SID_CLIENTID',
      def = {
        p:uint32("Registration Version", base.HEX),
        p:uint32("Registration Authority", base.HEX),
        p:uint32("Account Number", base.HEX),
        p:uint32("Registration Token", base.HEX),
      },
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
    {
      id = 0x06,
      name = 'SID_STARTVERSIONING',
      def = {
        p:wintime("MPQ Filetime"),
        p:stringz("MPQ Filename"),
        p:stringz("ValueString"),
      },
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
    {
      id = 0x07,
      name = 'SID_REPORTVERSION',
      def = {
        p:uint32("Result", nil, {
          [0x00] = "Failed version check",
          [0x01] = "Old game version",
          [0x02] = "Success",
          [0x03] = "Reinstall required",
        }),
        p:stringz("Patch path"),
      },
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
    {
      id = 0x08,
      name = 'SID_STARTADVEX',
      def = {
        p:uint32("Status", nil, {
          [0x00] = "Failed",
          [0x01] = "Success",
        }),
      },
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
    {
      id = 0x09,
      name = 'SID_GETADVLISTEX',
      def = {
        p:uint32 { 'Number of games', key = 'games' },
        p:when(
          p.conditions.keyEquals('games', 0),
          {
            p:uint32('Status', nil, p.descs.GameStatus)
          },
          {
            p:iterator('Game Information', 'games', {
              -- Test for PvPGN (0, 1) or Battle.net (>= 2)
              -- Using a protofield_type of 'none' will not add
              -- a tree node but will capture the value in the
              -- given key.
              p:uint16 { key = 'pvpgnTest', protofield_type = 'none' },
              p:when(p.conditions.keyIn('pvpgnTest', { 0, 1 }), {
                p:uint32('Unknown (PvPGN)')
              }),
              p:uint16 { 'Game Type', nil, {
                [0x02] = 'Melee',
                [0x03] = 'Free for all',
                [0x04] = 'one vs one',
                [0x05] = 'CTF',
                [0x06] = 'Greed',
                [0x07] = 'Slaughter',
                [0x08] = 'Sudden Death',
                [0x09] = 'Ladder',
                [0x0A] = 'Use Map Settings',
                [0x0B] = 'Team Melee',
                [0x0C] = 'Team FFA',
                [0x0D] = 'Team CTF',
                [0x0F] = 'Top vs Bottom',
                [0x10] = 'Iron man ladder',
              }, key = 'gametype' },
              p:casewhen {
                {
                  -- melee / ffa / 1 on 1 / CTF / suddenDeath
                  p.conditions.keyIn('gametype', { 2, 3, 4, 5, 8 }),
                  {
                    p:uint16('Penalty', nil, {
                      [1] = 'Melee Disc',
                      [2] = 'Loss'
                    })
                  }
                },
                -- greed
                {
                  p.conditions.keyEquals('gametype', 6),
                  {
                    p:uint16('Resources', nil, {
                      [1] = 2500,
                      [2] = 5000,
                      [3] = 7500,
                      [4] = 10000
                    })
                  }
                },
                -- slaughter
                {
                  p.conditions.keyEquals('gametype', 7),
                  {
                    p:uint16('Minutes', nil, {
                      [1] = 15,
                      [2] = 30,
                      [3] = 45,
                      [4] = 60
                    })
                  }
                },
                {
                  -- ladder
                  p.conditions.keyEquals('gametype', 9),
                  {
                    p:uint16('Penalty', nil, {
                      [1] = 'Ladder Disc',
                      [2] = 'Ladder Loss + Disc'
                    })
                  }
                },
                -- ums
                {
                  p.conditions.keyEquals('gametype', 0xA),
                  {
                    p:uint16('Penalty', nil, {
                      [1] = 'Draw',
                      [2] = 'Draw',
                    })
                  }
                },
                -- Team melee / team FFA / team CTF
                {
                  p.conditions.keyIn('gametype', { 0xB, 0xC, 0xD }),
                  {
                    p:uint16('Teams', nil, {
                      [1] = 2,
                      [2] = 3,
                      [3] = 4
                    })
                  }
                },
                -- Top vs Bottom
                {
                  p.conditions.keyEquals('gametype', 0xF),
                  {
                    p:uint16('Teams', nil, {
                      [1] = '1 vs all',
                      [2] = '2 vs all',
                      [3] = '3 vs all',
                      [4] = '4 vs all',
                      [5] = '5 vs all',
                      [6] = '6 vs all',
                      [7] = '7 vs all',
                    })
                  }
                },
                -- default block
                {
                  p.conditions.always(),
                  {
                    p:uint16('Parameter', base.HEX)
                  }
                }
              },
              p:when(p.conditions.neg(p.conditions.keyIn('pvpgnTest', { 0, 1 })), {
                p:uint32('Language ID', nil, p.descs.LocaleID)
              }),
              p:sockaddr('Game Host'),
              p:uint32('Status', nil, p.descs.GameStatus),
              p:uint32('Elapsed time (seconds)'),
              p:stringz('Game name'),
              p:stringz('Game password'),
              p:stringz('Game statstring')
            })
          })
      }
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
    {
      id = 0x0A,
      name = 'SID_ENTERCHAT',
      def = {
        p:stringz("Unique name"),
        p:stringz("Statstring"),
        p:stringz("Account name"),
      },
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
    {
      id = 0x0B,
      name = 'SID_GETCHANNELLIST',
      def = {
        p:iterator{
          protofield_type = "none",
          condition = p.conditions.neg(p.conditions.keyEquals("chan", "")),
          repeated = {
            p:stringz{"Channel name", key="chan"},
          }
        }
      },
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
    {
      id = 0x0F,
      name = 'SID_CHATEVENT',
      def = {
        p:uint32{"Event ID", key="eid", filter="eid", nil, {
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
        p:casewhen{
          {
            p.conditions.keyEquals("eid", 7),
            { -- Channel information
              p:flags{of = p.uint32, label = "Channel Flags", fields = {
                {"Public Channel",              0x00001, p.descs.YesNo},
                {"Moderated",                   0x00002, p.descs.YesNo},
                {"Restricted",                  0x00004, p.descs.YesNo},
                {"Silent",                      0x00008, p.descs.YesNo},
                {"System",                      0x00010, p.descs.YesNo},
                {"Product-Specific",            0x00020, p.descs.YesNo},
                {"Globally Accessible",         0x01000, p.descs.YesNo},
                {"Redirected",                  0x04000, p.descs.YesNo},
                {"Chat",                        0x08000, p.descs.YesNo},
                {"Tech Support",                0x10000, p.descs.YesNo},
              }},
            },
          },
          {
            p.conditions.always(),
            {  -- Otherwise
              p:flags{of = p.uint32, label = "User's Flags", fields = {
                {"Blizzard Representative",     0x00000001, p.descs.YesNo},
                {"Channel Operator",            0x00000002, p.descs.YesNo},
                {"Speaker",                     0x00000004, p.descs.YesNo},
                {"Battle.net Administrator",    0x00000008, p.descs.YesNo},
                {"No UDP Support",              0x00000010, p.descs.YesNo},
                {"Squelched",                   0x00000020, p.descs.YesNo},
                {"Special Guest",               0x00000040, p.descs.YesNo},
                {"Unknown",                     0x00000080, p.descs.YesNo},
                {"Beep Enabled (Defunct)",      0x00000100, p.descs.YesNo},
                {"PGL Player (Defunct)",        0x00000200, p.descs.YesNo},
                {"PGL Official (Defunct)",      0x00000400, p.descs.YesNo},
                {"KBK Player (Defunct)",        0x00000800, p.descs.YesNo},
                {"WCG Official",                0x00001000, p.descs.YesNo},
                {"KBK Singles (Defunct)",       0x00002000, p.descs.YesNo},
                {"KBK Player (Defunct)",        0x00002000, p.descs.YesNo},
                {"KBK Beginner (Defunct)",      0x00010000, p.descs.YesNo},
                {"White KBK (1 bar) (Defunct)", 0x00020000, p.descs.YesNo},
                {"GF Official",                 0x00100000, p.descs.YesNo},
                {"GF Player",                   0x00200000, p.descs.YesNo},
                {"PGL Player",                  0x02000000, p.descs.YesNo},
              }},
            },
          },
        },
        p:uint32("Ping"),
        p:ipv4("IP Address (Defunct)"),
        p:uint32("Account number (Defunct)", base.HEX),
        p:uint32("Registration Authority (Defunct)", base.HEX),
        p:stringz("Username"),
        -- statstring: 1,2,9,
        -- empty: 3,
        -- text: 5,18
        -- channel name: 7
        p:casewhen{
          {
            p.conditions.keyIn("eid", {1,2,9}),
            {
              p:stringz("Statstring"),
            }
          },
          {
            p.conditions.keyEquals("eid", 7),
            {
              p:stringz("Channel name"),
            },
          },
          {
            p.conditions.always(),
            {
              p:stringz("Text"),
            },
          },
        },
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
    {
      id = 0x13,
      name = 'SID_FLOODDETECTED',
      def = {},
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
    {
      id = 0x15,
      name = 'SID_CHECKAD',
      def = {
        p:uint32("Ad ID", base.HEX),
        p:stringz{"File extension", length = 4},
        p:wintime("Local file time"),
        p:stringz("Filename"),
        p:stringz("Link URL"),
      },
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
    {
      id = 0x17,
      name = 'SID_READMEMORY',
      def = {
        p:uint32("Request ID"),
        p:uint32("Address", base.HEX),
        p:uint32("Length"),
      },
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
    {
      id = 0x18,
      name = 'SID_REGISTRY',
      def = {
        p:uint32("Cookie"),
        p:uint32("HKEY", base.HEX, {
          [0x80000000] = "HKEY_CLASSES_ROOT",
          [0x80000001] = "HKEY_CURRENT_USER",
          [0x80000002] = "HKEY_LOCAL_MACHINE",
          [0x80000003] = "HKEY_USERS",
          [0x80000004] = "HKEY_PERFORMANCE_DATA",
          [0x80000005] = "HKEY_CURRENT_CONFIG",
          [0x80000006] = "HKEY_DYN_DATA",
        }),
        p:stringz("Registry path"),
        p:stringz("Registry key"),
      },
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
    {
      id = 0x19,
      name = 'SID_MESSAGEBOX',
      def = {
        p:uint32("Style"),
        p:stringz("Text"),
        p:stringz("Caption"),
      },
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
    {
      id = 0x1C,
      name = 'SID_STARTADVEX3',
      def = {
        p:uint32("Status", nil, {
          [0x00] = "Ok",
          [0x01] = "Failed"
        }),
      },
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
    {
      id = 0x1D,
      name = 'SID_LOGONCHALLENGEEX',
      def = {
        p:uint32("UDP Token", base.HEX),
        p:uint32("Server Token", base.HEX),
      },
    },
    --[[doc
        Message ID:    0x20

        Message Name:  SID_ANNOUNCEMENT

        Direction:     Server -> Client (Received)

        Format:        (STRING) Text

        Purpose:       Very simply prints out text with the string at 1903B9FBh (the default string, used anyway if the username field is NULL in the chat event struct -- currently a single 0x7F char) as the username. Used to send announcements and arbitrary messages to the user, but this was soon superseded by SID_CHAT subcommands such as EID_INFO, EID_ERROR, and EID_BROADCAST. Printed out with the same color and style as an EID_BROADCAST.
    ]]
    {
      id = 0x20,
      name = 'SID_ANNOUNCEMENT',
      def = {
        p:stringz("Text"),
      },
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
    {
      id = 0x23,
      name = 'SID_WRITECOOKIE',
      def = {
        p:uint32("Flags, Request ID?"),
        p:uint32("Timestamp?"),
        p:stringz("Registry key name"),
        p:stringz("Registry key value"),
      },
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
    {
      id = 0x24,
      name = 'SID_READCOOKIE',
      def = {
        p:uint32("Request ID?"),
        p:uint32("Timestamp?"),
        p:stringz("Registry key name"),
      },
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
    {
      id = 0x25,
      name = 'SID_PING',
      def = {
        p:uint32("Ping Value", base.HEX),
      },
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
    {
      id = 0x26,
      name = 'SID_READUSERDATA',
      def = {
        p:uint32{"Number of accounts", key="numaccts"},
        p:uint32{"Number of keys", key="numkeys"},
        p:uint32("Request ID"),
        p:iterator{label="Requested Account", refkey="numaccts", repeated={
          p:iterator{protofield_type="none", label="Key Values", refkey="numkeys", repeated={
            p:stringz("Requested Key Value"),
          }},
        }},
      },
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
    {
      id = 0x28,
      name = 'SID_LOGONCHALLENGE',
      def = {
        p:uint32("Server Token", base.HEX),
      },
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
    {
      id = 0x29,
      name = 'SID_LOGONRESPONSE',
      def = {
        p:uint32("Result", nil, {
          [0x00] = "Invalid password",
          [0x01] = "Success",
        }),
      },
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
    {
      id = 0x2A,
      name = 'SID_CREATEACCOUNT',
      def = {
        p:uint32("Result", nil, {
          [0x00] = "Failed",
          [0x01] = "Success",
        }),
      },
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
    {
      id = 0x2D,
      name = 'SID_GETICONDATA',
      def = {
        p:wintime("Filetime"),
        p:stringz("Filename"),
      },
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
    {
      id = 0x2E,
      name = 'SID_GETLADDERDATA',
      def = {
        p:uint32("Ladder type", base.HEX),
        p:uint32("League", base.HEX),
        p:uint32("Sort method", nil, {
          [0x00] = "Highest rating",
          [0x01] = "Fastest climbers",
          [0x02] = "Most wins on record",
          [0x03] = "Most games played",
        }),
        p:uint32("Starting rank", base.HEX),
        p:uint32{"Number of ranks listed", key="ranks"},
        p:iterator{label="Rank", refkey="ranks", repeated={
          p:uint32("Wins"),
          p:uint32("Losses"),
          p:uint32("Disconnects"),
          p:uint32("Rating"),
          p:uint32("Rank"),
          p:uint32("Official wins"),
          p:uint32("Official losses"),
          p:uint32("Official disconnects"),
          p:uint32("Official rating"),
          p:uint32("Unknown", base.HEX),
          p:uint32("Official rank"),
          p:uint32("Unknown", base.HEX),
          p:uint32("Unknown", base.HEX),
          p:uint32("Highest rating"),
          p:uint32("Unknown", base.HEX),
          p:uint32("Season"),
          p:wintime("Last game time"),
          p:wintime("Official last game time"),
          p:stringz("Name"),
        }},
      },
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
    {
      id = 0x2F,
      name = 'SID_FINDLADDERUSER',
      def = {
        p:uint32("Rank. Zero-based. 0xFFFFFFFF == Not ranked"),
      },
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
    {
      id = 0x30,
      name = 'SID_CDKEY',
      def = {
        p:uint32("Result", nil, {
          [0x01] = "Ok",
          [0x02] = "Invalid key",
          [0x03] = "Bad product",
          [0x04] = "Banned",
          [0x05] = "In use",
        }),
        p:stringz("Key owner"),
      },
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
    {
      id = 0x31,
      name = 'SID_CHANGEPASSWORD',
      def = {
        p:uint32("Password change succeeded", nil, p.descs.YesNo),
      },
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
    {
      id = 0x32,
      name = 'SID_CHECKDATAFILE',
      def = {
        p:uint32("Status", nil, {
          [0x00] = "Rejected",
          [0x01] = "Approved",
          [0x02] = "Ladder approved",
        }),
      },
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
    {
      id = 0x33,
      name = 'SID_GETFILETIME',
      def = {
        p:uint32('Request ID'),
        p:uint32('Unknown'),
        p:wintime('Last update time'),
        p:stringz('Filename')
      }
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
    {
      id = 0x34,
      name = 'SID_QUERYREALMS',
      def = {
        p:uint32("Unknown", base.HEX),
        p:uint32{"Count", key="realms"},
        p:iterator{label="Realm", refkey="realms", repeated={
          p:uint32("Unknown", base.HEX),
          p:stringz("Realm title"),
          p:stringz("Realm description"),
        }},
      },
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
    {
      id = 0x35,
      name = 'SID_PROFILE',
      def = {
        p:uint32("Cookie"),
        p:uint8{"Success", nil, p.descs.YesNo, key="status"},
        p:when{p.conditions.keyEquals("status", 0), {
          p:stringz("Profile\\Description value"),
          p:stringz("Profile\\Location value"),
          p:strdw("Clan Tag"),
        }},
      },
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
    {
      id = 0x36,
      name = 'SID_CDKEY2',
      def = {
        p:uint32("Result", nil, {
          [0x01] = "Ok",
          [0x02] = "Invalid key",
          [0x03] = "Bad product",
          [0x04] = "Banned",
          [0x05] = "In use",
        }),
        p:stringz("Key owner"),
      },
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
    {
      id = 0x3A,
      name = 'SID_LOGONRESPONSE2',
      def = {
        p:uint32{"Result", nil, {
          [0x00] = "Success",
          [0x01] = "Account Does Not Exist",
          [0x02] = "Invalid Password",
          [0x06] = "Account Closed",
        }, key="res"},
        p:when{p.conditions.keyEquals("res", 6), {
          p:stringz("Reason"),
        }},
      },
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
    {
      id = 0x3C,
      name = 'SID_CHECKDATAFILE2',
      def = {
        p:uint32("Result", nil, {
          [0x00] = "Not approved",
          [0x01] = "Blizzard approved",
          [0x02] = "Approved for ladder",
        }),
      },
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
    {
      id = 0x3D,
      name = 'SID_CREATEACCOUNT2',
      def = {
        p:uint32("Status", nil, {
          [0x00] = "Account created",
          [0x02] = "Name contained invalid characters",
          [0x03] = "Name contained a banned word",
          [0x04] = "Account already exists",
          [0x06] = "Name did not contain enough alphanumeric characters",
        }),
        -- TODO under what conditions the name suggestion is given?
        -- stringz("Account name suggestion"),
      },
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
    {
      id = 0x3E,
      name = 'SID_LOGONREALMEX',
      def = {
        p:uint32("MCP Cookie"),
        p:uint32{"MCP Status", key="status"},
        p:when{p.conditions.keyEquals("status", 0), {
          p:array("MCP Chunk 1", p.uint32, 2),
          p:ipv4("IP"),
          p:uint16{"Port", big_endian=true},
          p:array("Padding", p.uint8, 2),
          p:array("MCP Chunk 2", p.uint32, 12),
          p:stringz("Battle.net unique name"),
        }},
      },
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
    {
      id = 0x3F,
      name = 'SID_STARTVERSIONING2',
      def = {
        p:wintime("MPQ Filetime"),
        p:stringz("MPQ Filename"),
        p:stringz("ValueString"),
      },
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
    {
      id = 0x40,
      name = 'SID_QUERYREALMS2',
      def = {
        p:uint32("Unknown", base.HEX),
        p:uint32{"Count", key="realms"},
        p:iterator{label="Realm", refkey="realms", repeated={
          p:uint32("Unknown", base.HEX),
          p:stringz("Realm title"),
          p:stringz("Realm description"),
        }},
      },
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
    {
      id = 0x41,
      name = 'SID_QUERYADURL',
      def = {
        p:uint32("Ad ID"),
        p:stringz("Ad URL"),
      },
    },
    --[[doc
        Message ID:    0x43

        Message Name:  SID_WARCRAFTSOMETHING

        Direction:     Server -> Client (Received)

        Format:        (DWORD) Unknown (0)
      
        Purpose:       Unknown. I am unable to disassemble Warcraft 3's game.dll without a lot of trouble, and therefore I have limited knowledge of it. It has been seen once, after SID_LOGONPROOF (0x54) in the NLS logon sequence.
      
      source: http://darkblizz.org/Forum2/starcraft/the-lost-packets/msg19580
    ]]
    {
      id = 0x43,
      name = 'SID_WARCRAFTSOMETHING',
      def = {
        p:uint32("Unknown (0)"),
      },
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
    {
      id = 0x44,
      name = 'SID_WARCRAFTGENERAL',
      def = {
        p:uint8{"Subcommand ID", key="subcommand", filter="wid", nil, p.descs.WarcraftGeneralSubcommandId},
        --[[doc
          WID_GAMESEARCH 0x00 RECV
          (DWORD) Cookie
          (BYTE) Status
            0x00: Search Started
            0x04: Banned CD Key
        ]]
        -- Subcommand ID 0: Game search?
        p:when{p.conditions.keyEquals("subcommand", 0), {
          p:uint32("Cookie"),
          p:uint8("Status", nil, {
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
        p:when{p.conditions.keyEquals("subcommand", 2), {
          p:uint32("Cookie"),
          p:uint8("Responses"),
          p:strdw("ID", p.descs.WarcraftGeneralRequestType),
          p:uint32("Checksum", base.HEX),
          p:uint16("Decompressed Len"),
          p:uint16("Compressed Len"),
          -- TODO: length as refkey
          -- array("Compressed Data", uint8,
          p:consume('plen', "Remaining Packet Data"),
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
        p:when{p.conditions.keyEquals("subcommand", 4), {
          p:uint32("Cookie"),
          p:strdw("Icon ID", p.descs.W3IconNames),
          p:uint8{"Number of ladder records", key="ladders"},
          p:iterator{label="Ladder Record", refkey="ladders", repeated={
            p:strdw("Ladder type", p.descs.W3LadderType),
            p:uint16("Number of wins"),
            p:uint16("Number of losses"),
            p:uint8("Level"),
            p:uint8("Hours until XP decay"),
            p:uint16("Experience"),
            p:uint32("Rank"),
          }},
          p:uint8{"Number of race records", key="races"},
          p:iterator{label="Race Record", refkey="races", repeated={
            p:uint16("Wins"),
            p:uint16("Losses"),
          }},
          p:uint8{"Number of team records", key="teams"},
          p:iterator{label="Team Record", refkey="teams", repeated={
            p:strdw("Type of team", p.descs.W3TeamType),
            p:uint16("Number of wins"),
            p:uint16("Number of losses"),
            p:uint8("Level"),
            p:uint8("Hours until XP decay"),
            p:uint16("Experience"),
            p:uint32("Rank"),
            p:wintime("Time of last game played"),
            p:uint8{"Number of partners", key="partners"},
            p:iterator{label="Partners", refkey="partners", repeated={
              p:stringz("Names of partners"),
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
        p:when{p.conditions.keyEquals("subcommand", 7), {
          p:uint32("Cookie"),
          p:uint8("Status", nil, {
            [0x00] = "No Tournament",
            [0x01] = "Starting Soon",
            [0x02] = "Ending Soon",
            [0x03] = "Started",
            [0x04] = "Last Call",
          }),
          p:wintime("Time of Status"),
          p:uint16("Unknown"),
          p:uint16("Unknown"),
          p:uint8("Wins"),
          p:uint8("Losses"),
          p:uint8("Draws"),
          p:uint8("Unknown"),
          p:uint8("Unknown"),
          p:uint8("Unknown"),
          p:uint8("Unknown"),
        }},
        -- Subcommand ID 8: Clan stats request
        p:when{p.conditions.keyEquals("subcommand", 8), {
          p:uint32("Cookie"),
          p:uint8{"Number of ladder records", key="ladders"},
          p:iterator{label="Ladder Record", refkey="ladders", repeated={
            p:strdw("Ladder type", p.descs.W3LadderType),
            p:uint16("Number of wins"),
            p:uint16("Number of losses"),
            p:uint8("Level"),
            p:uint8("Hours until XP decay"),
            p:uint16("Experience"),
            p:uint32("Rank"),
          }},
          p:uint8{"Number of race records", key="races"},
          p:iterator{label="Race Record", refkey="races", repeated={
            p:uint16("Wins"),
            p:uint16("Losses"),
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
        p:when{
          p.conditions.keyEquals("subcommand", 9),
          {
            p:uint32("Cookie"),
            p:uint32("Unknown", base.HEX),
            p:uint8("Tiers"),
            p:uint8{"Number of Icons", key="icons"},
            p:iterator{label="Icon", refkey="icons", repeated={
              p:strdw("Icon", p.descs.W3Icon),
              p:strdw("Name", p.descs.W3IconNames),
              p:uint8("Race", nil, p.descs.W3Races),
              p:uint16("Wins required"),
              p:uint8("Unknown", base.HEX),
            }},
          },
        },
      },
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
    {
      id = 0x46,
      name = 'SID_NEWS_INFO',
      def = {
        p:uint8 { "Number of entries", key = "nentries" },
        p:posixtime { "Last logon" },
        p:posixtime { "Oldest news" },
        p:posixtime { "Latest news" },
        p:iterator("News List", "nentries", {
          p:posixtime { "Timestamp", key = "stamp" },
          p:when{
            p.conditions.keyEquals("stamp", 0),
            {
              p:stringz("MOTD"),
            },
            {
              p:stringz("News"),
            },
          },
        })
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
    {
      id = 0x4A,
      name = 'SID_OPTIONALWORK',
      def = {
        p:stringz("MPQ Filename"),
      },
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
    {
      id = 0x4C,
      name = 'SID_REQUIREDWORK',
      def = {
        p:stringz("ExtraWork MPQ FileName"),
      },
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
    {
      id = 0x4E,
      name = 'SID_TOURNAMENT',
      def = {
        p:uint8("Unknown", base.HEX),
        p:uint8("Unknown, maybe number of non-null strings sent?", base.HEX),
        p:stringz("Description"),
        p:stringz("Unknown"),
        p:stringz("Website"),
        p:uint32("Unknown", base.HEX),
        p:stringz("Name"),
        p:stringz("Unknown"),
        p:stringz("Unknown"),
        p:stringz("Unknown"),
        p:array("Unknown", p.uint32, 5),
      },
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
    {
      id = 0x50,
      name = 'SID_AUTH_INFO',
      def = {
        p:uint32 { "Logon type", base.HEX, {
          [0x00] = "Broken SHA-1 (STAR/SEXP/D2DV/D2XP)",
          [0x01] = "NLS Version 1 (WAR3Beta/STAR/SEXP/D2DV/D2XP)",
          [0x02] = "NLS Version 2 (WAR3/W3XP)"
        }, key = "logontype" },
        p:uint32("Server token", base.HEX),
        p:uint32("UDP value", base.HEX),
        p:wintime("CheckRevision MPQ filetime"),
        p:stringz("CheckRevision MPQ filename"),
        p:stringz("CheckRevision Formula"),
        p:when(p.conditions.keyEquals("logontype", 2), {
          p:bytes("Server signature", 128)
        })
      }
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
    {
      id = 0x51,
      name = 'SID_AUTH_CHECK',
      def = {
        p:uint32{"Result", base.HEX, {
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
        }, key = "res"},
        p:casewhen{
          {
            p.conditions.keyIn("res", { 0x100, 0x102 }),
            {
              p:stringz("MPQ Filename"),
            },
          },
          {
            p.conditions.keyIn("res", { 0x201, 0x211 }),
            {
              p:stringz("Username"),
            },
          },
          {
            p.conditions.always(),
            {
              p:stringz("Additional Information"),
            },
          },
        },
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
    {
      id = 0x52,
      name = 'SID_AUTH_ACCOUNTCREATE',
      def = {
        p:uint32("Status", base.HEX, {
          [0x00] = "Successfully created account name",
          [0x04] = "Name already exists",
          [0x07] = "Name is too short/blank",
          [0x08] = "Name contains an illegal character",
          [0x09] = "Name contains an illegal word",
          [0x0a] = "Name contains too few alphanumeric characters",
          [0x0b] = "Name contains adjacent punctuation characters",
          [0x0c] = "Name contains too many punctuation characters"
        }),
      },
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
    {
      id = 0x53,
      name = 'SID_AUTH_ACCOUNTLOGON',
      def = {
        p:uint32("Status", nil, {
          [0x00] = "Logon accepted, requires proof",
          [0x01] = "Account doesn't exist",
          [0x05] = "Account requires upgrade",
        }),
        p:array("Salt", p.uint8, 32),
        p:array("Server Key", p.uint8, 32),
      },
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
    {
      id = 0x54,
      name = 'SID_AUTH_ACCOUNTLOGONPROOF',
      def = {
        p:uint32{"Status", key="status", nil, {
          [0x00] = "Logon successful",
          [0x02] = "Incorrect password",
          [0x0E] = "An email address should be registered for this account",
          [0x0F] = "Custom error. A string at the end of this message contains the error",
        }},
        p:array("Server Password Proof", p.uint8, 20),
        p:when{
          p.conditions.keyEquals("status", 0xF),
          {
            p:stringz("Additional information"),
          }
        },
      },
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
    {
      id = 0x55,
      name = 'SID_AUTH_ACCOUNTCHANGE',
      def = {
        p:uint32("Status", nil, {
          [0x00] = "Change accepted, requires proof",
          [0x01] = "Account doesn't exist",
          [0x05] = "Account requires upgrade",
        }),
        p:array("Salt", p.uint8, 32),
        p:array("Server Key", p.uint8, 32),
      },
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
    {
      id = 0x56,
      name = 'SID_AUTH_ACCOUNTCHANGEPROOF',
      def = {
        p:uint32("Status code", nil, {
          [0x00] = "Password changed",
          [0x02] = "Incorrect old password",
        }),
        p:array(
          "Server password proof for old password",
          p.uint8,
          20
        ),
      },
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
    {
      id = 0x57,
      name = 'SID_AUTH_ACCOUNTUPGRADE',
      def = {
        p:uint32("Status", nil, {
          [0x00] = "Upgrade Request Accepted",
          [0x01] = "Upgrade Request Denied",
        }),
        p:uint32("Server Token", base.HEX),
      },
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
    {
      id = 0x58,
      name = 'SID_AUTH_ACCOUNTUPGRADEPROOF',
      def = {
        p:uint32("Status", nil, {
          [0x00] = "Password changed",
          [0x02] = "Incorrect old password",
        }),
        p:array("Password proof", p.uint32, 5),
      },
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
    {
      id = 0x59,
      name = 'SID_SETEMAIL',
      def = {},
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
    {
      id = 0x5E,
      name = 'SID_WARDEN',
      def = {
        --[[TODO - decrypt packet data
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
        p:consume("plen", "Encrypted Packet"),
      },
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
    {
      id = 0x60,
      name = 'SID_GAMEPLAYERSEARCH',
      def = {
        p:uint8{"Number of players", key="players"},
        p:iterator{protofield_type="none", refkey="players", repeated={
          p:stringz("Player name"),
        }},
      },
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
    {
      id = 0x65,
      name = 'SID_FRIENDSLIST',
      def = {
        p:uint8{"Number of Entries", key="friends"},
        p:iterator{label="Friend", refkey="friends", repeated={
          p:stringz("Account"),
          p:flags{of=p.uint8, label="Status", fields={
            {"Mutual", 0x01, p.descs.YesNo},
            {"DND"   , 0x02, p.descs.YesNo},
            {"Away"  , 0x04, p.descs.YesNo},
          }},
          p:uint8("Location", nil, p.descs.OnlineStatus),
          p:strdw("ProductID", p.descs.ClientTag),
          p:stringz("Location name"),
        }},
      },
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
    {
      id = 0x66,
      name = 'SID_FRIENDSUPDATE',
      def = {
        p:uint8("Entry number"),
        p:flags{of=p.uint8, label="Status", fields={
          {"Mutual" , 0x01, p.descs.YesNo},
          {"DND"    , 0x02, p.descs.YesNo},
          {"Away"   , 0x04, p.descs.YesNo},
        }},
        p:uint8("Location", nil, p.descs.OnlineStatus),
        p:strdw("ProductID", p.descs.ClientTag),
        p:stringz("Location name"),
      },
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
    {
      id = 0x67,
      name = 'SID_FRIENDSADD',
      def = {
        p:stringz("Account"),
        p:uint8("Friend Type", nil, {
          [0x00] = "Non-mutual",
          [0x01] = "Mutual",
          [0x02] = "Nonmutual, DND",
          [0x03] = "Mutual, DND",
          [0x04] = "Nonmutual, Away",
          [0x05] = "Mutual, Away",
        }),
        p:uint8("Friend Status", nil, {
          [0x00] = "Offline",
          [0x02] = "In chat",
          [0x03] = "In public game",
          [0x05] = "In private game",
        }),
        p:strdw("ProductID", p.descs.ClientTag),
        p:stringz("Location"),
      },
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
    {
      id = 0x68,
      name = 'SID_FRIENDSREMOVE',
      def = {
        p:uint8("Entry Number"),
      },
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
    {
      id = 0x69,
      name = 'SID_FRIENDSPOSITION',
      def = {
        p:uint8("Old Position"),
        p:uint8("New Position"),
      },
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
    {
      id = 0x70,
      name = 'SID_CLANFINDCANDIDATES',
      def = {
        p:uint32("Cookie"),
        p:uint8("Status", nil, {
          [0x00] = "Successfully found candidate(s)",
          [0x01] = "Clan tag already taken",
          [0x08] = "Already in clan",
          [0x0a] = "Invalid clan tag specified",
        }),
        p:uint8{"Number of potential candidates", key="names"},
        p:iterator{protofield_type="none", refkey="names", repeated={
          p:stringz("Username"),
        }},
      },
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
    {
      id = 0x71,
      name = 'SID_CLANINVITEMULTIPLE',
      def = {
        p:uint32("Cookie"),
        p:uint8("Result", nil, {
          [0x00] = "Everyone accepted",
          [0x04] = "Declined",
          [0x05] = "Not available",
        }),
        p:iterator{
          protofield_type="none",
          condition = p.conditions.neg(p.conditions.keyEquals("acc", "")),
          repeated = {
            p:stringz{"Failed Account", key="acc"},
          },
        },
      },
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
    {
      id = 0x72,
      name = 'SID_CLANCREATIONINVITATION',
      def = {
        p:uint32("Cookie"),
        p:strdw("Clan Tag"),
        p:stringz("Clan Name"),
        p:stringz("Inviter's username"),
        p:uint8{"Number of users being invited", key="users"},
        p:iterator{refkey="users", label="Invited users", repeated={
          p:stringz("Name"),
        }},
      },
    },
    --[[doc
        Message ID:    0x73

        Message Name:  SID_CLANDISBAND

        Direction:     Server -> Client (Received)

        Used By:       Warcraft III: The Frozen Throne, Warcraft III

        Format:        (DWORD) Cookie
                      (BYTE) Result

        Remarks:       Result:

                      0x00: Successfully disbanded the clan
                      0x02: Cannot quit clan, not one week old yet
                      0x07: Not authorized to disband the clan

        Related:       [0x73] SID_CLANDISBAND (C->S), Clan Message Codes

    ]]
    {
      id = 0x73,
      name = 'SID_CLANDISBAND',
      def = {
        p:uint32("Cookie"),
        p:uint8("Result", nil, {
          [0x00] = "Successfully disbanded the clan",
          [0x02] = "Cannot quit clan, not one week old yet",
          [0x07] = "Not authorized to disband the clan",
        }),
      },
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
    {
      id = 0x74,
      name = 'SID_CLANMAKECHIEFTAIN',
      def = {
        p:uint32("Cookie"),
        p:uint8("Status", nil, {
          [0x00] = "Success",
          [0x02] = "Can't change until clan is a week old",
          [0x04] = "Declined",
          [0x05] = "Failed",
          [0x07] = "Not Authorized",
          [0x08] = "Not Allowed",
        }),
      },
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
    {
      id = 0x75,
      name = 'SID_CLANINFO',
      def = {
        p:uint8("Unknown"),
        p:strdw("Clan tag"),
        p:uint8("Rank", nil, p.descs.ClanRank),
      },
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
    {
      id = 0x76,
      name = 'SID_CLANQUITNOTIFY',
      def = {
        p:uint8("Status"),
      },
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
    {
      id = 0x77,
      name = 'SID_CLANINVITATION',
      def = {
        p:uint32("Cookie"),
        p:uint8("Result", nil, {
          [0x00] = "Invitation accepted",
          [0x04] = "Invitation declined",
          [0x05] = "Failed to invite user",
          [0x09] = "Clan is full",
        }),
      },
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
    {
      id = 0x78,
      name = 'SID_CLANREMOVEMEMBER',
      def = {
        p:uint32("Cookie"),
        p:uint8("Status", nil, {
          [0x00] = "Removed",
          [0x01] = "Removal failed",
          [0x02] = "Can not be removed yet",
          [0x07] = "Not authorized to remove",
          [0x08] = "Not allowed to remove",
        }),
      },
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
    {
      id = 0x79,
      name = 'SID_CLANINVITATIONRESPONSE',
      def = {
        p:uint32("Cookie"),
        p:strdw("Clan tag"),
        p:stringz("Clan name"),
        p:stringz("Inviter"),
      },
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
    {
      id = 0x7A,
      name = 'SID_CLANRANKCHANGE',
      def = {
        p:uint32("Cookie"),
        p:uint8("Status", nil, {
          [0x00] = "Successfully changed rank",
          [0x01] = "Failed to change rank",
          [0x02] = "Cannot change user's rank yet",
          [0x07] = "Not authorized to change user rank",
          [0x08] = "Not allowed to change user rank",
        }),
      },
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
    {
      id = 0x7C,
      name = 'SID_CLANMOTD',
      def = {
        p:uint32("Cookie"),
        p:uint32("Unknown"),
        p:stringz("MOTD"),
      },
    },
    --[[doc
        Message ID:    0x7D

        Message Name:  SID_CLANMEMBERLIST

        Direction:     Server -> Client (Received)

        Used By:       Warcraft III: The Frozen Throne, Warcraft III

        Format:        (DWORD) Cookie
                      (BYTE) Number of Members
                      For each member:

                      (STRING) Username
                      (BYTE) Rank
                      (BYTE) Online Status
                      (STRING) Location

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
    {
      id = 0x7D,
      name = 'SID_CLANMEMBERLIST',
      def = {
        p:uint32("Cookie"),
        p:uint8{"Number of Members", key = "members"},
        p:iterator{"Member Details", refkey = "members", repeated = {
          p:stringz("Username"),
          p:uint8("Rank", nil, p.descs.ClanRank),
          p:uint8("Online Status", nil, {
            [0x00] = "Offline",
            [0x01] = "Online",
          }),
          p:stringz("Location"),
        }},
      },
    },
    --[[doc
        Message ID:    0x7E

        Message Name:  SID_CLANMEMBERREMOVED

        Direction:     Server -> Client (Received)

        Used By:       Warcraft III: The Frozen Throne, Warcraft III

        Format:        (STRING) Clan member name

        Remarks:       Notifies the members of a clan that a user has been removed.

    ]]
    {
      id = 0x7E,
      name = 'SID_CLANMEMBERREMOVED',
      def = {
        p:stringz("Clan member name"),
      },
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
    {
      id = 0x7F,
      name = 'SID_CLANMEMBERSTATUSCHANGE',
      def = {
        p:stringz("Username"),
        p:uint8("Rank", nil, p.descs.ClanRank),
        p:uint8("Status", nil, {
          [0x00] = "Offline",
          [0x01] = "Online (not in either channel or game)",
          [0x02] = "In a channel",
          [0x03] = "In a public game",
          [0x05] = "In a private game",
        }),
        p:stringz("Location"),
      },
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
    {
      id = 0x81,
      name = 'SID_CLANMEMBERRANKCHANGE',
      def = {
        p:uint8("Old rank", nil, p.descs.ClanRank),
        p:uint8("New rank", nil, p.descs.ClanRank),
        p:stringz("Clan member who changed your rank"),
      },
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
    {
      id = 0x82,
      name = 'SID_CLANMEMBERINFORMATION',
      def = {
        p:uint32("Cookie"),
        p:uint8("Status code", nil, {
          [0x00] = "Success",
          [0x0C] = "User not found in clan",
        }),
        p:stringz("Clan name"),
        p:uint8("User's rank"),
        p:wintime("Date joined"),
      },
    },
  },
}

-- Define custom value maps before registration phase is triggered
p.utils.copy_table({
  [1] = 'Yes',
  [0] = 'No',
}, p.descs.YesNo)

p.utils.copy_table({
  ['IX86'] = 'Windows (Intel x86)',
  ['PMAC'] = 'Macintosh',
  ['XMAC'] = 'Macintosh OS X',
}, p.descs.PlatformID)

p.utils.copy_table({
  ['DSHR'] = 'Diablo 1 Shareware',
  ['DRTL'] = 'Diablo 1 (Retail)',
  ['SSHR'] = 'Starcraft Shareware',
  ['STAR'] = 'Starcraft',
  ['SEXP'] = 'Starcraft: Broodwar',
  ['JSTR'] = 'Starcraft Japanese',
  ['W2BN'] = 'Warcraft II Battle.Net Edition',
  ['D2DV'] = 'Diablo 2',
  ['D2XP'] = 'Diablo 2: Lord Of Destruction',
  ['WAR3'] = 'Warcraft III (Reign Of Chaos)',
  ['W3XP'] = 'Warcraft III: The Frozen Throne',
}, p.descs.ClientTag)

p.utils.copy_table({
  ['enUS'] = 'English (US)',
  ['enGB'] = 'English (UK)',
  ['frFR'] = 'French',
  ['deDE'] = 'German',
  ['esES'] = 'Spanish',
  ['itIT'] = 'Italian',
  ['csCZ'] = 'Czech',
  ['ruRU'] = 'Russian',
  ['plPL'] = 'Polish',
  ['ptBR'] = 'Portuguese (Brazilian)',
  ['ptPT'] = 'Portuguese (Portugal)',
  ['tkTK'] = 'Turkish',
  ['jaJA'] = 'Japanese',
  ['koKR'] = 'Korean',
  ['zhTW'] = 'Chinese (Traditional)',
  ['zhCN'] = 'Chinese (Simplified)',
  ['thTH'] = 'Thai',
}, p.descs.LangId)

p.utils.copy_table({
  [-720] = 'UTC +12',
  [-690] = 'UTC +11.5',
  [-660] = 'UTC +11',
  [-630] = 'UTC +10.5',
  [-600] = 'UTC +10',
  [-570] = 'UTC +9.5',
  [-540] = 'UTC +9',
  [-510] = 'UTC +8.5',
  [-480] = 'UTC +8',
  [-450] = 'UTC +7.5',
  [-420] = 'UTC +7',
  [-390] = 'UTC +6.5',
  [-360] = 'UTC +6',
  [-330] = 'UTC +5.5',
  [-300] = 'UTC +5',
  [-270] = 'UTC +4.5',
  [-240] = 'UTC +4',
  [-210] = 'UTC +3.5',
  [-180] = 'UTC +3',
  [-150] = 'UTC +2.5',
  [-120] = 'UTC +2',
  [-90]  = 'UTC +1.5',
  [-60]  = 'UTC +1',
  [-30]  = 'UTC +0.5',
  [0]    = 'UTC +0',
  [30]   = 'UTC -0.5',
  [60]   = 'UTC -1',
  [90]   = 'UTC -1.5',
  [120]  = 'UTC -2',
  [150]  = 'UTC -2.5',
  [180]  = 'UTC -3',
  [210]  = 'UTC -3.5',
  [240]  = 'UTC -4',
  [270]  = 'UTC -4.5',
  [300]  = 'UTC -5',
  [330]  = 'UTC -5.5',
  [360]  = 'UTC -6',
  [390]  = 'UTC -6.5',
  [420]  = 'UTC -7',
  [450]  = 'UTC -7.5',
  [480]  = 'UTC -8',
  [510]  = 'UTC -8.5',
  [540]  = 'UTC -9',
  [570]  = 'UTC -9.5',
  [600]  = 'UTC -10',
  [630]  = 'UTC -10.5',
  [660]  = 'UTC -11',
  [690]  = 'UTC -11.5',
  [720]  = 'UTC -12',
}, p.descs.TimeZoneBias)

-- International Locale ID (LCID)
-- http://support.microsoft.com/kb/221435
-- ( https://www.betaarchive.com/wiki/index.php/Microsoft_KB_Archive/221435 )
p.utils.copy_table({
  [11276] = 'French (Cameroon)',
  [1025] = 'Arabic (Saudi Arabia)',
  [1026] = 'Bulgarian',
  [1027] = 'Catalan',
  [1028] = 'Chinese (Taiwan)',
  [1029] = 'Czech',
  [1030] = 'Danish',
  [1031] = 'German (Germany)',
  [1032] = 'Greek',
  [1033] = 'English (United States)',
  [1034] = 'Spanish (Traditional Sort)',
  [1035] = 'Finnish',
  [1036] = 'French (France)',
  [1037] = 'Hebrew',
  [1038] = 'Hungarian',
  [1039] = 'Icelandic',
  [1040] = 'Italian (Italy)',
  [1041] = 'Japanese',
  [1042] = 'Korean',
  [1043] = 'Dutch (Netherlands)',
  [1044] = 'Norwegian (Bokmal)',
  [1045] = 'Polish',
  [1046] = 'Portuguese (Brazil)',
  [1047] = 'Rhaeto-Romanic',
  [1048] = 'Romanian',
  [1049] = 'Russian',
  [1050] = 'Croatian',
  [1051] = 'Slovak',
  [1052] = 'Albanian',
  [1053] = 'Swedish',
  [1054] = 'Thai',
  [1055] = 'Turkish',
  [1056] = 'Urdu',
  [1057] = 'Indonesian',
  [1058] = 'Ukrainian',
  [1059] = 'Belarusian',
  [1060] = 'Slovenian',
  [1061] = 'Estonian',
  [1062] = 'Latvian',
  [1063] = 'Lithuanian',
  [1064] = 'Tajik',
  [1065] = 'Farsi',
  [1066] = 'Vietnamese',
  [1070] = 'Sorbian',
  [1067] = 'Armenian',
  [1068] = 'Azeri (Latin)',
  [1069] = 'Basque',
  [1071] = 'FYRO Macedonian',
  [1072] = 'Sutu',
  [1073] = 'Tsonga',
  [1074] = 'Tswana',
  [1075] = 'Venda',
  [1076] = 'Xhosa',
  [1077] = 'Zulu',
  [1078] = 'Afrikaans',
  [1079] = 'Georgian',
  [1080] = 'Faroese',
  [1081] = 'Hindi',
  [1082] = 'Maltese',
  [1083] = 'Sami Lappish',
  [1084] = 'Gaelic Scotland',
  [1085] = 'Yiddish',
  [1086] = 'Malay (Malaysia)',
  [1087] = 'Kazakh',
  [1088] = 'Kyrgyz (Cyrillic)',
  [1089] = 'Swahili',
  [1090] = 'Turkmen',
  [1091] = 'Uzbek (Latin)',
  [1092] = 'Tatar',
  [1093] = 'Bengali (India)',
  [1094] = 'Punjabi',
  [1095] = 'Gujarati',
  [1096] = 'Oriya',
  [1097] = 'Tamil',
  [1098] = 'Telugu',
  [1099] = 'Kannada',
  [1100] = 'Malayalam',
  [1101] = 'Assamese',
  [1102] = 'Marathi',
  [1103] = 'Sanskrit',
  [1104] = 'Mongolian (Cyrillic)',
  [1105] = 'Tibetan',
  [1106] = 'Welsh',
  [1107] = 'Khmer',
  [1108] = 'Lao',
  [1109] = 'Burmese',
  [1110] = 'Galician',
  [1111] = 'Konkani',
  [1112] = 'Manipuri',
  [1113] = 'Sindhi',
  [1114] = 'Syriac',
  [1115] = 'Sinhalese (Sri Lanka)',
  [1118] = 'Amharic (Ethiopia)',
  [1120] = 'Kashmiri',
  [1121] = 'Nepali',
  [1122] = 'Frisian (Netherlands)',
  [1124] = 'Filipino',
  [1125] = 'Divehi',
  [1126] = 'Edo',
  [1136] = 'Igbo (Nigeria)',
  [1140] = 'Guarani (Paraguay)',
  [1142] = 'Latin',
  [1143] = 'Somali',
  [1153] = 'Maori (New Zealand)',
  [1279] = 'HID (Human Interface Device)',
  [2049] = 'Arabic (Iraq)',
  [2052] = 'Chinese (PRC)',
  [2055] = 'German (Switzerland)',
  [2057] = 'English (United Kingdom)',
  [2058] = 'Spanish (Mexico)',
  [2060] = 'French (Belgium)',
  [2064] = 'Italian (Switzerland)',
  [2067] = 'Dutch (Belgium)',
  [2068] = 'Norwegian (Nynorsk)',
  [2070] = 'Portuguese (Portugal)',
  [2072] = 'Romanian (Moldova)',
  [2073] = 'Russian (Moldova)',
  [2074] = 'Serbian (Latin)',
  [2077] = 'Swedish (Finland)',
  [2092] = 'Azeri (Cyrillic)',
  [2108] = 'Gaelic Ireland',
  [2110] = 'Malay (Brunei Darussalam)',
  [2115] = 'Uzbek (Cyrillic)',
  [2117] = 'Bengali (Bangladesh)',
  [2128] = 'Mongolian (Mongolia)',
  [3073] = 'Arabic (Egypt)',
  [3076] = 'Chinese (Hong Kong S.A.R.)',
  [3079] = 'German (Austria)',
  [3081] = 'English (Australia)',
  [3082] = 'Spanish (International Sort)',
  [3084] = 'French (Canada)',
  [3098] = 'Serbian (Cyrillic)',
  [4097] = 'Arabic (Libya)',
  [4100] = 'Chinese (Singapore)',
  [4103] = 'German (Luxembourg)',
  [4105] = 'English (Canada)',
  [4106] = 'Spanish (Guatemala)',
  [4108] = 'French (Switzerland)',
  [4122] = 'Croatian (Bosnia/Herzegovina)',
  [5121] = 'Arabic (Algeria)',
  [5124] = 'Chinese (Macau S.A.R.)',
  [5127] = 'German (Liechtenstein)',
  [5129] = 'English (New Zealand)',
  [5130] = 'Spanish (Costa Rica)',
  [5132] = 'French (Luxembourg)',
  [5146] = 'Bosnian (Bosnia/Herzegovina)',
  [6145] = 'Arabic (Morocco)',
  [6153] = 'English (Ireland)',
  [6154] = 'Spanish (Panama)',
  [6156] = 'French (Monaco)',
  [7169] = 'Arabic (Tunisia)',
  [7177] = 'English (South Africa)',
  [7178] = 'Spanish (Dominican Republic)',
  [7180] = 'French (West Indies)',
  [8193] = 'Arabic (Oman)',
  [8201] = 'English (Jamaica)',
  [8202] = 'Spanish (Venezuela)',
  [9217] = 'Arabic (Yemen)',
  [9225] = 'English (Caribbean)',
  [9226] = 'Spanish (Colombia)',
  [9228] = 'French (Congo, DRC)',
  [10241] = 'Arabic (Syria)',
  [10249] = 'English (Belize)',
  [10250] = 'Spanish (Peru)',
  [10252] = 'French (Senegal)',
  [11265] = 'Arabic (Jordan)',
  [11273] = 'English (Trinidad)',
  [11274] = 'Spanish (Argentina)',
  [12289] = 'Arabic (Lebanon)',
  [12297] = 'English (Zimbabwe)',
  [12298] = 'Spanish (Ecuador)',
  [12300] = "French (Cote d'Ivoire)",
  [13313] = 'Arabic (Kuwait)',
  [13321] = 'English (Philippines)',
  [13322] = 'Spanish (Chile)',
  [13324] = 'French (Mali)',
  [14337] = 'Arabic (U.A.E.)',
  [14346] = 'Spanish (Uruguay)',
  [14348] = 'French (Morocco)',
  [15361] = 'Arabic (Bahrain)',
  [15370] = 'Spanish (Paraguay)',
  [16385] = 'Arabic (Qatar)',
  [16393] = 'English (India)',
  [16394] = 'Spanish (Bolivia)',
  [17418] = 'Spanish (El Salvador)',
  [18442] = 'Spanish (Honduras)',
  [19466] = 'Spanish (Nicaragua)',
  [20490] = 'Spanish (Puerto Rico)',
}, p.descs.LocaleID)

p.utils.copy_table({
  [0x00] = 'OK',
  [0x01] = "Game doesn't exist",
  [0x02] = 'Incorrect password',
  [0x03] = 'Game full',
  [0x04] = 'Game already started',
  [0x06] = 'Too many server requests',
}, p.descs.GameStatus)

p.utils.copy_table({
  [0x00] = "All",
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
}, p.descs.GameType)

p.utils.copy_table({
  [0x00] = "WID_GAMESEARCH",
  [0x01] = "",
  [0x02] = "WID_MAPLIST: Request ladder map listing",
  [0x03] = "WID_CANCELSEARCH: Cancel ladder game search",
  [0x04] = "WID_USERRECORD: User stats request",
  [0x05] = "",
  [0x06] = "",
  [0x07] = "WID_TOURNAMENT",
  [0x08] = "WID_CLANRECORD: Clan stats request",
  [0x09] = "WID_ICONLIST: Icon list request",
  [0x0A] = "WID_SETICON: Change icon",
}, p.descs.WarcraftGeneralSubcommandId)

p.utils.copy_table({
  ["URL"] = "URL",
  ["MAP"] = "MAP",
  ["TYPE"] = "TYPE",
  ["DESC"] = "DESC",
  ["LADR"] = "LADR",
}, p.descs.WarcraftGeneralRequestType)

p.utils.copy_table({
  [""] = "Default icon",
  ["W3H1"] = "",
  ["W3O1"] = "",
  ["W3N1"] = "",
  ["W3U1"] = "",
  ["W3R1"] = "",
  ["W3D1"] = "",
}, p.descs.W3Icon)

p.utils.copy_table({
  -- Random
  ["ngrd"] = "Green Dragon Whelp",
  ["nadr"] = "Azure Dragon (Blue Dragon)",
  ["nrdr"] = "Red Dragon",
  ["nbwm"] = "Deathwing",

  -- Humans
  ["hpea"] = "Peasant",
  ["hfoo"] = "Footman",
  ["hkni"] = "Knight",
  ["Hamg"] = "Archmage",
  ["nmed"] = "Medivh",

  -- Orcs
  ["opeo"] = "Peon",
  ["ogru"] = "Grunt",
  ["otau"] = "Tauren",
  ["Ofar"] = "Far Seer",
  ["Othr"] = "Thrall",

  -- Undead
  ["uaco"] = "Acolyle",
  ["ugho"] = "Ghoul",
  ["uabo"] = "Abomination",
  ["Ulic"] = "Lich",
  ["Utic"] = "Tichondrius",

  -- Night Elves
  ["ewsp"] = "Wisp",
  ["earc"] = "Archer",
  ["edoc"] = "Druid of the Claw",
  ["Emoo"] = "Priestess of the Moon",
  ["Efur"] = "Furion Stormrage",

  -- Demons
  ["nfng"] = "dunno",
  ["ninf"] = "Infernal",
  ["nbal"] = "Doom Guard",
  ["Nplh"] = "Pit Lord/Manaroth",
  ["Uwar"] = "Archimonde",

  -- Random
  ["nmyr"] = "Naga Myrmidon",
  ["nnsw"] = "Naga Siren",
  ["nhyc"] = "Dragon Turtle",
  ["Hvsh"] = "Lady Vashj",
  ["Eevm"] = "Illidan (Morphed 2)",

  -- Humans
  ["hrif"] = "Rifleman",
  ["hsor"] = "Sorceress",
  ["hspt"] = "Spellbreaker",
  ["Hblm"] = "Blood Mage",
  ["Hjai"] = "Jaina",

  -- Orcs
  ["ohun"] = "Troll Headhunter",
  ["oshm"] = "Shaman",
  ["ospw"] = "Spirit Walker",
  ["Oshd"] = "Shadow Hunter",
  ["Orex"] = "Rexxar",

  -- Undead
  ["ucry"] = "Crypt Fiend",
  ["uban"] = "Banshee",
  ["uobs"] = "Destroyer",
  ["Ucrl"] = "Crypt Lord",
  ["Usyl"] = "Sylvanas",

  -- Night Elves
  ["esen"] = "Huntress",
  ["edot"] = "Druid of the Talon",
  ["edry"] = "Dryad",
  ["Ekee"] = "Keeper of the Grove",
  ["Ewrd"] = "Maiev",

  -- Tournament
  ["nfgu"] = "Felguard",
}, p.descs.W3IconNames)

p.utils.copy_table({
  ['SOLO'] = 'SOLO',
  ['TEAM'] = 'TEAM',
  ['FFA '] = 'FFA',
}, p.descs.W3LadderType)

p.utils.copy_table({
  ['2VS2'] = '2VS2',
  ['3VS3'] = '3VS3',
  ['4VS4'] = '4VS4',
}, p.descs.W3TeamType)

p.utils.copy_table({
  [0x00] = "Random",
  [0x01] = "Humans",
  [0x02] = "Orcs",
  [0x03] = "Undead",
  [0x04] = "Night Elves",
  [0x05] = "Tournament",
}, p.descs.W3Races)

-- Friend online status
p.utils.copy_table({
  [0x00] = "Offline",
  [0x01] = "Not in chat",
  [0x02] = "In chat",
  [0x03] = "In a public game",
  [0x04] = "In a private game, and you are not that person's friend",
  [0x05] = "In a private game, and you are that person's friend",
}, p.descs.OnlineStatus)

p.utils.copy_table({
  [0x00] = "Initiate that has been in the clan for less than one week (Peon)",
  [0x01] = "Initiate that has been in the clan for over one week (Peon)",
  [0x02] = "Member (Grunt)",
  [0x03] = "Officer (Shaman)",
  [0x04] = "Leader (Chieftain)",
}, p.descs.ClanRank)

-- trigger registration phase
p:initialize()
