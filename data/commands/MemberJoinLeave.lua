MemberJoinLeave = {
	prompts = {}
}

MemberJoinLeave.prompts['memberJoin'] = {
	"Welcome %s!", "%s has joined this server", "Everbody welcome %s!", '"Hello there." "%s, you are a bold one!"', "Heyyy %s!",
	"Hope you have a nice stay, %s. :)", "Happy to see you %s"
}
MemberJoinLeave.prompts['memberLeave'] = {
	"%s has left this server.", "Sad to see you go %s", "We will miss you %s...", "Another one bites the dust... %s", "Bye bye %s",
	"%s is gone :(", "Where did %s go??", "%s is no longer *among us*..."
}


local function getPrompt(Member, action)
	if MemberJoinLeave.prompts[action] == nil then return end

	local user, username = Member.user, ""
	if action == "memberJoin" then username = user.mentionString end
	if action == "memberLeave" then username = string.format("**%s**", user.tag) end
	return string.format(easy.table.randomIn(MemberJoinLeave.prompts[action]), username)
end

function MemberJoinLeave:handleEvent(Member, event)
	local file_location = string.format("%s/%s.json", FileLocation.storage.serverdirectory, Member.guild.id)
	local server = jsonfile.import(file_location)
	if server == nil then return end
	if server["log-channels"] == nil then return end

	local channel = server["log-channels"]["join-leave"]
	if channel == nil or channel == 0 then return end
	channel = Member.guild:getChannel(channel)

	local prompt = getPrompt(Member, event)
	if not channel:send(prompt) then print("didnt do it :(") end
end

return MemberJoinLeave
