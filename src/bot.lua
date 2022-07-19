bot = {
	isdebug = false
}

function bot.debug(text, ...)
	print(" :: DEBUG: " .. string.format(text, ...))
end

return bot