#!/usr/bin/env python
import xml.dom.minidom
import json
import requests

class PMFileGenerator():
    def __init__(self):
        pass

    def createPMFiles(self,file):
        doc = xml.dom.minidom.parse("A.xml")
        print(doc._get_version())
        element = doc.getElementsByTagName("measCollecFile")
        for itmes in element:
            print(itmes.__getattribute__("xmlns"))

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