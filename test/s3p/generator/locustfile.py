import random
import string
import time
import datetime
import sys
import collections
import json
import tzlocal
import os
import fcntl
import logging
from locust import HttpLocust, TaskSet, task
from decimal import Decimal


class UserBehavior(TaskSet):
    base = "/ecomp/mso/infra/e2eServiceInstances/v3"
    headers = {"Accept":"application/json","Content-Type":"application/json","Authorization":"Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA=="}
    service_creation_body = "{\"service\": {\"name\": \"E2E_volte_%s\", \"description\": \"E2E_volte_ONAP_deploy\", \"serviceDefId\": \"a16eb184-4a81-4c8c-89df-c287d390315a\", \"templateId\": \"012c3446-51db-4a2a-9e64-a936f10a5e3c\", \"parameters\": { \"globalSubscriberId\": \"Demonstration\", \"subscriberName\": \"Demonstration\", \"serviceType\": \"vIMS\", \"templateName\": \"VoLTE e2e Service:null\", \"resources\": [ { \"resourceName\": \"VL OVERLAYTUNNEL\", \"resourceDefId\": \"671d4757-b018-47ab-9df3-351c3bda0a98\", \"resourceId\": \"e859b0fd-d928-4cc8-969e-0fee7795d623\", \"nsParameters\": { \"locationConstraints\": [], \"additionalParamForNs\": { \"site2_vni\": \"5010\", \"site1_localNetworkAll\": \"false\", \"site1_vni\": \"5010\", \"site1_exportRT1\": \"11:1\", \"description\": \"overlay\", \"site2_localNetworkAll\": \"false\", \"site1_routerId\": \"9.9.9.9\", \"site1_fireWallEnable\": \"false\", \"site1_networkName\": \"network1\", \"site2_description\": \"overlay\", \"site1_importRT1\": \"11:1\", \"site1_description\": \"overlay\", \"site2_networkName\": \"network3\", \"name\": \"overlay\", \"site2_fireWallEnable\": \"false\", \"site2_id\": \"ZTE-DCI-Controller\", \"site2_routerId\": \"9.9.9.9\", \"site2_importRT1\": \"11:1\", \"site2_exportRT1\": \"11:1\", \"site2_fireWallId\": \"false\", \"site1_id\": \"DCI-Controller-1\", \"tunnelType\": \"L3-DCI\" } } },{\"resourceName\": \"VL UNDERLAYVPN\", \"resourceDefId\": \"4f5d692b-4022-43ab-b878-a93deb5b2061\", \"resourceId\": \"b977ec47-45b2-41f6-aa03-bf6554dc9620\", \"nsParameters\": { \"locationConstraints\": [], \"additionalParamForNs\": { \"topology\": \"full-mesh\", \"site2_name\": \"site2\", \"sna2_name\": \"site2_sna\", \"description\": \"underlay\", \"sna1_name\": \"site1_sna\", \"ac1_route\": \"3.3.3.12/30:dc84ce88-99f7\", \"ac2_peer_ip\": \"3.3.3.20/30\", \"technology\": \"mpls\", \"ac2_route\": \"3.3.3.20/30:98928302-3287\", \"ac2_id\": \"84d937a4-b227-375f-a744-2b778f36e04e\", \"ac1_protocol\": \"STATIC\", \"ac2_svlan\": \"4004\", \"serviceType\": \"l3vpn-ipwan\", \"ac2_ip\": \"3.3.3.21/30\", \"pe2_id\": \"4412d3f0-c296-314d-9284-b72fc5d485e8\", \"ac1_id\": \"b4f01ac0-c1e1-3e58-a8be-325e4372c960\", \"af_type\": \"ipv4\", \"ac1_svlan\": \"4002\", \"ac1_peer_ip\": \"3.3.3.12/30\", \"ac1_ip\": \"3.3.3.13/30\", \"version\": \"1.0\", \"name\": \"testunderlay\", \"id\": \"123124141\", \"pe1_id\": \"2ef788f0-407c-3070-b756-3a5cd71fde18\", \"ac2_protocol\": \"STATIC\", \"site1_name\": \"stie1\" } } } ] } } }"
    # following class variables to make them unique across all users
    transaction_file= open("transaction.log", "w+")
    operation_file = open("operation.log", "w+")
    
    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        self.init()

    def init(self):
        pass

    def myconverter(self, o):
        if isinstance(o, datetime.datetime):
            return o.__str__()

    @task(1)
    def create_service(self):
	# Post a E2E service instantiation request to SO
        method = "POST"
        url = self.base
	service_instance_name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(10))
	data = self.service_creation_body % service_instance_name

	t1 = datetime.datetime.now(tzlocal.get_localzone())
        response = self.client.request(method, url, headers=self.headers, data=data)
	t2 = datetime.datetime.now(tzlocal.get_localzone())
	delta = t2 - t1
        data = collections.OrderedDict()
        data['datetime'] = datetime.datetime.now(tzlocal.get_localzone()).strftime("%Y-%m-%dT%H:%M:%S%Z")
        data['method'] = method
        data['url'] = url
        data['status_code'] = response.status_code
        data['transaction_time'] = (delta.seconds*10^6 + delta.microseconds)/1000
        fcntl.flock(self.transaction_file, fcntl.LOCK_EX)
        self.transaction_file.write(json.dumps(data, default = self.myconverter) + "\n") 
        self.transaction_file.flush()
        os.fsync(self.transaction_file)
        fcntl.flock(self.transaction_file, fcntl.LOCK_UN)
	serviceId = response.json()['service']['serviceId']
	operationId = response.json()['service']['operationId']

	# Get the request status
	method = "GET"
	url = self.base + "/" + serviceId + "/operations/" + operationId
	url1 = "/ecomp/mso/infra/e2eServiceInstances/v3/{serviceId}/operations/{operationId}"
	count = 1
	while count < 50:
	    tt1 = datetime.datetime.now()
	    response = self.client.request(method, url, name=url1, headers=self.headers)
	    tt2 = datetime.datetime.now()
            delta = tt2 - tt1
	    result = response.json()['operationStatus']['result']	    
	    progress = response.json()['operationStatus']['progress']
            data = collections.OrderedDict()
            data['datetime'] = datetime.datetime.now(tzlocal.get_localzone()).strftime("%Y-%m-%dT%H:%M:%S%Z")
            data['method'] = method
            data['url'] = url1
            data['status_code'] = response.status_code
            data['count'] = count
            data['result'] = result
            data['progress'] = progress
            data['transaction_time'] = (delta.seconds*10^6 + delta.microseconds)/1000
            fcntl.flock(self.transaction_file, fcntl.LOCK_EX)
            self.transaction_file.write(json.dumps(data, default = self.myconverter) + "\n") 
            self.transaction_file.flush()
            os.fsync(self.transaction_file)
            fcntl.flock(self.transaction_file, fcntl.LOCK_UN)
	    if result == "finished" or result == "error":
                break
	    else:
		time.sleep(1)
		count = count + 1
	
        if result == "finished":
            result = "success"
        else:
            result = "failure"
	t3 = datetime.datetime.now(tzlocal.get_localzone())
	delta = t3 - t1
        data = collections.OrderedDict()
        data['datetime'] = t1.strftime("%Y-%m-%dT%H:%M:%S%Z")
        data['operation'] = "volte_create"
        data['result'] = result
        data['duration'] = round(delta.seconds + Decimal(delta.microseconds/1000000.0), 3)
        fcntl.flock(self.operation_file, fcntl.LOCK_EX)
        self.operation_file.write(json.dumps(data, default = self.myconverter) + "\n")
        self.operation_file.flush()
        os.fsync(self.operation_file)
        fcntl.flock(self.operation_file, fcntl.LOCK_UN)

	self.delete_service(serviceId)

    def delete_service(self, serviceId):
	method = "DELETE"
 	url = self.base + "/" + serviceId
	data = "{\"globalSubscriberId\":\"Demonstration\", \"serviceType\":\"vIMS\"}" 	
	t1 = datetime.datetime.now(tzlocal.get_localzone())
        response = self.client.request(method, url, name=self.base, headers=self.headers, data=data)
	t2 = datetime.datetime.now(tzlocal.get_localzone())
	delta = t2 - t1
        data = collections.OrderedDict()
        data['datetime'] = datetime.datetime.now(tzlocal.get_localzone()).strftime("%Y-%m-%dT%H:%M:%S%Z")
        data['method'] = method
        data['url'] = self.base
        data['status_code'] = response.status_code
        data['transaction_time'] = (delta.seconds*10^6 + delta.microseconds)/1000
        fcntl.flock(self.transaction_file, fcntl.LOCK_EX)
        self.transaction_file.write(json.dumps(data, default = self.myconverter) + "\n")
        self.transaction_file.flush()
        os.fsync(self.transaction_file)
        fcntl.flock(self.transaction_file, fcntl.LOCK_UN)
	operationId = response.json()['operationId']

	# Get the request status
	method = "GET"
	url = self.base + "/" + serviceId + "/operations/" + operationId
	url1 = "/ecomp/mso/infra/e2eServiceInstances/v3/{serviceId}/operations/{operationId}"
	count = 1
	while count < 50:
	    tt1 = datetime.datetime.now(tzlocal.get_localzone())
	    response = self.client.request(method, url, name=url1, headers=self.headers)
	    tt2 = datetime.datetime.now(tzlocal.get_localzone())
            delta = tt2 - tt1
	    result = response.json()['operationStatus']['result']	    
	    progress = response.json()['operationStatus']['progress']
            data = collections.OrderedDict()
            data['datetime'] = datetime.datetime.now(tzlocal.get_localzone()).strftime("%Y-%m-%dT%H:%M:%S%Z")
            data['method'] = method
            data['url'] = url1
            data['status_code'] = response.status_code
            data['count'] = count
            data['result'] = result
            data['progress'] = progress
            data['transaction_time'] = (delta.seconds*10^6 + delta.microseconds)/1000
            fcntl.flock(self.transaction_file, fcntl.LOCK_EX)
            self.transaction_file.write(json.dumps(data, default = self.myconverter) + "\n") 
            self.transaction_file.flush()
            os.fsync(self.transaction_file)
            fcntl.flock(self.transaction_file, fcntl.LOCK_UN)
	    if result == "finished" or result == "error":
		break
	    else:
		time.sleep(1)
		count = count + 1
	
        if result == "finished":
            result = "success"
        else:
            result = "failure"
	t3 = datetime.datetime.now(tzlocal.get_localzone())
	delta = t3 - t1
        data = collections.OrderedDict()
        data['datetime'] = t1.strftime("%Y-%m-%dT%H:%M:%S%Z")
        data['operation'] = "volte_delete"
        data['result'] = result
        data['duration'] = round(delta.seconds + Decimal(delta.microseconds/1000000.0), 3)
        fcntl.flock(self.operation_file, fcntl.LOCK_EX)
        self.operation_file.write(json.dumps(data, default = self.myconverter) + "\n")
        self.operation_file.flush()
        os.fsync(self.operation_file)
        fcntl.flock(self.operation_file, fcntl.LOCK_UN)

        
class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 1000
    max_wait = 3000
