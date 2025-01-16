.. nfv_testing_automation_platform_requirements:

:orphan:

=======================================================
NFV Testing Automatic Platform Requirements- User Guide
=======================================================

.. Overview: this page used to explain how to use NFV testing automatic platform,
             the relevant requirements include REQ-335(Support for Test Topology
             Auto Design), REQ-336(Support for Test Environment Auto Deploy),
             REQ_337(Support for Test Task Auto Execution),REQ-338(Support for
             Test Result Auto Analysis & Certification).

Description
===========

There are a large number of cross-department and cross-organization communications
during the traditional network element, system or equipment network access test.
And the manual errors are inevitable, the knowledge in test field cannot be
solidified. The cost of each test is high and the test cycle is always long.
After introducing NFV, because network element software and hardware equipment are
layered decoupled, the introduction of a large number of open source components as
well as the frequent upgrade of the software itself, make network access test
become more complicated and frequent.

Testing has become a bottleneck during the introduction and iteration of new
technologies. Therefore, it is urgent to introduce automated test tools.
By introducing testing automatic capabilities including topology auto design,
test environment auto deploy, test task auto execution and test result auto
analysis & certification, it can solidify domain knowledge, and help reduce labor
costs, shorten test cycle, improve test efficiency , optimize test accuracy.

Requirement Details
===================

Test Topology Auto Design( enhancement in SDC)
----------------------------------------------

1.Quickly design a test service (topology) composed with tested VNF and test
  environment (One way is to define abstract testing service (topology) template
  for each type of VNF);

2.For the service designed, can be imported into SDC for modification or enhancement,
  or the test template can be reused for different test environments (the SDC needs
  to support service import).

Test Environment Auto Deploy (enhancement in VF-C)
--------------------------------------------------

By getting VM/VL/Port/VNF/NS instance information from Openstack via Multi-cloud
to VF-C for instance information storage,  enable VTP obtaining all the real-time
instance information.

Test Task Auto Execution(enhancement in VNFSDK, CLI)
----------------------------------------------------
1. Test instruments integration：

* Test Case execution;
* Test Case discovering and auto registration;
* Robot profile integration

2. VTP capability expansion:

* Loading different test scripts and cases- Scenario Active Management ;
* Flexible test process definition(Middle);
* Test report customization
* Profile HTTP API support

3. Execution-Standard / Open source test case support

* Enable ETSI NFV APIs conformance test cases in VTP;
* Enable CNCF CNF conformance test case in VTP.

4. Test Result Auto Analysis & Certification

* The test objects that passed test certification are put into marketplace
* OVP integrates with VTP to automatically receive VTP test results:

  * Enable OVP with HTTP API for submit the result
  * Enable VTP for result submission into OVP.

New Features and Guide (Guilin Release)
=======================================

SDC New features
----------------

Service import
>>>>>>>>>>>>>>

1. Add a button “IMPORT SERVICE CSAR" to perform service CSAR import.
2. When clicking the “IMPORT SERVICE CSAR” button on the portal, a window will
   pop up to select the service CSAR file to be imported.
3. After selecting the service CSAR file to be imported, it will switch to the
   general information input page for creating the service.
4. After filling in all the required fields, you can click the "create" button
   to create a new service.
5. Add a new API for the request of importing service CSAR.

Abstract service template
>>>>>>>>>>>>>>>>>>>>>>>>>

1. On the general page of VF, add a IS_ABSTRACT_RESOURCE selection box, which is
   false by default. If it is an abstract VNF, select true manually.
2. Add three APIs to handle the corresponding requests of abstract service template:
   2.1 Return whether the service is a abstract service: GET /v1/catalog/abstract/service/serviceUUID/{uuid}/status
   2.2 Copy a new service based on the existing service: POST /v1/catalog/abstract/service/copy
   2.3 Replace the abstract VNF in the abstract service template with the actual VNF: PUT /v1/catalog/abstract/service/replaceVNF

VTP New features
----------------
1. Added active scenario and profile management support
2. Added integration with Robot CSIT tests
3. Enabled auto discovery of test cases from 3rd party tool integration
4. Added support for cnf-conformance test support( In order to enable CNF
   conformance tool in VTP, please refer `the guide <https://gerrit.onap.org/r/gitweb?p=vnfsdk/validation.git;a=blob;f=cnf-conformance/README.md;h=cda3dee762f4dd2873613341f60f6662880f006a;hb=refs/heads/master>`_
5. New VTP API has been updated: see the `VTP API wiki page <https://wiki.onap.org/display/DW/VTP+REST+API+v1>`_

Test Status and Plans
=====================

See `the status of the test wiki page <https://wiki.onap.org/display/DW/Automatic+Testing+Requirements>`_
