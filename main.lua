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


-- FUNCTIONS:
local function getGlobalErrorMessage()
	return {
		title = "Internal Bot Error",
		description = "The bot ran into an error while executing a command.\nPlease report this issue if you see this message. :)",
		footer = {
			text = "Please report here: " .. info.repository .. "/issues"
		}
	}
end

local function updateProfile()
	Client:setUsername(info.name)
	Client:setGame(BotProfile.playing)
	-- Client:setStatus(BotProfile.status)
end


-- SETUP:
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

-- MAIN:
Client:on("messageCreate", function(Message)
	if Message.author.bot then return end
	Command:handleMessage(Message)
	Goodies:handleMessage(Message)
	LogChannel:handleEvent(Message, "messageCreate", "messages")
end)

Client:on("messageUpdate", function(Message)
	LogChannel:handleEvent(Message, "messageUpdate", "messages")
end)

Client:on("messageDelete", function(Message)
	LogChannel:handleEvent(Message, "messageDelete", "messages")
end)

Client:on("reactionAdd", function(Reaction, CallerID)
	MessageReaction:handleReaction(Reaction, CallerID)
end)

Client:on("memberJoin", function(Member)
	MemberJoinLeave:handleEvent(Member, "memberJoin")
end)

Client:on("memberLeave", function(Member)
	MemberJoinLeave:handleEvent(Member, "memberLeave")
end)


-- Run bot with token:
Client:run(string.format('Bot %s', info.token))
