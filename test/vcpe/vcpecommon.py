#!/usr/bin/env python

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
import yaml
from novaclient import client as openstackclient
from openstack.config import loader
from kubernetes import client, config
from netaddr import IPAddress, IPNetwork

class VcpeCommon:

    def __init__(self, extra_host_names=None, cfg_file=None):
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging.DEBUG)
        self.logger.info('Initializing configuration')
        self.default_config = 'vcpeconfig.yaml'

        # Read configuration from config file
        self._load_config(cfg_file)
        # Load OpenStack settings
        self._load_os_config()

        self.sdnc_controller_pod = '-'.join([self.onap_environment, 'sdnc-sdnc-0'])
        # OOM: this is the address that the brg and bng will nat for sdnc access - 10.0.0.x address of k8 host for sdnc-0 container
        self.sdnc_oam_ip = self.get_pod_node_oam_ip(self.sdnc_controller_pod)
        # OOM: this is a k8s host external IP, e.g. oom-k8s-01 IP
        self.oom_so_sdnc_aai_ip = self.get_pod_node_public_ip(self.sdnc_controller_pod)
        # OOM: this is a k8s host external IP, e.g. oom-k8s-01 IP
        self.oom_dcae_ves_collector = self.oom_so_sdnc_aai_ip
        # OOM: this is a k8s host external IP, e.g. oom-k8s-01 IP
        self.mr_ip_addr = self.oom_so_sdnc_aai_ip
        self.mr_ip_port = '30227'
        self.so_nbi_port = '30277' if self.oom_mode else '8080'
        self.sdnc_preloading_port = '30267' if self.oom_mode else '8282'
        self.aai_query_port = '30233' if self.oom_mode else '8443'
        self.sniro_port = '30288' if self.oom_mode else '8080'

        self.host_names = ['sdc', 'so', 'sdnc', 'robot', 'aai-inst1', self.dcae_ves_collector_name, 'mariadb-galera']
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
        self.sdc_be_port = '30204'
        self.sdc_be_request_userpass = 'vid', 'Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U'
        self.sdc_be_request_headers = {'X-ECOMP-InstanceID': 'VID'}
        self.sdc_be_url_prefix = 'https://' + self.hosts['sdc'] + ':' + self.sdc_be_port
        self.sdc_service_list_url = self.sdc_be_url_prefix + '/sdc/v1/catalog/services'

        self.sdc_fe_port = '30207'
        self.sdc_fe_request_userpass = 'beep', 'boop'
        self.sdc_fe_request_headers = {'USER_ID': 'demo', 'Content-Type': 'application/json'}
        self.sdc_fe_url_prefix = 'https://' + self.hosts['sdc'] + ':' + self.sdc_fe_port
        self.sdc_get_category_list_url = self.sdc_fe_url_prefix + '/sdc1/feProxy/rest/v1/categories'
        self.sdc_create_allotted_resource_subcategory_url = self.sdc_fe_url_prefix + '/sdc1/feProxy/rest/v1/category/resources/resourceNewCategory.allotted%20resource/subCategory'

        #############################################################################################
        # SDNC urls
        self.sdnc_userpass = 'admin', 'Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U'
        self.sdnc_db_name = 'sdnctl'
        self.sdnc_db_user = 'sdnctl'
        self.sdnc_db_pass = 'gamma'
        self.sdnc_db_port = self.get_k8s_service_endpoint_info('mariadb-galera','port') if self.oom_mode else '3306'
        self.sdnc_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.sdnc_preload_network_url = 'https://' + self.hosts['sdnc'] + \
                                        ':' + self.sdnc_preloading_port + '/restconf/operations/VNF-API:preload-network-topology-operation'
        self.sdnc_preload_network_gra_url = 'https://' + self.hosts['sdnc'] + \
                                        ':' + self.sdnc_preloading_port + '/restconf/operations/GENERIC-RESOURCE-API:preload-network-topology-operation'
        self.sdnc_preload_vnf_url = 'https://' + self.hosts['sdnc'] + \
                                    ':' + self.sdnc_preloading_port + '/restconf/operations/VNF-API:preload-vnf-topology-operation'
        self.sdnc_preload_gra_url = 'https://' + self.hosts['sdnc'] + \
                                    ':' + self.sdnc_preloading_port + '/restconf/operations/GENERIC-RESOURCE-API:preload-vf-module-topology-operation'
        self.sdnc_ar_cleanup_url = 'https://' + self.hosts['sdnc'] + ':' + self.sdnc_preloading_port + \
                                   '/restconf/config/GENERIC-RESOURCE-API:'

        #############################################################################################
        # MARIADB-GALERA settings
        self.mariadb_galera_endpoint_ip = self.get_k8s_service_endpoint_info('mariadb-galera','ip')
        self.mariadb_galera_endpoint_port = self.get_k8s_service_endpoint_info('mariadb-galera','port')

        #############################################################################################
        # SO urls, note: do NOT add a '/' at the end of the url
        self.so_req_api_url = {'v4': 'http://' + self.hosts['so'] + ':' + self.so_nbi_port + '/onap/so/infra/serviceInstantiation/v7/serviceInstances',
                           'v5': 'http://' + self.hosts['so'] + ':' + self.so_nbi_port + '/onap/so/infra/serviceInstantiation/v7/serviceInstances'}
        self.so_check_progress_api_url = 'http://' + self.hosts['so'] + ':' + self.so_nbi_port + '/onap/so/infra/orchestrationRequests/v6'
        self.so_userpass = 'InfraPortalClient', 'password1$'
        self.so_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.so_db_name = 'catalogdb'
        self.so_db_user = 'root'
        self.so_db_pass = 'secretpassword'
        self.so_db_host = self.mariadb_galera_endpoint_ip if self.oom_mode else self.hosts['so']
        self.so_db_port = self.mariadb_galera_endpoint_port if self.oom_mode else '3306'

        self.vpp_inf_url = 'http://{0}:8183/restconf/config/ietf-interfaces:interfaces'
        self.vpp_api_headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        self.vpp_api_userpass = ('admin', 'admin')
        self.vpp_ves_url= 'http://{0}:8183/restconf/config/vesagent:vesagent'

        #############################################################################################
        # POLICY urls
        self.policy_userpass = ('healthcheck', 'zb!XztG34')
        self.policy_headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
        self.policy_api_url = 'https://{0}:6969/policy/api/v1/policytypes/onap.policies.controlloop.Operational/versions/1.0.0/policies'
        self.policy_pap_get_url = 'https://{0}:6969/policy/pap/v1/pdps'
        self.policy_pap_json = {'policies': [{'policy-id': 'operational.vcpe'}]}
        self.policy_pap_post_url = self.policy_pap_get_url + '/policies'
        self.policy_api_service_name = 'policy-api'
        self.policy_pap_service_name = 'policy-pap'

        #############################################################################################
        # AAI urls
        self.aai_region_query_url = 'https://' + self.oom_so_sdnc_aai_ip + ':' +\
                                    self.aai_query_port +\
                                    '/aai/v14/cloud-infrastructure/cloud-regions/cloud-region/CloudOwner/' +\
                                    self.cloud['--os-region-name']
        self.aai_headers = {'Accept': 'application/json',
                            'Content-Type': 'application/json',
                            'X-FromAppId': 'postman', 'X-TransactionId': '9999'}

    def _load_config(self, cfg_file):
        """
        Reads vcpe config file and injects settings as object's attributes
        :param cfg_file: Configuration file path
        """

        if cfg_file is None:
            cfg_file = self.default_config

        try:
            with open(cfg_file, 'r') as cfg:
                cfg_yml = yaml.full_load(cfg)
        except Exception as e:
            self.logger.error('Error loading configuration: ' + str(e))
            sys.exit(1)

        self.logger.debug('\n' + yaml.dump(cfg_yml))

        # Use setattr to load config file keys as VcpeCommon class' object
        # attributes
        try:
            # Check config isn't empty
            if cfg_yml is not None:
                for cfg_key in cfg_yml:
                    setattr(self, cfg_key, cfg_yml[cfg_key])
        except TypeError as e:
            self.logger.error('Unable to parse config file: ' + str(e))
            sys.exit(1)

    def _load_os_config(self):
        """
        Reads cloud settings and sets them as object's 'cloud' attribute
        """
        # Create OpenStackConfig config instance
        os_config = loader.OpenStackConfig()
        # Try reading cloud settings for self.cloud_name
        try:
            os_cloud = os_config.cloud_config['clouds'][self.cloud_name]
        except KeyError:
            self.logger.error('Error fetching cloud settings for cloud "{0}"'
                              .format(self.cloud_name))
            sys.exit(1)
        self.logger.debug('Cloud config:\n {0}'.format(json.dumps(
                          os_cloud,indent=4)))

        # Extract all OS settings keys and alter their names
        # to conform to openstack cli client
        self.cloud = {}
        for k in os_cloud:
            if isinstance(os_cloud[k],dict):
                for sub_k in os_cloud[k]:
                    os_setting_name = '--os-' + sub_k.replace('_','-')
                    self.cloud[os_setting_name] = os_cloud[k][sub_k]
            else:
                os_setting_name = '--os-' + k.replace('_','-')
                self.cloud[os_setting_name] = os_cloud[k]

    def heatbridge(self, openstack_stack_name, svc_instance_uuid):
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
        if self.oom_mode:
            db_host=self.mariadb_galera_endpoint_ip
        else:
            db_host=self.hosts['mariadb-galera']

        cnx = mysql.connector.connect(user=self.sdnc_db_user,
                                      password=self.sdnc_db_pass,
                                      database=self.sdnc_db_name,
                                      host=db_host,
                                      port=self.sdnc_db_port)
        cursor = cnx.cursor()
        query = "SELECT * from DHCP_MAP"
        cursor.execute(query)

        self.logger.debug('DHCP_MAP table in SDNC')
        mac_recent = None
        host = -1
        for mac, ip in cursor:
            self.logger.debug(mac + ' - ' + ip)
            this_host = int(ip.split('.')[-1])
            if host < this_host:
                host = this_host
                mac_recent = mac

        cnx.close()

        try:
            assert mac_recent
        except AssertionError:
            self.logger.error('Failed to obtain BRG MAC address from database')
            sys.exit(1)

        return mac_recent

    def execute_cmds_mariadb(self, cmds):
        self.execute_cmds_db(cmds, self.sdnc_db_user, self.sdnc_db_pass,
                             self.sdnc_db_name, self.mariadb_galera_endpoint_ip,
                             self.mariadb_galera_endpoint_port)

    def execute_cmds_sdnc_db(self, cmds):
        self.execute_cmds_db(cmds, self.sdnc_db_user, self.sdnc_db_pass, self.sdnc_db_name,
                             self.hosts['sdnc'], self.sdnc_db_port)

    def execute_cmds_so_db(self, cmds):
        self.execute_cmds_db(cmds, self.so_db_user, self.so_db_pass, self.so_db_name,
                             self.so_db_host, self.so_db_port)

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
                    sys.exit(1)
                filenamepath = os.path.abspath(os.path.join(search_dir, file_name))

        if filenamepath:
            return filenamepath
        else:
            self.logger.error("Cannot find *{0}*{1} in directory {2}".format(file_name_keyword, file_ext, search_dir))
            sys.exit(1)

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

    def set_closed_loop_policy(self, policy_template_file):
        # Gather policy services cluster ips
        p_api_cluster_ip = self.get_k8s_service_cluster_ip(self.policy_api_service_name)
        p_pap_cluster_ip = self.get_k8s_service_cluster_ip(self.policy_pap_service_name)

        # Read policy json from file
        with open(policy_template_file) as f:
            try:
                policy_json = json.load(f)
            except ValueError:
                self.logger.error(policy_template_file + " doesn't seem to contain valid JSON data")
                sys.exit(1)

        # Check policy already applied
        policy_exists_req = requests.get(self.policy_pap_get_url.format(
                            p_pap_cluster_ip), auth=self.policy_userpass,
                            verify=False, headers=self.policy_headers)
        if policy_exists_req.status_code != 200:
            self.logger.error('Failure in checking CL policy existence. '
                               'Policy-pap responded with HTTP code {0}'.format(
                               policy_exists_req.status_code))
            sys.exit(1)

        try:
            policy_exists_json = policy_exists_req.json()
        except ValueError as e:
            self.logger.error('Policy-pap request failed: ' + e.message)
            sys.exit(1)

        try:
            assert policy_exists_json['groups'][0]['pdpSubgroups'] \
                               [1]['policies'][0]['name'] != 'operational.vcpe'
        except AssertionError:
            self.logger.info('vCPE closed loop policy already exists, not applying')
            return
        except IndexError:
            pass # policy doesn't exist

        # Create policy
        policy_create_req = requests.post(self.policy_api_url.format(
                            p_api_cluster_ip), auth=self.policy_userpass,
                            json=policy_json, verify=False,
                            headers=self.policy_headers)
        # Get the policy id from policy-api response
        if policy_create_req.status_code != 200:
            self.logger.error('Failed creating policy. Policy-api responded'
                              ' with HTTP code {0}'.format(policy_create_req.status_code))
            sys.exit(1)

        try:
            policy_version = json.loads(policy_create_req.text)['policy-version']
        except (KeyError, ValueError):
            self.logger.error('Policy API response not understood:')
            self.logger.debug('\n' + str(policy_create_req.text))

        # Inject the policy into Policy PAP
        self.policy_pap_json['policies'].append({'policy-version': policy_version})
        policy_insert_req = requests.post(self.policy_pap_post_url.format(
                            p_pap_cluster_ip), auth=self.policy_userpass,
                            json=self.policy_pap_json, verify=False,
                            headers=self.policy_headers)
        if policy_insert_req.status_code != 200:
            self.logger.error('Policy PAP request failed with HTTP code'
                              '{0}'.format(policy_insert_req.status_code))
            sys.exit(1)
        self.logger.info('Successully pushed closed loop Policy')

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
            sys.exit(1)

        url = 'https://{0}:{1}/aai/v11/search/nodes-query?search-node-type={2}&filter={3}:EQUALS:{4}'.format(
            self.hosts['aai-inst1'], self.aai_query_port, search_node_type, key, node_uuid)

        headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'X-FromAppID': 'vCPE-Robot', 'X-TransactionId': 'get_aai_subscr'}
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
        network = ipaddress.ip_network(unicode('{0}/{1}'.format(net_addr, net_addr_len)), strict=False) # pylint: disable=E0602
        ip_list = re.findall(r'[0-9]+(?:\.[0-9]+){3}', sz)
        for ip in ip_list:
            this_net = ipaddress.ip_network(unicode('{0}/{1}'.format(ip, net_addr_len)), strict=False) # pylint: disable=E0602
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
            ret = raw_input("Enter " + self.sdnc_controller_pod + " pod cluster node OAM IP address(10.0.0.0/16): ") # pylint: disable=E0602
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
            ret = raw_input("Enter " + self.sdnc_controller_pod + " pod cluster node public IP address(i.e. " + self.external_net_addr + "): ") # pylint: disable=E0602
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
                for k, v in i.networks.items(): # pylint: disable=W0612
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
#            sys.exit(1)
        return ip_dict

    def get_oom_onap_vm_ip(self, keywords):
        vm_ip = {}
        for vm in keywords:
            if vm in self.host_names:
                vm_ip[vm] = self.oom_so_sdnc_aai_ip
        return vm_ip

    def get_k8s_service_cluster_ip(self, service):
        """
        Returns cluster IP for a given service
        :param service: name of the service
        :return: cluster ip
        """
        config.load_kube_config()
        api = client.CoreV1Api()
        kslogger = logging.getLogger('kubernetes')
        kslogger.setLevel(logging.INFO)
        try:
            resp = api.read_namespaced_service(service, self.onap_namespace)
        except client.rest.ApiException as e:
            self.logger.error('Error while making k8s API request: ' + e.body)
            sys.exit(1)

        return resp.spec.cluster_ip

    def get_k8s_service_endpoint_info(self, service, subset):
        """
        Returns endpoint data for a given service and subset. If there
        is more than one endpoint returns data for the first one from
        the list that API returned.
        :param service: name of the service
        :param subset: subset name, one of "ip","port"
        :return: endpoint ip
        """
        config.load_kube_config()
        api = client.CoreV1Api()
        kslogger = logging.getLogger('kubernetes')
        kslogger.setLevel(logging.INFO)
        try:
            resp = api.read_namespaced_endpoints(service, self.onap_namespace)
        except client.rest.ApiException as e:
            self.logger.error('Error while making k8s API request: ' + e.body)
            sys.exit(1)

        if subset == "ip":
            return resp.subsets[0].addresses[0].ip
        elif subset == "port":
            return resp.subsets[0].ports[0].port
        else:
            self.logger.error("Unsupported subset type")

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

            if self.get_vxlan_interfaces(ip):
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
