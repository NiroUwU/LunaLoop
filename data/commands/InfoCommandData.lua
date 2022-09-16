InfoCommandData = {
	title = "",
	description = "",
	colour = 0,
	footer = {},
	fields = {}
}

-- Functions:

local function getOSInformation()
	-- This is totally not a workaround, ignore this:
	if bash == nil then return "Soon:tm:" end
	local sf = string.format

	local OS = bash.execute("uname.temp", "uname -o")

	local results = {
		sf("Running on: %s", OS)
	}
	return table.concat(results)
end


-- Data:
local function setAuthor()
	return {
		name = "Click here to invite me!",
		url = info.invite,
		icon_url = bot.user.avatarURL
	}
end

local function setTitle()
	return info.name .. " Bot Information"
end

local function setDesc()
	local fulldesc = {
		"This is the info command, it displays interesting and nerdy information about this bot!",
		string.format("This bot is open source. Click [here](%s) to see the source code!", info.repository)
	}
	return table.concat(fulldesc, "\n")
end

local function setColour()
	return Colours.embeds.default
end

local function setFooter()
	return {
		text = string.format("For further help, see: %shelp", info.prefix)
	}
end

local function setFields()
	return {
		{
			name = "__Bot Version:__",
			value = info.version,
			inline = true
		},
		{
			name = "__Uptime:__",
			value = bot.time.getUptimeFormated(),
			inline = true
		},
		{
			name = "__Technical Information:__",
			value = getOSInformation(),
			inline = true
		}
	}
end

local function update()
	InfoCommandData.author = setAuthor()
	InfoCommandData.title = setTitle()
	InfoCommandData.description = setDesc()
	InfoCommandData.fields = setFields()
	InfoCommandData.footer = setFooter()
	InfoCommandData.colour = setColour()
end

function InfoCommandData.getFullTable()
	update()
	return {
		author = InfoCommandData.author,
		title = InfoCommandData.title,
		description = InfoCommandData.description,

		fields = InfoCommandData.fields,
		footer = InfoCommandData.footer,
		color = InfoCommandData.colour
	}
end

update()
return InfoCommandData
