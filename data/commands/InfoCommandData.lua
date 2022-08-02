InfoCommandData = {
	title = "",
	description = "",
	colour = 0,
	footer = {},
	fields = {}
}

-- Data:
local function setTitle()
	return info.name .. " Bot Information"
end

local function setDesc()
	return "This is the info command, it displays interesting and nerdy information about this bot!"
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
			value = "Soon:tm:",
			inline = true
		}
	}
end

local function update()
	InfoCommandData.fields = setFields()
	InfoCommandData.description = setDesc()
	InfoCommandData.title = setTitle()
	InfoCommandData.colour = setColour()
	InfoCommandData.footer = setFooter()
end

function InfoCommandData.getFullTable()
	update()
	return {
		title = InfoCommandData.title,
		description = InfoCommandData.description,

		fields = InfoCommandData.fields,
		footer = InfoCommandData.footer,
		color = InfoCommandData.colour
	}
end

update()
return InfoCommandData
