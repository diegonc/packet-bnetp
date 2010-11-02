--[[ make_args_table
--
--	Builds a table to be used by create_proto_field().
--	Positional parameters are moved to their corresponding named parameter.
--
--	This should be called in either of the following forms:
--		* Positional: make_args_table(arg1,arg2, ... )
--		* Mixed: make_args_table { arg1, arg2, name1=value1, ... }
--
--	They can be diferentiated because arg1 must always be a string
--	in the positional form. (field label)
--
--	In mixed form, named parameters overwrite their corresponding
--	positional parameter.
--]]
function make_args_table_with_positional_map(pmap, ...)
	local args = {}
	local size = table.getn(arg)
	if size > 0 then
		local orig = arg
		if type(arg[1]) == "table"  then
			-- Mixed
			orig = arg[1]
			size = table.getn(orig)
		elseif type(arg[1]) ~= "string"  then
			error("make_args_table called with wrong arguments types.")
		end
		-- Process positional parameters
		for i=1, table.getn(pmap) do
			args[pmap[i]] = orig[i]
		end
		if size > table.getn(pmap) then
			args[pmap.unpacked or "params"] = { n=(size - table.getn(pmap)), unpack(orig, table.getn(pmap)) }
		end
		-- Wipe positional parameters
		-- for i=1, size do
		--	orig[i] = nil
		-- end
		-- Copy named parameters if any. Avoid positional ones.
		for k,v in pairs(orig) do
			if type(k) ~= "number" then
				args[k] = v
			end
		end
	end	
	return args
end

function make_args_table(...)
	return make_args_table_with_positional_map({
		"label",
		"display",
		"desc",
		["unpacked"] = "params",}, unpack(arg))
end

require "doc"

function valuemap(vmap)
	if not vmap then return nil end

	local node = doc.new "valuemap"

	for k,v in pairs(vmap) do
		local pair = doc.new("valuemap", {
			key = k,
			value = v,
		})
		node:add_direct_child(pair)
	end
	return node
end
