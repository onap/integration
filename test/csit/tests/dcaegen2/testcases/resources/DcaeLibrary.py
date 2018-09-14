'''
Created on Aug 18, 2017

@author: sw6830
'''
from robot.api import logger
from Queue import Queue
import uuid
import time
import datetime
import json
import threading
import os
import platform
import subprocess
import paramiko
import DcaeVariables
import DMaaP


class DcaeLibrary(object):
    
    def __init__(self):
        pass 
    
    @staticmethod
    def setup_dmaap_server(port_num=3904):
        if DcaeVariables.HttpServerThread is not None:
            DMaaP.clean_up_event()
            logger.console("Clean up event from event queue before test")
            logger.info("DMaaP Server already started")
            return "true"
        
        DcaeVariables.IsRobotRun = True
        DMaaP.test(port=port_num)
        try:
            DcaeVariables.VESEventQ = Queue()
            DcaeVariables.HttpServerThread = threading.Thread(name='DMAAP_HTTPServer', target=DMaaP.DMaaPHttpd.serve_forever)
            DcaeVariables.HttpServerThread.start()
            logger.console("DMaaP Mockup Sever started")
            time.sleep(2)
            return "true"
        except Exception as e:
            print (str(e))
            return "false"
            
    @staticmethod
    def shutdown_dmaap():
        if DcaeVariables.HTTPD is not None:
            DcaeVariables.HTTPD.shutdown()
            logger.console("DMaaP Server shut down")
            time.sleep(3)
            return "true"
        else:
            return "false"
            
    @staticmethod
    def cleanup_ves_events():
        if DcaeVariables.HttpServerThread is not None:
            DMaaP.clean_up_event()
            logger.console("DMaaP event queue is cleaned up")
            return "true"
        logger.console("DMaaP server not started yet")
        return "false"
    
    @staticmethod
    def enable_vesc_https_auth():
        global client
        if 'Windows' in platform.system():
            try:
                client = paramiko.SSHClient()
                client.load_system_host_keys()
                # client.set_missing_host_key_policy(paramiko.WarningPolicy)
                client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                
                client.connect(os.environ['CSIT_IP'], port=22, username=os.environ['CSIT_USER'], password=os.environ['CSIT_PD'])
                stdin, stdout, stderr = client.exec_command('%{WORKSPACE}/test/csit/tests/dcaegen2/testcases/resources/vesc_enable_https_auth.sh')
                logger.console(stdout.read())    
            finally:
                client.close()
            return
        ws = os.environ['WORKSPACE']
        script2run = ws + "/test/csit/tests/dcaegen2/testcases/resources/vesc_enable_https_auth.sh"
        logger.info("Running script: " + script2run)
        logger.console("Running script: " + script2run)
        subprocess.call(script2run)
        time.sleep(5)
        return  
                   
    @staticmethod
    def dmaap_message_receive(evtobj, action='contain'):
        
        evt_str = DMaaP.deque_event()
        while evt_str != None:
            logger.console("DMaaP receive VES Event:\n" + evt_str)
            if action == 'contain':
                if evtobj in evt_str:
                    logger.info("DMaaP Receive Expected Publish Event:\n" + evt_str)
                    return 'true'
            if action == 'sizematch':
                if len(evtobj) == len(evt_str):
                    return 'true'
            if action == 'dictmatch':
                evt_dict = json.loads(evt_str)
                if cmp(evtobj, evt_dict) == 0:
                    return 'true'
            evt_str = DMaaP.deque_event()
        return 'false'

    @staticmethod
    def is_json_empty(resp):
        logger.info("Enter is_json_empty: resp.text: " + resp.text)
        if resp.text is None or len(resp.text) < 2:
            return 'True'
        return 'False'
    
    @staticmethod
    def generate_uuid():
        """generate a uuid"""
        return uuid.uuid4()
    
    @staticmethod
    def get_json_value_list(jsonstr, keyval):
        logger.info("Enter Get_Json_Key_Value_List")
        if jsonstr is None or len(jsonstr) < 2:
            logger.info("No Json data found")
            return []
        try:
            data = json.loads(jsonstr)   
            nodelist = []
            for item in data:
                nodelist.append(item[keyval])
            return nodelist
        except Exception as e:
            logger.info("Json data parsing fails")
            print str(e)
            return []
        
    @staticmethod
    def generate_millitimestamp_uuid():
        """generate a millisecond timestamp uuid"""
        then = datetime.datetime.now()
        return int(time.mktime(then.timetuple())*1e3 + then.microsecond/1e3)
    
    @staticmethod
    def test():
        import json
        from pprint import pprint

        with open('robot/assets/dcae/ves_volte_single_fault_event.json') as data_file:    
            data = json.load(data_file)

        data['event']['commonEventHeader']['version'] = '5.0'
        pprint(data)


if __name__ == '__main__':
    '''
    dictStr = "action=getTable,Accept=application/json,Content-Type=application/json,X-FromAppId=1234908903284"
    cls = DcaeLibrary()
    #dict = cls.create_header_from_string(dictStr)
    #print str(dict)
    jsonStr = "[{'Node': 'onapfcnsl00', 'CheckID': 'serfHealth', 'Name': 'Serf Health Status', 'ServiceName': '', 'Notes': '', 'ModifyIndex': 6, 'Status': 'passing', 'ServiceID': '', 'ServiceTags': [], 'Output': 'Agent alive and reachable', 'CreateIndex': 6}]"
    lsObj = cls.get_json_value_list(jsonStr, 'Status')
    print lsObj
    '''
    
    lib = DcaeLibrary()
    lib.enable_vesc_https_auth()
    
    ret = lib.setup_dmaap_server()
    print ret
    time.sleep(100000)
