'''
Created on Aug 18, 2017

@author: sw6830
'''
from robot.api import logger
from Queue import Queue
import uuid, time, datetime,json, threading,os, platform, subprocess,paramiko
import DcaeVariables
import DMaaP

class DcaeLibrary(object):
    
    def __init__(self):
        pass 
    
    def setup_dmaap_server(self, portNum=3904):
        if DcaeVariables.HttpServerThread != None:
            DMaaP.cleanUpEvent()
            logger.console("Clean up event from event queue before test")
            logger.info("DMaaP Server already started")
            return "true"
        
        DcaeVariables.IsRobotRun = True
        DMaaP.test(port=portNum)
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
            
    def shutdown_dmaap(self):
        if DcaeVariables.HTTPD != None:
            DcaeVariables.HTTPD.shutdown()
            logger.console("DMaaP Server shut down")
            time.sleep(3)
            return "true"
        else:
            return "false"
            
    def cleanup_ves_events(self):
        if DcaeVariables.HttpServerThread != None:
            DMaaP.cleanUpEvent()
            logger.console("DMaaP event queue is cleaned up")
            return "true"
        logger.console("DMaaP server not started yet")
        return "false"
    
    def enable_vesc_https_auth(self):
        if 'Windows' in platform.system():
            try:
                client = paramiko.SSHClient()
                client.load_system_host_keys()
                #client.set_missing_host_key_policy(paramiko.WarningPolicy)
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
                   
    def dmaap_message_receive(self, evtobj, action='contain'):
        
        evtStr = DMaaP.dequeEvent()
        while evtStr != None:
            logger.console("DMaaP receive VES Event:\n" + evtStr)
            if action == 'contain':
                if evtobj in evtStr:
                    logger.info("DMaaP Receive Expected Publish Event:\n" + evtStr)
                    return 'true'
            if action == 'sizematch':
                if len(evtobj) == len(evtStr):
                    return 'true'
            if action == 'dictmatch':
                evtDict = json.loads(evtStr)
                if cmp(evtobj, evtDict) == 0:
                    return 'true'
            evtStr = DMaaP.dequeEvent()
        return 'false'
    
    def create_header_from_string(self, dictStr):
        logger.info("Enter create_header_from_string: dictStr")
        return dict(u.split("=") for u in dictStr.split(","))
    
    def is_json_empty(self, resp):
        logger.info("Enter is_json_empty: resp.text: " + resp.text)
        if resp.text == None or len(resp.text) < 2:
            return 'True'
        return 'False'
    
    def Generate_UUID(self):
        """generate a uuid"""
        return uuid.uuid4()
    
    def get_json_value_list(self, jsonstr, keyval):
        logger.info("Enter Get_Json_Key_Value_List")
        if jsonstr == None or len(jsonstr) < 2:
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
        
    def generate_MilliTimestamp_UUID(self):
        """generate a millisecond timestamp uuid"""
        then = datetime.datetime.now()
        return int(time.mktime(then.timetuple())*1e3 + then.microsecond/1e3)
    
    def test (self):
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
    
