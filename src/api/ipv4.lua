--[[
--  ipv4
--
--  Creates a field for an ip address.
--
--  Quick call: ( label, big_endian )
--    @par label       Name of the field. It will be used as a label for the
--                     field's node at the dissection tree.
--    @par big_endian  Endianess used while decoding address. If it is true big
--                     endian otherwise little endian.
--
--]]
do
	local template = {
		protofield_type = "ipv4",
		size = function(...) return 4 end,
		value = function (self, state)
			local val = state:peek(self.size())
			return tostring(val:ipv4())
		end,
		big_endian = true,
	}

	function ipv4(...)
		local args = make_args_table_with_positional_map(
				{"label", "big_endian"}, unpack(arg))

		return create_proto_field(template, args)
	end
end

