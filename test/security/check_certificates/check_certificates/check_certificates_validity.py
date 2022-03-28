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
"""
Check ONAP certificates
"""
import argparse
import logging
import os
import ssl
import sys
import OpenSSL
from datetime import datetime
from kubernetes import client, config
from jinja2 import Environment, FileSystemLoader, select_autoescape
from socket import *  # pylint: disable=W0614

# Set SSL timeout
setdefaulttimeout(10)

# Logger
LOG_LEVEL = 'INFO'
logging.basicConfig()
LOGGER = logging.getLogger("Gating-Index")
LOGGER.setLevel(LOG_LEVEL)
CERT_MODES = ['nodeport', 'ingress', 'internal']
EXP_CRITERIA_MIN = 30
EXP_CRITERIA_MAX = 389
EXPECTED_CERT_STRING = "C=US;O=ONAP;OU=OSAAF;CN=intermediateCA_9"
EXPECTED_STRIMZI_CA_CERT_STRING = "O=io.strimzi;CN=cluster-ca v0"
RESULT_PATH = "."


# Get arguments
parser = argparse.ArgumentParser()
parser.add_argument(
    '-m',
    '--mode',
    choices=CERT_MODES,
    help='Mode (nodeport, ingress, internal). If not set all modes are tried',
    default='nodeport')
parser.add_argument(
    '-i',
    '--ip',
    help='ONAP IP needed (for nodeport mode)',
    default=os.environ.get('ONAP_IP'))
parser.add_argument(
    '-n',
    '--namespace',
    help='ONAP namespace',
    default='onap')
parser.add_argument(
    '-d',
    '--dir',
    help='Result directory',
    default=RESULT_PATH)

args = parser.parse_args()

# Get the ONAP namespace
onap_namespace = args.namespace
LOGGER.info("Verification of the %s certificates started", onap_namespace)

# Create the target dir (in case it does not exist)
if os.pardir not in args.dir:
    os.makedirs(args.dir, exist_ok=True)

# Nodeport specific section
# Retrieve the kubernetes IP for mode nodeport
if args.mode == "nodeport":
    if args.ip is None:
        LOGGER.error(
            "In nodeport mode, the IP of the ONAP cluster is required." +
            "The value can be set using -i option " +
            "or retrieved from the ONAP_IP env variable")
        exit(parser.print_usage())
    try:
        nodeports_xfail_list = []
        with open('nodeports_xfail.txt', 'r') as f:
            first_line = f.readline()
            for line in f:
                nodeports_xfail_list.append(
                    line.split(" ", 1)[0].strip('\n'))
                LOGGER.info("nodeports xfail list: %s",
                            nodeports_xfail_list)
    except KeyError:
        LOGGER.error("Please set the environment variable ONAP_IP")
        sys.exit(1)
    except FileNotFoundError:
        LOGGER.warning("Nodeport xfail list not found")

# Kubernetes section
# retrieve the candidate ports first
if args.mode == "internal":
    k8s_config = config.load_incluster_config()
else:
    k8s_config = config.load_kube_config()

core = client.CoreV1Api()
api_instance = client.NetworkingV1Api(
    client.ApiClient(k8s_config))
k8s_services = core.list_namespaced_service(onap_namespace).items
k8s_ingress = api_instance.list_namespaced_ingress(onap_namespace).items


def get_certifificate_info(host, port):
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
    issuer = x509.get_issuer().get_components()

    issuer_info = ''
    # format issuer nicely
    for issuer_info_key, issuer_info_val in issuer:
        issuer_info += (issuer_info_key.decode('utf-8') + "=" +
                        issuer_info_val.decode('utf-8') + ";")
    cert_validity = False
    if issuer_info[:-1] == EXPECTED_CERT_STRING or issuer_info[:-1] == EXPECTED_STRIMZI_CA_CERT_STRING:
        cert_validity = True

    return {'expiration_date': exp_date,
            'issuer': issuer_info[:-1],
            'validity': cert_validity}


def test_services(k8s_services, mode):
    success_criteria = True  # success criteria per scan
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
                # For nodeport mode, we consider
                # - the IP of the cluster
                # - spec.port.node_port
                #
                # For internal mode, we consider
                # - spec.selector.app
                # - spec.port.port
                test_name = service.metadata.name
                test_port = None
                error_waiver = False  # waiver per port
                if mode == 'nodeport':
                    test_url = args.ip
                    test_port = port.node_port

                    # Retrieve the nodeport xfail list
                    # to consider SECCOM waiver if needed
                    if test_port in nodeports_xfail_list:
                        error_waiver = True
                else:  # internal mode
                    test_port = port.port
                    test_url = ''
                    # in Internal mode there are 2 types
                    # app
                    # app.kubernetes.io/name
                    try:
                        test_url = service.spec.selector['app']
                    except KeyError:
                        test_url = service.spec.selector['app.kubernetes.io/name']

                if test_port is not None:
                    LOGGER.info(
                        "Look for certificate %s (%s:%s)",
                        test_name,
                        test_url,
                        test_port)
                    cert_info = get_certifificate_info(test_url, test_port)
                    exp_date = cert_info['expiration_date']
                    LOGGER.info("Expiration date retrieved %s", exp_date)
                    # calculate the remaining time
                    delta_time = (exp_date - datetime.now()).days

                    # Test criteria
                    if error_waiver:
                        LOGGER.info("Port found in the xfail list," +
                                    "do not consider it for success criteria")
                    else:
                        if (delta_time < EXP_CRITERIA_MIN or
                                delta_time > EXP_CRITERIA_MAX):
                            success_criteria = False
                        if cert_info['validity'] is False:
                            success_criteria = False
                    # add certificate to the list
                    node_ports_list.append(
                        {'pod_name': test_name,
                         'pod_port': test_port,
                         'expiration_date': str(exp_date),
                         'remaining_days': delta_time,
                         'cluster_ip': service.spec.cluster_ip,
                         'issuer': cert_info['issuer'],
                         'validity': cert_info['validity']})
                else:
                    LOGGER.debug("Port value retrieved as None")
        except ssl.SSLError as e:
            LOGGER.exception("Bad certificate for port %s" % port)
            node_ports_ssl_error_list.append(
                {'pod_name': test_name,
                 'pod_port': test_port,
                 'error_details': str(e)})
        except ConnectionRefusedError as e:
            LOGGER.exception("ConnectionrefusedError for port %s" % port)
            node_ports_connection_error_list.append(
                {'pod_name': test_name,
                 'pod_port': test_port,
                 'error_details': str(e)})
        except TypeError as e:
            LOGGER.exception("Type Error for port %s" % port)
            node_ports_type_error_list.append(
                {'pod_name': test_name,
                 'pod_port': test_port,
                 'error_details': str(e)})
        except ConnectionResetError as e:
            LOGGER.exception("ConnectionResetError for port %s" % port)
            node_ports_reset_error_list.append(
                {'pod_name': test_name,
                 'pod_port': test_port,
                 'error_details': str(e)})
        except:
            LOGGER.error("Unknown error")

    # Create html summary
    jinja_env = Environment(
        autoescape=select_autoescape(['html']),
        loader=FileSystemLoader('./templates'))
    if args.mode == 'nodeport':
        jinja_env.get_template('cert-nodeports.html.j2').stream(
            node_ports_list=node_ports_list,
            node_ports_ssl_error_list=node_ports_ssl_error_list,
            node_ports_connection_error_list=node_ports_connection_error_list,
            node_ports_type_error_list=node_ports_type_error_list,
            node_ports_reset_error_list=node_ports_reset_error_list).dump(
            '{}/certificates.html'.format(args.dir))
    else:
        jinja_env.get_template('cert-internal.html.j2').stream(
            node_ports_list=node_ports_list,
            node_ports_ssl_error_list=node_ports_ssl_error_list,
            node_ports_connection_error_list=node_ports_connection_error_list,
            node_ports_type_error_list=node_ports_type_error_list,
            node_ports_reset_error_list=node_ports_reset_error_list).dump(
            '{}/certificates.html'.format(args.dir))

    return success_criteria


def test_ingress(k8s_ingress, mode):
    LOGGER.debug('Test %s mode', mode)
    for ingress in k8s_ingress:
        LOGGER.debug(ingress)
    return True


# ***************************************************************************
# ***************************************************************************
# start of the test
# ***************************************************************************
# ***************************************************************************
test_status = True
if args.mode == "ingress":
    test_routine = test_ingress
    test_param = k8s_ingress
else:
    test_routine = test_services
    test_param = k8s_services

LOGGER.info(">>>> Test certificates: mode = %s", args.mode)
if test_routine(test_param, args.mode):
    LOGGER.warning(">>>> Test PASS")
else:
    LOGGER.warning(">>>> Test FAIL")
    test_status = False

if test_status:
    LOGGER.info(">>>> Test Check certificates PASS")
else:
    LOGGER.error(">>>> Test Check certificates FAIL")
    sys.exit(1)
