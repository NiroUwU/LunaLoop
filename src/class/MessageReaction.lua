MessageReaction = {}
MessageReaction.list = {}

-- Add and remove messages that need to be listened to:
--@param Message must be a Message object
--@param successReactionTable is a dictionary of emojis -> functions
--@param failFunction is function triggered on fail
--@param targetUserID is the user ID from the targeted user, set to nil to allow everyone
--@param repeatableExecution must be a boolean (removes message from memory if false)
--@param repeatableFail must be a boolean (surpressed removing if reaction failed)
function MessageReaction:add(Message, successReactionTable, failFunction, targetUserID, repeatableExecution, repeatableFail)
	bot.debug("Adding Message id '%s' to memory", Message.id)
	local temp = {
		Message = Message,
		repeatable = {
			success = repeatableExecution,
			fail = repeatableFail
		},
		targetUserID = targetUserID,
		reactions = {
			success = successReactionTable,
			failed = nil
		}
	}
	if type(failFunction) ~= "function" then
		temp.reactions.failed = function()
			bot.debug("MessageReaction: Message id '%s' did not have a fail function to run!", Message.id)
		end
	end

	MessageReaction.list[Message.id] = temp
	bot.debug("Added Message id '%s' to memory", Message.id)
end
function MessageReaction:remove(Message)
	bot.debug("MessageReaction: Removing message id '%s'!", tostring(Message.id))
	MessageReaction.list[Message.id] = nil
end

-- Query for a message saved in the list and return it's contents:
function MessageReaction:query(Message)
	local result = MessageReaction.list[Message.id]
	if not result then
		bot.debug("MessageReaction: Message id '%s' was not found, cannot be queried!", tostring(Message.id))
	end
	return result or {}
end

-- Execute a function set to a reaction:
function MessageReaction:execute(Message, Reaction, userID)
	-- Exit if message not saved in memory:
	local msg = MessageReaction.list[Message.id]
	if not msg then
		bot.debug("msg is nil")
		return
	end

	-- Ignore Target User if set to nil (everyone can use this reaction!):
	if msg.targetUserID ~= nil then
		-- Check if User ID matches target user:
		if msg.targetUserID ~= userID then
			bot.debug("User ID does not check out!")
			return
		end
	end

	bot.debug("User ID checks out: %s (target) ~= %s (reactee)", msg.targetUserID, userID)

	-- Try to execute a function:
	local fn = msg.reactions.success[Reaction.emojiName]
	local statusSuccess = nil
	if fn == nil and type(fn) == "function" then
		bot.debug("Failed, executing failed()")
		fn = msg.reactions.failed
		statusSuccess = false
	end
	if fn ~= nil then
		if statusSuccess == nil then
			statusSuccess = true
		end
		bot.debug("Executing fn()")
		fn()
	end

	-- Remove Object from memory if nonrepeatable:
	local function remove(action)
		bot.debug("Removing Message from memory! (%s)", action)
		MessageReaction:remove(Message)
	end
	if msg.repeatable.success == false and statusSuccess == true then
		remove("Success")
		return
	end
	if msg.repeatable.fail == false and statusSuccess == false then
		remove("Fail")
		return
	end
	bot.debug("Done")
end

return MessageReaction
