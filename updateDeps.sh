#!/bin/bash

TASKS=( 'curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh' './lit install SinisterRectus/discordia ' )

function main() {
	for task in "${TASKS[@]}"; do
		echo -e "Starting task '$task'!" && $task && echo -e "Task '$task' completed!" || echo -e "Task '$task' failed..."
	done
}
main
