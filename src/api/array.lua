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
			{"label", "of", "num"},
			...
	)

	if args.of ~= uint32 and args.of ~= uint8 then
		error("Arrays of types other than uint32 or uint8 are not supported.")
	end

	args.of = args.of {protofield_type="none"}
	args.length = args.of:size() * args.num
	args.dissect = function (self, state)
		local str = ""
		local isz = args.of:size()
		-- local fmt = "%0" .. (isz * 2) .. "X "
		local fmt = ""

		if isz == 1
			then fmt = "%02X"
			else fmt = "%08X "
		end
		local tail = state:tail()
		for i=0, self.num - 1 do
			str = str .. string.format(fmt,
			args.of:value(tail))
			tail:read(isz)
		end
		-- trim trailing space
		str = (string.gsub(str, "^(.*)%s*$", "%1")) 
		state.bnet_node:add(self.pf, state:read(args.length), str)
	end
	return stringz(args)
end

