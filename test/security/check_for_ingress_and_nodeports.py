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
# Check all ingeress controller services exposed outside of kubernetes cluster 
# looking for plain http and https.  This script looks for K8S NodePorts and ingress services declared
# in the K8S cluster configurations and check if service is allive or not.
# Automatic detect nodeport or ingress protocol HTTP or HTTPS it also detect if particular service uses HTTPS
# with self signed certificate (HTTPU).
# Verbose option retrives HTTP header and print it for each service
#
# Dependencies:
#     
#     pip3 install kubernetes
#     pip3 install colorama
#

from kubernetes import client, config
import http.client
import ssl
import socket
from enum import Enum
import argparse
import sys
from colorama import Fore, Back, Style
import urllib.parse
from os import path

#List all nodeports
def list_nodeports(v1):
    ret = {};
    svc = v1.list_namespaced_service(K8S_NAMESPACE)
    for i in svc.items:
        if i.spec.ports:
            ports = [];
            for j in i.spec.ports:
                if j.node_port: ports += [ j.node_port]
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

#Read the ingress controller http and https ports from the kubernetes config
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

# List all ingress devices
def list_ingress(xv1b):
    inglist = xv1b.list_namespaced_ingress(K8S_NAMESPACE)
    ret = {}
    for ing in inglist.items:
        svc_name = ing.metadata.labels['app']
        arr = []
        for host in ing.spec.rules:
            arr.append(host.host)
        ret[svc_name] = arr
    return ret

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
        outstr = conn.getresponse();
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
            result = port, mode, out.getcode(), out.getheaders()
            break
        else:
            result = port, retstatus, out, None
    return result
 

def scan_port(host, http, https):
    retstatus, out = scan_single_port(host,http,ScanMode.HTTPS)
    if not retstatus: 
        return host, ScanMode.HTTPS, out.getcode(), out.getheaders()
    else:
        retstatus, out = scan_single_port(host,https,ScanMode.HTTPU)
        if not retstatus:
            return host, ScanMode.HTTPU, out.getcode(), out.getheaders()
        else:
            retstatus, out = scan_single_port(host,https,ScanMode.HTTP)
            if not retstatus:
                return host, ScanMode.HTTP, out.getcode(), out.getheaders()
            else:
                return host, retstatus, out, None


# Visualise scan result
def console_visualisation(cname, name, retstatus, httpcode, out):
    print(Fore.YELLOW,end='');
    print( cname,name, end='\t',sep='\t');
    if isinstance(retstatus,ScanMode): 
        print( Fore.GREEN, '[OK ', retstatus, str(httpcode)+ ']'+Fore.RESET,end='')
        if VERBOSE: print( '\t',str(out) )
        else: print()
    else:
        if not out: out = str(retstatus)
        print( Fore.RED, '[ERROR]', Fore.RESET,end='')
        if VERBOSE: print( '\t', str(out) )
        else: print()

# Port detector type 
def check_onap_ports():
    print("Scanning onap nodeports")
    check_list = list_nodeports(v1)
    if not check_list:
        print(Fore.RED + 'Unable to find any declared node port in the K8S cluster', Fore.RESET)
    for k,v in check_list.items():
        for port in v:
            console_visualisation(k,*scan_portn(port) )

#Check ONAP ingress
def check_onap_ingress():
    print("Scanning onap ingress")
    ihttp,ihttps = find_ingress_ports(v1)
    check_list = list_ingress(v1b)
    if not check_list:
        print(Fore.RED+ 'Unable to find any declared ingress service in the K8S cluster', Fore.RESET)
    for k,v in check_list.items():
        #print( "Scanning component:", k)
        for host in v:
            console_visualisation(k,*scan_port(host,ihttp,ihttps))

#Print onap all ingress ports and node ports
def onap_list_all():
    print(Fore.YELLOW+"Onap NodePorts list",Fore.RESET)
    check_list = list_nodeports(v1)
    for name,ports in check_list.items():
        print(Fore.GREEN, name,Fore.RESET,":", *ports)
    print(Fore.YELLOW+"Onap ingress controler list",Fore.RESET)
    check_list = list_ingress(v1b)
    for name,hosts in check_list.items():
        print(Fore.GREEN, name + Fore.RESET,":", *hosts)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--scan-nodeport", 
       default=False, action='store_true',
       help='Scan onap for node services'
    )
    parser.add_argument("--scan-ingress", 
       default=False, action='store_true',
       help='Scan onap for ingress services'
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
        default='config.onap', action='store',
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
    if not path.exists(args.conf):
        print('Fatal! K8S config',args.conf, 'does not exist',file=sys.stderr)
        sys.exit(-1)
    config.load_kube_config(config_file=args.conf)
    v1 = client.CoreV1Api()
    v1b = client.ExtensionsV1beta1Api()
    v1c = client.Configuration()
    if args.scan_nodeport: check_onap_ports()
    elif args.scan_ingress: check_onap_ingress()
    else: onap_list_all()
