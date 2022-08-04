easy = {
	table  = {},
	string = {}
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

return easy
