Goodies = {
	users_file = "storage/users.json"
}

local function getUsersFile()
	return jsonfile.import(FileLocation.storage.usersfile) or {}
end


function Goodies:handleMessage(Message)
	if Message.author.bot then return end
	if Message.content == nil then return end
	-- Check if users.json exists:
	local users_file = filehandler.read(FileLocation.storage.usersfile)
	if users_file == nil then
		bot.debug("File '%s' was not found, creating!", FileLocation.storage.usersfile)
		io.output(FileLocation.storage.usersfile):write("{}")
		io.close()
	end

	local users = getUsersFile()
	local userid = Message.author.id

	-- Check if user already has a goodies value, set to 0 if not:
	if users[userid] == nil then users[userid] = {} end
	if users[userid].goodies == nil then users[userid].goodies = 0 end
	if tonumber(users[userid].goodies) == nil then users[userid].goodies = 0 end

	-- Adds goodies to goodies value and writes it to json file:
	users[userid].goodies = users[userid].goodies + Config.goodies.gain_per_message
	jsonfile.export(FileLocation.storage.usersfile, users)
end

function Goodies:getBalance(userid)
	local balance = 0

	-- Search user id in .json file:
	local users = getUsersFile()
	if users[userid] == nil then
		bot.debug("Invalid user object for user id '%d', returning 0 balance.", userid)
		return 0
	end

	balance = users[userid].goodies
	if type(balance) ~= "number" then
		bot.debug("Balance for user %d not storing a number! (%s)", userid, type(balance))
		balance = 0
	end
	return balance
end

-- Returns true or false depending on success of action, and string if unsuccessful explaining why failure happened:
function Goodies:modifyBalance(userid, amount)
	if type(amount) ~= "number" then
		bot.debug("Attempted modifying balance of user '%s' with a not number value (%s)!", tostring(userid), tostring(amount))
		return false, "Provided value was not a number."
	end

	-- I am paranoid, okay??:
	amount = tonumber(amount)

	local balance_old = Goodies:getBalance(userid)
	local balance_new = balance_old + amount

	if balance_new < 0 then
		bot.debug("")
		return false, "New balance would go into negative."
	end

	local users = getUsersFile()
	if users[userid] == nil then users[userid] = {} end
	if users[userid].goodies == nil then users[userid].goodies = 0 end

	-- Write new users list:
	users[userid].goodies = balance_new
	jsonfile.export(FileLocation.storage.usersfile, users)
	return true, "Success"
end

return Goodies
