local X = require("xproto")
local p = X.protocol("bnetp", "Battle.net Pre protocol",
  { key = "tcp.port", value = 6112 })

-- Create dissector table under the "bnetp.type" key
local type_table = DissectorTable.new(
  "bnetp.type", "Battle.net Protocol Type", ftypes.UINT8)

p.api.call_subdissector_or_reject = function (proto)
  return {
    dissect = function (self, state)
      local type = state.packet.type
      local dissector = type_table:get_dissector(type)

      -- Reject packet if no subdissector is found
      if dissector == nil then
        state:reject()
      else
        -- Pass packet direction down to subdissector
        state.pkt.private.isServerPacket = tostring(state.isServerPacket)

        -- Allow desegmentation in the subdissector
        local can_deseg_saved = state.pkt.can_desegment
        if (state.pkt.can_desegment > 0) then
          state.pkt.can_desegment = 2
        end

        local consumed = type_table:try(type, state:tvb(), state.pkt, state.root_node)
        state.used = state.used + consumed

        -- Restore desegmentation value
        state.pkt.can_desegment = can_deseg_saved
      end
    end
  }
end

p:entrypoint {
  p:uint8 {
    filter = "bnetp.type",
    key = "type",
    protofield_type = "none",
  },
  p:call_subdissector_or_reject(),
}

p:initialize()
