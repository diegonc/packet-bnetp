--[[
--  sockaddr([label])
--
--
--	Displays sockaddr struct.
--	Is equals to the sequence
--
--		uint16("Address Family", nil, {[0]="AF_UNSPEC",[2]="AF_INET"}),
--		uint16("Port", big_endian=true},
--		ipv4("Host's IP"},
--		uint32("sin_zero"),
--		uint32("sin_zero"),
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
			uint16 {"Address Family", nil, {[0]="AF_UNSPEC",[2]="AF_INET"}, key="af"},
			uint16 {"Port", big_endian=true, key="port"},
			ipv4   {"Host's IP", key="ip"},
			uint32 {"sin_zero", key="sz1"},
			uint32 {"sin_zero", key="sz2"},
		},
	}

	function template:size()
		return 16
	end

	function template:dissect(state)
		local bn = state.bnet_node
		if self.big_endian then
			state.bnet_node = bn:add(self.pf, state:peek(self:size()))
		else
			state.bnet_node = bn:add_le(self.pf, state:peek(self:size()))
		end
		dissect_packet(state, self.imp)
		if state.packet.sz1 ~= 0 or state.packet.sz2 ~= 0 then
			state:error("sin_zero is not zero.");
		end
		if state.packet.af ~= 0 and state.packet.af ~= 2 then
			state:error("Adress Family is not AF_INET.")
		end
		local summary = string.format("IP: %s, Port: %d", state.packet.ip, state.packet.port)
		if self.label ~= nil then
			summary = self.label .. ": " .. summary 
		end
		state.bnet_node:set_text(summary)
		state.bnet_node = bn
	end

	function sockaddr (...)
		local args = make_args_table_with_positional_map(
				{"real_label"},
				...
		)
		args.label = "dummy string"
		return create_proto_field(template, args)
	end
end

