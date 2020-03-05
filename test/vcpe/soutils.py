#!/usr/bin/env python

import sys
import logging
import requests
import json
from datetime import datetime
import progressbar
import time
import csar_parser
import preload
from vcpecommon import *


class SoUtils:
    def __init__(self, vcpecommon, api_version):
        """
        :param vcpecommon:
        :param api_version: must be 'v4' or 'v5'
        """
        self.tmp_solution_for_so_bug = False
        self.logger = logging.getLogger(__name__)
        self.vcpecommon = vcpecommon
        if api_version not in self.vcpecommon.so_req_api_url:
            self.logger.error('Incorrect SO API version: %s', api_version)
            sys.exit(1)
        self.service_req_api_url = self.vcpecommon.so_req_api_url[api_version]
        self.testApi = 'VNF_API'

    def submit_create_req(self, req_json, req_type, service_instance_id=None, vnf_instance_id=None):
        """
        POST	{serverRoot}/serviceInstances/v4
        POST	{serverRoot}/serviceInstances/v4/{serviceInstanceId}/vnfs
        POST	{serverRoot}/serviceInstances/v4/{serviceInstanceId}/networks
        POST	{serverRoot}/serviceInstances/v4/{serviceInstanceId}/vnfs/{vnfInstanceId}/vfModules
        :param req_json:
        :param service_instance_id:  this is required only for networks, vnfs, and vf modules
        :param req_type:
        :param vnf_instance_id:
        :return: req_id, instance_id
        """
        if req_type == 'service':
            url = self.service_req_api_url
        elif req_type == 'vnf':
            url = '/'.join([self.service_req_api_url, service_instance_id, 'vnfs'])
        elif req_type == 'network':
            url = '/'.join([self.service_req_api_url, service_instance_id, 'networks'])
        elif req_type == 'vfmodule':
            url = '/'.join([self.service_req_api_url, service_instance_id, 'vnfs', vnf_instance_id, 'vfModules'])
        else:
            self.logger.error('Invalid request type: {0}. Can only be service/vnf/network/vfmodule'.format(req_type))
            return None, None

        self.logger.info(url)
        r = requests.post(url, headers=self.vcpecommon.so_headers, auth=self.vcpecommon.so_userpass, json=req_json)
        self.logger.debug(r)
        response = r.json()

        self.logger.debug('---------------------------------------------------------------')
        self.logger.debug('------- Creation request submitted to SO, got response --------')
        self.logger.debug(json.dumps(response, indent=4, sort_keys=True))
        self.logger.debug('---------------------------------------------------------------')
        req_id = response.get('requestReferences', {}).get('requestId', '')
        instance_id = response.get('requestReferences', {}).get('instanceId', '')

        return req_id, instance_id

    def check_progress(self, req_id, eta=0, interval=5):
        if not req_id:
            self.logger.error('Error when checking SO request progress, invalid request ID: ' + req_id)
            return False
        duration = 0.0
        bar = progressbar.ProgressBar(redirect_stdout=True)
        url = self.vcpecommon.so_check_progress_api_url + '/' + req_id

        while True:
            time.sleep(interval)
            r = requests.get(url, headers=self.vcpecommon.so_headers, auth=self.vcpecommon.so_userpass)
            response = r.json()

            duration += interval
            if eta > 0:
                percentage = min(95, 100 * duration / eta)
            else:
                percentage = int(response['request']['requestStatus']['percentProgress'])

            if response['request']['requestStatus']['requestState'] == 'IN_PROGRESS':
                self.logger.debug('------------------Request Status-------------------------------')
                self.logger.debug(json.dumps(response, indent=4, sort_keys=True))
                bar.update(percentage)
            else:
                self.logger.debug('---------------------------------------------------------------')
                self.logger.debug('----------------- Creation Request Results --------------------')
                self.logger.debug(json.dumps(response, indent=4, sort_keys=True))
                self.logger.debug('---------------------------------------------------------------')
                flag = response['request']['requestStatus']['requestState'] == 'COMPLETE'
                if not flag:
                    self.logger.error('Request failed.')
                    self.logger.error(json.dumps(response, indent=4, sort_keys=True))
                bar.update(100)
                bar.finish()
                return flag

    def add_req_info(self, req_details, instance_name, product_family_id=None):
        req_details['requestInfo'] = {
                    'instanceName': instance_name,
                    'source': 'VID',
                    'suppressRollback': 'true',
                    'requestorId': 'vCPE-Robot'
        }
        if product_family_id:
            req_details['requestInfo']['productFamilyId'] = product_family_id

    def add_related_instance(self, req_details, instance_id, instance_model):
        instance = {"instanceId": instance_id, "modelInfo": instance_model}
        if 'relatedInstanceList' not in req_details:
            req_details['relatedInstanceList'] = [{"relatedInstance": instance}]
        else:
            req_details['relatedInstanceList'].append({"relatedInstance": instance})

    def generate_vnf_or_network_request(self, req_type, instance_name, vnf_or_network_model, service_instance_id,
                                        service_model):
        if self.vcpecommon.gra_api_flag:
            self.testApi = 'GR_API'
        req_details = {
            'modelInfo':  vnf_or_network_model,
            'cloudConfiguration': {"lcpCloudRegionId": self.vcpecommon.os_region_name,
                                   "tenantId": self.vcpecommon.os_tenant_id},
            'requestParameters':  {
                "userParams": [],
                "testApi": self.testApi
                },
            'platform': {"platformName": "Platform-Demonstration"}
        }
        self.add_req_info(req_details, instance_name, self.vcpecommon.product_family_id)
        self.add_related_instance(req_details, service_instance_id, service_model)
        return {'requestDetails': req_details}

    def generate_vfmodule_request(self, instance_name, vfmodule_model, service_instance_id,
                                        service_model, vnf_instance_id, vnf_model):
        if self.vcpecommon.gra_api_flag:
            self.testApi = 'GR_API'
        req_details = {
            'modelInfo':  vfmodule_model,
            'cloudConfiguration': {"lcpCloudRegionId": self.vcpecommon.os_region_name,
                                   "tenantId": self.vcpecommon.os_tenant_id},
            'requestParameters': {
                "usePreload": 'true',
                "testApi": self.testApi
                }
        }
        self.add_req_info(req_details, instance_name, self.vcpecommon.product_family_id)
        self.add_related_instance(req_details, service_instance_id, service_model)
        self.add_related_instance(req_details, vnf_instance_id, vnf_model)
        return {'requestDetails': req_details}

    def generate_service_request(self, instance_name, model):
        if self.vcpecommon.gra_api_flag:
		self.testApi = 'GR_API'

        self.logger.info('testApi' + self.testApi)

        req_details = {
            'modelInfo':  model,
            'subscriberInfo':  {'globalSubscriberId': self.vcpecommon.global_subscriber_id},
            'requestParameters': {
                "userParams": [],
                "subscriptionServiceType": "vCPE",
                "aLaCarte": 'true',
                "testApi": self.testApi
            }
        }
        self.add_req_info(req_details, instance_name)
        self.add_project_info(req_details)
        self.add_owning_entity(req_details)
        self.logger.info(json.dumps(req_details, indent=2, sort_keys=True))
        return {'requestDetails': req_details}

    def add_project_info(self, req_details):
        req_details['project'] = {'projectName': self.vcpecommon.project_name}

    def add_owning_entity(self, req_details):
        req_details['owningEntity'] = {'owningEntityId': self.vcpecommon.owning_entity_id,
                                       'owningEntityName': self.vcpecommon.owning_entity_name}

    def generate_custom_service_request(self, instance_name, svc_model,
                                        vfmodule_models, brg_mac):
        brg_mac_enc = brg_mac.replace(':', '-')
        req_details = {
            'modelInfo':  svc_model,
            'subscriberInfo':  {'subscriberName': 'Kaneohe',
                                'globalSubscriberId': self.vcpecommon.global_subscriber_id},
            'cloudConfiguration': {"lcpCloudRegionId": 'RegionOne', #self.vcpecommon.os_region_name,
                                   "tenantId": self.vcpecommon.os_tenant_id},
            'requestParameters': {
                "userParams": [
                    {
                        'name': 'BRG_WAN_MAC_Address',
                        'value': brg_mac
                    },
                    {
                       'name': 'VfModuleNames',
                       'value': [
                            {
                                'VfModuleModelInvariantUuid': vfmodule_models[0]['modelInvariantId'],
                                'VfModuleName': 'VGW2BRG-{0}'.format(brg_mac_enc)
                            }
                       ]
                    },
                    {
                         "name": "Customer_Location",
                         "value": self.vcpecommon.customer_location_used_by_oof
                    },
                    {
                         "name": "Homing_Solution",
                         "value": self.vcpecommon.homing_solution
                    }
                ],
                "subscriptionServiceType": "vCPE",
                'aLaCarte': 'false'
            }
        }
        self.add_req_info(req_details, instance_name, self.vcpecommon.custom_product_family_id)
        self.add_project_info(req_details)
        self.add_owning_entity(req_details)
        return {'requestDetails': req_details}

    def create_custom_service(self, csar_file, brg_mac, name_suffix=None):
        parser = csar_parser.CsarParser()
        if not parser.parse_csar(csar_file):
            return False

        # yyyymmdd_hhmm
        if not name_suffix:
            name_suffix = '_' + datetime.now().strftime('%Y%m%d%H%M')

        # create service
        instance_name = '_'.join([self.vcpecommon.instance_name_prefix['service'],
                                  parser.svc_model['modelName'][0:10], name_suffix])
        instance_name = instance_name.lower()
        req = self.generate_custom_service_request(instance_name, parser.svc_model,
                                                   parser.vfmodule_models, brg_mac)
        self.logger.info(json.dumps(req, indent=2, sort_keys=True))
        self.logger.info('Creating custom service {0}.'.format(instance_name))
        req_id, svc_instance_id = self.submit_create_req(req, 'service')
        if not self.check_progress(req_id, 140):
            return False
        return True

    def wait_for_aai(self, node_type, uuid):
        self.logger.info('Waiting for AAI traversal to complete...')
        bar = progressbar.ProgressBar()
        for i in range(30):
            time.sleep(1)
            bar.update(i*100.0/30)
            if self.vcpecommon.is_node_in_aai(node_type, uuid):
                bar.update(100)
                bar.finish()
                return

        self.logger.error("AAI traversal didn't finish in 30 seconds. Something is wrong. Type {0}, UUID {1}".format(
            node_type, uuid))
        sys.exit(1)

    def create_entire_service(self, csar_file, vnf_template_file, preload_dict, name_suffix, heatbridge=False):
        """
        :param csar_file:
        :param vnf_template_file:
        :param preload_dict:
        :param name_suffix:
        :return:  service instance UUID
        """
        self.logger.info('\n----------------------------------------------------------------------------------')
        self.logger.info('Start to create entire service defined in csar: {0}'.format(csar_file))
        parser = csar_parser.CsarParser()
        self.logger.info('Parsing csar ...')
        if not parser.parse_csar(csar_file):
            self.logger.error('Cannot parse csar: {0}'.format(csar_file))
            return None

        # create service
        instance_name = '_'.join([self.vcpecommon.instance_name_prefix['service'],
                                  parser.svc_model['modelName'], name_suffix])
        instance_name = instance_name.lower()
        self.logger.info('Creating service instance: {0}.'.format(instance_name))
        req = self.generate_service_request(instance_name, parser.svc_model)
        self.logger.debug(json.dumps(req, indent=2, sort_keys=True))
        req_id, svc_instance_id = self.submit_create_req(req, 'service')
        if not self.check_progress(req_id, eta=2, interval=1):
            return None

        # wait for AAI to complete traversal
        self.wait_for_aai('service', svc_instance_id)

        # create networks
        for model in parser.net_models:
            base_name = model['modelCustomizationName'].lower().replace('mux_vg', 'mux_gw')
            network_name = '_'.join([self.vcpecommon.instance_name_prefix['network'], base_name, name_suffix])
            network_name = network_name.lower()
            self.logger.info('Creating network: ' + network_name)
            req = self.generate_vnf_or_network_request('network', network_name, model, svc_instance_id,
                                                       parser.svc_model)
            self.logger.debug(json.dumps(req, indent=2, sort_keys=True))
            req_id, net_instance_id = self.submit_create_req(req, 'network', svc_instance_id)
            if not self.check_progress(req_id, eta=20):
                return None

            self.logger.info('Changing subnet name to ' + self.vcpecommon.network_name_to_subnet_name(network_name))
            self.vcpecommon.set_network_name(network_name)
            subnet_name_changed = False
            for i in range(20):
                time.sleep(3)
                if self.vcpecommon.set_subnet_name(network_name):
                    subnet_name_changed = True
                    break

            if not subnet_name_changed:
                self.logger.error('Failed to change subnet name for ' + network_name)
                return None


        vnf_model = None
        vnf_instance_id = None
        # create VNF
        if len(parser.vnf_models) == 1:
            vnf_model = parser.vnf_models[0]
            vnf_instance_name = '_'.join([self.vcpecommon.instance_name_prefix['vnf'],
                                          vnf_model['modelCustomizationName'].split(' ')[0], name_suffix])
            vnf_instance_name = vnf_instance_name.lower()
            self.logger.info('Creating VNF: ' + vnf_instance_name)
            req = self.generate_vnf_or_network_request('vnf', vnf_instance_name, vnf_model, svc_instance_id,
                                                       parser.svc_model)
            self.logger.debug(json.dumps(req, indent=2, sort_keys=True))
            req_id, vnf_instance_id = self.submit_create_req(req, 'vnf', svc_instance_id)
            if not self.check_progress(req_id, eta=2, interval=1):
                self.logger.error('Failed to create VNF {0}.'.format(vnf_instance_name))
                return False

            # wait for AAI to complete traversal
            if not vnf_instance_id:
                self.logger.error('No VNF instance ID returned!')
                sys.exit(1)
            self.wait_for_aai('vnf', vnf_instance_id)

        preloader = preload.Preload(self.vcpecommon)
        if self.vcpecommon.gra_api_flag:
                preloader.preload_vfmodule(vnf_template_file, svc_instance_id, parser.vnf_models[0], parser.vfmodule_models[0],
                                   preload_dict, name_suffix, True)
        else:
                preloader.preload_vfmodule(vnf_template_file, svc_instance_id, parser.vnf_models[0], parser.vfmodule_models[0],
                                   preload_dict, name_suffix, False)
        # create VF Module
        if len(parser.vfmodule_models) == 1:
            if not vnf_instance_id or not vnf_model:
                self.logger.error('Invalid VNF instance ID or VNF model!')
                sys.exit(1)

            model = parser.vfmodule_models[0]
            vfmodule_instance_name = '_'.join([self.vcpecommon.instance_name_prefix['vfmodule'],
                                               model['modelCustomizationName'].split('..')[0], name_suffix])
            vfmodule_instance_name = vfmodule_instance_name.lower()
            self.logger.info('Creating VF Module: ' + vfmodule_instance_name)
            req = self.generate_vfmodule_request(vfmodule_instance_name, model, svc_instance_id, parser.svc_model,
                                                 vnf_instance_id, vnf_model)
            self.logger.debug(json.dumps(req, indent=2, sort_keys=True))
            req_id, vfmodule_instance_id = self.submit_create_req(req, 'vfmodule', svc_instance_id, vnf_instance_id)
            if not self.check_progress(req_id, eta=70, interval=50):
                self.logger.error('Failed to create VF Module {0}.'.format(vfmodule_instance_name))
                return None

        # run heatbridge
        if heatbridge:
            self.vcpecommon.heatbridge(vfmodule_instance_name, svc_instance_id)
            self.vcpecommon.save_vgmux_vnf_name(vnf_instance_name)

        return svc_instance_id
