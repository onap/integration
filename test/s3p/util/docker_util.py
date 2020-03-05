# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import subprocess
import json
import re
from decimal import Decimal


def get_container_list(ip):
    """
    Get the list of containers running on the host
    Args:
        param1 (str): host ip

    Returns:
        list of containers in string
    """

    cmd = ['ssh', '-i', 'onap_dev']
    cmd.append('ubuntu@' + ip)
    cmd.append("sudo docker ps --format '{{.Names}}'")
    ssh = subprocess.Popen(cmd, shell=False, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
    result = ssh.stdout.readlines()
    containers = []
    if result == []:
        error = ssh.stderr.readlines()
        print(error)
    else:
        for line in result:
            token = line.decode('ascii').strip()
            containers.append(token)

    return containers


def get_container_volume_size(ip, container):
    """
    Get container total volume usage
    Args:
        param1 (str): host ip
        param2 (str): container name

    Returns:
        float number in GB if the container has volume(s), None otherwise
    """

    cmd = ['ssh', '-i', 'onap_dev']
    cmd.append('ubuntu@' + ip)
    cmd.append("sudo docker inspect -f '{{ json .Mounts }}'")
    cmd.append(container)
    ssh = subprocess.Popen(cmd, shell=False, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
    result = ssh.stdout.readlines()
    total = None
    if result == []:
        error = ssh.stderr.readlines()
        print(error)
    else:
        data = json.loads(result[0])
        for entry in data:
            if entry['Type'] == 'volume':
                name = entry['Name']
                size = get_volume_size(ip, name)
                if total is None:
                    total = size
                else:
                    total = total + size

    return total


def get_volume_size(ip, volume):
    """
    Get a volume size
    Args:
        param1 (str): host ip
        param2 (str): volume name

    Returns:
        float number in GB
    """

    cmd = ['ssh', '-i', 'onap_dev']
    cmd.append('ubuntu@' + ip)
    cmd.append('sudo docker system df -v')
    p1 = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    p2 = subprocess.Popen(['grep', volume], stdin=p1.stdout,
                          stdout=subprocess.PIPE)
    p1.stdout.close()
    (output, err) = p2.communicate() # pylint: disable=W0612
    size = output.split()[2]
    return convert_to_GB(size)


def convert_to_GB(s):
    """
    Convert volume size to GB
    Args:
        param1 (str): volume size with unit

    Returns:
        float number representing volume size in GB
    """

    if s.endswith('GB'):
        d = float(re.sub('[^0-9\\.]', '', s))
    if s.endswith('MB'):
        d = round(Decimal(float(re.sub('[^0-9\\.]', '', s)) / 1000.0),
                  1)
    if s.endswith('kB'):
        d = round(Decimal(float(re.sub('[^0-9\\.]', '', s))
                  / 1000000.0), 1)
    return d
