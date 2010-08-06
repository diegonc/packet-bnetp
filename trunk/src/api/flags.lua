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
	local args = make_args_table_with_positional_map(
			{"label", "of", "fields"}, unpack(arg))
	
	args.filter = "hasflags"

	local tmp = args.of(args)
	local fields = {}

	for k,v in pairs(tmp.fields) do
		local pfarg = make_args_table_with_positional_map(
				{"label", "mask", "desc", "sname"}, v)
		pfarg.label = pfarg.label or pfarg.sname
		pfarg.params = { pfarg.mask }
		pfarg.active = pfarg.active or function (self, state)
			if bit.band(self:value(state), self.mask) ~= 0 then
				return true
			end
			return false
		end
		fields[k] = tmp.of(pfarg)
	end
	tmp.fields = fields
	tmp.dissect = function(self, state)
		local infostr = ""
		local bn = state.bnet_node
		if self.big_endian then
			state.bnet_node = bn:add(self.pf, state:peek(self.size()))
		else
			state.bnet_node = bn:add_le(self.pf, state:peek(self.size()))
		end
		for k,v in pairs(self.fields) do
			local tail = state:tail()
			local block = { v }
			local active = v:active(tail)
			dissect_packet(tail, block)
			if v.sname and v.sname ~= "" and active then
				infostr = infostr .. v.sname .. ", "
			end
		end
		if infostr ~= "" then
			infostr = (string.gsub(infostr, "^(.*),%s*$", "%1"))
			state.bnet_node:append_text(" (" .. infostr .. ")")
		end
		state.bnet_node = bn
		state:read(self.size())
	end
	return tmp
end

