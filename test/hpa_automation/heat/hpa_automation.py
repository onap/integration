#!/usr/bin/python

'''
Read the README file before running this script
'''

import json
import os
import mysql.connector as mariadb
import time

def get_parameters(file):
    parameters = json.load(file)
    return parameters

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
    cloud_create_string = 'oclip cloud-create -e {} -b {} -x {} -y {} -j {} -w {} -l {} -url {} -n {} -q {} \
    -r {} -Q {} -i {} -g {} -z {} -k {} -c {} -m {} -u {} -p {}'.format( values.get("esr-system-info-id"), \
    values.get("user-name"), parameters["cloud-owner"], cloud_region, values.get("password"), \
    values.get("cloud-region-version"), values.get("default-tenant"), values.get("service-url"), \
    parameters["complex_name"], values.get("cloud-type"), parameters["owner-defined-type"], values.get("system-type"),\
    values.get("identity-url"), parameters["cloud-zone"], values.get("ssl-insecure"), values.get("system-status"), \
    values.get("cloud-domain"), parameters["aai_url"], parameters["aai_username"], parameters["aai_password"])


    os.system(cloud_create_string)

    #Associate Cloud with complex
    complex_associate_string = "oclip complex-associate -x {} -y {} -z {} -m {} -u {} -p {}".format(parameters["complex_name"], \
      cloud_region, parameters["cloud-owner"], parameters["aai_url"], parameters["aai_username"], parameters["aai_password"])
    os.system(complex_associate_string)

    #Register Cloud with Multicloud
    multicloud_register_string = "oclip multicloud-register-cloud -y {} -x {} -m {}".format(parameters["cloud-owner"], \
      cloud_region, parameters["multicloud_url"])
    os.system(multicloud_register_string)
    time.sleep(2)

def register_all_clouds(parameters):
    cloud_dictionary = parameters["cloud_region_data"]
    for cloud_region, cloud_region_values in cloud_dictionary.iteritems():
        register_cloud_helper(cloud_region, cloud_region_values, parameters)

def create_service_type(parameters):
    create_string = "oclip service-type-create -x {} -m {} -u {} -p {}".format( parameters["service_name"], \
      parameters["aai_url"], parameters["aai_username"], parameters["aai_password"])
    os.system(create_string)

def create_customer(parameters):
    create_string = "oclip customer-create -x {} -y {} -m {} -u {} -p {}".format( parameters["customer_name"], \
    parameters["subscriber_name"], parameters["aai_url"], parameters["aai_username"], parameters["aai_password"])
    os.system(create_string)

def add_customer_subscription(parameters):
    subscription_check = 0
    for cloud_region, cloud_region_values in (parameters["cloud_region_data"]).iteritems():
      if subscription_check == 0 :
        subscription_string = "oclip subscription-create -x {} -c {} -z {} -e {} -y {} -r {} -m {} -u {} -p {}".format(\
          parameters["customer_name"], cloud_region_values.get("tenant-id"), parameters["cloud-owner"], parameters["service_name"],\
          cloud_region_values.get("default-tenant"), cloud_region, parameters["aai_url"], parameters["aai_username"], parameters["aai_password"] )
      else:
        subscription_string = "oclip subscription-cloud-add -x {} -c {} -z {} -e {} -y {} -r {} -m {} -u {} -p {}".format(\
          parameters["customer_name"], cloud_region_values.get("tenant-id"), parameters["cloud-owner"], parameters["service_name"],\
          cloud_region_values.get("default-tenant"), cloud_region, parameters["aai_url"], parameters["aai_username"], parameters["aai_password"] )
      os.system(subscription_string)
      subscription_check+=1

def get_out_helper(in_string):
    out_list = (((in_string.replace('-','')).replace('|', '')).replace('+', '')).split()
    return out_list

def get_out_helper_2(in_string):
    out_list = ((in_string.replace('|', '')).replace('+', '')).split()
    return out_list

#ONBOARDING SECTION
def create_vlm(parameters):
    vlm_create_string = "oclip vlm-create -x {} -u {} -p {} -m {}".format(parameters["vendor-name"], \
      parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_onboarding_url"])
    command_out = (os.popen(vlm_create_string)).read()
    out_list = get_out_helper(command_out)
    vlm_id = out_list[3]
    vlm_version = out_list[5]


    entitlement_string = "oclip vlm-entitlement-pool-create -x {} -y {} -e {} -k {} -g {} -l {} -u {} -p {} -m {}".format( \
      parameters["entitlement-pool-name"], vlm_id, vlm_version, parameters["vendor-name"], parameters["expiry-date"], \
      parameters["start-date"],  parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_onboarding_url"])
    command_out = (os.popen(entitlement_string)).read()
    entitlement_id = (get_out_helper(command_out))[3]

    key_group_string = "oclip vlm-key-group-create -c {} -e {} -x {} -y {} -u {} -p {} -m {}".format(vlm_id, vlm_version, \
      parameters["key-group-name"], parameters["key-group-type"],  parameters["sdc_creator"], parameters["sdc_password"], \
      parameters["sdc_onboarding_url"])
    command_out = (os.popen(key_group_string)).read()
    key_group_id = (get_out_helper(command_out))[3]

    feature_group_string = "oclip vlm-feature-group-create -x {} -y {} -e {} -g {} -b {} -c {} -u {} -p {} -m {}".format(
      parameters["feature-grp-name"], vlm_id, vlm_version, key_group_id, entitlement_id, \
      parameters["part-no"], parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_onboarding_url"])
    command_out = (os.popen(feature_group_string)).read()
    feature_group_id = (get_out_helper(command_out))[3]

    agreement_string = "oclip vlm-aggreement-create -x {} -y {} -e {} -g {} -u {} -p {} -m {}".format(parameters["agreement-name"], \
      vlm_id, vlm_version, feature_group_id, parameters["sdc_creator"], parameters["sdc_password"], \
      parameters["sdc_onboarding_url"])
    command_out = (os.popen(agreement_string)).read()
    agreement_id = (get_out_helper(command_out))[3]


    submit_string = "oclip vlm-submit -x {} -y {} -u {} -p {} -m {}".format(vlm_id, vlm_version, parameters["sdc_creator"], \
      parameters["sdc_password"], parameters["sdc_onboarding_url"])
    os.system(submit_string)

    output = [feature_group_id, agreement_id, vlm_version, vlm_id ]

    return output

def create_vsp(parameters, in_list):
    create_string = "oclip vsp-create -j {} -o {} -e {} -x {} -y {} -i {} -c {} -g {} -u {} -p {} -m {}".format( in_list[0], \
      parameters["onboarding-method"], parameters["vendor-name" ], parameters["vsp-name"], parameters["vsp-desc"], in_list[1], \
      in_list[2], in_list[3], parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_onboarding_url"] )
    command_out = (os.popen(create_string)).read()
    out_list = get_out_helper(command_out)
    vsp_id = out_list[3]
    vsp_version = out_list[7]

    os.system("oclip vsp-add-artifact -x {} -y {} -z {} -u {} -p {} -m {}".format(vsp_id, vsp_version, parameters["csar-file-path"], \
      parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_onboarding_url"]))

    os.system("oclip vsp-validate -x {} -y {} -u {} -p {} -m {}".format(vsp_id, vsp_version, parameters["sdc_creator"], \
      parameters["sdc_password"], parameters["sdc_onboarding_url"]))

    os.system("oclip vsp-submit -x {} -y {} -u {} -p {} -m {}".format(vsp_id, vsp_version, parameters["sdc_creator"], \
      parameters["sdc_password"], parameters["sdc_onboarding_url"]))

    os.system("oclip vsp-package -x {} -y {} -u {} -p {} -m {}".format(vsp_id, vsp_version, parameters["sdc_creator"], \
      parameters["sdc_password"], parameters["sdc_onboarding_url"]))


    return vsp_id


def create_vf_model(parameters, vsp_id):
    create_string = "oclip vf-model-create -y {} -g {} -x {} -z {} -b {} -u {} -p {} -m {}".format(parameters["vf-description"], \
      parameters["vsp-version"], parameters["vf-name"], parameters["vendor-name"], vsp_id, parameters["sdc_creator"], \
      parameters["sdc_password"], parameters["sdc_catalog_url"])
    os.system(create_string)

    output = (os.popen("oclip vf-model-list -m {} -u {} -p {} | grep {}".format(parameters["sdc_catalog_url"], \
      parameters["sdc_creator"], parameters["sdc_password"], parameters["vf-name"]))).read()
    output = (get_out_helper_2(output))

    vf_unique_id = output[1]

    os.system("oclip vf-model-certify -b {} -r {} -u {} -p {} -m {}".format(vf_unique_id, parameters["vf-remarks"], \
      parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_catalog_url"]))

    #Check for new parameters after certification
    output = (os.popen("oclip vf-model-list -m {} -u {} -p {} | grep {}".format(parameters["sdc_catalog_url"], \
                              parameters["sdc_creator"], parameters["sdc_password"], parameters["vf-name"]))).read()
    output = (get_out_helper_2(output))

    vf_id = output[0]
    vf_unique_id = output[1]
    vf_model_invariant_uuid = output[2]
    vf_model_version = output[4]

    out_dict = {}
    out_dict["vf_id"] = vf_id
    out_dict["vf_unique_id"] = vf_unique_id
    out_dict["vf_model_invariant_uuid"] = vf_model_invariant_uuid
    out_dict["vf_model_version"] = vf_model_version

    return out_dict


def create_service_model(parameters, vf_unique_id):
    create_string = "oclip service-model-create -z {} -y {} -e {} -x {} -c {} -b {} -u {} -p {} -m {} |grep -i ID".format(parameters["project-code"], \
    parameters["service-model-desc"], parameters["icon-id"], parameters["service-model-name"], parameters["category-display"], \
    parameters["category"],parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_catalog_url"])

    service_model_id = (get_out_helper_2((os.popen(create_string)).read()))[1]

    os.system("oclip service-model-add-vf -x {} -b {} -y {} -z {} -u {} -p {} -m {}".format(service_model_id, parameters["vf-version"], \
    vf_unique_id, parameters["vf-name"], parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_catalog_url"] ))

    os.system("oclip service-model-test-request -b {} -r {} -u {} -p {} -m {}".format(service_model_id, parameters["service-test-remarks"], \
    parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_catalog_url"]))

    os.system("oclip service-model-test-start -b {} -u {} -p {} -m {}".format(service_model_id, parameters["sdc_tester"], \
    parameters["sdc_password"], parameters["sdc_catalog_url"]))

    os.system("oclip service-model-test-accept -b {} -r {} -u {} -p {} -m {}".format(service_model_id, parameters["service-accept-remarks"], \
    parameters["sdc_tester"], parameters["sdc_password"], parameters["sdc_catalog_url"]))

    #Get uniqueId for the service model
    service_model_values = (os.popen("oclip service-model-list -u {} -p {} -m {} |grep {}".format(parameters["sdc_creator"], \
      parameters["sdc_password"], parameters["sdc_catalog_url"], parameters["service-model-name"]))).read()
    service_model_values = get_out_helper_2(service_model_values)
    service_model_uniqueId = (service_model_values)[1]

    os.system("oclip service-model-approve -b {} -r {} -u {} -p {} -m {}".format(service_model_uniqueId, parameters["service-approve-remarks"], \
    parameters["sdc_governor"], parameters["sdc_password"], parameters["sdc_catalog_url"]))

    os.system("oclip service-model-distribute -b {} -u {} -p {} -m {}".format(service_model_uniqueId, parameters["sdc_operator"], \
    parameters["sdc_password"], parameters["sdc_catalog_url"]))

    return service_model_values


#VNF Deployment Section
def upload_policy_models(parameters):
    os.system("python insert_policy_models_heat.py {} {} {}".format(parameters["policy_db_ip"], \
            parameters["policy_db_user"], parameters["policy_db_password"]))

def add_policies(parameters):
    resource_string = (os.popen("oclip get-resource-module-name  -u {} -p {} -m {} |grep {}".format(\
      parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_catalog_url"], \
      parameters["vf-name"] ))).read()
    resource_module_name =   (get_out_helper_2(resource_string))[1]

   #Put in the right resource module name in all policies located in parameters["policy_directory"]
    os.system("find {}/ -type f -exec sed -i 's/{}/{}/g' {{}} \;".format(
      parameters["policy_directory"], parameters["temp_resource_module_name"], resource_module_name))

    #Loop through policy, put in resource_model_name and create policies
    for policy in os.listdir(parameters["policy_directory"]):

      policy_file = (os.path.join(parameters["policy_directory"], policy))

      #Get policy name from policy file
      policy_contents = open(policy_file, 'r').read()
      start_string = '"policyName\\":\\"'
      end_string = '\\",\\"ver'
      policy_name = policy_contents[policy_contents.find(start_string)+len(start_string):policy_contents.rfind(end_string)]


     #Create policy
      os.system("oclip policy-create-outdated -m {} -u {} -p {} -x {} -S {} -T {} -o {} -b $(cat {})".format(parameters["policy_url"],\
      parameters["policy_username"], parameters["policy_password"], policy_name, parameters["policy_scope"], \
      parameters["policy_config_type"], parameters["policy_onapName"], policy_file))

      #Push policy
      os.system("oclip policy-push-outdated -m {} -u {} -p {} -x {} -b {} -c {}".format(parameters["policy_url"], \
        parameters["policy_username"], parameters["policy_password"], policy_name, parameters["policy_config_type"],\
        parameters["policy_pdp_group"]))


def create_service_instance(parameters, sevice_model_list):
    #Get Required parameters
    service_uuid = service_model_list[0]
    service_invariant_uuid = service_model_list[2]
    service_version = service_model_list[4]

    owning_entity_values = (os.popen("oclip owning-entity-list -u {} -p {} -m {} |grep {}".format(parameters["aai_username"], \
      parameters["aai_password"], parameters["aai_url"], parameters["owning-entity-name"]))).read()
    owning_entity_id = (get_out_helper_2(owning_entity_values))[1]

    #Create service instance
    instance_output = (os.popen("oclip service-create -w {} -la {} -lo {} -o {} -A {} -i {} -y {} -x {} -q {} -O {} -k {}-{} -P {} \
      -H {} -n {} -e {} -j {} -S {} -g {} -z {} -c {} -u {} -p {} -m {} |grep service-id".format(parameters["service_name"], \
        parameters["customer-latitude"], parameters["customer-longitude"], parameters["orchestrator"], parameters["a-la-carte"], \
        parameters["service-model-name"], parameters["company-name"], parameters["projectName"], parameters["requestor-id"], \
        parameters["owning-entity-name"], parameters["instance-name"], parameters["service_name"], parameters["test-api"], parameters["homing-solution"], \
        service_uuid, service_invariant_uuid, service_version, parameters["subscriber_name"], service_uuid, owning_entity_id, \
        parameters["customer_name"], parameters["so_username"], parameters["so_password"], parameters["so_url"] ))).read()

    service_instance_id = (get_out_helper_2(instance_output))[1]
    output_dict = {}

    output_dict["service_instance_id"] = service_instance_id
    output_dict["service_uuid"] = service_uuid
    output_dict["service_invariant_uuid"] = service_invariant_uuid
    output_dict["service_version"] = service_version


    return output_dict

def query_db(parameters, service_model_uuid, vf_model_uuid):

    out_dictionary = {}
    #Query DB Certain parameters required
    mariadb_connection = mariadb.connect(user='{}'.format(parameters["so_mariadb_user"]), host='{}'.format(parameters["mariadb_host"]),
                         password='{}'.format(parameters["so_mariadb_password"]), database='{}'.format(parameters["so_mariadb_db"]))
    values = mariadb_connection.cursor()

    #Get vf model customization values
    values.execute('SELECT MODEL_INSTANCE_NAME, MODEL_CUSTOMIZATION_UUID FROM vnf_resource_customization WHERE \
      SERVICE_MODEL_UUID = "{}"'.format(service_model_uuid))
    vf_customization_values = values.fetchall()

    out_dictionary["vf_model_customization_name"] = vf_customization_values[0][0]
    out_dictionary["vf_model_customization_id"] = vf_customization_values[0][1]

    values.execute('SELECT MODEL_INVARIANT_UUID, MODEL_UUID, MODEL_NAME, MODEL_VERSION FROM vf_module WHERE \
      VNF_RESOURCE_MODEL_UUID = "{}"'.format(vf_model_uuid))

    vf_module_values = values.fetchall()
    out_dictionary["vf_module_model_invariant_id"] = vf_module_values[0][0]
    out_dictionary["vf_module_model_id"] = vf_module_values[0][1]
    out_dictionary["vf_module_model_name"] = vf_module_values[0][2]
    out_dictionary["vf_module_model_version"] = vf_module_values[0][3]

    values.execute('SELECT MODEL_CUSTOMIZATION_UUID FROM vf_module_customization WHERE \
      VF_MODULE_MODEL_UUID = "{}"'.format(out_dictionary["vf_module_model_id"]))
    vf_module_customization = values.fetchall()

    out_dictionary["vf_module_customization_id"] = vf_module_customization[0][0]
    values.close()
    mariadb_connection.close()

    return out_dictionary



def create_vnf(parameters, service_dict, db_dict, vf_model_dict):

    vf_model_uuid = vf_model_dict["vf_id"]
    vf_model_invariant_uuid = vf_model_dict["vf_model_invariant_uuid"]
    vf_model_version = vf_model_dict["vf_model_version"]

    vf_model_customization_name = db_dict["vf_model_customization_name"]
    vf_model_customization_id = db_dict["vf_model_customization_id"]

    #Put in any cloud region, OOF will select the right one
    cloud_region = next(iter(parameters["cloud_region_data"]))
    tenant_id =  ((parameters["cloud_region_data"])[cloud_region])["tenant-id"]

    service_invariant_uuid = service_dict["service_invariant_uuid"]
    service_uuid = service_dict["service_uuid"]
    service_instance_id = service_dict["service_instance_id"]
    service_version = service_dict["service_version"]

    #Create vnf
    vnf_create_out = (os.popen("oclip vnf-create -j {} -q {} -k {} -l {} -y {} -z {} -r {} -c {} -o {} -e {} -g {} -b {} -n {} -i {} -vn '{}'\
       -w {} -pn {} -lob {} -u {} -p {} -m {} |grep vf-id".format(service_invariant_uuid, parameters["service-model-name"], \
           service_uuid, cloud_region, service_instance_id, tenant_id, parameters["requestor-id"], vf_model_uuid, \
           parameters["generic-vnf-name"], parameters["vf-name"], vf_model_version, vf_model_invariant_uuid, service_version, \
           vf_model_customization_id,  vf_model_customization_name, parameters["service_name"], parameters["platform-name"], \
           parameters["lob-name"], parameters["so_username"], parameters["so_password"], parameters["so_url"]))).read()

    vnf_instance_id = (get_out_helper_2(vnf_create_out))[1]

    vf_model_dict["vnf_instance_id"] = vnf_instance_id

    return vf_model_dict

def sdnc_preload(parameters, db_dict, service_dict):


    preload_file = parameters["sdnc_preload_file"]

    #Replace values gotten from the service instance, vnf, vf in preload file, other values such as ip addresses
    #should be directly changed in the preload file
    #Items to search and replace in file
    replace_dict = {
                    '"generic-vnf-name"' : '           "generic-vnf-name": "{}",\n'.format(parameters["generic-vnf-name"]),
                    '"generic-vnf-type"' : '           "generic-vnf-type": "{}",\n'.format(db_dict["vf_model_customization_name"]),
                    '"service-type"' : '         "service-type": "{}",\n'.format(service_dict["service_instance_id"]),
                    '"vnf-name"' : '           "vnf-name": "{}",\n'.format(parameters["vf-module-name"]),
                    '"vnf-type"' : '           "vnf-type": "{}"\n'.format(db_dict["vf_module_model_name"]),
                    '"vf_module_id"' : '       "vnf-parameter-value": "{}"\n'.format(db_dict["vf_module_model_name"])
                    }

    with open(preload_file, 'r') as file:
         preload_data = file.readlines()

         for key, val in replace_dict.iteritems():
           for line in range(len(preload_data)):

             if key in preload_data[line] and key == '"vf_module_id"':
                preload_data[line + 1] = val
                break

             elif key in preload_data[line] and key != '"vf_module_id"':
                preload_data[line] = val
                break
    with open(preload_file, 'w') as file:
         file.writelines(preload_data)

    os.system("oclip vf-preload -u {} -p {} -y {} -m {}".format(parameters["sdnc_user"], parameters["sdnc_password"], \
      preload_file, parameters["sdnc_url"]))



def create_vf_module(parameters, service_dict, vnf_dict, db_dict):

    #vf module parameters
    vf_module_model_name = db_dict["vf_module_model_name"]
    vf_module_model_invariant_id = db_dict["vf_module_model_invariant_id"]
    vf_module_model_version = db_dict["vf_module_model_version"]
    vf_module_model_version_id = db_dict["vf_module_model_id"]
    vf_module_customization_id = db_dict["vf_module_customization_id"]

    #service parameters
    service_invariant_uuid = service_dict["service_invariant_uuid"]
    service_uuid = service_dict["service_uuid"]
    service_instance_id = service_dict["service_instance_id"]
    service_version = service_dict["service_version"]

    #vnf parameters
    vnf_instance_id = vnf_dict["vnf_instance_id"]
    vf_model_id = vnf_dict["vf_id"]
    vf_model_invariant_uuid = vnf_dict["vf_model_invariant_uuid"]
    vf_model_version = vnf_dict["vf_model_version"]
    vf_model_customization_name = db_dict["vf_model_customization_name"]
    vf_model_customization_id = db_dict["vf_model_customization_id"]

    #Put in any cloud region, OOF will select the right one
    cloud_region = next(iter(parameters["cloud_region_data"]))
    tenant_id =  ((parameters["cloud_region_data"])[cloud_region])["tenant-id"]


    os.system("oclip vf-module-create -w {} -mn '{}' -x {} -l {} -sv {} -vc {} -vm {} -mv {} -i {} -vf {} -vi {}  -r {} \
      -mc {} -api {} -mi {} -vid {} -y {} -R {} -si {} -up {} -sd {} -z {} -vn {} -vv {} -co {} -u {} -p {} -m {}".format(tenant_id, \
        vf_model_customization_name, service_instance_id, cloud_region, service_version, vf_module_customization_id, vf_module_model_version,\
         vf_model_version, parameters["vf-module-name"], parameters["vf-name"], vf_module_model_invariant_id, parameters["supress-rollback"], \
         vf_model_customization_id, parameters["test-api"], vf_model_invariant_uuid, vf_model_id, vnf_instance_id, parameters["requestor-id"], \
         service_uuid, parameters["use-preload"], service_invariant_uuid, parameters["service-model-name"], vf_module_model_name, \
         vf_module_model_version_id, parameters["cloud-owner"], parameters["so_username"], parameters["so_password"], parameters["so_url"]))






#Run Functions

config_file_path = "/root/integration/test/hpa_automation/heat/hpa_automation_config.json"
config_file = open(config_file_path)

#Get required parameters from hpa config file
parameters = get_parameters(config_file)

#Set CLI env variables
set_open_cli_env(parameters)
create_complex(parameters)
register_all_clouds(parameters)

create_service_type(parameters)

create_customer(parameters)
add_customer_subscription(parameters)

vlm_output = create_vlm(parameters)
print("vlm parameters={}".format(vlm_output))

vsp_id = create_vsp(parameters, vlm_output)
print("vsp id={}".format(vsp_id))

vf_model_dict = create_vf_model(parameters, vsp_id)
print("vf model parameters={}".format(vf_model_dict))
vf_id = vf_model_dict["vf_id"]
vf_unique_id = vf_model_dict["vf_unique_id"]

service_model_list = create_service_model(parameters, vf_unique_id)
print("service model parameters={}".format(service_model_list))

upload_policy_models(parameters)
add_policies(parameters)

#Create Service Instance
service_dict = create_service_instance(parameters, service_model_list)
print("service instance parameters={}".format(service_dict))
service_model_uuid = service_dict["service_uuid"]
time.sleep(2)
db_dict = query_db(parameters, service_model_uuid, vf_id)

#Wait for Service instance to be created then create VNF Instance
while True:
    #Check if service instance has been created"
    check_service_instance = os.popen("oclip service-instance-list -u {} -p {} -m {} |grep {}-{}".format(parameters["aai_username"], \
            parameters["aai_password"], parameters["aai_url"], parameters["instance-name"], parameters["service_name"])).read()
    if check_service_instance:
        print("service instance created successfully")
        #Create VNF Instance
        vnf_dict = create_vnf(parameters, service_dict, db_dict, vf_model_dict)
        time.sleep(10)
        print("vnf instance parameters={}".format(vnf_dict))
        break
    print("service instance create in progress")
    time.sleep(30)

#Preload VF module and create VF module
sdnc_preload(parameters, db_dict, service_dict)
create_vf_module(parameters, service_dict, vnf_dict, db_dict)
print("Deployment complete!!!, check cloud to confirm that vf module has been created")
