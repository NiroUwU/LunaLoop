-- Help Utils
bot = require "src/bot"
easy = require "src/easy"

-- Libraries:
Class = require "lib/class"   -- https://github.com/vrld/hump/blob/master/class.lua
Switch = require "lib/Switch" -- https://github.com/NiroUwU/Lua-Utils/blob/main/Switch.lua

-- Import General Data About the Bot
globalInfo = require "globalInfo"
info = require "info"

-- Commands:
require "src/class/Command"
require "data/CommandList"

-- Substring Responses:
require "src/class/MessageSubstring"
require "data/ReactionList"

-- IDs:
require "data/BannedIDs"

-- Data required for Commands:
require "data/Units"
require "data/HelloResponse"
require "data/Gifs"
require "data/Changelog"
