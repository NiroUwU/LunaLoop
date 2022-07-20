#!/bin/bash

TASKS=( './lit install SinisterRectus/discordia ' )

function main() {
	for task in "${TASKS[@]}"; do
		echo -e "Starting task '$task'!" && $task && echo -e "Task '$task' completed!" || echo -e "Task '$task' failed..."
	done
}
main
