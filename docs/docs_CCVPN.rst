.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_ccvpn:

CCVPN (Cross Domain and Cross Layer VPN)
----------------------------------------

Update for Frankfurt release
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In Frankfurt, we introduced two extensions in CCVPN use case. One is E-LINE service over OTN NNI handover, another is the
multi domain optical service which aims to provide end to end layer 1 service.

E-LINE over OTN NNI
~~~~~~~~~~~~~~~~~~~
Description
~~~~~~~~~~~
It is considered a typical scenario for operators to use OTN to interconnect its multiple transport network domains. Hence
the capabilities of orchestrating end-to-end E-LINE services across the domains over OTN is important for ONAP.  When operating
with multiple domains with multi vendor solutions, it is also important to define and use standard and open
interfaces, such as the IETF ACTN-based transport YANG models(https://tools.ietf.org/html/rfc8345), as the southbound interface
of ONAP, in order to ensure interoperability. The SOTN NNI use-case aims to automate the design, service provision by independent
operational entities within a service provider network by delivering E-Line over OTN orchestration capabilities into ONAP. SOTN NNI
extends upon the CCVPN use-case by incorporating support for L1/L2 network management capabilities leveraging open standards & common
data models.

Frankfurt Scope and Impacted modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The Frankfurt demonstration includes L1(OTN) and L2(ETH) Topology discovery from multiple domains controllers with in an operator
and provide VPN service provision in OTN and ETH network.

The ONAP components involved in this use case are: SDC, A&AI, UUI, SO, SDNC, OOF, MSB.

Functional Test Cases
~~~~~~~~~~~~~~~~~~~~~
Usecase specific developments have been realized in SO, OOF, AAI, SDNC and UUI ONAP components..

All test case covered by this use case:
https://wiki.onap.org/display/DW/E-LINE+over+OTN+Inter+Domain+Test+Cases

Testing Procedure
~~~~~~~~~~~~~~~~~
Design time
SOTNVPNInfraService service design in SDC and distribute to AAI and SO.

Run Time:
All operation will be triggered by UUI, including service creation and termination, link management and topology network display.

More details can be found here:
https://wiki.onap.org/display/DW/E-LINE+over+OTN+Inter+Domain+Test+Cases

Test status can be found here:
https://wiki.onap.org/display/DW/2%3A+Frankfurt+Release+Integration+Testing+Status


Update for Dublin release
~~~~~~~~~~~~~~~~~~~~~~~~~

1. Service model optimization

In Dublin release,the design of CCVPN was optimized by having support of List type of Input in SDC.
During onboarding and design phase, one end to end service is created using SDC. This service is
composed of these two kinds of resources:
• VPN resource
• Site resource
You can see the details from here https://wiki.onap.org/display/DW/Details+of+Targeted+Service+Template

2. Closed Loop in bandwidth adjustment
Simulate alarm at the edge site branch and ONAP will execute close-loop automatically and trigger bandwidth to change higher.

3. Site Change
Site can be add or delete according to the requirements


More information about CCVPN in Dublin release:https://wiki.onap.org/pages/viewpage.action?pageId=45296665
and the test case in Dublin can be found:https://wiki.onap.org/display/DW/CCVPN+Test+Cases+for+Dublin+Release
And test status:https://wiki.onap.org/display/DW/CCVPN+Test+Status

Note: CCVPN integration testing coversed service design, service creation and closed-loop bandwidth adjustments in Dublin release.
The service termination and service change will continue to be tested in E release.
During the integration testing, SDC, SO, SDC master branch are used which include the enhanced features for CCVPN use case.


Service used for CCVPN
~~~~~~~~~~~~~~~~~~~~~

- SOTNVPNInfraService, SDWANVPNInfraService and SIteService: https://wiki.onap.org/display/DW/CCVPN+Service+Design
- WanConnectionService ( Another way to describe CCVPN in a single service form which based on ONF CIM ): https://wiki.onap.org/display/DW/CCVPN+Wan+Connection+Service+Design

Description
~~~~~~~~~~~
Cross-domain, cross-layer VPN (CCVPN) is one of the use cases of the ONAP Casablanca release. This release demonstrates cross-operator ONAP orchestration and interoperability with third party SDN controllers and enables cross-domain, cross-layer and cross-operator service creation and assurance.

The demonstration includes two ONAP instances, one deployed by Vodafone and one by China Mobile, both of which orchestrate the respective operator underlay OTN networks and overlay SD-WAN networks and peer to each other for cross-operator VPN service delivery.

The CCVPN Use Case Wiki Page can be found here: https://wiki.onap.org/display/DW/CCVPN%28Cross+Domain+and+Cross+Layer+VPN%29+USE+CASE.

The projects covered by this use case include: SDC, A&AI, UUI, SO, SDNC, OOF, Policy, DCAE(Holmes), External API, MSB

How to Use
~~~~~~~~~~
Design time
SOTNVPNInfraService, SDWANVPNInfraService and SIteService service Design steps can be found here: https://wiki.onap.org/display/DW/CCVPN+Service+Design
WanConnectionService ( Another way to describe CCVPN in a single service form which based on ONF CIM ): https://wiki.onap.org/display/DW/CCVPN+Wan+Connection+Service+Design

Run Time:
All opertion will be triggerd by UUI, inlcuding service creation and termination, link management and topology network display.


More details can be fonud here: https://wiki.onap.org/display/DW/CCVPN+Test+Guide

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
All test case covered by this use case: https://wiki.onap.org/display/DW/CCVPN+Integration+Test+Case

And the test status can be found: https://wiki.onap.org/display/DW/CCVPN++-Test+Status

Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1) AAI-1923. Link Management, UUI can't delete the link to external onap otn domain. 

For the manual steps provided by A&AI team, we should follow the steps as follow
the only way to delete is using the forceDeleteTool shell script in the graphadmin container.
First we will need to find the vertex id, you should be able to get the id by making the following GET request.

GET /aai/v14/network/ext-aai-networks/ext-aai-network/createAndDelete/esr-system-info/test-esr-system-info-id-val-0?format=raw

::

{
"results": [
{
"id": "20624",
"node-type": "pserver",
"url": "/aai/v13/cloud-infrastructure/pservers/pserver/pserverid14503-as988q",
"properties": {
}
}
]
}


Same goes for the ext-aai-network:

GET /aai/v14/network/ext-aai-networks/ext-aai-network/createAndDelete?format=raw

Retrieve the id from the above output as that will be the vertex id that you want to remove.

Run the following command multiple times for both the esr-system-info and ext-aai-network:

::

kubectl exec -it $(kubectl get pods -lapp=aai-graphadmin -n onap --template 'range .items.metadata.name"\n"end' | head -1) -n onap gosu aaiadmin /opt/app/aai-graphadmin/scripts/forceDeleteTool.sh -action DELETE_NODE -userId YOUR_ID_ANY_VALUE -vertexId VERTEX_ID

From the above, remove the YOUR_ID_ANY_VALUE and VERTEX_ID with your info.

2) SDC-1955. Site service Distribution

To overcome the Service distribution, the SO catalog has to be populated with the model information of the services and resources.
a) Refering to the Csar that is generated in the SDC designed as per the detailes mentioned in the below link: https://wiki.onap.org/display/DW/CCVPN+Service+Design
b) Download the Csar from SDC thus generated.
c) copy the csar to SO sdc controller pod and bpmn pod
  kubectl -n onap get pod|grep so
  kubectl -n onap exec -it dev-so-so-sdc-controller-c949f5fbd-qhfbl  /bin/sh

  mkdir null/ASDC
  mkdir null/ASDC/1
  kubectl -n onap cp service-Sdwanvpninfraservice-csar.csar  dev-so-so-bpmn-infra-58796498cf-6pzmz:null/ASDC/1/service-Sdwanvpninfraservice-csar.csar
  kubectl -n onap cp service-Sdwanvpninfraservice-csar.csar  dev-so-so-bpmn-infra-58796498cf-6pzmz:ASDC/1/service-Sdwanvpninfraservice-csar.csar

d) populate model information to SO db 
  the db script example can be seen in https://wiki.onap.org/display/DW/Manual+steps+for+CCVPN+Integration+Testing

The same would also be applicable for the integration of the client to create the service and get the details.
Currently the testing has been performed using the postman calls to the corresponding APIs.

3) SDC-1955 & SDC-1958. Site serivce parsing Error

UUI: stored the csar which created based on beijing release under a fixed directory, If site serive can't parsed by SDC tosca parser, UUI will parse this default csar and get the input parameter
a) Make an available csar file for CCVPN use case.
b) Replace uuid of available files with what existing in SDC.
c) Put available csar files in UUI local path (/home/uui).

4) SO docker branch 1.3.5 has fixes for the issues 1SO-1248.

After SDC distribution success, copy all csar files from so-sdc-controller:
    connect to so-sdc-controller( eg: kubectl.exe exec -it -n onap dev-so-so-sdc-controller-77df99bbc9-stqdz /bin/sh )
    find out all csar files ( eg: find / -name '*.csar' )
    the csar files should be in this path: /app/null/ASDC/ ( eg: /app/null/ASDC/1/service-Sotnvpninfraservice-csar.csar )
    exit from the so-sdc-controller ( eg: exit )
    copy all csar files to local derectory ( eg: kubectl.exe cp onap/dev-so-so-sdc-controller-6dfdbff76c-64nf9:/app/null/ASDC/tmp/service-DemoService-csar.csar service-DemoService-csar.csar -c so-sdc-controller )
    
Copy csar files, which got from so-sdc-controller, to so-bpmn-infra
    connect to so-bpmn-infra ( eg: kubectl.exe -n onap exec -it dev-so-so-bpmn-infra-54db5cd955-h7f5s -c so-bpmn-infra /bin/sh )
    check the /app/ASDC deretory, if doesn't exist, create it ( eg: mkdir /app/ASDC -p )
    exit from the so-bpmn-infra ( eg: exit )
    copy all csar files to so-bpmn-infra ( eg: kubectl.exe cp service-Siteservice-csar.csar onap/dev-so-so-bpmn-infra-54db5cd955-h7f5s:/app/ASDC/1/service-Siteservice-csar.csar )

5) Manual steps in closed loop Scenario:
Following steps were undertaken for the closed loop testing.
a. Give controller ip, username and password, trust store and key store file in restconf collector collector.properties
b. Updated DMAAP ip in cambria.hosts in DmaapConfig.json in restconf collector and run restconf collector
c. Followed the steps provided in this link(https://wiki.onap.org/display/DW/Holmes+User+Guide+-+Casablanca#HolmesUserGuide-Casablanca-Configurations) to push CCVPN rules to holmes
d. Followed the steps provided in this link(https://wiki.onap.org/display/DW/ONAP+Policy+Framework%3A+Installation+of+Amsterdam+Controller+and+vCPE+Policy) as reference to push CCVPN policies to policy module and updated sdnc.url, username and password in environment(/opt/app/policy/config/controlloop.properties.environment)
As per wiki (Policy on OOM), push-policied.sh script is used to install policies. but I observed that CCVPN policy is not added in this script. So merged CCVPN policy using POLICY-1356 JIRA ticket. but policy is pushed by using push-policy_casablanca.sh script during integration test.
It is found that the changes made were overwritten and hence had to patch the DG manually. This will be tracked by the JIRA SDNC-540.

all above manual steps can be found  https://wiki.onap.org/display/DW/Manual+steps+for+CCVPN+Integration+Testing