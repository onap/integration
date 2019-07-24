.. _docs_scaleout:

VF Module Scale Out Use Case
----------------------------

Source files
~~~~~~~~~~~~
- Heat templates directory: https://git.onap.org/demo/tree/heat/vLB_CDS?h=dublin

Additional files
~~~~~~~~~~~~~~~~
- DCAE blueprint: https://git.onap.org/integration/tree/docs/files/scaleout/k8s-tca-clamp-policy-05162019.yaml
- TOSCA model template: https://git.onap.org/integration/tree/docs/files/scaleout/service-Vloadbalancercds-template.yml
- Naming policy script: https://git.onap.org/integration/tree/docs/files/scaleout/push_naming_policy.sh

Description
~~~~~~~~~~~
The scale out use case uses a VNF composed of three virtual functions. A traffic generator (vPacketGen), a load balancer (vLB), and a DNS (vDNS). Communication between the vPacketGen and the vLB, and the vLB and the vDNS occurs via two separate private networks. In addition, all virtual functions have an interface to the ONAP OAM private network, as shown in the topology below.

.. figure:: files/scaleout/topology.png
   :align: center

The vPacketGen issues DNS lookup queries that reach the DNS server via the vLB. vDNS replies reach the packet generator via the vLB as well. The vLB reports the average amount of traffic per vDNS instances over a given time interval (e.g. 10 seconds) to the DCAE collector via the ONAP OAM private network.

To run the use case, make sure that the security group in OpenStack has ingress/egress entries for protocol 47 (GRE). Users can test the VNF by running DNS queries from the vPakcketGen:

::

  dig @vLoadBalancer_IP host1.dnsdemo.onap.org

The output below means that the vLB has been set up correctly, has forwarded the DNS queries to a vDNS instance, and the vPacketGen has received the vDNS reply message.

::

    ; <<>> DiG 9.10.3-P4-Ubuntu <<>> @192.168.9.111 host1.dnsdemo.onap.org
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31892
    ;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2
    ;; WARNING: recursion requested but not available

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;host1.dnsdemo.onap.org.		IN	A

    ;; ANSWER SECTION:
    host1.dnsdemo.onap.org.	604800	IN	A	10.0.100.101

    ;; AUTHORITY SECTION:
    dnsdemo.onap.org.	604800	IN	NS	dnsdemo.onap.org.

    ;; ADDITIONAL SECTION:
    dnsdemo.onap.org.	604800	IN	A	10.0.100.100

    ;; Query time: 0 msec
    ;; SERVER: 192.168.9.111#53(192.168.9.111)
    ;; WHEN: Fri Nov 10 17:39:12 UTC 2017
    ;; MSG SIZE  rcvd: 97


The Scale Out Use Case
~~~~~~~~~~~~~~~~~~~~~~
The Scale Out use case shows how users/network operators can add Virtual Network Function Components (VNFCs) as part of a VF Module that has been instantiated in the Service model, in order to increase capacity of the network. ONAP Dublin release supports scale out with manual trigger by directly calling SO APIs and closed-loop-enabled automation from Policy. For Dublin, the APPC controller is used to demonstrate accepting request from SO to execute the Scale Out operation. APPC can be used to scale different VNF types, not only the VNF described in this document.


PART 1 - Service Definition and Onboarding
------------------------------------------
This use-case requires operations on several ONAP components to perform service definition and onboarding


1-1 using CDS : VNF configuration modeling and upload
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
For Dublin, the scale out use case integrates with the Controller Design Studio (CDS) ONAP component to automate the generation of cloud configuration at VNF instantiation time. Users can model this configuration at VNF design time and onboard the blueprint to CDS via the CDS GUI. The blueprint includes naming policies and network configuration details (e.g. IP address families, network names, etc.) that CDS will use during VNF instantiation to generate resource names and assign network configuration to VMs through the cloud orchestrator.

Please look at the CDS documentation for details about how to create configuration models, blueprints, and use the CDS tool: https://wiki.onap.org/display/DW/Modeling+Concepts. For running the use case, users can use the standard model package that CDS provides out of the box, which can be found here: https://wiki.onap.org/pages/viewpage.action?pageId=64007442


1-2 using SDC : VNF onboarding and Service definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Once the configuration blueprint is uploaded to CDS, users can define and onboard a service using SDC. For details about service design and creation, please refer to the SDC wiki page: https://wiki.onap.org/display/DW/Design

During the creation of the service in SDC, there are a few extra steps that need to be executed to make the VNF ready for scale out. These require users to login to the SDC Portal as service designer user (username: cs0008, password: demo123456!).

After importing the Vendor Software Package (VSP), as described in the SDC wiki page, users need to set property values in the Property Assignment window, as shown below:

.. figure:: files/scaleout/9.png
   :align: center

These properties include parameters in the Heat template (which will be overridden by CDS and then don't need to be changed) and other parameters that describe the VNF type or are used to link the service to the configuration in the CDS package.

Users can search for parameter names starting with "nf" to assign values that describe the VNF type, such as nf_type, nf_function, and nf_role. Users are free to choose the values they like. Users should also set "skip_post_instantiation" to "TRUE", as for Dublin CDS is not used for post-instantiation configuration.

.. figure:: files/scaleout/10.png
   :align: center

For CDS parameters, users can search for names starting with "sdnc". These parameters have to match the configuration blueprint in CDS. To use the standard blueprint shipped with CDS, please set the parameters as below. For further details, please refer to the CDS documentation.

.. figure:: files/scaleout/11.png
   :align: center


After importing the VSP, users need to onboard the DCAE blueprint and the Policy Model used to design closed loops in CLAMP. From the "Composition" tab in the service menu, select the artifact icon on the right, as shown below:

.. figure:: files/scaleout/1.png
   :align: center

Upload the DCAE blueprint linked at the top of the page using the pop-up window.

.. figure:: files/scaleout/2.png
   :align: center

The blueprint will appear in the artifacts section on the right.

.. figure:: files/scaleout/3.png
   :align: center

To attach a Policy Model to the service, open the Policy drop-down list on left.

.. figure:: files/scaleout/4.png
   :align: center

Then, add the TCA Policy.

.. figure:: files/scaleout/5.png
   :align: center

The Policy will be attached to the service defined in SDC

.. figure:: files/scaleout/6.png
   :align: center

Finally, users need to provide the maximum number of VNF instances that ONAP is allowed to create as part of the scale out use case by setting up deployment properties.

.. figure:: files/scaleout/7.png
   :align: center

This VNF only supports scaling the vDNS, so users should select the vDNS module from the right panel and then click the "max_vf_module_instance" link. The maximum number of VNF instances to scale can be set to an arbitrary number higher than zero.

.. figure:: files/scaleout/8.png
   :align: center

At this point, users can complete the service creation in SDC by testing, accepting, and distributing the Service Models as described in the SDC user manual.



1-3 using a shell script : deploy naming policy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In order to instantiate the VNF using CDS features, users need to deploy the naming policy that CDS uses for resource name generation to the Policy Engine. User can copy and run the script at the top of the page from any ONAP pod, for example Robot or Drools. The script uses the Policy endpoint defined in the Kubernetes domain, so the execution has to be triggered from some pod in the Kubernetes space.

::

    kubectl exec -it dev-policy-drools-0
    ./push_naming_policy.sh


1-4 using CLAMP : Closed Loop Design
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Once the service model is distributed, users can design the closed loop from CLAMP, using the GUI at https://clamp.api.simpledemo.onap.org:30258/designer/index.html

Use the "Closed Loop" link to open a distributed model.

.. figure:: files/scaleout/12.png
   :align: center

Select the closed loop associated to the distributed service model.

.. figure:: files/scaleout/13.png
   :align: center

The closed loop main page for TCA microservices is shown below.

.. figure:: files/scaleout/14.png
   :align: center

Click on the TCA box to create a configuration policy. From the pop-up window, users need to click "Add item" to create a new policy and fill it in with specific information, as shown below.

.. figure:: files/scaleout/15.png
   :align: center

For this use case, the control loop schema type is "VM", while the event name has to match the event name reported in the VNF telemetry, which is "vLoadBalancer".

Once the policy item has been created, users can define a threshold that will be used at runtime to evaluate telemetry reported by the vLB. When the specified threshold is crossed, DCAE generates an ONSET event that will tell Policy Engine which closed loop to activate.

.. figure:: files/scaleout/16.png
   :align: center

After the configuration policy is created, users need to create the operational policy, which the Policy Engine uses to determine which actions and parameters should be used during closed loop.

.. figure:: files/scaleout/17.png
   :align: center

Select "VF Module Create" recipe and "SO" actor. The payload section is:

::

    requestParameters: '{"usePreload":false,"userParams":[]}'
    configurationParameters: '[{"ip-addr":"$.vf-module-topology.vf-module-parameters.param[17].value","oam-ip-addr":"$.vf-module-topology.vf-module-parameters.param[31].value"}]'

Policy Engine passes the payload to SO, which will then use it during VF module instantiation to resolve configuration parameters. The JSON path

::

    "ip-addr":"$.vf-module-topology.vf-module-parameters.param[17].value"

indicates that resolution for parameter "ip-addr" is available at "$.vf-module-topology.vf-module-parameters.param[17].value" in the JSON object linked by the VF module self-link in AAI. For the vPacketGen/vLB/vDNS VNF, use the JSON paths provided in the example above.

The target type to select is VF module, as we are scaling a VF module. Please select the vDNS module as target resource ID.

.. figure:: files/scaleout/18.png
   :align: center

For what regards guard policies, either "Frequency Limiter", or "MinMax", or both can be used for the scale out use case. The example below shows the definition of a "Frequency Limiter" guard policy. Irrespective of the guard policy type, the policy name should be x.y.scaleout.

Once the operational policy design is completed, users can submit and then deploy the closed loop clicking the "Submit" and "Deploy" buttons, respectively, as shown below.

.. figure:: files/scaleout/20.png
   :align: center

At this point, the closed loop is deployed to Policy Engine and DCAE, and a new microservice will be deployed to the DCAE platform.


1-5 using CDT : Creating a VNF Template
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Before running scale out use case, the users need to create a VNF template using the Controller Design Tool (CDT), a design-time tool that allows users to create and on-board VNF templates into APPC. The template describes which control operation can be executed against the VNF (e.g. scale out, health check, modify configuration, etc.), the protocols that the VNF supports, port numbers, VNF APIs, and credentials for authentication. Being VNF agnostic, APPC uses these templates to "learn" about specific VNFs and the supported operations.
CDT requires two input:

1) the list of parameters that APPC will receive (ip-addr, oam-ip-addr, enabled in the example above);

2) the VNF API that APPC will use to reconfigure the VNF.

Below is an example of the parameters file (yaml format), which we call parameters.yaml:
::

    version: V1
    vnf-parameter-list:
    - name: ip-addr
      type: null
      description: null
      required: "true"
      default: null
      source: Manual
      rule-type: null
      request-keys: null
      response-keys: null
    - name: oam-ip-addr
      type: null
      description: null
      required: "true"
      default: null
      source: Manual
      rule-type: null
      request-keys: null
      response-keys: null
    - name: enabled
      type: null
      description: null
      required: "false"
      default: null
      source: Manual
      rule-type: null
      request-keys: null
      response-keys: null

Here is an example of API for the vLB VNF used for this use case. We name the file after the vnf-type contained in SDNC (i.e. Vloadbalancerms..vdns..module-3):
::

    <vlb-business-vnf-onap-plugin xmlns="urn:opendaylight:params:xml:ns:yang:vlb-business-vnf-onap-plugin">
        <vdns-instances>
            <vdns-instance>
                <ip-addr>${ip-addr}</ip-addr>
                <oam-ip-addr>${oam-ip-addr}</oam-ip-addr>
                <enabled>true</enabled>
            </vdns-instance>
        </vdns-instances>
    </vlb-business-vnf-onap-plugin>

To create the VNF template in CDT, the following steps are required:

- Connect to the CDT GUI: http://ANY-K8S-IP:30289
- Click "My VNF" Tab. Create your user ID, if necessary
- Click "Create new VNF" entering the VNF type as reported in VID or AAI, e.g. vLoadBalancerMS/vLoadBalancerMS 0
- Select "ConfigScaleOut" action
- Create a new template identifier using the VNF type name in service model as template name, e.g. Vloadbalancerms..vdns..module-3
- Select protocol (Netconf-XML), VNF username (admin), and VNF port number (2831 for NETCONF)
- Click "Parameter Definition" Tab and upload the parameters (.yaml) file
- Click "Template Tab" and upload API template (.yaml) file
- Click "Reference Data" Tab
- Click "Save All to APPC"

For health check operation, we just need to specify the protocol, the port number and username of the VNF (REST, 8183, and "admin" respectively, in the case of vLB/vDNS) and the API. For the vLB/vDNS, the API is:
::

  restconf/operational/health-vnf-onap-plugin:health-vnf-onap-plugin-state/health-check

Note that we don't need to create a VNF template for health check, so the "Template" flag can be set to "N". Again, the user has to click "Save All to APPC" to update the APPC database.
At this time, CDT doesn't allow users to provide VNF password from the GUI. To update the VNF password we need to log into the APPC Maria DB container and change the password manually:
::

  mysql -u sdnctl -p (type "gamma" when password is prompted)
  use sdnctl;
  UPDATE DEVICE_AUTHENTICATION SET PASSWORD='admin' WHERE
  VNF_TYPE='vLoadBalancerMS/vLoadBalancerMS 0'; (use your VNF type)


1-6 using SO : Setting the Controller Type in SO Database
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Users need to specify which controller to use for the scale out use case. For Dublin, the supported controller is APPC. Users need to create an association between the controller and the VNF type in the SO database.

To do so:

- Connect to one of the replicas of the MariaDB database
- Type

::

    mysql -ucataloguser -pcatalog123

- Use catalogdb databalse

::

    use catalogdb;

- Create an association between APPC and the VNF type, for example:

::

    INSERT INTO controller_selection_reference (`VNF_TYPE`, `CONTROLLER_NAME`, `ACTION_CATEGORY`) VALUES ('<VNF Type>', 'APPC', 'ConfigScaleOut');
    INSERT INTO controller_selection_reference (`VNF_TYPE`, `CONTROLLER_NAME`, `ACTION_CATEGORY`) VALUES ('<VNF Type>', 'APPC', 'HealthCheck');

SO has a default entry for VNF type "vLoadBalancerMS/vLoadBalancerMS 0"




PART 2 - Scale-out use-case Instantiation
-----------------------------------------

GET information from SDC catalogdb

::

  curl -X GET \
    'https://{{k8s}}:30204/sdc/v1/catalog/services' \
    -H 'Authorization: Basic dmlkOktwOGJKNFNYc3pNMFdYbGhhazNlSGxjc2UyZ0F3ODR2YW9HR21KdlV5MlU=' \
    -H 'X-ECOMP-InstanceID: VID' \
    -H 'cache-control: no-cache'


In the response you should find values for:

* service-uuid
* service-invariantUUID
* service-name


GET informations from SO catalogdb

::

  curl -X GET \
    'http://{{k8s}}:30744/ecomp/mso/catalog/v2/serviceVnfs?serviceModelName={{service-name}}' \
    -H 'Authorization: Basic YnBlbDpwYXNzd29yZDEk' \
    -H 'cache-control: no-cache'


In the response you should find values for:

* vnf-modelinfo-modelname
* vnf-modelinfo-modeluuid
* vnf-modelinfo-modelinvariantuuid
* vnf-modelinfo-modelcustomizationuuid
* vnf-modelinfo-modelinstancename
* vnf-vfmodule-0-modelinfo-modelname
* vnf-vfmodule-0-modelinfo-modeluuid
* vnf-vfmodule-0-modelinfo-modelinvariantuuid
* vnf-vfmodule-0-modelinfo-modelcustomizationuuid
* vnf-vfmodule-1-modelinfo-modelname
* vnf-vfmodule-1-modelinfo-modeluuid
* vnf-vfmodule-1-modelinfo-modelinvariantuuid
* vnf-vfmodule-1-modelinfo-modelcustomizationuuid
* vnf-vfmodule-2-modelinfo-modelname
* vnf-vfmodule-2-modelinfo-modeluuid
* vnf-vfmodule-2-modelinfo-modelinvariantuuid
* vnf-vfmodule-2-modelinfo-modelcustomizationuuid
* vnf-vfmodule-3-modelinfo-modelname
* vnf-vfmodule-3-modelinfo-modeluuid
* vnf-vfmodule-3-modelinfo-modelinvariantuuid
* vnf-vfmodule-3-modelinfo-modelcustomizationuuid


Note : all those informations are also available in the TOSCA service template in the SDC

You need after:

* a SSH public key value that will allow you then to connect to the VM.
* the cloudSite name and TenantId where to deploy the service
* the name of the security group that will be used in the tenant for your service
* the name of the network that will be used to connect your VM
* the name of your Openstack image
* the name of yout Openstack VM flavor

We supposed here that we are using some already declared informations:

* customer named "Demonstration"
* subscriptionServiceType named "vLB"
* projectName named "Project-Demonstration"
* owningEntityName named "OE-Demonstration"
* platformName named "test"
* lineOfBusinessName named "someValue"

Having all those information, you are now able to build the SO request
that will instantiate Service, VNF, VF modules and Heat stacks:

::

  curl -X POST \
  'http://{{k8s}}:30277/onap/so/infra/serviceInstantiation/v7/serviceInstances' \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
  "requestDetails": {
    "subscriberInfo": {
      "globalSubscriberId": "Demonstration"
    },
    "requestInfo": {
      "suppressRollback": false,
      "productFamilyId": "a9a77d5a-123e-4ca2-9eb9-0b015d2ee0fb",
      "requestorId": "adt",
      "instanceName": "{{cds-instance-name}}",
      "source": "VID"
    },
    "cloudConfiguration": {
      "lcpCloudRegionId": "{{CloudSite-name}}",
      "tenantId": "{{tenantId}}"
    },
    "requestParameters": {
      "subscriptionServiceType": "vLB",
      "userParams": [
        {
          "Homing_Solution": "none"
        },
        {
          "service": {
            "instanceParams": [

            ],
            "instanceName": "{{cds-instance-name}}",
            "resources": {
              "vnfs": [
                {
                  "modelInfo": {
                "modelName": "{{vnf-modelinfo-modelname}}",
                "modelVersionId": "{{vnf-modelinfo-modeluuid}}",
                "modelInvariantUuid": "{{vnf-modelinfo-modelinvariantuuid}}",
                "modelVersion": "1.0",
                "modelCustomizationId": "{{vnf-modelinfo-modelcustomizationuuid}}",
                "modelInstanceName": "{{vnf-modelinfo-modelinstancename}}"
                  },
                  "cloudConfiguration": {
                    "lcpCloudRegionId": "{{CloudSite-name}}",
                    "tenantId": "{{tenantId}}"
                  },
                  "platform": {
                    "platformName": "test"
                  },
                  "lineOfBusiness": {
                    "lineOfBusinessName": "someValue"
                  },
                  "productFamilyId": "a9a77d5a-123e-4ca2-9eb9-0b015d2ee0fb",
                  "instanceName": "{{vnf-modelinfo-modelinstancename}}",
                  "instanceParams": [
                    {
                      "onap_private_net_id": "olc-private",
                      "onap_private_subnet_id": "olc-private",
                      "pub_key": "{{Your SSH public key value}}",
                      "image_name": "{{my_image_name}}",
                      "flavor_name":"{{my_VM_flavor_name}}"
                    }
                  ],
                  "vfModules": [
                    {
                      "modelInfo": {
                        "modelName": "{{vnf-vfmodule-0-modelinfo-modelname}}",
                        "modelVersionId": "{{vnf-vfmodule-0-modelinfo-modeluuid}}",
                        "modelInvariantUuid": "{{vnf-vfmodule-0-modelinfo-modelinvariantuuid}}",
                        "modelVersion": "1",
                        "modelCustomizationId": "{{vnf-vfmodule-0-modelinfo-modelcustomizationuuid}}"
                       },
                      "instanceName": "{{vnf-vfmodule-0-modelinfo-modelname}}",
                      "instanceParams": [
                                                 {
                          "sec_group": "{{your_security_group_name}}",
                          "public_net_id": "{{your_public_network_name}}"
                        }
                      ]
                    },
                    {
                      "modelInfo": {
                        "modelName": "{{vnf-vfmodule-1-modelinfo-modelname}}",
                        "modelVersionId": "{{vnf-vfmodule-1-modelinfo-modeluuid}}",
                        "modelInvariantUuid": "{{vnf-vfmodule-1-modelinfo-modelinvariantuuid}}",
                        "modelVersion": "1",
                        "modelCustomizationId": "{{vnf-vfmodule-1-modelinfo-modelcustomizationuuid}}"
                       },
                      "instanceName": "{{vnf-vfmodule-1-modelinfo-modelname}}",
                      "instanceParams": [
                        {
                          "sec_group": "{{your_security_group_name}}",
                          "public_net_id": "{{your_public_network_name}}"
                        }
                      ]
                    },
                    {
                      "modelInfo": {
                        "modelName": "{{vnf-vfmodule-2-modelinfo-modelname}}",
                        "modelVersionId": "{{vnf-vfmodule-2-modelinfo-modeluuid}}",
                        "modelInvariantUuid": "{{vnf-vfmodule-2-modelinfo-modelinvariantuuid}}",
                        "modelVersion": "1",
                        "modelCustomizationId": "{{vnf-vfmodule-2-modelinfo-modelcustomizationuuid}}"
                       },
                      "instanceName": "{{vnf-vfmodule-2-modelinfo-modelname}}",
                      "instanceParams": [
                        {
                          "sec_group": "{{your_security_group_name}}",
                          "public_net_id": "{{your_public_network_name}}"
                        }
                      ]
                    },
                    {
                      "modelInfo": {
                        "modelName": "{{vnf-vfmodule-3-modelinfo-modelname}}",
                        "modelVersionId": "{{vnf-vfmodule-3-modelinfo-modeluuid}}",
                        "modelInvariantUuid": "{{vnf-vfmodule-3-modelinfo-modelinvariantuuid}}",
                        "modelVersion": "1",
                        "modelCustomizationId": "{{vnf-vfmodule-3-modelinfo-modelcustomizationuuid}}"
                      },
                      "instanceName": "{{vnf-vfmodule-3-modelinfo-modelname}}",
                      "instanceParams": [
                        {
                          "sec_group": "{{your_security_group_name}}",
                          "public_net_id": "{{your_public_network_name}}"
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            "modelInfo": {
              "modelVersion": "1.0",
        "modelVersionId": "{{service-uuid}}",
        "modelInvariantId": "{{service-invariantUUID}}",
        "modelName": "{{service-name}}",
              "modelType": "service"
            }
          }
        }
      ],
      "aLaCarte": false
    },
    "project": {
      "projectName": "Project-Demonstration"
    },
    "owningEntity": {
      "owningEntityId": "24ef5425-bec4-4fa3-ab03-c0ecf4eaac96",
      "owningEntityName": "OE-Demonstration"
    },
    "modelInfo": {
      "modelVersion": "1.0",
        "modelVersionId": "{{service-uuid}}",
        "modelInvariantId": "{{service-invariantUUID}}",
        "modelName": "{{service-name}}",
     "modelType": "service"
    }
  }
  }'


In the response, you will obtain a requestId that will be usefull
to follow the instantiation request status in the ONAP SO:


::

  curl -X GET \
    'http://{{k8s}}:30086/infraActiveRequests/{{requestid}}' \
    -H 'cache-control: no-cache'





PART 3 - post_instantiation
---------------------------

3-1 using the VNF : vLB manual configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
After the VNF has been instantiated using the CDS configuration blueprint, user should manually configure the vLB to open a connection towards the vDNS. At this time, the use case doesn't support automated post-instantiation configuration with CDS. Note that this step is NOT required during scale out operations, as VNF reconfiguration will be triggered by SO and executed by APPC. To change the state of the vLB, the users can run the following REST call, replacing the IP addresses in the VNF endpoint and JSON object to match the private IP addresses of their vDNS instance:

::

  curl -X PUT \
  http://10.12.5.78:8183/restconf/config/vlb-business-vnf-onap-plugin:vlb-business-vnf-onap-plugin/vdns-instances/vdns-instance/192.168.10.59 \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: a708b064-adb1-4804-89a7-ee604f5fe76f' \
  -H 'cache-control: no-cache' \
  -d '{
    "vdns-instance": [
        {
            "ip-addr": "192.168.10.59",
            "oam-ip-addr": "10.0.101.49",
            "enabled": true
        }
    ]}'

At this point, the VNF is fully set up.


3-2 using AAI : update AAI inventory with VNF resources
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
To allow automated scale out via closed loop, the users need to inventory the VNF resources in AAI. This is done by running the heatbridge python script in /root/oom/kubernetes/robot in the Rancher VM in the Kubernetes cluster:

::

    ./demo-k8s.ete onap heatbridge <vLB stack_name in OpenStack> <service_instance_id> vLB vlb_onap_private_ip_0

Heatbridge is needed for control loops because DCAE and Policy runs queries against AAI using vServer names as key.


PART 4 - running a manual Scale Out
-----------------------------------

4- 1 using SO : manually triggering scale-out
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
For scale out with manual trigger, VID is not supported at this time. Users can run the use case by directly calling SO APIs:

::

  curl -X POST \
  http://10.12.5.86:30277/onap/so/infra/serviceInstantiation/v7/serviceInstances/7d3ca782-c486-44b3-9fe5-39f322d8ee80/vnfs/9d33cf2d-d6aa-4b9e-a311-460a6be5a7de/vfModules/scaleOut \
  -H 'Accept: application/json' \
  -H 'Authorization: Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
  -H 'Host: 10.12.5.86:30277' \
  -H 'Postman-Token: 12f2601a-4eb2-402c-a51a-f29502359501,9befda68-b2c9-4e7a-90ca-1be9c24ef664' \
  -H 'User-Agent: PostmanRuntime/7.15.0' \
  -H 'accept-encoding: gzip, deflate' \
  -H 'cache-control: no-cache' \
  -H 'content-length: 2422' \
  -H 'cookie: JSESSIONID=B3BA24216367F9D39E3DF5E8CBA4BC64' \
  -b JSESSIONID=B3BA24216367F9D39E3DF5E8CBA4BC64 \
  -d '{
    "requestDetails": {
        "modelInfo": {
            "modelCustomizationName": "VdnsloadbalancerCds..vdns..module-3",
            "modelCustomizationId": "ec2f6466-a786-41f9-98f3-86506ceb57aa",
            "modelInvariantId": "8e134fbd-d6fe-4b0a-b4da-286c69dfed2f",
            "modelVersionId": "297c4829-a412-4db2-bcf4-8f8ab8890772",
            "modelName": "VdnsloadbalancerCds..vdns..module-3",
            "modelType": "vfModule",
            "modelVersion": "1"
        },
        "cloudConfiguration": {
            "lcpCloudRegionId": "RegionOne",
            "tenantId": "d570c718cbc545029f40e50b75eb13df",
            "cloudOwner": "CloudOwner"
        },
        "requestInfo": {
            "instanceName": "RegionOne_ONAP-NF_20190613T023006695Z_1",
            "source": "VID",
            "suppressRollback": false,
            "requestorId": "demo"
        },
        "requestParameters": {
            "userParams": []
        },
        "relatedInstanceList": [
            {
                "relatedInstance": {
                    "instanceId": "7d3ca782-c486-44b3-9fe5-39f322d8ee80",
                    "modelInfo": {
                        "modelType": "service",
                        "modelInvariantId": "a158d0c9-7de4-4011-a838-f1fb8fa26be8",
                        "modelVersionId": "a68d8e71-206b-4ed7-a759-533a4473304b",
                        "modelName": "vDNSLoadBalancerService_CDS",
                        "modelVersion": "2.0"
                    }
                }
            },
            {
                "relatedInstance": {
                    "instanceId": "9d33cf2d-d6aa-4b9e-a311-460a6be5a7de",
                    "modelInfo": {
                        "modelType": "vnf",
                        "modelInvariantId": "7cc46834-962b-463a-93b8-8c88d45c4fb1",
                        "modelVersionId": "94cb4ca9-7084-4236-869f-9ba114245e41",
                        "modelName": "vDNSLOADBALANCER_CDS",
                        "modelVersion": "3.0",
                        "modelCustomizationId": "69a4ebc7-0200-435b-930a-3cb247d7a3fd"
                    }
                }
            }
        ],
        "configurationParameters": [
            {
                "ip-addr": "$.vf-module-topology.vf-module-parameters.param[17].value",
                "oam-ip-addr": "$.vf-module-topology.vf-module-parameters.param[31].value"
            }
        ]
    }}'


To fill in the JSON object, users can refer to the Service Model TOSCA template at the top of the page. The template contains all the model (invariant/version/customization) IDs of service, VNF, and VF modules that the input request to SO needs.





Test Status and Plans
---------------------
Dublin Scale Out test cases can be found here: https://wiki.onap.org/pages/viewpage.action?pageId=59966105

Known Issues and Resolutions
----------------------------
1) When running closed loop-enabled scale out, the closed loop designed in CLAMP conflicts with the default closed loop defined for the old vLB/vDNS use case

Resolution: Change TCA configuration for the old vLB/vDNS use case

- Connect to Consul: http://<ANY K8S VM IP ADDRESS>:30270 and click on "Key/Value" → "dcae-tca-analytics"
- Change "eventName" in the vLB default policy to something different, for example "vLB" instead of the default value "vLoadBalancer"
- Change "subscriberConsumerGroup" in the TCA configuration to something different, for example "OpenDCAE-c13" instead of the default value "OpenDCAE-c12"
- Click "UPDATE" to upload the new TCA configuration
