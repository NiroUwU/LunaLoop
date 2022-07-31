CommandList = {
	list = {}
}

local function add(Name, Desc, Type, Func)
	-- Case insensitive:
	Name = Name:lower()

	CommandList.list[Name] = {
		name = Name,
		desc = Desc,
		type = Type,
		fn = Func
	}
end
local commandType = {
	technical = "Technical",
	chat = "Chatting",
	social = "Social",
	math = "Math"
}


-- COMMAND LIST:

-- Technical:
add("info", "Displays info about the bot.", commandType.technical, function(Message, Caller, ...)
	local output = "Hi, I'm " .. info.name .. "\nI am a general-purpose bot, written in Lua!\n"
	local prefix = "My prefix is: " .. info.prefix
	local source = "Check out my source code: `" .. info.repository .. "`"

	output = output .. string.format("%s\n%s\n", prefix, source)
	Message.channel:send(output)
end)

add("help", "Displays a help message about all commands.", commandType.technical, function(Message, Caller, ...)
	local output = "Here is a list of all commands this I am capable of:"

	-- Sort by command types:
	local sorted = {}
	for i, v in pairs(CommandList.list) do
		if sorted[v.type] == nil then
			sorted[v.type] = {}
		end
		table.insert(sorted[v.type], v)
	end
	table.sort(sorted)

	-- Add one by one by types to output:
	for i, v in pairs(sorted) do
		output = output .. "\n**__" .. tostring(i) .. "__**:"

		-- Add each command to output:
		for _, l in pairs(v) do
			local cmd_name = "**" .. tostring(l.name) .. "**"
			local desc = "*" .. tostring(l.desc) .. "*"
			output = output .. "\n> " .. cmd_name .. "   " .. desc
		end
	end

	Message.channel:send(tostring(output))
end)

add("ping", "Pong! :D", commandType.technical, function(Message, Caller, ...)
	Message.channel:send("Pong! :ping_pong:")
end)

add("changelog", "Shows the changelog for the current or a specific version of the bot.", commandType.technical, function(Message, Caller, ...)
	local arg = ...
	local showVersion = ""
	bot.debug(tostring(arg))
	if #arg == 0 then
		showVersion = info.version
	else
		showVersion = arg[1]
	end

	if Changelog[showVersion] == nil then
		local tab = {}
		for i, v in pairs(Changelog) do
			table.insert(tab, i)
		end
		local list = table.concat(tab, ", ")

		Message.channel:send("The requested version '" .. showVersion .."' does not exist.\nPlease refer to one of these availabe options: *" .. list .. "*\nUsage: changelog [*optional:* specific_version]")
		return
	end

	Message.channel:send("__Changelog for version '" .. showVersion .. "':__\n\n" .. tostring(Changelog[showVersion]))
end)


-- Chatting:
add("echo", "I will echo back whatever you said to me.", commandType.chat, function(Message, Caller, ...)
	local tab = ...
	if #tab == 0 then
		Message.channel:send("You have to provide a string for me to echo back!\nUsage: echo [string]")
		return
	end
	local str = table.concat(tab, " ")

	Message.channel:send(Message.author.mentionString .. " said: '" .. str .. "'")
end)

add("hello", "Greet me, I greet you.", commandType.chat, function(Message, Caller, ...)
	Message.channel:send(HelloResponse[math.random(1, #HelloResponse)])
end)


-- Math:
add("flip", "Flip a coin.", commandType.math, function(Message, Caller, ...)
	local flip = ""
	if math.random(0, 9) < 5 then
		flip = "Heads"
	else
		flip = "Tails"
	end

	Message.channel:send(Message.author.mentionString .. " flipped a coin:\n**" .. flip .. "**")
end)

add("ynm", "Yes? No? Maybe? Ask me a question!", commandType.math, function(Message, Caller, ...)
	local args = ...
	local temp = string.format(YesNoMaybe.askMeSomethingPrompt, Message.author.mentionString)
	if args == nil then
		Message.channel:send(temp)
		return
	end
	if #args < 1 then
		Message.channel:send(temp)
		return
	end
	local vals = {}

	for i,v in pairs(YesNoMaybe.weight) do
		for _=0, v do
			table.insert(vals, i)
		end
	end

	local out = easy.string.firstUppercase(easy.table.randomIn(vals))
	Message.channel:send(string.format(YesNoMaybe.responsePrompt, out, Message.author.mentionString))
end)

add("pickrandom", "Pick a random word from a string input (seperated by spaces).", commandType.math, function(Message, Caller, ...)
	local args = ...
	local usage = "\nUsage: pickrandom option1 option2 option3 long_option_four option.5 ( -> randomly chosen)"

	local function handleErrorMessage(txt, ...)
		Message.channel:send(string.format(txt, ...) .. usage)
	end
	if args == nil then
		handleErrorMessage("Please provide a string from which words can be randomly picked.")
		return
	end
	if #args < 1 then
		handleErrorMessage("Please provide a string from which words can be randomly picked.")
		return
	end

	local pick = easy.table.randomIn(args)
	Message.channel:send("Your randomly chosen word is:\n**" .. pick .. "**")
end)

add("checklove", "Check the love value between two members.", commandType.math, function(Message, Caller, ...)
	local mentioned = Message.mentionedUsers
	local usage = "\nUsage: checklove @FirstMember @SecondMember"
	if #mentioned < 2 then
		Message.channel:send("You need to provide two users as input!" .. usage)
		return
	end

	-- Member IDs:
	mentioned = {mentioned[1][1], mentioned[1][2]}

	local percentage = (mentioned[1]%1000 + mentioned[2]%1000) % 101
	Message.channel:send(string.format("%s x %s = %d%s", "<@"..mentioned[1]..">", "<@"..mentioned[2]..">", percentage, "%"))
end)

add("checktruth", "Check the truth-value of a given statement.", commandType.math, function(Message, Caller, ...)
	local args = ...
	local usage = "\nUsage: checktruth This String Will Be Evaluated For The Truth Value"
	local function handleErrorMessage(txt, ...)
		Message.channel:send(string.format(txt, ...) .. usage)
	end

	-- Check if string provided:
	if args == nil then
		handleErrorMessage("Faulty Syntax. You need to provide a string to evaluate after the command name!")
		return
	end
	if #args < 1 then
		handleErrorMessage("Faulty Syntax. You need to provide a string to evaluate after the command name!")
		return
	end

	local fullString = table.concat(args, " ")
	local fullEncoded = base64.encode(tostring(fullString))
	local percentage = 0

	-- Emergency Break-Out:
	if fullEncoded == nil then
		Message.channel:send("There was an error calculating the truth value...")
		return
	end

	-- Calculate Percentage:
	for i=1, #fullEncoded do
		local char = string.sub(fullEncoded, i, i)
		percentage = percentage + string.byte(char)
	end
	percentage = percentage % 101

	Message.channel:send(string.format("The truth value for... `%s`... is %d%s!", fullString, percentage, "%"))
end)

add("roll", "Roll a die. (Supports `roll int int` and `roll string`(-> String: '2d6', '4d20') )", commandType.math, function(Message, Caller, ...)
	local arg = ...
	local default = "1d6"
	local roll = default
	local maxRolls = 100

	-- Set roll to custom XdY string:
	if arg[1] ~= nil and arg[2] == nil then
		roll = tostring(arg[1]):lower()
	end
	if arg[1] ~= nil and arg[2] ~= nil then
		roll = tostring(arg[1]) .. "d" .. tostring(arg[2])
	end

	-- Seperate t and d from string:
	local usage = "Usage: roll 2d6 (-> rolls a 6-sided die two times)\nUsage: roll 2 6"
	local seperator = string.find(roll, "d")
	if seperator == nil then
		Message.channel:send("Faulty Syntax. Make sure you provide two integers!\n" .. usage)
		return
	end
	local t_, d_ = string.sub(roll, 1, seperator-1), string.sub(roll, seperator+1, #roll)

	-- Check for t and d being numbers and error message if not:
	local t, d = tonumber(t_), tonumber(d_)
	if t == nil or d == nil then
		Message.channel:send("Faulty Syntax. Make sure you provide two integers!\n" .. usage)
		return
	end
	if t < 1 or d < 1 then
		Message.channel:send("Faulty Syntax. Make sure you provide positive numbers!\n" .. usage)
		return
	end
	t, d = math.ceil(t), math.ceil(d)

	-- Roll dice and send to output:
	local output = ""

	-- Make d not more than maxRolls:
	if t > maxRolls then t = maxRolls output = output .. string.format("Maximum rolls are limited to %d!\n\n", t) end
	local rolls = {}
	for i=1, t do
		local newRoll = math.random(1, d)
		table.insert(rolls, newRoll)
	end

	local stats={
		sum = 0,
		concat = table.concat(rolls, ", "),
		average = 0
	}
	for i, v in pairs(rolls) do
		stats.sum = stats.sum + v
	end
	stats.average = stats.sum / t

	output = output .. string.format("**All rolls:** %s\n\n**Sum of all rolls:** %d\n**Average roll:** %d", stats.concat, stats.sum, stats.average)
	Message.channel:send(output)
end)

add("convert", "Convert units of measurement.", commandType.math, function(Message, Caller, ...)
	local args = ...
	-- Table of units: (base unit is valued as 1)
	local units = Units.list

	-- Error Handling:
	local usage = "Usage: convert 2 m cm ( -> 200cm)\nUsage: convert 2000 ml l ( -> 2l)\n\nPlease refer to the command `convert list` for a full list of units!"
	local list = "Full list of units:\n"
	for i,v in pairs(units) do
		local concat = {}
		for j,k in pairs(v) do
			table.insert(concat, j)
		end
		local cat_name = easy.string.firstUppercase(i)
		list = list .. "\n" .. cat_name .. ":\n> " .. table.concat(concat, ",  ")
	end
	local function handleErrorMessage(txt, ...)
		Message.channel:send(string.format(txt, ...) .. "\n" .. usage)
	end

	-- Arguments checked for existance:
	if args == nil then
		handleErrorMessage("You have to provide three arguments! (value, initial unit, goal unit)")
		return
	end
	if args[1] == "list" then
		Message.channel:send(list)
		return
	end
	local num, initial_unit, goal_unit = args[1], args[2], args[3]
	if num == nil or initial_unit == nil or goal_unit == nil then
		handleErrorMessage("Please make sure to provide three arguments! (value, initial unit, goal unit)")
		return
	end
	initial_unit = tostring(initial_unit):lower()
	goal_unit = tostring(goal_unit):lower()

	-- Check if number:
	num = tonumber(num)
	if num == nil then
		handleErrorMessage("You have to provide a number as first input to convert!")
		return
	end

	-- Check unit validity/compatibility:
	local a, b = nil, nil
	local vars = {}
	for category,v in pairs(units) do
		for u,var in pairs(v) do
			if u == initial_unit then
				a = category
				vars[1] = var
			end
			if u == goal_unit then
				b = category
				vars[2] = var
			end
		end
	end
	local notcat = "not a cetegory"
	if a == nil then a = notcat end
	if b == nil then b = notcat end
	if a ~= b or a == notcat or b == notcat then
		handleErrorMessage("Provided units '%s' (%s) and '%s' (%s), do not match categories!", initial_unit, a, goal_unit, b)
		return
	end

	-- Conversion of values:
	local multiplyer = vars[2] / vars[1]
	local out = num
	out = out / multiplyer

	-- Overwrite out with funky wunky weird temperature calculation (finally works, kill me):
	if a == 'temperature' then
		local C = Units.temp.convertToC(num, initial_unit)
		out = Units.temp.convertToX(C, goal_unit)
		if out == nil then
			Message.channel:send("There was an error converting values!")
			return
		end
	end

	Message.channel:send(string.format("Converted Value:\n" .. num .. " %s = " .. out .. " %s", initial_unit, goal_unit))
end)


-- Social:
local function handleSocialEvent(Message, Caller, type, textAction, emojis)
	-- Check if no members have been mentioned:
	if #Message.mentionedUsers == 0 then
		return string.format("You need to ping the person you want to %s!\nUsage: %s @AnotherUser", type, type)
	end

	local active = Message.author.mentionString
	local passive = Message.mentionedUsers["first"].mentionString
	local text = textAction .. " you"
	local emoji = emojis[1]
	local gifs = Gifs[type]
	local gif = easy.table.randomIn(gifs)

	-- User @'ed themselves:
	if active == passive then
		passive = active
		active = string.format("<@%s>", info.id)
		if emojis[2] ~= nil then
			emoji = emojis[2]
		end
	end

	-- Return the full string, ready to be sent:
	return string.format("%s %s %s! %s\n%s", active, text, passive, emoji, gif)
end

add("hug", "Hug another server member. :)", commandType.social, function(Message, Caller, ...)
	Message.channel:send(handleSocialEvent(
		Message, Caller,
		"hug", "hugged",
		{":)", ";) <3"}
	))
end)
add("pat", "Pat another server memeber. :D", commandType.social, function(Message, Caller, ...)
	Message.channel:send(handleSocialEvent(
		Message, Caller,
		"pat", "patted",
		{"-v-", "^v^"}
	))
end)
add("slap", "Slap another server member. >:(", commandType.social, function(Message, Caller, ...)
	Message.channel:send(handleSocialEvent(
		Message, Caller,
		"slap", "slapped",
		{">:(", ">:O"}
	))
end)
add("kiss", "Kiss another server member. :3", commandType.social, function(Message, Caller, ...)
	Message.channel:send(handleSocialEvent(
		Message, Caller,
		"kiss", "kissed",
		{":3", ";3 <3"}
	))
end)
add("boop", "Boop another server member. -v-", commandType.social, function(Message, Caller, ...)
	Message.channel:send(handleSocialEvent(
		Message, Caller,
		"boop", "booped",
		{":p", ";p"}
	))
end)


return CommandList
