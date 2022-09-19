#!/bin/bash

echo -e "\nWelcome to the setup script!\nPlease put in the following information as asked by this script :)\n"

echo -e "Name for your Bot: \c" && read -r NAME
echo -e "Bot Prefix: \c" && read -r PREFIX
echo -e "Bot Token: \c" && read -r TOKEN
echo -e "Invite Link (optional): \c" && read -r INVITE


echo "-- These are the bot information needed to connect to your discord application:
info = {
	name = '$NAME',
	version = globalInfo.version,
	prefix = '$PREFIX',
	token = '$TOKEN',
	invite = '$INVITE',
	repository = 'https://github.com/NiroUwU/LunaLoop'
}

return info" >> info.lua && echo -e "File written, commencing with bot start :)\n" || echo -e "There was an issue writing the info file to disk :(\n"
