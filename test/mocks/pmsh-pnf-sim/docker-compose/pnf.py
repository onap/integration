import xml.dom.minidom
import json
import requests
import os
import time
import pmfunction
import re

class PNF():
    def __init__(self):
        pass

    def createPMJob(self,jobid,timestemp):
        script_dir = os.path.dirname(__file__)
        pm_rel_file_path = "sftp/"
        pm_location = os.path.join(script_dir,pm_rel_file_path)
        pmfunction.generatexml(jobid,timestemp)

    def deletePMJob(self,jobid):
        pass

    def sendFileReadyEvent(self,IP,PORT,timestemp):
        script_dir = os.path.dirname(__file__)
        rel_path = "FileReadyEvent.json"
        fileReadyEventPath = os.path.join(script_dir,rel_path)
        with open(fileReadyEventPath) as json_file:
                data = json_file.read().replace("pmfilename",str(timestemp))
                eventdata = json.loads(data)
        url = "http://{}:{}/eventListener/v7".format(IP,PORT)
        print("Sending File Ready Event to VES Collector " + url + " -- data @" + data)
        headers = {'content-type': 'application/json'}
        requests.post(url, json=eventdata, headers=headers)