# LunaLoop Discord Bot

## About

LunaLoop is a discord general-purpose bot written in Lua, using the [discordia](https://github.com/SinisterRectus/Discordia) discord-api.

## Installation and Running

Simply clone this repository and run the `start.sh` file from your terminal. Upon first run, you will be prompted to insert your bot information (such as id, token). This will then be saved to a file called `info.lua`. This file will look something like this:

```lua
info = {
	name = 'LunaLoop',
	version = 'v0.1',
	prefix = '=',
	id = '0123456789',
	token = 'very_secret_token',
	invite = 'https://discord.com/',
	repository = 'https://github.com/NiroUwU/LunaLoop'
}

return info
```

## Dependancies

Included in this Repository:

+ Lua Programming Language

+ Discordia API

Required on your system:

+ bash

+ curl

+ [Luvit runtime](https://github.com/luvit/luvit)
