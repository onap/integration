import gzip
import json
import logging
import os
import shutil
import time
import xml.etree.ElementTree as ElementTree
from random import randint

import requests
from requests.auth import HTTPBasicAuth

from app_config import pnfconfig

logger = logging.getLogger('dev')


class PNF:
    """ Handle update on xml and send file ready event to ves collector """
    def __init__(self):
        pass

    @staticmethod
    def create_job_id(jobid, change_list):
        """
        create new measinfo tag and add new sub element in existing xml.
        :param jobid: create unique job id within xml sub element.
        :param change_list: list to create sub elements itmes.
        """
        try:
            measurement_type = []
            meas_object_dn = []
            for items in range(len(change_list)):
                if "/measurementType =" in change_list[items]:
                    measurement_type.append(((change_list[items].rsplit('/', 1))[1].rsplit('=', 1))[1].strip())
                if "/DN =" in change_list[items]:
                    meas_object_dn.append(((change_list[items].rsplit('/', 1))[1].rsplit('=', 1))[1].strip())
            script_dir = os.path.dirname(__file__)
            pm_rel_file_path = "sftp/"
            pm_location = os.path.join(script_dir, pm_rel_file_path)
            ElementTree.register_namespace('', "http://www.3gpp.org/ftp/specs/archive/32_series/32.435#measCollec")
            tree = ElementTree.parse(pm_location + "pm.xml")
            root = tree.getroot()
            attrib = {}
            measinfo = ElementTree.SubElement(root[1], 'measInfo', attrib)
            attrib = {'jobId': jobid}
            ElementTree.SubElement(measinfo, 'job', attrib)
            ElementTree.SubElement(measinfo, 'granPeriod', {'duration': 'PT900S', 'endTime': '2000-03-01T14:14:30+02:00'})
            ElementTree.SubElement(measinfo, 'repPeriod', {'duration': 'PT1800S'})
            for items in range(len(measurement_type)):
                meastype = ElementTree.SubElement(measinfo, 'measType', {'p': (items + 1).__str__()})
                meastype.text = measurement_type[items]
            for items in range(len(meas_object_dn)):
                measvalue = ElementTree.SubElement(measinfo, 'measValue', {'measObjLdn': meas_object_dn[items]})
                for item in range(len(measurement_type)):
                    value = ElementTree.SubElement(measvalue, 'r', {'p': (item + 1).__str__()})
                    value.text = randint(100, 900).__str__()
            tree.write(pm_location + "pm.xml", encoding="utf-8", xml_declaration=True)
        except Exception as error:
            logger.debug(error)

    @staticmethod
    def delete_job_id(jobid):
        """
        delete measinfo tag from existing xml pm file based on jobid.
        :param jobid: element within measinfo tag.
        """
        try:
            script_dir = os.path.dirname(__file__)
            pm_rel_file_path = "sftp/"
            pm_location = os.path.join(script_dir, pm_rel_file_path)
            ElementTree.register_namespace(
                '', "http://www.3gpp.org/ftp/specs/archive/32_series/32.435#measCollec")
            tree = ElementTree.parse(pm_location + "pm.xml")
            root = tree.getroot()
            for measinfo in root[1].findall(
                    '{http://www.3gpp.org/ftp/specs/archive/32_series/32.435#measCollec}measInfo'):
                xml_id = measinfo.find(
                    '{http://www.3gpp.org/ftp/specs/archive/32_series/32.435#measCollec}job').attrib
                if xml_id["jobId"] == jobid:
                    root[1].remove(measinfo)
            tree.write(pm_location + "pm.xml", encoding="utf-8", xml_declaration=True)
        except Exception as error:
            logger.debug(error)

    @staticmethod
    def pm_job():
        """
        create timestemp based gunzip xml file and send file ready event to ves collector.
        """
        try:
            script_dir = os.path.dirname(__file__)
            timestemp = time.time()
            pm_location = os.path.join(script_dir, 'sftp/')
            shutil.copy(pm_location + 'pm.xml', pm_location + f'A{timestemp}.xml')
            with open(pm_location + f'A{timestemp}.xml', 'rb') as f_in:
                with gzip.open(pm_location + f'A{timestemp}.xml.gz', 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            os.remove(pm_location + f'A{timestemp}.xml')
            with open(os.path.join(script_dir, 'FileReadyEvent.json')) as json_file:
                data = json_file.read().replace("pmfilename", str(timestemp))
                eventdata = json.loads(data)
            session = requests.Session()
            url = f'https://{pnfconfig.VES_IP}:{pnfconfig.VES_PORT}/eventListener/v7'
            logger.debug(f'Sending File Ready Event to VES Collector {url} -- data @{data}')
            headers = {'content-type': 'application/json',
                       'x-transactionid': '123456'}
            response = session.post(url, json=eventdata, headers=headers,
                                    auth=HTTPBasicAuth(pnfconfig.VES_USER, pnfconfig.VES_PASS),
                                    verify=False)
            response.raise_for_status()
        except Exception as error:
            logger.debug(f'Exception caught {error}', exc_info=True)
