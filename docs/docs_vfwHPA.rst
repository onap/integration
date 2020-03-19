.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. Copyright 2018 ONAP

.. _docs_vfw_hpa:

vFW/vDNS with HPA Tutorial: Setting Up and Configuration
--------------------------------------------------------

Description
~~~~~~~~~~
This use case makes modifications to the regular vFW use case in ONAP by giving the VMs certain hardware features (such as SRIOV NIC, CPU pinning, pci passthrough.. etc.) in order to enhance their performance. Multiple cloud regions with flavors that have HPA features are registered with ONAP. We then create policies that specify the HPA requirements of each VM in the use case. When a service instance is created with OOF specified as the homing solution, OOF responds with the homing solution (cloud region) and flavor directives that meet the requirements specified in the policy.
This tutorial covers enhancements 1 to 5 in Background of https://wiki.onap.org/pages/viewpage.action?pageId=41421112. It focuses on Test Plan 1.

**Useful Links**

`HPA Test Plan Page <https://wiki.onap.org/pages/viewpage.action?pageId=41421112>`_

`HPA Enhancements Page <https://wiki.onap.org/pages/viewpage.action?pageId=34376310>`_

`vFW with HPA Test Status Page <https://wiki.onap.org/display/DW/vFW+with+HPA+Integration+Test+-+Test+Status>`_


`Hardware Platform Enablement in ONAP <https://wiki.onap.org/display/DW/Hardware+Platform+Enablement+In+ONAP>`_



Setting Up and Installation
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Some fixes for HPA support were made subsequent to the release of the Casablanca images.  Several updated docker images need to be used to utilize the fixes.  The details of the docker images that need to be used and the issues that are fixed are described at this link https://wiki.onap.org/display/DW/Docker+image+updates+for+HPA+vFW+testing

Instructions for updating the manifest of ONAP docker images can be found here:  https://onap.readthedocs.io/en/casablanca/submodules/integration.git/docs/#deploying-an-updated-docker-manifest

Install OOM ONAP using the deploy script in the integration repo. Instructions for this can be found in this link https://wiki.onap.org/display/DW/OOM+Component. When the installation is complete (all the pods are either in running or completed state) Do the following;


1. Check that all the required components were deployed;

 ``oom-rancher# helm list``

2. Check the state of the pods;

   ``oom-rancher# kubectl get pods -n onap``

3. Run robot health check

   ``oom-rancher# cd oom/kubernetes/robot``

   ``oom-rancher# ./ete-k8s.sh onap health``

   Ensure all the required components pass the health tests
4. Modify the SO bpmn configmap to change the SO vnf adapter endpoint to v2

   ``oom-rancher#    kubectl -n onap edit configmap dev-so-so-bpmn-infra-app-configmap``

			``- vnf:``

			          ``endpoint: http://so-openstack-adapter.onap:8087/services/VnfAdapter``

			          ``rest:``

			            ``endpoint: http://so-openstack-adapter.onap:8087/services/rest/v1/vnfs``
			 
			``+ vnf:``

			          ``endpoint: http://so-openstack-adapter.onap:8087/services/VnfAdapter``

			          ``rest:``

			            ``endpoint: http://so-openstack-adapter.onap:8087/services/rest/v2/vnfs`` 

   Then delete the bpmn pod

   ``oom-rancher#  kubectl delete <pod-name> -n onap``


5. Create HPA flavors in cloud regions to be registered with ONAP. All HPA flavor names must start with onap. During our tests, 3 cloud regions were registered and we created flavors in each cloud. The flavors match the flavors described in the test plan `here <https://wiki.onap.org/pages/viewpage.action?pageId=41421112>`_.

- **Cloud Region One**

    **Flavor11**
     ``#nova flavor-create onap.hpa.flavor11 111 8 20 2``

     ``#nova flavor-key onap.hpa.flavor11 set hw:mem_page_size=2048``

    **Flavor12**
     ``#nova flavor-create onap.hpa.flavor12 112 12 20 2``

     ``#nova flavor-key onap.hpa.flavor12 set hw:mem_page_size=2048``

     ``#openstack aggregate create --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-8086-154C-shared-1:3 aggr121``

     ``#openstack flavor set onap.hpa.flavor12 --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-8086-154C-shared-1:3``

    **Flavor13**
     ``#nova flavor-create onap.hpa.flavor13 113 12 20 2``

     ``#nova flavor-key onap.hpa.flavor13 set hw:mem_page_size=2048``

     ``#openstack aggregate create --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-8086-154C-private-1:1 aggr131``

     ``#openstack flavor set onap.hpa.flavor13 --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-8086-154C-private-1:1``

- **Cloud Region Two**

    **Flavor21**
     ``#nova flavor-create onap.hpa.flavor21 221 8 20 2``

     ``#nova flavor-key onap.hpa.flavor21 set hw:mem_page_size=2048``

     ``#nova flavor-key onap.hpa.flavor21 set hw:cpu_policy=dedicated``

     ``#nova flavor-key onap.hpa.flavor21 set hw:cpu_thread_policy=isolate``

    **Flavor22**
     ``#nova flavor-create onap.hpa.flavor22 222 12 20 2``

     ``#nova flavor-key onap.hpa.flavor22 set hw:mem_page_size=2048``

     ``#openstack aggregate create --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-8086-154C-shared-1:2 aggr221``

     ``#openstack flavor set onap.hpa.flavor22 --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-8086-154C-shared-1:2``

    **Flavor23**
     ``#nova flavor-create onap.hpa.flavor23 223 12 20 2``

     ``#nova flavor-key onap.hpa.flavor23 set hw:mem_page_size=2048``

     ``#openstack aggregate create --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-8086-154C-private-1:2 aggr231``

     ``#openstack flavor set onap.hpa.flavor23 --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-8086-154C-private-1:2``

- **Cloud Region Three**

    **Flavor31**
     ``#nova flavor-create onap.hpa.flavor31 331 8 20 2``

     ``#nova flavor-key onap.hpa.flavor31 set hw:mem_page_size=2048``

     ``#nova flavor-key onap.hpa.flavor31 set hw:cpu_policy=dedicated``

     ``#nova flavor-key onap.hpa.flavor31 set hw:cpu_thread_policy=isolate``

    **Flavor32**
     ``#nova flavor-create onap.hpa.flavor32 332 8192 20 2``

     ``#nova flavor-key onap.hpa.flavor32 set hw:mem_page_size=1048576``

    **Flavor33**
     ``#nova flavor-create onap.hpa.flavor33 333 12 20 2``

     ``#nova flavor-key onap.hpa.flavor33 set hw:mem_page_size=2048``

     ``#openstack aggregate create --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-8086-154C-shared-1:1 aggr331``

     ``#openstack flavor set onap.hpa.flavor33 --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-8086-154C-shared-1:1``

**Note: Use case can be run manually or using automation script (recommended)**


After completing steps 1 to 5 above, the use case can be set up either manually using **step 6 to 21** below or using the hpa automation script in the integration repo. It can be found in this `link <https://github.com/onap/integration/tree/master/test/hpa_automation/heat>`_. The automation script is not limited to the vFW use case, it can also be used for vDNS and should ideally work with other hpa use cases such as vIPSEC. Instructions for running the script can be found in the README file in the link above. Note that the identity and policy name must be different for all the policies in the policy engine.



6. Run robot healthdist

   ``oom-rancher# ./ete-k8s.sh onap healthdist``
7. Run robot demo init, this initializes the default Demonstration customer and distributes the default models

  ``oom-rancher# ./demo-k8s.sh onap init``

8. Check that the cloud complex has the right values and update if it does not. Required values are;

    "elevation": "example-elevation-val-28399",

    "lata": "example-lata-val-28399",

    "country": "USA",

    "latitude": "32.89948",

    "longitude": "97.045443",

    "postal-code": "00000


If an update is needed, the update can be done via rest using curl or postman

::

    curl -X PUT \
    https://$ONAP_AAI_IP:$ONAP_AAI_PORT/aai/v14/cloud-infrastructure/complexes/complex/clli1 \
    -H 'Accept: application/json' \
    -H 'Authorization: Basic QUFJOkFBSQ==' \
    -H 'Cache-Control: no-cache' \
    -H 'Content-Type: application/json' \
    -H 'Postman-Token: 2b272126-aa65-41e6-aa5d-46bc70b9eb4f' \
    -H 'Real-Time: true' \
    -H 'X-FromAppId: jimmy-postman' \
    -H 'X-TransactionId: 9999' \
    -d '{
         "physical-location-id": "clli1",
         "data-center-code": "example-data-center-code-val-5556",
         "complex-name": "clli1",
         "identity-url": "example-identity-url-val-56898",
         "resource-version": "1543284556407",
         "physical-location-type": "example-physical-location-type-val-7608",
         "street1": "example-street1-val-34205",
         "street2": "example-street2-val-99210",
         "city": "example-city-val-27150",
         "state": "example-state-val-59487",
         "postal-code": "00000",
         "country": "USA",
         "region": "example-region-val-13893",
         "latitude": "32.89948",
         "longitude": "97.045443",
         "elevation": "example-elevation-val-28399",
         "lata": "example-lata-val-28399"

        }'

9. Register new cloud regions. This can be done using instructions (Step 1 to Step 3) on this `page <https://onap.readthedocs.io/en/latest/submodules/multicloud/framework.git/docs/multicloud-plugin-windriver/UserGuide-MultiCloud-WindRiver-TitaniumCloud.html#tutorial-onboard-instance-of-wind-river-titanium-cloud>`_. The already existing CloudOwner and cloud complex can be used. If step 3 does not work using the k8s ip and external port. It can be done using the internal ip address and port. Exec into any pod and run the command from the pod.

- Get msb-iag internal ip address and port

 ``oom-rancher#  kubectl get services -n onap |grep msb-iag``

- Exec into any pod (oof in this case) and run curl command, you may need to install curl

  ``oom-rancher#  kubectl exec dev-oof-oof-6c848594c5-5khps -it -- bash``

10. Put required subscription list into tenant for all the newly added cloud regions. An easy way to do this is to do a get on the default cloud region, copy the tenant information with the subscription. Then paste it in your put command and modify the region id, tenant-id, tenant-name and resource-version.

**GET COMMAND**

::

    curl -X GET \
    https://$ONAP_AAI_IP:$ONAP_AAI_PORT/aai/v14/cloud-infrastructure/cloud-regions/cloud-region/${CLOUD_OWNER}/${CLOUD_REGION_ID}?depth=all \
    -H 'Accept: application/json' \
    -H 'Authorization: Basic QUFJOkFBSQ==' \
    -H 'Cache-Control: no-cache' \
    -H 'Content-Type: application/json' \
    -H 'Postman-Token: 2899359f-871b-4e61-a307-ecf8b3144e3f' \
    -H 'Real-Time: true' \
    -H 'X-FromAppId: jimmy-postman' \
    -H 'X-TransactionId: 9999'

**PUT COMMAND**
::

 curl -X PUT \
    https://{{AAI1_PUB_IP}}:{{AAI1_PUB_PORT}}/aai/v14/cloud-infrastructure/cloud-regions/cloud-region/{{cloud-owner}}/{{cloud-region-id}}/tenants/tenant/{{tenant-id}} \
    -H 'Accept: application/json' \
    -H 'Authorization: Basic QUFJOkFBSQ==' \
    -H 'Cache-Control: no-cache' \
    -H 'Content-Type: application/json' \
    -H 'Postman-Token: 2b272126-aa65-41e6-aa5d-46bc70b9eb4f' \
    -H 'Real-Time: true' \
    -H 'X-FromAppId: jimmy-postman' \
    -H 'X-TransactionId: 9999' \
    -d '{
                "tenant-id": "709ba629fe194f8699b12f9d6ffd86a0",
                "tenant-name": "Integration-HPA",
                "resource-version": "1542650451856",
                "relationship-list": {
                    "relationship": [
                        {
                            "related-to": "service-subscription",
                            "relationship-label": "org.onap.relationships.inventory.Uses",
                            "related-link": "/aai/v14/business/customers/customer/Demonstration/service-subscriptions/service-subscription/vFWCL",
                            "relationship-data": [
                                {
                                    "relationship-key": "customer.global-customer-id",
                                    "relationship-value": "Demonstration"
                                },
                                {
                                    "relationship-key": "service-subscription.service-type",
                                    "relationship-value": "vFWCL"
                                }
                            ]
                        },
                        {
                            "related-to": "service-subscription",
                            "relationship-label": "org.onap.relationships.inventory.Uses",
                            "related-link": "/aai/v14/business/customers/customer/Demonstration/service-subscriptions/service-subscription/gNB",
                            "relationship-data": [
                                {
                                    "relationship-key": "customer.global-customer-id",
                                    "relationship-value": "Demonstration"
                                },
                                {
                                    "relationship-key": "service-subscription.service-type",
                                    "relationship-value": "gNB"
                                }
                            ]
                        },
                        {
                            "related-to": "service-subscription",
                            "relationship-label": "org.onap.relationships.inventory.Uses",
                            "related-link": "/aai/v14/business/customers/customer/Demonstration/service-subscriptions/service-subscription/vFW",
                            "relationship-data": [
                                {
                                    "relationship-key": "customer.global-customer-id",
                                    "relationship-value": "Demonstration"
                                },
                                {
                                    "relationship-key": "service-subscription.service-type",
                                    "relationship-value": "vFW"
                                }
                            ]
                        },
                        {
                            "related-to": "service-subscription",
                            "relationship-label": "org.onap.relationships.inventory.Uses",
                            "related-link": "/aai/v14/business/customers/customer/Demonstration/service-subscriptions/service-subscription/vCPE",
                            "relationship-data": [
                                {
                                    "relationship-key": "customer.global-customer-id",
                                    "relationship-value": "Demonstration"
                                },
                                {
                                    "relationship-key": "service-subscription.service-type",
                                    "relationship-value": "vCPE"
                                }
                            ]
                        },
                        {
                            "related-to": "service-subscription",
                            "relationship-label": "org.onap.relationships.inventory.Uses",
                            "related-link": "/aai/v14/business/customers/customer/Demonstration/service-subscriptions/service-subscription/vFW_HPA",
                            "relationship-data": [
                                {
                                    "relationship-key": "customer.global-customer-id",
                                    "relationship-value": "Demonstration"
                                },
                                {
                                    "relationship-key": "service-subscription.service-type",
                                    "relationship-value": "vFW_HPA"
                                }
                            ]
                        },
                        {
                            "related-to": "service-subscription",
                            "relationship-label": "org.onap.relationships.inventory.Uses",
                            "related-link": "/aai/v14/business/customers/customer/Demonstration/service-subscriptions/service-subscription/vLB",
                            "relationship-data": [
                                {
                                    "relationship-key": "customer.global-customer-id",
                                    "relationship-value": "Demonstration"
                                },
                                {
                                    "relationship-key": "service-subscription.service-type",
                                    "relationship-value": "vLB"
                                }
                            ]
                        },
                        {
                            "related-to": "service-subscription",
                            "relationship-label": "org.onap.relationships.inventory.Uses",
                            "related-link": "/aai/v14/business/customers/customer/Demonstration/service-subscriptions/service-subscription/vIMS",
                            "relationship-data": [
                                {
                                    "relationship-key": "customer.global-customer-id",
                                    "relationship-value": "Demonstration"
                                },
                                {
                                    "relationship-key": "service-subscription.service-type",
                                    "relationship-value": "vIMS"
                                }
                            ]
                        }
                    ]
                }
            }'


11.  Onboard the vFW HPA template. The templates can be gotten from the `demo <https://github.com/onap/demo>`_ repo. The heat and env files used are located in demo/heat/vFW_HPA/vFW/. Create a zip file using the files. For onboarding instructions see steps 4 to 9 of `vFWCL instantiation, testing and debugging <https://wiki.onap.org/display/DW/vFWCL+instantiation%2C+testing%2C+and+debuging>`_. Note that in step 5, only one VSP is created. For the VSP the option to submit for testing in step 5cii was not shown. So you can check in and certify the VSP and proceed to step 6.

12. Get the parameters (model info, model invarant id...etc) required to create a service instance via rest. This can be done by creating a service instance via VID as in step 10 of `vFWCL instantiation, testing and debugging <https://wiki.onap.org/display/DW/vFWCL+instantiation%2C+testing%2C+and+debuging>`_.  After creating the service instance, exec into the SO bpmn pod and look into the /app/logs/bpmn/debug.log file. Search for the service instance and look for its request details. Then populate the parameters required to create a service instance via rest in step 13 below.

13. Create a service instance rest request but do not create service instance yet. Specify OOF as the homing solution and multicloud as the orchestrator. Be sure to use a service instance name that does not exist and populate the parameters with values gotten from step 12.

::

    curl -k -X POST \
    http://{{k8s}}:30277/onap/so/infra/serviceInstances/v6 \
    -H 'authorization: Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA== \
    -H 'content-type: application/json' \

    -d '{

        "requestDetails":{

            "modelInfo":{

                "modelInvariantId":"b7564cb9-4074-4c9b-95d6-39d4191e80d9",

                "modelType":"service",

                "modelName":"vfw_HPA",

                "modelVersion":"1.0",

                "modelVersionId":"35d184e8-1cba-46e3-9311-a17ace766eb0",

                "modelUuid":"35d184e8-1cba-46e3-9311-a17ace766eb0",

                "modelInvariantUuid":"b7564cb9-4074-4c9b-95d6-39d4191e80d9"

            },

            "requestInfo":{

                "source":"VID",

                "instanceName":"oof-12-homing",

                "suppressRollback":false,

                "requestorId":"demo"

            },

            "subscriberInfo":{

                "globalSubscriberId":"Demonstration"

            },

            "requestParameters":{

                "subscriptionServiceType":"vFW",

                "aLaCarte":true,

                "testApi":"VNF_API",

                "userParams":[

                    {

                        "name":"Customer_Location",

                        "value":{

                            "customerLatitude":"32.897480",

                            "customerLongitude":"97.040443",

                            "customerName":"some_company"

                        }

                    },

                    {

                        "name":"Homing_Solution",

                        "value":"oof"

                    },

                    {

                        "name":"orchestrator",

                        "value":"multicloud"

                    }

                ]

            },

            "project":{

                "projectName":"Project-Demonstration"

            },

            "owningEntity":{

                "owningEntityId":"e1564fc9-b9d0-44f9-b5af-953b4aad2f40",

                "owningEntityName":"OE-Demonstration"

            }

        }

    }'

14. Get the resourceModuleName to be used for creating policies. This can be gotten from the CSAR file of the service model created. However, an easy way to get the resourceModuleName is to send the service instance create request in step 13 above. This will fail as there are no policies but you can then go into the bpmn debug.log file and get its value by searching for resourcemodulename.

15. Create policies. For instructions to do this, look in **method 2 (Manual upload)** of `OOF - HPA guide for integration testing <https://wiki.onap.org/display/DW/OOF+-+HPA+guide+for+integration+testing>`_. Put in the correct resouceModuleName. This is located in the resources section of the rest request. For example the resourceModuleName in the distance policy is 7400fd06C75f4a44A68f.

16. Do a get to verify all the polcies have been put in correctly. This can be done by doing an exec into the policy-pdp pod and running the following curl command.

::

    curl -k -v -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'ClientAuth: cHl0aG9uOnRlc3Q=' -H 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' -H 'Environment: TEST' -X POST -d '{"policyName": "OSDF_CASABLANCA.*", "configAttributes": {"policyScope": "us"}}' 'https://pdp:8081/pdp/api/getConfig' | python -m json.tool

To Update a policy, use the following curl command. Modify the policy as required

::

    curl -k -v  -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
        "configBody": "{\"service\":\"hpaPolicy\",\"guard\":\"False\",\"content\":{\"flavorFeatures\":[{\"directives\":[{\"attributes\":[{\"attribute_value\":\"\",\"attribute_name\":\"firewall_flavor_name\"}],\"type\":\"flavor_directives\"}],\"type\":\"vnfc\",\"flavorProperties\":[{\"mandatory\":\"True\",\"hpa-feature-attributes\":[{\"hpa-attribute-value\":\"2\",\"unit\":\"\",\"operator\":\"=\",\"hpa-attribute-key\":\"numVirtualCpu\"},{\"hpa-attribute-value\":\"8\",\"unit\":\"MB\",\"operator\":\"=\",\"hpa-attribute-key\":\"virtualMemSize\"}],\"directives\":[],\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"hpa-feature\":\"basicCapabilities\"},{\"mandatory\":\"True\",\"hpa-feature-attributes\":[{\"hpa-attribute-value\":\"2\",\"unit\":\"MB\",\"operator\":\"=\",\"hpa-attribute-key\":\"memoryPageSize\"}],\"directives\":[],\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"hpa-feature\":\"hugePages\"},{\"hpa-feature\":\"localStorage\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"True\",\"directives\":[],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"diskSize\",\"hpa-attribute-value\":\"10\",\"operator\":\">=\",\"unit\":\"GB\"}]},{\"mandatory\":\"False\",\"score\":\"100\",\"directives\":[],\"hpa-version\":\"v1\",\"hpa-feature-attributes\":[{\"hpa-attribute-value\":\"1\",\"unit\":\"\",\"operator\":\"=\",\"hpa-attribute-key\":\"pciCount\"},{\"hpa-attribute-value\":\"8086\",\"unit\":\"\",\"operator\":\"=\",\"hpa-attribute-key\":\"pciVendorId\"},{\"hpa-attribute-value\":\"37c9\",\"unit\":\"\",\"operator\":\"=\",\"hpa-attribute-key\":\"pciDeviceId\"}],\"architecture\":\"vf\",\"hpa-feature\":\"pciePassthrough\"}],\"id\":\"vfw\"},{\"directives\":[{\"attributes\":[{\"attribute_value\":\"\",\"attribute_name\":\"packetgen_flavor_name\"}],\"type\":\"flavor_directives\"}],\"type\":\"vnfc\",\"flavorProperties\":[{\"mandatory\":\"True\",\"hpa-feature-attributes\":[{\"hpa-attribute-value\":\"1\",\"operator\":\">=\",\"hpa-attribute-key\":\"numVirtualCpu\"},{\"hpa-attribute-value\":\"7\",\"unit\":\"GB\",\"operator\":\">=\",\"hpa-attribute-key\":\"virtualMemSize\"}],\"directives\":[],\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"hpa-feature\":\"basicCapabilities\"},{\"hpa-feature\":\"localStorage\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"True\",\"directives\":[],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"diskSize\",\"hpa-attribute-value\":\"10\",\"operator\":\">=\",\"unit\":\"GB\"}]}],\"id\":\"vgenerator\"},{\"directives\":[{\"attributes\":[{\"attribute_value\":\"\",\"attribute_name\":\"sink_flavor_name\"}],\"type\":\"flavor_directives\"}],\"id\":\"vsink\",\"type\":\"vnfc\",\"flavorProperties\":[{\"mandatory\":\"True\",\"directives\":[],\"hpa-version\":\"v1\",\"hpa-feature-attributes\":[],\"architecture\":\"generic\",\"hpa-feature\":\"basicCapabilities\"}]}],\"policyType\":\"hpa\",\"policyScope\":[\"vfw\",\"us\",\"international\",\"ip\"],\"identity\":\"hpa-vFW\",\"resources\":[\"vFW\",\"A5ece5a02e86450391d6\"]},\"priority\":\"3\",\"templateVersion\":\"OpenSource.version.1\",\"riskLevel\":\"2\",\"description\":\"HPApolicyforvFW\",\"policyName\":\"OSDF_CASABLANCA.hpa_policy_vFW_1\",\"version\":\"test1\",\"riskType\":\"test\"}",
        "policyName": "OSDF_CASABLANCA.hpa_policy_vFW_1",
        "policyConfigType": "MicroService",
        "onapName": "SampleDemo",
        "policyScope": "OSDF_CASABLANCA"
    }' 'https://pdp:8081/pdp/api/updatePolicy'


To delete a policy, use two commands below to delete from PDP and PAP

**DELETE POLICY INSIDE PDP**

::

    curl -k -v -H 'Content-Type: application/json' \
     -H 'Accept: application/json' \
     -H 'ClientAuth: cHl0aG9uOnRlc3Q=' \
     -H 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' \
     -H 'Environment: TEST' \
     -X DELETE \
     -d '{"policyName": "OSDF_CASABLANCA.Config_MS_vnfPolicy_vFWHPA.1.xml","policyComponent":"PDP","policyType":"MicroService","pdpGroup":"default"}' https://pdp:8081/pdp/api/deletePolicy


**DELETE POLICY INSIDE PAP**

::

    curl -k -v -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -H 'ClientAuth: cHl0aG9uOnRlc3Q=' \
    -H 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' \
    -H 'Environment: TEST' \
    -X DELETE \
    -d '{"policyName": "OSDF_CASABLANCA.Config_MS_vnfPolicy_vFWHPA.1.xml","policyComponent":"PAP","policyType":"Optimization","deleteCondition":"ALL"}' https://pdp:8081/pdp/api/deletePolicy

Below are the 3 HPA policies for test cases in the `test plan <https://wiki.onap.org/pages/viewpage.action?pageId=41421112>`_

**Test 1 (Basic)**

Create Policy

::

    curl -k -v  -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
        "configBody": "{\"service\":\"hpaPolicy\",\"guard\":\"False\",\"content\":{\"flavorFeatures\":[{\"directives\":[{\"attributes\":[{\"attribute_value\":\"\",\"attribute_name\":\"firewall_flavor_name\"}],\"type\":\"flavor_directives\"}],\"type\":\"vnfc\",\"flavorProperties\":[{\"mandatory\":\"True\",\"hpa-feature-attributes\":[{\"hpa-attribute-value\":\"2\",\"unit\":\"\",\"operator\":\"=\",\"hpa-attribute-key\":\"numVirtualCpu\"},{\"hpa-attribute-value\":\"8\",\"unit\":\"MB\",\"operator\":\"=\",\"hpa-attribute-key\":\"virtualMemSize\"}],\"directives\":[],\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"hpa-feature\":\"basicCapabilities\"},{\"mandatory\":\"True\",\"hpa-feature-attributes\":[{\"hpa-attribute-value\":\"2\",\"unit\":\"MB\",\"operator\":\"=\",\"hpa-attribute-key\":\"memoryPageSize\"}],\"directives\":[],\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"hpa-feature\":\"hugePages\"},{\"hpa-feature\":\"localStorage\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"True\",\"directives\":[],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"diskSize\",\"hpa-attribute-value\":\"10\",\"operator\":\">=\",\"unit\":\"GB\"}]},{\"mandatory\":\"False\",\"score\":\"100\",\"directives\":[],\"hpa-version\":\"v1\",\"hpa-feature-attributes\":[{\"hpa-attribute-value\":\"isolate\",\"unit\":\"\",\"operator\":\"=\",\"hpa-attribute-key\":\"logicalCpuThreadPinningPolicy\"},{\"hpa-attribute-value\":\"dedicated\",\"unit\":\"\",\"operator\":\"=\",\"hpa-attribute-key\":\"logicalCpuPinningPolicy\"}],\"architecture\":\"generic\",\"hpa-feature\":\"cpuPinning\"}],\"id\":\"vfw\"},{\"directives\":[{\"attributes\":[{\"attribute_value\":\"\",\"attribute_name\":\"packetgen_flavor_name\"}],\"type\":\"flavor_directives\"}],\"type\":\"vnfc\",\"flavorProperties\":[{\"mandatory\":\"True\",\"hpa-feature-attributes\":[{\"hpa-attribute-value\":\"1\",\"operator\":\">=\",\"hpa-attribute-key\":\"numVirtualCpu\"},{\"hpa-attribute-value\":\"7\",\"unit\":\"GB\",\"operator\":\">=\",\"hpa-attribute-key\":\"virtualMemSize\"}],\"directives\":[],\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"hpa-feature\":\"basicCapabilities\"},{\"hpa-feature\":\"localStorage\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"True\",\"directives\":[],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"diskSize\",\"hpa-attribute-value\":\"10\",\"operator\":\">=\",\"unit\":\"GB\"}]}],\"id\":\"vgenerator\"},{\"directives\":[{\"attributes\":[{\"attribute_value\":\"\",\"attribute_name\":\"sink_flavor_name\"}],\"type\":\"flavor_directives\"}],\"id\":\"vsink\",\"type\":\"vnfc\",\"flavorProperties\":[{\"mandatory\":\"True\",\"directives\":[],\"hpa-version\":\"v1\",\"hpa-feature-attributes\":[],\"architecture\":\"generic\",\"hpa-feature\":\"basicCapabilities\"}]}],\"policyType\":\"hpa\",\"policyScope\":[\"vfw\",\"us\",\"international\",\"ip\"],\"identity\":\"hpa-vFW\",\"resources\":[\"vFW\",\"VfwHpa\"]},\"priority\":\"3\",\"templateVersion\":\"OpenSource.version.1\",\"riskLevel\":\"2\",\"description\":\"HPApolicyforvFW\",\"policyName\":\"OSDF_CASABLANCA.hpa_policy_vFWHPA_1\",\"version\":\"test1\",\"riskType\":\"test\"}",
        "policyName": "OSDF_CASABLANCA.hpa_policy_vFWHPA_1",
        "policyConfigType": "MicroService",
        "onapName": "SampleDemo",
        "policyScope": "OSDF_CASABLANCA"
    }' 'https://pdp:8081/pdp/api/createPolicy'


Push Policy

::

        curl -k -v  -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
        "pdpGroup": "default",
        "policyName": "OSDF_CASABLANCA.hpa_policy_vFWHPA_1",
        "policyType": "MicroService"
        }' 'https://pdp:8081/pdp/api/pushPolicy'




**Test 2:  (to test SRIOV-NIC feature) (to ensure that right cloud-region is selected based on score)**

Create Policy

::

    curl -k -v  -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
    "configBody": "{\"service\":\"hpaPolicy\",\"guard\":\"False\",\"content\":{\"flavorFeatures\":[{\"id\":\"vfw\",\"type\":\"vnfc\",\"directives\":[{\"type\":\"flavor_directives\",\"attributes\":[{\"attribute_name\":\"firewall_flavor_name\",\"attribute_value\":\"\"}]}],\"flavorProperties\":[{\"hpa-feature\":\"sriovNICNetwork\",\"hpa-version\":\"v1\",\"architecture\":\"intel\",\"mandatory\":\"True\",\"directives\":[{\"type\":\"sriovNICNetwork_directives\",\"attributes\":[{\"attribute_name\":\"vfw_private_0_port_vnic_type\",\"attribute_value\":\"direct\"}]}],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"pciCount\",\"hpa-attribute-value\":\"1\",\"operator\":\"=\"},{\"hpa-attribute-key\":\"pciVendorId\",\"hpa-attribute-value\":\"8086\",\"operator\":\"=\"},{\"hpa-attribute-key\":\"pciDeviceId\",\"hpa-attribute-value\":\"154C\",\"operator\":\"=\"},{\"hpa-attribute-key\":\"physicalNetwork\",\"hpa-attribute-value\":\"private-1\",\"operator\":\"=\"}]}]},{\"id\":\"vgenerator\",\"type\":\"vnfc\",\"directives\":[{\"type\":\"flavor_directives\",\"attributes\":[{\"attribute_name\":\"packetgen_flavor_name\",\"attribute_value\":\"\"}]}],\"flavorProperties\":[{\"hpa-feature\":\"sriovNICNetwork\",\"hpa-version\":\"v1\",\"architecture\":\"intel\",\"mandatory\":\"True\",\"directives\":[{\"type\":\"sriovNICNetwork_directives\",\"attributes\":[{\"attribute_name\":\"vpg_private_0_port_vnic_type\",\"attribute_value\":\"direct\"}]}],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"pciCount\",\"hpa-attribute-value\":\"3\",\"operator\":\"=\",\"unit\":\"\"},{\"hpa-attribute-key\":\"pciVendorId\",\"hpa-attribute-value\":\"8086\",\"operator\":\"=\",\"unit\":\"\"},{\"hpa-attribute-key\":\"pciDeviceId\",\"hpa-attribute-value\":\"154C\",\"operator\":\"=\",\"unit\":\"\"},{\"hpa-attribute-key\":\"physicalNetwork\",\"hpa-attribute-value\":\"shared-1\",\"operator\":\"=\"}]}]},{\"id\":\"vsink\",\"type\":\"vnfc\",\"directives\":[{\"type\":\"flavor_directives\",\"attributes\":[{\"attribute_name\":\"sink_flavor_name\",\"attribute_value\":\"\"}]}],\"flavorProperties\":[{\"hpa-feature\":\"sriovNICNetwork\",\"hpa-version\":\"v1\",\"architecture\":\"intel\",\"mandatory\":\"True\",\"directives\":[{\"type\":\"sriovNICNetwork_directives\",\"attributes\":[{\"attribute_name\":\"vsn_private_0_port_vnic_type\",\"attribute_value\":\"direct\"}]}],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"pciCount\",\"hpa-attribute-value\":\"1\",\"operator\":\"=\",\"unit\":\"\"},{\"hpa-attribute-key\":\"pciVendorId\",\"hpa-attribute-value\":\"8086\",\"operator\":\"=\",\"unit\":\"\"},{\"hpa-attribute-key\":\"pciDeviceId\",\"hpa-attribute-value\":\"154C\",\"operator\":\"=\",\"unit\":\"\"},{\"hpa-attribute-key\":\"physicalNetwork\",\"hpa-attribute-value\":\"private-1\",\"operator\":\"=\"}]}]}],\"policyType\":\"hpa\",\"policyScope\":[\"vfw\",\"us\",\"international\",\"ip\"],\"identity\":\"hpa-vFW\",\"resources\":[\"vFW\",\"A5ece5a02e86450391d6\"]},\"priority\":\"3\",\"templateVersion\":\"OpenSource.version.1\",\"riskLevel\":\"2\",\"description\":\"HPApolicyforvFW\",\"policyName\":\"OSDF_CASABLANCA.hpa_policy_vFW_2\",\"version\":\"test1\",\"riskType\":\"test\"}",
    "policyName": "OSDF_CASABLANCA.hpa_policy_vFW_2",
    "policyConfigType": "MicroService",
    "onapName": "SampleDemo",
    "policyScope": "OSDF_CASABLANCA"
    }' 'https://pdp:8081/pdp/api/createPolicy'


Push Policy

::

            curl -k -v  -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
    "pdpGroup": "default",
    "policyName": "OSDF_CASABLANCA.hpa_policy_vFW_2",
    "policyType": "MicroService"
    }' 'https://pdp:8081/pdp/api/pushPolicy'


**Test 3 (to ensure that right cloud-region is selected based on score)**

Create Policy

::

        curl -k -v  -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
        "configBody": "{\"service\":\"hpaPolicy\",\"guard\":\"False\",\"content\":{\"flavorFeatures\":[{\"id\":\"vfw\",\"type\":\"vnfc\",\"directives\":[{\"type\":\"flavor_directives\",\"attributes\":[{\"attribute_name\":\"firewall_flavor_name\",\"attribute_value\":\"\"}]}],\"flavorProperties\":[{\"hpa-feature\":\"sriovNICNetwork\",\"hpa-version\":\"v1\",\"architecture\":\"intel\",\"mandatory\":\"False\",\"score\":\"100\",\"directives\":[{\"type\":\"sriovNICNetwork_directives\",\"attributes\":[{\"attribute_name\":\"vfw_private_0_port_vnic_type\",\"attribute_value\":\"direct\"}]}],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"pciCount\",\"hpa-attribute-value\":\"1\",\"operator\":\"=\"},{\"hpa-attribute-key\":\"pciVendorId\",\"hpa-attribute-value\":\"8086\",\"operator\":\"=\"},{\"hpa-attribute-key\":\"pciDeviceId\",\"hpa-attribute-value\":\"154C\",\"operator\":\"=\"},{\"hpa-attribute-key\":\"physicalNetwork\",\"hpa-attribute-value\":\"shared-1\",\"operator\":\"=\"}]},{\"hpa-feature\":\"localStorage\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"True\",\"directives\":[],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"diskSize\",\"hpa-attribute-value\":\"10\",\"operator\":\">=\",\"unit\":\"GB\"}]},{\"hpa-feature\":\"hugePages\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"True\",\"directives\":[],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"memoryPageSize\",\"hpa-attribute-value\":\"2\",\"operator\":\"=\",\"unit\":\"MB\"}]},{\"hpa-feature\":\"basicCapabilities\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"True\",\"directives\":[],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"numVirtualCpu\",\"hpa-attribute-value\":\"2\",\"operator\":\"=\"},{\"hpa-attribute-key\":\"virtualMemSize\",\"hpa-attribute-value\":\"8\",\"operator\":\"=\",\"unit\":\"MB\"}]}]},{\"id\":\"vgenerator\",\"type\":\"vnfc\",\"directives\":[{\"type\":\"flavor_directives\",\"attributes\":[{\"attribute_name\":\"packetgen_flavor_name\",\"attribute_value\":\"\"}]}],\"flavorProperties\":[{\"hpa-feature\":\"hugePages\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"False\",\"score\":\"200\",\"directives\":[],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"memoryPageSize\",\"hpa-attribute-value\":\"1\",\"operator\":\"=\",\"unit\":\"GB\"}]},{\"hpa-feature\":\"localStorage\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"True\",\"directives\":[],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"diskSize\",\"hpa-attribute-value\":\"10\",\"operator\":\">=\",\"unit\":\"GB\"}]},{\"hpa-feature\":\"basicCapabilities\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"True\",\"directives\":[],\"hpa-feature-attributes\":[{\"hpa-attribute-key\":\"numVirtualCpu\",\"hpa-attribute-value\":\"1\",\"operator\":\">=\"},{\"hpa-attribute-key\":\"virtualMemSize\",\"hpa-attribute-value\":\"2\",\"operator\":\">=\",\"unit\":\"GB\"}]}]},{\"id\":\"vsink\",\"type\":\"vnfc\",\"directives\":[{\"type\":\"flavor_directives\",\"attributes\":[{\"attribute_name\":\"sink_flavor_name\",\"attribute_value\":\"\"}]}],\"flavorProperties\":[{\"hpa-feature\":\"basicCapabilities\",\"hpa-version\":\"v1\",\"architecture\":\"generic\",\"mandatory\":\"True\",\"directives\":[],\"hpa-feature-attributes\":[]}]}],\"policyType\":\"hpa\",\"policyScope\":[\"vfw\",\"us\",\"international\",\"ip\"],\"identity\":\"hpa-vFW\",\"resources\":[\"vFW\",\"A5ece5a02e86450391d6\"]},\"priority\":\"3\",\"templateVersion\":\"OpenSource.version.1\",\"riskLevel\":\"2\",\"description\":\"HPApolicyforvFW\",\"policyName\":\"OSDF_CASABLANCA.hpa_policy_vFW_3\",\"version\":\"test1\",\"riskType\":\"test\"}",
        "policyName": "OSDF_CASABLANCA.hpa_policy_vFW_3",
        "policyConfigType": "MicroService",
        "onapName": "SampleDemo",
        "policyScope": "OSDF_CASABLANCA"
    }' 'https://pdp:8081/pdp/api/createPolicy'

Push Policy

::

                curl -k -v  -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
    "pdpGroup": "default",
    "policyName": "OSDF_CASABLANCA.hpa_policy_vFW_3",
    "policyType": "MicroService"
    }' 'https://pdp:8081/pdp/api/pushPolicy'

17. Create Service Instance using step 13 above

18. Check bpmn logs to ensure that OOF sent homing response and flavor directives.

19. Create vnf using VID as in 10f and 10g in `vFWCL instantiation, testing and debugging <https://wiki.onap.org/display/DW/vFWCL+instantiation%2C+testing%2C+and+debuging>`_.

20. Do SDNC Preload. Instructions for this can be found in this `video <https://wiki.onap.org/display/DW/Running+the+ONAP+Demos?preview=/1015891/16010290/vFW_closed_loop.mp4>`_ (Fast forward to 3:55 in the video). The contents of my preload file are shown below;

::

    {
        "input": {
            "request-information": {
                "notification-url": "openecomp.org",
                "order-number": "1",
                "order-version": "1",
                "request-action": "PreloadVNFRequest",
                "request-id": "test"
            },
            "sdnc-request-header": {
                "svc-action": "reserve",
                "svc-notification-url": "http://openecomp.org:8080/adapters/rest/SDNCNotify",
                "svc-request-id": "test"
            },
            "vnf-topology-information": {
                "vnf-assignments": {
                    "availability-zones": [],
                    "vnf-networks": [],
                    "vnf-vms": []
                },


                "vnf-parameters": [
    			    {
                        "vnf-parameter-name": "vfw_image_name",
                        "vnf-parameter-value": "ubuntu-16.04"
                    },
    				{
                        "vnf-parameter-name": "firewall_flavor_name",
                        "vnf-parameter-value": "m1.large"
                    },
    				 {
                        "vnf-parameter-name": "sink_flavor_name",
                        "vnf-parameter-value": "m1.medium"
                    },
    				 {
                        "vnf-parameter-name": "packetgen_flavor_name",
                        "vnf-parameter-value": "m1.large"
                    },
                    {
                        "vnf-parameter-name": "public_net_id",
                        "vnf-parameter-value": "external"
                    },
    				 {
                        "vnf-parameter-name": "unprotected_private_net_id",
                        "vnf-parameter-value": "unprotected_private_net"
                    },
    				{
                        "vnf-parameter-name": "protected_private_net_id",
                        "vnf-parameter-value": "protected_private_net"
                    },
                    {
                        "vnf-parameter-name": "onap_private_net_id",
                        "vnf-parameter-value": "oam_onap_vnf_test"
                    },
                    {
                        "vnf-parameter-name": "onap_private_subnet_id",
                        "vnf-parameter-value": "oam_onap_vnf_test"
                    },
    				{
                        "vnf-parameter-name": "unprotected_private_net_cidr",
                        "vnf-parameter-value": "192.168.10.0/24"
                    },
    				{
                        "vnf-parameter-name": "protected_private_net_cidr",
                        "vnf-parameter-value": "192.168.20.0/24"
                    },
    				{
                        "vnf-parameter-name": "onap_private_net_cidr",
                        "vnf-parameter-value": "10.0.0.0/16"
                    },
    				{
                        "vnf-parameter-name": "vfw_private_ip_0",
                        "vnf-parameter-value": "192.168.10.100"
                    },
    				{
                        "vnf-parameter-name": "vfw_private_ip_1",
                        "vnf-parameter-value": "192.168.20.100"
                    },
    				{
                        "vnf-parameter-name": "vfw_private_ip_2",
                        "vnf-parameter-value": "10.0.100.1"
                    },
    				{
                        "vnf-parameter-name": "vpg_private_ip_0",
                        "vnf-parameter-value": "192.168.10.200"
                    },
    				{
                        "vnf-parameter-name": "vpg_private_ip_1",
                        "vnf-parameter-value": "10.0.100.2"
                    },
    				{
                        "vnf-parameter-name": "vsn_private_ip_0",
                        "vnf-parameter-value": "192.168.20.250"
                    },
    				{
                        "vnf-parameter-name": "vsn_private_ip_1",
                        "vnf-parameter-value": "10.0.100.3"
                    },

    				{
                        "vnf-parameter-name": "vfw_name_0",
                        "vnf-parameter-value": "vfw"
                    },
    				{
                        "vnf-parameter-name": "vpg_name_0",
                        "vnf-parameter-value": "vpktgen"
                    },
    				{
                        "vnf-parameter-name": "vsn_name_0",
                        "vnf-parameter-value": "vsink"
                    },
    				{
                        "vnf-parameter-name": "vfw_private_0_port_vnic_type",
                        "vnf-parameter-value": "normal"
                    },
    				{
                        "vnf-parameter-name": "vfw_private_1_port_vnic_type",
                        "vnf-parameter-value": "normal"
                    },
    				{
                        "vnf-parameter-name": "vfw_private_2_port_vnic_type",
                        "vnf-parameter-value": "normal"
                    },
    				{
                        "vnf-parameter-name": "vpg_private_0_port_vnic_type",
                        "vnf-parameter-value": "normal"
                    },
    				{
                        "vnf-parameter-name": "vpg_private_1_port_vnic_type",
                        "vnf-parameter-value": "normal"
                    },
    				{
                        "vnf-parameter-name": "vsn_private_0_port_vnic_type",
                        "vnf-parameter-value": "normal"
                    },
    				{
                        "vnf-parameter-name": "vsn_private_1_port_vnic_type",
                        "vnf-parameter-value": "normal"
                    },
                    {
                        "vnf-parameter-name": "vf_module_id",
                        "vnf-parameter-value": "VfwHpa..base_vfw..module-0"
                    },
                    {
                        "vnf-parameter-name": "sec_group",
                        "vnf-parameter-value": "default"
                    },
                    {
                        "vnf-parameter-name": "sdnc_model_name",
                        "vnf-parameter-value": ""
                    },
                     {
                        "vnf-parameter-name": "sdnc_model_version",
                        "vnf-parameter-value": ""
                    },
                    {
                        "vnf-parameter-name": "sdnc_artifact_name",
                        "vnf-parameter-value": ""
                    },

                    {
                        "vnf-parameter-name": "oof_directives",
                        "vnf-parameter-value": "{\"directives\": [{\"id\": \"vfw\", \"type\": \"vnfc\", \"directives\": [{\"attributes\": [{\"attribute_name\": \"firewall_flavor_name\", \"attribute_value\": \"onap.hpa.flavor31\"}, {\"attribute_name\": \"flavorId\", \"attribute_value\": \"2297339f-6a89-4808-a78f-68216091f904\"}, {\"attribute_name\": \"flavorId\", \"attribute_value\": \"2297339f-6a89-4808-a78f-68216091f904\"}, {\"attribute_name\": \"flavorId\", \"attribute_value\": \"2297339f-6a89-4808-a78f-68216091f904\"}], \"type\": \"flavor_directives\"}]}, {\"id\": \"vgenerator\", \"type\": \"vnfc\", \"directives\": [{\"attributes\": [{\"attribute_name\": \"packetgen_flavor_name\", \"attribute_value\": \"onap.hpa.flavor32\"}, {\"attribute_name\": \"flavorId\", \"attribute_value\": \"2297339f-6a89-4808-a78f-68216091f904\"}], \"type\": \"flavor_directives\"}]}, {\"id\": \"vsink\", \"type\": \"vnfc\", \"directives\": [{\"attributes\": [{\"attribute_name\": \"sink_flavor_name\", \"attribute_value\": \"onap.large\"}, {\"attribute_name\": \"flavorId\", \"attribute_value\": \"2297339f-6a89-4808-a78f-68216091f904\"}], \"type\": \"flavor_directives\"}]}]}"
                   },

                   {
                        "vnf-parameter-name": "sdnc_directives",
                        "vnf-parameter-value": "{}"
                    },

                    {
                        "vnf-parameter-name": "template_type",
                        "vnf-parameter-value": "heat"
                    }


                ],
                "vnf-topology-identifier": {
                    "generic-vnf-name": "oof-12-vnf-3",
                    "generic-vnf-type": "vfw_hpa 0",
                    "service-type": "6b17354c-0fae-4491-b62e-b41619929c54",
                    "vnf-name": "vfwhpa_stack",
                    "vnf-type": "VfwHpa..base_vfw..module-0"

                }
            }
        }}


Change parameters based on your environment.

**Note**

::

    "generic-vnf-name": "oof-12-vnf-3",     <-- NAME GIVEN TO VNF
    "generic-vnf-type": "vfw_hpa 0",   <-- can be found on VNF dialog screen get the part of the VNF-TYPE after the '/'
    "service-type": "6b17354c-0fae-4491-b62e-b41619929c54",  <-- same as Service Instance ID
    "vnf-name": "vfwhpa_stack",  <-- name to be given to the vf module
    "vnf-type": "VfwHpa..base_vfw..module-0" <-- can be found on the VID - VF Module dialog screen - Model Name

21. Create vf module (11g of `vFWCL instantiation, testing and debugging <https://wiki.onap.org/display/DW/vFWCL+instantiation%2C+testing%2C+and+debuging>`_). If everything worked properly, you should see the stack created in your VIM(WR titanium cloud openstack in this case).
