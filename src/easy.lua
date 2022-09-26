easy = {
	table  = {},
	string = {},
	number = {},
	time   = {}
}

-- Table:
function easy.table.randomIn(tab)
	if type(tab) ~= "table" then
		bot.debug("randomIn() needs a table of contents!")
		return
	end

	local ranNum = math.random(1, #tab)
	return tab[ranNum], ranNum, #tab
end

function easy.table.normalise(baseTable, valueTable)
	local out = {}
	local function doit(base, val)
		local temp = {}
		for i, bas in pairs(base) do
			local dat = val[i]
			if type(bas) == "table" then
				if type(dat) == "table" then
					temp[i] = doit(bas, dat)
				else
					temp[i] = bas
				end
			else
				temp[i] = dat or bas
			end
		end
		return temp
	end

	out = doit(baseTable, valueTable)
	return out
end

function easy.table.readCompactStrings(stringTable)
	local function concatAll(tab, prev)
		local tmp = {}
		for i,v in pairs(tab) do
			if type(v) == "table" then
				local tmp2 = concatAll(v, prev .. " " .. i)
				for _,k in pairs(tmp2) do
					table.insert(tmp, k)
				end
			elseif type(v) == "string" then
				local str = string.format("%s %s", prev, v)
				table.insert(tmp, str)
			end
		end
		return tmp
	end

	return concatAll(stringTable, "")
end

-- String:
function easy.string.firstUppercase(str, ...)
	str = string.format(str, ...)
	return (string.sub(str, 1, 1)):upper()..string.sub(str, 2, -1):lower()
end

easy.string.readCompact = easy.table.readCompactStrings


-- Number:
function easy.number.tointeger(num)
	num = tonumber(num)

	-- Attempt to convert to number:
	if num == nil then return nil end
	if tostring(num) == "nan" then return nil end

	-- Attempt to convert to integer:
	num = math.floor(num)
	if num == nil then return nil end

	-- Number is an integer:
	return num
end

function easy.number.forcetointeger(num, forced_value)
	-- Attempt to convert:
	num = easy.number.tointeger(num)

	-- Number is an integer:
	if num ~= nil then return num end

	-- Return forced value:
	if forced_value == nil then forced_value = 0 end
	return forced_value
end

-- Time:
function easy.time.format(seconds)
	local sec = tonumber(seconds)

	if sec == nil then
		bot.debug("Error formating time, expected number, got %s!", type(seconds))
		return string.format("[Error when formating time, raw seconds: %s]", tostring(seconds))
	end
	sec = math.floor(sec)

	local f = {}
	f.s = sec % 60
	f.m = math.floor(sec / 60) % 60
	f.h = math.floor(sec / 3600) % 24
	f.d = math.floor(sec / 86400)

	local out = {}
	local function t(num, char)
		if num == 0 then
			return
		end
		table.insert(out, string.format("%d%s", num, char))
	end
	t(f.d, "d") t(f.h, "h")
	t(f.m, "m") t(f.s, "s")
	return string.format("%s", table.concat(out, " "))
end

return easy
--[[local function overwrite(base, values)
		local temp = {}
		for i,v in pairs(base) do
			print("Doing:", i, v)
			if type(v) == "table" then
				print("Detected Table")
				if values[i] ~= nil then
					print("Recursion")
					table.insert(temp, overwrite(v, values[i]), i)
				else
					print("Direct write")
					base[i] = v
				end
			else
				print("Not a table")
				base[i] = values[i] or v
			end
		end
		return base
	end

	local out = {}
	table.insert(out, overwrite(baseTable, valueTable))
	return out]]