#!/bin/python

import requests
import time
import re
import sys
import datetime
import syslog

req_count=0
apikey=sys.argv[1]
logkey=sys.argv[2]
leq=sys.argv[3]
appname=sys.argv[4]
wdir=sys.argv[5]
perPage=int(sys.argv[6])
timeWait=int(sys.argv[7])
previous_dump = []

timeint = timeWait*1250

def continue_request(req):
    if 'links' in req.json():
        continue_url = req.json()['links'][0]['href']
        new_response = make_request(continue_url)
        handle_response(new_response)

def handle_response(resp):
    response = resp
    ev_dict={}
    print "Resp code "+str(response.status_code)+"\n"
    if response.status_code == 200:
        ev_dict = eval(resp.text)
        syslog_send(ev_dict,send_log=[])
        return
    if response.status_code == 202:
        continue_request(resp)
        return
    if response.status_code > 202:
        print 'Error status code ' + str(response.status_code)
        print_query()
        return

def make_request(provided_url=None):
    print "\n---------------------------------------------\nStartTime: "+str(startTime)+"; Endtime: "+str(endTime)
    print "Start: "+datetime.datetime.fromtimestamp(startTime/1000).strftime('%Y-%m-%d %H:%M:%S.%f')+" End: "+datetime.datetime.fromtimestamp(endTime/1000).strftime('%Y-%m-%d %H:%M:%S.%f')+"\n"
    headers = {'x-api-key': apikey}
    print perPage
    url = "https://rest.logentries.com/query/logs/%s/?query=%s&from=%i&to=%i&per_page=%i" % (logkey, leq, startTime, endTime, perPage)
    if provided_url:
        url = provided_url
    print url
    try:
       req = requests.get(url, headers=headers)
    except requests.exceptions.RequestException as e:
       print e
       time.sleep(5)
       print_query()
    return req

def print_query():
    global startTime
    startTime = int(round((time.time() * 1000) - timeint - 10000))
    global endTime
    endTime = int(round((time.time() * 1000 - 10000)))
    global req_count
    print "Req Count: "+str(req_count)+"\n"
    req_count+=1
    req = make_request()
    handle_response(req)

def start():
    syslog.syslog("Job started for " + appname + "\n")
    while True:
       print_query()
       time.sleep(timeWait)

def syslog_send(ev_dict,send_log):
   lsent=0
   global previous_dump
   temp_dump = previous_dump
   previous_dump = []
   for line in ev_dict['events']:
      if line['message'] not in temp_dump:
         previous_dump.append(line['message'])
         syslog.syslog(str(datetime.datetime.fromtimestamp(line['timestamp']/1000))+" "+line['message'])
         lsent+=1
   syslog.syslog("le_query sent "+str(lsent)+" lines for app "+appname)

if __name__ == '__main__':
    start()
