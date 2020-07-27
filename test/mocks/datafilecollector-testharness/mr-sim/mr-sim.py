import argparse
import os
import sys
import time
from time import sleep

from flask import Flask

app = Flask(__name__)

# Server info
HOST_IP = "0.0.0.0"
HOST_PORT = 2222
HOST_PORT_TLS = 2223

sftp_hosts = []
sftp_ports = []
ftpes_hosts = []
ftpes_ports = []
num_ftp_servers = 1


def sumList(ctrArray):
    tmp = 0
    for i in range(len(ctrArray)):
        tmp = tmp + ctrArray[i]

    return str(tmp)


def sumListLength(ctrArray):
    tmp = 0
    for i in range(len(ctrArray)):
        tmp = tmp + len(ctrArray[i])

    return str(tmp)


# Test function to check server running
@app.route('/',
           methods=['GET'])
def index():
    return 'Hello world'


# Returns the list of configured groups
@app.route('/groups',
           methods=['GET'])
def group_ids():
    global configuredGroups
    return configuredGroups


# Returns the list of configured changeids
@app.route('/changeids',
           methods=['GET'])
def change_ids():
    global configuredChangeIds
    return configuredChangeIds


# Returns the list of configured fileprefixes
@app.route('/fileprefixes',
           methods=['GET'])
def fileprefixes():
    global configuredPrefixes
    return configuredPrefixes


# Returns number of polls
@app.route('/ctr_requests',
           methods=['GET'])
def counter_requests():
    global ctr_requests
    return sumList(ctr_requests)


# Returns number of polls for all groups
@app.route('/groups/ctr_requests',
           methods=['GET'])
def group_counter_requests():
    global ctr_requests
    global groupNames
    tmp = ''
    for i in range(len(groupNames)):
        if (i > 0):
            tmp = tmp + ','
        tmp = tmp + str(ctr_requests[i])
    return tmp


# Returns the total number of polls for a group
@app.route('/ctr_requests/<groupId>',
           methods=['GET'])
def counter_requests_group(groupId):
    global ctr_requests
    global groupNameIndexes
    return str(ctr_requests[groupNameIndexes[groupId]])


# Returns number of poll replies
@app.route('/ctr_responses',
           methods=['GET'])
def counter_responses():
    global ctr_responses
    return sumList(ctr_responses)


# Returns number of poll replies for all groups
@app.route('/groups/ctr_responses',
           methods=['GET'])
def group_counter_responses():
    global ctr_responses
    global groupNames
    tmp = ''
    for i in range(len(groupNames)):
        if (i > 0):
            tmp = tmp + ','
        tmp = tmp + str(ctr_responses[i])
    return tmp


# Returns the total number of poll replies for a group
@app.route('/ctr_responses/<groupId>',
           methods=['GET'])
def counter_responses_group(groupId):
    global ctr_responses
    global groupNameIndexes
    return str(ctr_responses[groupNameIndexes[groupId]])


# Returns the total number of files
@app.route('/ctr_files',
           methods=['GET'])
def counter_files():
    global ctr_files
    return sumList(ctr_files)


# Returns the total number of file for all groups
@app.route('/groups/ctr_files',
           methods=['GET'])
def group_counter_files():
    global ctr_files
    global groupNames
    tmp = ''
    for i in range(len(groupNames)):
        if (i > 0):
            tmp = tmp + ','
        tmp = tmp + str(ctr_files[i])
    return tmp


# Returns the total number of files for a group
@app.route('/ctr_files/<groupId>',
           methods=['GET'])
def counter_files_group(groupId):
    global ctr_files
    global groupNameIndexes
    return str(ctr_files[groupNameIndexes[groupId]])


# Returns number of unique files
@app.route('/ctr_unique_files',
           methods=['GET'])
def counter_uniquefiles():
    global fileMap
    return sumListLength(fileMap)


# Returns number of unique files for all groups
@app.route('/groups/ctr_unique_files',
           methods=['GET'])
def group_counter_uniquefiles():
    global fileMap
    global groupNames
    tmp = ''
    for i in range(len(groupNames)):
        if (i > 0):
            tmp = tmp + ','
        tmp = tmp + str(len(fileMap[i]))
    return tmp


# Returns the total number of unique files for a group
@app.route('/ctr_unique_files/<groupId>',
           methods=['GET'])
def counter_uniquefiles_group(groupId):
    global fileMap
    global groupNameIndexes
    return str(len(fileMap[groupNameIndexes[groupId]]))


# Returns tc info
@app.route('/tc_info',
           methods=['GET'])
def testcase_info():
    global tc_num
    return tc_num


# Returns number of events
@app.route('/ctr_events',
           methods=['GET'])
def counter_events():
    global ctr_events
    return sumList(ctr_events)


# Returns number of events for all groups
@app.route('/groups/ctr_events',
           methods=['GET'])
def group_counter_events():
    global ctr_events
    global groupNames
    tmp = ''
    for i in range(len(groupNames)):
        if (i > 0):
            tmp = tmp + ','
        tmp = tmp + str(ctr_events[i])
    return tmp


# Returns the total number of events for a group
@app.route('/ctr_events/<groupId>',
           methods=['GET'])
def counter_events_group(groupId):
    global ctr_events
    global groupNameIndexes
    return str(ctr_events[groupNameIndexes[groupId]])


# Returns execution time in mm:ss
@app.route('/execution_time',
           methods=['GET'])
def exe_time():
    global startTime

    stopTime = time.time()
    minutes, seconds = divmod(stopTime - startTime, 60)
    return "{:0>2}:{:0>2}".format(int(minutes), int(seconds))


# Returns the timestamp for first poll
@app.route('/exe_time_first_poll',
           methods=['GET'])
def exe_time_first_poll():
    global firstPollTime

    tmp = 0
    for i in range(len(groupNames)):
        if (firstPollTime[i] > tmp):
            tmp = firstPollTime[i]

    if (tmp == 0):
        return "--:--"
    minutes, seconds = divmod(time.time() - tmp, 60)
    return "{:0>2}:{:0>2}".format(int(minutes), int(seconds))


# Returns the timestamp for first poll for all groups
@app.route('/groups/exe_time_first_poll',
           methods=['GET'])
def group_exe_time_first_poll():
    global firstPollTime
    global groupNames

    tmp = ''
    for i in range(len(groupNames)):
        if (i > 0):
            tmp = tmp + ','
        if (firstPollTime[i] == 0):
            tmp = tmp + "--:--"
        else:
            minutes, seconds = divmod(time.time() - firstPollTime[i], 60)
            tmp = tmp + "{:0>2}:{:0>2}".format(int(minutes), int(seconds))
    return tmp


# Returns the timestamp for first poll for a group
@app.route('/exe_time_first_poll/<groupId>',
           methods=['GET'])
def exe_time_first_poll_group(groupId):
    global ctr_requests
    global groupNameIndexes

    if (firstPollTime[groupNameIndexes[groupId]] == 0):
        return "--:--"
    minutes, seconds = divmod(time.time() - firstPollTime[groupNameIndexes[groupId]], 60)
    return "{:0>2}:{:0>2}".format(int(minutes), int(seconds))


# Starts event delivery
@app.route('/start',
           methods=['GET'])
def start():
    global runningState
    runningState = "Started"
    return runningState


# Stops event delivery
@app.route('/stop',
           methods=['GET'])
def stop():
    global runningState
    runningState = "Stopped"
    return runningState


# Returns the running state
@app.route('/status',
           methods=['GET'])
def status():
    global runningState
    return runningState


# Returns number of unique PNFs
@app.route('/ctr_unique_PNFs',
           methods=['GET'])
def counter_uniquePNFs():
    global pnfMap
    return sumListLength(pnfMap)


# Returns number of unique PNFs for all groups
@app.route('/groups/ctr_unique_PNFs',
           methods=['GET'])
def group_counter_uniquePNFs():
    global pnfMap
    global groupNames
    tmp = ''
    for i in range(len(groupNames)):
        if (i > 0):
            tmp = tmp + ','
        tmp = tmp + str(len(pnfMap[i]))
    return tmp


# Returns the unique PNFs for a group
@app.route('/ctr_unique_PNFs/<groupId>',
           methods=['GET'])
def counter_uniquePNFs_group(groupId):
    global pnfMap
    global groupNameIndexes
    return str(len(pnfMap[groupNameIndexes[groupId]]))


# Messages polling function
@app.route(
    "/events/unauthenticated.VES_NOTIFICATION_OUTPUT/<consumerGroup>/<consumerId>",
    methods=['GET'])
def MR_reply(consumerGroup, consumerId):
    global ctr_requests
    global ctr_responses
    global args
    global runningState
    global firstPollTime
    global groupNameIndexes
    global changeIds
    global filePrefixes
    print("Received request at /events/unauthenticated.VES_NOTIFICATION_OUTPUT/ for consumerGroup: " + consumerGroup +
          " with consumerId: " + consumerId)

    groupIndex = groupNameIndexes[consumerGroup]
    print("Setting groupIndex: " + str(groupIndex))

    reqCtr = ctr_requests[groupIndex]
    changeId = changeIds[groupIndex][reqCtr % len(changeIds[groupIndex])]
    print("Setting changeid: " + changeId)
    filePrefix = filePrefixes[changeId]
    print("Setting file name prefix: " + filePrefix)

    if (firstPollTime[groupIndex] == 0):
        firstPollTime[groupIndex] = time.time()

    ctr_requests[groupIndex] = ctr_requests[groupIndex] + 1
    print("MR: poll request#: " + str(ctr_requests[groupIndex]))

    if (runningState == "Stopped"):
        ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1
        return buildOkResponse("[]")

    if args.tc100:
        return tc100(groupIndex, changeId, filePrefix, "sftp", "1MB")
    elif args.tc101:
        return tc100(groupIndex, changeId, filePrefix, "sftp", "5MB")
    elif args.tc102:
        return tc100(groupIndex, changeId, filePrefix, "sftp", "50MB")

    elif args.tc110:
        return tc110(groupIndex, changeId, filePrefix, "sftp")
    elif args.tc111:
        return tc111(groupIndex, changeId, filePrefix, "sftp")
    elif args.tc112:
        return tc112(groupIndex, changeId, filePrefix, "sftp")
    elif args.tc113:
        return tc113(groupIndex, changeId, filePrefix, "sftp")

    elif args.tc120:
        return tc120(groupIndex, changeId, filePrefix, "sftp")
    elif args.tc121:
        return tc121(groupIndex, changeId, filePrefix, "sftp")
    elif args.tc122:
        return tc122(groupIndex, changeId, filePrefix, "sftp")

    elif args.tc1000:
        return tc1000(groupIndex, changeId, filePrefix, "sftp")
    elif args.tc1001:
        return tc1001(groupIndex, changeId, filePrefix, "sftp")

    elif args.tc1100:
        return tc1100(groupIndex, changeId, filePrefix, "sftp", "1MB")
    elif args.tc1101:
        return tc1100(groupIndex, changeId, filePrefix, "sftp", "50MB")
    elif args.tc1102:
        return tc1100(groupIndex, changeId, filePrefix, "sftp", "50MB")
    elif args.tc1200:
        return tc1200(groupIndex, changeId, filePrefix, "sftp", "1MB")
    elif args.tc1201:
        return tc1200(groupIndex, changeId, filePrefix, "sftp", "5MB")
    elif args.tc1202:
        return tc1200(groupIndex, changeId, filePrefix, "sftp", "50MB")
    elif args.tc1300:
        return tc1300(groupIndex, changeId, filePrefix, "sftp", "1MB")
    elif args.tc1301:
        return tc1300(groupIndex, changeId, filePrefix, "sftp", "5MB")
    elif args.tc1302:
        return tc1300(groupIndex, changeId, filePrefix, "sftp", "50MB")

    elif args.tc1500:
        return tc1500(groupIndex, changeId, filePrefix, "sftp", "1MB")

    elif args.tc500:
        return tc500(groupIndex, changeId, filePrefix, "sftp", "1MB")
    elif args.tc501:
        return tc500(groupIndex, changeId, filePrefix, "sftp", "5MB")
    elif args.tc502:
        return tc500(groupIndex, changeId, filePrefix, "sftp", "50MB")
    elif args.tc510:
        return tc510(groupIndex, changeId, filePrefix, "sftp", "1MB")
    elif args.tc511:
        return tc511(groupIndex, changeId, filePrefix, "sftp", "1KB")

    elif args.tc550:
        return tc510(groupIndex, changeId, filePrefix, "sftp", "50MB")

    elif args.tc710:
        return tc710(groupIndex, changeId, filePrefix, "sftp")


    elif args.tc200:
        return tc100(groupIndex, changeId, filePrefix, "ftpes", "1MB")
    elif args.tc201:
        return tc100(groupIndex, changeId, filePrefix, "ftpes", "5MB")
    elif args.tc202:
        return tc100(groupIndex, changeId, filePrefix, "ftpes", "50MB")

    elif args.tc210:
        return tc110(groupIndex, changeId, filePrefix, "ftpes")
    elif args.tc211:
        return tc111(groupIndex, changeId, filePrefix, "ftpes")
    elif args.tc212:
        return tc112(groupIndex, changeId, filePrefix, "ftpes")
    elif args.tc213:
        return tc113(groupIndex, changeId, filePrefix, "ftpes")

    elif args.tc220:
        return tc120(groupIndex, changeId, filePrefix, "ftpes")
    elif args.tc221:
        return tc121(groupIndex, changeId, filePrefix, "ftpes")
    elif args.tc222:
        return tc122(groupIndex, changeId, filePrefix, "ftpes")

    elif args.tc2000:
        return tc1000(groupIndex, changeId, filePrefix, "ftpes")
    elif args.tc2001:
        return tc1001(groupIndex, changeId, filePrefix, "ftpes")

    elif args.tc2100:
        return tc1100(groupIndex, changeId, filePrefix, "ftpes", "1MB")
    elif args.tc2101:
        return tc1100(groupIndex, changeId, filePrefix, "ftpes", "50MB")
    elif args.tc2102:
        return tc1100(groupIndex, changeId, filePrefix, "ftpes", "50MB")
    elif args.tc2200:
        return tc1200(groupIndex, changeId, filePrefix, "ftpes", "1MB")
    elif args.tc2201:
        return tc1200(groupIndex, changeId, filePrefix, "ftpes", "5MB")
    elif args.tc2202:
        return tc1200(groupIndex, changeId, filePrefix, "ftpes", "50MB")
    elif args.tc2300:
        return tc1300(groupIndex, changeId, filePrefix, "ftpes", "1MB")
    elif args.tc2301:
        return tc1300(groupIndex, changeId, filePrefix, "ftpes", "5MB")
    elif args.tc2302:
        return tc1300(groupIndex, changeId, filePrefix, "ftpes", "50MB")

    elif args.tc2500:
        return tc1500(groupIndex, changeId, filePrefix, "ftpes", "1MB")

    elif args.tc600:
        return tc500(groupIndex, changeId, filePrefix, "ftpes", "1MB")
    elif args.tc601:
        return tc500(groupIndex, changeId, filePrefix, "ftpes", "5MB")
    elif args.tc602:
        return tc500(groupIndex, changeId, filePrefix, "ftpes", "50MB")
    elif args.tc610:
        return tc510(groupIndex, changeId, filePrefix, "ftpes", "1MB")
    elif args.tc611:
        return tc511(groupIndex, changeId, filePrefix, "ftpes", "1KB")
    elif args.tc650:
        return tc510(groupIndex, changeId, filePrefix, "ftpes", "50MB")
    elif args.tc810:
        return tc710(groupIndex, changeId, filePrefix, "ftpes")


#### Test case functions


def tc100(groupIndex, changeId, filePrefix, ftpType, fileSize):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 1):
        return buildOkResponse("[]")

    seqNr = (ctr_responses[groupIndex] - 1)
    nodeIndex = 0
    nodeName = createNodeName(nodeIndex)
    fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, fileSize)
    msg = getEventHead(groupIndex, changeId, nodeName) + getEventName(fileName, ftpType, "onap", "pano",
                                                                      nodeIndex) + getEventEnd()
    fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr
    ctr_events[groupIndex] = ctr_events[groupIndex] + 1
    return buildOkResponse("[" + msg + "]")


# def tc101(groupIndex, ftpType):
#  global ctr_responses
#  global ctr_events
#
#  ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1
#
#  if (ctr_responses[groupIndex] > 1):
#    return buildOkResponse("[]")
#
#  seqNr = (ctr_responses[groupIndex]-1)
#  nodeName = createNodeName(0)
#  fileName = createFileName(groupIndex, nodeName, seqNr, "5MB")
#  msg = getEventHead(groupIndex, nodeName) + getEventName(fileName,ftpType,"onap","pano") + getEventEnd()
#  fileMap[groupIndex][seqNr] = seqNr
#  ctr_events[groupIndex] = ctr_events[groupIndex]+1
#  return buildOkResponse("["+msg+"]")
#
# def tc102(groupIndex, ftpType):
#  global ctr_responses
#  global ctr_events
#
#  ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1
#
#  if (ctr_responses[groupIndex] > 1):
#    return buildOkResponse("[]")
#
#  seqNr = (ctr_responses[groupIndex]-1)
#  nodeName = createNodeName(0)
#  fileName = createFileName(groupIndex, nodeName, seqNr, "50MB")
#  msg = getEventHead(groupIndex, nodeName) + getEventName(fileName,ftpType,"onap","pano") + getEventEnd()
#  fileMap[groupIndex][seqNr] = seqNr
#  ctr_events[groupIndex] = ctr_events[groupIndex]+1
#  return buildOkResponse("["+msg+"]")

def tc110(groupIndex, changeId, filePrefix, ftpType):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 100):
        return buildOkResponse("[]")

    seqNr = (ctr_responses[groupIndex] - 1)
    nodeIndex = 0
    nodeName = createNodeName(nodeIndex)
    fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, "1MB")
    msg = getEventHead(groupIndex, changeId, nodeName) + getEventName(fileName, ftpType, "onap", "pano",
                                                                      nodeIndex) + getEventEnd()
    fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr
    ctr_events[groupIndex] = ctr_events[groupIndex] + 1
    return buildOkResponse("[" + msg + "]")


def tc111(groupIndex, changeId, filePrefix, ftpType):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 100):
        return buildOkResponse("[]")

    nodeIndex = 0
    nodeName = createNodeName(nodeIndex)
    msg = getEventHead(groupIndex, changeId, nodeName)

    for i in range(100):
        seqNr = i + (ctr_responses[groupIndex] - 1)
        if i != 0: msg = msg + ","
        fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, "1MB")
        msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
        fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

    msg = msg + getEventEnd()
    ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc112(groupIndex, changeId, filePrefix, ftpType):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 100):
        return buildOkResponse("[]")

    nodeIndex = 0
    nodeName = createNodeName(nodeIndex)
    msg = getEventHead(groupIndex, changeId, nodeName)

    for i in range(100):
        seqNr = i + (ctr_responses[groupIndex] - 1)
        if i != 0: msg = msg + ","
        fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, "5MB")
        msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
        fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

    msg = msg + getEventEnd()
    ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc113(groupIndex, changeId, filePrefix, ftpType):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 1):
        return buildOkResponse("[]")

    nodeIndex = 0
    nodeName = createNodeName(nodeIndex)
    msg = ""

    for evts in range(100):  # build 100 evts
        if (evts > 0):
            msg = msg + ","
        msg = msg + getEventHead(groupIndex, changeId, nodeName)
        for i in range(100):  # build 100 files
            seqNr = i + evts + 100 * (ctr_responses[groupIndex] - 1)
            if i != 0: msg = msg + ","
            fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, "1MB")
            msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
            fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

        msg = msg + getEventEnd()
        ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc120(groupIndex, changeId, filePrefix, ftpType):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    nodeIndex = 0
    nodeName = createNodeName(nodeIndex)

    if (ctr_responses[groupIndex] > 100):
        return buildOkResponse("[]")

    if (ctr_responses[groupIndex] % 10 == 2):
        return  # Return nothing

    if (ctr_responses[groupIndex] % 10 == 3):
        return buildOkResponse("")  # Return empty message

    if (ctr_responses[groupIndex] % 10 == 4):
        return buildOkResponse(getEventHead(groupIndex, changeId, nodeName))  # Return part of a json event

    if (ctr_responses[groupIndex] % 10 == 5):
        return buildEmptyResponse(404)  # Return empty message with status code

    if (ctr_responses[groupIndex] % 10 == 6):
        sleep(60)

    msg = getEventHead(groupIndex, changeId, nodeName)

    for i in range(100):
        seqNr = i + (ctr_responses[groupIndex] - 1)
        if i != 0: msg = msg + ","
        fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, "1MB")
        msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
        fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

    msg = msg + getEventEnd()
    ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc121(groupIndex, changeId, filePrefix, ftpType):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 100):
        return buildOkResponse("[]")

    nodeIndex = 0
    nodeName = createNodeName(nodeIndex)
    msg = getEventHead(groupIndex, changeId, nodeName)

    fileName = ""
    for i in range(100):
        seqNr = i + (ctr_responses[groupIndex] - 1)
        if (seqNr % 10 == 0):  # Every 10th file is "missing"
            fileName = createMissingFileName(groupIndex, filePrefix, nodeName, seqNr, "1MB")
        else:
            fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, "1MB")
            fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

        if i != 0: msg = msg + ","
        msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)

    msg = msg + getEventEnd()
    ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc122(groupIndex, changeId, filePrefix, ftpType):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 100):
        return buildOkResponse("[]")

    nodeIndex = 0
    nodeName = createNodeName(nodeIndex)
    msg = getEventHead(groupIndex, changeId, nodeName)

    for i in range(100):
        fileName = createFileName(groupIndex, filePrefix, nodeName, 0, "1MB")  # All files identical names
        if i != 0: msg = msg + ","
        msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)

    fileMap[groupIndex][0] = 0
    msg = msg + getEventEnd()
    ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc1000(groupIndex, changeId, filePrefix, ftpType):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    nodeIndex = 0
    nodeName = createNodeName(nodeIndex)
    msg = getEventHead(groupIndex, changeId, nodeName)

    for i in range(100):
        seqNr = i + (ctr_responses[groupIndex] - 1)
        if i != 0: msg = msg + ","
        fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, "1MB")
        msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
        fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

    msg = msg + getEventEnd()
    ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc1001(groupIndex, changeId, filePrefix, ftpType):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    nodeIndex = 0
    nodeName = createNodeName(nodeIndex)
    msg = getEventHead(groupIndex, changeId, nodeName)

    for i in range(100):
        seqNr = i + (ctr_responses[groupIndex] - 1)
        if i != 0: msg = msg + ","
        fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, "5MB")
        msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
        fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

    msg = msg + getEventEnd()
    ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc1100(groupIndex, changeId, filePrefix, ftpType, filesize):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    msg = ""

    batch = (ctr_responses[groupIndex] - 1) % 20

    for pnfs in range(35):  # build events for 35 PNFs at a time. 20 batches -> 700
        if (pnfs > 0):
            msg = msg + ","
        nodeIndex = pnfs + batch * 35
        nodeName = createNodeName(nodeIndex)
        msg = msg + getEventHead(groupIndex, changeId, nodeName)

        for i in range(100):  # 100 files per event
            seqNr = i + int((ctr_responses[groupIndex] - 1) / 20)
            if i != 0: msg = msg + ","
            fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, filesize)
            msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
            seqNr = seqNr + (pnfs + batch * 35) * 1000000  # Create unique id for this node and file
            fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

        msg = msg + getEventEnd()
        ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc1200(groupIndex, changeId, filePrefix, ftpType, filesize):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    msg = ""

    batch = (ctr_responses[groupIndex] - 1) % 20

    for pnfs in range(35):  # build events for 35 PNFs at a time. 20 batches -> 700
        if (pnfs > 0):
            msg = msg + ","
        nodeIndex = pnfs + batch * 35
        nodeName = createNodeName(nodeIndex)
        msg = msg + getEventHead(groupIndex, changeId, nodeName)

        for i in range(100):  # 100 files per event, all new files
            seqNr = i + 100 * int((ctr_responses[groupIndex] - 1) / 20)
            if i != 0: msg = msg + ","
            fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, filesize)
            msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
            seqNr = seqNr + (pnfs + batch * 35) * 1000000  # Create unique id for this node and file
            fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

        msg = msg + getEventEnd()
        ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc1300(groupIndex, changeId, filePrefix, ftpType, filesize):
    global ctr_responses
    global ctr_events
    global rop_counter
    global rop_timestamp

    if (rop_counter == 0):
        rop_timestamp = time.time()

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    # Start a  event deliver for all 700 nodes every 15min
    rop = time.time() - rop_timestamp
    if ((rop < 900) & (rop_counter % 20 == 0) & (rop_counter != 0)):
        return buildOkResponse("[]")
    else:
        if (rop_counter % 20 == 0) & (rop_counter > 0):
            rop_timestamp = rop_timestamp + 900

        rop_counter = rop_counter + 1

    msg = ""

    batch = (rop_counter - 1) % 20

    for pnfs in range(35):  # build events for 35 PNFs at a time. 20 batches -> 700
        if (pnfs > 0):
            msg = msg + ","
        nodeIndex = pnfs + batch * 35
        nodeName = createNodeName(nodeIndex)
        msg = msg + getEventHead(groupIndex, changeId, nodeName)

        for i in range(100):  # 100 files per event
            seqNr = i + int((rop_counter - 1) / 20)
            if i != 0: msg = msg + ","
            fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, filesize)
            msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
            seqNr = seqNr + (pnfs + batch * 35) * 1000000  # Create unique id for this node and file
            fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

        msg = msg + getEventEnd()
        ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc1500(groupIndex, changeId, filePrefix, ftpType, filesize):
    global ctr_responses
    global ctr_events
    global rop_counter
    global rop_timestamp

    if (rop_counter == 0):
        rop_timestamp = time.time()

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] <= 2000):  # first 25h of event doess not care of 15min rop timer

        msg = ""

        batch = (ctr_responses[groupIndex] - 1) % 20

        for pnfs in range(35):  # build events for 35 PNFs at a time. 20 batches -> 700
            if (pnfs > 0):
                msg = msg + ","

            nodeIndex = pnfs + batch * 35
            nodeName = createNodeName(nodeIndex)
            msg = msg + getEventHead(groupIndex, changeId, nodeName)

            for i in range(100):  # 100 files per event
                seqNr = i + int((ctr_responses[groupIndex] - 1) / 20)
                if i != 0: msg = msg + ","
                if (seqNr < 100):
                    fileName = createMissingFileName(groupIndex, filePrefix, nodeName, seqNr, "1MB")
                else:
                    fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, "1MB")
                    seqNr = seqNr + (pnfs + batch * 35) * 1000000  # Create unique id for this node and file
                    fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr
                msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)

            msg = msg + getEventEnd()
            ctr_events[groupIndex] = ctr_events[groupIndex] + 1

            rop_counter = rop_counter + 1
        return buildOkResponse("[" + msg + "]")

    # Start an event delivery for all 700 nodes every 15min
    rop = time.time() - rop_timestamp
    if ((rop < 900) & (rop_counter % 20 == 0) & (rop_counter != 0)):
        return buildOkResponse("[]")
    else:
        if (rop_counter % 20 == 0):
            rop_timestamp = time.time()

        rop_counter = rop_counter + 1

    msg = ""

    batch = (rop_counter - 1) % 20

    for pnfs in range(35):  # build events for 35 PNFs at a time. 20 batches -> 700
        if (pnfs > 0):
            msg = msg + ","
        nodeIndex = pnfs + batch * 35
        nodeName = createNodeName(nodeIndex)
        msg = msg + getEventHead(groupIndex, changeId, nodeName)

        for i in range(100):  # 100 files per event
            seqNr = i + int((rop_counter - 1) / 20)
            if i != 0: msg = msg + ","
            fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, filesize)
            msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
            seqNr = seqNr + (pnfs + batch * 35) * 1000000  # Create unique id for this node and file
            fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

        msg = msg + getEventEnd()
        ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc500(groupIndex, changeId, filePrefix, ftpType, filesize):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 1):
        return buildOkResponse("[]")

    msg = ""

    for pnfs in range(700):
        if (pnfs > 0):
            msg = msg + ","
        nodeName = createNodeName(pnfs)
        msg = msg + getEventHead(groupIndex, changeId, nodeName)

        for i in range(2):
            seqNr = i
            if i != 0: msg = msg + ","
            fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, filesize)
            msg = msg + getEventName(fileName, ftpType, "onap", "pano", pnfs)
            seqNr = seqNr + pnfs * 1000000  # Create unique id for this node and file
            fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

        msg = msg + getEventEnd()
        ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc510(groupIndex, changeId, filePrefix, ftpType, fileSize):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 5):
        return buildOkResponse("[]")

    msg = ""

    for pnfs in range(700):  # build events for 700 MEs
        if (pnfs > 0):
            msg = msg + ","
        nodeName = createNodeName(pnfs)
        msg = msg + getEventHead(groupIndex, changeId, nodeName)
        seqNr = (ctr_responses[groupIndex] - 1)
        fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, fileSize)
        msg = msg + getEventName(fileName, ftpType, "onap", "pano", pnfs)
        seqNr = seqNr + pnfs * 1000000  # Create unique id for this node and file
        fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr
        msg = msg + getEventEnd()
        ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc511(groupIndex, changeId, filePrefix, ftpType, fileSize):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 5):
        return buildOkResponse("[]")

    msg = ""

    for pnfs in range(700):  # build events for 700 MEs
        if (pnfs > 0):
            msg = msg + ","
        nodeName = createNodeName(pnfs)
        msg = msg + getEventHead(groupIndex, changeId, nodeName)
        seqNr = (ctr_responses[groupIndex] - 1)
        fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, fileSize)
        msg = msg + getEventName(fileName, ftpType, "onap", "pano", pnfs)
        seqNr = seqNr + pnfs * 1000000  # Create unique id for this node and file
        fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr
        msg = msg + getEventEnd()
        ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


def tc710(groupIndex, changeId, filePrefix, ftpType):
    global ctr_responses
    global ctr_events

    ctr_responses[groupIndex] = ctr_responses[groupIndex] + 1

    if (ctr_responses[groupIndex] > 100):
        return buildOkResponse("[]")

    msg = ""

    batch = (ctr_responses[groupIndex] - 1) % 20

    for pnfs in range(35):  # build events for 35 PNFs at a time. 20 batches -> 700
        if (pnfs > 0):
            msg = msg + ","
        nodeIndex = pnfs + batch * 35
        nodeName = createNodeName(nodeIndex)
        msg = msg + getEventHead(groupIndex, changeId, nodeName)

        for i in range(100):  # 100 files per event
            seqNr = i + int((ctr_responses[groupIndex] - 1) / 20)
            if i != 0: msg = msg + ","
            fileName = createFileName(groupIndex, filePrefix, nodeName, seqNr, "1MB")
            msg = msg + getEventName(fileName, ftpType, "onap", "pano", nodeIndex)
            seqNr = seqNr + (pnfs + batch * 35) * 1000000  # Create unique id for this node and file
            fileMap[groupIndex][seqNr * hash(filePrefix)] = seqNr

        msg = msg + getEventEnd()
        ctr_events[groupIndex] = ctr_events[groupIndex] + 1

    return buildOkResponse("[" + msg + "]")


#### Functions to build json messages and respones ####

def createNodeName(index):
    return "PNF" + str(index)


def createFileName(groupIndex, filePrefix, nodeName, index, size):
    global ctr_files
    ctr_files[groupIndex] = ctr_files[groupIndex] + 1
    return filePrefix + "20000626.2315+0200-2330+0200_" + nodeName + "-" + str(index) + "-" + size + ".tar.gz"


def createMissingFileName(groupIndex, filePrefix, nodeName, index, size):
    global ctr_files
    ctr_files[groupIndex] = ctr_files[groupIndex] + 1
    return filePrefix + "MissingFile_" + nodeName + "-" + str(index) + "-" + size + ".tar.gz"


# Function to build fixed beginning of an event

def getEventHead(groupIndex, changeId, nodename):
    global pnfMap
    pnfMap[groupIndex].add(nodename)
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
              "changeIdentifier": \"""" + changeId + """",
              "arrayOfNamedHashMap": [
          """
    return headStr


# Function to build the variable part of an event
def getEventName(fn, type, user, passwd, nodeIndex):
    nodeIndex = nodeIndex % num_ftp_servers
    port = sftp_ports[nodeIndex]
    ip = sftp_hosts[nodeIndex]
    if (type == "ftpes"):
        port = ftpes_ports[nodeIndex]
        ip = ftpes_hosts[nodeIndex]

    nameStr = """{
                  "name": \"""" + fn + """",
                  "hashMap": {
                    "fileFormatType": "org.3GPP.32.435#measCollec",
                    "location": \"""" + type + """://""" + user + """:""" + passwd + """@""" + ip + """:""" + str(
        port) + """/""" + fn + """",
                    "fileFormatVersion": "V10",
                    "compression": "gzip"
                  }
                } """
    return nameStr


# Function to build fixed end of an event
def getEventEnd():
    endStr = """
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

    # IP addresses to use for ftp servers, using localhost if not env var is set
    sftp_sims = os.environ.get('SFTP_SIMS', 'localhost:1022')
    ftpes_sims = os.environ.get('FTPES_SIMS', 'localhost:21')
    num_ftp_servers = int(os.environ.get('NUM_FTP_SERVERS', 1))

    print("Configured sftp sims: " + sftp_sims)
    print("Configured ftpes sims: " + ftpes_sims)
    print("Configured number of ftp servers: " + str(num_ftp_servers))

    tmp = sftp_sims.split(',')
    for i in range(len(tmp)):
        hp = tmp[i].split(':')
        sftp_hosts.append(hp[0])
        sftp_ports.append(hp[1])

    tmp = ftpes_sims.split(',')
    for i in range(len(tmp)):
        hp = tmp[i].split(':')
        ftpes_hosts.append(hp[0])
        ftpes_ports.append(hp[1])

    groups = os.environ.get('MR_GROUPS', 'OpenDcae-c12:PM_MEAS_FILES')
    print("Groups detected: " + groups)
    configuredPrefixes = os.environ.get('MR_FILE_PREFIX_MAPPING', 'PM_MEAS_FILES:A')

    if not groups:
        groups = 'OpenDcae-c12:PM_MEAS_FILES'
        print("Using default group: " + groups)
    else:
        print("Configured groups: " + groups)

    if not configuredPrefixes:
        configuredPrefixes = 'PM_MEAS_FILES:A'
        print("Using default changeid to file prefix mapping: " + configuredPrefixes)
    else:
        print("Configured changeid to file prefix mapping: " + configuredPrefixes)

    # Counters
    ctr_responses = []
    ctr_requests = []
    ctr_files = []
    ctr_events = []
    startTime = time.time()
    firstPollTime = []
    runningState = "Started"
    # Keeps all responded file names
    fileMap = []
    # Keeps all responded PNF names
    pnfMap = []
    # Handles rop periods for tests that deliveres events every 15 min
    rop_counter = 0
    rop_timestamp = time.time()

    # List of configured group names
    groupNames = []
    # Mapping between group name and index in groupNames
    groupNameIndexes = {}
    # String of configured groups
    configuredGroups = ""
    # String of configured change identifiers
    configuredChangeIds = ""
    # List of changed identifiers
    changeIds = []
    # List of filePrefixes
    filePrefixes = {}

    tmp = groups.split(',')
    for i in range(len(tmp)):
        g = tmp[i].split(':')
        for j in range(len(g)):
            g[j] = g[j].strip()
            if (j == 0):
                if configuredGroups:
                    configuredGroups = configuredGroups + ","
                configuredGroups = configuredGroups + g[0]
                groupNames.append(g[0])
                groupNameIndexes[g[0]] = i
                changeIds.append({})
                ctr_responses.append(0)
                ctr_requests.append(0)
                ctr_files.append(0)
                ctr_events.append(0)
                firstPollTime.append(0)
                pnfMap.append(set())
                fileMap.append({})
                if configuredGroups:
                    configuredChangeIds = configuredChangeIds + ","
            else:
                changeIds[i][j - 1] = g[j]
                if (j > 1):
                    configuredChangeIds = configuredChangeIds + ":"
                configuredChangeIds = configuredChangeIds + g[j]

    # Create a map between changeid and file name prefix
    tmp = configuredPrefixes.split(',')
    for i in range(len(tmp)):
        p = tmp[i].split(':')
        filePrefixes[p[0]] = p[1]

    tc_num = "Not set"
    tc_help = "Not set"

    parser = argparse.ArgumentParser()

    # SFTP TCs with single ME
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
        '--tc500',
        action='store_true',
        help='TC500 - 700 MEs, SFTP, 1MB files, 2 new files per event, 700 events, all event in one poll.')

    parser.add_argument(
        '--tc501',
        action='store_true',
        help='TC501 - 700 MEs, SFTP, 5MB files, 2 new files per event, 700 events, all event in one poll.')

    parser.add_argument(
        '--tc502',
        action='store_true',
        help='TC502 - 700 MEs, SFTP, 50MB files, 2 new files per event, 700 events, all event in one poll.')

    parser.add_argument(
        '--tc510',
        action='store_true',
        help='TC510 - 700 MEs, SFTP, 1MB files, 1 file per event, 3500 events, 700 event per poll.')

    parser.add_argument(
        '--tc511',
        action='store_true',
        help='TC511 - 700 MEs, SFTP, 1KB files, 1 file per event, 3500 events, 700 event per poll.')

    parser.add_argument(
        '--tc550',
        action='store_true',
        help='TC550 - 700 MEs, SFTP, 50MB files, 1 file per event, 3500 events, 700 event per poll.')

    parser.add_argument(
        '--tc710',
        action='store_true',
        help='TC710 - 700 MEs, SFTP, 1MB files, 100 files per event, 3500 events, 35 event per poll.')

    parser.add_argument(
        '--tc1100',
        action='store_true',
        help='TC1100 - 700 ME, SFTP, 1MB files, 100 files per event, endless number of events, 35 event per poll')
    parser.add_argument(
        '--tc1101',
        action='store_true',
        help='TC1101 - 700 ME, SFTP, 5MB files, 100 files per event, endless number of events, 35 event per poll')
    parser.add_argument(
        '--tc1102',
        action='store_true',
        help='TC1102 - 700 ME, SFTP, 50MB files, 100 files per event, endless number of events, 35 event per poll')

    parser.add_argument(
        '--tc1200',
        action='store_true',
        help='TC1200 - 700 ME, SFTP, 1MB files, 100 new files per event, endless number of events, 35 event per poll')
    parser.add_argument(
        '--tc1201',
        action='store_true',
        help='TC1201 - 700 ME, SFTP, 5MB files, 100 new files per event, endless number of events, 35 event per poll')
    parser.add_argument(
        '--tc1202',
        action='store_true',
        help='TC1202 - 700 ME, SFTP, 50MB files, 100 new files per event, endless number of events, 35 event per poll')

    parser.add_argument(
        '--tc1300',
        action='store_true',
        help='TC1300 - 700 ME, SFTP, 1MB files, 100 files per event, endless number of events, 35 event per poll, 20 event polls every 15min')
    parser.add_argument(
        '--tc1301',
        action='store_true',
        help='TC1301 - 700 ME, SFTP, 5MB files, 100 files per event, endless number of events, 35 event per poll, 20 event polls every 15min')
    parser.add_argument(
        '--tc1302',
        action='store_true',
        help='TC1302 - 700 ME, SFTP, 50MB files, 100 files per event, endless number of events, 35 event per poll, 20 event polls every 15min')

    parser.add_argument(
        '--tc1500',
        action='store_true',
        help='TC1500 - 700 ME, SFTP, 1MB files, 100 files per event, 35 events per poll, simulating 25h backlog of decreasing number of outdated files and then 20 event polls every 15min for 1h')

    # FTPES TCs with single ME
    parser.add_argument(
        '--tc200',
        action='store_true',
        help='TC200 - One ME, FTPES, 1 1MB file, 1 event')
    parser.add_argument(
        '--tc201',
        action='store_true',
        help='TC201 - One ME, FTPES, 1 5MB file, 1 event')
    parser.add_argument(
        '--tc202',
        action='store_true',
        help='TC202 - One ME, FTPES, 1 50MB file, 1 event')

    parser.add_argument(
        '--tc210',
        action='store_true',
        help='TC210 - One ME, FTPES, 1MB files, 1 file per event, 100 events, 1 event per poll.')
    parser.add_argument(
        '--tc211',
        action='store_true',
        help='TC211 - One ME, FTPES, 1MB files, 100 files per event, 100 events, 1 event per poll.')
    parser.add_argument(
        '--tc212',
        action='store_true',
        help='TC212 - One ME, FTPES, 5MB files, 100 files per event, 100 events, 1 event per poll.')
    parser.add_argument(
        '--tc213',
        action='store_true',
        help='TC213 - One ME, FTPES, 1MB files, 100 files per event, 100 events. All events in one poll.')

    parser.add_argument(
        '--tc220',
        action='store_true',
        help='TC220 - One ME, FTPES, 1MB files, 100 files per event, 100 events, 1 event per poll. 10% of replies each: no response, empty message, slow response, 404-error, malformed json')
    parser.add_argument(
        '--tc221',
        action='store_true',
        help='TC221 - One ME, FTPES, 1MB files, 100 files per event, 100 events, 1 event per poll. 10% missing files')
    parser.add_argument(
        '--tc222',
        action='store_true',
        help='TC222 - One ME, FTPES, 1MB files, 100 files per event, 100 events. 1 event per poll. All files with identical name. ')

    parser.add_argument(
        '--tc2000',
        action='store_true',
        help='TC2000 - One ME, FTPES, 1MB files, 100 files per event, endless number of events, 1 event per poll')
    parser.add_argument(
        '--tc2001',
        action='store_true',
        help='TC2001 - One ME, FTPES, 5MB files, 100 files per event, endless number of events, 1 event per poll')

    parser.add_argument(
        '--tc2100',
        action='store_true',
        help='TC2100 - 700 ME, FTPES, 1MB files, 100 files per event, endless number of events, 35 event per poll')
    parser.add_argument(
        '--tc2101',
        action='store_true',
        help='TC2101 - 700 ME, FTPES, 5MB files, 100 files per event, endless number of events, 35 event per poll')
    parser.add_argument(
        '--tc2102',
        action='store_true',
        help='TC2102 - 700 ME, FTPES, 50MB files, 100 files per event, endless number of events, 35 event per poll')

    parser.add_argument(
        '--tc2200',
        action='store_true',
        help='TC2200 - 700 ME, FTPES, 1MB files, 100 new files per event, endless number of events, 35 event per poll')
    parser.add_argument(
        '--tc2201',
        action='store_true',
        help='TC2201 - 700 ME, FTPES, 5MB files, 100 new files per event, endless number of events, 35 event per poll')
    parser.add_argument(
        '--tc2202',
        action='store_true',
        help='TC2202 - 700 ME, FTPES, 50MB files, 100 new files per event, endless number of events, 35 event per poll')

    parser.add_argument(
        '--tc2300',
        action='store_true',
        help='TC2300 - 700 ME, FTPES, 1MB files, 100 files per event, endless number of events, 35 event per poll, 20 event polls every 15min')
    parser.add_argument(
        '--tc2301',
        action='store_true',
        help='TC2301 - 700 ME, FTPES, 5MB files, 100 files per event, endless number of events, 35 event per poll, 20 event polls every 15min')
    parser.add_argument(
        '--tc2302',
        action='store_true',
        help='TC2302 - 700 ME, FTPES, 50MB files, 100 files per event, endless number of events, 35 event per poll, 20 event polls every 15min')

    parser.add_argument(
        '--tc2500',
        action='store_true',
        help='TC2500 - 700 ME, FTPES, 1MB files, 100 files per event, 35 events per poll, simulating 25h backlog of decreasing number of outdated files and then 20 event polls every 15min for 1h')

    parser.add_argument(
        '--tc600',
        action='store_true',
        help='TC600 - 700 MEs, FTPES, 1MB files, 2 new files per event, 700 events, all event in one poll.')

    parser.add_argument(
        '--tc601',
        action='store_true',
        help='TC601 - 700 MEs, FTPES, 5MB files, 2 new files per event, 700 events, all event in one poll.')

    parser.add_argument(
        '--tc602',
        action='store_true',
        help='TC602 - 700 MEs, FTPES, 50MB files, 2 new files per event, 700 events, all event in one poll.')

    parser.add_argument(
        '--tc610',
        action='store_true',
        help='TC610 - 700 MEs, FTPES, 1MB files, 1 file per event, 3500 events, 700 event per poll.')

    parser.add_argument(
        '--tc611',
        action='store_true',
        help='TC611 - 700 MEs, FTPES, 1KB files, 1 file per event, 3500 events, 700 event per poll.')

    parser.add_argument(
        '--tc650',
        action='store_true',
        help='TC610 - 700 MEs, FTPES, 50MB files, 1 file per event, 3500 events, 700 event per poll.')

    parser.add_argument(
        '--tc810',
        action='store_true',
        help='TC810 - 700 MEs, FTPES, 1MB files, 100 files per event, 3500 events, 35 event per poll.')

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

    elif args.tc1100:
        tc_num = "TC# 1100"
    elif args.tc1101:
        tc_num = "TC# 1101"
    elif args.tc1102:
        tc_num = "TC# 1102"
    elif args.tc1200:
        tc_num = "TC# 1200"
    elif args.tc1201:
        tc_num = "TC# 1201"
    elif args.tc1202:
        tc_num = "TC# 1202"
    elif args.tc1300:
        tc_num = "TC# 1300"
    elif args.tc1301:
        tc_num = "TC# 1301"
    elif args.tc1302:
        tc_num = "TC# 1302"

    elif args.tc1500:
        tc_num = "TC# 1500"

    elif args.tc500:
        tc_num = "TC# 500"
    elif args.tc501:
        tc_num = "TC# 501"
    elif args.tc502:
        tc_num = "TC# 502"
    elif args.tc510:
        tc_num = "TC# 510"
    elif args.tc511:
        tc_num = "TC# 511"

    elif args.tc550:
        tc_num = "TC# 550"

    elif args.tc710:
        tc_num = "TC# 710"

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

    elif args.tc2100:
        tc_num = "TC# 2100"
    elif args.tc2101:
        tc_num = "TC# 2101"
    elif args.tc2102:
        tc_num = "TC# 2102"
    elif args.tc2200:
        tc_num = "TC# 2200"
    elif args.tc2201:
        tc_num = "TC# 2201"
    elif args.tc2202:
        tc_num = "TC# 2202"
    elif args.tc2300:
        tc_num = "TC# 2300"
    elif args.tc2301:
        tc_num = "TC# 2301"
    elif args.tc2302:
        tc_num = "TC# 2302"

    elif args.tc2500:
        tc_num = "TC# 2500"

    elif args.tc600:
        tc_num = "TC# 600"
    elif args.tc601:
        tc_num = "TC# 601"
    elif args.tc602:
        tc_num = "TC# 602"
    elif args.tc610:
        tc_num = "TC# 610"
    elif args.tc611:
        tc_num = "TC# 611"
    elif args.tc650:
        tc_num = "TC# 650"
    elif args.tc810:
        tc_num = "TC# 810"

    else:
        print("No TC was defined")
        print("use --help for usage info")
        sys.exit()

    print("TC num: " + tc_num)

    for i in range(len(sftp_hosts)):
        print("Using " + str(sftp_hosts[i]) + ":" + str(sftp_ports[i]) + " for sftp server with index " + str(
            i) + " for sftp server address and port in file urls.")

    for i in range(len(ftpes_hosts)):
        print("Using " + str(ftpes_hosts[i]) + ":" + str(ftpes_ports[i]) + " for ftpes server with index " + str(
            i) + " for ftpes server address and port in file urls.")

    print("Using up to " + str(num_ftp_servers) + " ftp servers, for each protocol for PNFs.")


    def https_app(**kwargs):
        import ssl
        context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
        context.load_cert_chain('cert/cert.pem', 'cert/key.pem')
        app.run(ssl_context=context, **kwargs)


    from multiprocessing import Process

    kwargs = dict(host=HOST_IP)
    Process(target=https_app, kwargs=dict(kwargs, port=HOST_PORT_TLS),
            daemon=True).start()

    app.run(port=HOST_PORT, host=HOST_IP)
