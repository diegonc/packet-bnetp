require "api.utils"

require "doc"

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
function ipv4(...)
	local args = make_args_table_with_positional_map(
		{"label", "big_endian"}, unpack(arg))
	return doc.new("ipv4", args)
end
