#!/usr/bin/python
import subprocess
import sys
import json
import datetime
import collections
import re
import tzlocal

sys.path.append('../util')
import docker_util

AAI1_NAME = "AAI1"
AAI2_NAME = "AAI2"
SO_NAME = "SO"
SDNC_NAME = "SDNC"
AAI1_IP = "10.0.1.1"
AAI2_IP = "10.0.1.2"
SO_IP = "10.0.5.1"
SDNC_IP = "10.0.7.1"

def aai1():
    containers = docker_util.get_container_list(AAI1_IP)
    run(AAI1_NAME, AAI1_IP, containers)

def aai2():
    containers = docker_util.get_container_list(AAI2_IP)
    run(AAI2_NAME, AAI2_IP, containers)

def so():
    containers = docker_util.get_container_list(SO_IP)
    run(SO_NAME, SO_IP, containers)

def sdnc():
    containers = docker_util.get_container_list(SDNC_IP)
    run(SDNC_NAME, SDNC_IP, containers)

def run(component, ip, containers):
    cmd = ["ssh", "-i", "onap_dev"]
    cmd.append("ubuntu@" + ip)
    cmd.append("sudo docker stats --no-stream")
    for c in containers:
        cmd.append(c)
    ssh = subprocess.Popen(cmd, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    result = ssh.stdout.readlines()
    if result == []:
        error = ssh.stderr.readlines()
        print(error)
    else:
        result.pop(0)
        for line in result:
            token = line.decode('ascii').strip().split()
            data = collections.OrderedDict()
            data['datetime'] = datetime.datetime.now(tzlocal.get_localzone()).strftime("%Y-%m-%dT%H:%M:%S%Z")
            data['component'] = component
            data['container'] = token[0]
            data['cpu'] = get_percent_number(token[1])
            data['memory'] = get_memory_number(token[2])
            data['physical'] = get_memory_number(token[4])
            data['mem_percent'] = get_percent_number(token[5])
            size = docker_util.get_container_volume_size(ip, data['container'])
            if size is not None:
                data['volume'] = size
            file.write(json.dumps(data, default = myconverter) + "\n")
            file.flush()

def myconverter(o):
    if isinstance(o, datetime.datetime):
        return o.__str__()

def get_percent_number(s):
    return float(re.sub('[^0-9\.]', '', s))

def get_memory_number(s):
    f = float(re.sub('[^0-9\.]', '', s))
    if s.endswith("GiB"):
        f = f*1000
    return f

file = open("resource.log", "w+")
while True:
    so()
    sdnc()
    aai1()
    aai2()
