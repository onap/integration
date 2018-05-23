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


class VcpeCommon:
    #############################################################################################
    #     Start: configurations that you must change for a new ONAP installation
    external_net_addr = '10.12.0.0'
    external_net_prefix_len = 16
    #############################################################################################
    # set the openstack cloud access credentials here
    cloud = {
        '--os-auth-url': 'http://10.12.25.2:5000',
        '--os-username': 'kxi',
        '--os-user-domain-id': 'default',
        '--os-project-domain-id': 'default',
        '--os-tenant-id': '1e097c6713e74fd7ac8e4295e605ee1e',
        '--os-region-name': 'RegionOne',
        '--os-password': 'n3JhGMGuDzD8',
        '--os-project-domain-name': 'Integration-SB-07',
        '--os-identity-api-version': '3'
    }

    common_preload_config = {
        'oam_onap_net': 'oam_onap_lAky',
        'oam_onap_subnet': 'oam_onap_lAky',
        'public_net': 'external',
        'public_net_id': '971040b2-7059-49dc-b220-4fab50cb2ad4'
    }
    #     End: configurations that you must change for a new ONAP installation
    #############################################################################################

    template_variable_symbol = '${'
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
    owning_entity_name = 'OE-Demonstration'

    def __init__(self, extra_host_names=None):
        self.logger = logging.getLogger(__name__)
        self.logger.info('Initializing configuration')

        self.host_names = ['so', 'sdnc', 'robot', 'aai-inst1', self.dcae_ves_collector_name]
        if extra_host_names:
            self.host_names.extend(extra_host_names)
        # get IP addresses
        self.hosts = self.get_vm_ip(self.host_names, self.external_net_addr, self.external_net_prefix_len)
        # this is the keyword used to name vgw stack, must not be used in other stacks
        self.vgw_name_keyword = 'base_vcpe_vgw'
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
        self.sniro_url = 'http://' + self.hosts['robot'] + ':8080/__admin/mappings'
        self.sniro_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.homing_solution = 'sniro'  # value is either 'sniro' or 'oof'
#        self.homing_solution = 'oof'
        self.customer_location_used_by_oof = {
            "customerLatitude": "32.897480",
            "customerLongitude": "-97.040443",
            "customerName": "some_company"
        }

        #############################################################################################
        # SDNC urls
        self.sdnc_userpass = 'admin', 'Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U'
        self.sdnc_db_name = 'sdnctl'
        self.sdnc_db_user = 'sdnctl'
        self.sdnc_db_pass = 'gamma'
        self.sdnc_db_port = '32774'
        self.sdnc_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.sdnc_preload_network_url = 'http://' + self.hosts['sdnc'] + \
                                        ':8282/restconf/operations/VNF-API:preload-network-topology-operation'
        self.sdnc_preload_vnf_url = 'http://' + self.hosts['sdnc'] + \
                                    ':8282/restconf/operations/VNF-API:preload-vnf-topology-operation'
        self.sdnc_ar_cleanup_url = 'http://' + self.hosts['sdnc'] + ':8282/restconf/config/GENERIC-RESOURCE-API:'

        #############################################################################################
        # SO urls, note: do NOT add a '/' at the end of the url
        self.so_req_api_url = {'v4': 'http://' + self.hosts['so'] + ':8080/ecomp/mso/infra/serviceInstances/v4',
                           'v5': 'http://' + self.hosts['so'] + ':8080/ecomp/mso/infra/serviceInstances/v5'}
        self.so_check_progress_api_url = 'http://' + self.hosts['so'] + ':8080/ecomp/mso/infra/orchestrationRequests/v5'
        self.so_userpass = 'InfraPortalClient', 'password1$'
        self.so_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.so_db_name = 'mso_catalog'
        self.so_db_user = 'root'
        self.so_db_pass = 'password'
        self.so_db_port = '32768'

        self.vpp_inf_url = 'http://{0}:8183/restconf/config/ietf-interfaces:interfaces'
        self.vpp_api_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.vpp_api_userpass = ('admin', 'admin')
        self.vpp_ves_url= 'http://{0}:8183/restconf/config/vesagent:vesagent'

    def headbridge(self, openstack_stack_name, svc_instance_uuid):
        """
        Add vserver information to AAI
        """
        self.logger.info('Adding vServer information to AAI for {0}'.format(openstack_stack_name))
        cmd = '/opt/demo.sh heatbridge {0} {1} vCPE'.format(openstack_stack_name, svc_instance_uuid)
        ret = commands.getstatusoutput("ssh -i onap_dev root@{0} '{1}'".format(self.hosts['robot'], cmd))
        self.logger.debug('%s', ret)

    def get_brg_mac_from_sdnc(self):
        """
        :return:  BRG MAC address. Currently we only support one BRG instance.
        """
        cnx = mysql.connector.connect(user=self.sdnc_db_user, password=self.sdnc_db_pass, database=self.sdnc_db_name,
                                      host=self.hosts['sdnc'], port=self.sdnc_db_port)
        cursor = cnx.cursor()
        query = "SELECT * from DHCP_MAP"
        cursor.execute(query)

        self.logger.debug('DHCP_MAP table in SDNC')
        counter = 0
        mac = None
        for mac, ip in cursor:
            counter += 1
            self.logger.debug(mac + ':' + ip)

        cnx.close()

        if counter != 1:
            self.logger.error('Found %s MAC addresses in DHCP_MAP', counter)
            sys.exit()
        else:
            self.logger.debug('Found MAC addresses in DHCP_MAP: %s', mac)
            return mac

    def insert_into_sdnc_db(self, cmds):
        cnx = mysql.connector.connect(user=self.sdnc_db_user, password=self.sdnc_db_pass, database=self.sdnc_db_name,
                                      host=self.hosts['sdnc'], port=self.sdnc_db_port)
        cursor = cnx.cursor()
        for cmd in cmds:
            self.logger.debug(cmd)
            cursor.execute(cmd)
            self.logger.debug('%s', cursor)
        cnx.commit()
        cursor.close()
        cnx.close()

    def insert_into_so_db(self, cmds):
        cnx = mysql.connector.connect(user=self.so_db_user, password=self.so_db_pass, database=self.so_db_name,
                                      host=self.hosts['so'], port=self.so_db_port)
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

        url = 'https://{0}:8443/aai/v11/search/nodes-query?search-node-type={1}&filter={2}:EQUALS:{3}'.format(
            self.hosts['aai-inst1'], search_node_type, key, node_uuid)

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

        ip_dict = {}
        results = os.popen(openstackcmd).read()
        for line in results.split('\n'):
            fields = line.split('|')
            if len(fields) == 8:
                vm_name = fields[2]
                ip_info = fields[-2]
                for keyword in keywords:
                    if keyword in vm_name:
                        ip = self.extract_ip_from_str(net_addr, net_addr_len, ip_info)
                        if ip:
                            ip_dict[keyword] = ip
        if len(ip_dict) != len(keywords):
            self.logger.error('Cannot find all desired IP addresses for %s.', keywords)
            self.logger.error(json.dumps(ip_dict, indent=4, sort_keys=True))
            self.logger.error('Temporarily continue.. remember to check back vcpecommon.py line: 316')
#            sys.exit()
        return ip_dict

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
                     'server-port': '8081',
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

    def save_preload_data(self, preload_data):
        self.save_object(preload_data, self.preload_dict_file)

    def load_preload_data(self):
        return self.load_object(self.preload_dict_file)

    def save_vgmux_vnf_name(self, vgmux_vnf_name):
        self.save_object(vgmux_vnf_name, self.vgmux_vnf_name_file)

    def load_vgmux_vnf_name(self):
        return self.load_object(self.vgmux_vnf_name_file)

