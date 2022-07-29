Switch = {}
default = "DEFAULT_SWITCH_VALUE"

function Switch.switch(val, cases)
	-- Loop through cases and execute, return if found:
	for i, v in pairs(cases) do
		if val == i then
			v()
			return
		end
	end

	-- Check if default case is given:
	if not cases[default] then
		return
	end
	
	-- Run default statement:
	cases[default]()
end

return Switch
