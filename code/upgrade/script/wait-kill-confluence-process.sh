#!/bin/bash

set -o errexit -o pipefail

# Wait until confluence process has stopped before continuing to next step

# Check if not root user, then change to root user
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

MAX_RUN_INTERVAL=60
SLEEP_RUN_INTERVAL=5
currSecond=0

while true; do
    # Count Confluence process
    JAVA_PROCESS_COUNT=`ps -ef | grep confluence | grep -v grep | wc -l`

    if [ $JAVA_PROCESS_COUNT -eq 0 ]
    then
        break
    fi

    currSecond=$(($currSecond + $SLEEP_RUN_INTERVAL))
    echo "Checking Confluence process ($JAVA_PROCESS_COUNT)... $currSecond"

    if [[ $currSecond -gt $MAX_RUN_INTERVAL ]]
    then
        echo "Quit checking because maximum timeout of trying within $MAX_RUN_INTERVAL"

        kill_list=`ps -ef | grep confluence | grep -v grep | awk '{print $2}'`
        echo "List of current Confluence processes to be killed: $kill_list"
        kill -9 $kill_list
        break
    fi

    sleep $SLEEP_RUN_INTERVAL

done