require "api.utils"

require "doc"

--[[
--  sockaddr([label])
--
--
--	Displays sockaddr struct.
--	Is equals to the sequence
--
--		uint16("Address Family", nil, {[2]="AF_INET"}),
--		uint16("Port", big_endian=true},
--		ipv4("Host's IP"},
--		uint32("sin_zero"),
--		uint32("sin_zero"),
--
--	with some summary.
--
--  Quick call:
--    @par label   Name of the field. It will be used as a label for the
--                 field's node at the dissection tree.
--
--]]
function sockaddr (...)
	local args = make_args_table_with_positional_map(
			{"label"}, unpack(arg))
	return doc.new("sockaddr", args)
end
