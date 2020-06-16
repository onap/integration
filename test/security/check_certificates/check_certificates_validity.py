#!/usr/bin/env python3
#   COPYRIGHT NOTICE STARTS HERE
#
#   Copyright 2020 Orange, Ltd.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   COPYRIGHT NOTICE ENDS HERE

# Check all the kubernetes pods, evaluate the certificate and build a certificate
# dashboard.
#
# Dependencies:
#
#     pip3 install kubernetes
#     pip3 install pyopenssl
#
#     The dashboard is based on bulma framework
#
# Environment:
#   This script should be run on the local machine which has network access to
# the onap K8S cluster.
#   It requires k8s cluster config file on local machine
#   It requires also the ONAP IP provided through an env variable ONAP_IP
#   ONAP_NAMESPACE env variable is also considered, if not set we set it to onap
# Example usage:
#       python check_certificates_validity.py
# the summary html page will be generated where the script is launched
import os
import ssl
import sys
import OpenSSL
from datetime import datetime
from kubernetes import client, config
from jinja2 import Environment, PackageLoader, FileSystemLoader, select_autoescape

# ONAP IP usually referenced in the /etc/hosts of the controller node
# 10.253.0.8 portal.api.simpledemo.onap.org
# 10.253.0.8 vid.api.simpledemo.onap.org
# 10.253.0.8 sdc.api.fe.simpledemo.onap.org
try:
   url_onap = os.environ['ONAP_IP']
except KeyError:
   print("Please set the environment variable ONAP_IP")
   sys.exit(1)

try:
   onap_namespace = os.environ['ONAP_NAMESPACE']
except KeyError:
   onap_namespace = 'onap'

# retrieve the candidate ports firt
config.load_kube_config()
core = client.CoreV1Api()
k8s_services = core.list_namespaced_service(onap_namespace).items

# looks for the certificates
certificates_list = []

for service in k8s_services:
    try:
        for port in service.spec.ports:
            if port.node_port is not None:
                cert = ssl.get_server_certificate((url_onap, port.node_port))
                x509 = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, cert)
                exp = datetime.strptime(x509.get_notAfter().decode('ascii'), '%Y%m%d%H%M%SZ')
                # calculate the remaining time
                delta_time = (exp - datetime.now()).days
                # add certificate to the list
                certificates_list.append({'pod_name':port.name, 'pod_node': port.node_port, 'expiration_date': str(exp), 'remaining_days': delta_time})
    except:
        pass

#print(certificates_list)
# Create html summary
jinja_env = Environment(autoescape=select_autoescape(['html']), loader=FileSystemLoader('./templates'))
jinja_env.get_template('cert.html.j2').stream(certificate_list=certificates_list).dump('{}/certificates.html'.format('.'))
