easy = {
	table  = {},
	string = {},
	time   = {}
}

function easy.table.randomIn(tab)
	if type(tab) ~= "table" then
		bot.debug("randomIn() needs a table of contents!")
		return
	end

	local ranNum = math.random(1, #tab)
	return tab[ranNum], ranNum, #tab
end

function easy.string.firstUppercase(str, ...)
	str = string.format(str, ...)
	return (string.sub(str, 1, 1)):upper()..string.sub(str, 2, -1):lower()
end

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
