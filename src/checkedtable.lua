do
	--
	-- CheckedTable
	--
	-- Metatable that implements the metamethods required for verifying
	-- that a field is defined before it may be succesfully read.
	--
	-- ChackedTable may be used as the metatable of any amount of tables
	-- at a time.
	--
	local CheckedTable = {
		--
		-- Maps a table for which CheckedTable is it's metatable to a string
		-- that is used to refer to the table when reporting error.
		--
		-- The default value is 'thing'.
		--
		tableType = setmetatable({}, {
			__mode = "k",
			__index = function () return "'thing'" end }),
		--
		-- Maps a table for which CheckedTable is it's metatable to the set
		-- of fields that are declared.
		--
		declaredNames = setmetatable({}, {
			__mode = "k",
			__index = function () return {} end } ), 
	}

	--
	-- A table will be read only while it's guarded by CheckedTable.
	-- No new field may be created.
	--
	function CheckedTable.__newindex (t, n, v)
		error("attempt to write to a new field '"..n.."' in a read only table.", 2)
	end

	--
	-- A table will not allow reading from non existant fields while it's
	-- guarded by CheckedTable.
	--
	function CheckedTable.__index (t, n)
		error("attempt to read undeclared "
			.. CheckedTable.tableType[t]
			.. ": " .. n, 2)
	end

	--
	-- Make CheckedTable guard table @t.
	--
	function CheckedTable.guard (self, t, description)
		for k, _ in pairs(t) do
			self.declaredNames[t][k] = true
		end

		if description then
			self.tableType[t] = description
		end

		setmetatable(t, self)
	end

	--
	-- Protect valuemaps.lua tables.
	--
	CheckedTable:guard(Descs, "value description")
	CheckedTable:guard(Cond, "condition function")
end

