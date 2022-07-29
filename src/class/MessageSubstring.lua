MessageSubstring = Class {}

function MessageSubstring:init(id, reactionType, reaction, trigger, fn)
	self.id = id
	self.reactionType = reactionType
	self.reaction = reaction
	self.trigger = trigger
	self.fn = fn
	local reactionTypes = {"reply", "reaction"}
	if type(self.reactionType ~= "string") then
		bot.debug("MessageSubstring reaction type for '%s' is not a string! (%s)", id, type(reactionType))
		--return
	end
	if type(self.trigger) ~= "table" then
		bot.debug("MessageSubstring '%s' triggers must be in a table!", id)
		return
	end
	if type(self.reaction) ~= "table" then
		bot.debug("MessageSubstring '%s' reactions must be in a table!", id)
		return
	end
	
	local pass = false
	for i, v in pairs(reactionTypes) do
		if v == self.reactionType then
			bot.debug("MessageSubstring '%s' passed, valid reactionType (%s)!", id, reactionType)
			pass = true
		end
	end
	if not pass then
		bot.debug("MessageSubstring '%s' did not pass, invalid reactionType (%s)!", id, reactionType)
		return
	end

	--[[return setmetatable({
		reactionType = reactionType,
		reaction = reaction,
		trigger = trigger,
		fn = fn
	}, MessageSubstring)]]
end

function MessageSubstring.reply(Message, Caller, ...)
	if self.fn ~= nil then
		Message.channel:send(self.fn)
		return
	end

	Message.channel:send(easy.randomIn(self.reaction))
end

function MessageSubstring.react(Message, Caller, ...)
	Message.channel:addReaction(easy.randomIn(self.reaction))
end
