easy = {}

function easy.randomIn(tab)
	if type(tab) ~= "table" then
		bot.debug("easy.randomIn needs a table of contents!")
		return
	end

	return tab[math.random(1, #tab)]
end

return easy
