CommandList = {
	list = {}
}

local function add(Name, Aliases, Desc, Type, Func)
	-- Case insensitive:
	Name = Name:lower()

	CommandList.list[Name] = {
		name = Name,
		aliases = Aliases,
		desc = Desc,
		type = Type,
		fn = Func
	}
end
local commandType = {
	admin = "Administrative",
	chat = "Chatting",
	goodies = "Goodies",
	math = "Math",
	social = "Social",
	technical = "Technical"
}

-- FUNCTIONS:
local function getErrorMessageEmbed(errorType, errormessage, usage)
	if errorType == nil or errorType == "" then
		errorType = ""
	else
		errorType = easy.string.firstUppercase(tostring(errorType)) .. " "
	end

	local temp = {
		title = errorType .. "Error",
		description = errormessage,
		color = Colours.embeds.error
	}
	if usage ~= nil then
		temp.footer = {
			text = "Usage:\n" .. usage
		}
	end
	return temp
end


-- Administrative:
add("setchannel", {"channelset", "channel", "set"}, "Set a channel to a specific function.", commandType.admin, function(Message, Caller, args, ...)
	local usage = "setchannel [function] [#Channel]\nsetchannel join-leave #welcome-messages"
	-- On server:
	if Message.member == nil then
		Message:reply { embed = getErrorMessageEmbed("Logical", "You have to execute this command as the owner on a server.", usage)}
		return
	end
	-- Owner:
	if Message.guild.ownerId ~= Message.author.id then
		Message:reply { embed = getErrorMessageEmbed("Permission", "Only the owner can run this command.", usage)}
		return
	end

	-- Check if channel type provided:
	if args == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You have to supply the channel type and channel id as arguments.", usage)}
		return
	end
	local channelType = args[1]
	if channelType == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You have to supply the channel type as first argument.", usage)}
		return
	end

	-- Check if channel type is valid:
	local pass = false
	local template = jsonfile.import(FileLocation.templates.server)
	if template == nil then
		local msg = string.format("Template file for servers was not found... :( Please [%s/issues](report this here), if it happens.", info.repository)
		Message:reply { embed = {"Internal", msg, usage}}
		return
	end
	if template["log-channels"] ~= nil then
		for i, v in pairs(template["log-channels"]) do
			print(i, v, pass, channelType)
			if i == channelType then pass = true end
		end
	end
	if pass == false then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "The channel type you have provided is invalid.", usage)}
		return
	end

	-- Check channel:
	local channel = {}
	if Message.mentionedChannels ~= nil then
		channel = Message.mentionedChannels["first"]
	else
	end

	local channelid = 0
	if channel.id ~= nil then channelid = channel.id end

	if channelid == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You have to mention a valid channel as your second argument.", usage)}
		return
	end

	-- Get and set channel:
	local file_location = string.format("%s/%s.json", FileLocation.storage.serverdirectory, Message.guild.id)
	local server = jsonfile.importarray(file_location, FileLocation.templates.server) --jsonfile.import(file_location) or jsonfile.import(FileLocation.templates.server) --or { ["log-channels"] = {}}
	if server == nil or server == {} then return end

	server["log-channels"][channelType] = channelid
	jsonfile.export(file_location, server)

	-- Confirmation message:
	local str = ""
	for i, v in pairs(server["log-channels"]) do
		local ch = "none"
		if v ~= 0 then ch = "<#" .. v .. ">" end
		str = string.format("%s%s: %s\n", str, i, ch)
	end
	Message:reply { embed = {
		title = "Server File Successfully Updated!",
		description = str,
		color = Colours.embeds.success
	}}
end)


-- Goodies:
add("balance", {"bal", "display-balance", "displaybalance"}, "Show your goody balance.", commandType.goodies, function(Message, Caller, args, ...)
	local target = Message.author
	if Message.mentionedUsers ~= nil then
		if Message.mentionedUsers["first"] ~= nil then target = Message.mentionedUsers["first"] end
	end

	local bal = Goodies:getBalance(target.id)
	Message:reply { embed = {
		author = {
			name = string.format("%s", target.username),
			icon_url = target.avatarURL
		},
		title = string.format("Balance: %s", tostring(bal)),
		footer = {
			text = string.format("ID: %s", target.id)
		},
		color = Colours.embeds.default
	}}
end)

add("transfer", {"pay", "givegoodies", "give-goodies"}, "Transfer goodies to a server member.", commandType.goodies, function(Message, Caller, args, ...)
	local usage = "transfer [integer] @AnotherUser"
	local target = nil
	if Message.mentionedUsers ~= nil then
		if Message.mentionedUsers["first"] ~= nil then
			target = Message.mentionedUsers["first"]
		end
	end

	-- Check Target:
	if target == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You have to specify another user to transfer goodies to!", usage)}
		return
	end
	if target.id == Message.author.id then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You have to specify another user to transfer goodies to!", usage)}
		return
	end

	-- Check valididty of transfer amount:
	local amount = args[1]
	if amount == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You have to specify an amount to transfer as your first argument.", usage)}
		return
	end
	amount = tonumber(amount)
	if amount == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You have to provide an integer value to transfer.", usage)}
		return
	end
	if amount < 1 then
		Message:reply { embed = getErrorMessageEmbed("Value", "You have to provide a positive integer as your transfer value.", usage)}
		return
	end
	if math.floor(amount) ~= amount then
		Message:reply { embed = getErrorMessageEmbed("Value", "You have to provide an integer.", usage)}
		return
	end

	-- Attempt Transfer:
	local successful, status = Goodies:modifyBalance(Message.author.id, amount * -1)
	if not successful then
		Message:reply { embed = getErrorMessageEmbed("Value", status, usage)}
		return
	end
	Goodies:modifyBalance(target.id, amount)

	-- Send confirmation embed:
	local f = string.format
	local desc = {
		f("Transaction of %s goodies successful.", tostring(amount)),
		f("%s's new balance: %s (-%s) goodies", Message.author.mentionString, Goodies:getBalance(Message.author.id), tostring(amount)),
		f("%s's new balance: %s (+%s) goodies", target.mentionString, Goodies:getBalance(target.id), tostring(amount))
	}
	Message:reply { embed = {
		title = "Transfer successful!",
		description = table.concat(desc, "\n"),
		color = Colours.embeds.success
	}}
end)

add("daily", {"bonus", "reward", "dailyreward"}, "Cash in your daily amounts of goodies", commandType.goodies, function(Message, Caller, args, ...)
	local userid = Message.author.id
	local users = jsonfile.import(FileLocation.storage.usersfile) or {}
	if users[userid] == nil then users[userid] = {} end
	if users[userid].lastdaily == nil then users[userid].lastdaily = 0 end

	local time_now = os.time()
	local time_old = users[userid].lastdaily

	-- Check Daily Time Left:
	local diff = time_now - time_old
	if diff < Config.goodies.daily.claim_interval_seconds then
		local till = easy.time.format(Config.goodies.daily.claim_interval_seconds - diff)
		local desc = string.format("You have to wait another **%s** till you can claim another daily reward.", till)
		Message:reply{ embed = getErrorMessageEmbed("Patience", desc)}
		return
	end

	-- Update Json List:
	users[userid].lastdaily = time_now
	jsonfile.export(FileLocation.storage.usersfile, users)

	-- Add to balance:
	Goodies:modifyBalance(userid, Config.goodies.daily.reward)
	Message:reply { embed = {
		title = "Daily reward claimed!",
		description = string.format("You have claimed your daily %s goodies. (Current Balance: %s)", tostring(Config.goodies.daily.reward), tostring(Goodies:getBalance(userid))),
		color = Colours.embeds.success
	}}
end)


-- Technical:
add("info", {"botinfo", "bot-info", "bot", "i"}, "Displays info about the bot.", commandType.technical, function(Message, Caller, args, ...)
	Message:reply { embed = InfoCommandData.getFullTable()}
end)

add("neofetch", {}, "Displays the systems neofetch command the bot is running on (Waring: Nerd Alert).", commandType.technical, function(Message, Caller, args, ...)
	local cmd = 'neofetch --color_blocks off | sed \'s/\x1B\\[[0-9;\\?]*[a-zA-Z]//g\''
	local neofetch = bash.execute("neofetch.temp", cmd)
	Message:reply(string.format("```\n%s\n```", neofetch))
end)

add("apple", {"testreaction", "test-reaction", "appletest", "apple-test"}, "Test reaction response, spoiler: it SHOULD work", commandType.technical, function(Message, Caller, args, ...)
	local emoji = "🍎"
	local secret_emoji = "🍏"
	local sentMessage = Message:reply { embed = {
		title = string.format("React with %s for funny :)", emoji)
	}}
	sentMessage:addReaction(emoji)

	local function response()
		bot.debug("Executing!")
		Message:reply { embed = {
			title = string.format("hehe %s", emoji)
		}}
	end
	local function responseSecret()
		bot.debug("Executing secret...")
		Message:reply { embed = {
			title = string.format("Bet you're really smart, aren't ya... %s", secret_emoji)
		}}
	end

	MessageReaction:add(sentMessage, {[emoji] = response, [secret_emoji] = responseSecret}, nil, Message.author.id, false, true)
end)

add("help", {"commands", "commandlist"}, "Displays a help message about all commands.", commandType.technical, function(Message, Caller, args, ...)
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

add("ping", {}, "Pong! :D", commandType.technical, function(Message, Caller, args, ...)
	Message:reply { embed = {
		title = "Pong! :ping_pong:",
		color = Colours.embeds.default
	}}
end)

add("changelog", {"changes", "whatsnew", "whatsnew?", "update", "updates"}, "Shows the changelog for the current or a specific version of the bot.", commandType.technical, function(Message, Caller, args, ...)
	local showVersion = ""
	bot.debug(tostring(args))
	if #args == 0 then
		showVersion = info.version
	else
		showVersion = args[1]
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
local function getEchoObject(Message, args)
	local tab = args
	local usage = "echo [string]"
	if #tab == 0 then
		local err = "Insufficient Arguments. You have to provide a string for me to echo back!"
		Message:reply { embed = getErrorMessageEmbed("Syntax", err, usage)}
		return
	end
	local str = table.concat(tab, " ")

	Message:reply { embed = {
		description = str,
		author = {
			name = Message.author.username,
			icon_url = Message.author.avatarURL,
			url = string.format("https://%s.id", Message.author.id)
		},
		color = Colours.embeds.default,
		footer = {
			text = Message.author.id
		}
	}}
end

add("echo", {"print", "say", "puts", "printf"}, "I will echo back whatever you said to me.", commandType.chat, function(Message, Caller, args, ...)
	Message:reply { embed = getEchoObject(Message, args)}
end)

add("echodel", {"echodelete", "echorem", "echoremove"}, "Echos back a message, and deletes the senders message.", commandType.chat, function(Message, Caller, args, ...)
	Message:reply { embed = getEchoObject(Message, args)}

	-- Delete message, if fails, send message about missing permissions:
	if not Message:delete() then
		Message:reply { embed = getErrorMessageEmbed("Permission", "The bot may not have permissions to delete messages.")}
	end
end)

add("hello", {"hi"}, "Greet me, and I greet you.", commandType.chat, function(Message, Caller, ...)
	Message:reply(HelloResponse[math.random(1, #HelloResponse)])
end)

add("profile", {"p"}, "Display a server member's profile.", commandType.chat, function(Message, Caller, args, ...)
	local mentioned = Message.mentionedUsers
	local usage = "profile @TargetUser"

	-- Check if the target user was mentioned:
	if #mentioned == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You have to mention a target user to get their profile information from.", usage)}
		return
	end

	local user = mentioned["first"]
	if not user then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "You have to mention a target user to get their profile information from.", usage)}
		return
	end

	if not Message.guild then
		Message:reply { embed = getErrorMessageEmbed("Usage", "Please make sure you are using this command in a server.", usage)}
		return
	end
	local member = Message.guild.members:get(user.id)
	local content = {
		{'Server Name', member.nickname or user.name},
		{'User ID', user.id},

		{'Highest Role', member.highestRole.mentionString},
		{'Number of Roles', #member.roles},

		{'Creation Date', os.date("%d. %B %Y", user.createdAt)},
		{'Join Date', member.joinedAt}
	}
	local outString = ""
	for _,v in pairs(content) do
		outString = outString .. string.format("\n**%s:**   %s", v[1], v[2])
	end

	-- Add emojis:
	local emoji = " "
	if Message.guild.owner == member then
		emoji = emoji .. ":crown:"
	end
	if user.bot then
		emoji = emoji .. ":robot:"
	end
	if member.premiumSince then
		emoji = emoji .. ":rocket:"
	end

	-- Colour:
	local colour = member.highestRole.color
	if colour == 0 then
		colour = Colours.embeds.default
	end

	-- Activity:
	local statusTable = {
		['unknown'] = ":grey_question:",

		['streaming'] = ":purple_circle:",
		['phone'] = ":mobile_phone:",

		['online'] = ":green_circle:",
		['offline'] = ":black_circle:",
		['idle'] = ":crescent_moon:",
		['dnd'] = ":red_circle:"
	}
	local status = statusTable[member.status] or statusTable['unknown']

	Message:reply { embed = {
		title = status .. " User Profile for " .. user.tag .. emoji,
		description = outString,
		thumbnail = {
			url = user.avatarURL
		},
		color = colour
	}}
end)


-- Math:
add("flip", {"coin"}, "Flip a coin.", commandType.math, function(Message, Caller, ...)
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

add("ynm", {"yn", "yesno", "yesorno"}, "Yes? No? Maybe? Ask me a question!", commandType.math, function(Message, Caller, args, ...)
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

add("pickrandom", {"randomword", "pickword"}, "Pick a random word from a string input (seperated by spaces).", commandType.math, function(Message, Caller, args, ...)
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

add("checklove", {"love-o-meter", "love"}, "Check the love value between two members.", commandType.math, function(Message, Caller, args, ...)
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

add("checktruth", {"truth-o-meter", "true", "thruth"}, "Check the truth-value of a given statement.", commandType.math, function(Message, Caller, args, ...)
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
		description = string.format("The truth value for... `%s`... is **%s**!", fullString, out),
		color = Colours.embeds.default
	}}
end)

add("roll", {"die", "dice"}, "Roll a die. (Supports `roll int int` and `roll string`(-> String: '2d6', '4d20') )", commandType.math, function(Message, Caller, args, ...)
	local default = "1d6"
	local roll = default
	local maxRolls = 100

	-- Set roll to custom XdY string:
	if args[1] ~= nil and args[2] == nil then
		roll = tostring(args[1]):lower()
	end
	if args[1] ~= nil and args[2] ~= nil then
		roll = tostring(args[1]) .. "d" .. tostring(args[2])
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
		warning = string.format("Maximum rolls are limited to %d!\n", maxRolls)
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

	output = output .. string.format("\n**All rolls:** %s\n\n**Sum of all rolls:** %d\n**Average roll:** %d", stats.concat, stats.sum, stats.average)
	if not (Message:reply { embed = {
		title = "Die Roll",
		description = string.format(warning .. "__You rolled a %d-sided die %d times! Here are your results:__\n\n%s", d, t, tostring(stats.concat)),
		fields = {
			{
				name = "__Average Sides:__",
				value = tostring(stats.average),
				inline = true
			},
			{
				name = "__Sum of all Sides:__",
				value = tostring(stats.sum),
				inline = true
			}
		},
		color = Colours.embeds.default
	}}) then
		Message:reply("Embed message could not be sent, contained too many characters?")
		--Message.channel:send(output)
	end
end)

add("convert", {"unitconvert", "unit", "wtfis", "wtf-is"}, "Convert units of measurement.", commandType.math, function(Message, Caller, args, ...)
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
	local gifInfo = { id = 0, total = 0}
	local gif = nil
	gif, gifInfo.id, gifInfo.total = easy.table.randomIn(gifs)

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
		title = easy.string.firstUppercase("You have been %s!", textAction),
		description = string.format("%s %s %s! %s", active, text, passive, emoji),
		image = {
			url = gif
		},
		footer = {
			text = string.format("gif id: %d (out of %d)", gifInfo.id, gifInfo.total)
		},
		color = Colours.list.pink
	}}
end

add("hug", {}, "Hug another server member. :)", commandType.social, function(Message, Caller, args, ...)
	handleSocialEvent(
		Message, Caller,
		"hug", "hugged",
		{":)", ";) <3"}
	)
end)
add("pat", {"pet"}, "Pat another server memeber. :D", commandType.social, function(Message, Caller, args, ...)
	handleSocialEvent(
		Message, Caller,
		"pat", "patted",
		{"-v-", "^v^"}
	)
end)
add("slap", {"punch", "hit"}, "Slap another server member. >:(", commandType.social, function(Message, Caller, args, ...)
	handleSocialEvent(
		Message, Caller,
		"slap", "slapped",
		{">:(", ">:O"}
	)
end)
add("kiss", {"smooch"}, "Kiss another server member. :3", commandType.social, function(Message, Caller, args, ...)
	handleSocialEvent(
		Message, Caller,
		"kiss", "kissed",
		{":3", ";3 <3"}
	)
end)
add("boop", {"nose-boop"}, "Boop another server member. -v-", commandType.social, function(Message, Caller, args, ...)
	handleSocialEvent(
		Message, Caller,
		"boop", "booped",
		{":p", ";p"}
	)
end)

add("date", {"askout", "ask-out", "askdate", "ask-date"}, "Date a server member o///o", commandType.social, function(Message, Caller, args, ...)
	local mentioned = Message.mentionedUsers
	local usage = "date @AnotherUser"
	if mentioned == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "Make sure to ping a different user you want to ask out.", usage)}
		return
	end

	local targetUser = mentioned['first']
	if targetUser == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "Make sure to ping a different user you want to ask out.", usage)}
		return
	end

	if targetUser.id == Message.author.id then
		Message:reply { embed = {
			title = "Damn...",
			description = "Let me give you a hug... <3",
			image = {
				url = easy.table.randomIn(Gifs.hug) or "",
			},
			color = Colours.embeds.error,
			footer = {
				text = usage
			}
		}}
		return
	end

	local emoji = { accept = "❤️", refuse = "💔" }
	local date_msg = Message:reply { embed = {
		title = "You have been asked out!",
		description = string.format("%s asked out %s!\nReact with %s to accept or %s to refuse.", Message.author.mentionString, targetUser.mentionString, emoji.accept, emoji.refuse),
		color = Colours.embeds.notice
	}}

	local function dateAccept()
		Message:reply { embed = {
			title = Dating:getTitle("success"),
			description = Dating:getDescription(Message.author, targetUser),
			color = Colours.embeds.default
		}}
	end
	local function dateRefuse()
		Message:reply { embed = {
			title = Dating:getTitle("failed"),
			description = string.format("%s refused the date invitation of %s.", targetUser.mentionString, Message.author.mentionString),
			color = Colours.embeds.error
		}}
	end

	if date_msg then
		date_msg:addReaction(emoji.accept)
		date_msg:addReaction(emoji.refuse)
		MessageReaction:add(date_msg, {[emoji.accept] = dateAccept, [emoji.refuse] = dateRefuse}, nil, targetUser.id, false, true)
	else
		Message:reply { embed = getErrorMessageEmbed("Internal", "The bot ran into an issue, please try again later...", usage)}
	end
end)

add("rps", {"rock-paper-scissors", "rockpaperscissors"},  "Play rock, paper, scissors against the bot!", commandType.social, function(Message, Caller, args, ...)
	local emojis = {"🪨", "📄", "✂️"}
	local usage = "rps"

	local msg = Message:reply { embed = {
		title = "Rock Paper Scissors",
		description = Message.author.mentionString .. ", react with the following emojis to this message to choose your pick:\n" .. table.concat(emojis, " / "),
		color = Colours.embeds.lighter
	}}

	local function reactionResponse(userPick, emojisTable)
		local botPick = easy.table.randomIn(emojisTable)
		local function sendResult(playerWinStatus)
			local cols = {
				['won'] = Colours.embeds.success,
				['drawed'] = Colours.embeds.notice,
				['lost'] = Colours.embeds.error
			}
			Message:reply { embed = {
				title = string.format("You %s!", playerWinStatus),
				description = string.format("I picked %s and %s picked %s.", botPick, Message.author.mentionString, userPick),
				color = cols[playerWinStatus] or Colours.embeds.default
			}}
		end

		-- Draw:
		if userPick == botPick then
			sendResult("drawed")
			return
		end

		-- Rock:
		if userPick == emojis[1] then
			if botPick == emojis[2] then
				sendResult("lost")
			else
				sendResult("won")
			end
			return
		end

		-- Paper:
		if userPick == emojis[2] then
			if botPick == emojis[3] then
				sendResult("lost")
			else
				sendResult("won")
			end
			return
		end

		-- Scissors:
		if userPick == emojis[3] then
			if botPick == emojis[1] then
				sendResult("lost")
			else
				sendResult("won")
			end
			return
		end
	end

	local successTable = {
		[emojis[1]] = function() reactionResponse(emojis[1], emojis) end,
		[emojis[2]] = function() reactionResponse(emojis[2], emojis) end,
		[emojis[3]] = function() reactionResponse(emojis[3], emojis) end
	}

	if msg then
		-- Add listener for message reactions:
		MessageReaction:add(msg, successTable, nil, Message.author.id, false, true)

		-- Add emoji reactions:
		for _,v in pairs(emojis) do
			msg:addReaction(v)
		end
	else
		Message:reply { embed = getErrorMessageEmbed("Internal", "The bot ran into an issue, please try again later...", usage)}
	end
end)


return CommandList
