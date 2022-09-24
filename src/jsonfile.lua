jsonfile = {}

function jsonfile.import(fl)
	local file = io.open(fl, "r")

	-- Return if file was not found:
	if file == nil then
		local err = string.format("Json file '%s' not found...", fl)
		bot.debug(err)
		return nil, err
	end

	local raw_json = file:read("a")
	file:close()

	local formated_json = json.decode(raw_json)
	return formated_json
end

function jsonfile.importarray(fl, template)
	local base, err1 = jsonfile.import(template)
	local data, err2 = jsonfile.import(fl)

	if base == nil then
		bot.debug(err1 .. " (base/template)")
		return {}
	end
	if data == nil then
		bot.debug(err2 .. " (data)")
		return base
	end

	return easy.table.normalise(base, data)
end

function jsonfile.export(fl, data)
	-- Check if data is in table:
	if type(data) ~= "table" then
		bot.debug("Tried writing json file, table expected and got %s.", type(data))
		return
	end
	local formated_json = json.encode(data)

	io.output(fl)
	io.write(formated_json)
	io.close()
end

return jsonfile
