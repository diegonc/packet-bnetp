--[[
--  when
--
--  Selects a block of fields from a list when it's associated condition
--  is true.
--
--  Walks though the list of pairs received as argument sequentially evaluating
--  the first element and if it was true executing the second element of the
--  pair as a block of fields.
--
--  Only one block is executed.
--
--  Table call: { {condition, block}, ... )
--    @par condition Function that returns true if the block should be
--                   used given the current state.
--    @par block     Block of fields that will be executed when condition
--                   is true.
--
--]]
do
	local template = {
		protofield_type = "none",
	}

	function template:dissect(state)
		for _, v in ipairs(self.tests) do
			if v.condition(self, state) then
				dissect_packet(state, v.block)
				break
			end
		end
	end

  function when (...)
		local tmp = create_proto_field(template, {})
		if (#arg == 1) and arg[1].tests then
			tmp.tests = arg[1].tests
		else
			tmp.tests = {}
			-- XXX: little hack to allow both syntax for calling a function
			--      ( f() y f {} )
			if #arg == 1 and type(arg[1][1])=="table" then arg = arg[1] end
			for k, v in ipairs(arg) do
				local test = make_args_table_with_positional_map(
					{"condition", "block"}, v)
				tmp.tests[k] = test
			end
		end
		return tmp
	end
	function oldwhen (...)
		local par = { { arg[1].condition, arg[1].block } }
		if arg[1].otherwise then
			par[2] = { function() return true end, arg[1].otherwise }
		end
		return when (unpack(par))
	end
end

