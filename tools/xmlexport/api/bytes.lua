require "api.utils"

require "doc"

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
function bytes(...)
	local args = make_args_table_with_positional_map(
			{"label", "length"}, unpack(arg))

	return doc.new("bytes", args)
end
