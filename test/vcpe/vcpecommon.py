import json
import logging
import os
import pickle
import re
import sys

import ipaddress
import mysql.connector
import requests
import commands
import time
from novaclient import client as openstackclient
from kubernetes import client, config
from netaddr import IPAddress, IPNetwork

class VcpeCommon:
    #############################################################################################
    #     Start: configurations that you must change for a new ONAP installation
    external_net_addr = '10.12.0.0'
    external_net_prefix_len = 16
    #############################################################################################
    # set the openstack cloud access credentials here
    oom_mode = True

    cloud = {
        '--os-auth-url': 'http://10.12.25.2:5000',
        '--os-username': 'kxi',
        '--os-user-domain-id': 'default',
        '--os-project-domain-id': 'default',
        '--os-tenant-id': 'bc43d50ffcb84750bac0c1707a9a765b' if oom_mode else '1e097c6713e74fd7ac8e4295e605ee1e',
        '--os-region-name': 'RegionOne',
        '--os-password': 'n3JhGMGuDzD8',
        '--os-project-domain-name': 'Integration-SB-03' if oom_mode else 'Integration-SB-07',
        '--os-identity-api-version': '3'
    }

    common_preload_config = {
        'oam_onap_net': 'oam_network_2No2' if oom_mode else 'oam_onap_lAky',
        'oam_onap_subnet': 'oam_network_2No2' if oom_mode else 'oam_onap_lAky',
        'public_net': 'external',
        'public_net_id': '971040b2-7059-49dc-b220-4fab50cb2ad4'
    }
    sdnc_controller_pod = 'dev-sdnc-sdnc-0'

    #############################################################################################

    template_variable_symbol = '${'
    cpe_vm_prefix = 'zdcpe'
    #############################################################################################
    # preloading network config
    #  key=network role
    #  value = [subnet_start_ip, subnet_gateway_ip]
    preload_network_config = {
        'cpe_public': ['10.2.0.2', '10.2.0.1'],
        'cpe_signal': ['10.4.0.2', '10.4.0.1'],
        'brg_bng': ['10.3.0.2', '10.3.0.1'],
        'bng_mux': ['10.1.0.10', '10.1.0.1'],
        'mux_gw': ['10.5.0.10', '10.5.0.1']
    }

    dcae_ves_collector_name = 'dcae-bootstrap'
    global_subscriber_id = 'SDN-ETHERNET-INTERNET'
    project_name = 'Project-Demonstration'
    owning_entity_id = '520cc603-a3c4-4ec2-9ef4-ca70facd79c0'
    owning_entity_name = 'OE-Demonstration1'

    def __init__(self, extra_host_names=None):
        rootlogger = logging.getLogger()
        handler = logging.StreamHandler()
        formatter = logging.Formatter('%(asctime)s %(levelname)s %(name)s.%(funcName)s(): %(message)s')
        handler.setFormatter(formatter)
        rootlogger.addHandler(handler)
        rootlogger.setLevel(logging.INFO)

        self.logger = logging.getLogger(__name__)
        self.logger.propagate = False
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.DEBUG)
        self.logger.info('Initializing configuration')

        # CHANGEME: vgw_VfModuleModelInvariantUuid is in rescust service csar, look in service-VcpesvcRescust1118-template.yml for groups vgw module metadata. TODO: read this value automcatically
        self.vgw_VfModuleModelInvariantUuid = '26d6a718-17b2-4ba8-8691-c44343b2ecd2'
        # CHANGEME: OOM: this is the address that the brg and bng will nat for sdnc access - 10.0.0.x address of k8 host for sdnc-0 container
        self.sdnc_oam_ip = self.get_pod_node_oam_ip('sdnc-sdnc-0')
        # CHANGEME: OOM: this is a k8s host external IP, e.g. oom-k8s-01 IP 
        self.oom_so_sdnc_aai_ip = self.get_pod_node_public_ip('sdnc-sdnc-0')
        # CHANGEME: OOM: this is a k8s host external IP, e.g. oom-k8s-01 IP
        self.oom_dcae_ves_collector = self.oom_so_sdnc_aai_ip
        # CHANGEME: OOM: this is a k8s host external IP, e.g. oom-k8s-01 IP
        self.mr_ip_addr = self.oom_so_sdnc_aai_ip
        self.mr_ip_port = '30227'
        self.so_nbi_port = '30277' if self.oom_mode else '8080'
        self.sdnc_preloading_port = '30202' if self.oom_mode else '8282'
        self.aai_query_port = '30233' if self.oom_mode else '8443'
        self.sniro_port = '30288' if self.oom_mode else '8080'

        self.host_names = ['sdc', 'so', 'sdnc', 'robot', 'aai-inst1', self.dcae_ves_collector_name]
        if extra_host_names:
            self.host_names.extend(extra_host_names)
        # get IP addresses
        self.hosts = self.get_vm_ip(self.host_names, self.external_net_addr, self.external_net_prefix_len)
        # this is the keyword used to name vgw stack, must not be used in other stacks
        self.vgw_name_keyword = 'base_vcpe_vgw'
        # this is the file that will keep the index of last assigned SO name
        self.vgw_vfmod_name_index_file= '__var/vgw_vfmod_name_index'
        self.svc_instance_uuid_file = '__var/svc_instance_uuid'
        self.preload_dict_file = '__var/preload_dict'
        self.vgmux_vnf_name_file = '__var/vgmux_vnf_name'
        self.product_family_id = 'f9457e8c-4afd-45da-9389-46acd9bf5116'
        self.custom_product_family_id = 'a9a77d5a-123e-4ca2-9eb9-0b015d2ee0fb'
        self.instance_name_prefix = {
            'service': 'vcpe_svc',
            'network': 'vcpe_net',
            'vnf': 'vcpe_vnf',
            'vfmodule': 'vcpe_vfmodule'
        }
        self.aai_userpass = 'AAI', 'AAI'
        self.pub_key = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKXDgoo3+WOqcUG8/5uUbk81+yczgwC4Y8ywTmuQqbNxlY1oQ0YxdMUqUnhitSXs5S/yRuAVOYHwGg2mCs20oAINrP+mxBI544AMIb9itPjCtgqtE2EWo6MmnFGbHB4Sx3XioE7F4VPsh7japsIwzOjbrQe+Mua1TGQ5d4nfEOQaaglXLLPFfuc7WbhbJbK6Q7rHqZfRcOwAMXgDoBqlyqKeiKwnumddo2RyNT8ljYmvB6buz7KnMinzo7qB0uktVT05FH9Rg0CTWH5norlG5qXgP2aukL0gk1ph8iAt7uYLf1ktp+LJI2gaF6L0/qli9EmVCSLr1uJ38Q8CBflhkh'
        self.os_tenant_id = self.cloud['--os-tenant-id']
        self.os_region_name = self.cloud['--os-region-name']
        self.common_preload_config['pub_key'] = self.pub_key
        self.sniro_url = 'http://' + self.hosts['robot'] + ':' + self.sniro_port + '/__admin/mappings'
        self.sniro_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.homing_solution = 'sniro'  # value is either 'sniro' or 'oof'
#        self.homing_solution = 'oof'
        self.customer_location_used_by_oof = {
            "customerLatitude": "32.897480",
            "customerLongitude": "-97.040443",
            "customerName": "some_company"
        }

        #############################################################################################
        # SDC urls
        self.sdc_get_request_userpass = 'vid','Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U'
        self.sdc_get_request_headers = {'X-ECOMP-InstanceID': 'VID'}
        self.sdc_port = '30205'
        self.sdc_url_prefix = 'http://' + self.hosts['sdc'] + ':' + self.sdc_port
        self.sdc_service_list_url = self.sdc_url_prefix + '/sdc/v1/catalog/services'

        #############################################################################################
        # SDNC urls
        self.sdnc_userpass = 'admin', 'Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U'
        self.sdnc_db_name = 'sdnctl'
        self.sdnc_db_user = 'sdnctl'
        self.sdnc_db_pass = 'gamma'
        self.sdnc_db_port = '32774'
        self.sdnc_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.sdnc_preload_network_url = 'http://' + self.hosts['sdnc'] + \
                                        ':' + self.sdnc_preloading_port + '/restconf/operations/VNF-API:preload-network-topology-operation'
        self.sdnc_preload_vnf_url = 'http://' + self.hosts['sdnc'] + \
                                    ':' + self.sdnc_preloading_port + '/restconf/operations/VNF-API:preload-vnf-topology-operation'
        self.sdnc_preload_gra_url = 'http://' + self.hosts['sdnc'] + \
                                    ':' + self.sdnc_preloading_port + '/restconf/operations/GENERIC-RESOURCE-API:preload-vf-module-topology-operation'
        self.sdnc_ar_cleanup_url = 'http://' + self.hosts['sdnc'] + ':' + self.sdnc_preloading_port + \
                                   '/restconf/config/GENERIC-RESOURCE-API:'

        #############################################################################################
        # SO urls, note: do NOT add a '/' at the end of the url
        self.so_req_api_url = {'v4': 'http://' + self.hosts['so'] + ':' + self.so_nbi_port + '/onap/so/infra/serviceInstantiation/v7/serviceInstances',
                           'v5': 'http://' + self.hosts['so'] + ':' + self.so_nbi_port + '/onap/so/infra/serviceInstantiation/v7/serviceInstances'}
        self.so_check_progress_api_url = 'http://' + self.hosts['so'] + ':' + self.so_nbi_port + '/onap/so/infra/orchestrationRequests/v6'
        self.so_userpass = 'InfraPortalClient', 'password1$'
        self.so_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.so_db_name = 'catalogdb'
        self.so_db_user = 'root'
        self.so_db_pass = 'password'
        self.so_db_port = '30252' if self.oom_mode else '32769'

        self.vpp_inf_url = 'http://{0}:8183/restconf/config/ietf-interfaces:interfaces'
        self.vpp_api_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.vpp_api_userpass = ('admin', 'admin')
        self.vpp_ves_url= 'http://{0}:8183/restconf/config/vesagent:vesagent'

    def headbridge(self, openstack_stack_name, svc_instance_uuid):
        """
        Add vserver information to AAI
        """
        self.logger.info('Adding vServer information to AAI for {0}'.format(openstack_stack_name))
        if not self.oom_mode:
            cmd = '/opt/demo.sh heatbridge {0} {1} vCPE'.format(openstack_stack_name, svc_instance_uuid)
            ret = commands.getstatusoutput("ssh -i onap_dev root@{0} '{1}'".format(self.hosts['robot'], cmd))
            self.logger.debug('%s', ret)
        else:
            print('To add vGMUX vserver info to AAI, do the following:')
            print('- ssh to rancher')
            print('- sudo su -')
            print('- cd /root/oom/kubernetes/robot')
            print('- ./demo-k8s.sh onap heatbridge {0} {1} vCPE'.format(openstack_stack_name, svc_instance_uuid))

    def get_brg_mac_from_sdnc(self):
        """
        Check table DHCP_MAP in the SDNC DB. Find the newly instantiated BRG MAC address.
        Note that there might be multiple BRGs, the most recently instantiated BRG always has the largest IP address.
        """
        cnx = mysql.connector.connect(user=self.sdnc_db_user, password=self.sdnc_db_pass, database=self.sdnc_db_name,
                                      host=self.hosts['sdnc'], port=self.sdnc_db_port)
        cursor = cnx.cursor()
        query = "SELECT * from DHCP_MAP"
        cursor.execute(query)

        self.logger.debug('DHCP_MAP table in SDNC')
        mac_recent = None
        host = -1
        for mac, ip in cursor:
            self.logger.debug(mac + ':' + ip)
            this_host = int(ip.split('.')[-1])
            if host < this_host:
                host = this_host
                mac_recent = mac

        cnx.close()

        assert mac_recent
        return mac_recent

    def execute_cmds_sdnc_db(self, cmds):
        self.execute_cmds_db(cmds, self.sdnc_db_user, self.sdnc_db_pass, self.sdnc_db_name,
                             self.hosts['sdnc'], self.sdnc_db_port)

    def execute_cmds_so_db(self, cmds):
        self.execute_cmds_db(cmds, self.so_db_user, self.so_db_pass, self.so_db_name,
                             self.hosts['so'], self.so_db_port)

    def execute_cmds_db(self, cmds, dbuser, dbpass, dbname, host, port):
        cnx = mysql.connector.connect(user=dbuser, password=dbpass, database=dbname, host=host, port=port)
        cursor = cnx.cursor()
        for cmd in cmds:
            self.logger.debug(cmd)
            cursor.execute(cmd)
            self.logger.debug('%s', cursor)
        cnx.commit()
        cursor.close()
        cnx.close()

    def find_file(self, file_name_keyword, file_ext, search_dir):
        """
        :param file_name_keyword:  keyword used to look for the csar file, case insensitive matching, e.g, infra
        :param file_ext: e.g., csar, json
        :param search_dir path to search
        :return: path name of the file
        """
        file_name_keyword = file_name_keyword.lower()
        file_ext = file_ext.lower()
        if not file_ext.startswith('.'):
            file_ext = '.' + file_ext

        filenamepath = None
        for file_name in os.listdir(search_dir):
            file_name_lower = file_name.lower()
            if file_name_keyword in file_name_lower and file_name_lower.endswith(file_ext):
                if filenamepath:
                    self.logger.error('Multiple files found for *{0}*.{1} in '
                                      'directory {2}'.format(file_name_keyword, file_ext, search_dir))
                    sys.exit()
                filenamepath = os.path.abspath(os.path.join(search_dir, file_name))

        if filenamepath:
            return filenamepath
        else:
            self.logger.error("Cannot find *{0}*{1} in directory {2}".format(file_name_keyword, file_ext, search_dir))
            sys.exit()

    @staticmethod
    def network_name_to_subnet_name(network_name):
        """
        :param network_name: example: vcpe_net_cpe_signal_201711281221
        :return: vcpe_net_cpe_signal_subnet_201711281221
        """
        fields = network_name.split('_')
        fields.insert(-1, 'subnet')
        return '_'.join(fields)

    def set_network_name(self, network_name):
        param = ' '.join([k + ' ' + v for k, v in self.cloud.items()])
        openstackcmd = 'openstack ' + param
        cmd = ' '.join([openstackcmd, 'network set --name', network_name, 'ONAP-NW1'])
        os.popen(cmd)

    def set_subnet_name(self, network_name):
        """
        Example: network_name =  vcpe_net_cpe_signal_201711281221
        set subnet name to vcpe_net_cpe_signal_subnet_201711281221
        :return:
        """
        param = ' '.join([k + ' ' + v for k, v in self.cloud.items()])
        openstackcmd = 'openstack ' + param

        # expected results: | subnets | subnet_id |
        subnet_info = os.popen(openstackcmd + ' network show ' + network_name + ' |grep subnets').read().split('|')
        if len(subnet_info) > 2 and subnet_info[1].strip() == 'subnets':
            subnet_id = subnet_info[2].strip()
            subnet_name = self.network_name_to_subnet_name(network_name)
            cmd = ' '.join([openstackcmd, 'subnet set --name', subnet_name, subnet_id])
            os.popen(cmd)
            self.logger.info("Subnet name set to: " + subnet_name)
            return True
        else:
            self.logger.error("Can't get subnet info from network name: " + network_name)
            return False

    def is_node_in_aai(self, node_type, node_uuid):
        key = None
        search_node_type = None
        if node_type == 'service':
            search_node_type = 'service-instance'
            key = 'service-instance-id'
        elif node_type == 'vnf':
            search_node_type = 'generic-vnf'
            key = 'vnf-id'
        else:
            logging.error('Invalid node_type: ' + node_type)
            sys.exit()

        url = 'https://{0}:{1}/aai/v11/search/nodes-query?search-node-type={2}&filter={3}:EQUALS:{4}'.format(
            self.hosts['aai-inst1'], self.aai_query_port, search_node_type, key, node_uuid)

        headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'X-FromAppID': 'vCPE-Robot', 'X-TransactionId': 'get_aai_subscr'}
        requests.packages.urllib3.disable_warnings()
        r = requests.get(url, headers=headers, auth=self.aai_userpass, verify=False)
        response = r.json()
        self.logger.debug('aai query: ' + url)
        self.logger.debug('aai response:\n' + json.dumps(response, indent=4, sort_keys=True))
        return 'result-data' in response

    @staticmethod
    def extract_ip_from_str(net_addr, net_addr_len, sz):
        """
        :param net_addr:  e.g. 10.5.12.0
        :param net_addr_len: e.g. 24
        :param sz: a string
        :return: the first IP address matching the network, e.g. 10.5.12.3
        """
        network = ipaddress.ip_network(unicode('{0}/{1}'.format(net_addr, net_addr_len)), strict=False)
        ip_list = re.findall(r'[0-9]+(?:\.[0-9]+){3}', sz)
        for ip in ip_list:
            this_net = ipaddress.ip_network(unicode('{0}/{1}'.format(ip, net_addr_len)), strict=False)
            if this_net == network:
                return str(ip)
        return None

    def get_pod_node_oam_ip(self, pod):
        """
        :Assuming kubectl is available and configured by default config (~/.kube/config) 
        :param pod: pod name substring, e.g. 'sdnc-sdnc-0'
        :return pod's cluster node oam ip (10.0.0.0/16)
        """
        ret = None
        config.load_kube_config()
        api = client.CoreV1Api()
        kslogger = logging.getLogger('kubernetes')
        kslogger.setLevel(logging.INFO)
        res = api.list_pod_for_all_namespaces()
        for i in res.items:
            if pod in i.metadata.name:
                self.logger.debug("found {0}\t{1}\t{2}".format(i.metadata.name, i.status.host_ip, i.spec.node_name))
                ret = i.status.host_ip
                break

        if ret is None:
            ret = raw_input("Enter sdnc-sdnc-0 pod cluster node OAM IP address(10.0.0.0/16): ")
        return ret

    def get_pod_node_public_ip(self, pod):
        """
        :Assuming kubectl is available and configured by default config (~/.kube/config) 
        :param pod: pod name substring, e.g. 'sdnc-sdnc-0'
        :return pod's cluster node public ip (i.e. 10.12.0.0/16)
        """
        ret = None
        config.load_kube_config()
        api = client.CoreV1Api()
        kslogger = logging.getLogger('kubernetes')
        kslogger.setLevel(logging.INFO)
        res = api.list_pod_for_all_namespaces()
        for i in res.items:
            if pod in i.metadata.name:
                ret = self.get_vm_public_ip_by_nova(i.spec.node_name)
                self.logger.debug("found node {0} public ip: {1}".format(i.spec.node_name, ret))
                break

        if ret is None:
            ret = raw_input("Enter sdnc-sdnc-0 pod cluster node public IP address(i.e. 10.12.0.0/16): ")
        return ret

    def get_vm_public_ip_by_nova(self, vm):
        """
        This method uses openstack nova api to retrieve vm public ip
        :param vm: vm name
        :return vm public ip
        """
        subnet = IPNetwork('{0}/{1}'.format(self.external_net_addr, self.external_net_prefix_len))
        nova = openstackclient.Client(2, self.cloud['--os-username'], self.cloud['--os-password'], self.cloud['--os-tenant-id'], self.cloud['--os-auth-url']) 
        for i in nova.servers.list():
            if i.name == vm:
                for k, v in i.networks.items():
                    for ip in v:
                        if IPAddress(ip) in subnet:
                            return ip
        return None

    def get_vm_ip(self, keywords, net_addr=None, net_addr_len=None):
        """
        :param keywords: list of keywords to search for vm, e.g. ['bng', 'gmux', 'brg']
        :param net_addr: e.g. 10.12.5.0
        :param net_addr_len: e.g. 24
        :return: dictionary {keyword: ip}
        """
        if not net_addr:
            net_addr = self.external_net_addr

        if not net_addr_len:
            net_addr_len = self.external_net_prefix_len

        param = ' '.join([k + ' ' + v for k, v in self.cloud.items() if 'identity' not in k])
        openstackcmd = 'nova ' + param + ' list'
        self.logger.debug(openstackcmd)

        results = os.popen(openstackcmd).read()
        all_vm_ip_dict = self.extract_vm_ip_as_dict(results, net_addr, net_addr_len)
        latest_vm_list = self.remove_old_vms(all_vm_ip_dict.keys(), self.cpe_vm_prefix)
        latest_vm_ip_dict = {vm: all_vm_ip_dict[vm] for vm in latest_vm_list}
        ip_dict = self.select_subset_vm_ip(latest_vm_ip_dict, keywords)
        if self.oom_mode:
            ip_dict.update(self.get_oom_onap_vm_ip(keywords))

        if len(ip_dict) != len(keywords):
            self.logger.error('Cannot find all desired IP addresses for %s.', keywords)
            self.logger.error(json.dumps(ip_dict, indent=4, sort_keys=True))
            self.logger.error('Temporarily continue.. remember to check back vcpecommon.py line: 396')
#            sys.exit()
        return ip_dict

    def get_oom_onap_vm_ip(self, keywords):
        vm_ip = {}
        onap_vm_list = set(['sdc', 'so', 'sdnc', 'aai-inst1', 'robot', self.dcae_ves_collector_name])
        for vm in keywords:
            if vm in onap_vm_list:
                vm_ip[vm] = self.oom_so_sdnc_aai_ip
        return vm_ip

    def extract_vm_ip_as_dict(self, novalist_results, net_addr, net_addr_len):
        vm_ip_dict = {}
        for line in novalist_results.split('\n'):
            fields = line.split('|')
            if len(fields) == 8:
                vm_name = fields[2]
                ip_info = fields[-2]
                ip = self.extract_ip_from_str(net_addr, net_addr_len, ip_info)
                vm_ip_dict[vm_name] = ip

        return vm_ip_dict

    def remove_old_vms(self, vm_list, prefix):
        """
        For vms with format name_timestamp, only keep the one with the latest timestamp.
        E.g.,
            zdcpe1cpe01brgemu01_201805222148        (drop this)
            zdcpe1cpe01brgemu01_201805222229        (keep this)
            zdcpe1cpe01gw01_201805162201
        """
        new_vm_list = []
        same_type_vm_dict = {}
        for vm in vm_list:
            fields = vm.split('_')
            if vm.startswith(prefix) and len(fields) == 2 and len(fields[-1]) == len('201805222148') and fields[-1].isdigit():
                if vm > same_type_vm_dict.get(fields[0], '0'):
                    same_type_vm_dict[fields[0]] = vm
            else:
                new_vm_list.append(vm)

        new_vm_list.extend(same_type_vm_dict.values())
        return new_vm_list

    def select_subset_vm_ip(self, all_vm_ip_dict, vm_name_keyword_list):
        vm_ip_dict = {}
        for keyword in vm_name_keyword_list:
            for vm, ip in all_vm_ip_dict.items():
                if keyword in vm:
                    vm_ip_dict[keyword] = ip
                    break
        return vm_ip_dict

    def del_vgmux_ves_mode(self):
        url = self.vpp_ves_url.format(self.hosts['mux']) + '/mode'
        r = requests.delete(url, headers=self.vpp_api_headers, auth=self.vpp_api_userpass)
        self.logger.debug('%s', r)

    def del_vgmux_ves_collector(self):
        url = self.vpp_ves_url.format(self.hosts['mux']) + '/config'
        r = requests.delete(url, headers=self.vpp_api_headers, auth=self.vpp_api_userpass)
        self.logger.debug('%s', r)

    def set_vgmux_ves_collector(self ):
        url = self.vpp_ves_url.format(self.hosts['mux'])
        data = {'config':
                    {'server-addr': self.hosts[self.dcae_ves_collector_name],
                     'server-port': '30235' if self.oom_mode else '8081',
                     'read-interval': '10',
                     'is-add':'1'
                     }
                }
        r = requests.post(url, headers=self.vpp_api_headers, auth=self.vpp_api_userpass, json=data)
        self.logger.debug('%s', r)

    def set_vgmux_packet_loss_rate(self, lossrate, vg_vnf_instance_name):
        url = self.vpp_ves_url.format(self.hosts['mux'])
        data = {"mode":
                    {"working-mode": "demo",
                     "base-packet-loss": str(lossrate),
                     "source-name": vg_vnf_instance_name
                     }
                }
        r = requests.post(url, headers=self.vpp_api_headers, auth=self.vpp_api_userpass, json=data)
        self.logger.debug('%s', r)

        # return all the VxLAN interface names of BRG or vGMUX based on the IP address
    def get_vxlan_interfaces(self, ip, print_info=False):
        url = self.vpp_inf_url.format(ip)
        self.logger.debug('url is this: %s', url)
        r = requests.get(url, headers=self.vpp_api_headers, auth=self.vpp_api_userpass)
        data = r.json()['interfaces']['interface']
        if print_info:
            for inf in data:
                if 'name' in inf and 'type' in inf and inf['type'] == 'v3po:vxlan-tunnel':
                    print(json.dumps(inf, indent=4, sort_keys=True))

        return [inf['name'] for inf in data if 'name' in inf and 'type' in inf and inf['type'] == 'v3po:vxlan-tunnel']

    # delete all VxLAN interfaces of each hosts
    def delete_vxlan_interfaces(self, host_dic):
        for host, ip in host_dic.items():
            deleted = False
            self.logger.info('{0}: Getting VxLAN interfaces'.format(host))
            inf_list = self.get_vxlan_interfaces(ip)
            for inf in inf_list:
                deleted = True
                time.sleep(2)
                self.logger.info("{0}: Deleting VxLAN crossconnect {1}".format(host, inf))
                url = self.vpp_inf_url.format(ip) + '/interface/' + inf + '/v3po:l2'
                requests.delete(url, headers=self.vpp_api_headers, auth=self.vpp_api_userpass)

            for inf in inf_list:
                deleted = True
                time.sleep(2)
                self.logger.info("{0}: Deleting VxLAN interface {1}".format(host, inf))
                url = self.vpp_inf_url.format(ip) + '/interface/' + inf
                requests.delete(url, headers=self.vpp_api_headers, auth=self.vpp_api_userpass)

            if len(self.get_vxlan_interfaces(ip)) > 0:
                self.logger.error("Error deleting VxLAN from {0}, try to restart the VM, IP is {1}.".format(host, ip))
                return False

            if not deleted:
                self.logger.info("{0}: no VxLAN interface found, nothing to delete".format(host))
        return True

    @staticmethod
    def save_object(obj, filepathname):
        with open(filepathname, 'wb') as fout:
            pickle.dump(obj, fout)

    @staticmethod
    def load_object(filepathname):
        with open(filepathname, 'rb') as fin:
            return pickle.load(fin)

    @staticmethod
    def increase_ip_address_or_vni_in_template(vnf_template_file, vnf_parameter_name_list):
        with open(vnf_template_file) as json_input:
            json_data = json.load(json_input)
            param_list = json_data['VNF-API:input']['VNF-API:vnf-topology-information']['VNF-API:vnf-parameters']
            for param in param_list:
                if param['vnf-parameter-name'] in vnf_parameter_name_list:
                    ipaddr_or_vni = param['vnf-parameter-value'].split('.')
                    number = int(ipaddr_or_vni[-1])
                    if 254 == number:
                        number = 10
                    else:
                        number = number + 1
                    ipaddr_or_vni[-1] = str(number)
                    param['vnf-parameter-value'] = '.'.join(ipaddr_or_vni)

        assert json_data is not None
        with open(vnf_template_file, 'w') as json_output:
            json.dump(json_data, json_output, indent=4, sort_keys=True)

    def save_preload_data(self, preload_data):
        self.save_object(preload_data, self.preload_dict_file)

    def load_preload_data(self):
        return self.load_object(self.preload_dict_file)

    def save_vgmux_vnf_name(self, vgmux_vnf_name):
        self.save_object(vgmux_vnf_name, self.vgmux_vnf_name_file)

    def load_vgmux_vnf_name(self):
        return self.load_object(self.vgmux_vnf_name_file)

