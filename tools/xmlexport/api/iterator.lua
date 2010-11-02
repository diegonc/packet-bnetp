require "api.utils"

require "doc"

--[[
--  iterator
--
--  It will repeat a block of fields for a given number of times.
--
--  Quick call: ( label, refkey, repeated, node, subnode )
--    @par label     Name of the field. It will be used as a label for the
--                   field's node at the dissection tree.
--    @par refkey    Key that holds the number of repetitions. Must have
--                   been initialized by a former field.
--    @par repeated  Block of fields that will be repeated.
--    @par node      Whether to create a node for the iterator.
--    @par subnode   Whether to create a node for every iteration.
--
--]]
function iterator(...)
	local args = make_args_table_with_positional_map({
		"label", "refkey", "repeated", "node", "subnode"},
		unpack(arg))

	if not args.repeated then
		error(package.loaded.debug.traceback())
	end

	local repeated = args.repeated

	-- defaults for node creation
	if not args.node
		then args.node = true end
	if not args.subnode
		then args.subnode = (#args.repeated > 1) end

	args.repeated = nil
	local node = doc.new ("iterator", args)
	for _,v in pairs(repeated) do
		node:add_direct_child(v)
	end
	return node
end
