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
do
	local template = {
		size = function(...) return 8 end,
		protofield_type = "string",
		dissect = function(self, state)
			local size = self.size(state:tvb())
			local node = state.bnet_node:add(self.pf, state:peek(8), "")
			-- POSIX epoch filetime
			local epoch = 0xd53e8000 + (0x100000000 * 0x019db1de)
			-- Read filetime
			local filetime = state:read(4):le_uint()
				+ (0x100000000 * state:read(4):le_uint())
			-- Convert to POSIX time if possible
			if filetime > epoch then
				-- Append text form of date to the node label.
				node:append_text(os.date("%c", (filetime - epoch) * 1E-7))
			end
		end,
	}

	function wintime(...)
		local args = make_args_table_with_positional_map(
				{"label"}, unpack(arg))

		return create_proto_field(template, args)
	end
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
do
	local template = {
		size = function(...) return 4 end,
		protofield_type = "string",
		dissect = function(self, state)
			local node = state.bnet_node:add(self.pf, state:peek(4), "")
			local unixtime = os.date("%c", state:read(4):le_uint())
			-- Append text form of date to the node label.
			node:append_text(unixtime)
		end,
		value = function (self, state) return state:peek(4):uint() end,

	}

	function posixtime(...)
		local args = make_args_table_with_positional_map(
				{"label"}, unpack(arg))

		return create_proto_field(template, args)
	end
end

