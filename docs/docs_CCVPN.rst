CCVPN
----------------------------

Sevice used for CCVPN 
~~~~~~~~~~~~

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
Refering to the Csar that is generated in the SDC designed as per the detailes mentioned in the below link: https://wiki.onap.org/display/DW/CCVPN+Service+Design
One can download the Csar thus generated.
The same would also be applicable for the integration of the client to create the service and get the details.
Currently the testing has been performed using the postman calls to the corresponding APIs.

3) SDC-1955 & SDC-1958. Site serivce parsing Error

UUI: stored the csar which created based on beijing release under a fixed directory, If site serive can't parsed by SDC tosca parser, UUI will parse this default csar and get the input parameter

SO: SO catalog has to be populated with the model information of site service 

4) SO-1248. Csar needs to be manually placed into the bpmn corresponding directory

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

