--[[
--  slot([label])
--
--
--	Displays a slot struct.
--	Is equals to the sequence
--
--		uint8  {"Player Number"},
--		uint8  {"Download status"},
--		uint8  {"Slot status"},
--		uint8  {"Computer status"},
--		uint8  {"Team"},
--		uint8  {"Colour"},
--		uint8  {"Race"},
--		uint8  {"Computer type"},
--		uint8  {"Handicap"},
--
--	with some summary.
--
--  Quick call:
--    @par label   Name of the field. It will be used as a label for the
--                 field's node at the dissection tree.
--
--]]
do
	local template = {
		protofield_type = "bytes",
		imp = {
			uint8  {"Player Number", key="num"},
			int8  {"Download status", key="dl"},
			uint8  {"Slot status", key="status"},
			uint8  {"Computer status", key="comp"},
			uint8  {"Team", key="team"},
			uint8  {"Colour", key="color"},
			uint8  {"Race", key="race"},
			uint8  {"Computer type", key="diff"}, -- difficulty
			uint8  {"Handicap", key="handicap"},
		},
	}

	function template:size()
		return 9
	end

	function template:dissect(state)
		local bn = state.bnet_node
		if self.big_endian then
			state.bnet_node = bn:add(self.pf, state:peek(self:size()))
		else
			state.bnet_node = bn:add_le(self.pf, state:peek(self:size()))
		end
		dissect_packet(state, self.imp)
		local summary = string.format("Slot %d", state.packet.num)
		if self.label ~= nil then
			summary = self.label .. ": " .. summary
		end
		state.bnet_node:set_text(summary)
		state.bnet_node = bn
	end

	function slot (...)
		local args = make_args_table_with_positional_map(
				{"real_label"},
				...
		)
		args.label = "dummy string"
		return create_proto_field(template, args)
	end
end

