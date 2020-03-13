.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

.. _docs_5g_pnf_software_upgrade_direct_netconf_yang:

===========================================================================
PNF Software Upgrade Scenario: Using Direct Netconf/Yang interface with PNF
===========================================================================
Software Upgrade Procedure
------------------------------------

With this scenario, the pre-condition is that:

* ONAP is ready to use
* SO upgrade workflows are ready to use
* An SDC service template with one PNF resource is designed (including CBA association) and it is distributed to run time
* Service instantiation is completed, including PNF PnP. meaning a PNF instance is in operation with connectivity between PNF-ONAP, PNF-SFTP
* At design time, the flag is set for CDS client for the API Decision Tree
* PNF has direct NETCONF/YANG interface configured which can be reachable from ONAP controller.

At run time, the PNF in-place software upgrade procedure is triggered when the operator provides the selected upgrade workflow, a PNF instance, and the target software version using VID GUI or CLI.
Then the software upgrade workflow is executed in SO:

a. SO sends CDS request(s) with action-identifier {actionName, blueprintName, blueprintVersion} to the blueprint processor inside the controller using CDS self-service API
b. Controller/blueprint processor executes the blueprint scripts including sending NETCONF request(s) to the PNF instance via the direct NETCONF interface. 
c. Repeat above two steps for each SO building blocks. 

        .. image:: files/softwareUpgrade/DirectNetconfYangInterface.png


Test Status and Plans
------------------------------------

To see information on the status of the test cases please follow the link below:

`PNF Software Upgrade Test Status <https://wiki.onap.org/display/DW/PNF+software+upgrade+in+R6+Frankfurt#PNFsoftwareupgradeinR6Frankfurt-TestStatus>`_

