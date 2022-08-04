-- SETUP:

-- Variables:
Discordia = require "discordia"
Class = Discordia.class
Client = Discordia.Client()

require "import"
bot.isDebug = true
switch = Switch.switch

-- Functions:
local function getGlobalErrorMessage()
	return {
		title = "Internal Bot Error",
		description = "The bot ran into an error while executing a command.\nPlease report this issue if you see this message. :)",
		footer = {
			text = "Please report here: " .. info.repository .. "/issues"
		}
	}
end

local function attemptCommandExecution(Message, commandString, args, ...)
	for i, v in pairs(CommandList.list) do
		if i == commandString then
			bot.debug("Executing command '%s'!", commandString)

			table.remove(args, 1)
			v.fn(Message, Message.author, args, ...)
			return
		end
	end
	bot.debug("Command '%s' was not found!", commandString)
end


local function updateProfile()
	Client:setUsername(info.name)
	Client:setGame(BotProfile.playing)
	-- Client:setStatus(BotProfile.status)
end


-- MAIN:
Client:on("ready", function()
	updateProfile()
	bot.time.setStartup()
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
		--bot.debug("Got message with no content, exiting!")
		return
	else
		--bot.debug("Got message: '%s'", messageData.rawString)
	end
	-- Check if Member ID is blocked:
	for _, id in pairs(BannedIDs) do
		if id == Message.author.id then
			bot.debug("Member ID '%s' was blocked, ignoring.", id)
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


Client:on("reactionAdd", function(Reaction, CallerID)
	local Message = Reaction.message
	local msg = MessageReaction.list[Message.id]
	bot.debug("Bot observed an emoji reaction '%s' by %s", Reaction.emojiName, tostring(CallerID))

	for i=0, #BannedIDs do
		if CallerID == BannedIDs[i] then
			bot.debug("Blocked user reacted to message, ignoring.")
			return
		end
	end

	-- Check if message stored in memory:
	if not msg then
		bot.debug("Message with the id '%s' not saved in memory!", Message.id)
		return
	end
	bot.debug("Executing saved message id '%s' function!", Message.id)
	MessageReaction:execute(Message, Reaction, CallerID)
end)



Client:run('Bot ' .. info.token)
