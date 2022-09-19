#!/bin/bash
# This script is automatically run by 'start.sh' from the root directory!

# Prepare all directories (beacause lua cannot create directories on its own ;-;):
DIR_list=( 'cache' 'logs' 'storage' 'storage/servers' )
for d in "${DIR_list[@]}"; do
	[ ! -d "$d" ] && mkdir "$d" && echo -e "Created directory '$d'!"
done

# Move all log files to 'logs' directory:
LOG_files=$(ls ./*.log)
for f in "${LOG_files[@]}"; do
	mv "$f" "logs"
done
