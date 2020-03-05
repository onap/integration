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
import argparse
import sys
import requests
import mysql.connector

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

def create_vlm(parameters):
    vlm_create_string = "oclip vlm-create -x {} -u {} -p {} -m {}".format(parameters["vendor-name"], \
      parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_onboarding_url"])
    command_out = (os.popen(vlm_create_string)).read()
    out_list = get_out_helper(command_out)
    vlm_id = out_list[3]
    vlm_version = out_list[5]

    entitlement_string = "oclip vlm-entitlement-pool-create -x {} -y {} -e {} -z {} -k {} -g {} -l {} -u {} -p {} -m {}".format( \
      parameters["entitlement-pool-name"], vlm_id, vlm_version, parameters["entitlement-description"], parameters["vendor-name"], \
      parameters["expiry-date"], parameters["start-date"],  parameters["sdc_creator"], parameters["sdc_password"], \
      parameters["sdc_onboarding_url"])
    command_out = (os.popen(entitlement_string)).read()
    entitlement_id = (get_out_helper(command_out))[3]


    key_group_string = "oclip vlm-key-group-create -c {} -e {} -x {} -y {} -u {} -p {} -m {}".format(vlm_id, vlm_version, \
      parameters["key-group-name"], parameters["key-group-type"],  parameters["sdc_creator"], parameters["sdc_password"], \
      parameters["sdc_onboarding_url"])
    command_out = (os.popen(key_group_string)).read()
    key_group_id = (get_out_helper(command_out))[3]

    feature_group_string = "oclip vlm-feature-group-create -x {} -y {} -e {} -z {} -g {} -b {} -c {} -u {} -p {} -m {}".format(
      parameters["feature-grp-name"], vlm_id, vlm_version, parameters["feature-grp-desc"], key_group_id, entitlement_id, \
      parameters["part-no"], parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_onboarding_url"])
    command_out = (os.popen(feature_group_string)).read()
    feature_group_id = (get_out_helper(command_out))[3]

    agreement_string = "oclip vlm-aggreement-create -x {} -y {} -e {} -z {} -g {} -u {} -p {} -m {}".format(parameters["agreement-name"], \
      vlm_id, vlm_version, parameters["agreement-desc"], feature_group_id, parameters["sdc_creator"], parameters["sdc_password"], \
      parameters["sdc_onboarding_url"])
    command_out = (os.popen(agreement_string)).read()
    agreement_id = (get_out_helper(command_out))[3]

    submit_string = "oclip vlm-submit -x {} -y {} -u {} -p {} -m {}".format(vlm_id, vlm_version, parameters["sdc_creator"], \
      parameters["sdc_password"], parameters["sdc_onboarding_url"])
    os.system(submit_string)

    output = [feature_group_id, agreement_id, vlm_version, vlm_id ]
    return output

def create_vsp(parameters, in_list):
    vnfs = parameters["vnf"]
    vsp_ids = {}
    for name, value in vnfs.iteritems():
        create_string = "oclip vsp-create -j {} -o {} -e {} -x {} -y {} -i {} -c {} -g {} -u {} -p {} -m {}".format( in_list[0], \
          parameters["onboarding-method"], parameters["vendor-name"], value.get("vsp-name"), value.get("vsp-desc"), in_list[1], \
          in_list[2], in_list[3], parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_onboarding_url"] )
        command_out = (os.popen(create_string)).read()
        out_list = get_out_helper(command_out)
        vsp_id = out_list[3]
        vsp_version = out_list[5]

        os.system("oclip vsp-add-artifact -x {} -y {} -z {} -u {} -p {} -m {}".format(vsp_id, vsp_version, value.get("path"), \
          parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_onboarding_url"]))

        os.system("oclip vsp-validate -x {} -y {} -u {} -p {} -m {}".format(vsp_id, vsp_version, parameters["sdc_creator"], \
          parameters["sdc_password"], parameters["sdc_onboarding_url"]))

        os.system("oclip vsp-submit -x {} -y {} -u {} -p {} -m {}".format(vsp_id, vsp_version, parameters["sdc_creator"], \
          parameters["sdc_password"], parameters["sdc_onboarding_url"]))

        os.system("oclip vsp-package -x {} -y {} -u {} -p {} -m {}".format(vsp_id, vsp_version, parameters["sdc_creator"], \
          parameters["sdc_password"], parameters["sdc_onboarding_url"]))

        vsp_ids[name] = vsp_id
    return vsp_ids

def create_vf_model(parameters, vsp_dict):
    vnfs = parameters["vnfs"]
    vf_dict = {}
    for name, value in vnfs.iteritems():
        create_string = "oclip vf-model-create -y {} -g {} -x {} -z {} -b {} -u {} -p {} -m {}".format(value.get("vf-description"), \
          value.get("vsp-version"), value.get("vf-name"), parameters["vendor-name"], vsp_dict[name], \
          parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_catalog_url"])
        os.system(create_string)

        output = (os.popen("oclip vf-model-list -m {} -u {} -p {} | grep {}".format(parameters["sdc_catalog_url"], \
          parameters["sdc_creator"], parameters["sdc_password"], value.get("vf-name")))).read()
        output = (get_out_helper_2(output))

        vf_unique_id = output[1]

        os.system("oclip vf-model-certify -b {} -r {} -u {} -p {} -m {}".format(vf_unique_id, value.get("vf-remarks"), \
          parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_catalog_url"]))

        #Check for new parameters after certification
        output = (os.popen("oclip vf-model-list -m {} -u {} -p {} | grep {}".format(parameters["sdc_catalog_url"], \
                              parameters["sdc_creator"], parameters["sdc_password"], value.get("vf-name")))).read()
        output = (get_out_helper_2(output))

        vf_dict[name] = output[1]

    return vf_dict


def create_service_model(parameters, vf_dict):
    vnfs = parameters["vnfs"]

    create_string = "oclip service-model-create -z {} -y {} -e {} -x {} -c {} -b {} -u {} -p {} -m {} |grep ID".format(parameters["project-code"], \
    parameters["service-model-desc"], parameters["icon-id"], parameters["service-model-name"], parameters["category-display"], \
    parameters["category"],parameters["sdc_creator"], parameters["sdc_password"], parameters["sdc_catalog_url"])

    service_model_id = (get_out_helper_2((os.popen(create_string)).read()))[1]

    for name, value in vnfs.iteritems():
        os.system("oclip service-model-add-vf -x {} -b {} -y {} -z {} -u {} -p {} -m {}".format(service_model_id, \
                   parameters["vf-version"], vf_dict[name], value.get("vf-name"), parameters["sdc_creator"], \
                   parameters["sdc_password"], parameters["sdc_catalog_url"] ))

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

def add_policy_models(parameters):
    mydb = mysql.connector.connect(
      host="policydb",
      user="policy_user",
      passwd="policy_user",
      database="onap_sdk",
    )

    mycursor = mydb.cursor()
    hpa_sql = "INSERT INTO optimizationmodels (modelname, description, dependency, imported_by, \
              attributes, ref_attributes, sub_attributes, version, annotation, enumValues, \
              dataOrderInfo) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
    hpa_val = ('hpaPolicy', 'HPA Tests Model', '[]', 'demo', 'identity=string:defaultValue-null:required-true:MANY-false:description-null', \
         'policyScope=MANY-true,policyType=POLICYTYPE:MANY-false,resources=MANY-true,flavorFeatures=flavorFeatures_properties:MANY-true:description-null', \
         '{"directives_properties":{"attributes":"directives_attributes_properties:required-false:MANY-true:description-null",\
         "type":"string:defaultValue-null:required-false:MANY-false:description-null"},\
         "directives_attributes_properties":{"attribute_name":"string:defaultValue-null:required-false:MANY-false:description-null",\
         "attribute_value":"string:defaultValue-null:required-false:MANY-false:description-null"},\
         "flavorProperties_properties":{"score":"string:defaultValue-null:required-false:MANY-false:description-null",\
         "hpa-feature-attributes":"hpa-feature-attributes_properties:required-true:MANY-true:description-null",\
         "directives":"directives_properties:required-true:MANY-true:description-null",\
         "hpa-version":"string:defaultValue-null:required-true:MANY-false:description-null",\
         "hpa-feature":"string:defaultValue-null:required-true:MANY-false:description-null",\
         "mandatory":"string:defaultValue-null:required-true:MANY-false:description-null",\
         "architecture":"string:defaultValue-null:required-true:MANY-false:description-null"},\
         "flavorFeatures_properties":{"directives":"directives_properties:required-true:MANY-true:description-null",\
         "flavorProperties":"flavorProperties_properties:required-true:MANY-true:description-null",\
         "id":"string:defaultValue-null:required-true:MANY-false:description-null",\
         "type":"string:defaultValue-null:required-true:MANY-false:description-null"},\
         "hpa-feature-attributes_properties":{"unit":"string:defaultValue-null:required-false:MANY-false:description-null",\
         "hpa-attribute-value":"string:defaultValue-null:required-true:MANY-false:description-null",\
         "hpa-attribute-key":"string:defaultValue-null:required-true:MANY-false:description-null",\
         "operator":"OPERATOR:defaultValue-null:required-false:MANY-false:description-null"}}', \
         'test1', 'policyScope=matching-true, policyType=matching-true', \
         'OPERATOR=[<,<equal-sign,>,>equal-sign,equal-sign,!equal-sign,any,all,subset,], POLICYTYPE=[hpa,]', '""')

    mycursor.execute(hpa_sql, hpa_val)

    sql = "INSERT INTO microservicemodels (modelname, description, dependency, imported_by, \
          attributes, ref_attributes, sub_attributes, version, annotation, enumValues, \
          dataOrderInfo) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
    val = [
        ('distancePolicy', 'distancePolicy', '[]', 'demo', 'identity=string:defaultValue-null:required-true:MANY-false:description-null', \
         'policyScope=MANY-true,distanceProperties=distanceProperties_properties:MANY-false:description-null,policyType=POLICYTYPE:MANY-false,\
          resources=MANY-true,applicableResources=APPLICABLERESOURCES:MANY-false', \
         '{"distanceProperties_properties":{"locationInfo":"string:defaultValue-null:required-true:MANY-false:description-null",\
           "distance":"distance_properties:required-true:MANY-false:description-null"},\
           "distance_properties":{"unit":"UNIT:defaultValue-null:required-true:MANY-false:description-null",\
           "value":"string:defaultValue-null:required-true:MANY-false:description-null","operator":"OPERATOR:defaultValue-null:required-true:MANY-false:description-null"}}', \
           'test1', 'policyScope=matching-true, policyType=matching-true', \
           'OPERATOR=[<,<equal-sign,>,>equal-sign,equal-sign,], APPLICABLERESOURCES=[any,all,], POLICYTYPE=[distance_to_location,] ', '""'),
        ('optimizationPolicy', 'Optimization policy model', '[]', 'demo', 'identity=string:defaultValue-null:required-true:MANY-false:description-null', \
         'objectiveParameter=objectiveParameter_properties:MANY-false:description-null,policyScope=MANY-true,policyType=POLICYTYPE:MANY-false,\
          objective=objectiveParameter_properties:MANY-false:description-null', \
         '{"parameterAttributes_properties":{"customerLocationInfo":"string:defaultValue-null:required-true:MANY-false:description-null",\
           "parameter":"string:defaultValue-null:required-true:MANY-false:description-null",\
           "resources":"string:defaultValue-null:required-true:MANY-false:description-null",\
           "weight":"string:defaultValue-null:required-true:MANY-false:description-null",\
           "operator":"OPERATOR:defaultValue-null:required-true:MANY-false:description-null"},\
           "objectiveParameter_properties":{"parameterAttributes":"parameterAttributes_properties:required-true:MANY-true:description-null",\
           "operator":"OPERATOR:defaultValue-null:required-true:MANY-false:description-null"}}', \
           'test1', 'policyScope=matching-true, policyType=matching-true', 'OPERATOR=[*,+,-,/,%,], POLICYTYPE=[placement_optimization,]', '""'),
        ('queryPolicy', 'Query policy model', '[]', 'demo', 'identity=string:defaultValue-null:required-true:MANY-false:description-null', \
         'policyScope=MANY-true,policyType=POLICYTYPE:MANY-false,queryProperties=queryProperties_properties:MANY-true:description-null', \
         '{"queryProperties_properties":{"attribute_location":"string:defaultValue-null:required-true:MANY-false:description-null",\
           "attribute":"string:defaultValue-null:required-true:MANY-false:description-null","value":"string:defaultValue-null:required-true:MANY-false:description-null"}}', \
         'test1', 'policyScope=matching-true, policyType=matching-true', 'POLICYTYPE=[request_param_query,]', '""'),
        ('vnfPolicy', 'VnfPolicy model', '[]', 'demo', 'identity=string:defaultValue-null:required-true:MANY-false:description-null', \
         'policyScope=MANY-true,policyType=POLICYTYPE:MANY-false,resources=MANY-true,\
          vnfProperties=vnfProperties_properties:MANY-true:description-null,applicableResources=APPLICABLERESOURCES:MANY-false', \
         '{"vnfProperties_properties":{"serviceType":"string:defaultValue-null:required-true:MANY-false:description-null",\
           "inventoryProvider":"string:defaultValue-null:required-true:MANY-false:description-null",\
           "inventoryType":"INVENTORYTYPE:defaultValue-null:required-true:MANY-false:description-null",\
         "customerId":"string:defaultValue-null:required-true:MANY-false:description-null"}}', \
         'test1', 'policyScope=matching-true, policyType=matching-true', \
         'INVENTORYTYPE=[serviceInstanceId,vnfName,cloudRegionId,vimId,], APPLICABLERESOURCES=[any,all,], POLICYTYPE=[vnfPolicy,]', '""'),
        ('vim_fit', 'Capacity policy model', '[]', 'demo', 'identity=string:defaultValue-null:required-true:MANY-false:description-null', \
         'policyScope=MANY-true,policyType=POLICYTYPE:MANY-false,capacityProperties=capacityProperties_properties:MANY-false:description-null,\
          resources=MANY-true,applicableResources=APPLICABLERESOURCES:MANY-false', \
         '{"capacityProperties_properties":{"request":"string:defaultValue-null:required-true:MANY-false:description-null",\
           "controller":"string:defaultValue-null:required-true:MANY-false:description-null"}}', \
           'test1', 'policyScope=matching-true, policyType=matching-true ', ' APPLICABLERESOURCES=[any,all,], POLICYTYPE=[vim_fit,]', '""'),
        ('affinityPolicy', 'Affinity policy model', '[]', 'demo', 'identity=string:defaultValue-null:required-true:MANY-false:description-null', \
         'policyScope=MANY-true,policyType=POLICYTYPE:MANY-false,affinityProperties=affinityProperties_properties:MANY-false:description-null,\
          resources=MANY-true,applicableResources=APPLICABLERESOURCES:MANY-false', \
         '{"affinityProperties_properties":{"qualifier":"QUALIFIER:defaultValue-null:required-true:MANY-false:description-null",\
           "category":"string:defaultValue-null:required-true:MANY-false:description-null"}}', \
           'test1', 'policyScope=matching-true, policyType=matching-true ', ' APPLICABLERESOURCES=[any,all,], POLICYTYPE=[zone,], QUALIFIER=[same,different,]', '""'),
        ('pciPolicy', 'Pci policy model', '[]', 'demo', 'identity=string:defaultValue-null:required-true:MANY-false:description-null', \
         'policyScope=MANY-true,policyType=POLICYTYPE:MANY-false,resources=MANY-true,pciProperties=pciProperties_properties:MANY-true:description-null', \
         '{"pciProperties_properties":{"pciOptimizationTimeConstraint":"string:defaultValue-null:required-false:MANY-false:description-null",\
           "pciOptimizationNwConstraint":"string:defaultValue-null:required-false:MANY-false:description-null",\
           "algoCategory":"string:defaultValue-null:required-false:MANY-false:description-null",\
           "pciOptmizationAlgoName":"string:defaultValue-null:required-false:MANY-false:description-null",\
           "pciOptimizationPriority":"string:defaultValue-null:required-false:MANY-false:description-null"}}', \
           'test1', 'olicyScope=matching-true, policyType=matching-true ', ' POLICYTYPE=[pciPolicy,]', '""'),
        ('subscriberPolicy', 'Subscriber Policy Model', '[]', 'demo', 'identity=string:defaultValue-null:required-true:MANY-false:description-null', \
         'policyScope=MANY-true,policyType=POLICYTYPE:MANY-false,properties=properties_properties:MANY-false:description-type of a policy', \
         '{"properties_properties":{"provStatus":"PROVSTATUS:defaultValue-null:required-true:MANY-false:description-null",\
           "subscriberName":"SUBSCRIBERNAME:defaultValue-null:required-true:MANY-false:description-null",\
           "subscriberRole":"SUBSCRIBERROLE:defaultValue-null:required-true:MANY-false:description-null"}}', \
         'test1', 'policyScope=matching-true, policyType=matching-true, properties=matching-true ', \
         ' SUBSCRIBERNAME=[], SUBSCRIBERROLE=[], POLICYTYPE=[subscriberPolicy,], PROVSTATUS=[]', '""')
    ]

    mycursor.executemany(sql, val)
    mydb.commit()
    print(mycursor.rowcount, "was inserted.")

def add_policies(parameters):
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
    vnfs = parameters["vnfs"]
    vnf_onboard_outputs = {}

    for key, value in vnfs.items():
        vnf_onboard_string = 'oclip vfc-catalog-onboard-vnf -m {} -c {}'\
            .format(value.get("url"), value.get("csar-id"))
        vnf_onboard_outputs[key] = (os.popen(vnf_onboard_string)).read()
    return vnf_onboard_outputs

def onboard_ns(parameters):
    ns_onboard_string = 'oclip vfc-catalog-onboard-ns -m {} -c {}'.format(parameters["ns"]["url"],
                                                                          parameters["ns"]["csar-id"])
    ns_onboard_out = (os.popen(ns_onboard_string)).read()
    return ns_onboard_out

def create_ns(parameters, csar_id):
    ns = parameters["ns"]
    ns_create_string = 'oclip vfc-nslcm-create -m {} -c {} -n {} -q {} -S {}'.format(parameters["vfc-url"], \
       csar_id, ns.get("name"), parameters["customer_name"], parameters["service_name"])
    print(ns_create_string)
    ns_create_out = (os.popen(ns_create_string)).read()
    print(ns_create_out)
    ns_instance_id = (get_out_helper_2(ns_create_out))[4]
    return ns_instance_id

def instantiate_ns(parameters, ns_instance_id):
    ns_instantiate_string = 'oclip vfc-nslcm-instantiate -m {} -i {} -c {} -n {}'.format(parameters["vfc-url"], \
        ns_instance_id, parameters["location"], parameters["sdc-controller-id"])
    print(ns_instantiate_string)

    ns_instantiate_out = (os.popen(ns_instantiate_string)).read()
    return ns_instantiate_out

def terminate_ns(parameters, ns_instance_id):
    ns_terminate_string = 'oclip vfc-nslcm-terminate -m {} -i {}'.format(parameters["vfc-url"], ns_instance_id)
    print(ns_terminate_string)
    ns_terminate_out = (os.popen(ns_terminate_string)).read()
    print(ns_terminate_out)
    return ns_terminate_out

def delete_ns(parameters, ns_instance_id):
    ns_delete_string = 'oclip vfc-nslcm-delete -m {} -c {}'.format(parameters["vfc-url"], ns_instance_id)
    print(ns_delete_string)
    ns_delete_out = (os.popen(ns_delete_string)).read()
    return ns_delete_out

def create_ns_package(parameters):
    ns = parameters["ns"]
    create_ns_string = 'oclip vfc-catalog-create-ns -m {} -c {} -e {}'.format(parameters["vfc-url"], \
      ns.get("key"), ns.get("value"))
    cmd_out = (os.popen(create_ns_string)).read()
    out_list =  get_out_helper_2(cmd_out)
    return out_list[4]

def create_vnf_package(parameters):
    vnfs = parameters["vnfs"]
    outputs = {}

    for vnf_key, vnf_values in vnfs.iteritems():
        create_vnf_string = 'oclip vfc-catalog-create-vnf -m {} -c {} -e {}'.format(parameters["vfc-url"], \
          vnf_values.get("key"), vnf_values.get("value"))
        cmd_out = (os.popen(create_vnf_string)).read()
        out_list =  get_out_helper_2(cmd_out)
        outputs[vnf_key] = out_list[4]

    return outputs

def upload_ns_package(parameters, ns_package_output):
    ns = parameters["ns"]
    ns_upload_string = '{}/api/nsd/v1/ns_descriptors/{}/nsd_content'.format(parameters["vfc-url"], ns_package_output)
    print(ns_upload_string)
    print(ns.get("path"))
    resp = requests.put(ns_upload_string, files={'file': open(ns.get("path"), 'rb')})
    return resp

def upload_vnf_package(parameters, vnf_package_output):
    vnfs = parameters["vnfs"]
    for vnf_key, vnf_values in vnfs.iteritems():
        vnf_upload_str = '{}/api/vnfpkgm/v1/vnf_packages/{}/package_content'.format(parameters["vfc-url"], \
          vnf_package_output[vnf_key], vnf_package_output[vnf_key])
        resp = requests.put(vnf_upload_str, files={'file': open(vnf_values.get("path"), 'rb')})
    return resp


#Run Functions
parser = argparse.ArgumentParser()
parser.add_argument('-f', action='store', dest='config_file_path', help='Store config file path')
parser.add_argument('-t', action='store', dest='model', help='Store config file path')

parser.add_argument('--version', action='version', version='%(prog)s 1.0')

results = parser.parse_args()

config_file_path = results.config_file_path
model = results.model
if config_file_path is None:
    sys.exit(1)
config_file = open(config_file_path)
parameters = get_parameters(config_file)

# 1.Set cli command envionment
set_open_cli_env(parameters)

# 2.Create cloud complex
create_complex(parameters)

# 3.1 Register all clouds
register_all_clouds(parameters)

# 3.2 create service and customer
create_service_type(parameters)
create_customer(parameters)
add_customer_subscription(parameters)

# 4.Register vnfm
register_vnfm(parameters)

# 5.create csar file
# 5.1 upload csar file to catalog
# 5.2 FIXME:Because SDC internal API will change without notice, so I will maually design VNF and Service.
# SDC output data model is not align with VFC, we use an workaround method
# We just do run time automation
ns_package_output = ""

if model == "sdc":
    print("use csar file is distributed by sdc")
    # output = create_vlm(parameters)
    # vsp_dict = create_vsp(parameters, output)
    # vf_dict = create_vf_model(parameters, vsp_dict)
    # service_model_list = create_service_model(parameters, vf_dict)

    vnf_onboard_output = onboard_vnf(parameters)
    print(vnf_onboard_output)
    ns_out = onboard_ns(parameters)
    print(ns_out)
else:
    print("use csar file is uploaded by local")
    vnf_package_output = create_vnf_package(parameters)
    print(vnf_package_output)
    ns_package_output = create_ns_package(parameters)
    print(ns_package_output)
    upload_vnf_out = upload_vnf_package(parameters, vnf_package_output)
    print(upload_vnf_out)
    ns_out = upload_ns_package(parameters, ns_package_output)
    print(ns_out)

# 6.add_policies function not currently working, using curl commands
add_policy_models(parameters)
add_policies(parameters)

# 7. VFC part
ns_instance_id = create_ns(parameters, ns_out)
print(ns_instance_id)
instantiate_ns_output = instantiate_ns(parameters, ns_instance_id)
print(instantiate_ns_output)

#terminate and delete ns;
#option args add the end of json file

if sys.argv[3] == "terminate":
    terminate_ns_output = terminate_ns(parameters, ns_instance_id)
    print(terminate_ns_output)

elif sys.argv[3] == "delete":
    delete_ns_output = delete_ns(parameters, ns_instance_id)
    print(delete_ns_output)
