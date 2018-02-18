--[[
--  stringz
--
--  Creates a field for a string.
--
--  Quick call: ( label, length, eos )
--    @par label     Name of the field. It will be used as a label for the
--                   field's node at the dissection tree.
--    @par length    Length of the string. If it is -1, the string is `eos`
--                   terminated. (Default: -1)
--    @par eos       String terminator. (Default: null character )
--
--]]
do
	local template = {
		protofield_type = "string",
		size = function(self, state)
			if (self.length == nil) or (self.length < 0) then
				local eos = self.eos or 0 -- end of string
				local buf = state:tvb()
				local n = 0
				while (n < buf:len()) and (buf(n,1):uint() ~= eos) do
					n = n + 1
				end
				return n + 1
			else
				return self.length
			end
		end,
		length = -1,
		dissect = function(self, state)
			local size = self:size(state)
			local str = state:peek(size):string()

			if self.reversed then
				str = string.reverse(str)
			end

			state.bnet_node:add(self.pf, state:read(size), str)
		end,
		value = function (self, state)
			-- Subtract one from size to remove string terminator
			local val = state:peek(self:size(state) - 1)
			return val:string()
		end,
	}

	function stringz(...)
		local args = make_args_table_with_positional_map(
				{"label", "length", "eos"},
				...
		)

		return create_proto_field(template, args)
	end
end

