LogChannel = {
	functions = {}
}

local function sendToChannel(Message, id, emb)
	local guild = Message.guild
	local channel = guild:getChannel(id)

	if channel ~= nil then
		channel:send { embed = emb }
	end
end

-- All loggable actions:
LogChannel.functions["join-leave"] = function(Member, event, id)
	sendToChannel(Member, id, {})
end

LogChannel.functions["member-update"] = function(Member, event, id)
	sendToChannel(Member, id, {})
end

LogChannel.functions["messages"] = function(Message, event, id)
	local function getTitle(str)
		return string.format("Message %s in #%s (ID: %s)", tostring(str):lower(), Message.channel.name, Message.id)
	end
	local emb = {
		author = {
			name = string.format("%s (ID: %s)", Message.author.username, tostring(Message.author.id)),
			icon_url = Message.author.avatarURL,
			url = Message.link
		},
		description = tostring(Message.content),
		footer = {
			text = os.date("Timestamp: %d.%h.%Y - %T %Z (UTC%z)")
		}
	}

	if event == "messageCreate" then
		emb.title = getTitle("sent")
		emb.color = Colours.list.blue_light
		sendToChannel(Message, id, emb)

	elseif event == "messageUpdate" then
		emb.title = getTitle("updated")
		emb.color = Colours.list.yellow
		sendToChannel(Message, id, emb)

	elseif event == "messageDelete" then
		emb.title = getTitle("deleted")
		emb.color = Colours.list.red
		sendToChannel(Message, id, emb)
	end
end


-- Handle incoming request: (it's doing most of the dirty work... good girl -v-)
function LogChannel:handleEvent(EventObject, event, action)
	if EventObject == nil then bot.debug("Error on %s (%s): EventObject not valid", tostring(event), tostring(action)) return end
	if EventObject.guild == nil then bot.debug("Error on %s (%s): EventObject.guild not valid", tostring(event), tostring(action)) return end

	local server = jsonfile.import(string.format("storage/servers/%s.json", EventObject.guild.id))
	if server == nil then return end

	local id = server["log-channels"][action]
	if id == nil then return end
	if id == 0 then return end

	LogChannel.functions[action](EventObject, event, id)
end

return LogChannel
