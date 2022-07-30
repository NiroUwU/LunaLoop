easy = {
	table  = {},
	string = {}
}

function easy.table.randomIn(tab)
	if type(tab) ~= "table" then
		bot.debug("randomIn() needs a table of contents!")
		return
	end

	return tab[math.random(1, #tab)]
end

function easy.string.firstUppercase(str)
	return (string.sub(str, 1, 1)):upper()..string.sub(str, 2, -1):lower()
end

return easy
