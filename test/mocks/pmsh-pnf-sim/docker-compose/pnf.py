import xml.dom.minidom
import json
import requests
import shutil
import os
import time

class PNF():
    def __init__(self):
        pass

    def createPMJob(self,timestemp):
        script_dir = os.path.dirname(__file__)
        pm_rel_file_path = "sftp/"
        pm_location = os.path.join(script_dir,pm_rel_file_path)
        shutil.copy(pm_location+"A.xml",pm_location+"A{}.xml.gz".format(timestemp))

    def publishToSftp(self,file):
        pass

    def sendFileReadyEvent(self,IP,PORT,timestemp):
        script_dir = os.path.dirname(__file__)
        rel_path = "FileReadyEvent.json"
        fileReadyEventPath = os.path.join(script_dir,rel_path)
        with open(fileReadyEventPath) as json_file:
                data = json_file.read().replace("pmfilename",str(timestemp))
                eventdata = json.loads(data)
        url = "http://{}:{}/eventListener/v7".format(IP,PORT)
        print("Sending File Ready Event to VES Collector " + url + " -- data @")
        print(data)
        headers = {'content-type': 'application/json'}
        requests.post(url, json=eventdata, headers=headers)