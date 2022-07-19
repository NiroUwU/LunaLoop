#!/bin/bash

echo -e "\nWelcome to the setup script!\nPlease put in the following information as asked by this script :)\n"

printf "Name for your Bot: " && read NAME
printf "Version Number (optional): " && read VERSION
printf "Bot Prefix: " && read PREFIX
printf "Bot ID: " && read ID
printf "Bot Token: " && read TOKEN
printf "Invite Link (optional): " && read INVITE


echo "-- These are the bot information needed to connect to your discord application:
info = {
	name = '$NAME',
	version = '$VERSION',
	prefix = '$PREFIX',
	id = '$ID',	
	token = '$TOKEN',
	invite = '$INVITE',
	repository = 'https://github.com/NiroUwU/LunaLoop'
}

return info" >> info.lua && echo -e "File written, commencing with bot start :)\n" || echo -e "There was an issue writing the info file to disk :(\n"
