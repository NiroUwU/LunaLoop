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

-- FUNCTIONS:
local function getErrorMessageEmbed(errorType, errormessage, usage)
	if errorType == nil or errorType == "" then
		errorType = ""
	else
		errorType = easy.string.firstUppercase(tostring(errorType)) .. " "
	end
	return {
		title = errorType .. "Error",
		description = errormessage,
		footer = {
			text = "Usage:\n" .. usage
		},
		color = Colours.embeds.error
	}
end


-- COMMAND LIST:

-- Technical:
add("info", "Displays info about the bot.", commandType.technical, function(Message, Caller, ...)
	Message:reply { embed = InfoCommandData.getFullTable()}
end)

add("help", "Displays a help message about all commands.", commandType.technical, function(Message, Caller, ...)
	local sorted = {}
	for i, v in pairs(CommandList.list) do
		-- Create new Category if not existant:
		if sorted[v.type] == nil then
			sorted[v.type] = {}
		end

		-- Add command to category:
		table.insert(sorted[v.type], v)
	end
	table.sort(sorted)

	local finalFields = {}
	for category, cmds in pairs(sorted) do
		local newField = {
			name = easy.string.firstUppercase(category),
			value = "",
			inline = false
		}
		for _, cmd in pairs(cmds) do
			newField.value = newField.value .. string.format("\n**%s** - *%s*", cmd.name, cmd.desc)
		end
		table.insert(finalFields, newField)
	end

	Message:reply { embed = {
		title = "Command List",
		description = "This is a list of all commands I am capable of!",
		fields = finalFields,
		color = Colours.embeds.default
	}}
end)

add("ping", "Pong! :D", commandType.technical, function(Message, Caller, ...)
	Message:reply { embed = {
		title = "Pong! :ping_pong:",
		color = Colours.embeds.default
	}}
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

		-- Version could not be found:
		local err = "Version '" .. showVersion .. "' does not exist.\n"
		err = err .. "Please refer to one of these availabe options: (current version is: '**" .. info.version .. "**')\n" .. list
		Message:reply { embed = getErrorMessageEmbed(nil, err, "changelog [*optional:* specific_version]")}
		return
	end

	Message:reply { embed = {
		title = "Changelog for version " .. showVersion,
		description = tostring(Changelog[showVersion]),
		color = Colours.embeds.default
	}}
end)


-- Chatting:
add("echo", "I will echo back whatever you said to me.", commandType.chat, function(Message, Caller, ...)
	local tab = ...
	if #tab == 0 then
		local err = "Insufficient Arguments. You have to provide a string for me to echo back!"
		Message:reply { embed = getErrorMessageEmbed("Syntax", err, "echo [string]")}
		return
	end
	local str = table.concat(tab, " ")

	Message:reply { embed = {
		description = str,
		author = {
			name = Message.author.username,
			icon_url = Message.author.avatarURL
		},
		color = Colours.embeds.default
	}}
end)

add("hello", "Greet me, I greet you.", commandType.chat, function(Message, Caller, ...)
	--[[
	Message:reply { embed = {
		title = HelloResponse[math.random(1, #HelloResponse)],
		color = Colours.embeds.default
	}}
	]]
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

	Message:reply { embed = {
		title = "Coin Flip!",
		description = Message.author.mentionString .. " got **" .. flip .. "**!",
		color = Colours.embeds.default
	}}
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

	local function throwError()
		local err = "Please provide a string from which words can be randomly picked."
		local usage = "pickrandom option1 option2 option3 long_option_four option.5 (-> randomly chosen)"
		Message:reply { embed = getErrorMessageEmbed("Syntax", err, usage)}
	end
	if args == nil then
		throwError()
		return
	end
	if #args < 1 then
		throwError()
		return
	end

	local pick = easy.table.randomIn(args)
	Message:reply { embed = {
		title = "Random Word Choice",
		description = "Your randomly chosen word is:  **" .. pick .. "** !",
		color = Colours.embeds.default
	}}
end)

add("checklove", "Check the love value between two members.", commandType.math, function(Message, Caller, ...)
	local mentioned = Message.mentionedUsers
	local usage = "checklove @FirstMember @SecondMember"
	if #mentioned < 2 then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You need to provide two users as input!", usage)}
		return
	end

	-- Member IDs:
	mentioned = {mentioned[1][1], mentioned[1][2]}

	local percentage = tostring((mentioned[1]%1000 + mentioned[2]%1000) % 101) .. "%"
	local user1 = "<@"..mentioned[1]..">"
	local user2 = "<@"..mentioned[2]..">"
	Message:reply { embed = {
		title = "Love check",
		description = string.format("%s :two_hearts: %s = %s", user1, user2, percentage),
		color = Colours.list.pink
	}}
end)

add("checktruth", "Check the truth-value of a given statement.", commandType.math, function(Message, Caller, ...)
	local args = ...
	local usage = "checktruth This String Will Be Evaluated For The Truth Value"

	local function handleErrorMessage(txt, ...)
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You need to provide a string to evaluate after the command name!", usage)}
	end

	-- Check if string provided:
	if args == nil then
		handleErrorMessage()
		return
	end
	if #args < 1 then
		handleErrorMessage()
		return
	end

	local fullString = table.concat(args, " ")
	local fullEncoded = base64.encode(tostring(fullString))
	local percentage = 0

	-- Emergency Break-Out:
	if fullEncoded == nil then
		Message:reply { embed = getErrorMessageEmbed("Internal", "There was an error calculating the truth value...", usage)}
		return
	end

	-- Calculate Percentage:
	for i=1, #fullEncoded do
		local char = string.sub(fullEncoded, i, i)
		percentage = percentage + string.byte(char)
	end
	percentage = percentage % 101

	local out = tostring(percentage % 101) .. "%"
	Message:reply { embed = {
		title = "Truth check",
		description = string.format("The truth value for... `%s`... is **%s**!", fullString, out)
	}}
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
	local usage = "Uroll 2d6 (-> rolls a 6-sided die two times)\nroll 2 6"
	local seperator = string.find(roll, "d")
	if seperator == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "Make sure you provide two integers!", usage)}
		return
	end
	local t_, d_ = string.sub(roll, 1, seperator-1), string.sub(roll, seperator+1, #roll)

	-- Check for t and d being numbers and error message if not:
	local t, d = tonumber(t_), tonumber(d_)
	if t == nil or d == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "Make sure you provide two integers!", usage)}
		return
	end
	if t < 1 or d < 1 then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "Make sure you provide only positive numbers!", usage)}
		return
	end
	t, d = math.ceil(t), math.ceil(d)

	-- Roll dice and send to output:
	local output = ""

	-- Make d not more than maxRolls:
	local warning = ""
	if t > maxRolls then
		warning = string.format("Maximum rolls are limited to %d!\n\n", maxRolls)
		t = maxRolls output = output .. warning
	end
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
	if not (Message:reply { embed = {
		title = "Die Roll",
		description = string.format(warning .. "You rolled a %d-sided die %d times! Here are your results:", d, t),
		fields = {
			{
				name = "__Average Sides:__",
				value = tostring(stats.average),
				inline = false
			},
			{
				name = "__Sum of all Sides:__",
				value = tostring(stats.sum),
				inline = false
			},
			{
				name = "__All rolls:__",
				value = tostring(stats.concat),
				inline = false
			}
		},
		color = Colours.embeds.default
	}}) then
		Message:reply("Embed message could not be sent, contained too many characters?")
		Message.channel:send(output)
	end
end)

add("convert", "Convert units of measurement.", commandType.math, function(Message, Caller, ...)
	local args = ...
	-- Table of units: (base unit is valued as 1)
	local units = Units.list

	-- Error Handling:
	local usage = "convert 2 m cm ( -> 200cm)\nconvert 2000 ml l ( -> 2l)\n\nPlease refer to the command 'convert list' for a full list of units!"
	local list = {}
	for i,v in pairs(units) do
		local temp = {
			name = easy.string.firstUppercase(i),
			value = "",
			inline = false
		}
		local concat = {}
		for j,_ in pairs(v) do
			table.insert(concat, j)
		end
		temp.value = table.concat(concat, ",  ")
		table.insert(list, temp)
	end
	local function handleErrorMessage(txt, ...)
		Message:reply { embed = getErrorMessageEmbed("Syntax", string.format(txt,...), usage)}
		--Message.channel:send(string.format(txt, ...) .. "\n" .. usage)
	end

	-- Check if arguments exist:
	if args == nil then
		handleErrorMessage("You have to provide three arguments! (value, initial unit, goal unit)")
		return
	end

	-- Display unit list:
	if args[1] == "list" then
		Message:reply { embed = {
			title = "Unit conversion list",
			description = "This is a list of all available units and categories:",
			fields = list,
			color = Colours.embeds.default
		}}
		return
	end

	-- Check if all three arguments are present
	local num, initial_unit, goal_unit = args[1], args[2], args[3]
	if num == nil or initial_unit == nil or goal_unit == nil then
		handleErrorMessage("Please make sure to provide three arguments! (value, initial unit, goal unit)")
		return
	end
	initial_unit = tostring(initial_unit):lower()
	goal_unit = tostring(goal_unit):lower()

	-- Check if args[1] is number:
	num = tonumber(num)
	if num == nil then
		handleErrorMessage("You have to provide a number as first input to convert!")
		return
	end

	-- Check unit validity/compatibility of units:
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
	local notcat = "not a category"
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
		-- Check if conversion was successful:
		if out == nil then
			Message:reply { embed = getErrorMessageEmbed("Internal", "There was an error converting values!", usage)}
			return
		end
	end

	Message:reply { embed = {
		title = "Unit conversion",
		description = string.format("Converted Value:\n" .. num .. " %s = **" .. out .. "** %s", initial_unit, goal_unit),
		color = Colours.embeds.default
	}}
end)


-- Social:
local function handleSocialEvent(Message, Caller, type, textAction, emojis)
	-- Check if no members have been mentioned:
	if #Message.mentionedUsers == 0 then
		local err = string.format("You need to ping the person you want to %s!", type)
		local usage = string.format("%s @AnotherUser", type)

		Message:reply { embed = getErrorMessageEmbed("Syntax", err, usage)}
		return
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
	Message:reply { embed = {
		title = easy.string.firstUppercase("Someone has been " .. textAction),
		description = string.format("%s %s %s! %s", active, text, passive, emoji),
		image = {
			url = gif
		},
		color = Colours.list.pink
	}}
end

add("hug", "Hug another server member. :)", commandType.social, function(Message, Caller, ...)
	handleSocialEvent(
		Message, Caller,
		"hug", "hugged",
		{":)", ";) <3"}
	)
end)
add("pat", "Pat another server memeber. :D", commandType.social, function(Message, Caller, ...)
	handleSocialEvent(
		Message, Caller,
		"pat", "patted",
		{"-v-", "^v^"}
	)
end)
add("slap", "Slap another server member. >:(", commandType.social, function(Message, Caller, ...)
	handleSocialEvent(
		Message, Caller,
		"slap", "slapped",
		{">:(", ">:O"}
	)
end)
add("kiss", "Kiss another server member. :3", commandType.social, function(Message, Caller, ...)
	handleSocialEvent(
		Message, Caller,
		"kiss", "kissed",
		{":3", ";3 <3"}
	)
end)
add("boop", "Boop another server member. -v-", commandType.social, function(Message, Caller, ...)
	handleSocialEvent(
		Message, Caller,
		"boop", "booped",
		{":p", ";p"}
	)
end)


return CommandList
