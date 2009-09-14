-- Common value descriptions
local Descs = {
	-- Boolean values
	YesNo = {
		[1] = "Yes",
		[0] = "No",
	},
}

-- Common condition functions
local Cond = {
	equals = function(key, value)
		return function(self, state)
			return state.packet[key] == value
		end
	end,
}	
