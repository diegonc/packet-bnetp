--[[
--  bytes
--
--  Creates a field for an array of bytes.
--
--  Quick call: ( label, length, refkey )
--  Table call: { label=..., length=..., refkey=... }
--    @par label   Name of the field. It will be used as a label for the
--                 field's node at the dissection tree.
--    @par length  Length of the array.
--                 If it is numeric, it indicates an array of that fixed
--                 legth.
--                 If it is a string, it specifies one of the following
--                 values:
--                   * "key": use the key parameter to set the length of
                              the array.
--    @par refkey  Key that holds the length of the array. It must have
--                 been initialized by a former field.
--                 Required if the length parameter is "key".
--
--]]
do
	local valid_lengths = {
		key = true
	}
	local template = {
		protofield_type = "bytes",
		size = function(self, state)
			if type(self.length) == "number" then
				return self.length
			end
			if type(self.length) ~= "string"
					or not valid_lengths[self.length] then
				error("length has an invalid value: "
					 .. tostring(self.length))
			end
			local length = state.packet[self.refkey]
			if length == nil then
				error("key '" .. self.refkey .. "' has not been defined")
			end
			return length
		end,
		length = 1,
	}

	function bytes(...)
		local args = make_args_table_with_positional_map(
				{"label", "length", "refkey"},
				...
		)

		return create_proto_field(template, args)
	end
end

