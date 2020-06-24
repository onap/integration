#!/usr/bin/env python3
#   COPYRIGHT NOTICE STARTS HERE
#
#   Copyright 2019 Samsung Electronics Co., Ltd.
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

# Check all node ports exposed outside of kubernetes cluster looking for plain http and https.
# Check all ingress controller services exposed outside of the kubernetes cluster
# looking for plain http and https.  This script looks for K8S NodePorts and ingress services declared
# in the K8S cluster configurations and check if service is alive or not.
# Automatic detect nodeport or ingress protocol HTTP or HTTPS it also detect if particular service uses HTTPS
# with self signed certificate (HTTPU).
# Verbose option retrives HTTP header and prints it for each service
#
# Dependencies:
#
#     pip3 install kubernetes
#     pip3 install colorama
#
# Environment:
#   This script should be run on the local machine which has network access to the onap K8S cluster.
#   It requires k8s cluster config file on local machine.
#
# Example usage:
#   Display exposed nodeport and ingress resources declared in the K8S cluster without scanning:
#       check_for_ingress_and_nodeports.py
#   Scan declared nodeports:
#       check_for_ingress_and_nodeports.py --scan-nodeport
#   Scan declared exposed ingress resources:
#       check_for_ingress_and_nodeports.py --scan-ingress

from kubernetes import client, config
import http.client
import ssl
import socket
from enum import Enum
import argparse
import sys
from colorama import Fore
import urllib.parse
from os import path

""" List all nodeports """
def list_nodeports(v1):
    ret = {}
    svc = v1.list_namespaced_service(K8S_NAMESPACE)
    for i in svc.items:
        if i.spec.ports:
            ports = [ j.node_port for j in i.spec.ports if j.node_port ]
            if ports:
                ret[i.metadata.name] = ports
    return ret

# Class enum for returning current http mode
class ScanMode(Enum):
    HTTPS = 0   #Safe https
    HTTPU = 1   #Unsafe https
    HTTP = 2    #Pure http
    def __str__(self):
        return self.name

#Read the ingress controller http and https ports from the kubernetes cluster
def find_ingress_ports(v1):
    svc = v1.list_namespaced_service(K8S_INGRESS_NS)
    http_port = 0
    https_port = 0
    for item in svc.items:
        if item.metadata.name == K8S_INGRESS_NS:
            for pinfo in item.spec.ports:
                if pinfo and pinfo.name == 'http':
                    http_port = pinfo.node_port
                elif pinfo and pinfo.name == 'https':
                    https_port = pinfo.node_port

            return http_port,https_port
        else: return(80,443)

# List all ingress devices
def list_ingress(xv1b):
    SSL_ANNOTATION = 'nginx.ingress.kubernetes.io/ssl-redirect'
    inglist = xv1b.list_namespaced_ingress(K8S_NAMESPACE)
    svc_list = {}
    for ing in inglist.items:
        svc_name = ing.metadata.labels['app']
        arr = []
        annotations = ing.metadata.annotations
        for host in ing.spec.rules:
            arr.append(host.host)
        if (SSL_ANNOTATION in annotations) and annotations[SSL_ANNOTATION]=="true":
            smode = ScanMode.HTTPS
        else: smode = ScanMode.HTTP
        svc_list[svc_name] = [ arr, smode ]
    return svc_list

# Scan single port
def scan_single_port(host,port,scanmode):
    ssl_unverified = ssl._create_unverified_context()
    if scanmode==ScanMode.HTTP:
        conn = http.client.HTTPConnection(host,port,timeout=10)
    elif scanmode==ScanMode.HTTPS:
        conn = http.client.HTTPSConnection(host,port,timeout=10)
    elif scanmode==ScanMode.HTTPU:
        conn = http.client.HTTPSConnection(host,port,timeout=10,context=ssl_unverified)
    outstr = None
    retstatus = False
    try:
        conn.request("GET","/")
        outstr = conn.getresponse()
    except http.client.BadStatusLine as exc:
        outstr = "Non HTTP proto" +  str(exc)
        retstatus = exc
    except ConnectionRefusedError as exc:
        outstr = "Connection refused" + str(exc)
        retstatus = exc
    except ConnectionResetError as exc:
        outstr = "Connection reset" + str(exc)
        retstatus = exc
    except socket.timeout as exc:
        outstr = "Connection timeout" + str(exc)
        retstatus = exc
    except ssl.SSLError as exc:
        outstr = "SSL error" + str(exc)
        retstatus = exc
    except OSError as exc:
        outstr = "OS error" + str(exc)
        retstatus = exc
    conn.close()
    return retstatus,outstr

# Scan port
def scan_portn(port):
    host =  urllib.parse.urlsplit(v1c.host).hostname
    for mode in ScanMode:
        retstatus, out = scan_single_port(host,port,mode)
        if not retstatus:
            result = port, mode, out.getcode(), out.read().decode('utf-8'),mode
            break
        else:
            result = port, retstatus, out, None,mode
    return result


def scan_port(host, http, https, mode):
    if mode==ScanMode.HTTP:
        retstatus, out = scan_single_port(host,http,ScanMode.HTTP)
        if not retstatus:
            return host, ScanMode.HTTP, out.getcode(), out.read().decode('utf-8'), mode
        else:
            return host, retstatus, out, None, mode
    elif mode==ScanMode.HTTPS:
        retstatus, out = scan_single_port(host,https,ScanMode.HTTPS)
        if not retstatus:
            return host, ScanMode.HTTPS, out.getcode(), out.read().decode('utf-8'), mode
        else:
            retstatus, out = scan_single_port(host,https,ScanMode.HTTPU)
            if not retstatus:
                return host, ScanMode.HTTPU, out.getcode(), out.read().decode('utf-8'), mode
            else:
                return host, retstatus, out, None, mode


# Visualise scan result
def console_visualisation(cname, name, retstatus, httpcode, out, mode, httpcodes = None):
    if httpcodes is None: httpcodes=[]
    print(Fore.YELLOW,end='')
    print( cname,name, end='\t',sep='\t')
    if isinstance(retstatus,ScanMode):
        if httpcode in httpcodes: estr = Fore.RED + '[ERROR '
        else:  estr = Fore.GREEN + '[OK '
        print( estr, retstatus, str(httpcode)+ ']'+Fore.RESET,end='')
        if VERBOSE: print( '\t',str(out) )
        else: print()
    else:
        if not out: out = str(retstatus)
        print( Fore.RED, '[ERROR ' +str(mode) +']', Fore.RESET,'\t', str(out))

# Visualize compare results
def console_compare_visualisation(cname,d1,d2):
    print(Fore.YELLOW,end='')
    print(cname, end='\t',sep='\t')
    if d1!=d2:
        print(Fore.RED + '[ERROR] '+ Fore.RESET)
        if d1[0]!=d2[0]:
            print('\tCode:',d1[0],'!=',d2[0])
        if d1[1]!=d2[1]:
            print('\t******** Response #1 ********\n',d1[1])
            print('\t******** Response #2 ********\n',d2[1])
    else:
        print(Fore.GREEN + '[OK ',d1[0],']', Fore.RESET,sep='')
        if VERBOSE and d1[1]:
            print(d1[1])


# Port detector type
def check_onap_ports():
    print("Scanning onap NodePorts")
    check_list = list_nodeports(v1)
    if not check_list:
        print(Fore.RED + 'Unable to find any declared node port in the K8S cluster', Fore.RESET)
    for k,v in check_list.items():
        for port in v:
            console_visualisation(k,*scan_portn(port) )

#Check ONAP ingress
def check_onap_ingress():
    print("Scanning onap ingress services")
    ihttp,ihttps = find_ingress_ports(v1)
    check_list = list_ingress(v1b)
    if not check_list:
        print(Fore.RED+ 'Unable to find any declared ingress service in the K8S cluster', Fore.RESET)
    for k,v in check_list.items():
        for host in v[0]:
            console_visualisation(k,*scan_port(host,ihttp,ihttps,v[1]),httpcodes=[404])

#Print onap all ingress ports and node ports
def onap_list_all():
    ihttp,ihttps = find_ingress_ports(v1)
    host =  urllib.parse.urlsplit(v1c.host).hostname
    print( 'Cluster IP' + Fore.YELLOW, host, Fore.RESET )
    print('Ingress ' + Fore.RED + 'HTTP'  + Fore.RESET + '  port:',Fore.YELLOW, ihttp, Fore.RESET)
    print('Ingress ' + Fore.RED + 'HTTPS' + Fore.RESET + ' port:',Fore.YELLOW, ihttps, Fore.RESET)
    print(Fore.YELLOW+"Onap NodePorts list:",Fore.RESET)
    check_list = list_nodeports(v1)
    for name,ports in check_list.items():
        print(Fore.GREEN, name,Fore.RESET,":", *ports)
    print(Fore.YELLOW+"Onap ingress controler services list:",Fore.RESET)
    check_list = list_ingress(v1b)
    for name,hosts in check_list.items():
        print(Fore.GREEN, name + Fore.RESET,":", *hosts[0], Fore.RED+':', hosts[1],Fore.RESET)

#Scan and compare nodeports and ingress check for results
def compare_nodeports_and_ingress():
    ihttp,ihttps = find_ingress_ports(v1)
    print('Scanning nodeport services ...')
    check_list = list_nodeports(v1)
    if not check_list:
        print(Fore.RED + 'Unable to find any declared node port in the K8S cluster', Fore.RESET)
    valid_results = {}
    for k,v in check_list.items():
        for port in v:
            nodeport_results = scan_portn(port)
            if isinstance(nodeport_results[1],ScanMode) and nodeport_results[2] != 404:
                valid_results[k] = nodeport_results
            if VERBOSE: console_visualisation(k,*nodeport_results)
    check_list = list_ingress(v1b)
    if not check_list:
        print(Fore.RED+ 'Unable to find any declared ingress service in the K8S cluster', Fore.RESET)
    print('Scanning ingress services ...')
    ing_valid_results = {}
    for k,v in check_list.items():
        for host in v[0]:
            ingress_results = scan_port(host,ihttp,ihttps,v[1])
            if isinstance(ingress_results[1],ScanMode) and ingress_results[2]!=404:
                ing_valid_results[k] = ingress_results
            if VERBOSE: console_visualisation(k,*ingress_results,httpcodes=[404])
    ks1 = set(valid_results.keys())
    ks2 = set(ing_valid_results.keys())
    diff_keys = (ks1 - ks2) | (ks2 - ks1)
    common_keys = ks1 & ks2
    if VERBOSE and diff_keys:
        print(Fore.BLUE + '[WARNING] Non matching nodes and ingress list:')
        for key in diff_keys: print(key,sep='\t')
        print(Fore.RESET + 'Please check is it correct.')
    print('Matching ingress and nodeport host scan results:')
    for scan_key in common_keys:
        s1 = valid_results[scan_key][2:4]
        s2 = ing_valid_results[scan_key][2:4]
        num_failures = 0
        if s1!=s2: ++num_failures
        console_compare_visualisation(scan_key,s1,s2)
    return num_failures



if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    command_group = parser.add_mutually_exclusive_group()
    command_group.add_argument("--scan-nodeport",
       default=False, action='store_true',
       help='Scan onap for node services'
    )
    command_group.add_argument("--scan-ingress",
       default=False, action='store_true',
       help='Scan onap for ingress services'
    )
    command_group.add_argument("--scan-and-compare",
       default=False, action='store_true',
       help='Scan nodeports and ingress and compare results'
    )
    parser.add_argument( "--namespace",
        default='onap', action='store',
        help = 'kubernetes onap namespace'
    )
    parser.add_argument( "--ingress-namespace",
        default='ingress-nginx', action='store',
        help = 'kubernetes ingress namespace'
    )
    parser.add_argument( "--conf",
        default='~/.kube/config', action='store',
        help = 'kubernetes config file'
    )
    parser.add_argument("--verbose",
       default=False, action='store_true',
       help='Verbose output'
    )
    args = parser.parse_args()
    K8S_NAMESPACE = args.namespace
    K8S_INGRESS_NS  = args.ingress_namespace
    VERBOSE = args.verbose
    try:
        assert path.exists(args.conf)
    except AssertionError:
        print('Fatal! K8S config',args.conf, 'does not exist',file=sys.stderr)
        sys.exit(-1)
    config.load_kube_config(config_file=args.conf)
    v1 = client.CoreV1Api()
    v1b = client.ExtensionsV1beta1Api()
    v1c = client.Configuration()
    if args.scan_nodeport: check_onap_ports()
    elif args.scan_ingress: check_onap_ingress()
    elif args.scan_and_compare: sys.exit(compare_nodeports_and_ingress())
    else: onap_list_all()
