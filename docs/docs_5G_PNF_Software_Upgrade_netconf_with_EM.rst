.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

.. _docs_5g_pnf_software_upgrade_netconf_with_EM:

===========================================================================
PNF Software Upgrade Scenario: Using Netconf/Yang interface with EM
===========================================================================
Software Upgrade Procedure
------------------------------------

With this scenario, the pre-conditions are:

* SO PNF software upgrade workflows are ready to use.
* An SDC service template with one PNF resource has been designed (including CBA association) and has been distributed.
* Service instantiation is completed, including PNF PnP.
* At design time, the CONTROLLER_ACTOR is set for CDS client for the API selection decision.
* EMS (with netconf capability and suitable software management yang model) is ready to use. It has direct NETCONF/YANG interface configured which can be reachable from CDS.

At run time, the service provider in R6 can use CLI to trigger the PNF in-place software upgrade procedure by selecting the existing PNF software upgrade workflow or uploading a custom workflow, as well as an identifier of a PNF instance, the target software version.

Then the software upgrade workflow is executed as follows:

a. SO sends CDS request(s) with action-identifier {actionName, blueprintName, blueprintVersion} to the blueprint processor inside the controller using CDS self-service API.
b. Controller/blueprint processor executes the blueprint scripts including sending NETCONF request(s) to the EMS via the direct NETCONF interface. Then EMS is responsible of software upgrade procedure of the selected PNF instance.
c. Repeat above two steps for each SO building block in the corresponsding PNF software upgrade workflow.


Test Status and Plans
------------------------------------

To see information on the status of the test cases, please follow the link below:

`PNF Software Upgrade with netconf/yang interface with EM Test Status <https://wiki.onap.org/pages/viewpage.action?pageId=64008675#PNFsoftwareupgradewithNetconf/YanginterfacewithhEM-TestStatus>`_
