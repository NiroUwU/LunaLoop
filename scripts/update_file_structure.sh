#!/bin/bash
# This script is automatically run by 'start.sh' from the root directory!

# Move all log files to 'logs' directory:
[ ! -d "logs" ] && mkdir "logs"
for f in *.log; do
	mv "$f" "logs"
done
