bot = {
	isdebug = false,
	time = {},
	user = {}
}

-- Debug text output:
function bot.debug(text, ...)
	local out = string.format(text, ...)
	print(" :: DEBUG: " .. out)
	bot.log(out)
end

-- Write Bot logs:
function bot.log(txt)
	local logs = io.open(Filesystem.logs .. "/bot.log", "a+")
	if logs == nil then return end

	local out = string.format("%s: %s\n", os.date(), txt)
	logs:write(out)
	logs:close()
end

-- Global sleep function:
function bot.sleep(time)
	if time == nil then
		bot.debug("Sleep time was not set, exiting.")
		return
	end
	time = tonumber(time)
	if time == nil then
		bot.debug("Sleep function expected number, got %s", type(time))
		return
	end

	os.execute("sleep " .. time)
end

-- Bot uptime functions:
bot.time.startup = 0

function bot.time.setStartup()
	bot.time.startup = os.time()
end

function bot.time.getUptimeSeconds()
	if bot.time.startup == nil then
		bot.debug("Bot startup time was not specified!")
		return 0
	end

	local up_seconds = os.time() - bot.time.startup
	return up_seconds
end

function bot.time.getUptimeFormated()
	local rawS = bot.time.getUptimeSeconds()
	local f = {}
	f.s = rawS % 60
	f.m = math.floor(rawS / 60) % 60
	f.h = math.floor(rawS / 3600) % 24
	f.d = math.floor(rawS / 86400)

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

return bot
