---@diagnostic disable: undefined-global

Message:reply { embed = {
	title = "Embed Title",
	description = "Here is my fancy description!",
	author = {
		name = Message.author.username,
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
		text = ""
	},
	color = Colours.embeds.default
}}
