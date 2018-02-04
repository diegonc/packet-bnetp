--[[
--  strdw
--
--  Creates a field for a 4 bytes string encoded in an integer.
--
--    @par label   Name of the field. It will be used as a label for the
--                 field's node at the dissection tree.
--    @par desc    Friendly names assigned to the valid values of the field.
--
--]]
function strdw (...)
	local args = make_args_table_with_positional_map(
		{"label", "desc"},
		...
	)
	args.reversed = true
	args.length = 4
	args.priv = { desc = args.desc }
	args.desc = nil
	args.dissect = function(self, state)
		local size = self:size(state)
		local str = state:peek(size):string()
		
		if self.reversed then
			str = string.reverse(str)
		end

		-- TODO: generalize lua based value/string maps
		if self.priv.desc and self.priv.desc[str] then
			str = self.priv.desc[str] .. " (" .. str .. ")"
		end
		state.bnet_node:add(self.pf, state:read(size), str)
	end
	return stringz(args)
end

