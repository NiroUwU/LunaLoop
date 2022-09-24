Command = {}
Command.__index = Command

function Command:new(Name, Aliases, Description, Type, Function)
    if tostring(type(Type)) == 'function' and Function == nil then
        Function = Type
        Type = "Other"
    end
    return setmetatable({
        name = Name,
        aliases = Aliases,
        desc = Description,
        type = Type,
        func = Function
    }, Command)
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


function Command:handleMessage(Message)
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
end

return Command
