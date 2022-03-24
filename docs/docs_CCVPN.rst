.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_ccvpn:

:orphan:

CCVPN (Cross Domain and Cross Layer VPN)
----------------------------------------
Update for Jakarta Release
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Jakarta release enhances the CCVPN use-case by introducing the following three features (REG-1076):
1. Support for IBN service discovery by registering Cloud Leased Line (CLL) and Transport Slicing services to MSB
2. Support for 1+1 protection of Cloud Leased Line (CLL)
3. Support for closed-loop and user-triggered intent update

Jakarta Scope and Impacted modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The "CCVPN closed-loop" feature and the "user-triggered intent update" feature require both a front-end and a back-end system.
The front-end would be different for IBN and CCVPN, but the two features can share a common back-end.
As a first step, current bandwidth usage of a CLL should be collected from the physical network. Then VES collector API
should be called to send this information to DCAE. DCAE would then publish a new DMaaP topic to be consumed by DCAE slice
analysis micro-service. This module will then send this notification to Policy.

In Jakarta, the goal of both user-triggered intent update and CCVPN closed-loop is to ensure the max-bandwidth of the CLL service
can satisfy user's intent throughout the intent life cycle. Thus, the modify-CLL operation triggered by DCAE and Policy is
common to IBN and CCVPN. So a common back-end mechanism is implemented to support both use-cases.

The impacted ONAP modules are: CCSDK, SDN-C, A&AI, DCAE, POLICY, and SO.

Installation Procedure
~~~~~~~~~~~~~~~~~~~~~~

For Jakarta new features, the integration test environment is similar to that of
the Istanbul release: an ONAP instance with Istanbul release interfacing with 3rd party
transport domain controllers should be established.

Functional/Integration Test Cases
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The testing procedure is described in the following few test cases:
- Create and delete single CLL instance which accesses single cloud, and monitor if the closed-loop call flow is getting triggered.
- Create and delete single CLL instance which access multiple clouds, and monitor if the closed-loop call flow is getting triggered.
- Create and delete multiple CLL instances which access single cloud, and monitor if the closed-loop call flow is getting triggered.
- Create and delete multiple CLL instances which access multiple clouds, and monitor if the closed-loop call flow is getting triggered.
- Create a CLL instance which have connection links with different bandwidth, and monitor if the closed-loop call flow is getting triggered.
- Modify the bandwidth of a connection link of an existing CLL instance, and monitor if the closed-loop call flow is getting triggered.
- Modify an existing CLL instance by add a new connection link, and monitor if the closed-loop call flow is getting triggered.


Update for Istanbul Release
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Istanbul release introduces a new functionality for the CCVPN use-case:
Cloud Lease Line (CLL) service support. The following three main operations were
added in Istanbul release (REQ-719):

1. The support for creating an E-Tree service, which has one ROOT (Cloud POP) and may have
   one or more LEAFs (i.e. ONUs) as its branches.
2. The support for modifying the maximum bandwidth supported by a given E-Tree.
3. The support for deleting an E-Tree service.

Istanbul Scope and Impacted modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For operation #1 mentioned above, the user should be able to "create" an E-Tree service.
The modification operation is able to support the following scenarios:

a. An E-Tree can have one or more branches (LEAFs) located in one or multiple (different)
   domains.
b. When multiple LEAFs are physically located in a single OLT node, those LEAFs
   should re-use or share the same OTN tunnels, therefore the path computation
   mechanism should only be called once.

By operation #2 mentioned above, a user can change/modify the maximum bandwidth supported
by a given E-Tree.

And by operation #3 mentioned above, a user can delete a given E-Tree.

The impacted ONAP modules are: SO, SDN-C, and A&AI.

For A&AI, additional edge-rules were introduced between two connectivity nodes as well as
between a connectivity and a uni node.

In SDN-C, additional Directed Graphs (DGs) were implemented to support the above-mentioned
features. These new DGs are placed under the generic-resource-api folder in SDNC.

Installation Procedure
~~~~~~~~~~~~~~~~~~~~~~

For Istanbul new features, the integration test environment is similar to that of
the Honolulu release: an ONAP instance with Istanbul release interfacing with 3rd party
transport domain controllers should be established.

For E-Tree support, the installation procedure is similar to that of the E2E
Network Slicing use case. In other words, we need to bring up the required modules
including SO, ADNS, A&AI, and UUI. We also need to configure these modules along
with the mandatory common modules such as DMaaP.

Functional/Integration Test Cases
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The testing procedure is described in the following few test cases:

- create an E-Tree with one ROOT and one or multiple LEAF(s) in a multi-domain topology
- modify the maximum bw of a given E-Tree or add a new connection link to a given E-Tree
- delete a given E-Tree

To run such test cases, the user must first add (register) the domain controllers as the ESR
3rd party controllers. As a result of this registration, a round of topology discovery gets
triggered. After that, network-routes or UNI Endpoints have to be created in A&AI. This step
is similar to that of Guilin release, and is described in the following link:
https://wiki.onap.org/display/DW/Transport+Slicing+Configuration+and+Operation+Guidance

Then an E-Tree creation, modification and deletion can be triggered from SO APIs.



Update for Honolulu Release
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Honolulu release continued to support and extend the Transport Slicing functionality
developed in Guilin release. Two main features were aded in Honolulu release (REQ-456):

1. The support for reuse and modification of an existing TN NSSI has been developed.
2. In addition, the Honolulu release also continuted to support and extend the CCVPN
   use-case and in particular, the support for inter-domain connections of three or
   more network domains has been introduced in Honolulu release. (CCVPN in previous
   releases were only be able to connect two domains).

Honolulu Scope and Impacted modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For feature #1 mentioned above, the user should be able to "modify" a Transport Slice.
The modification operation is able to support the following three scenarios:

a. A user may "Add" one or more new service(s)/connections link(s) to a given slice
   (TN NSSI) that is already created.
b. A user may need to change or modify the maximum bandwidth attribute (i.e. the SLA
   agreement) using which a given slice is created.
c. Both of the above operations.

For feature #2 mentioned above, now in H release, we can have and support an artibrary
number of domains inter-connected to each other and we can support a cross-layer
cross-domain VPN connectivity and transport slicing for these kinds of scenarios as well.

Impacted ONAP modules include: SO, SDN-C, CCSDK, A&AI.

In CCSDk, a path computation engine (PCE) mechanism is introduced to support a
graph-based path computation in a multi-domain network topologies. This PCE system is
implemented as a SLI plugin to be called and used by Directed Graphs (DGs).

For A&AI, additional attributes were introduced to the connectivity node and vpn-binding node.

In SDN-C, additional Directed Graphs (DGs) were implemented to support the above-mentioned
two features.

Installation Procedure
~~~~~~~~~~~~~~~~~~~~~~

For Honolulu new features, the integration test environment is similar to that of the Guilin
release: an ONAP instance with Honolulu release interfacing to 3rd party transport domain
controllers should be established.

For Transport Slicing, the installation procedure is similar to that of the E2E
Network Slicing use case. In other words, we need to bring up the required modules
including SDC, SO, A&AI, UUI and OOF. We also need to configure these modules along
with the mandatory common modules such as DMaaP.

Functional/Integration Test Cases
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The testing procedure is described in the following few test cases:

- service/template design: Successful design of TN NSST and Slice Profile
- modify max-bandwidth of existing TN NSSI: Modify the maximum bandwidth of an existing TN NSSI
- modify connection links existing TN NSSI: Add new connection links to existing TN NSSI
- modify both max-bandwidth and connection links of TN NSSI: Modify both the maximum bandwidth and add new connection links to an existing TN NSSI
- three-domain network: Test create TN NSSI (or other NSI life cycle operations) on a three-domain network (i.e., need 3 ACTN PNC simulators)



Update for Guilin Release
~~~~~~~~~~~~~~~~~~~~~~~~~

In Guilin Release, **MDONS** Extension feature is introduced.

In addition to the MDONS extension, CCVPN has also developed an
IETF/ACTN-based Transport Slicing solution (REQ-347). This development
enabled ONAP to offer the TN NSSMF functionality, which was used by
the E2E Network Slicing use case (REQ-342).  The solution was built
upon the existing IETF/ACTN E-LINE over OTN NNI feature developed in Frankfurt release.

Guilin Scope and Impacted modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MDONS Extension implementation for the Frankfurt release will incorporate the following:

- Support Asynchronous OpenRoadM OTN service activation notification handling
- Add OOF support for inter domain link/path selection
- Support Closed Loop sub-use case

Impacted ONAP modules include: OOF, SDN-C, SO and Holmes.

`Wiki link reference <https://wiki.onap.org/display/DW/MDONS+Extension+in+R7>`_

Transport Slicing in Guilin release has implemented the following TN NSSMF functionality:

- Allocate TN NSSI
- Deallocate TN NSSI
- Activate TN NSSI
- Deactivate TN NSSI

The Tranport Slicing implementation has made code changes in the following modules:

- AAI (Schema changes only)
- UUI
- SO
- OOF
- SDN-C
- CCSDK
- Modelling

Functional/Integration Test Cases
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For integration test case and description of MDONS extension, refer to this
`following wiki-page <https://wiki.onap.org/display/DW/Integration+Test+Cases+-+MDONS+Extension>`_.

For integration test case and description of Transport Slicing:

- `Guilin Test plan <https://wiki.onap.org/display/DW/CCVPN+-+Transport+Slicing+integration+test+plan+for+Guilin+release>`_
- `Guilin E2E Network Slicing <https://wiki.onap.org/display/DW/E2E+Network+Slicing+Use+Case+in+R7+Guilin>`_

Installation Procedure
~~~~~~~~~~~~~~~~~~~~~~

For MDONS extension, the integration test environment is established to have ONAP instance with Guilin
release interfacing to 3rd party transport domain controllers. One controller
instance manages OpenROADM OTN topology and the other 2 instances manage TAPI
OTN topology. L0 infrastructure and WDM services are pre-provisioned to support
L1 topology discovery and OTN service orchestration from ONAP.

For Transport Slicing, the installation procedure is similar to that of the E2E
Network Slicing use case. In other words, we need to bring up the required modules
including SDC, SO, A&AI, UUI and OOF. We also need to configure these modules along
with the mandatory common modules such as DMaaP.

Testing Procedures
~~~~~~~~~~~~~~~~~~

The testing procedure is described in:

- `Testing procedure for MDONS extension <https://wiki.onap.org/display/DW/Integration+Test+Cases+-+MDONS+Extension>`_
- `Testing procedure for Transport Slicing <https://wiki.onap.org/display/DW/CCVPN+-+Transport+Slicing+integration+test+plan+for+Guilin+release>`_

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
interfaces, such as the IETF ACTN-based transport `YANG models <https://tools.ietf.org/html/rfc8345>`_, as the southbound interface
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

Testing Procedure
~~~~~~~~~~~~~~~~~
Design time
SOTNVPNInfraService service design in SDC and distribute to AAI and SO.

Run Time:
All operation will be triggered by UUI, including service creation and termination,
link management and topology network display:

- `E-LINE over OTN Inter Domain Test Cases <https://wiki.onap.org/display/DW/E-LINE+over+OTN+Inter+Domain+Test+Cases>`_
- `Testing status <https://wiki.onap.org/display/DW/2%3A+Frankfurt+Release+Integration+Testing+Status>`_

MDONS (Multi-Domain Optical Network Services)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Overall Description
~~~~~~~~~~~~~~~~~~~

The MDONS use-case aims to automate the design, activation & operations resulting
from an optical transport (L0/L1) service request exchange between service providers and/or independent operational entities within a service provider network by delivering E2E optical orchestration capabilities into ONAP. MDONS extends upon the CCVPN use-case by incorporating support for L0/L1 network management capabilities leveraging open standards & common data models defined by OpenROADM, Transport-API & MEF.

Frankfurt Scope and Impacted modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MDONS implementation for the Frankfurt release will incorporate the following:
- Design & modelling of optical services based on MEF L1 subscriber & operator properties
- E2E optical service workflow definitions for service instantiation & deletion
- UI portal with L1 service instantiation templates
- Optical Transport domain management (topology, resource onboarding) through standard models / APIs - OpenROADM, T-API
Impacted ONAP modules include: A&AI, SDC, SDN-C, SO, UUI

References:

- `OpenROADM reference <https://github.com/OpenROADM/OpenROADM_MSA_Public>`_
- `ONF Transport-API (TAPI) <https://github.com/OpenNetworkingFoundation/TAPI>`_
- `MEF <https://wiki.mef.net/display/CESG/MEF+63+-+Subscriber+Layer+1+Service+Attributes>`_

Functional/Integration Test Cases
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For integration test case and description, refer to this following
`wiki-page <https://wiki.onap.org/display/DW/MDONS+Integration+Test+Case>`_.

Installation Procedure
~~~~~~~~~~~~~~~~~~~~~~

The integration test environment is established to have ONAP instance with
Frankfurt release interfacing to 3rd party transport domain controllers.
One controller instance manages OpenROADM OTN topology and the other 2 instances
manage TAPI OTN topology. L0 infrastructure and WDM services are pre-provisioned
to support L1 topology discovery and OTN service orchestration from ONAP.

Testing Procedure
~~~~~~~~~~~~~~~~~

Test environment is described in
`Installation and Test Procedure <https://wiki.onap.org/display/DW/MDONS+Integration+Test+Case>`_.

Update for Dublin release
~~~~~~~~~~~~~~~~~~~~~~~~~

1. Service model optimization

In Dublin release,the design of CCVPN was optimized by having support of List type of Input in SDC.
During onboarding and design phase, one end to end service is created using SDC.
This service is composed of these two kinds of resources:

- VPN resource
- Site resource

See the `Details of Targeted Service Template wiki page <https://wiki.onap.org/display/DW/Details+of+Targeted+Service+Template>`_
for details.

2. Closed Loop in bandwidth adjustment
Simulate alarm at the edge site branch and ONAP will execute close-loop automatically and trigger bandwidth to change higher.

3. Site Change
Site can be add or delete according to the requirements

More information about:

- `CCVPN in Dublin release <https://wiki.onap.org/pages/viewpage.action?pageId=45296665>`_
- `Dublin test cases <https://wiki.onap.org/display/DW/CCVPN+Test+Cases+for+Dublin+Release>`_
- `CCVPN Test Status wiki page <https://wiki.onap.org/display/DW/CCVPN+Test+Status>`_

.. note::
    CCVPN integration testing coversed service design, service creation and
    closed-loop bandwidth adjustments in Dublin release.

    The service termination and service change will continue to be tested in E release.
    During the integration testing, SDC, SO, SDC master branch are used which
    includes the enhanced features for CCVPN use case.

Service used for CCVPN
~~~~~~~~~~~~~~~~~~~~~~

- `SOTNVPNInfraService, SDWANVPNInfraService and SIteService <https://wiki.onap.org/display/DW/CCVPN+Service+Design>`_
- `WanConnectionService (Another way to describe CCVPN in a single service form which based on ONF CIM <https://wiki.onap.org/display/DW/CCVPN+Wan+Connection+Service+Design>`_

Description
~~~~~~~~~~~

Cross-domain, cross-layer VPN (CCVPN) is one of the use cases of the ONAP
Casablanca release. This release demonstrates cross-operator ONAP orchestration
and interoperability with third party SDN controllers and enables cross-domain,
cross-layer and cross-operator service creation and assurance.

The demonstration includes two ONAP instances, one deployed by Vodafone and one
by China Mobile, both of which orchestrate the respective operator underlay OTN
networks and overlay SD-WAN networks and peer to each other for cross-operator
VPN service delivery.

`CCVPN Use Case Wiki Page <https://wiki.onap.org/display/DW/CCVPN%28Cross+Domain+and+Cross+Layer+VPN%29+USE+CASE>`_

The projects covered by this use case include: SDC, A&AI, UUI, SO, SDNC, OOF, Policy, DCAE(Holmes), External API, MSB

How to Use
~~~~~~~~~~

Design time:

- `SOTNVPNInfraService, SDWANVPNInfraService and SIteService service Design steps <https://wiki.onap.org/display/DW/CCVPN+Service+Design>`_
- `WanConnectionService ( Another way to describe CCVPN in a single service form which based on ONF CIM ) <https://wiki.onap.org/display/DW/CCVPN+Wan+Connection+Service+Design>`_

Run Time:

- All operations will be triggered by UUI, including service creation and termination,
  link management and topology network display.


See the `CCVPN Test Guide wiki page <https://wiki.onap.org/display/DW/CCVPN+Test+Guide>`_
for details.

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~

- `All test case covered by this use case <https://wiki.onap.org/display/DW/CCVPN+Integration+Test+Case>`_
- `Test status <https://wiki.onap.org/display/DW/CCVPN++-Test+Status>`_

Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1) AAI-1923. Link Management, UUI can't delete the link to external onap otn domain.

For the manual steps provided by A&AI team, we should follow the steps as follow
the only way to delete is using the forceDeleteTool shell script in the graphadmin container.
First we will need to find the vertex id, you should be able to get the id by making the following GET request.

GET /aai/v14/network/ext-aai-networks/ext-aai-network/createAndDelete/esr-system-info/test-esr-system-info-id-val-0?format=raw

.. code-block:: JSON

  {

    "results": [
      {
        "id": "20624",
        "node-type": "pserver",
        "url": "/aai/v13/cloud-infrastructure/pservers/pserver/pserverid14503-as988q",
        "properties": {}
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
a) Refering to the Csar that is generated in the SDC designed as per the details mentioned in the below link: https://wiki.onap.org/display/DW/CCVPN+Service+Design
b) Download the Csar from SDC thus generated.
c) copy the csar to SO sdc controller pod and bpmn pod

.. code-block:: bash

  kubectl -n onap get pod|grep so
  kubectl -n onap exec -it dev-so-so-sdc-controller-c949f5fbd-qhfbl  /bin/sh
  mkdir null/ASDC
  mkdir null/ASDC/1
  kubectl -n onap cp service-Sdwanvpninfraservice-csar.csar  dev-so-so-bpmn-infra-58796498cf-6pzmz:null/ASDC/1/service-Sdwanvpninfraservice-csar.csar
  kubectl -n onap cp service-Sdwanvpninfraservice-csar.csar  dev-so-so-bpmn-infra-58796498cf-6pzmz:ASDC/1/service-Sdwanvpninfraservice-csar.csar

d) populate model information to SO db: the db script example can be seen in
   https://wiki.onap.org/display/DW/Manual+steps+for+CCVPN+Integration+Testing

The same would also be applicable for the integration of the client to create the service and get the details.
Currently the testing has been performed using the postman calls to the corresponding APIs.

3) SDC-1955 & SDC-1958. Site service parsing Error

UUI: stored the csar which created based on beijing release under a fixed directory, If site servive can't parsed by SDC tosca parser, UUI will parse this default csar and get the input parameter
a) Make an available csar file for CCVPN use case.
b) Replace uuid of available files with what existing in SDC.
c) Put available csar files in UUI local path (/home/uui).

4) SO docker branch 1.3.5 has fixes for the issues 1SO-1248

After SDC distribution success, copy all csar files from so-sdc-controller:

- connect to so-sdc-controller ( eg: kubectl.exe exec -it -n onap dev-so-so-sdc-controller-77df99bbc9-stqdz /bin/sh )
- find out all csar files ( eg: find / -name "\*.csar" ), the csar files should
  be in this path: /app/null/ASDC/ ( eg: /app/null/ASDC/1/service-Sotnvpninfraservice-csar.csar )
- exit from the so-sdc-controller ( eg: exit )
- copy all csar files to local derectory ( eg: kubectl.exe cp onap/dev-so-so-sdc-controller-6dfdbff76c-64nf9:/app/null/ASDC/tmp/service-DemoService-csar.csar service-DemoService-csar.csar -c so-sdc-controller )

Copy csar files, which got from so-sdc-controller, to so-bpmn-infra:

- connect to so-bpmn-infra ( eg: kubectl.exe -n onap exec -it dev-so-so-bpmn-infra-54db5cd955-h7f5s -c so-bpmn-infra /bin/sh )
- check the /app/ASDC directory, if doesn't exist, create it ( eg: mkdir /app/ASDC -p )
- exit from the so-bpmn-infra ( eg: exit )
- copy all csar files to so-bpmn-infra ( eg: kubectl.exe cp service-Siteservice-csar.csar onap/dev-so-so-bpmn-infra-54db5cd955-h7f5s:/app/ASDC/1/service-Siteservice-csar.csar )
