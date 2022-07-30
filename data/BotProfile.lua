BotProfile = {
	playing = "=help"
}

BotProfile.status = string.format([[
%s is a general-purpose bot written in Lua.
My default prefix is %s, see %shelp for more information about me!

My source code can be viewed here: %s
]], info.name, info.prefix, info.prefix ,info.repository)

return BotProfile
