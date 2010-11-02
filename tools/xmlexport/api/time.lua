require "api.utils"

require "doc"

--[[
--  wintime
--
--  Creates a field for a wintime value.
--
--  Quick call: ( label )
--    @par label     Name of the field. It will be used as a label for the
--                   field's node at the dissection tree.
--
--]]
function wintime(...)
	local args = make_args_table_with_positional_map(
			{"label"}, unpack(arg))
	return doc.new("wintime", args)
end

--[[
--  posixtime
--
--  Creates a field for a UNIX time value.
--
--  Quick call: ( label )
--    @par label     Name of the field. It will be used as a label for the
--                   field's node at the dissection tree.
--
--]]
function posixtime(...)
	local args = make_args_table_with_positional_map(
			{"label"}, unpack(arg))
	return doc.new ("posixtime", args)
end
