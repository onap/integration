#!/usr/bin/env python
import xml.dom.minidom
import json
import requests

class PNF():
    def __init__(self):
        pass

    def createPMJob(self,file):
        pass

    def publishToSftp(self,file):
        pass

    def sendFileReadyEvent(self,filereadyevent,IP,PORT):
        with open(filereadyevent) as json_file:
            data = json.load(json_file)
        print(IP)
        url = "http://{}:{}/eventListener/v7".format(IP,PORT)
        print("Sending File Ready Event to VES Collector " + url + " -- data @")
        print(data)
        headers = {'content-type': 'application/json'}
        requests.post(url, json=data, headers=headers)