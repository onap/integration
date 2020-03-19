.. _docs_scaleout:

VF Module Scale Out Use Case
----------------------------

Source files
~~~~~~~~~~~~
- Heat templates directory: https://git.onap.org/demo/tree/heat/vLB_CDS?h=elalto

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
The Scale Out use case shows how users/network operators can add Virtual Network Function Components (VNFCs) as part of a VF Module that has been instantiated in the Service model, in order to increase capacity of the network. ONAP El Alto release supports scale out with manual trigger by directly calling SO APIs and closed-loop-enabled automation from Policy. For El Alto, the APPC controller is used to demonstrate post-scaling VNF reconfiguration operations. APPC can handle different VNF types, not only the VNF described in this document.

The figure below shows all the interactions that take place during scale out operations.

.. figure:: files/scaleout/scaleout.png
   :align: center

There are four different message flows:
  - Gray: This communication happens internally to the VNF and it is described in the section above.
  - Green: Scale out with manual trigger.
  - Red: Closed-loop enabled scale out.
  - Black: Orchestration and VNF lifecycle management (LCM) operations.

The numbers in the figure represent the sequence of steps within a given flow. Note that interactions between the components in the picture and AAI, SDNC, and DMaaP are not shown for clarity's sake.

Scale out with manual trigger (green flow) and closed-loop-enabled scale out (red flow) are mutually exclusive. When the manual trigger is used, VID directly triggers the appropriate workflow in SO (step 1 of the green flow in the figure above). See Section 4 for more details.

When closed-loop enabled scale out is used, Policy triggers the SO workflow. The closed loop starts with the vLB periodically reporting telemetry about traffic patterns to the VES collector in DCAE (step 1 of the red flow). When the amount of traffic exceeds a given threshold (which the user defines during closed loop creation in CLAMP - see Section 1-4), DCAE notifies Policy (step 2), which in turn triggers the appropriate action. For this use case, the action is contacting SO to augment resource capacity in the network (step 3).

At high level, once SO receives a call for scale out actions, it first creates a new VF module (step 1 of the black flow), then calls APPC to trigger some LCM actions (step 2). APPC runs VNF health check and configuration scale out as part of LCM actions (step 3). At this time, the VNF health check only reports the health status of the vLB, while the configuration scale out operation adds a new vDNS instance to the vLB internal state. As a result of configuration scale out, the vLB opens a connection towards the new vDNS instance.

At deeper level, the SO workflow works as depicted below:

.. figure:: files/scaleout/so-blocks.png
   :align: center

SO first contacts APPC to run VNF health check and proceeds on to the next block of the workflow only if the vLB is healthy (not shown in the previous figure for simplicity's sake). Then, SO assigns resources, instantiates, and activates the new VF module. Finally, SO calls APPC again for configuration scale out and VNF health check. The VNF health check at the end of the workflow validates that the vLB health status hasn't been negatively affected by the scale out operation.

PART 1 - Service Definition and Onboarding
------------------------------------------
This use-case requires operations on several ONAP components to perform service definition and onboarding.


1-1 VNF Configuration Modeling and Upload with CDS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Since Dublin, the scale out use case integrates with the Controller Design Studio (CDS) ONAP component to automate the generation of cloud configuration at VNF instantiation time. The user interested in running the use case only with manual preload can skip this section and start from Section 1-2. The description of the use case with manual preload is provided in Section5.

Users can model this configuration at VNF design time and onboard the blueprint to CDS via the CDS GUI. The blueprint includes naming policies and network configuration details (e.g. IP address families, network names, etc.) that CDS will use during VNF instantiation to generate resource names and assign network configuration to VMs through the cloud orchestrator.

Please look at the CDS documentation for details about how to create configuration models, blueprints, and use the CDS tool: https://wiki.onap.org/display/DW/Modeling+Concepts. For running the use case, users can use the standard model package that CDS provides out of the box, which can be found here: https://wiki.onap.org/pages/viewpage.action?pageId=64007442


1-2 VNF Onboarding and Service Creation with SDC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Once the configuration blueprint is uploaded to CDS, users can define and onboard a service using SDC. SDC requires users to onboard a VNF descriptor that contains the definition of all the resources (private networks, compute nodes, keys, etc.) with their parameters that compose a VNF. The VNF used to demonstrate the scale out use case supports Heat templates as VNF descriptor, and hence requires OpenStack as cloud layer. Users can use the Heat templates linked at the top of the page to create a zip file that can be uploaded to SDC during service creation. To create a zip file, the user must be in the same folder that contains the Heat templates and the Manifest file that describes the content of the package. To create a zip file from command line, type:
::

    zip ../vLB.zip *

For a complete description of service design and creation, please refer to the SDC wiki page: https://wiki.onap.org/display/DW/Design

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


After importing the VSP, users need to onboard the DCAE blueprint and the Policy Model used to design closed loops in CLAMP. This step is only required for users that want to run closed loop; users interested in manual scale out only can skip the remainder of the section.

From the "Composition" tab in the service menu, select the artifact icon on the right, as shown below:

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



1-3 Deploy Naming Policy
~~~~~~~~~~~~~~~~~~~~~~~~
This step is only required if CDS is used.

In order to instantiate the VNF using CDS features, users need to deploy the naming policy that CDS uses for resource name generation to the Policy Engine. User can copy and run the script at the top of the page from any ONAP pod, for example Robot or Drools. The script uses the Policy endpoint defined in the Kubernetes domain, so the execution has to be triggered from some pod in the Kubernetes space.

::

    kubectl exec -it dev-policy-drools-0
    ./push_naming_policy.sh


1-4 Closed Loop Design with CLAMP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This step is only required if closed loop is used.

Once the service model is distributed, users can design the closed loop from CLAMP, using the GUI at https://clamp.api.simpledemo.onap.org:30258/designer/index.html In El Alto, CLAMP doesn't authenticate with AAF, so users have to login using "admin" and "password" as username and password, respectively.

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

Since El Alto, CLAMP adds the "Policy Decision Entry" parameter, which has to contain the name of the root operational policy in the decision tree. For this use case, there is only one operational policy, called "vlbpolicy2" in the example above ("Policy ID" parameter). As such, "Policy Decision Entry" has to be set to "vlbpolicy2" as well. During creation of the operational policy, the user should select "VF Module Create" recipe and "SO" actor. The payload section is:

::

    requestParameters: '{"usePreload":false,"userParams":[]}'
    configurationParameters: '[{"ip-addr":"$.vf-module-topology.vf-module-parameters.param[16].value","oam-ip-addr":"$.vf-module-topology.vf-module-parameters.param[30].value"}]'

Policy Engine passes the payload to SO, which will then use it during VF module instantiation to resolve configuration parameters. The JSON path

::

    "ip-addr":"$.vf-module-topology.vf-module-parameters.param[16].value"

indicates that resolution for parameter "ip-addr" is available at "$.vf-module-topology.vf-module-parameters.param[16].value" in the JSON object linked by the VF module self-link in AAI. See section 1-7 for an example of how to determine the right path to configuration parameters.

The target tab allows users to select the target type for the closed loop. For this use case, the user should select VF module as target type, as we are scaling a VF module. Please select the vDNS module as target resource ID.

.. figure:: files/scaleout/18.png
   :align: center

For what regards guard policies, either "Frequency Limiter", or "MinMax", or both can be used for the scale out use case. The example below shows the definition of a "Frequency Limiter" guard policy. The policy name should be guard.frequency.<policy ID> for Frequency Limiter and guard.minmax.<policy ID> for MinMax, where <policy ID> is vlbpolicy2 in the example above.

.. figure:: files/scaleout/19.png
   :align: center

Once the operational policy design is completed, users can submit and then deploy the closed loop clicking the "Submit" and "Deploy" buttons, respectively, as shown below.

.. figure:: files/scaleout/20.png
   :align: center

At this point, the closed loop is deployed to Policy Engine and DCAE, and a new microservice will be deployed to the DCAE platform.


1-5 Creating a VNF Template with CDT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


1-6 Setting the Controller Type in SO Database
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


1-7 Determining VNF reconfiguration parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The post scale out VNF reconfiguration is VNF-independent but the parameters used for VNF reconfiguration depend on the specific use case. For example, the vLB-vDNS-vPacketGenerator VNF described in this documentation use the vLB as "anchor" point. The vLB maintains the state of the VNF, which, for this use case is the list of active vDNS instances. After creating a new vDNS instance, the vLB needs to know the IP addresses (of the internal private network and management network) of the new vDNS. The reconfiguration action is executed by APPC, which receives those IP addresses from SO during the scale out workflow execution. Note that different VNFs may have different reconfiguration actions. A parameter resolution is expressed as JSON path to the SDNC VF module topology parameter array. For each reconfiguration parameter, the user has to specify the array location that contains the corresponding value (IP address in the specific case). For example, the "configurationParameters" section of the input request to SO during scale out with manual trigger (see Section 4) contains the resolution path to "ip-addr" and "oam-ip-addr" parameters used by the VNF.

::

    "configurationParameters": [
            {
                "ip-addr": "$.vf-module-topology.vf-module-parameters.param[16].value",
                "oam-ip-addr": "$.vf-module-topology.vf-module-parameters.param[30].value"
            }
    ]

The same resolution path needs to be provided for the closed-loop enabled use case during the closed loop design phase in CLAMP (see Section 1-4). The reconfiguration parameters and their resolution path will be pushed to the Policy Engine during closed loop deployment. Policy will eventually push them to SO during closed loop execution.

Users can determine the correct location by querying the SDNC topology object. The URL can be obtained from AAI following these steps:

1) Retrieve the list of VNF instances in AAI using the following link:

::

    curl -k -X GET \
  https://<Any_K8S_Node_IP_Address>:30233/aai/v16/network/generic-vnfs \
  -H 'Accept: application/json' \
  -H 'Authorization: Basic QUFJOkFBSQ==' \
  -H 'Content-Type: application/json' \
  -H 'X-FromAppId: AAI' \
  -H 'X-TransactionId: get_aai_subscr'

2) From the returned JSON object, search for the generic VNF object related to the VNF of interest (for example by using the VNF name defined during VNF instantiation). Then, select the "vnf-id" value to build a request to AAI to list all the VF modules of that VNF:

::

    curl -k -X GET \
  https://<Any_K8S_Node_IP_Address>:30233/aai/v16/network/generic-vnfs/generic-vnf/0e905228-c719-489a-9bcc-4470f3254e87/vf-modules \
  -H 'Accept: application/json' \
  -H 'Authorization: Basic QUFJOkFBSQ==' \
  -H 'Content-Type: application/json' \
  -H 'X-FromAppId: AAI' \
  -H 'X-TransactionId: get_aai_subscr'

3) From the returned list of VF modules, select the "selflink" URL of the VF module type that is target of the scaling action. This object refers to an existing instance of that VF module type, which could have been created either as part of regular VNF instantiation process or scaling action. The selflink points to the topology of that VF module instance in SDNC. A new instance of this VF module type will have a topology of the same form, just different parameter values. As such, the existing topology pointed by the selflink in AAI can be used to determine the resolution path to configuration parameters for future instantiation of that VF module type.

The selflink has the following structure:

::

    restconf/config/GENERIC-RESOURCE-API:services/service/4545562a-cbe3-409a-8227-0b863f5bc34e/service-data/vnfs/vnf/0e905228-c719-489a-9bcc-4470f3254e87/vnf-data/vf-modules/vf-module/793df714-106e-40a6-a28a-746b65f9e247/vf-module-data/vf-module-topology/

The complete URL to access the VF module topology in SDNC becomes:

::

    http://<Any_K8S_Node_IP_Address>:30202/restconf/config/GENERIC-RESOURCE-API:services/service/4545562a-cbe3-409a-8227-0b863f5bc34e/service-data/vnfs/vnf/0e905228-c719-489a-9bcc-4470f3254e87/vnf-data/vf-modules/vf-module/793df714-106e-40a6-a28a-746b65f9e247/vf-module-data/vf-module-topology/

See below an example of VF module topology. It can be stored in SDNC either using CDS (see Section 2) or manual preload (see Section 5).

::

    {
    "vf-module-topology": {
        "onap-model-information": {
            "model-name": "VlbCds..vdns..module-3",
            "model-invariant-uuid": "b985f371-4c59-45f7-b53e-36f970946469",
            "model-version": "1",
            "model-customization-uuid": "613b6877-0231-4ca4-90e4-4aa3374674ef",
            "model-uuid": "739e4a32-f744-47be-9208-5dcf15772306"
        },
        "vf-module-parameters": {
            "param": [
                {
                    "name": "vfc_customization_uuid",
                    "value": "770af15f-564d-438c-ba3e-6df318c2b1fe",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "key_name",
                    "value": "${key_name}",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vdns_flavor_name",
                    "value": "m1.medium",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "cloud_env",
                    "value": "openstack",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vnfc-model-customization-uuid",
                    "value": "770af15f-564d-438c-ba3e-6df318c2b1fe",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vf-module-name",
                    "value": "RegionOne_ONAP-NF_20191010T013003141Z_vdns_Expansion_003",
                    "resource-resolution-data": {
                        "capability-name": "generate-name",
                        "resource-key": [
                            {
                                "name": "VF_MODULE_LABEL",
                                "value": "vdns"
                            },
                            {
                                "name": "resource-name",
                                "value": "vf-module-name"
                            },
                            {
                                "name": "resource-value",
                                "value": "${vf-module-name}"
                            },
                            {
                                "name": "naming-type",
                                "value": "VF-MODULE"
                            },
                            {
                                "name": "VNF_NAME",
                                "value": "RegionOne_ONAP-NF_20191010T013003141Z"
                            },
                            {
                                "name": "external-key",
                                "value": "793df714-106e-40a6-a28a-746b65f9e247_vf-module-name"
                            },
                            {
                                "name": "policy-instance-name",
                                "value": "SDNC_Policy.Config_MS_ONAP_VNF_NAMING_TIMESTAMP"
                            },
                            {
                                "name": "VF_MODULE_TYPE",
                                "value": "Expansion"
                            }
                        ],
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vnfc-model-version",
                    "value": "1.0",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "pktgen_private_net_cidr",
                    "value": "${pktgen_private_net_cidr}",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vnf_model_customization_uuid",
                    "value": "c7be2fca-9a5c-4364-8c32-801e64f90ccd",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "service-instance-id",
                    "value": "4545562a-cbe3-409a-8227-0b863f5bc34e",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vlb_private_net_cidr",
                    "value": "192.168.10.0/24",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "install_script_version",
                    "value": "1.5.0-SNAPSHOT",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vlb_int_private_ip_0",
                    "value": "192.168.10.50",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vnfc-model-invariant-uuid",
                    "value": "49e70b6f-87e7-4f68-b1ec-958e68c7cbf5",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "pub_key",
                    "value": "${pub_key}",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "onap_private_net_cidr",
                    "value": "10.0.0.0/8",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vdns_int_private_ip_0",
                    "value": "192.168.10.54",
                    "resource-resolution-data": {
                        "capability-name": "netbox-ip-assign",
                        "resource-key": [
                            {
                                "name": "external_key",
                                "value": "0e905228-c719-489a-9bcc-4470f3254e87-vdns_int_private_ip_0"
                            },
                            {
                                "name": "vnf-id",
                                "value": "0e905228-c719-489a-9bcc-4470f3254e87"
                            },
                            {
                                "name": "service-instance-id",
                                "value": "4545562a-cbe3-409a-8227-0b863f5bc34e"
                            },
                            {
                                "name": "prefix-id",
                                "value": "2"
                            }
                        ],
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vnf_id",
                    "value": "0e905228-c719-489a-9bcc-4470f3254e87",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "nfc-naming-code",
                    "value": "vdns",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "onap_private_subnet_id",
                    "value": "oam_network_qXyY",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vf_module_customization_uuid",
                    "value": "613b6877-0231-4ca4-90e4-4aa3374674ef",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vf_module_type",
                    "value": "Expansion",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vlb_onap_private_ip_0",
                    "value": "10.0.101.32",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vf_module_id",
                    "value": "793df714-106e-40a6-a28a-746b65f9e247",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vdns_name_0",
                    "value": "RegionOne_ONAP-NF_20191010T013003141Z_vdns_003",
                    "resource-resolution-data": {
                        "capability-name": "generate-name",
                        "resource-key": [
                            {
                                "name": "resource-name",
                                "value": "vdns_name_0"
                            },
                            {
                                "name": "resource-value",
                                "value": "${vdns_name_0}"
                            },
                            {
                                "name": "naming-type",
                                "value": "VNFC"
                            },
                            {
                                "name": "VNF_NAME",
                                "value": "RegionOne_ONAP-NF_20191010T013003141Z"
                            },
                            {
                                "name": "external-key",
                                "value": "793df714-106e-40a6-a28a-746b65f9e247_vdns_name_0"
                            },
                            {
                                "name": "policy-instance-name",
                                "value": "SDNC_Policy.Config_MS_ONAP_VNF_NAMING_TIMESTAMP"
                            },
                            {
                                "name": "NFC_NAMING_CODE",
                                "value": "vdns"
                            }
                        ],
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vm-type",
                    "value": "vdns",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vlb_int_pktgen_private_ip_0",
                    "value": "192.168.20.35",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "onap_private_net_id",
                    "value": "oam_network_qXyY",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "nb_api_version",
                    "value": "1.2.0",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vdns_image_name",
                    "value": "${image_name}",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vdns_onap_private_ip_0",
                    "value": "10.0.101.35",
                    "resource-resolution-data": {
                        "capability-name": "netbox-ip-assign",
                        "resource-key": [
                            {
                                "name": "external_key",
                                "value": "0e905228-c719-489a-9bcc-4470f3254e87-vdns_onap_private_ip_0"
                            },
                            {
                                "name": "vnf-id",
                                "value": "0e905228-c719-489a-9bcc-4470f3254e87"
                            },
                            {
                                "name": "service-instance-id",
                                "value": "4545562a-cbe3-409a-8227-0b863f5bc34e"
                            },
                            {
                                "name": "prefix-id",
                                "value": "3"
                            }
                        ],
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "aai-vf-module-put",
                    "value": "SUCCESS",
                    "resource-resolution-data": {
                        "capability-name": "aai-vf-module-put",
                        "resource-key": [
                            {
                                "name": "vf-module",
                                "value": "vf-module"
                            }
                        ],
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "aic-cloud-region",
                    "value": "${aic-cloud-region}",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "nfc-function",
                    "value": "${nf-role}",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "sec_group",
                    "value": "onap_sg_qXyY",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "vnf_name",
                    "value": "RegionOne_ONAP-NF_20191010T013003141Z",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "nexus_artifact_repo",
                    "value": "https://nexus.onap.org",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                },
                {
                    "name": "public_net_id",
                    "value": "external",
                    "resource-resolution-data": {
                        "capability-name": "RA Resolved",
                        "status": "SUCCESS"
                    }
                }
            ]
        },
        "tenant": "41d6d38489bd40b09ea8a6b6b852dcbd",
        "sdnc-generated-cloud-resources": true,
        "vf-module-topology-identifier": {
            "vf-module-id": "793df714-106e-40a6-a28a-746b65f9e247",
            "vf-module-name": "vfModuleName",
            "vf-module-type": "VlbCds..vdns..module-3"
        },
        "aic-cloud-region": "RegionOne"
    }}

Search for the reconfiguration parameters in the vf-module-topology.vf-module-parameters.param array. The user should count (starting from 0, as in most programming languages) the number of array elements to determine the exact location of the parameters of interest. For the VNF described in this documentation, the parameters of interest are "vdns_int_private_ip_0" and "vdns_onap_private_ip_0", which correspond to "ip-addr" and "onap-ip-addr" in the scale out request, respectively. As the user can see by counting the number of array locations (starting from 0), "vdns_int_private_ip_0" and "vdns_onap_private_ip_0" are stored at locations 16 and 30, respectively. As such, the complete resolution path to reconfiguration parameters for the VNF described in this documentation is:

::

    [{"ip-addr":"$.vf-module-topology.vf-module-parameters.param[16].value","oam-ip-addr":"$.vf-module-topology.vf-module-parameters.param[30].value"}]

In future releases, we plan to leverage CDS to model post scaling VNF reconfiguration, so as to remove the dependency from JSON paths and simplify the overall process.


PART 2 - Scale Out Use Case Instantiation
-----------------------------------------
This step is only required if CDS is used.

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


GET informations from SO catalogdb.

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

* the SSH public key value that will allow you to connect to the VM.
* the cloudSite name and TenantId where to deploy the service
* the name of the security group that will be used in the tenant for your service
* the name of the network that will be used to connect your VM
* the name of your OpenStack image
* the name of your OpenStack VM flavor

We supposed here that we are using some already declared informations:

* customer named "Demonstration"
* subscriptionServiceType named "vLB"
* projectName named "Project-Demonstration"
* owningEntityName named "OE-Demonstration"
* platformName named "test"
* lineOfBusinessName named "someValue"

Having all those information, you are now able to build the SO Macro request
that will instantiate Service, VNF, VF modules and Heat stacks:

::

  curl -X POST \
  'http://{{k8s}}:30277/onap/so/infra/serviceInstantiation/v7/serviceInstances' \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
   "requestDetails":{
      "subscriberInfo":{
         "globalSubscriberId":"Demonstration"
      },
      "requestInfo":{
         "suppressRollback":false,
         "productFamilyId":"a9a77d5a-123e-4ca2-9eb9-0b015d2ee0fb",
         "requestorId":"adt",
         "instanceName":"{{cds-instance-name}}",
         "source":"VID"
      },
      "cloudConfiguration":{
         "lcpCloudRegionId":"RegionOne",
         "tenantId":"41d6d38489bd40b09ea8a6b6b852dcbd",
         "cloudOwner":"CloudOwner"
      },
      "requestParameters":{
         "subscriptionServiceType":"vLB",
         "userParams":[
            {
               "Homing_Solution":"none"
            },
            {
               "service":{
                  "instanceParams":[

                  ],
                  "instanceName":"{{cds-instance-name}}",
                  "resources":{
                     "vnfs":[
                        {
                           "modelInfo":{
                              "modelName":"{{vnf-modelinfo-modelname}}",
                              "modelVersionId":"{{vnf-modelinfo-modeluuid}}",
                              "modelInvariantUuid":"{{vnf-modelinfo-modelinvariantuuid}}",
                              "modelVersion":"1.0",
                              "modelCustomizationId":"{{vnf-modelinfo-modelcustomizationuuid}}",
                              "modelInstanceName":"{{vnf-modelinfo-modelinstancename}}"
                           },
                           "cloudConfiguration":{
                              "lcpCloudRegionId":"RegionOne",
                              "tenantId":"41d6d38489bd40b09ea8a6b6b852dcbd"
                           },
                           "platform":{
                              "platformName":"test"
                           },
                           "lineOfBusiness":{
                              "lineOfBusinessName":"LOB-Demonstration"
                           },
                           "productFamilyId":"a9a77d5a-123e-4ca2-9eb9-0b015d2ee0fb",
                           "instanceName":"{{vnf-modelinfo-modelinstancename}}",
                           "instanceParams":[
                              {
                                 "onap_private_net_id":"oam_network_qXyY",
                                 "dcae_collector_ip":"10.12.5.214",
                                 "onap_private_subnet_id":"oam_network_qXyY",
                                 "pub_key":"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKXDgoo3+WOqcUG8/5uUbk81+yczgwC4Y8ywTmuQqbNxlY1oQ0YxdMUqUnhitSXs5S/yRuAVOYHwGg2mCs20oAINrP+mxBI544AMIb9itPjCtgqtE2EWo6MmnFGbHB4Sx3XioE7F4VPsh7japsIwzOjbrQe+Mua1TGQ5d4nfEOQaaglXLLPFfuc7WbhbJbK6Q7rHqZfRcOwAMXgDoBqlyqKeiKwnumddo2RyNT8ljYmvB6buz7KnMinzo7qB0uktVT05FH9Rg0CTWH5norlG5qXgP2aukL0gk1ph8iAt7uYLf1ktp+LJI2gaF6L0/qli9EmVCSLr1uJ38Q8CBflhkh",
                                 "sec_group":"onap_sg_qXyY",
                                 "install_script_version":"1.5.0",
                                 "demo_artifacts_version":"1.5.0",
                                 "cloud_env":"openstack",
                                 "flavor_name":"m1.medium",
                                 "public_net_id":"external",
                                 "image_name":"ubuntu-16-04-cloud-amd64"
                              }
                           ],
                           "vfModules":[
                              {
                                 "modelInfo":{
                                    "modelName":"{{vnf-vfmodule-0-modelinfo-modelname}}",
                                    "modelVersionId":"{{vnf-vfmodule-0-modelinfo-modeluuid}}",
                                    "modelInvariantUuid":"{{vnf-vfmodule-0-modelinfo-modelinvariantuuid}}",
                                    "modelVersion":"1",
                                    "modelCustomizationId":"{{vnf-vfmodule-0-modelinfo-modelcustomizationuuid}}"
                                 },
                                 "instanceName":"{{vnf-vfmodule-0-modelinfo-modelname}}",
                                 "instanceParams":[
                                    {
                                       "sec_group":"onap_sg_imAd",
                                       "public_net_id":"external"
                                    }
                                 ]
                              },
                              {
                                 "modelInfo":{
                                    "modelName":"{{vnf-vfmodule-1-modelinfo-modelname}}",
                                    "modelVersionId":"{{vnf-vfmodule-1-modelinfo-modeluuid}}",
                                    "modelInvariantUuid":"{{vnf-vfmodule-1-modelinfo-modelinvariantuuid}}",
                                    "modelVersion":"1",
                                    "modelCustomizationId":"{{vnf-vfmodule-1-modelinfo-modelcustomizationuuid}}"
                                 },
                                 "instanceName":"{{vnf-vfmodule-1-modelinfo-modelname}}",
                                 "instanceParams":[
                                    {
                                       "sec_group":"onap_sg_imAd",
                                       "public_net_id":"external"
                                    }
                                 ]
                              },
                              {
                                 "modelInfo":{
                                    "modelName":"{{vnf-vfmodule-2-modelinfo-modelname}}",
                                    "modelVersionId":"{{vnf-vfmodule-2-modelinfo-modeluuid}}",
                                    "modelInvariantUuid":"{{vnf-vfmodule-2-modelinfo-modelinvariantuuid}}",
                                    "modelVersion":"1",
                                    "modelCustomizationId":"{{vnf-vfmodule-2-modelinfo-modelcustomizationuuid}}"
                                 },
                                 "instanceName":"{{vnf-vfmodule-2-modelinfo-modelname}}",
                                 "instanceParams":[
                                    {
                                       "sec_group":"onap_sg_imAd",
                                       "public_net_id":"external"
                                    }
                                 ]
                              },
                              {
                                 "modelInfo":{
                                    "modelName":"{{vnf-vfmodule-3-modelinfo-modelname}}",
                                    "modelVersionId":"{{vnf-vfmodule-3-modelinfo-modeluuid}}",
                                    "modelInvariantUuid":"{{vnf-vfmodule-3-modelinfo-modelinvariantuuid}}",
                                    "modelVersion":"1",
                                    "modelCustomizationId":"{{vnf-vfmodule-3-modelinfo-modelcustomizationuuid}}"
                                 },
                                 "instanceName":"{{vnf-vfmodule-3-modelinfo-modelname}}",
                                 "instanceParams":[
                                    {
                                       "sec_group":"onap_sg_imAd",
                                       "public_net_id":"external"
                                    }
                                 ]
                              }
                           ]
                        }
                     ]
                  },
                  "modelInfo":{
                     "modelVersion":"1.0",
                     "modelVersionId":"{{service-uuid}}",
                     "modelInvariantId":"{{service-invariantUUID}}",
                     "modelName":"{{service-name}}",
                     "modelType":"service"
                  }
               }
            }
         ],
         "aLaCarte":false
      },
      "project":{
         "projectName":"Project-Demonstration"
      },
      "owningEntity":{
         "owningEntityId":"6f6c49d0-8a8c-4704-9174-321bcc526cc0",
         "owningEntityName":"OE-Demonstration"
      },
      "modelInfo":{
         "modelVersion":"1.0",
         "modelVersionId":"{{service-uuid}}",
         "modelInvariantId":"{{service-invariantUUID}}",
         "modelName":"{{service-name}}",
         "modelType":"service"
      }
   }
}'


Note that the "dcae_collector_ip" parameter has to contain the IP address of one of the Kubernetes cluster nodes, 10.12.5.214 in the example above. In the response to the Macro request, the user will obtain a requestId that will be usefulto follow the instantiation request status in the ONAP SO:

::

  curl -X GET \
    'http://{{k8s}}:30086/infraActiveRequests/{{requestid}}' \
    -H 'cache-control: no-cache'





PART 3 - Post Instantiation Operations
--------------------------------------

3-1 Post Instantiation VNF configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CDS executes post-instantiation VNF configuration if the "skip-post-instantiation" flag in the SDC service model is set to false, which is the default behavior. Manual post-instantiation configuration is necessary if the "skip-post-instantiation" flag in the service model is set to true or if the VNF is instantiated using the preload approach, which doesn't include CDS. Regardless, this step is NOT required during scale out operations, as VNF reconfiguration will be triggered by SO and executed by APPC.

If VNF post instantiation is executed manually, in order to change the state of the vLB the users should run the following REST call, replacing the IP addresses in the VNF endpoint and JSON object to match the private IP addresses of their vDNS instance:

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
    ]
  }'

At this point, the VNF is fully set up.


3-2 Updating AAI with VNF resources
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
To allow automated scale out via closed loop, the users need to inventory the VNF resources in AAI. This is done by running the heatbridge python script in /root/oom/kubernetes/robot in the Rancher VM in the Kubernetes cluster:

::

    ./demo-k8s.sh onap heatbridge <vLB stack_name in OpenStack> <service_instance_id> vLB vlb_onap_private_ip_0

Note that "vlb_onap_private_ip_0" used in the heatbridge call is the actual parameter name, not its value (e.g. the actual IP address). Heatbridge is needed for control loops because DCAE and Policy runs queries against AAI using vServer names as key.


PART 4 - Triggering Scale Out Manually
--------------------------------------

For scale out with manual trigger, VID is not supported at this time. Users can run the use case by directly calling SO APIs:

::

  curl -X POST \
  http://<Any_K8S_Node_IP_Address>:30277/onap/so/infra/serviceInstantiation/v7/serviceInstances/7d3ca782-c486-44b3-9fe5-39f322d8ee80/vnfs/9d33cf2d-d6aa-4b9e-a311-460a6be5a7de/vfModules/scaleOut \
  -H 'Accept: application/json' \
  -H 'Authorization: Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
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
            "modelCustomizationId": "ded42059-2f35-42d4-848b-16e1ab1ad197",
            "modelInvariantId": "2815d321-c6b4-4f21-b7f7-fa5adf8ed7d9",
            "modelVersionId": "524e34ed-9789-453e-ab73-8eff30eafef3",
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
            "instanceName": "vDNS-VM-02",
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
                        "modelInvariantId": "dfabdcae-cf50-4801-9885-9a3a9cc07e6f",
                        "modelVersionId": "ee55b537-7be5-4377-93c1-5d92931b6a78",
                        "modelName": "vLoadBalancerCDS",
                        "modelVersion": "1.0"
                    }
                }
            },
            {
                "relatedInstance": {
                    "instanceId": "9d33cf2d-d6aa-4b9e-a311-460a6be5a7de",
                    "modelInfo": {
                        "modelType": "vnf",
                        "modelInvariantId": "a77f9280-5c02-46cd-b1fc-855975db9df9",
                        "modelVersionId": "ff0e99ce-a521-44b5-b11b-da7e07ac83fc",
                        "modelName": "vLoadBalancerCDS",
                        "modelVersion": "1.0",
                        "modelCustomizationId": "b8b8a25d-19de-4581-bb63-f2dc8c0d79a7"
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
    }
  }'


To fill in the JSON object, users need to download the Service Model TOSCA template from the SDC Portal using one of the standard SDC users (for example user: cs0008, password: demo123456!). After logging to SDC, the user should select from the catalog the vLB service that they created, click the "TOSCA Artifacts" link on the left, and finally the download button on the right, as shown in the figure below:

.. figure:: files/scaleout/tosca_template_fig.png
   :align: center

For the example described below, users can refer to the TOSCA template linked at the top of the page. The template contains all the model (invariant/version/customization) IDs of service, VNF, and VF modules that the input request to SO needs.

The values of modelInvariantId, modelVersionId, and modelName in the relatedInstance item identified by "modelType": "service" in the JSON request to SO have to match invariantUUID, UUID, and name, respectively, in the TOSCA template:
::

            {
                "relatedInstance": {
                    "instanceId": "7d3ca782-c486-44b3-9fe5-39f322d8ee80",
                    "modelInfo": {
                        "modelType": "service",
                        "modelInvariantId": "dfabdcae-cf50-4801-9885-9a3a9cc07e6f",
                        "modelVersionId": "ee55b537-7be5-4377-93c1-5d92931b6a78",
                        "modelName": "vLoadBalancerCDS",
                        "modelVersion": "1.0"
                    }
                }
            }

.. figure:: files/scaleout/service.png
   :align: center


The values of modelInvariantId, modelVersionId, modelName, and modelVersion in the relatedInstance item identified by "modelType": "vnf" in the JSON request to SO have to match invariantUUID, UUID, name, and version, respectively, in the TOSCA template:

::

            {
                "relatedInstance": {
                    "instanceId": "9d33cf2d-d6aa-4b9e-a311-460a6be5a7de",
                    "modelInfo": {
                        "modelType": "vnf",
                        "modelInvariantId": "a77f9280-5c02-46cd-b1fc-855975db9df9",
                        "modelVersionId": "ff0e99ce-a521-44b5-b11b-da7e07ac83fc",
                        "modelName": "vLoadBalancerCDS",
                        "modelVersion": "1.0",
                        "modelCustomizationId": "b8b8a25d-19de-4581-bb63-f2dc8c0d79a7"
                    }
                }
            }

.. figure:: files/scaleout/vnf.png
   :align: center


The modelCustomizationId, modelInvariantId, modelVersionId, modelName, and modelVersion in the modelInfo item identified by "modelType": "vfModule" in the JSON request to SO have to match vfModuleModelCustomizationUUID, vfModuleModelInvariantUUID, vfModuleModelUUID, vfModuleModelName, and vfModuleModelVersion, respectively, in the TOSCA template. The modelCustomizationName parameter in the SO object can be set as the modelName parameter in the same JSON object:

::

        "modelInfo": {
            "modelCustomizationName": "Vloadbalancercds..vdns..module-3",
            "modelCustomizationId": "ded42059-2f35-42d4-848b-16e1ab1ad197",
            "modelInvariantId": "2815d321-c6b4-4f21-b7f7-fa5adf8ed7d9",
            "modelVersionId": "524e34ed-9789-453e-ab73-8eff30eafef3",
            "modelName": "Vloadbalancercds..vdns..module-3",
            "modelType": "vfModule",
            "modelVersion": "1"
        }

The vLB-vDNS-vPacketGenerator VNF that we use to describe the scale out use case supports the scaling of the vDNS VF module only. As such, in the TOSCA template users should refer to the section identified by "vfModuleModelName": "Vloadbalancercds..vdns..module-3", as highlighted below:

.. figure:: files/scaleout/service.png
   :align: center


Note that both Service and VNF related instances have a field called "instanceId" that represent the Service and VNF instance ID, respectively. These IDs are assigned at Service and VNF instantiation time and can be retrieved from AAI, querying for generic VNF objects:

::

    curl -k -X GET \
  https://<Any_K8S_Node_IP_Address>:30233/aai/v16/network/generic-vnfs \
  -H 'Accept: application/json' \
  -H 'Authorization: Basic QUFJOkFBSQ==' \
  -H 'Content-Type: application/json' \
  -H 'X-FromAppId: AAI' \
  -H 'X-TransactionId: get_aai_subscr'

From the list of VNFs reported by AAI, search for the name of the VNF that was previously instantiated, for example "vLB_VNF_01" in the example below:

::

        {
            "vnf-id": "9d33cf2d-d6aa-4b9e-a311-460a6be5a7de",
            "vnf-name": "vLB_VNF_01",
            "vnf-type": "vLoadBalancer/vLoadBalancer 0",
            "prov-status": "ACTIVE",
            "equipment-role": "",
            "orchestration-status": "Active",
            "ipv4-oam-address": "10.0.220.10",
            "in-maint": true,
            "is-closed-loop-disabled": false,
            "resource-version": "1565817789379",
            "model-invariant-id": "a77f9280-5c02-46cd-b1fc-855975db9df9",
            "model-version-id": "ff0e99ce-a521-44b5-b11b-da7e07ac83fc",
            "model-customization-id": "b8b8a25d-19de-4581-bb63-f2dc8c0d79a7",
            "selflink": "restconf/config/GENERIC-RESOURCE-API:services/service/7d3ca782-c486-44b3-9fe5-39f322d8ee80/service-data/vnfs/vnf/9d33cf2d-d6aa-4b9e-a311-460a6be5a7de/vnf-data/vnf-topology/",
            "relationship-list": {
                "relationship": [
                    {
                        "related-to": "service-instance",
                        "relationship-label": "org.onap.relationships.inventory.ComposedOf",
                        "related-link": "/aai/v16/business/customers/customer/Demonstration/service-subscriptions/service-subscription/vRAR/service-instances/service-instance/7d3ca782-c486-44b3-9fe5-39f322d8ee80",
                        "relationship-data": [
                            {
                                "relationship-key": "customer.global-customer-id",
                                "relationship-value": "Demonstration"
                            },
                            {
                                "relationship-key": "service-subscription.service-type",
                                "relationship-value": "vLB"
                            },
                            {
                                "relationship-key": "service-instance.service-instance-id",
                                "relationship-value": "7d3ca782-c486-44b3-9fe5-39f322d8ee80"
                            }
                        ],
                        "related-to-property": [
                            {
                                "property-key": "service-instance.service-instance-name",
                                "property-value": "vLB-Service-0814-1"
                            }
                        ]
                    }
                    ...
         }

To identify the VNF ID, look for the "vnf-id" parameter at the top of the JSON object, while to determine the Service ID, look for the "relationship-value" parameter corresponding to the "relationship-key": "service-instance.service-instance-id" item in the "relationship-data" list. In the example above, the Service instance ID is 7d3ca782-c486-44b3-9fe5-39f322d8ee80, while the VNF ID is 9d33cf2d-d6aa-4b9e-a311-460a6be5a7de.

These IDs are also used in the URL request to SO:

::

    http://<Any_K8S_Node_IP_Address>:30277/onap/so/infra/serviceInstantiation/v7/serviceInstances/7d3ca782-c486-44b3-9fe5-39f322d8ee80/vnfs/9d33cf2d-d6aa-4b9e-a311-460a6be5a7de/vfModules/scaleOut


Finally, the "configurationParameters" section in the JSON request to SO contains the parameters that will be used to reconfigure the VNF after scaling. Please see Section 1-7 for an in-depth description of how to set the parameters correctly.

::

    "configurationParameters": [
            {
                "ip-addr": "$.vf-module-topology.vf-module-parameters.param[16].value",
                "oam-ip-addr": "$.vf-module-topology.vf-module-parameters.param[30].value"
            }
    ]


PART 5 - Running the Scale Out Use Case with Configuration Preload
------------------------------------------------------------------

While CDS can be used to model and automate the generation of cloud configuration for VNF instantiation, the manual preload approach is still supported for scale out with manual trigger (no closed loop). Note that preload operations must be executed before VF modules are created or scaled, as the instantiation process will use the preload to determine the VF module configuration.

The procedure is similar to one described above, with some minor changes:

1) **Service Design and Creation**: The heat template used to create a vendor software product in SDC is the same. However, during property assignment (Section 1-2) "sdnc_artifact_name", "sdnc_model_version", "sdnc_model_name" **must be** left blank, as they are used for CDS only.

2) As closed loop with preload is not supported for scale out, DCAE blueprint and Policy onboarding (Section 1-2), deployment of naming policy (Section 1-3), and closed loop design and deployment from CLAMP (Section 1-4) are not necessary.

3) **Creation of VNF template with CDT** works as described in Section 1-5.

4) **Controller type selection** in SO works as described in Section 1-6.

5) **VNF instantiation from VID**: users can use VID to create the service, the VNF, and instantiate the VF modules. In the VID main page, users should select GR API (this should be the default option).

.. figure:: files/scaleout/vid.png
   :align: center

Based on the Heat template structure, there are four VF modules:

  * module-0: base module that contains resources, such as internal private networks and public key, shared across the VNF elements
  * module-1: vLB resource descriptor
  * module-2: vPacketGen resource descriptor
  * module-3: vDNS resource descriptor

These VF modules have to be installed in the following order, so as to satisfy heat dependencies: module-0, module-1, module-2, module-3. The parameters defined in the Heat environment files can be overridden by loading cloud configuration to SDNC before the VF modules are instantiated. See example of preloads below. They need to be customized based on the OpenStack cloud and execution environment in which the VF modules are going to be instantiated.

Module-0 Preload
~~~~~~~~~~~~~~~~

::

    curl -X POST \
  http://<Any_K8S_Node_IP_Address>:30202/restconf/operations/GENERIC-RESOURCE-API:preload-vf-module-topology-operation \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 0a7abc62-9d8f-4f63-8b05-db7cc4c3e28b' \
  -H 'cache-control: no-cache' \
  -d '{
    "input": {
        "preload-vf-module-topology-information": {
            "vf-module-topology": {
                "vf-module-topology-identifier": {
                    "vf-module-name": "vNetworks-0211-1"
                },
                "vf-module-parameters": {
                    "param": [
                        {
                            "name": "vlb_private_net_id",
                            "value": "vLBMS_zdfw1lb01_private_ms"
                        },
                        {
                            "name": "pktgen_private_net_id",
                            "value": "vLBMS_zdfw1pktgen01_private_ms"
                        },
                        {
                            "name": "vlb_private_net_cidr",
                            "value": "192.168.10.0/24"
                        },
                        {
                            "name": "pktgen_private_net_cidr",
                            "value": "192.168.9.0/24"
                        },
                        {
                            "name": "vlb_0_int_pktgen_private_port_0_mac",
                            "value": "fa:16:3e:00:01:10"
                        },
                        {
                            "name": "vpg_0_int_pktgen_private_port_0_mac",
                            "value": "fa:16:3e:00:01:20"
                        },
                        {
                            "name": "vnf_id",
                            "value": "vLoadBalancerMS"
                        },
                        {
                            "name": "vnf_name",
                            "value": "vLBMS"
                        },
                        {
                            "name": "key_name",
                            "value": "vlb_key"
                        },
                        {
                            "name": "pub_key",
                            "value": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQXYJYYi3/OUZXUiCYWdtc7K0m5C0dJKVxPG0eI8EWZrEHYdfYe6WoTSDJCww+1qlBSpA5ac/Ba4Wn9vh+lR1vtUKkyIC/nrYb90ReUd385Glkgzrfh5HdR5y5S2cL/Frh86lAn9r6b3iWTJD8wBwXFyoe1S2nMTOIuG4RPNvfmyCTYVh8XTCCE8HPvh3xv2r4egawG1P4Q4UDwk+hDBXThY2KS8M5/8EMyxHV0ImpLbpYCTBA6KYDIRtqmgS6iKyy8v2D1aSY5mc9J0T5t9S2Gv+VZQNWQDDKNFnxqYaAo1uEoq/i1q63XC5AD3ckXb2VT6dp23BQMdDfbHyUWfJN"
                        }
                    ]
                }
            },
            "vnf-topology-identifier-structure": {
                "vnf-name": "vLoadBalancer-Vnf-0211-1",
                "vnf-type": "vLoadBalancer/vLoadBalancer 0"
            },
            "vnf-resource-assignments": {
                "availability-zones": {
                    "availability-zone": [
                        "nova"
                    ],
                    "max-count": 1
                },
                "vnf-networks": {
                    "vnf-network": []
                }
            }
        },
        "request-information": {
            "request-id": "robot12",
            "order-version": "1",
            "notification-url": "openecomp.org",
            "order-number": "1",
            "request-action": "PreloadVfModuleRequest"
        },
        "sdnc-request-header": {
            "svc-request-id": "robot12",
            "svc-notification-url": "http://openecomp.org:8080/adapters/rest/SDNCNotify",
            "svc-action": "reserve"
        }
    }
  }'


Module-1 Preload
~~~~~~~~~~~~~~~~

::

    curl -X POST \
  http://<Any_K8S_Node_IP_Address>:30202/restconf/operations/GENERIC-RESOURCE-API:preload-vf-module-topology-operation \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 662914ac-29fc-414d-8823-1691fb2c718a' \
  -H 'cache-control: no-cache' \
  -d '{
    "input": {
        "preload-vf-module-topology-information": {
            "vf-module-topology": {
                "vf-module-topology-identifier": {
                    "vf-module-name": "vLoadBalancer-0211-1"
                },
                "vf-module-parameters": {
                    "param": [
                        {
                            "name": "vlb_image_name",
                            "value": "ubuntu-16-04-cloud-amd64"
                        },
                        {
                            "name": "vlb_flavor_name",
                            "value": "m1.medium"
                        },
                        {
                            "name": "public_net_id",
                            "value": "public"
                        },
                        {
                            "name": "int_private_net_id",
                            "value": "vLBMS_zdfw1lb01_private_ms"
                        },
                        {
                            "name": "int_private_subnet_id",
                            "value": "vLBMS_zdfw1lb01_private_sub_ms"
                        },
                        {
                            "name": "int_pktgen_private_net_id",
                            "value": "vLBMS_zdfw1pktgen01_private_ms"
                        },
                        {
                            "name": "int_pktgen_private_subnet_id",
                            "value": "vLBMS_zdfw1pktgen01_private_sub_ms"
                        },
                        {
                            "name": "onap_private_net_id",
                            "value": "oam_onap_vnf_test"
                        },
                        {
                            "name": "onap_private_subnet_id",
                            "value": "oam_onap_vnf_test"
                        },
                        {
                            "name": "vlb_private_net_cidr",
                            "value": "192.168.10.0/24"
                        },
                        {
                            "name": "pktgen_private_net_cidr",
                            "value": "192.168.9.0/24"
                        },
                        {
                            "name": "onap_private_net_cidr",
                            "value": "10.0.0.0/16"
                        },
                        {
                            "name": "vlb_int_private_ip_0",
                            "value": "192.168.10.111"
                        },
                        {
                            "name": "vlb_onap_private_ip_0",
                            "value": "10.0.150.1"
                        },
                        {
                            "name": "vlb_int_pktgen_private_ip_0",
                            "value": "192.168.9.111"
                        },
                        {
                            "name": "vdns_int_private_ip_0",
                            "value": "192.168.10.211"
                        },
                        {
                            "name": "vdns_onap_private_ip_0",
                            "value": "10.0.150.3"
                        },
                        {
                            "name": "vpg_int_pktgen_private_ip_0",
                            "value": "192.168.9.110"
                        },
                        {
                            "name": "vpg_onap_private_ip_0",
                            "value": "10.0.150.2"
                        },
                        {
                            "name": "vlb_name_0",
                            "value": "vlb-0211-1"
                        },
                        {
                            "name": "vlb_0_mac_address",
                            "value": "fa:16:3e:00:01:10"
                        },
                        {
                            "name": "vpg_0_mac_address",
                            "value": "fa:16:3e:00:01:20"
                        },
                        {
                            "name": "vip",
                            "value": "192.168.9.112"
                        },
                        {
                            "name": "gre_ipaddr",
                            "value": "192.168.10.112"
                        },
                        {
                            "name": "vnf_id",
                            "value": "vLoadBalancerMS"
                        },
                        {
                            "name": "vf_module_id",
                            "value": "vLoadBalancerMS"
                        },
                        {
                            "name": "vnf_name",
                            "value": "vLBMS"
                        },
                        {
                            "name": "dcae_collector_ip",
                            "value": "10.12.5.20"
                        },
                        {
                            "name": "dcae_collector_port",
                            "value": "30235"
                        },
                        {
                            "name": "demo_artifacts_version",
                            "value": "1.6.0-SNAPSHOT"
                        },
                        {
                            "name": "install_script_version",
                            "value": "1.6.0-SNAPSHOT"
                        },
                        {
                            "name": "nb_api_version",
                            "value": "1.2.0"
                        },
                        {
                            "name": "keypair",
                            "value": "vlb_key"
                        },
                        {
                            "name": "cloud_env",
                            "value": "openstack"
                        },
                        {
                            "name": "nexus_artifact_repo",
                            "value": "https://nexus.onap.org"
                        },
                        {
                            "name": "sec_group",
                            "value": "default"
                        }
                    ]
                }
            },
            "vnf-topology-identifier-structure": {
                "vnf-name": "vLoadBalancer-Vnf-0211-1",
                "vnf-type": "vLoadBalancer/vLoadBalancer 0"
            },
            "vnf-resource-assignments": {
                "availability-zones": {
                    "availability-zone": [
                        "nova"
                    ],
                    "max-count": 1
                },
                "vnf-networks": {
                    "vnf-network": []
                }
            }
        },
        "request-information": {
            "request-id": "robot12",
            "order-version": "1",
            "notification-url": "openecomp.org",
            "order-number": "1",
            "request-action": "PreloadVfModuleRequest"
        },
        "sdnc-request-header": {
            "svc-request-id": "robot12",
            "svc-notification-url": "http://openecomp.org:8080/adapters/rest/SDNCNotify",
            "svc-action": "reserve"
        }
    }
  }'


Module-2 Preload
~~~~~~~~~~~~~~~~
::


    curl -X POST \
  http://<Any_K8S_Node_IP_Address>:30202/restconf/operations/GENERIC-RESOURCE-API:preload-vf-module-topology-operation \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 5f2490b3-6e4a-4512-9a0d-0aa6f6fa0ea8' \
  -H 'cache-control: no-cache' \
  -d '{
    "input": {
        "preload-vf-module-topology-information": {
            "vf-module-topology": {
                "vf-module-topology-identifier": {
                    "vf-module-name": "vPacketGen-0211-1"
                },
                "vf-module-parameters": {
                    "param": [
                        {
                            "name": "vpg_image_name",
                            "value": "ubuntu-16-04-cloud-amd64"
                        },
                        {
                            "name": "vpg_flavor_name",
                            "value": "m1.medium"
                        },
                        {
                            "name": "public_net_id",
                            "value": "public"
                        },
                        {
                            "name": "int_pktgen_private_net_id",
                            "value": "vLBMS_zdfw1pktgen01_private_ms"
                        },
                        {
                            "name": "int_pktgen_private_subnet_id",
                            "value": "vLBMS_zdfw1pktgen01_private_sub_ms"
                        },
                        {
                            "name": "onap_private_net_id",
                            "value": "oam_onap_vnf_test"
                        },
                        {
                            "name": "onap_private_subnet_id",
                            "value": "oam_onap_vnf_test"
                        },
                        {
                            "name": "pktgen_private_net_cidr",
                            "value": "192.168.9.0/24"
                        },
                        {
                            "name": "onap_private_net_cidr",
                            "value": "10.0.0.0/16"
                        },
                        {
                            "name": "vlb_int_pktgen_private_ip_0",
                            "value": "192.168.9.111"
                        },
                        {
                            "name": "vpg_int_pktgen_private_ip_0",
                            "value": "192.168.9.110"
                        },
                        {
                            "name": "vpg_onap_private_ip_0",
                            "value": "10.0.150.2"
                        },
                        {
                            "name": "vpg_name_0",
                            "value": "vpg-0211-1"
                        },
                        {
                            "name": "vlb_0_mac_address",
                            "value": "fa:16:3e:00:01:10"
                        },
                        {
                            "name": "vpg_0_mac_address",
                            "value": "fa:16:3e:00:01:20"
                        },
                        {
                            "name": "pg_int",
                            "value": "192.168.9.109"
                        },
                        {
                            "name": "vnf_id",
                            "value": "vLoadBalancerMS"
                        },
                        {
                            "name": "vf_module_id",
                            "value": "vLoadBalancerMS"
                        },
                        {
                            "name": "vnf_name",
                            "value": "vLBMS"
                        },
                        {
                            "name": "demo_artifacts_version",
                            "value": "1.6.0-SNAPSHOT"
                        },
                        {
                            "name": "install_script_version",
                            "value": "1.6.0-SNAPSHOT"
                        },
                        {
                            "name": "nb_api_version",
                            "value": "1.2.0"
                        },
                        {
                            "name": "keypair",
                            "value": "vlb_key"
                        },
                        {
                            "name": "cloud_env",
                            "value": "openstack"
                        },
                        {
                            "name": "nexus_artifact_repo",
                            "value": "https://nexus.onap.org"
                        },
                        {
                            "name": "sec_group",
                            "value": "default"
                        }
                    ]
                }
            },
            "vnf-topology-identifier-structure": {
                "vnf-name": "vLoadBalancer-Vnf-0211-1",
                "vnf-type": "vLoadBalancer/vLoadBalancer 0"
            },
            "vnf-resource-assignments": {
                "availability-zones": {
                    "availability-zone": [
                        "nova"
                    ],
                    "max-count": 1
                },
                "vnf-networks": {
                    "vnf-network": []
                }
            }
        },
        "request-information": {
            "request-id": "robot12",
            "order-version": "1",
            "notification-url": "openecomp.org",
            "order-number": "1",
            "request-action": "PreloadVfModuleRequest"
        },
        "sdnc-request-header": {
            "svc-request-id": "robot12",
            "svc-notification-url": "http://openecomp.org:8080/adapters/rest/SDNCNotify",
            "svc-action": "reserve"
        }
    }
 }'


Module-3 Preload
~~~~~~~~~~~~~~~~

::

    curl -X POST \
  http://<Any_K8S_Node_IP_Address>:30202/restconf/operations/GENERIC-RESOURCE-API:preload-vf-module-topology-operation \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: fd0a4706-f955-490a-875e-08ddd8fe002e' \
  -H 'cache-control: no-cache' \
  -d '{
    "input": {
        "preload-vf-module-topology-information": {
            "vf-module-topology": {
                "vf-module-topology-identifier": {
                    "vf-module-name": "vDNS-0125-1"
                },
                "vf-module-parameters": {
                    "param": [
                        {
                            "name": "vdns_image_name",
                            "value": "ubuntu-16-04-cloud-amd64"
                        },
                        {
                            "name": "vdns_flavor_name",
                            "value": "m1.medium"
                        },
                        {
                            "name": "public_net_id",
                            "value": "public"
                        },
                        {
                            "name": "int_private_net_id",
                            "value": "vLBMS_zdfw1lb01_private"
                        },
                        {
                            "name": "int_private_subnet_id",
                            "value": "vLBMS_zdfw1lb01_private_sub_ms"
                        },
                        {
                            "name": "onap_private_net_id",
                            "value": "oam_onap_vnf_test"
                        },
                        {
                            "name": "onap_private_subnet_id",
                            "value": "oam_onap_vnf_test"
                        },
                        {
                            "name": "vlb_private_net_cidr",
                            "value": "192.168.10.0/24"
                        },
                        {
                            "name": "onap_private_net_cidr",
                            "value": "10.0.0.0/16"
                        },
                        {
                            "name": "vlb_int_private_ip_0",
                            "value": "192.168.10.111"
                        },
                        {
                            "name": "vlb_onap_private_ip_0",
                            "value": "10.0.150.1"
                        },
                        {
                            "name": "vlb_int_pktgen_private_ip_0",
                            "value": "192.168.9.111"
                        },
                        {
                            "name": "vdns_int_private_ip_0",
                            "value": "192.168.10.212"
                        },
                        {
                            "name": "vdns_onap_private_ip_0",
                            "value": "10.0.150.4"
                        },
                        {
                            "name": "vdns_name_0",
                            "value": "vdns-0211-1"
                        },
                        {
                            "name": "vnf_id",
                            "value": "vLoadBalancerMS"
                        },
                        {
                            "name": "vf_module_id",
                            "value": "vLoadBalancerMS"
                        },
                        {
                            "name": "vnf_name",
                            "value": "vLBMS"
                        },
                        {
                            "name": "install_script_version",
                            "value": "1.6.0-SNAPSHOT"
                        },
                        {
                            "name": "nb_api_version",
                            "value": "1.2.0"
                        },
                        {
                            "name": "keypair",
                            "value": "vlb_key"
                        },
                        {
                            "name": "cloud_env",
                            "value": "openstack"
                        },
                        {
                            "name": "sec_group",
                            "value": "default"
                        },
                        {
                            "name": "nexus_artifact_repo",
                            "value": "https://nexus.onap.org"
                        }
                    ]
                }
            },
            "vnf-topology-identifier-structure": {
                "vnf-name": "vLoadBalancer-Vnf-0125-1",
                "vnf-type": "vLoadBalancer/vLoadBalancer 0"
            },
            "vnf-resource-assignments": {
                "availability-zones": {
                    "availability-zone": [
                        "nova"
                    ],
                    "max-count": 1
                },
                "vnf-networks": {
                    "vnf-network": []
                }
            }
        },
        "request-information": {
            "request-id": "robot12",
            "order-version": "1",
            "notification-url": "openecomp.org",
            "order-number": "1",
            "request-action": "PreloadVfModuleRequest"
        },
        "sdnc-request-header": {
            "svc-request-id": "robot12",
            "svc-notification-url": "http://openecomp.org:8080/adapters/rest/SDNCNotify",
            "svc-action": "reserve"
        }
    }
 }'

The Heat environment files already set many parameters used for VF module instantiation. Those parameters can be reused in the SDNC preload too, while placeholders like "PUT THE IP ADDRESS HERE" or "PUT THE PUBLIC KEY HERE" must be overridden.

To instantiate VF modules, please refer to this wiki page: https://wiki.onap.org/display/DW/Tutorial+vIMS%3A+VID+Instantiate+the+VNF using vLB as ServiceType.

6) **Post Instantiation Actions**: Please refer to Sections 3-1 for vLB configuration and Section 3-2 for resource orchestration with heatbridge.

7) **Triggering Scale Out Manually**: Please refer to Section 4 to trigger scale out manually with direct API call to SO.


PART 6 - Known Issues and Resolutions
-------------------------------------
1) When running closed loop-enabled scale out, the closed loop designed in CLAMP conflicts with the default closed loop defined for the old vLB/vDNS use case

Resolution: Change TCA configuration for the old vLB/vDNS use case

- Connect to Consul: http://<ANY K8S VM IP ADDRESS>:30270 and click on "Key/Value" → "dcae-tca-analytics"
- Change "eventName" in the vLB default policy to something different, for example "vLB" instead of the default value "vLoadBalancer"
- Change "subscriberConsumerGroup" in the TCA configuration to something different, for example "OpenDCAE-c13" instead of the default value "OpenDCAE-c12"
- Click "UPDATE" to upload the new TCA configuration
