require "api.integer"
require "api.utils"

require "doc"

--[[
--  array
--
--  Creates a field for an array of other field types.
--
--  Currently only uint32 and uint8 are supported as base types.
--
--  Quick call:
--    @par label   Name of the field. It will be used as a label for the
--                 field's node at the dissection tree.
--    @par of      Base type.
--    @par num     Number of elements in the array.
--
--]]
function array (...)
	local args = make_args_table_with_positional_map(
			{"label", "of", "num"}, unpack(arg))

	if args.of ~= uint32 and args.of ~= uint8 then
		error("Arrays of types other than uint32 or uint8 are not supported.")
	end

	args.of = args.of().tag
	return doc.new("array", args)
end
