-- SETUP:

-- Variables:
Discord = require "discordia"
Client = Discord.Client()

require "import"
bot.isDebug = true

-- Functions:
Client:on("ready", function()
	bot.debug("Bot started: %s", os.date())
end
)

local function attemptCommandExecution(Message, commandString, args)
	for i, v in pairs(Commands.list) do
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


-- MAIN:
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
end)



Client:run('Bot ' .. info.token)
