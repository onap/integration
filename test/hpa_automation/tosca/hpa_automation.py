#!/usr/bin/python

#Prerequisites for machine to run this
#Put in required parameters in hpa_automation_config.json
#Install python-pip (apt install python-pip)
#Install python mysql.connector (pip install mysql-connector-python)
#Install ONAP CLI
#Must have connectivity to the ONAP, a k8s vm already running is recommended
#Create Preload File, the script will modify the parameters required from serivce model, service instance
#and vnf instance
#Create policies for homing
#Put in CSAR file
#modify so-bpmn configmap and change version to v2

import json
import os
import time
import argparse
import sys

def get_parameters(file):
    parameters = json.load(file)
    return parameters

def get_out_helper(in_string):
    out_list = (((in_string.replace('-','')).replace('|', '')).replace('+', '')).split()
    return out_list

def get_out_helper_2(in_string):
    out_list = ((in_string.replace('|', '')).replace('+', '')).split()
    return out_list

def set_open_cli_env(parameters):
    os.environ["OPEN_CLI_PRODUCT_IN_USE"] = parameters["open_cli_product"]
    os.environ["OPEN_CLI_HOME"] = parameters["open_cli_home"]

def create_complex(parameters):
    complex_create_string = "oclip complex-create -j {} -r {} -x {} -y {} -lt {} -l {} -i {} -lo {} \
                         -S {} -la {} -g {} -w {} -z {} -k {} -o {} -q {} -m {} -u {} -p {}".format(parameters["street2"], \
                          parameters["physical_location"], parameters["complex_name"], \
                          parameters["data_center_code"], parameters["latitude"], parameters["region"], \
                          parameters["street1"], parameters["longitude"], parameters["state"], \
                          parameters["lata"], parameters["city"], parameters["postal-code"], \
                          parameters["complex_name"], parameters["country"], parameters["elevation"], \
                          parameters["identity_url"], parameters["aai_url"], parameters["aai_username"], \
                          parameters["aai_password"])

    os.system(complex_create_string)


def register_cloud_helper(cloud_region, values, parameters):
    #Create Cloud
    cloud_create_string = 'oclip cloud-create -e {} -b {} -I {{\\\\\\"openstack-region-id\\\\\\":\\\\\\"{}\\\\\\"}} \
    -x {} -y {} -j {} -w {} -l {} -url {} -n {} -q {} -r {} -Q {} -i {} -g {} -z {} -k {} -c {} -m {} -u {} -p {}'.format(
      values.get("esr-system-info-id"), values.get("user-name"), cloud_region, parameters["cloud-owner"], \
      cloud_region, values.get("password"), values.get("cloud-region-version"), values.get("default-tenant"), \
      values.get("service-url"), parameters["complex_name"], values.get("cloud-type"), parameters["owner-defined-type"], \
      values.get("system-type"), values.get("identity-url"), parameters["cloud-zone"], values.get("ssl-insecure"), \
      values.get("system-status"), values.get("cloud-domain"), parameters["aai_url"], parameters["aai_username"], \
      parameters["aai_password"])


    os.system(cloud_create_string)

    #Associate Cloud with complex
    complex_associate_string = "oclip complex-associate -x {} -y {} -z {} -m {} -u {} -p {}".format(parameters["complex_name"], \
      cloud_region, parameters["cloud-owner"], parameters["aai_url"], parameters["aai_username"], parameters["aai_password"])
    os.system(complex_associate_string)

    #Register Cloud with Multicloud
    multicloud_register_string = "oclip multicloud-register-cloud -y {} -x {} -m {}".format(parameters["cloud-owner"], \
      cloud_region, parameters["multicloud_url"])
    os.system(multicloud_register_string)

def register_all_clouds(parameters):
    cloud_dictionary = parameters["cloud_region_data"]
    for cloud_region, cloud_region_values in cloud_dictionary.iteritems():
        register_cloud_helper(cloud_region, cloud_region_values, parameters)

def register_vnfm_helper(vnfm_key, values, parameters):
    #Create vnfm
    vnfm_create_string = 'oclip vnfm-create -b {} -c {} -e {} -v {} -g {} -x {} -i {} -j {} -q {} \
    -m {} -u {} -p {}'.format(vnfm_key, values.get("type"), values.get("vendor"), \
      values.get("version"), values.get("url"), values.get("vim-id"), \
      values.get("user-name"), values.get("user-password"), values.get("vnfm-version"), \
      parameters["aai_url"], parameters["aai_username"], parameters["aai_password"])

    os.system(vnfm_create_string)

def register_vnfm(parameters):
    vnfm_params = parameters["vnfm_params"]
    for vnfm_key, vnfm_values in vnfm_params.iteritems():
        register_vnfm_helper(vnfm_key, vnfm_values, parameters)


#VNF Deployment Section
def add_policies(parameters):
    resource_string = (os.popen("oclip get-resource-module-name  -u {} -p {} -m {} |grep {}".format(\
      parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_catalog_url"], \
      parameters["service-model-name"] ))).read()
    resource_module_name =   (get_out_helper_2(resource_string))[1]

   #Put in the right resource module name in all policies located in parameters["policy_directory"]
    os.system("find {}/ -type f -exec sed -i 's/{}/{}/g' {{}} \;".format(
      parameters["policy_directory"], parameters["temp_resource_module_name"], resource_module_name))

   #Upload policy models
    for model in os.listdir(parameters["policy_models_directory"]):
      os.system("oclip policy-type-create -x {} -u {} -p {} -m {}".format(model, parameters["policy_username"], \
        parameters["policy_password"], parameters["policy_url"]))
      time.sleep(0.5)

    #print("Put in the resourceModuleName {} in your policy files in {}. ".format(resource_module_name, \
    #(parameters["policy_directory"])))
    #raw_input("Press Enter to continue...")


    #Loop through policy, put in resource_model_name and create policies
    for policy in os.listdir(parameters["policy_directory"]):
      policy_name = "{}.{}".format(parameters["policy_scope"], os.path.splitext(policy)[0])
      policy_file = (os.path.join(parameters["policy_directory"], policy))
      #Create policy
      os.system("oclip policy-create-outdated -m {} -u {} -p {} -x {} -S {} -T {} -o {} -b $(cat {})".format(parameters["policy_url"],\
      parameters["policy_username"], parameters["policy_password"], policy_name, parameters["policy_scope"], \
      parameters["policy_config_type"], parameters["policy_onapName"], policy_file))

      #Push policy
      os.system("oclip policy-push-outdated -m {} -u {} -p {} -x {} -b {} -c {}".format(parameters["policy_url"], \
        parameters["policy_username"], parameters["policy_password"], policy_name, parameters["policy_config_type"],\
        parameters["policy_pdp_group"]))

def onboard_vnf(parameters):
    ns_csars = parameters["vnd-csars"]
    vnf_onboard_outs = {}

    for key, value in ns_csars.items():
        vnf_onboard_string = 'oclip vfc-catalog-onboard-vnf -c {}'.format(value)
        vnf_onboard_outs["key"] = (os.popen(ns_onboard_string)).read()
    return vnf_onboard_outs

def onboard_ns(parameters):
    ns_onboard_string = 'oclip vfc-catalog-onboard-ns -c {}'.format(parameters["ns-csar-id"])
    ns_onboard_out = (os.popen(ns_onboard_string)).read()
    return ns_onboard_out

def create_ns(parameters):
    ns_create_string = 'oclip vfc-nslcm-create -c {} -n {}'.format(parameters["ns-csar-id"], \
      parameters["ns-csar-name"])
    ns_create_out = (os.popen(ns_create_string)).read()
    ns_instance_id = (get_out_helper_2(ns_create_out))[1]
    ns_model_dict["vnf_instance_id"] = ns_instance_id
    return ns_model_dict

def instantiate_ns(parameters, ns_model_dict):
    ns_instance_id = ns_model_dict["ns_instance_id"]
    ns_instantiate_string = 'oclip vfc-nslcm-instantiate -i {} -c {} -n {}'.format(ns_instance_id, \
      parameters["location-constraints"], parameters["sdc-controller-id"])
    ns_instantiate_out = (os.popen(ns_instantiate_string)).read()
    return ns_instantiate_out

#Run Functions
parser = argparse.ArgumentParser()
parser.add_argument('-f', action='store', dest='config_file_path', help='Store config file path')

parser.add_argument('--version', action='version', version='%(prog)s 1.0')

results = parser.parse_args()

config_file_path = results.config_file_path
if config_file_path is None:
    sys.exit(1)
config_file = open(config_file_path)
parameters = get_parameters(config_file)

# 1.Set cli command envionment
set_open_cli_env(parameters)

# 2.Create cloud complex
create_complex(parameters)

# 3.Register all clouds
register_all_clouds(parameters)

# 4.Register vnfm
register_vnfm(parameters)

# 5.FIXME:Because SDC internal API will change without notice, so I will maually design VNF and Service.
# SDC output data model is not align with VFC, we use an workaround method
# We just do run time automation 

# 6.add_policies function not currently working, using curl commands
# add_policies(parameters)

# 7. VFC part
vnf_onboard_output = onboard_vnf(parameters)
print vnf_onboard_output
ns_onboard_out = onboard_ns(parameters)
print ns_onboard_out
ns_model_dict = create_ns(parameters)
print ns_model_dict
instantiate_ns_output = instantiate_ns(parameters, ns_model_dict)
print instantiate_ns_output
