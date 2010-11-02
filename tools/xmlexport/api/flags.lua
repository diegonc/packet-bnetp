require "api.integer"
require "api.utils"

require "doc"

local function flags_field(field)
	local attrs = make_args_table_with_positional_map(
			{"label", "mask", "desc", "sname"}, field)
	local vmap = valuemap(attrs.desc)
	
	attrs.desc = nil
	
	local node = doc.new ("field", attrs)
	if vmap then
		node:add_direct_child(vmap)
	end

	return node
end

--[[
--  flags
--
--  Creates a field for a set of flags encoded in an integer.
--
--  Currently only uint32 and uint8 are supported as base types.
--
--  Quick call:
--    @par label   Name of the field. It will be used as a label for the
--                 field's node at the dissection tree.
--    @par of      Base type.
--    @par fields  The set of flags inside a value of the base type.
--
--]]
function flags (...)
	local attrs = make_args_table_with_positional_map(
			{"label", "of", "fields"}, unpack(arg))
	
	local fields = attrs.fields

	attrs.of = attrs.of().tag
	attrs.fields = nil

	local node = doc.new("flags", attrs)

	for _,v in pairs(fields) do
		node:add_direct_child(flags_field(v))
	end
	return node
end

