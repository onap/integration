import json
import requests
import re
import xml.etree.ElementTree as ET
import os
import gzip
import shutil
from random import randint
import time
import pnfconfig

class PNF():
    def __init__(self):
        pass

    def createJobId(self,jobId,cl):
        try:
            measurementType = []
            dn = []
            for i in range(len(cl)):
                if ( "/measurementType =" in cl[i] ):
                    measurementType.append(((cl[i].rsplit('/',1))[1].rsplit('=',1))[1].strip())
                if ("/DN =" in cl[i]):
                    dn.append(((cl[i].rsplit('/',1))[1].rsplit('=',1))[1].strip())
            script_dir = os.path.dirname(__file__)
            pm_rel_file_path = "sftp/"
            pm_location = os.path.join(script_dir,pm_rel_file_path)
            ET.register_namespace('', "http://www.3gpp.org/ftp/specs/archive/32_series/32.435#measCollec")
            tree = ET.parse(pm_location+"pm.xml")
            root = tree.getroot()
            attrib = {}
            measInfo = ET.SubElement(root[1],'measInfo',attrib)
            attrib = { 'jobId': jobId}
            ET.SubElement(measInfo,'job', attrib)
            ET.SubElement(measInfo,'granPeriod', {'duration': 'PT900S', 'endTime': '2000-03-01T14:14:30+02:00'})
            ET.SubElement(measInfo,'repPeriod', {'duration': 'PT1800S'})
            for i in range(len(measurementType)):
                    meastype = ET.SubElement(measInfo,'measType', {'p': (i+1).__str__() })
                    meastype.text = measurementType[i]
            for i in range(len(dn)):
                    measValue = ET.SubElement(measInfo,'measValue', {'measObjLdn': dn[i]})
                    for i in range(len(measurementType)):
                            value = ET.SubElement(measValue,'r', {'p': (i+1).__str__()})
                            value.text = randint(100,900).__str__()
            tree.write(pm_location+"pm.xml",encoding="utf-8", xml_declaration=True)
        except Exception as e:
            print(e)

    def deleteJobId(self,jobId):
        try:
            script_dir = os.path.dirname(__file__)
            pm_rel_file_path = "sftp/"
            pm_location = os.path.join(script_dir,pm_rel_file_path)
            ET.register_namespace('', "http://www.3gpp.org/ftp/specs/archive/32_series/32.435#measCollec")
            tree = ET.parse(pm_location+"pm.xml")
            root = tree.getroot()
            for measInfo in root[1].findall('{http://www.3gpp.org/ftp/specs/archive/32_series/32.435#measCollec}measInfo'):
                    id = measInfo.find('{http://www.3gpp.org/ftp/specs/archive/32_series/32.435#measCollec}job').attrib
                    if id["jobId"] == jobId:
                            root[1].remove(measInfo)
            tree.write(pm_location+"pm.xml",encoding="utf-8", xml_declaration=True)
        except Exception as e:
            print(e)

    def pmJob(self):
        try:
            script_dir = os.path.dirname(__file__)
            timestemp = time.time()
            pm_rel_file_path = "sftp/"
            pm_location = os.path.join(script_dir,pm_rel_file_path)
            shutil.copy(pm_location+"pm.xml",pm_location+"A{}.xml".format(timestemp))
            with open(pm_location+"A{}.xml".format(timestemp), 'rb') as f_in:
                    with gzip.open(pm_location+"A{}.xml.gz".format(timestemp), 'wb') as f_out:
                            shutil.copyfileobj(f_in, f_out)
            os.remove(pm_location+"A{}.xml".format(timestemp))
            rel_path = "FileReadyEvent.json"
            fileReadyEventPath = os.path.join(script_dir,rel_path)
            with open(fileReadyEventPath) as json_file:
                    data = json_file.read().replace("pmfilename",str(timestemp))
                    eventdata = json.loads(data)
            url = "http://{}:{}/eventListener/v7".format(pnfconfig.VES_IP,pnfconfig.VES_PORT)
            print("Sending File Ready Event to VES Collector " + url + " -- data @" + data)
            headers = {'content-type': 'application/json'}
            requests.post(url, json=eventdata, headers=headers)
        except Exception as e:
            print(e)