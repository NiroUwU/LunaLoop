#!/bin/bash

TASKS_lit=('SinisterRectus/discordia')
TASKS_misc=()

function doThis() {
	local task="$*"
	local text_begin="\e[1;33m>> Task '$task' started!\e[0m"
	local text_success="\e[1;32m>> Task '$task' was completed successfully!\e[0m"
	local text_failure="\e[1;31m>> Task '$task' has failed...\e[0m"

	echo -e "$text_begin"
	$task && echo -e "$text_success" || echo -e "$text_failure"
}

function main() {
	# Update Lit dependancies:
	for task in "${TASKS_lit[@]}"; do
		doThis "lit install $task"
	done

	# Perform other tasks:
	for task in "${TASKS_misc[@]}"; do
		doThis "$task"
	done
}
main
