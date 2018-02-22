# le_get_api

1. PURPOSE

This set of scripts in python and bash pulls logs from Logentries cloud log management platform and passes them to the syslog daemon of the server it is run on. The syslog then can be configured to forward these events to another server via the network or store the events locally in a file or through them into a pipe etc.

2. PREREQUISITES

All the scripts have been tested on a Centos 7 linux yet they are most likely to be functional on other linux distros.
The only requirement is python 2.7 with the following modules:
- datetime;
- time;
- syslog;
- requests;
- json;
- sys;
- re.

3. DESCRIPTION

All the scripts are briefly described in the following section.
1) le_get_api.py
This is the main script which actually pulls the info via Logentries API, removes duplicates (if any) and passes th info to syslog daemon.
The script is run once a minute, it grabs the events for the last 75 seconds, sorts out the duplicates with the events it has grabbed during the previous run and passes the events to syslog daemon.
The source of the script was taken from here: https://docs.logentries.com/docs/get-query
Cons: in current version if by any means the script will not be able to find the last event (he read during the previous run) in the fresh portion of events it will stop processing the flow. The issue will be corrected in the next version.
2) tail_run.sh
Bash script user for launching and stoping le_get_api.py. The script reads the config file apps_list.txt and launches as many instances of le_get_api.py as there are config lines in the file. It also launches the tail_watcher.sh.
3) tail_watcher.sh
Used to "keep an eye" on running instances of le_get_api.py and re-launching those if they fail by some reason.
Cons: in current version does not monitor each single instance of le_get_api.py but all of them. That is if ALL instances fail then they will be restarted. Not otherwise.
4) apps_list.txt
This is a config file that holds configs for each application in Logentries that you want to grab logs from. A sample line of config is presented in the sample apps_list.txt. Every line in this file represents one application as follows:
\<api-key\>,\<log-key\>,\<leql\>,\<Name of app without spaces\>,\<Name of app with spaces\> 
  
4. INSTALLATION AND RUNNING

Just copy these files to /usr/local/le_get_api. 
If you want a different dir make a few changes to the scripts. 
Then edit apps_list.txt. 
After that launch with: ./tail_run.sh start. 
Stop with: ./tail_run.sh stop.
