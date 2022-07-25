MessageSubstring = {}
MessageSubstring.__index = MessageSubstring

function MessageSubstring.new(reactionType, reaction, trigger)
	local reactionTypes = {"reply", "reaction"}
	if type(reactionType ~= "string") then
		bot.debug("MessageSubstring reaction type for '%s' is not a string!", reaction)
		return
	end
	if type(trigger) ~= "table" then
		bot.debug("MessageSubstring '%s' triggers must be in a table!", reaction)
	end
	
	local pass = false
	for i, v in pairs(reactionTypes) do
		if v == reactionType then
			pass = true
		end
	end
	if not pass then
		bot.debug("MessageSubstring '%s' did not pass, invalid reactionType (%s)!", reaction, reactionType)
		return
	end

	return setmetatable({
		reactionType = reactionType,
		reaction = reaction,
		trigger = trigger
	}, MessageSubstring)
end

function MessageSubstring.reply(Message, Caller, ...)
	Message.channel:send()
end

function MessageSubstring.react(Message, Caller, ...)
end

return MessageSubstring
