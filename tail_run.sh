#!/bin/bash
# logentries connector version 1.0
wdir="/usr/local/le_get_api"
conf=$wdir"/apps_list.txt"

if [ "$1" == "start" ]
then
   while read -r line
   do
      apikey=`echo $line|awk -F ',' {'print $1'}`
      logkey=`echo $line|awk -F ',' {'print $2'}`
      leq=`echo $line|awk -F ',' {'print $3'}`
      appname=`echo $line|awk -F ',' {'print $4'}`
      nohup $wdir/le_query.py $apikey $logkey $leq $appname $wdir &> $wdir/$appname.out&
      disown
      sleep 7 
      pnm=`ps -ef|grep $logkey|grep -v "grep"|awk -F ' ' {'print $2'}`
      echo "Started instance for api: "$apikey" logkey: "$logkey" appname: "$appname" with query: "$leq" by process number: "$pnm
   done < "$conf"
   nohup $wdir/tail_watcher.sh &> $wdir/watcher.out&
   disown
   pwn=`ps -ef|grep tail_watcher|grep -v "grep"|awk -F ' ' {'print $2'}`
   echo "Started watcher by proc: "$pwn
elif [ "$1" == "stop" ]
then
   for i in $(ps -ef|grep "le_query.py"|grep -v grep|awk -F ' ' {'print $2'})
   do 
      echo "Killing process "$i
      kill $i
   done
   pwn=`ps -ef|grep tail_watcher|grep -v "grep"|awk -F ' ' {'print $2'}`
   echo "Killing watcher process "$pwn
   kill $pwn 
elif [ "$1" == "status" ]
then
   if [[ $(ps -ef|grep "le_query.py"|grep -v "grep") ]]
   then
      echo "Processes running"
   else
      echo "No running processes found"
   fi
elif [ "$1" == "start_no_watcher" ]
then
   while read -r line
   do
      apikey=`echo $line|awk -F ',' {'print $1'}`
      logkey=`echo $line|awk -F ',' {'print $2'}`
      leq=`echo $line|awk -F ',' {'print $3'}`
      appname=`echo $line|awk -F ',' {'print $4'}`
      nohup $wdir/le_query.py $apikey $logkey $leq $appname $wdir &> $wdir/$appname.out&
      disown
      pnm=`ps -ef|grep $logkey|grep -v "grep"|awk -F ' ' {'print $2'}`
      sleep 2
      echo "Started instance for api: "$apikey" logkey: "$logkey" appname: "$appname" with query: "$leq" by process number: "$pnm
   done < "$conf"
else
   echo "No arguments or incorrect arguments supplied. 'start' and 'stop' are valid."
fi
