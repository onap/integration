import random
import string
from locust import HttpLocust, TaskSet, task

class UserBehavior(TaskSet):
    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        self.init()

    def init(self):
        pass

    @task(1)
    def DCI(self):
        method = "POST"
        url = "/ecomp/mso/infra/e2eServiceInstances/v3"
        headers = {"Accept":"application/json","Content-Type":"application/json","Authorization":"Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA=="}
        service_instance_name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(10))
        data = "{\"service\": {\"name\": \"E2E_volte_%s\", \"description\": \"E2E_volte_ONAP_deploy\", \"serviceDefId\": \"a16eb184-4a81-4c8c-89df-c287d390315a\", \"templateId\": \"012c3446-51db-4a2a-9e64-a936f10a5e3c\", \"parameters\": { \"globalSubscriberId\": \"Demonstration\", \"subscriberName\": \"Demonstration\", \"serviceType\": \"vIMS\", \"templateName\": \"VoLTE e2e Service:null\", \"resources\": [ { \"resourceName\": \"VL OVERLAYTUNNEL\", \"resourceDefId\": \"671d4757-b018-47ab-9df3-351c3bda0a98\", \"resourceId\": \"e859b0fd-d928-4cc8-969e-0fee7795d623\", \"nsParameters\": { \"locationConstraints\": [], \"additionalParamForNs\": { \"site2_vni\": \"5010\", \"site1_localNetworkAll\": \"false\", \"site1_vni\": \"5010\", \"site1_exportRT1\": \"11:1\", \"description\": \"overlay\", \"site2_localNetworkAll\": \"false\", \"site1_routerId\": \"9.9.9.9\", \"site1_fireWallEnable\": \"false\", \"site1_networkName\": \"network1\", \"site2_description\": \"overlay\", \"site1_importRT1\": \"11:1\", \"site1_description\": \"overlay\", \"site2_networkName\": \"network3\", \"name\": \"overlay\", \"site2_fireWallEnable\": \"false\", \"site2_id\": \"ZTE-DCI-Controller\", \"site2_routerId\": \"9.9.9.9\", \"site2_importRT1\": \"11:1\", \"site2_exportRT1\": \"11:1\", \"site2_fireWallId\": \"false\", \"site1_id\": \"DCI-Controller-1\", \"tunnelType\": \"L3-DCI\" } } } ] } } }" % service_instance_name
        print(data)
        response = self.client.request(method, url, headers=headers, data=data)
        print(response.json())

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    host = "http://10.0.5.1:8080"
    min_wait = 5000
    max_wait = 9000
