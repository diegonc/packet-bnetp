--[[
--  bytes
--
--  Creates a field for an array of bytes.
--
--  Quick call:
--    @par label   Name of the field. It will be used as a label for the
--                 field's node at the dissection tree.
--    @par length  Length of the array. 
--
--]]
do
	local template = {
		protofield_type = "bytes",
		size = function(self, state)
			return self.length
		end,
		length = 1,
	}

	function bytes(...)
		local args = make_args_table_with_positional_map(
				{"label", "length"},
#if LUA_VERSION >= 510
				...
#else
				unpack(arg)
#endif
		)

		return create_proto_field(template, args)
	end
end

