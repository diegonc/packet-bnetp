--[[
--  version
--
--  Creates a field for a version like data type.
--
--  @par label     Name of the field. It will be used as a label for the
--                   field's node at the dissection tree.
--
--]]
function version (...)
	local args = make_args_table(
		...
	)
	args.big_endian = false
	return ipv4(args)
end
