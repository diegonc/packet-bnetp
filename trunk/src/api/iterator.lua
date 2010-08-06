--[[
--  iterator
--
--  It will repeat a block of fields for a given number of times.
--
--  Quick call: ( label, refkey, repeated )
--    @par label     Name of the field. It will be used as a label for the
--                   field's node at the dissection tree.
--    @par refkey    Key that holds the number of repetitions. Must have
--                   been initialized by a former field.
--    @par repeated  Block of fields that will be repeated.
--
--]]
do
	local template = {
		protofield_type = "bytes",
		priv = {}, -- iterator state,
	}

	function template:dissect(state)
		self:initialize(state)
		while self:condition(state) do
			self:iteration(state)
		end
		self:finalize(state)
	end
	
	function template:initialize (state)
		if self.refkey then
			self.priv.count = state.packet[self.refkey]
		end
		self.priv.bn = state.bnet_node
	end

	function template:condition (state)
		return (self.priv.count > 0)
	end

	function template:iteration (state)
		local start = state.used
		if self.pf then
			state.bnet_node = self.priv.bn:add(self.pf, state:peek(1))
		end
		dissect_packet(state, self.repeated)
		if self.pf and state.bnet_node.set_len then
			state.bnet_node:set_len(state.used - start)
		end
		if self.refkey then
			self.priv.count = self.priv.count - 1
		end
	end
	
	function template:finalize (state)
		state.bnet_node = self.priv.bn
	end

	function iterator(...)
		local args = make_args_table_with_positional_map(
				{"label", "refkey", "repeated"}, unpack(arg))

		-- translate alias to protofield_type
		if args.alias then
			args.protofield_type = args.alias
			args.alias = nil
		end

		return create_proto_field(template, args)
	end
end

