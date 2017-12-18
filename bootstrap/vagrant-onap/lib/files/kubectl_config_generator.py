import requests
import os
import base64

RANCHER_URL = str(os.environ['RANCHER_URL'])
RANCHER_ENVIRONMENT_ID = str(os.environ['RANCHER_ENVIRONMENT'])
data = requests.post(RANCHER_URL + '/v1/projects/' + RANCHER_ENVIRONMENT_ID + '/apikeys',
                     {"accountId": RANCHER_ENVIRONMENT_ID,
                      "description": "ONAP on Kubernetes",
                      "name": "ONAP on Kubernetes",
                      "publicValue": "string",
                      "secretValue": "password"})
json_dct = data.json()
access_key = json_dct['publicValue']
secret_key = json_dct['secretValue']
auth_header = 'Basic ' + base64.b64encode(access_key + ':' + secret_key)
token = "\"" + str(base64.b64encode(auth_header)) + "\""
dct = \
"""
apiVersion: v1
kind: Config
clusters:
- cluster:
    api-version: v1
    insecure-skip-tls-verify: true
    server: "{}/r/projects/{}/kubernetes:6443"
  name: "onap_on_kubernetes"
contexts:
- context:
    cluster: "onap_on_kubernetes"
    user: "onap_on_kubernetes"
  name: "onap_on_kubernetes"
current-context: "onap_on_kubernetes"
users:
- name: "onap_on_kubernetes"
  user:
    token: {}
""".format(RANCHER_URL, RANCHER_ENVIRONMENT_ID, token)
with open("config", "w") as file:
    file.write(dct)
