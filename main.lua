-- SETUP:

-- Variables:
Discordia = require "discordia"
require "src/import"

Class = Discordia.class
Client = Discordia.Client {
	logFile = "logs/discordia.log",
	gatewayFile = "logs/gateway.json"
}

bot.isDebug = true
switch = Switch.switch

-- Due to my inability to remember my own code structure:
easy.debug = bot.debug

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
	local function tryThisCommand(name, ...)
		bot.debug("Executing command '%s'!", commandString)

		table.remove(args, 1)
		name.fn(Message, Message.author, args, ...)
	end
	for i, v in pairs(CommandList.list) do
		-- Try real command name:
		if i == commandString then
			tryThisCommand(v, ...)
			return
		end
		-- Try all alias command names:
		for _,k in pairs(v.aliases) do
			if k == commandString then
				tryThisCommand(v, ...)
				return
			end
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
	bot.user = Client.user

	-- Legacy (i am extremly lazy, okay??):
	info.id = bot.user.id

	-- Add bot to ignored IDs list:
	table.insert(BannedIDs, bot.user.id)
end)


-- Listening for commands:
Client:on("messageCreate", function(Message)
	local messageData = {
		object = Message,
		rawString = Message.content,
		command = nil,
		split = {}
	}

	-- Check if Message content is empty:
	if Message.content == nil or #messageData.rawString < 1 then return end

	-- Check if Message was sent by a bot user, ignore if true:
	if Message.author.bot and not Config.commands.allow_bots then return end

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
end)


-- Goodies for Gambling: (listens to just messages from users)
Client:on("messageCreate", function(Message)
	if Message.content == nil then return end
	if Message.author.bot then return end

	Goodies:handleMessage(Message)
end)


-- Add Reaction Event: (listening to reactions for messages saved in memory for listening)
Client:on("reactionAdd", function(Reaction, CallerID)
	local Message = Reaction.message
	local msg = MessageReaction.list[Message.id]
	bot.debug("Bot observed an emoji reaction '%s' by %s", Reaction.emojiName, tostring(CallerID))

	-- Check if reaction was added by a blocked user:
	for i=0, #BannedIDs do
		if CallerID == BannedIDs[i] then
			bot.debug("Blocked user reacted to message. Ignoring reaction.")
			return
		end
	end

	-- Check if message is stored in memory:
	if not msg then
		bot.debug("Message with the id '%s' not saved in memory! Ignoring reaction.", Message.id)
		return
	end
	bot.debug("Executing saved message (id: '%s') function (name: '%s')!", Message.id, Reaction.emojiName)
	MessageReaction:execute(Message, Reaction, CallerID)
end)


-- Run bot with token:
Client:run(string.format('Bot %s', info.token))
