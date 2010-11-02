require "api.utils"

require "doc"

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
function stringz(...)
	local args = make_args_table_with_positional_map(
			{"label", "length", "eos"}, unpack(arg))

	return doc.new("stringz", args)
end
