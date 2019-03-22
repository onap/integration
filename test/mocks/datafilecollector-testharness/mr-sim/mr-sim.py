import argparse
import os
from werkzeug import secure_filename
from flask import Flask, render_template, request
from time import sleep
import sys
import json
from flask import Flask
app = Flask(__name__)

#Server info
HOST_IP = "0.0.0.0"
HOST_PORT = 2222

#Test function to check server running
@app.route('/',
    methods=['GET'])
def index():
    return 'Hello world'

#Returns number of polls
@app.route('/ctr_requests',
    methods=['GET'])
def counter_requests():
    global ctr_requests
    return str(ctr_requests)

#Returns number of replies
@app.route('/ctr_responses',
    methods=['GET'])
def counter_responses():
    global ctr_responses
    return str(ctr_responses)

#Returns number of unique files
@app.route('/ctr_unique_files',
    methods=['GET'])
def counter_uniquefiles():
    global fileMap
    return str(len(fileMap))

#Returns tc info
@app.route('/tc_info',
    methods=['GET'])
def testcase_info():
    global tc_num
    return tc_num

#Messages polling function
@app.route(
    "/events/unauthenticated.VES_NOTIFICATION_OUTPUT/OpenDcae-c12/C12",
    methods=['GET'])
def MR_reply():
    global ctr_requests
    global args

    ctr_requests = ctr_requests + 1
    print("MR: poll request#: " + str(ctr_requests))

    if args.tc100:
      return tc100("sftp")
    elif args.tc101:
      return tc101("sftp")
    elif args.tc102:
      return tc102("sftp")

    elif args.tc110:
      return tc110("sftp")
    elif args.tc111:
      return tc111("sftp")
    elif args.tc112:
      return tc112("sftp")
    elif args.tc113:
      return tc113("sftp")

    elif args.tc120:
      return tc120("sftp")
    elif args.tc121:
      return tc121("sftp")
    elif args.tc122:
      return tc122("sftp")

    elif args.tc1000:
      return tc1000("sftp")
    elif args.tc1001:
      return tc1001("sftp")

    elif args.tc510:
      return tc510("sftp")      


    elif args.tc200:
      return tc200("ftps")
    elif args.tc201:
      return tc201("ftps")
    elif args.tc202:
      return tc202("ftps")

    elif args.tc210:
      return tc210("ftps")
    elif args.tc211:
      return tc211("ftps")
    elif args.tc212:
      return tc212("ftps")
    elif args.tc213:
      return tc213("ftps")

    elif args.tc220:
      return tc220("ftps")
    elif args.tc221:
      return tc221("ftps")
    elif args.tc222:
      return tc222("ftps")

    elif args.tc2000:
      return tc2000("ftps")
    elif args.tc2001:
      return tc2001("ftps")

    elif args.tc610:
      return tc510("ftps")     


#### Test case functions


def tc100(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 1):
    return buildOkResponse("[]")

  seqNr = (ctr_responses-1)
  msg = getEventHead() + getEventName("1MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022) + getEventEnd()
  fileMap[seqNr] = seqNr
  return buildOkResponse("["+msg+"]")

def tc101(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 1):
    return buildOkResponse("[]")  
 
  seqNr = (ctr_responses-1)
  msg = getEventHead() + getEventName("5MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022) + getEventEnd()
  fileMap[seqNr] = seqNr

  return buildOkResponse("["+msg+"]")

def tc102(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 1):
    return buildOkResponse("[]")  

  seqNr = (ctr_responses-1)
  msg = getEventHead() + getEventName("50MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022) + getEventEnd()
  fileMap[seqNr] = seqNr

  return buildOkResponse("["+msg+"]")

def tc110(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 100):
    return buildOkResponse("[]")  
  
  seqNr = (ctr_responses-1)
  msg = getEventHead() + getEventName("1MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022) + getEventEnd()
  fileMap[seqNr] = seqNr

  return buildOkResponse("["+msg+"]")

def tc111(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 100):
    return buildOkResponse("[]")  
  
  msg = getEventHead()

  for i in range(100):
    seqNr = i+(ctr_responses-1)
    if i != 0: msg = msg + ","
    msg = msg + getEventName("1MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022)
    fileMap[seqNr] = seqNr

  msg = msg + getEventEnd()

  return buildOkResponse("["+msg+"]")

def tc112(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 100):
    return buildOkResponse("[]")  
  
  msg = getEventHead()

  for i in range(100):
    seqNr = i+(ctr_responses-1)
    if i != 0: msg = msg + ","
    msg = msg + getEventName("5MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022)
    fileMap[seqNr] = seqNr

  msg = msg + getEventEnd()

  return buildOkResponse("["+msg+"]")

def tc113(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 1):
    return buildOkResponse("[]")  
  
  msg = ""

  for evts in range(100):  # build 100 evts
    if (evts > 0):
      msg = msg + ","
    msg = msg + getEventHead()
    for i in range(100):   # build 100 files
      seqNr = i+evts+100*(ctr_responses-1)
      if i != 0: msg = msg + ","
      msg = msg + getEventName("1MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022)
      fileMap[seqNr] = seqNr

    msg = msg + getEventEnd()

  return buildOkResponse("["+msg+"]")


def tc120(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 100):
    return buildOkResponse("[]")  

  if (ctr_responses % 10 == 2):
    return  # Return nothing
  
  if (ctr_responses % 10 == 3):
    return buildOkResponse("") # Return empty message

  if (ctr_responses % 10 == 4):
    return buildOkResponse(getEventHead()) # Return part of a json event

  if (ctr_responses % 10 == 5):
    return buildEmptyResponse(404) # Return empty message with status code

  if (ctr_responses % 10 == 6):
    sleep(60)

  
  msg = getEventHead()

  for i in range(100):
    seqNr = i+(ctr_responses-1)
    if i != 0: msg = msg + ","
    msg = msg + getEventName("1MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022)
    fileMap[seqNr] = seqNr

  msg = msg + getEventEnd()

  return buildOkResponse("["+msg+"]")

def tc121(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 100):
    return buildOkResponse("[]")  
  
  msg = getEventHead()

  for i in range(100):
    seqNr = i+(ctr_responses-1)
    if (seqNr%10 == 0):     # Every 10th file is "missing"
      fn = "MissingFile_" + str(seqNr) + ".tar.gz"
    else:
      fn = "1MB_" + str(seqNr) + ".tar.gz"
      fileMap[seqNr] = seqNr

    if i != 0: msg = msg + ","
    msg = msg + getEventName(fn,ftptype,"onap","pano","localhost",1022)
    

  msg = msg + getEventEnd()

  return buildOkResponse("["+msg+"]")

def tc122(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 100):
    return buildOkResponse("[]")  
  
  msg = getEventHead()

  for i in range(100):
    fn = "1MB_0.tar.gz"  # All files identical names
    if i != 0: msg = msg + ","
    msg = msg + getEventName(fn,ftptype,"onap","pano","localhost",1022)

  fileMap[0] = 0
  msg = msg + getEventEnd()

  return buildOkResponse("["+msg+"]")


def tc1000(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  msg = getEventHead()

  for i in range(100):
    seqNr = i+(ctr_responses-1)
    if i != 0: msg = msg + ","
    msg = msg + getEventName("1MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022)
    fileMap[seqNr] = seqNr

  msg = msg + getEventEnd()

  return buildOkResponse("["+msg+"]")

def tc1001(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  msg = getEventHead()

  for i in range(100):
    seqNr = i+(ctr_responses-1)
    if i != 0: msg = msg + ","
    msg = msg + getEventName("5MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022)
    fileMap[seqNr] = seqNr

  msg = msg + getEventEnd()

  return buildOkResponse("["+msg+"]")

def tc510(ftptype):
  global ctr_responses
  global ctr_unique_files

  ctr_responses = ctr_responses + 1

  if (ctr_responses > 5):
    return buildOkResponse("[]")  

  msg = ""

  for evts in range(700):  # build events for 5 MEs
    if (evts > 0):
      msg = msg + ","
    msg = msg + getEventHeadNodeName("PNF"+str(evts))
    seqNr = (ctr_responses-1)
    msg = msg + getEventName("1MB_" + str(seqNr) + ".tar.gz",ftptype,"onap","pano","localhost",1022)
    seqNr = seqNr + evts*1000000 #Create unique id for this node and file
    fileMap[seqNr] = seqNr
    msg = msg + getEventEnd()

  return buildOkResponse("["+msg+"]")

#Mapping FTPS TCs
def tc200(ftptype):
  return tc100(ftptype)
def tc201(ftptype):
  return tc101(ftptype)
def tc202(ftptype):
  return tc102(ftptype)

def tc210(ftptype):
  return tc110(ftptype)
def tc211(ftptype):
  return tc111(ftptype)
def tc212(ftptype):
  return tc112(ftptype)
def tc213(ftptype):
  return tc113(ftptype)

def tc220(ftptype):
  return tc120(ftptype)
def tc221(ftptype):
  return tc121(ftptype)
def tc222(ftptype):
  return tc122(ftptype)

def tc2000(ftptype):
  return tc1000(ftptype)
def tc2001(ftptype):
  return tc1001(ftptype)

#### Functions to build json messages and respones ####

# Function to build fixed beginning of an event
def getEventHead():
  return getEventHeadNodeName("oteNB5309")

def getEventHeadNodeName(nodename):
  headStr = """
        {
          "event": {
            "commonEventHeader": {
              "startEpochMicrosec": 8745745764578,
              "eventId": "FileReady_1797490e-10ae-4d48-9ea7-3d7d790b25e1",
              "timeZoneOffset": "UTC+05.30",
              "internalHeaderFields": {
                "collectorTimeStamp": "Tue, 09 18 2018 10:56:52 UTC"
              },
              "priority": "Normal",
              "version": "4.0.1",
              "reportingEntityName": \"""" + nodename + """",
              "sequence": 0,
              "domain": "notification",
              "lastEpochMicrosec": 8745745764578,
              "eventName": "Noti_RnNode-Ericsson_FileReady",
              "vesEventListenerVersion": "7.0.1",
              "sourceName": \"""" + nodename + """"
            },
            "notificationFields": {
              "notificationFieldsVersion": "2.0",
              "changeType": "FileReady",
              "changeIdentifier": "PM_MEAS_FILES",
              "arrayOfNamedHashMap": [
          """ 
  return headStr

# Function to build the variable part of an event
def getEventName(fn,type,user,passwd,ip,port):
    nameStr =        """{
                  "name": \"""" + fn + """",
                  "hashMap": {
                    "fileFormatType": "org.3GPP.32.435#measCollec",
                    "location": \"""" + type + """://""" + user + """:""" + passwd + """@""" + ip + """:""" + str(port) + """/""" + fn + """",
                    "fileFormatVersion": "V10",
                    "compression": "gzip"
                  }
                } """
    return nameStr

# Function to build fixed end of an event
def getEventEnd():
    endStr =  """
              ]
            }
          }
        }
        """
    return endStr

# Function to build an OK reponse from a message string
def buildOkResponse(msg):
  response = app.response_class(
      response=str.encode(msg),
      status=200,
      mimetype='application/json')
  return response

# Function to build an empty message with status
def buildEmptyResponse(status_code):
  response = app.response_class(
      response=str.encode(""),
      status=status_code,
      mimetype='application/json')
  return response


if __name__ == "__main__":
  
    #Counters
    ctr_responses = 0
    ctr_requests = 0
    ctr_unique_files = 0

    #Keeps all reponded file names
    fileMap = {}

    tc_num = "Not set"
    tc_help = "Not set"

    parser = argparse.ArgumentParser()

#SFTP TCs with single ME 
    parser.add_argument(
        '--tc100',
        action='store_true',
        help='TC100 - One ME, SFTP, 1 1MB file, 1 event')
    parser.add_argument(
        '--tc101',
        action='store_true',
        help='TC101 - One ME, SFTP, 1 5MB file, 1 event')
    parser.add_argument(
        '--tc102',
        action='store_true',
        help='TC102 - One ME, SFTP, 1 50MB file, 1 event')

    parser.add_argument(
        '--tc110',
        action='store_true',
        help='TC110 - One ME, SFTP, 1MB files, 1 file per event, 100 events, 1 event per poll.')
    parser.add_argument(
        '--tc111',
        action='store_true',
        help='TC111 - One ME, SFTP, 1MB files, 100 files per event, 100 events, 1 event per poll.')
    parser.add_argument(
        '--tc112',
        action='store_true',
        help='TC112 - One ME, SFTP, 5MB files, 100 files per event, 100 events, 1 event per poll.')
    parser.add_argument(
        '--tc113',
        action='store_true',
        help='TC113 - One ME, SFTP, 1MB files, 100 files per event, 100 events. All events in one poll.')

    parser.add_argument(
        '--tc120',
        action='store_true',
        help='TC120 - One ME, SFTP, 1MB files, 100 files per event, 100 events, 1 event per poll. 10% of replies each: no response, empty message, slow response, 404-error, malformed json')
    parser.add_argument(
        '--tc121',
        action='store_true',
        help='TC121 - One ME, SFTP, 1MB files, 100 files per event, 100 events, 1 event per poll. 10% missing files')
    parser.add_argument(
        '--tc122',
        action='store_true',
        help='TC122 - One ME, SFTP, 1MB files, 100 files per event, 100 events. 1 event per poll. All files with identical name. ')

    parser.add_argument(
        '--tc1000',
        action='store_true',
        help='TC1000 - One ME, SFTP, 1MB files, 100 files per event, endless number of events, 1 event per poll')
    parser.add_argument(
        '--tc1001',
        action='store_true',
        help='TC1001 - One ME, SFTP, 5MB files, 100 files per event, endless number of events, 1 event per poll')

# SFTP TCs with multiple MEs
    parser.add_argument(
        '--tc510',
        action='store_true',
        help='TC510 - 5 MEs, SFTP, 1MB files, 1 file per event, 100 events, 1 event per poll.')



# FTPS TCs with single ME
    parser.add_argument(
        '--tc200',
        action='store_true',
        help='TC200 - One ME, FTPS, 1 1MB file, 1 event')
    parser.add_argument(
        '--tc201',
        action='store_true',
        help='TC201 - One ME, FTPS, 1 5MB file, 1 event')
    parser.add_argument(
        '--tc202',
        action='store_true',
        help='TC202 - One ME, FTPS, 1 50MB file, 1 event')

    parser.add_argument(
        '--tc210',
        action='store_true',
        help='TC210 - One ME, FTPS, 1MB files, 1 file per event, 100 events, 1 event per poll.')
    parser.add_argument(
        '--tc211',
        action='store_true',
        help='TC211 - One ME, FTPS, 1MB files, 100 files per event, 100 events, 1 event per poll.')
    parser.add_argument(
        '--tc212',
        action='store_true',
        help='TC212 - One ME, FTPS, 5MB files, 100 files per event, 100 events, 1 event per poll.')
    parser.add_argument(
        '--tc213',
        action='store_true',
        help='TC213 - One ME, FTPS, 1MB files, 100 files per event, 100 events. All events in one poll.')

    parser.add_argument(
        '--tc220',
        action='store_true',
        help='TC220 - One ME, FTPS, 1MB files, 100 files per event, 100 events, 1 event per poll. 10% of replies each: no response, empty message, slow response, 404-error, malformed json')
    parser.add_argument(
        '--tc221',
        action='store_true',
        help='TC221 - One ME, FTPS, 1MB files, 100 files per event, 100 events, 1 event per poll. 10% missing files')
    parser.add_argument(
        '--tc222',
        action='store_true',
        help='TC222 - One ME, FTPS, 1MB files, 100 files per event, 100 events. 1 event per poll. All files with identical name. ')

    parser.add_argument(
        '--tc2000',
        action='store_true',
        help='TC2000 - One ME, FTPS, 1MB files, 100 files per event, endless number of events, 1 event per poll')
    parser.add_argument(
        '--tc2001',
        action='store_true',
        help='TC2001 - One ME, FTPS, 5MB files, 100 files per event, endless number of events, 1 event per poll')    

    parser.add_argument(
        '--tc610',
        action='store_true',
        help='TC510 - 5 MEs, FTPS, 1MB files, 1 file per event, 100 events, 1 event per poll.')

    args = parser.parse_args()

    

    if args.tc100:
        tc_num = "TC# 100"
    elif args.tc101:
        tc_num = "TC# 101"
    elif args.tc102:
        tc_num = "TC# 102"

    elif args.tc110:
        tc_num = "TC# 110"
    elif args.tc111:
        tc_num = "TC# 111"
    elif args.tc112:
        tc_num = "TC# 112"
    elif args.tc113:
        tc_num = "TC# 113"

    elif args.tc120:
        tc_num = "TC# 120"
    elif args.tc121:
        tc_num = "TC# 121"
    elif args.tc122:
        tc_num = "TC# 122"

    elif args.tc1000:
        tc_num = "TC# 1000"
    elif args.tc1001:
        tc_num = "TC# 1001"

    elif args.tc510:
        tc_num = "TC# 510"

    elif args.tc200:
        tc_num = "TC# 200"
    elif args.tc201:
        tc_num = "TC# 201"
    elif args.tc202:
        tc_num = "TC# 202"

    elif args.tc210:
        tc_num = "TC# 210"
    elif args.tc211:
        tc_num = "TC# 211"
    elif args.tc212:
        tc_num = "TC# 212"
    elif args.tc213:
        tc_num = "TC# 213"

    elif args.tc220:
        tc_num = "TC# 220"
    elif args.tc221:
        tc_num = "TC# 221"
    elif args.tc222:
        tc_num = "TC# 222"

    elif args.tc2000:
        tc_num = "TC# 2000"
    elif args.tc2001:
        tc_num = "TC# 2001"

    elif args.tc610:
        tc_num = "TC# 610"

    else:
        print("No TC was defined")
        print("use --help for usage info")
        sys.exit()

    print(tc_num)
 
    app.run(port=HOST_PORT, host=HOST_IP)
