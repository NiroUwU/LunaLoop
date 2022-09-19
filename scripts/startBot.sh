#!/bin/bash
function setup() {	
	# Execute first time setup, if file "info.lua" not found:
	[ -f "info.lua" ] || "$PATH_scripts"/first_time_setup.sh

	# Check and fix file structure, if needed:
	"$PATH_scripts"/update_file_structure.sh
}

# MAIN:
function main() {
	printf "Starting Bot at %s.\n" "$(date)"

	setup
	luvit main.lua || echo -e "Bot ran into an issue!"

	printf "Bot terminated at %s.\n" "$(date)"
}
main
