-- SETUP:

-- Variables:
Discord = require "discordia"
Client = Discord.Client()

require "import"
bot.isDebug = true
switch = Switch.switch

-- Functions:
local function attemptCommandExecution(Message, commandString, args)
	for i, v in pairs(CommandList.list) do
		if i == commandString then
			bot.debug("Executing command '%s'!", commandString)

			--if args ~= nil then
				table.remove(args, 1)
			--end
			v.fn(Message, Message.member, args)
			return
		end
	end
	bot.debug("Command '%s' was not found!", commandString)
end

local function findMessageSubstring(Message, Caller, messageData, ...)
	local actions = {}
	print(#ReactionList)
	-- Add reactions in message:
	for i,v in pairs(ReactionList) do
		for j,k in pairs(v.trigger) do
			print(j .. k)
			if string.gmatch(Message.content, k) then
				table.insert(actions, v)
				bot.debug("Reaction ID '%s' is queued for execution!", v.id)
			end
		end
	end

	-- Execute reaction behaviour:
	for i,v in pairs(actions) do
		if v.reactionType == "reply" then
			v.reply(Message, Caller, messageData, ...)
		end
		if v.reactionType == "reaction" then
			v.react(Message, Caller, messageData, ...)
		end
	end
end

local function updateProfile()
	Client:setUsername(info.name)
	Client:setGame(BotProfile.playing)
	-- Client:setStatus(BotProfile.status)
end


-- MAIN:
Client:on("ready", function()
	updateProfile()
	bot.debug("Bot started: %s", os.date())
end)

Client:on("messageCreate", function(Message)
	local messageData = {
		object = Message,
		rawString = Message.content,
		command = nil,
		split = {}
	}

	-- Check if Message content is empty:
	if Message.content == nil or #messageData.rawString < 1 then
		print("\n")
		bot.debug("Got string with no content, exiting!")
		return
	else
		print("\n")
		bot.debug("Got message: '%s'", messageData.rawString)
	end
	-- Check if Member ID is blocked:
	for _, id in pairs(BannedIDs) do
		if id == Message.author.id then
			bot.debug("Member ID '%s' was blocked.", id)
			return
		end
	end
	
	-- Split up message by spaces into table:
	for s in string.gmatch(messageData.rawString, "%S+") do
		table.insert(messageData.split, s)
	end

	-- Check if split table is valid, return if empty:
	if messageData.split[1] ~= nil then
		messageData.split[1] = tostring(messageData.split[1])
	else
		bot.debug("Split table content ('%s') seems to be empty, aborting.", table.concat(messageData.split, ", ", 1, #messageData.split))
		return
	end

	-- Attempt command execution, if first character(s) is/are prefix:
	if string.sub(messageData.split[1], 1, #info.prefix):lower() == info.prefix:lower() and #messageData.split[1] > 1 then
		attemptCommandExecution(
			Message,                                                                          -- Message Object
			string.sub(messageData.split[1], #info.prefix+1, #messageData.split[1]):lower(),  -- Command String
			messageData.split                                                                 -- Raw Message Fragments (will be transformed into args)
		)
	end

	-- Find Substring, react to it: (still broken... ;w;)
	-- findMessageSubstring(Message, messageData)
end)


Client:run('Bot ' .. info.token)
