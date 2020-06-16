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

# Check all the kubernetes pods, evaluate the certificate and build a
# certificate dashboard.
#
# Dependencies:
#     See requirements.txt
#     The dashboard is based on bulma framework
#
# Environment:
#   This script should be run on the local machine which has network access to
# the onap K8S cluster.
#   It requires k8s cluster config file on local machine
#   It requires also the ONAP IP provided through an env variable ONAP_IP
#   ONAP_NAMESPACE env variable is also considered
# if not set we set it to onap
# Example usage:
#       python check_certificates_validity.py
# the summary html page will be generated where the script is launched
import argparse
import logging
import os
import ssl
import sys
import OpenSSL
from datetime import datetime
from kubernetes import client, config
from jinja2 import Environment, FileSystemLoader, select_autoescape

# Logger
logging.basicConfig()
LOGGER = logging.getLogger("Gating-Index")
LOGGER.setLevel("INFO")

onap_namespace = os.environ.get('ONAP_NAMESPACE', 'onap')

LOGGER.info("Verification of the %s certificates started", onap_namespace)

# ONAP IP usually referenced in the /etc/hosts of the controller node
# 10.253.0.8 portal.api.simpledemo.onap.org
# 10.253.0.8 vid.api.simpledemo.onap.org
# 10.253.0.8 sdc.api.fe.simpledemo.onap.org
CERT_MODES = ['nodeport', 'ingress', 'internal', 'full']
mode = ''

PARSER = argparse.ArgumentParser()
PARSER.add_argument(
    '-m',
    '--mode',
    help='Mode (nodeport, ingress, internal). If not set all modes are tried')

ARGS = PARSER.parse_args()

# Retrieve the selected mode
if ARGS.mode is not None:
    if ARGS.mode in CERT_MODES:
        mode = [ARGS.mode]
    else:
        LOGGER.error(
            "Mode %s not supported. Please use %s", mode, str(CERT_MODES))
        sys.exit(1)
else:
    mode = 'full'

LOGGER.info("Mode selected: %s", mode)

# Retrieve Kubernetes objects

try:
    url_onap = os.environ['ONAP_IP']
except KeyError:
    LOGGER.error("Please set the environment variable ONAP_IP")
    sys.exit(1)


# retrieve the candidate ports first
k8s_config = config.load_kube_config()

core = client.CoreV1Api()
api_instance = client.ExtensionsV1beta1Api(
    client.ApiClient(k8s_config))
k8s_services = core.list_namespaced_service(onap_namespace).items
k8s_ingress = api_instance.list_namespaced_ingress(onap_namespace).items


def get_certif_expiration_date(host, port):
    LOGGER.debug("Host: %s", host)
    LOGGER.debug("Port: %s", port)
    cert = ssl.get_server_certificate(
        (host, port))
    LOGGER.debug("get certificate")
    x509 = OpenSSL.crypto.load_certificate(
        OpenSSL.crypto.FILETYPE_PEM, cert)

    LOGGER.debug("get certificate")
    exp_date = datetime.strptime(
        x509.get_notAfter().decode('ascii'), '%Y%m%d%H%M%SZ')
    LOGGER.debug("Expiration date retrieved %s", exp_date)
    return exp_date


def test_services(k8s_services):
    # looks for the certificates
    node_ports_list = []
    node_ports_ssl_error_list = []
    node_ports_connection_error_list = []
    node_ports_type_error_list = []
    node_ports_reset_error_list = []

    # for node ports and internal we consider the services
    # for the ingress we consider the ingress
    for service in k8s_services:
        try:
            for port in service.spec.ports:
                # We consider the node ports here
                if port.node_port is not None:
                    LOGGER.info(
                        "Look for certificate %s:%s",
                        url_onap, port.node_port)
                    exp_date = get_certif_expiration_date(
                        url_onap, port.node_port)
                    LOGGER.info("Expiration date retrieved %s", exp_date)
                    # calculate the remaining time
                    delta_time = (exp_date - datetime.now()).days
                    # add certificate to the list
                    node_ports_list.append(
                        {'pod_name': port.name,
                         'pod_node': port.node_port,
                         'expiration_date': str(exp_date),
                         'remaining_days': delta_time})
        except ssl.SSLError:
            LOGGER.error("Bad certificate for port %s" % port)
            node_ports_ssl_error_list.append(
                {'pod_name': port.name,
                 'pod_node': port.node_port})
        except ConnectionRefusedError:
            LOGGER.error("ConnectionrefusedError for port %s" % port)
            node_ports_connection_error_list.append(
                {'pod_name': port.name,
                 'pod_node': port.node_port})
        except TypeError:
            LOGGER.error("Type Error for port %s" % port)
            node_ports_type_error_list.append(
                {'pod_name': port.name,
                 'pod_node': port.node_port})
        except ConnectionResetError:
            LOGGER.error("ConnectionResetError for port %s" % port)
            node_ports_reset_error_list.append(
                {'pod_name': port.name,
                 'pod_node': port.node_port})
        else:
            LOGGER.debug("Unexpected error:", sys.exc_info()[0])

    # Create html summary
    jinja_env = Environment(
        autoescape=select_autoescape(['html']),
        loader=FileSystemLoader('./templates'))
    jinja_env.get_template(
        'cert.html.j2').stream(
            node_ports_list=node_ports_list,
            node_ports_ssl_error_list=node_ports_ssl_error_list,
            node_ports_connection_error_list=node_ports_connection_error_list,
            node_ports_type_error_list=node_ports_type_error_list,
            node_ports_reset_error_list=node_ports_reset_error_list).dump(
                '{}/certificates.html'.format('.'))


# start of the test
test_services(k8s_services)
