-- Decides if feedback about module loading should be printed to console:
local doOutput = false

local path = ""
-- Switches Path:
local function cd(newPath)
	path = newPath
	if doOutput then print("\n🔍 Loading in:     *" .. newPath .. "*") end
end

-- Loads a module:
local modCount = 0
local function load(request)
	-- Module Path:
	local location = path .. "/" .. request
	local mod = require(location)

	-- Feedback Prinout:
	local out = "✅ Loaded Module:  " .. request
	-- Indentation:
	local gap = " "
	for i=#out, 35 do
		gap = gap .. " "
	end

	-- Return Module:
	if doOutput then print(out .. gap ..  "(" .. location .. ")") end
	modCount = modCount + 1
	return mod
end

-- Help Utils
cd("src")
bot = load "bot"
easy = load "easy"
filehandler = load "filehandler"
bash = load "bash"
jsonfile = load "jsonfile"


-- Libraries:
cd("lib")
--Class  = load "class"  -- https://github.com/vrld/hump/blob/master/class.lua
Switch = load "Switch" -- https://github.com/NiroUwU/Lua-Utils/blob/main/Switch.lua
base64 = load "base64" -- https://github.com/iskolbin/lbase64/blob/master/base64.lua
json   = load "json"   -- https://github.com/rxi/json.lua

-- Import General Data About the Bot
cd("")
globalInfo = load "globalInfo"
info = load "info"

-- Import Classes:
cd("src/class")
load "Command"
load "MessageReaction"
load "ServerSetting"
--load "MessageSubstring"

-- Import Data:
cd("data")
load "CommandList"
load "BannedIDs"
load "BotProfile"
load "Filesystem"
load "Colours"

-- Command Data:
cd("data/commands")
load "Units"
load "HelloResponse"
load "Gifs"
load "Dating"
load "Changelog"
load "YesNoMaybe"
load "InfoCommandData"
