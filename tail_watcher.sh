#!/bin/bash
# logentries connector version 1.0
wdir="/usr/local/le_get_api"

while :
do
    sleep 10
    if [[ $(ps -ef|grep le_query|grep -v grep) ]]
    then
        echo "Process found "
    else
    $wdir/tail_run.sh start_no_watcher
         echo "Restarted service"
    fi
done
