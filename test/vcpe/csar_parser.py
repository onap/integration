#!/usr/bin/env python

import os
import zipfile
import shutil
import yaml
import json
import logging


class CsarParser:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.svc_model = {}
        self.net_models = []  # there could be multiple networks
        self.vnf_models = [] # this version only support a single VNF in the service template
        self.vfmodule_models = [] # this version only support a single VF module in the service template

    def get_service_yaml_from_csar(self, csar_file):
        """
        :param csar_file: csar file path name, e.g. 'csar/vgmux.csar'
        :return:
        """
        tmpdir = './__tmp'
        if os.path.isdir(tmpdir):
            shutil.rmtree(tmpdir)
        os.mkdir(tmpdir)

        with zipfile.ZipFile(csar_file, "r") as zip_ref:
            zip_ref.extractall(tmpdir)

        yamldir = tmpdir + '/Definitions'
        if os.path.isdir(yamldir):
            for filename in os.listdir(yamldir):
                # look for service template like this: service-Vcpesvcbrgemu111601-template.yml
                if filename.startswith('service-') and filename.endswith('-template.yml'):
                    return os.path.join(yamldir, filename)

        self.logger.error('Invalid file: ' + csar_file)
        return ''

    def get_service_model_info(self, svc_template):
        """ extract service model info from yaml and convert to what to be used in SO request
        Sample from yaml:
            {
                "UUID": "aed4fc5e-b871-4e26-8531-ceabd46df85e",
                "category": "Network L1-3",
                "description": "Infra service",
                "ecompGeneratedNaming": true,
                "invariantUUID": "c806682a-5b3a-44d8-9e88-0708be151296",
                "name": "vcpesvcinfra111601",
                "namingPolicy": "",
                "serviceEcompNaming": true,
                "serviceRole": "",
                "serviceType": "",
                "type": "Service"
            },

        Convert to
            {
                 "modelType": "service",
                 "modelInvariantId": "ca4c7a70-06fd-45d8-8b9e-c9745d25bf2b",
                 "modelVersionId": "5d8911b4-e50c-4096-a81e-727a8157193c",
                 "modelName": "vcpesvcbrgemu111601",
                 "modelVersion": "1.0"
             },

        """
        if svc_template['metadata']['type'] != 'Service':
            self.logger.error('csar error: metadata->type is not Service')
            return

        metadata = svc_template['metadata']
        self.svc_model = {
            'modelType': 'service',
            'modelInvariantId': metadata['invariantUUID'],
            'modelVersionId': metadata['UUID'],
            'modelName':  metadata['name']
        }
        if 'version' in metadata:
            self.svc_model['modelVersion'] = metadata['version']
        else:
            self.svc_model['modelVersion'] = '1.0'

    def get_vnf_and_network_model_info(self, svc_template):
        """ extract vnf and network model info from yaml and convert to what to be used in SO request
        Sample from yaml:
        "topology_template": {
            "node_templates": {
                "CPE_PUBLIC": {
                    "metadata": {
                        "UUID": "33b2c367-a165-4bb3-81c3-0150cd06ceff",
                        "category": "Generic",
                        "customizationUUID": "db1d4ac2-62cd-4e5d-b2dc-300dbd1a5da1",
                        "description": "Generic NeutronNet",
                        "invariantUUID": "3d4c0e47-4794-4e98-a794-baaced668930",
                        "name": "Generic NeutronNet",
                        "resourceVendor": "ATT (Tosca)",
                        "resourceVendorModelNumber": "",
                        "resourceVendorRelease": "1.0.0.wd03",
                        "subcategory": "Network Elements",
                        "type": "VL",
                        "version": "1.0"
                    },
                    "type": "org.openecomp.resource.vl.GenericNeutronNet"
                },
        Convert to
            {
                "modelType": "network",
                "modelInvariantId": "3d4c0e47-4794-4e98-a794-baaced668930",
                "modelVersionId": "33b2c367-a165-4bb3-81c3-0150cd06ceff",
                "modelName": "Generic NeutronNet",
                "modelVersion": "1.0",
                "modelCustomizationId": "db1d4ac2-62cd-4e5d-b2dc-300dbd1a5da1",
                "modelCustomizationName": "CPE_PUBLIC"
            },
        """
        node_dic = svc_template['topology_template']['node_templates']
        for node_name, v in node_dic.items():
            model = {
                'modelInvariantId':  v['metadata']['invariantUUID'],
                'modelVersionId': v['metadata']['UUID'],
                'modelName': v['metadata']['name'],
                'modelVersion': v['metadata']['version'],
                'modelCustomizationId': v['metadata']['customizationUUID'],
                'modelCustomizationName': node_name
            }

            if v['type'].startswith('org.openecomp.resource.vl.GenericNeutronNet'):
                # a neutron network is found
                self.logger.info('Parser found a network: ' + node_name)
                model['modelType'] = 'network'
                self.net_models.append(model)
            elif v['type'].startswith('org.openecomp.resource.vf.'):
                # a VNF is found
                self.logger.info('Parser found a VNF: ' + node_name)
                model['modelType'] = 'vnf'
                self.vnf_models.append(model)
            else:
                self.logger.warning('Parser found a node that is neither a network nor a VNF: ' + node_name)

    def get_vfmodule_model_info(self, svc_template):
        """ extract network model info from yaml and convert to what to be used in SO request
        Sample from yaml:
            "topology_template": {
                "groups": {
                    "vspinfra1116010..Vspinfra111601..base_vcpe_infra..module-0": {
                        "metadata": {
                            "vfModuleModelCustomizationUUID": "11ddac51-30e3-4a3f-92eb-2eb99c2cb288",
                            "vfModuleModelInvariantUUID": "02f70416-581e-4f00-bde1-d65e69af95c5",
                            "vfModuleModelName": "Vspinfra111601..base_vcpe_infra..module-0",
                            "vfModuleModelUUID": "88c78078-f1fd-4f73-bdd9-10420b0f6353",
                            "vfModuleModelVersion": "1"
                        },
                        "properties": {
                            "availability_zone_count": null,
                            "initial_count": 1,
                            "max_vf_module_instances": 1,
                            "min_vf_module_instances": 1,
                            "vf_module_description": null,
                            "vf_module_label": "base_vcpe_infra",
                            "vf_module_type": "Base",
                            "vfc_list": null,
                            "volume_group": false
                        },
                        "type": "org.openecomp.groups.VfModule"
                    }
                },
        Convert to
            {
                "modelType": "vfModule",
                "modelInvariantId": "02f70416-581e-4f00-bde1-d65e69af95c5",
                "modelVersionId": "88c78078-f1fd-4f73-bdd9-10420b0f6353",
                "modelName": "Vspinfra111601..base_vcpe_infra..module-0",
                "modelVersion": "1",
                "modelCustomizationId": "11ddac51-30e3-4a3f-92eb-2eb99c2cb288",
                "modelCustomizationName": "Vspinfra111601..base_vcpe_infra..module-0"
            },
        """
        node_dic = svc_template['topology_template']['groups']
        for node_name, v in node_dic.items():
            if v['type'].startswith('org.openecomp.groups.VfModule'):
                model = {
                    'modelType': 'vfModule',
                    'modelInvariantId':  v['metadata']['vfModuleModelInvariantUUID'],
                    'modelVersionId': v['metadata']['vfModuleModelUUID'],
                    'modelName': v['metadata']['vfModuleModelName'],
                    'modelVersion': v['metadata']['vfModuleModelVersion'],
                    'modelCustomizationId': v['metadata']['vfModuleModelCustomizationUUID'],
                    'modelCustomizationName': v['metadata']['vfModuleModelName']
                }
                self.vfmodule_models.append(model)
                self.logger.info('Parser found a VF module: ' + model['modelCustomizationName'])

    def parse_service_yaml(self, filename):
        # clean up
        self.svc_model = {}
        self.net_models = []    # there could be multiple networks
        self.vnf_models = []    # this version only support a single VNF in the service template
        self.vfmodule_models = []   # this version only support a single VF module in the service template

        svc_template = yaml.load(file(filename, 'r')) # pylint: disable=E0602
        self.get_service_model_info(svc_template)
        self.get_vnf_and_network_model_info(svc_template)
        self.get_vfmodule_model_info(svc_template)

        return True

    def parse_csar(self, csar_file):
        yaml_file = self.get_service_yaml_from_csar(csar_file)
        if yaml_file != '':
            return self.parse_service_yaml(yaml_file)

    def print_models(self):
        print('---------Service Model----------')
        print(json.dumps(self.svc_model, indent=2, sort_keys=True))

        print('---------Network Model(s)----------')
        for model in self.net_models:
            print(json.dumps(model, indent=2, sort_keys=True))

        print('---------VNF Model(s)----------')
        for model in self.vnf_models:
            print(json.dumps(model, indent=2, sort_keys=True))

        print('---------VF Module Model(s)----------')
        for model in self.vfmodule_models:
            print(json.dumps(model, indent=2, sort_keys=True))

    def test(self):
        self.parse_csar('csar/service-Vcpesvcinfra111601-csar.csar')
        self.print_models()
