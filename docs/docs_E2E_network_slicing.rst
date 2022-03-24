.. This file is licensed under the CREATIVE COMMONS ATTRIBUTION 4.0 INTERNATIONAL LICENSE
.. Full license text at https://creativecommons.org/licenses/by/4.0/legalcode

.. contents::
   :depth: 3
..
.. _docs_E2E_network_slicing:


E2E Network Slicing Use Case
============================

Overall Blueprint
-----------------
The objective of this use case is to realize **End-to-End 5G Network
Slicing** using ONAP. An End-to-End Network Slice consists of RAN (Radio
Access Network), Transport Network (TN) and Core Network (CN) slice
sub-nets. This use case intends to demonstrate the modeling,
orchestration (life cycle and resources) and assurance of a network
slice which are implemented in alignment with relevant standards. The
key highlights of this use case include:

-  Modular architecture providing building blocks and flexibility under
   various deployment scenarios

-  Functionality aligned with 3GPP and other relevant standards such as
   ETSI and IETF

-  Interfaces and APIs aligned with relevant standards (3GPP, IETF,
   ETSI, TM Forum, etc.) while enabling easy customization through use
   of appropriate plug-ins. This would enable easier interoperability of
   slice management functions realized within ONAP with 3\ :sup:`rd`
   party slice management functions, as well as northbound and
   southbound systems.

-  Taking a step-by-step approach to realizing different architectural
   options in an extendable manner.

-  Providing flexibility in network slice selection by providing an
   option of manual intervention, as well as abstracting the network
   internals as needed.

-  The use case implementation team is composed of service providers,
   software and hardware vendors, solution providers and system
   integrators thereby taking into consideration different perspectives
   and requirements.

This use case is a multi-release effort in ONAP with the first steps
taken in Frankfurt release. It will continue to expand in scope both in
breadth and depth, and along the journey it shall also align with
updates to the relevant standards which are also currently evolving.
This use case shall also collaborate with SDOs such as
O-RAN and ETSI to enable wider adoption and use.

Architecture Choice
-------------------
3GPP(TS 28.801) defines three layer slice management functions which include:

CSMF(Communication Service Management Function):

• Responsible for translating the communication service related requirement to network slice related requirements.

• Communicate with Network Slice Management Function (NSMF).

NSMF(Network Slice Management Function):

• Responsible for management and orchestration of NSI.
• Derive network slice subnet related requirements from network slice related requirements.
• Communicate with the Network Slice Subnet Management Function (NSSMF) and Communication Service Management Function.

NSSMF(Network Slice Subnet Management Function):

• Responsible for management and orchestration of NSSI.
• Communicate with the NSMF.

To realize the three layers of the slice management function, we need to decide whether to implement CSMF, NSMF or NSMF within ONAP, or use the external CSMF, NSMF or NSSMF. This implies that for ONAP-based network slice management, we have different choices from an architectural perspective:

1) Implement CSMF, NSMF, NSSMF all within ONAP;

2) Connect an external CSMF from the Northbound, Implement NSMF and NSSMF within ONAP;

3) Connect an external CSMF from the Northbound, Implement NSMF within ONAP, Connect a 3rd party NSSMF from the Southbound;

4) Implement CSMF, NSMF within ONAP, Connect a 3rd party NSSMF from then Southbound.

5) Use external CSMF and NSMF, only implement NSSMF within ONAP.

External Interfaces
-------------------
The guiding principle is when a Slice Management function is outside ONAP, standard interfaces/APIs (3GPP, IETF, ETSI, TM Forum, etc.) can be supported by default, while any customization of such interfaces shall also be supported by ONAP using suitable plug-ins/adaptors. This would enable easier interoperability of slice management functions realized within ONAP with 3rd party slice management functions, as well as northbound and southbound systems.

Another key point would be that both internal and external interface mechanisms should be supported by the corresponding ONAP modules. To be more specific, communication between Slice Management Functions within ONAP (e.g., CSMF and NSMF) shall use ONAP internal mechanisms such as workflow calls, DMaaPmessages, etc. or standard APIs as appropriate. For example, SO acting as NSMF should support API call directly from CSMF in ONAP, as well as API trigger from an external CSMF via EXT-API.

Network Slice Instance (NSI) Life Cycle View
--------------------------------------------
3GPP Specification (3GPP TS 28.530) describes management aspects of a Network Slice Instance, which can be described by the four phases:

- Preparation: The preparation phase includes network slice design, network slice capacity planning, on-boarding and evaluation of the network functions, preparing the network environment and other necessary preparations required to be done before the creation of an NSI.
- Commissioning: NSI provisioning in the commissioning phase includes creation of the NSI. During NSI creation all needed resources are allocated and configured to satisfy the network slice requirements. The creation of an NSI can include creation and/or modification of the NSI constituents.
- Operation: The Operation phase includes the activation, supervision, performance reporting (e.g. for KPI monitoring), resource capacity planning, modification and de-activation of an NSI.
- Decommissioning: Network slice instance provisioning in the decommissioning phase includes decommissioning of non-shared constituents if required and removing the NSI specific configuration from the shared constituents. After the decommissioning phase, the NSI is terminated and does not exist anymore.
The ONAP-based NSI lifecycle management will finally provide the demonstration of all these phases.

Abbreviations
-------------

+---------------+--------------------------------------------+
|  Abbreviation |                   Meaning                  |
+===============+============================================+
| CSMF          | Communication Service Management Function  |
+---------------+--------------------------------------------+
| CSI           | Communication Service Instance             |
+---------------+--------------------------------------------+
| CST           | Communication Service Template             |
+---------------+--------------------------------------------+
| NSI           | Network Slice Instance                     |
+---------------+--------------------------------------------+
| NSMF          | Network Slice Management Function          |
+---------------+--------------------------------------------+
| NSSI          | Network Slice Sub-net Instance             |
+---------------+--------------------------------------------+
| NSSMF         | Network Slice Sub-net Management Function  |
+---------------+--------------------------------------------+
| NST           | Network Slice Template                     |
+---------------+--------------------------------------------+
| NSST          | Network Slice Sub-net Template             |
+---------------+--------------------------------------------+


Recap of Frankfurt functionality
--------------------------------
In Frankfurt release, CSMF and NSMF within ONAP was implemented, while connecting to an external Core NSSMF.
From the NSI Life Cycle perspective, the scope for Frankfurt included NSI design and pre-provision, NSI instantiation
and configuration, and NSI activation and deactivation. In particular:

- CSMF: Functions of slice service creation, slice service activation and deactivation were implemented.

- NSMF: Functions of NSI instantiation, NSI activation and deactivation were implemented. In addition, manual
  intervention is also provided in NSMF slice task management portal to ensure the selected NSI/NSSI as well as
  Service Profile and Slice Profile are OK or need adjustment.

- Design of CST, NST and onboarding NSST that are required to support the run-time orchestration functions

- To connect to the external (core) NSSMF, an adaptor was implemented to provide interface between ONAP and 3rd party
  core NSSMF.

To support the above functions, code impacts in U-UI, SO, OOF and ExtAPI components, and schema change in A&AI
were implemented. See the `Proposed Functions for R6 and Impacted Modules wiki page <https://wiki.onap.org/display/DW/Proposed+Functions+for+R6+and+Impacted+Modules>`_ for details.

As part of Frankfurt release work, we supported the minimum-scope installation of ONAP to reduce the resource requirements.
From the module perspective, 5G E2E Slicing use case involves SDC, SO, A&AI, UUI, EXT-API, OOF and Policy modules of ONAP.
So we will configure these required modules along with the mandatory common modules such as DMaaP. Further, for each module,
the use case also does not use all of the charts，so we removed the not needed Charts under those modules to optimize the
resources required for setting up the use case. This approach will help to install a minimum-scope version ONAP for the
E2E Slicing use case.

Further details of the installation steps are available at: `Install Minimum Scope ONAP for 5G Network Slicing wiki page
<https://wiki.onap.org/display/DW/Install+Minimum+Scope+ONAP+for+5G+Network+Slicing>`_

Recap of Guilin functionality
-----------------------------
From the architecture point of view, in Guilin release, besides the continuation of NSMF which was implemented in
Frankfurt release, the RAN NSSMF, TN NSSMF, CORE NSSMF have been implemented within ONAP, apart from interacting with
external RAN NSSMF and external CORE NSSMF.

The following provides an overview of the enhancements done in Guilin release:

- **Enhancements in NSMF**: Service Profile decomposition into Slice Profiles for 3 domains, NSI selection enhancement,
  E2E slice instance creation including RAN, TN and CN slice sub-net instance creation/reuse, activation/deactivation
  of E2E slice, and deciding whether to terminate E2E slice or not.

- **RAN NSSMF, TN NSSMF, CN NSSMF within ONAP**: Basic logic for all 3 NSSMFs to support NSSI allocation, activation,
  deactivation, deletion and modification (in case of reuse of NSSI).

- **Enable NSMF interaction with RAN NSSMF, TN NSSMF, CN NSSMF**: Implement generic NSSMF adaptor for three domain NSSMFs,
  alignment with standard interfaces (3GPP, IETF), enable the connection to external RAN NSSMF.

- **Design of RAN NSST, TN NSST, CN NSST and Slice Profiles, TN information models**: Basic E2E Slicing model was provided
  all the related templates designed from SDC, TN related information models.

- **TMF 641 support**: Extension of the TMF 641 based interface from NB of ExtAPI to support service activation,
  deactivation and termination.

- **RAN and CN NFs set up and initial configurations**: CN NF simulators was developed: AMF, SMF, UPF and configure the
  S-NSSAI on CN NFs; RAN NF Simulator was enhanced for PM data reporting, CU and Near-RT RIC configuration.

- **KPI monitoring**: Implementation to request details of a KPI via UUI to ONAP DCAE. Providing the requested data to UUI
  by DCAE using a new microservice (Data Exposure Service - DES). Enhancements in PM-Mapper to do KPI computation is
  in progress, and will be completed in Honolulu release.

- **Closed Loop**: First steps to realizing a simple Closed Loop in the RAN using PM data collected from the RAN was
  implemented - update the allowed throughput for a S-NSSAI per Near-RT RIC coverage area based on DL/UL PRB for data
  traffic that was reported from the RAN. The analysis of the PM data was done using a new Slice Analysis MS in DCAE,
  and the Policy-based Control Loop framework was applied to trigger the updates in the RAN.

- **Intelligent Slicing**: First steps to realizing a simple ML-based Closed Loop action in the RAN using PM data collected
  from the RAN was implemented - update the maxNumberofConns for a S-NSSAI in each cell based on PDU session related
  PM data that was reported from the RAN (PDU sessions requested, successfully setup and failed to be set up). The
  training was done offline, and the ML model is onboarded as a micro-service to ONAP for demo purpose alone (it is
  not part of ONAP code/repos). The ML model provides updates to the Slice Analysis MS, which then uses the
  Policy-based Control Loop framework to trigger the updates in the RAN.

- **Modeling enhancements**: Necessary modeling enhancements to support all the above functionalities.

The base use case page for Guilin release is `E2E Network Slicing Use Case in R7 Guilin <https://wiki.onap.org/display/DW/E2E+Network+Slicing+Use+Case+in+R7+Guilin>`_.

The child wiki pages of the above page contains details of the assumptions, flows and other relevant details.

Honolulu release updates
------------------------
In Honolulu release, the following aspects were realized:

- **Modeling Enhancements** were made, details can be found at:
  `Modeling enhancements in Honolulu <https://wiki.onap.org/display/DW/Modeling+enhancements+in+Honolulu>`_.

- **Functional Enhancements**

  (a) Minor enhancements in NSMF and NSSMFs including NST Selection, Shared slices, coverageArea to
      coverageAreaTAList mapping, etc.
  (b) Enhancements related to endpoints for stitching together an end-to-end network slice
  (c) Use of CPS (instead of Config DB) to determine the list of Tracking Areas corresponding to a given
      Coverage Area (input by user). For the remaining RAN configuration data, we continue to use Config DB.
  (d) RRM Policy update by SDN-R to RAN NFs during RAN NSSI creation/reuse

- **Integration Testing**
  Continuing with integration tests deferred in Guilin release, and associated bug-fixing

Important Remarks
~~~~~~~~~~~~~~~~~~~
(a) 2 deployment scenarios for RAN NSSI are supported. In the first scenario, the RAN NSSI comprises also of
    TN Fronthaul (FH) and TN Midhaul (FH) NSSIs, and RAN NSSMF shall trigger TN NSSMF for TN FH and MH NSSI
    related actions. In the second scenario, the RAN NSSI comprises only of RAN NFs. TN NSSMF shall be triggered by
    NSMF for TN FH and MH NSSI related actions. This part is not yet implemented in NSMF within ONAP.

(b) Details of the modeling aspects, flows and other relevant info about the use case are available in:
    `R8 E2E Network Slicing Use Case <https://wiki.onap.org/display/DW/R8+E2E+Network+Slicing+use+case>`_ and its child wiki pages.


Impacted Modules for Honolulu
-----------------------------
The code-impacted modules of E2E Network Slicing in Honolulu release are:

- **UUI**: The enhancements done include:

  (a) The coverageArea The coverageArea number param is added in CSMF creation UI. Users could input
      the grid numbers to specify the area where they want the slicing service to cover.
  (b) The relation link image of AN/TN/CN has been added. Users can see the links and related params
      of the three domains.
  (c) The TN’s connection link with AN/CN has been added in NS Task management GUI.

- **AAI**: Schema changes were introduced. We added some new parameters in 2 nodes:

  (a) ‘Connectivity’ is used to store IETF/ACTN ETH service parameters. New attributes added in order
      to support the CCVPN network configuration operations on multi-domain (2+) interconnections.
  (b) ‘Vpn-binding’is used to store ACTN OTN Tunnel model’s parameters.

- **OOF**: Updates include:

  (a) NST selection is enhanced by fetching the templates from SDC directly.
  (b) coverageArea to coverageAreaTAList mapping is done by OOF (as part of Slice Profile generation)
      by accessing CPS.
  (c) Bug-fixes

- **SO**: Main updates include support of NSI shared scenarios by enhancing the interaction with OOF, AAI and
  UUI. Apart from this some updates/fixes have been made in NSMF, RAN/Core/TN NSSMF functionality in SO, for
  example:

  (a) *NSMF*: Update NSI selection process support shared NSI and add sst parameter
  (b) *AN NSSMF*: Activation flow for SDN-R interactions, allocate flow & added timeDelay in QueryJobStatus,
      support of Option 1 for topmost RAN NSSI
  (c) *CN NSSMF*: Non-shared allocate flow
  (d) *TN NSSMF*: Modify TN NSSI operation

- **CPS**: 2 APIs required for the use case are supported. The remaining yang models are also onboarded,
  however, the API work as well as further enhancements to CPS Core, NF Proxy and Template-Based Data
  Model Transformer Service shall continue beyond Honolulu.

- **SDN-R**: RRMP Policy updates, enhancements for updating the RAN configuration during slice reuse,
  closed loop and intelligent slicing.

- **DCAE**:

  (a) *KPI Computation MS*: This MS was introduced newly for computation of slice related KPIs. In this release,
      it supports basic KPI computation based on formula specified via Policy. Further details about this MS is
      available at `KPI Computation MS <https://wiki.onap.org/display/DW/DCAE+R8+KPI-Computation+ms>`_
  (b) *Slice Analysis MS*: Minor updates were done.

Apart from the above, Policy and SDC had test-only impact for this use case.

In addition:

- **Config DB** was updated to handle bugs and gaps found during testing. This is not an official ONAP component, and
  its functionality is expected to be performed fully by the Configuration Persistence Service (CPS) in future ONAP
  release (beyond Honolulu).

- **Core NF simulator** and *ACTN simulator* were also updated and checked into ONAP simulator repo.

- **RAN-Sim** has been updated to fix bugs found during testing, and also checked into ONAP simulator repo.


Functional Test Cases
---------------------
The functional testing of this use case shall cover CSMF/NSMF, the 3 NSSMFs and Closed Loop functionality. We classify the
test cases into 5 tracks: CSMF/NSMF, RAN NSSMF, Core NSSMF, TN NSSMF and Closed Loop.
Details of the test cases can be found at:
`Integration Test details for Honolulu <https://wiki.onap.org/display/DW/Integration+Test+details+for+Honolulu>`_ and its child wiki pages.


Operation Guidance
------------------
The Honolulu release setup details for the E2E Network Slicing use case will be available at the following page and its
sub-pages:
`User Operation Guide for Honolulu release <https://wiki.onap.org/display/DW/User+Operation+Guide+for+Honolulu+release>`_


Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Details of manual configurations, work-arounds and known issues will be documented in the child wiki pages of:
`User Operation Guide for Honolulu release <https://wiki.onap.org/display/DW/User+Operation+Guide+for+Honolulu+release>`_

The foll. integration tests are carried over to Istanbul release: see `REQ-721 <https://jira.onap.org/browse/REQ-721>`_
- NSMF: Option 2 testing, remaining regression testing and service termination testing for NSMF
- RAN NSSMF: RAN NSSI termination, interactions with TN NSSMF for FH/BH NSSI reuse and some minor aspects related to SDN-R <-> RAN interaction
- TN NSSMF: Checking some minor aspects in SO for modifying TN NSSI.
- Core NSSMF: Modifying and deallocating a Core NSSI, reusing an existing Core NSSI
- KPI Computation, Closed Loop & Intelligent Slicing: Some minor aspects on SDN-R <-> RAN-Sim interface needs to be addressed.

Further details of these test cases can be found in REQ jiras for integration testing for Honolulu, and in the
use case wiki. This means that the functionality associated with these test cases may require updated versions
of the relevant components - the User Operation Guide will also be updated with details of any bug fixes
beyond Honolulu as the testing is anyhow continuing as part of Istanbul release.

Istanbul release updates
------------------------
Below aspects are covered in Istanbul release:

1. **CPS-TBDMT Enhancements** - This service shall be used to map the erstwhile Config-DB-like REST APIs to appropriate CPS API calls. The purpose of this service is to abstract the details of (possibly multiple, and complex) XPath queries from the users of CPS. It enables CPS-users to continue using simple REST API calls that are intuitive and easy-to-understand and implement. The mapping to appropriate queries to CPS (including mapping of one API call to many Xpath queries) shall be done in a generic way by the CPS-TBDMT service. In Istanbul release, following are the main enhancements done:

    - Support edit query ie. post, put and patch requests to CPS

    - Support Output Transformation

      (a) Extract desired output from the data returned from CPS.
      (b) If 'transformParam' is not defined in the template no transformation takes place.
    - Support Multiple query

      (a) Make multiple queries to CPS in single request.
      (b) If 'multipleQueryTemplateId' is mentioned in the template, it will execute this template first  and insert the result to the current template to make multiple queries to CPS.
    - Support Delete data requests to CPS

      (a) Process delete request type.
    - Support for dynamic anchor - Accept anchors at run time and execute query

2. **CPS Integration**

    - Config DB is replaced with the CPS component to read, write, update and delete the RAN Slice details. CPS APIs are accessed via CPS-TBDMT component. CPS integration with DCAE - Slice Analysis MS and OOF are completed. SDN-R integration with CPS is completed for the shared RAN Slice flow, activateRANslice and terminateRANSlice implementations are in progress.
    - A new SDN-C karaf feature is introduced to register the cm-handle (anchor) with CPS. The integration with CPS-DMI plugin will be done in Jakarta release.

3. **NSMF based TN Slices** - Support for interacting with TN NSSMF directly from NSMF for front haul and mid haul slice subnets. There will be separate SDC template for this scenario. NST will have 5 NSSTs - CN NSST, AN NSST, TN FH NSST, TN MH NSST, TN BH NSST.

4. **KPI Monitoring** - Implementation is done in KPI Computation MS to configure the required KPIs and the KPI computation formula based on policies.

5. **Closed Loop** - Closed Loop updates are sent over A1 interface to Near-RT RIC. This is done at the POC level. This will be further enhanced in Jakarta release to make use of the A1-Policy Management Service in CCSDK.

6. **Intelligent Slicing** - End to end intelligent slicing - closed loop flow is tested with the initial version of Machine Learning MS.

7. **Carry-over Testing from Honolulu Release**

    - RAN NSSMF Testing

      (a) Testing completed for the allocation, modification, activation and deactivation of the RAN slice to support option1
      (b) Integration Testing of AN NSSMF with SDNR interactions for allocate and modify flow is completed
    - E2E Testing

      (a) Service instantiation for non-shared and shared scenario and fixes to support option 1 are done
      (b) NSI selection process support for shared NSI is tested

Impacted Modules for Istanbul Release
-------------------------------------
- **SO**
    (a) Support of NSI termination by enhancing the interaction with OOF, AAI and UUI
    (b) RAN NSSI Termination support with OOF & SDN-R interactions
    (c) Bug fixes in Option 1 (CSMF, NSMF and NSSMFs are within ONAP & TN-FH, TN-MH are created by RAN NSSMF)
        - **CSMF**: Fixed sNSSAI format and updated authentication for NSMF invocation
        - **NSMF**: Fixes in NSI termination issues to support OOF interaction for NSI termination query and added subnet Type support for respective TN Domain
        - **AN NSSMF**: Fixes for different termination scenarios in Option 1
        - **CN NSSMF**: Bug fixes in shared allocate flow, modify flow and terminate flow
        - Slice Profile alignment with NSSMF
    (d) NSMF based TN Slices (TN-FH, TN-MH are created by NSMF) - Work flow changes to support this approach

- **OOF**
    (a) Integration with CPS for coverage area to coverage area TA list
    (b) Bug fixes in NxI termination

- **DCAE**
    (a) Minor changes in Slice Analysis MS to support CPS integration
    (b) KPI Computation MS in enhanced to support policy based KPIs and formula

- **SDN-R**
    (a) Bug fixes in instantiateRANSliceAllocate, instantiateRANSliceAllocateModify, activateRANSlice, terminateRANSlice Directed Graphs
    (b) CPS integration for the instantiateRANSliceAllocateModify, activateRANSlice, terminateRANSlice Directed Graphs
    (c) A new karaf feature is introduced to register the cm-handle with CPS

- **CPS-TBDMT**
    (a) This component is enhanced to support different type of queries based on templates

- **CPS**
    (a) Bug fixes and support for GET, POST, PATCH and DELETE type of queries.

Istanbul Release - Functional Test cases
----------------------------------------
**Honolulu release carry-over test cases**
    (a) Different possible scenarios of E2E Slice (eMBB) creation are tested in I-release
    (b) RAN slice Termination testing completed
    (c) Test cases to validate slice reuse and terminate using Option 2 (Core NSSMF and RAN NSSMF external) are completed

**R9 Integration Testing**
    (a) RAN NSSMF integration with CPS is covered for RANSlice modification, activation, deactivation and termination
    (b) NSMF driven TN-FH and TN-MH slices creation is tested
    (c) CPS impacts in closed loop scenario is validated and few test cases are deferred to Jakarta release

    Integration test plan is available at `Integration Testing in Instanbul Release <https://wiki.onap.org/display/DW/R9+Integration+Test+for+E2E+Network+Slicing>`_

Istanbul Release - Operation Guidance
-------------------------------------
The steps for E2E network slicing use case will be available at `User Operation Guidance - Istanbul Release <https://wiki.onap.org/pages/viewpage.action?pageId=111118867>`_. It is an update to the user manual created in Honolulu release.

Istanbul Release - Known issues and Solutions
---------------------------------------------

**REGISTER 3RD PARTY CONTROLLERS**

The ONAP TSC approved on July 9th, 2020 to change the status of ESR GUI Module
to an 'unmaintained' project. Further information about 'Unmaintained Projects'
can be found in the `ONAP Developer Wiki. <https://wiki.onap.org/x/Pw_LBQ>`__

But excluding the ESR GUI module from ONAP does not mean that the "external
system registration" mechanism is excluded; i.e. only the GUI is not available
anymore.

Nevertheless, in order to register the 3rd party controllers (like it is done
in E2E network slicing use case and recently in Cloud Leased Line "CLL" use
case as part of Intent-Based Networking), AAI's API are invoked manually.

To do so, please send the following CURL command (PUT) to your AAI, with the
attached xml payload. In the payload, please adjust the controller name (in
this case sdnc1) and the controller ip address accordingly based on your
environment:

CURL COMMAND:

.. code-block:: bash

   curl -k -X PUT https://{{your-onap-ip-address}}:30233/aai/v16/external-system/esr-thirdparty-sdnc-list/esr-thirdparty-sdnc/sdnc1 -u "AAI:AAI" -H "X-FromAppId:postman" -H "Content-Type:application/xml" -H "Accept: application/xml" -H "X-TransactionId:9999" -d @/home/onap/esr-registration-controller-1.xml


PAYLOAD (esr-registration-controller-1.xml):

.. code-block:: xml

  <?xml version="1.0" encoding="UTF-8"?>
  <esr-thirdparty-sdnc xmlns="http://org.onap.aai.inventory/v16">
      <thirdparty-sdnc-id>sdnc1</thirdparty-sdnc-id>
      <location>Core</location>
      <product-name>TSDN</product-name>
      <esr-system-info-list>
          <esr-system-info>
              <esr-system-info-id>sdnc1</esr-system-info-id>
              <system-name>sdnc1</system-name>
              <type>WAN</type>
              <vendor>Huawei</vendor>
              <version>V3R1</version>
              <service-url>http://192.168.198.10:18181</service-url>
              <user-name>onos</user-name>
              <password>rocks</password>
              <system-type>nce-t-controller</system-type>
              <protocol>RESTCONF</protocol>
              <ssl-cacert>example-ssl-cacert-val-20589</ssl-cacert>
              <ssl-insecure>true</ssl-insecure>
              <ip-address>192.168.198.10</ip-address>
              <port>26335</port>
              <cloud-domain>example-cloud-domain-val-76077</cloud-domain>
              <default-tenant>example-default-tenant-val-71148</default-tenant>
              <passive>true</passive>
              <remote-path>example-remotepath-val-5833</remote-path>
              <system-status>example-system-status-val-23435</system-status>
          </esr-system-info>
      </esr-system-info-list>
  </esr-thirdparty-sdnc>


Additional issues occurred during the deployment and integration testing will be
listed in the ONAP Developer Wiki at `Network Slicing - Issues and Solutions <https://wiki.onap.org/display/DW/Network+Slicing+-+Issues+and+Solutions>`_

Jakarta Release Updates
-----------------------
In Jakarta release, the following aspects are covered:

1. **E2E Network Slicing Solution**
    - Slice selection based on resource occupancy level. With this enhancement, NSMF/NSSMF is able to monitor and update resource levels at NSI/NSSI level. OOF returns the solution for NSI/NSSI selection based on the criteria. In case of shared scenario, NSI/NSSI can be shareable only if sufficient resources are available in the network. RAN NSSMF’s resource occupancy is considered for this release. Resource occupancy of Core and TN NSSMFs will be considered in future releases.
    - Dynamic Discovery of Core & RAN endpoints at NSMF. NSMF discovers the RAN endpoints for back haul dynamically at the time of slice allocation/reuse and feeds them to TN NSSMF. Implementation will continue in the next release. RAN endpoints in backhaul are considered for J-release. Discovery of fronthaul, midhaul and core endpoints will be covered in future releases.
    - Activate, Deactivate scenarios support in external RAN NSSMF - Option2. Note that instantiation and termination are supported in Istanbul release.
    - Use case Automation. Test automation for slicing use case in phases for manual configurations. Work will continue beyond Jakarta release.

2. **RAN Slicing**
    - Optimization of cm-handle registration with CPS-DMI Plugin for RAN NF instances to upload yang model.
    - CPS integration with SDN-R for RAN slice allocation and reconfiguration scenarios
    - CPS-TBDMT enhancement to integrate with NCMP, where CPS Core is invoked via NCMP from TBMT for RAN Slice configurations, i.e., NCMP endpoints are used in place of CPS Core. CPS Core is directly invoked from TBDMT in the previous release. This requirement will be implemented once the Caching is enabled in CPS in future releases.
    - CPS integration stabilization for RAN slice activate/deactivate and terminate scenarios. Validation and bug fix for CPS integration of RAN slice lifecycle.
    - CSIT for RAN slicing
3. **Transport Slicing**
    - TN NSSMF enhancements according to IETF latest specification. The implementation of this enhancement will be deferred to next releases.
    - OOF involvement in TN slice reuse and terminate scenarios
       - Implementation of the call to OOF for allocateNSSI to enable TN NSSI reuse in TN NSSMF
       - Implementation of the call to OOF for terminateNxi API to deallocate TN NSSI (which may not be terminated even when NSI is terminated) in TN NSSMF
    - Transport slicing enhancement to support IBN based E2E slicing (Covered in CCVPN use case). The implementation of this enhancement will be deferred to next releases.
    - Closed-loop enhancement in CCVPN to support Transport Slicing’s closed-loop (Covered in CCVPN use case).
    - CSIT for transport slicing. This requirement will be done in future releases.
4. **Closed Loop**
    - IBN based Closed loop for Network Slicing. This enhancement makes use of intents and Machine Learning models for closed loop. ML prediction microservice enhancement is done as a POC work in Jakarta release.
    - CPS integration stabilization, which validates and enhances CPS integration for closed loop.
5. **Carryover tests from Istanbul release**
    - Option-1 (internal NSMF, NSMF and NSSMF)
       - E2E testing for activate/deactivate scenario
       - Pending test cases for E2E Slice termination
    - NSMF driven TN slicing
       - Pending testing for activate/deactivate and terminate scenarios
    - Bug fixes and testing for Core slicing
       - NF instantiation issue with same NSST
       - Multiple non-share Core slice creation issue

Impacted Modules for Jakarta Release
------------------------------------
- **SO**: Requirements below are identified for Jakarta release and have impacts in SO component:
     (1) Core, RAN Endpoints dynamic discovery at NSMF
     (2) TN NSSMF model enhancements according to IETF latest specification
     (3) Use of Optimization solution (OOF) in allocateNSSI, deallocateNSSI in TN NSSMF
     (4) Bug fixes/enhancements of carryover test cases from Istanbul release
     (5) Activate, Deactivate flows support in external RAN NSSMF for option 2

- **OOF**: OOF component has an impact for the requirement below:
     (1) NSI/NSSI Selection enhancements based on resource occupancy levels

- **DCAE**: The requirements below are identified for Jakarta release and have impacts in DCAE component:
     (1) Slice selection taking into consideration of resource occupancy levels
     (2) CPS integration in closed loop – This was done in I-release. Expecting minor enhancements in Slice Analysis MS once after the other components impacts w.r.t CPS integration and E2E testing are completed.
     (3) IBN based Closed loop for Network Slicing - This will have impact in E2E Slicing closed loop and TN Slicing closed loop.

- **CCSDK**: The requirements below are identified for network slicing use case in Jakarta release and have impacts in CCSDK component. Most of these requirements fall under the category of CPS integration.
      (1) Optimizing cm-handle registration with CPS-DMI Plugin to upload yang model
      (2) CPS Integration with SDN-R for RAN Slice allocate and reconfigure scenarios
      (3) CPS Integration Stabilization - RAN Slice activate/deactivate and terminate scenarios
      (4) CSIT for RAN slicing

Jakarta Release - Functional Test cases
---------------------------------------
The functional testing of this use case covers CSMF/NSMF, RAN/CN/TN NSSMFs and Closed Loop functionality. Test cases are classified into 5 tracks: E2E network slicing, RAN NSSMF, TN NSSMF, Closed Loop and carryover testing. Details of the test cases can be found at: `E2E Network Slicing Tests for Jakarta Release <https://wiki.onap.org/display/DW/E2E+Network+Slicing+Integration+Tests+for+Jakarta+Release>`_ and its child wiki pages.

Jakarta Release - Operation Guidance
------------------------------------
The setup and operation details for E2E network slicing use case are available at `User Operation Guidance - Jakarta Release <https://wiki.onap.org/display/DW/User+Operation+Guidance+-+Jakarta+Release>`_.

Jakarta Release - Known issues and Solutions
--------------------------------------------
Details of up to date manual configurations, known issues, solutions and work-arounds can be found in the following wiki page: `Jakarta Release - Issues and Solutions <https://wiki.onap.org/display/DW/Jakarta+Release+-+Issues+and+Solutions>`_.
