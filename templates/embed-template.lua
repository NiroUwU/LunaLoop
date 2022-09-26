---@diagnostic disable: undefined-global

Message:reply { embed = {
	title = "Embed Title",
	description = "Here is my fancy description!",
	author = {
		name = Message.author.username,
		url = "https://discord.com/",
		icon_url = Message.author.avatarURL
	},
	image = {
		url = "https://urmom.com/"
	},
	fields = {
		{
			name = "",
			value = "",
			inline = true
		},
		{
			name = "",
			value = "",
			inline = false
		}
	},
	footer = {
		text = "",
		icon_url = "https://urmother.com/"
	},
	color = Colours.embeds.default
}}
