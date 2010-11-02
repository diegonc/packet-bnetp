require "api.utils"

require "doc"

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
	                {"label", "desc"}, unpack(arg))
	local vmap = valuemap(args.desc)
	args.desc = nil
	local node = doc.new("strdw", args)
	if vmap then
		node:add_direct_child(vmap)
	end
	return node
end
