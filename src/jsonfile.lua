jsonfile = {}

function jsonfile.import(fl)
	local file = io.open(fl, "r")

	-- Return if file was not found:
	if file == nil then
		return "File not found"
	end

	local raw_json = file:read("a")
	file:close()

	local formated_json = json.decode(raw_json)
	return formated_json
end

function jsonfile.export(fl, data)
	-- Check if data is in table:
	if type(data) ~= "table" then
		bot.debug("Tried writing json file, table expected and got %s.", type(data))
		return
	end
	local formated_json = json.encode(data)

	local file = io.open(fl, "w+")
	if file then
		file:write(formated_json)
		file:close()
		return
	end
	bot.debug("File '%s' was not found, could not be written to.", fl)
end

return jsonfile
