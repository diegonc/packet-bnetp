local X = require('xproto')
local p = X.protocol('w3gs', 'Warcraft III Game Protocol',
  { key = 'bnetp.type', value = 0xF7 })

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

--[[
--  slot([label])
--
--	Displays a slot struct.
--	Is equals to the sequence
--
--		p:uint8  {"Player Number"},
--		p:uint8  {"Download status"},
--		p:uint8  {"Slot status"},
--		p:uint8  {"Computer status"},
--		p:uint8  {"Team"},
--		p:uint8  {"Colour"},
--		p:uint8  {"Race"},
--		p:uint8  {"Computer type"},
--		p:uint8  {"Handicap"},
--
--	with some summary.
--
--  Quick call:
--    @par label   Name of the field. It will be used as a label for the
--                 field's node at the dissection tree.
--]]
p.api.slot = function(proto, ...)
  local args = proto.utils.make_args_table_with_positional_map(
    { "label" },
    ...
  )

  local template = { protofield_type = "bytes" }

  function template.size()
    return 9
  end

  ---@diagnostic disable-next-line: redefined-local
  function template:dissect(state, proto)
    local proto_node = state.proto_node
    state.proto_node = proto_node:add(self.pf, state:peek(self.size()))

    state:dissect_packets(proto, self.imp)

    local summary = string.format("Slot %d", state.packet.pnum)
    if (self.label ~= nil) then
      summary = self.label .. ": " .. summary
    end

    state.proto_node:set_text(summary)
    state.proto_node = proto_node
  end

  local imp = {
    proto:uint8 { "Player Number", key = "pnum" },
    proto:uint8 { "Download status" },
    proto:uint8 { "Slot status" },
    proto:uint8 { "Computer Status" },
    proto:uint8 { "Teram" },
    proto:uint8 { "Colour" },
    proto:uint8 { "Race" },
    proto:uint8 { "Computer Type" },
    proto:uint8 { "Handicap" },
  }

  return {
    args = args,
    imp = imp,
    register = function (self)
      self.args.imp = proto.utils.map_table(
        self.imp,
        function (c)
          if c.register then
            return c:register()
          else
            return c
          end
        end
      )

      -- add a dummy label as it's required by create_proto_field
      self.args.label = self.args.label or "Slot"

      local label = self.args.label
      local tmp = proto.utils.create_proto_field(proto, template, self.args)
      tmp.label = label

      return tmp
    end
  }
end

p:entrypoint {
  p:lookahead_uint8_check(0xF7),
  p:begin_packet(),
  p:uint8 {
    label = 'Header Type',
    display = base.HEX,
    key = 'type',
    filter = 'type'
  },
  p:when {
    p.conditions.keyEquals('isServerPacket', true),
    {p:uint8 {
      'Packet ID',
      base.HEX,
      p.descs.server_packets,
      key = 'pid',
      filter = 'pid'
    }},
    {p:uint8 {
      'Packet ID',
      base.HEX,
      p.descs.client_packets,
      key = 'pid',
      filter = 'pid'
    }},
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
  p:end_packet('plen'),
}

p:collection {
  name = 'client_packets',
  packets = {
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
                      (BYTE)[] Unknown
                      (SOCKADDR) Internal

        Remarks:       A client sends this to the host to enter the game lobby.

                      The internal IP uses the Windows sockaddr_in structure.

        Related:       [0x05] W3GS_REJECTJOIN (S->C), [0x04] W3GS_SLOTINFOJOIN (S->C),
                      [0x06] W3GS_PLAYERINFO (S->C), [0x3D] W3GS_MAPCHECK (S->C)

    ]]
    {
      id = 0x1E,
      name = "W3GS_REQJOIN",
      def = {
        p:uint32("Host Counter"),
        p:uint32("Entry Key"),
        p:uint8("Unknown"),
        p:uint16("Listen Port"),
        p:uint32("Peer Key"),
        p:stringz("Player name"),
        p:uint8{"Unknown", key="length"},
        p:iterator{alias="none", label="Unknown", refkey="length", repeated={
          p:uint8("Unknown")
        }},
        p:sockaddr("Socket"),
      },
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
    {
      id = 0x21,
      name = "W3GS_LEAVEREQ",
      def = {
        p:uint32("Reason", nil, {
          [0x01] = "PLAYERLEAVE_DISCONNECT",
          [0x07] = "PLAYERLEAVE_LOST",
          [0x08] = "PLAYERLEAVE_LOSTBUILDINGS",
          [0x09] = "PLAYERLEAVE_WON",
          [0x0A] = "PLAYERLEAVE_DRAW",
          [0x0B] = "PLAYERLEAVE_OBSERVER",
          [0x0D] = "PLAYERLEAVE_LOBBY",
        }),
      },
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
    {
      id = 0x23,
      name = "W3GS_GAMELOADED_SELF",
      def = {},
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
    {
      id = 0x26,
      name = "W3GS_OUTGOING_ACTION",
      def = {
        p:uint32("CRC-32 encryption"),
        p:consume("plen", "Action data", 'action_data'),
      },
    },
    --[[doc
        Message ID:    0x27

        Message Name:  W3GS_OUTGOING_KEEPALIVE

        Direction:     Client -> Server (Sent)

        Used By:       Warcraft III: The Frozen Throne, Warcraft III

        Format:        (BYTE)[] Unknown

        Remarks:       This is sent to the host from each client.

                      The unknown value may be a checksum and is also used in replays.

    ]]
    {
      id = 0x27,
      name = "W3GS_OUTGOING_KEEPALIVE",
      def = {
        p:array("Unknown", p.uint8, 5),
      },
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
    {
      id = 0x28,
      name = "W3GS_CHAT_TO_HOST",
      def = {
        p:uint8("Total"),
        p:uint8("To player number"),
        p:uint8("From player number"),
        p:uint8{"Flags", key="flags"},
        p:casewhen{
          {p.conditions.keyEquals("flags", 0x10), {
            p:stringz("Message"),
          }},
          {p.conditions.keyEquals("flags", 0x11), {
            p:uint8("Team"),
          }},
          {p.conditions.keyEquals("flags", 0x12), {
            p:uint8("Color"),
          }},
          {p.conditions.keyEquals("flags", 0x13), {
            p:uint8("Race"),
          }},
          {p.conditions.keyEquals("flags", 0x14), {
            p:uint8("Handicap"),
          }},
          {p.conditions.keyEquals("flags", 0x20), {
            p:uint32("Extra Flags"),	--message scope
            p:stringz("Message"),
          }},
          {p.conditions.always(), {	--Probably never happens
            p:stringz("Message"),
          }},
        },
      },
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
    {
      id = 0x2F,
      name = "W3GS_SEARCHGAME",
      def = {
        p:strdw("Product", p.descs.ClientTag),
        p:uint32("Version"),
        p:uint32("Unknown"),
      },
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
    {
      id = 0x35,
      name = "W3GS_PING_FROM_OTHERS",
      def = {},
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
    {
      id = 0x37,
      name = "W3GS_CLIENTINFO",
      def = {
        p:uint32("Player Counter"),
        p:uint32("Unknown"),
        p:uint8("Player number"),
        p:uint8("[5] Unknown"),
      },
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
    {
      id = 0x3F,
      name = "W3GS_STARTDOWNLOAD",
      def = {},
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
    {
      id = 0x42,
      name = "W3GS_MAPSIZE",
      def = {
        p:uint32("Unknown"),
        p:uint8("Size Flag"),
        p:uint32("Map Size"),
      },
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
    {
      id = 0x44,
      name = "W3GS_MAPPARTOK",
      def = {
        p:uint8("To player number"),
        p:uint8("From player number"),
        p:uint32("Unknown"),
        p:uint32("Chunk position in file"),
      },
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
    {
      id = 0x45,
      name = "W3GS_MAPPARTNOTOK",
      def = {
        p:consume('plen', 'Unknown')
      }
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
    {
      id = 0x46,
      name = "W3GS_PONG_TO_HOST",
      def = {
        p:uint32("tickCount"),
      },
    },
  },
}

p:collection {
  name = 'server_packets',
  packets = {
    --[[doc
        Message ID:    0x01

        Message Name:  W3GS_PING_FROM_HOST

        Direction:     Server -> Client (Received)

        Used By:       Warcraft III: The Frozen Throne, Warcraft III

        Format:        (DWORD) Tick Count

        Remarks:       This is sent every 30 seconds to make sure that the client is still
                      responsive.

        Related:       [0x46] W3GS_PONG_TO_HOST (C->S)

    ]]
    {
      id = 0x01,
      name = "W3GS_PING_FROM_HOST",
      def = {
        p:uint32("tickCount"),
      },
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
                      (SOCKADDR) Player's socket data

                      For each slot:
                      (BYTE) Player number
                      (BYTE) Download status
                      (BYTE) Slot status
                      (BYTE) Computer status
                      (BYTE) Team
                      (BYTE) Color
                      (BYTE) Race
                      (BYTE) Computer type (Difficulty)
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
    {
      id = 0x04,
      name = "W3GS_SLOTINFOJOIN",
      def = {
        p:uint16("Length of Slot Info"),
        p:uint8{"Number of slots", key="length"},
        p:iterator{alias="none", label="Slot data", refkey="length", repeated={
          p:slot()
        }},
        p:uint32("Random seed"),
        p:uint8("Game type"),
        p:uint8("Number of player slots without observers"),
        p:uint8("Player number"),
        p:sockaddr("Socket"),
      },
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
    {
      id = 0x05,
      name = "W3GS_REJECTION",
      def = {
        p:uint32("Reason"),
      },
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
                        (BYTE)[] Unknown
                        (SOCKADDR) External
                        (SOCKADDR) Internal

        Remarks:         Tells a client about a player's information.

                        The external and internal IP are always zero for the host.

                        NOTE: This packet needs a better structure in the Format. Until then,
                        you will have to deal with the unorganized fields.

    ]]
    {
      id = 0x06,
      name = "W3GS_PLAYERINFO",
      def = {
        p:uint32("Player Counter"),
        p:uint8("Player number"),
        p:stringz("Player name"),
        p:uint8{"Unknown", key="length"},
        p:iterator{alias="none", label="Unknown", refkey="length", repeated={
          p:uint8("Unknown")
        }},
        p:sockaddr("External Socket"),
        p:sockaddr("Internal Socket"),
      },
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
    {
      id = 0x07,
      name = "W3GS_PLAYERLEFT",
      def = {
        p:uint8("Player number"),
        p:uint32("Reason"),
      },
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
    {
      id = 0x08,
      name = "W3GS_PLAYERLOADED",
      def = {
        p:uint8("Player number"),
      },
    },
    --[[doc
        Message ID:    0x09

        Message Name:  W3GS_SLOTINFO

        Direction:     Server -> Client (Received)

        Used By:       Warcraft III: The Frozen Throne, Warcraft III

        Format:        (WORD) Length of Slot Info
                      (BYTE) Number of slots
                      (BYTE)[] Slot data
                      (DWORD) Random seed
                      (BYTE) Game type
                      (BYTE) Number of player slots without observers

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
    {
      id = 0x09,
      name = "W3GS_SLOTINFO",
      def = {
        p:uint16("Length of Slot Info"),
        p:uint8{"Number of slots", key="length"},
        p:iterator{alias="none", label="Slot data", refkey="length", repeated={
          p:slot()
        }},
        p:uint32("Random seed"),
        p:uint8("Layout status", nil, {
          [0x00] = "Melee",
          [0x01] = "Custom forces",
          [0x02] = "Fixed player settings",
          [0x03] = "Custom forces and fixed player settings",
        }),
        p:uint8("Non-observer slots")
      },
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
    {
      id = 0x0A,
      name = "W3GS_COUNTDOWN_START",
      def = {},
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
    {
      id = 0x0B,
      name = "W3GS_COUNTDOWN_END",
      def = {},
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
    {
      id = 0x0C,
      name = "W3GS_INCOMING_ACTION",
      def = {
        p:uint16("Send interval"),
        p:uint16("CRC-16 encryption"),
        p:uint8("Player number"),
        p:uint16 {"Length of action data", key="action_length"},
        p:bytes("Action data", "key", "action_length"),
      },
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
                      (BYTE)[] Data

        Remarks:       This is sent to the clients to print a message on the screen from
                      another player.

    ]]
    {
      id = 0x0F,
      name = "W3GS_CHAT_FROM_HOST",
      def = {
        p:uint8{"Player count", key="count"},
        p:iterator{alias="none", label="Slot data", refkey="count", repeated={
          p:uint8("  Player number"),
        }},
        p:uint8("Player number that sent the message"),
        p:uint8{"Flags", key="flags"},
        p:casewhen{
          {p.conditions.keyEquals("flags", 0x10), {
            p:stringz("Message"),
          }},
          {p.conditions.keyEquals("flags", 0x11), {
            p:uint8("Team"),
          }},
          {p.conditions.keyEquals("flags", 0x12), {
            p:uint8("Color"),
          }},
          {p.conditions.keyEquals("flags", 0x13), {
            p:uint8("Race"),
          }},
          {p.conditions.keyEquals("flags", 0x14), {
            p:uint8("Handicap"),
          }},
          {p.conditions.keyEquals("flags", 0x20), {
            p:uint32("Extra Flags"),	--message scope
            p:stringz("Message"),
          }},
          {p.conditions.always(), {	--Probably never happens
            p:stringz("Message"),
          }},
        },
      },
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
    {
      id = 0x1B,
      name = "W3GS_LEAVERS",
      def = {},
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
    {
      id = 0x2F,
      name = "W3GS_SEARCHGAME",
      def = {
        p:strdw("Product", p.descs.ClientTag),
        p:uint32("Version"),
        p:uint32("Unknown"),
      },
    },
    --[[doc
        Message ID:    0x30

        Message Name:  W3GS_GAMEINFO

        Direction:     Server -> Client (Received)

        Used By:       Warcraft III: The Frozen Throne, Warcraft III

        Format:        (DWORD) Product
                      (DWORD) Host Counter
                      (DWORD) Players In Game
                      (DWORD) Entry Key
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
    {
      id = 0x30,
      name = "W3GS_GAMEINFO",
      def = {
        p:strdw("Product", p.descs.ClientTag),
        p:uint32("Host Counter"),
        p:uint32("Players In Game"),
        p:uint32("Entry Key"),
        p:stringz("Game name"),
        p:stringz("Password"),
        p:stringz("Statstring"),
        p:uint32("Slots total"),
        p:uint32("Game Type Info"),
        p:uint32("Unknown"),
        p:uint32("Slots available"),
        p:uint32("Time since creation"),
        p:uint16("Game Port"),
      },
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
    {
      id = 0x31,
      name = "W3GS_CREATEGAME",
      def = {
        p:strdw("Product", p.descs.ClientTag),
        p:uint32("Host Counter"),
        p:uint32("Players In Game"),
      },
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
    {
      id = 0x32,
      name = "W3GS_REFRESHGAME",
      def = {
        p:uint32("Host Counter"),
        p:uint32("Players In Game"),
        p:uint32("Slots available"),
      },
    },
    --[[doc
        Message ID:    0x33

        Message Name:  W3GS_DECREATEGAME

        Direction:     Server -> Client (Received)

        Used By:       Warcraft III: The Frozen Throne, Warcraft III

        Format:        (DWORD) Host Counter

        Remarks:       Notifies the local area network that a game is no longer being hosted.

    ]]
    {
      id = 0x33,
      name = "W3GS_DECREATEGAME",
      def = {
        p:uint32("Host Counter"),
      },
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
    {
      id = 0x36,
      name = "W3GS_PONG_TO_OTHERS",
      def = {},
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
    {
      id = 0x3D,
      name = "W3GS_MAPCHECK",
      def = {
        p:uint32("Unknown"),
        p:stringz("File Path"),
        p:uint32("File size"),
        p:uint32{"Map info", base.HEX},
        p:uint32{"File CRC encryption", base.HEX},
        p:array("File SHA-1 hash", p.uint8, 20),
      },
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
    {
      id = 0x3F,
      name = "W3GS_STARTDOWNLOAD",
      def = {
        p:uint32("Unknown"),
        p:uint8("Player number"),
      },
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
    {
      id = 0x43,
      name = "W3GS_MAPPART",
      def = {
        p:uint8("To player number"),
        p:uint8("From player number"),
        p:uint32("Unknown"),
        p:uint32("Chunk position in file"),
        p:uint32("CRC-32 encryption"),
        p:array("Data", p.uint8, 1442),
      },
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
    {
      id = 0x48,
      name = "W3GS_INCOMING_ACTION2",
      def = {
        p:uint16("Send interval"),
        p:uint16("CRC-16 encryption"),
        p:uint8("Player number"),
        p:uint16 { "Length of action data", key = "data_length" },
        p:bytes("Action data", "key", "data_length"),
      },
    },
  },
}

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

-- trigger registration phase
p:initialize()
