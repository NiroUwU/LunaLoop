#!/bin/bash

# SETTINGS:
PATH_scripts=./scripts


# FUNCTIONS:
function beforeBotRun() {
	chmod +x -R scripts/*
	chmod +x ./*.sh
	
	printf "Starting Bot at %s.\n" "$(date)"

	# Execute first time setup, if file "info.lua" not found:
	[ -f "info.lua" ] || $PATH_scripts/setup.sh
}
function runBot() {
	luvit main.lua || printf "Bot ran into an issue!\n"
}
function afterBotRun() {
	printf "Bot terminated at %s.\n" "$(date)"
}


# MAIN:
function main() {
	beforeBotRun
	runBot
	afterBotRun
}
main
