Goodies = {
	users_file = "storage/users.json"
}

function Goodies:handleMessage(Message)
	-- Check if users.json exists:
	local users_file = filehandler.read(Goodies.users_file)
	if users_file == nil then
		bot.debug("File '%s' was not found, creating!", Goodies.users_file)
		io.output(Goodies.users_file):write("{}")
		io.close()
	end

	local users = jsonfile.import(Goodies.users_file) or {}
	local userid = Message.author.id

	-- Check if user already has a goodies value, set to 0 if not:
	if users[userid] == nil then users[userid] = {} end
	if users[userid].goodies == nil then users[userid].goodies = 0 end
	if tonumber(users[userid].goodies) == nil then users[userid].goodies = 0 end

	-- Adds goodies to goodies value and writes it to json file:
	users[userid].goodies = users[userid].goodies + Config.goodies.gain_per_message
	jsonfile.export(Goodies.users_file, users)
end

return Goodies
