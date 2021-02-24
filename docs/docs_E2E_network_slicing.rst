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

This use case is a multi-releases effort in ONAP with the first steps
taken in Frankfurt release. It will continue to expand in scope both in
breadth and depth, and along the journey it shall also align with
updates to the relevant standards which are also currently evolving.
This use case shall also collaborate with other open initiatives such as
O-RAN to enable wider adoption and use.

See the `Use Case Description and Blueprint wiki page <https://wiki.onap.org/display/DW/Use+Case+Description+and+Blueprint>`_
for details.


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

Scope of Guilin release
-----------------------
From the architecture point of view, in Guilin release, besides the continuation of NSMF which was implemented in
Frankfurt release, the RAN NSSMF, TN NSSMF, CORE NSSMF have been implemented within ONAP, apart from interacting with
ezternal RAN NSSMF and external CORE NSSMF.

The following provides an overview of the enhancements done in Guilin release:

- **Enhancements in NSMF**: Service Profile decomposition into Slice Profiles for 3 domains, NSI selection enhancement,
  E2E slice instance creation including RAN, TN and CN slice sub-net instance creation/reuse, activation/deactivation
  of E2E slice, and deciding whether to terminate E2E slice or not.

- **RAN NSSMF, TN NSSMF, CN NSSMF within ONAP**: Basic logic for all 3 NSSMFs to support NSSI allocation, activation,
  deactivation, deletion and modification (in case of reuse of NSSI).

- **Enable NSMF interaction with RAN NSSMF, TN NSSMF, CN NSSMF**: Implement generic NSSMF adaptor for three domain NSSMFs,
  alignment with standard intefaces (3GPP, IETF), enable the connection to external RAN NSSMF.

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

Important Remarks
~~~~~~~~~~~~~~~~~
(a) 2 deployment scenarios for RAN NSSI are supported. In the first scenario, the RAN NSSI comprises also of
    TN Fronthaul (FH) and TN Midhaul (FH) NSSIs, and RAN NSSMF shall trigger TN NSSMF for TN FH and MH NSSI
    related actions. In the second scenario, the RAN NSSI comprises only of RAN NFs. TN NSSMF shall be triggered by
    NSMF for TN FH and MH NSSI related actions. This part is not yet implemented in NSMF, and will be realized in
    Honolulu release.

(b) The Guilin release scope focused on enhancing NSMF and implementing basic functionality of all 3 NSSMFs within
    ONAP with the objective of realizing a simple E2E network slice using standard interfaces. So, further enhancements
    and refinement will continue in Honolulu release and beyond.

(c) Details of the assumptions in Guilin release are documented at:
    `Assumptions <https://wiki.onap.org/display/DW/Assumptions+for+Guilin+release>`_

(d) Sequence/flow diagrams related to this use case are available at:
    `Use Case Flows <https://wiki.onap.org/display/DW/Use+case+flows>`_

(e) Details of the Modeling aspects are available at:
    `Modeling Enhancements <https://wiki.onap.org/display/DW/Modeling+enhancements?src=contextnavpagetreemode>`_


Impacted Modules for Guilin
---------------------------
The code-impacted modules of E2E Network Slicing in Guilin release are:

- **SO**: Enhancements in NSMF explained above, NSSMF adaptor, workflows for RAN, Core and TN NSSMFs, Closed Loop
  trigger handling.

- **OOF**: Enhancements for NSI selection, NSSI selection, Slice Profile generation, and NSI/NSSI termination
  determination

- **DCAE**: 2 new MS were introduced:
  (a) **Data Exposure Service (DES)** for querying database/datalake for PM/KPI data by any entity
  (b) **Slice Analysis MS** for analyzing slice related PM/KPI data and determining necessary closed loop actions

- **AAI**: Updates for Slice Profile, NSST, Service Profile, TN slice models

- **SDN-C**: TN NSSMF related functionality (allocation, activation/deactivation and termination of TN NSSI/S-NSSAI)

- **CCSDK/SDN-R**: RAN NSSMF related functionality related to allocation, activation/deactivation and termination of RAN
  NSSI/S-NSSAI, mainly the configuration of CUs, DUs and Near-RT RICs over O1 interface to the RAN NFs. In addition,
  configuration updates related to Closed Loop and Intelligent Slicing shall also be sent over O1 interface.
  
- **U-UI**: Enhancements related to configuration/selection of end-points.

- **ExtAPI**: Enhancements to support service activation/deactivation and termination using TMF 641 APIs

- **Policy**: Minor updates to support the new Control Loop for Network Slicing.

Apart from the above, the following modules had test-only impact:

- **SDC**: Test of the supported functionality through creation of NST, NSST for all 3 domains, templates for Service
  Profile and Slice Profile.

- **CDS**: Support for configuration of S-NSSAI in the Core NFs.

In addition:

- **Config DB** is enhanced to support storing and retrieval of RAN-related configuration data. This is not an official
  ONAP component, and its functionality is expected to be performed by the Configuration Persistence Service in
  Honolulu release.

- **Core NF simulators** have been developed for instantiating as part of Core NSSI creation/configuration, and also
  to report PM data.

- **RAN-Sim** has been enhanced to include CU and Near-RT RIC functionality, apart from enhancements to DU functionality.

Details of the impacts/APIs of some of the modules listed above are available in the child pages of: `Impacted Modules - Design Details 
<https://wiki.onap.org/display/DW/Impacted+Modules--Design+Details>`_


Functional Test Cases
---------------------
The functional testing of this use case shall cover creation and activation of a service with an E2E Network Slice
Instance which contains RAN, Transport and Core Slice Sub-net instances. It also addresses the termination of an
E2E Network Slice Instance. We classify the test cases into 7 tracks: CSMF, NSMF, Common NSMMF/RAN NSSMF/TN NSSMF/
Core NSSMF/KPI Monitoring/Close loop/Intelligent Slicing. Details of the test cases can be found at: `Track-wise test cases
<https://wiki.onap.org/display/DW/Track-wise+test+cases>`_


Operation Guidance
------------------
The Guilin release setup details for the E2E Network Slicing use case will be available at the following page and its
sub-pages: `<https://wiki.onap.org/display/DW/User+Operation+Guidance+in+R7+Guilin>`_


Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(a) A limited testing of the supported scenarios is being carried out in Guilin. For example, for NSI allocation, only
    a sub-set of combinations of NSI reuse, creation using existing or new NSSIs (RAN, Core, TN) is being tested. However,
    since the remaining functionality will be activated only when triggered with the appropriate inputs, this limitation
    shall not affect the stability of the components or other existing functionality.

(b) The configuration updates for Closed Loop and Intelligent Slicing to the RAN is sent over O1 interface to Near-RT RIC.
    It should be sent over A1 interface - this will be taken up in Honolulu release.

(c) Coverage area to TA list is not performed. Based on the coverage area provided as input, a set of cells are assumed to
    be impacted.

(d) NST selection requires a file to be stored corresponding to the templates created in SDC. In Honolulu release, OOF
    functionality will be enhanced to fetch the NSTs from SDC.

(e) RAN/Core NSSI endpoint determination, configuration and use is limited in Guilin release.

(f) Only creation of new TN NSSI is supported, reuse of existing TN NSSI is not yet supported.

(g) KPI computation functionality enhancements in PM-Mapper in DCAE is not part of Guilin release, though the functionality
    is implemented and available.
