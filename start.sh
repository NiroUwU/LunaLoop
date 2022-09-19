#!/bin/bash

# SETTINGS:
export PATH_scripts=./scripts


# MAIN:

# Fetch update from github repository:
git pull || echo -e "Could not fetch updates... is git installed on this system?"

# Add permissions to all script files:
chmod +x $PATH_scripts/*
chmod +x *.sh -R

# Start the bot through script (will work with changes to files):
$PATH_scripts/startBot.sh
