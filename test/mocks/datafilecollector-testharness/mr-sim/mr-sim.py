import argparse
import os
from werkzeug import secure_filename
from flask import Flask, render_template, request
from time import sleep
import sys
import json
from flask import Flask
app = Flask(__name__)

DEFAULT_IP = "localhost"


@app.route(
    "/events/unauthenticated.VES_NOTIFICATION_OUTPUT/OpenDcae-c12/C12",
    methods=['GET'])
def MR_reply():
    global mr_counter
    global mr_replies

    mr_counter = mr_counter + 1
    print("MR receiver counter: " + str(mr_counter))

    if mr_replies[mr_counter].sleepMs != 0:
        sleep(mr_replies[mr_counter].sleepMs / 1000.0)
        print("Sleeping: " + str(mr_replies[mr_counter].sleepMs) + " ms")

    if mr_replies[mr_counter].replytype == 0:
        #print (str(mr_replies[mr_counter].jsonreply))
        print("Regular reply")
        response = app.response_class(
            response=mr_replies[mr_counter].jsonreply,
            status=200,
            mimetype='application/json')

        return response

    if mr_replies[mr_counter].replytype == 2:

        print("error: 404")
        response = app.response_class(
            response="",
            status=404,
            mimetype='application/json')

        return response

    if mr_replies[mr_counter].replytype == 1:
        print("do nothing, sink request")
        return


class Reply:
    """An instance of the reply event, which can be configured to behave in a certain way
    (delay, error code, reply body"""

    def to_json(self):
        return self.jsonreply

    def __init__(
            self,
            ip=DEFAULT_IP,
            file="1MB.tar.gz",
            sleepMs=0,
            replyType=0,
            port=1022,
            type="ftps"):
        self.sleepMs = sleepMs
        self.ip = ip
        self.file = file
        self.port = port
        self.replytype = replyType  # 0 for reply, 1 timeout, 2 deny
        self.user = "onap"
        self.passwd = "pano"
        self.type = type
        self.jsonreply = str.encode("""
        [{
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
              "reportingEntityName": "otenb5309",
              "sequence": 0,
              "domain": "notification",
              "lastEpochMicrosec": 8745745764578,
              "eventName": "Noti_RnNode-Ericsson_FileReady",
              "vesEventListenerVersion": "7.0.1",
              "sourceName": "oteNB5309"
            },
            "notificationFields": {
              "notificationFieldsVersion": "2.0",
              "changeType": "FileReady",
              "changeIdentifier": "PM_MEAS_FILES",
              "arrayOfNamedHashMap": [
                {
                  "name": \"""" +
                                    self.file +
                                    """",
                  "hashMap": {
                    "fileFormatType": "org.3GPP.32.435#measCollec",
                    "location": \"""" +
                                    self.type +
                                    """://""" +
                                    self.user +
                                    """:""" +
                                    self.passwd +
                                    """@""" +
                                    self.ip +
                                    """:""" +
                                    str(self.port) +
                                    """/""" +
                                    self.file +
                                    """",
                    "fileFormatVersion": "V10",
                    "compression": "gzip"
                  }
                }
              ]
            }
          }
        }]
        """)


def replyFactory(
        ip=DEFAULT_IP,
        file="1MB.tar.gz",
        factoryport=1022,
        count=1,
        factorytype="ftps"):
    aggregatedReply = ""
    # first item does not require .
    aggregatedReply = Reply(ip, file, port=factoryport).to_json()
    for i in range(count - 1):
        aggregatedReply = aggregatedReply + b", " + \
            Reply(ip, file, port=factoryport, type=factorytype).to_json()
    #print(b"aggregated reply: " + aggregatedReply)
    return b"[" + aggregatedReply + b"]"


def prepareMrRespArrSftp():
    global mr_replies

    for i in range(400):  # prepare 400 regular replies
        mr_replies.append(
            Reply(
                port=1022,
                ip="localhost",
                type="sftp",
                file="1MB.tar.gz"))
    #mr_replies[0] is not used


def prepareMrRespArrFtps():
    global mr_replies

    for i in range(400):
        mr_replies.append(
            Reply(
                port=21,
                ip="localhost",
                type="ftps",
                file="1MB.tar.gz"))


def tc1():
    prepareMrRespArrSftp()
    # no mutation needed in this TC


def tc2():
    global mr_replies

    for i in range(7):
        mr_replies.append(
            Reply(
                port=1022,
                ip="localhost",
                type="sftp",
                file="1MB.tar.gz"))

    # inserting and empty reply message
    mr_replies[1].jsonreply = b""
    mr_replies[2].jsonreply = b""

    # inserting a 404 error and delay
    mr_replies[3].replytype = 2
    mr_replies[3].sleepMs = 2000

    # inserting and empty reply message
    mr_replies[4].jsonreply = b""

    # sink the message
    mr_replies[5].replytype = 1

    # reply with one proper file finally
    mr_replies[6] = Reply(
        port=1022,
        ip="localhost",
        type="sftp",
        file="1MB.tar.gz")


def tc3():
    prepareMrRespArrFtps()


def tc4():
    global mr_replies

    for i in range(7):
        mr_replies.append(
            Reply(
                port=21,
                ip="localhost",
                type="ftps",
                file="1MB.tar.gz"))

    # inserting and empty reply message
    mr_replies[1].jsonreply = b""
    mr_replies[2].jsonreply = b""

    # inserting a 404 error and delay
    mr_replies[3].replytype = 2
    mr_replies[3].sleepMs = 2000

    # inserting and empty reply message
    mr_replies[4].jsonreply = b""

    # sink the message
    mr_replies[5].replytype = 1

    # reply with one proper file finally
    mr_replies[6] = Reply(
        port=21,
        ip="localhost",
        type="fftp",
        file="1MB.tar.gz")


if __name__ == "__main__":
    mr_replies = []
    mr_counter = 0  # counting hits reaching MR instance
    DR_block_single_req = 0

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--tc1',
        action='store_true',
        help='TC1: reply all queries with 1-1 files using SFTP')
    parser.add_argument(
        '--tc2',
        action='store_true',
        help='TC2: Reply according to error scenarios, then return 1 file finally for SFTP ---NOTE: updated keys required')
    parser.add_argument(
        '--tc3',
        action='store_true',
        help='TC3: reply all queries with 1-1 files using FTPS')
    parser.add_argument(
        '--tc4',
        action='store_true',
        help='TC4: Reply according to error scenarios, then return 1 file finally for FTPS ---NOTE: updated keys required')

    args = parser.parse_args()

    if args.tc1:
        print("TC: #1")
        tc1()
    elif args.tc2:
        print("TC: #2")
        tc2()
    elif args.tc3:
        print("TC: #3")
        tc3()
    elif args.tc4:
        print("TC: #4")
        tc4()

    else:
        print("No TC was defined")
        print("use --help for usage info")
        sys.exit()
    app.run(port=2222)
