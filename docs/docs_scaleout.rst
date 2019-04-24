.. _docs_scaleout:

VF Module Scale Out Use Case
----------------------------

Source files
~~~~~~~~~~~~

- Base VNF template file: https://git.onap.org/demo/plain/heat/vLBMS/base_vlb.yaml
- Base VNF environment file: https://git.onap.org/demo/plain/heat/vLBMS/base_vlb.env

- VF module scaling template file: https://git.onap.org/demo/plain/heat/vLBMS/dnsscaling.yaml
- VF module scaling environment file: https://git.onap.org/demo/plain/heat/vLBMS/dnsscaling.env

VVP Report
~~~~~~~~~~

:download:`vLBMS report <files/vLBMS_report.json>`

Description
~~~~~~~~~~~
The Scale Out use case shows how users/network operators can add Virtual Network Function Components (VNFCs) as part of a VF Module that has been instantiated in the Service model to an existing VNF, in order to increase capacity of the network. ONAP Casablanca release supports scale out with manual trigger from VID and closed-loop enabled automation from Policy. This is demonstrated against the vLB/vDNS VNFs developed for ONAP. For Casablanca, both APPC and SDNC controllers are used to demonstrate accepting request from SO to execute the Scale Out operation. APPC is the main controller used for this use case and it can be used to scale different VNF types. SDNC is experimental for now and it can scale only the vDNS VNF developed for ONAP.

The Casablanca Scaling Use Case Wiki Page can be found here: https://wiki.onap.org/display/DW/Scaling+Use+Case+Extension

How to Use
~~~~~~~~~~
Scaling VF modules manually requires the user/network operator to trigger the scale out operation from the VID portal. VID translates the operation into a call to SO. Scaling VF modules in an automated manner instead requires the user/network operator to design and deploy a closed loop for scale out that includes policies (e.g. threshold-crossing conditions), guard policies that determine when it's safe to scale out, and microservices that analyze events coming from the network in order to discover situations.
 
Both manual and automated scale out activate the scale out workflow in the Service Orchestrator (SO). The workflow runs as follows: 

- SO sends a request to APPC to run health check against the VNF;
- If the VNF is healthy, SO instantiates a new VF module and sends a request to APPC to reconfigure the VNF;
- APPC reconfigures the VNF, without interrupting the service;
- SO sends a request to APPC to run health check against the VNF again, to validate that the scale out operation didn't impact the running VNF.
 
The vLB has a Northbound API that allows an upstream system (e.g. ONAP) to change the internal configuration by updating the list of active vDNS instances (i.e. VNF reconfiguration). The Northbound API framework has been built using FD.io-based Honeycomb 1707, and supports both RESTconf and NETCONF protocols. Below is an example of vDNS instances contained in the vLB, in JSON format:
::

    {
    "vlb-business-vnf-onap-plugin": {
        "vdns-instances": {
            "vdns-instance": [
                {
                   "ip-addr": "192.168.10.211",
                   "oam-ip-addr": "10.0.150.2",
                   "enabled": true
                }
             ]
         }
     }
  }
 
The parameters required for VNF reconfiguration (i.e. "ip-addr", "oam-ip-addr", and "enabled" in case of vLB/vDNS) can be specified in the VID GUI when triggering the workflow manually or in CLAMP when designing a closed loop for the automated case. In both cases, the format used for specifying the parameters and their values is a JSON path. SO will use the provided paths to access parameters' name and value in the VF module preload received from SDNC before instantiating a new VF module.
 
VID accepts a JSON array in the "Configuration Parameter" box (see later), for example:
::

[{"ip-addr":"$.vf-module-topology.vf-module-parameters.param[10].value","oam-ip-addr":"$.vf-module-topology.vf-module-parameters.param[15].value","enabled":"$.vf-module-topology.vf-module-parameters.param[22].value"}]
 
CLAMP, instead, accepts a YAML file in the "Payload" box in the Policy Creation form, for example:
::

  requestParameters: '{"usePreload":true,"userParams":[]}'
  configurationParameters: '[{"ip-addr":"$.vf-module-topology.vf-module-parameters.param[10].value","oam-ip-addr":"$.vf-module-topology.vf-module-parameters.param[15].value","enabled":"$.vf-module-topology.vf-module-parameters.param[22].value"}]'

Note that Policy requires an additional object, called "requestParameters" in which "usePreload" should be set to true and the "userParams" array should be left empty.
 
The JSON path to the parameters used for VNF reconfiguration, including array locations, should be set as described above. Finally, although the VNF supports to update multiple vDNS records in the same call, for Casablanca release APPC updates a single vDNS instance at a time.
 
When using APPC, before running scale out, the user needs to create a VNF template using the Controller Design Tool (CDT), a design-time tool that allows users to create and on-board VNF templates into the APPC. The template describes which control operation can be executed against the VNF (e.g. scale out, health check, modify configuration, etc.), the protocols that the VNF supports, port numbers, VNF APIs, and credentials for authentication. Being VNF agnostic, APPC uses these templates to "learn" about specific VNFs and the supported operations.
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
      required: "true"
      default: null
      source: Manual
      rule-type: null
      request-keys: null
      response-keys: null
 
Here is an example of API for the vLB VNF used for this use case. We name the file after the vnf-type contained in SDNC (i.e. Vloadbalancerms..dnsscaling..module-1):
::

    <vlb-business-vnf-onap-plugin xmlns="urn:opendaylight:params:xml:ns:yang:vlb-business-vnf-onap-plugin">
        <vdns-instances>
            <vdns-instance>
                <ip-addr>${ip-addr}</ip-addr>
                <oam-ip-addr>${oam-ip-addr}</oam-ip-addr>
                <enabled>${enabled}</enabled>
            </vdns-instance>
        </vdns-instances>
    </vlb-business-vnf-onap-plugin>
 
To create the VNF template in CDT, the following steps are required:

- Connect to the CDT GUI: http://APPC-IP:8080 (in Heat-based ONAP deployments) or http://ANY-K8S-IP:30289 (in OOM/K8S-based ONAP deployments)
- Click "My VNF" Tab. Create your user ID, if necessary
- Click "Create new VNF" entering the VNF type as reported in VID or AAI, e.g. vLoadBalancerMS/vLoadBalancerMS 0
- Select "ConfigScaleOut" action
- Create a new template identifier using the vnf-type name in SDNC as template name, e.g. Vloadbalancerms..dnsscaling..module-1
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
 
To trigger the scale out workflow manually, the user/network operator can log into VID from the ONAP Portal (demo/demo123456! as username/password), select "VNF Changes" and then the "New (+)" button. The user/network operator needs to fill in the "VNF Change Form" by selecting Subscriber, Service Type, NF Role, Model Version, VNF, Scale Out from the Workflow dropdown window, and insert the JSON path array described above in the "Configuration Parameter" box. After clicking "Next", in the following window the user/network operator has to select the VF Module to scale by clicking on the VNF and then on the appropriate VF Module checkbox. Finally, by clicking on the "Schedule" button, the scale out use case will run as described above.
 
Automated scale out requires the user to onboard a DCAE blueprint in SDC when creating the service. To design a closed loop for scale out, the user needs to access the CLAMP GUI (https://clamp.api.simpledemo.onap.org:30258/designer/index.html) and execute the following operations:

- Click the "Closed loop" dropdown window and select "Open CL"
- Select the closed loop model and click "OK"
- In the next screen, click the "Policy" box to create a policy for closed loop, including guard policies
- After creating the policies, click "TCA" and review the blueprint uploaded during service creation and distributed by SDC to CLAMP
- Click the "Manage" dropdown and then "Submit" to push the policies to the Policy Engine
- From the same "Manage" dropdown, click "Deploy" to deploy the TCA blueprint to DCAE
 
The vLB/vDNS VNF generates traffic and reports metrics to the VES collector in the DCAE platform. The number of incoming packets to the vLB is used to evaluate the policy defined for closed loop. If the provided threshold is crossed, DCAE generates an event that reaches the Policy Engine, which in turn activates the scale out closed loop described above.

For more information about scale out, videos, and material used for running the use case, please look at the wiki page: https://wiki.onap.org/display/DW/Running+Scale+Out+Use+Case+for+Casablanca

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
Casablanca Scale Out completed all tests as found here: https://wiki.onap.org/pages/viewpage.action?pageId=36964241#UseCaseTracking(CasablancaScaling)-Testing

Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1) When running closed loop-enabled scale out, the closed loop designed in CLAMP conflicts with the default closed loop defined for the old vLB/vDNS use case

Resolution: Change TCA configuration for the old vLB/vDNS use case

- Connect to Consul: http://<ANY K8S VM IP ADDRESS>:30270 and click on "Key/Value" → "dcae-tca-analytics"
- Change "eventName" in the vLB default policy to something different, for example "vLB" instead of the default value "vLoadBalancer"
- Change "subscriberConsumerGroup" in the TCA configuration to something different, for example "OpenDCAE-c13" instead of the default value "OpenDCAE-c12"
- Click "UPDATE" to upload the new TCA configuration

2) When running closed loop-enabled scale out, the permitAll guard policy conflicts with the scale out guard policy

Resolution: Undeploy the permitAll guard policy

- Connect to the Policy GUI, either through the ONAP Portal (https://portal.api.simpledemo.onap.org:30225/ONAPPORTAL/login.htm) or directly (https://policy.api.simpledemo.onap.org:30219/onap/login.htm)
- If using the ONAP Portal, use demo/demo123456! as credentials, otherwise, if accessing Policy GUI directly, use demo/demo
- Click "Policy" → "Push" on the left panel
- Click the pencil symbol next to "default" in the PDP Groups table
- Select "Decision_AllPermitGuard"
- Click "Remove"