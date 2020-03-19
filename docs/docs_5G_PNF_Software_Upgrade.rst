<<<<<<< HEAD
.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
=======
.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0
>>>>>>> 522e0d3b... WIP: fix integration doc warning

.. _docs_5g_pnf_software_upgrade:

============================================================
5G PNF Software Upgrade
============================================================

Description
------------

The 5G PNF Software upgrade use case shows how users/network operators can modify the software of a PNF instance during installation or regular maintenance. This use case is one aspect of Software Management. This could be used to update the PNF software to a different version of software.

Useful Link
------------

`PNF Software Upgrade Wiki Page <https://wiki.onap.org/display/DW/PNF+software+upgrade+in+R6+Frankfurt>`_


Current Status in Frankfurt
---------------------------
============================================================
PNF Software Upgrade Scenarios
============================================================

There are 3 PNF software upgrade scenarios supported in Frankfurt release:

* `Using direct Netconf/Yang interface with PNF <docs_5g_pnf_software_upgrade_direct_netconf_yang>`_

  - (https://wiki.onap.org/pages/viewpage.action?pageId=64007309)

<<<<<<< HEAD
* `Using Ansible protocol with EM <docs_5g_pnf_software_upgrade_ansible_with_EM>`_
=======
**Current status in Dublin**
- with the support of an EM
- LCM API (focus on controller only)
- integration of basic 3GPP SwM interfaces (*)
- ansible protocol only
Note: In Dublin, Controller provided four related APIs (precheck, postcheck, upgrade and rollback), which were finally translated to invoke interfaces provided by EM. Rollback API  is to call swFallback operation, and Upgrade API is to call downloadNESw, installNESw and activateNESw operations (Ref. 3GPP TS 32.532[1]).
>>>>>>> 522e0d3b... WIP: fix integration doc warning

  - (https://wiki.onap.org/pages/viewpage.action?pageId=64007357)

* `Using Netconf/Yang interface with EM <docs_5g_pnf_software_upgrade_netconf_with_EM>`_

  - (https://wiki.onap.org/pages/viewpage.action?pageId=64008675)

<<<<<<< HEAD
Common tasks for all scenarios
------------------------------

SO Workflows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=======
1) In ansible server container, prepare the ssh connection conditions to the external controller, both ssh key file and ansible inventory configuration

2) In sdnc controller container, update the dg configuration file: lcm-dg.properties.
>>>>>>> 522e0d3b... WIP: fix integration doc warning

Common SO workflows are used with generic SO building blocks which can be used for any PNF software upgrade scenarios. In Frankfurt release, a PNF software upgrade workflow and a PNF preparation workflow have been created.

<<<<<<< HEAD
	.. image:: files/softwareUpgrade/SWUPWorkflow.png

LCM evolution with API Decision Tree
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=======
3) Login controller UI, access the pre-check LCM operation (or other operations) and send request, the detailed request parameters can be found in corresponding test case link.

4) The HTTP API response code 200 and LCM retured code 400 (See APPC return code design specification) indicate success, otherwise failed.
>>>>>>> 522e0d3b... WIP: fix integration doc warning

A decision point has been introduced in the Frankfurt release. The service designer needs to indicate which LCM API they would like to use for the LCM operations on the selected PNF source at design time (via SDC). The possible LCM APIs are: SO-REF-DATA (default), CDS, SDNC, or APPC.

	.. image:: files/softwareUpgrade/APIDecisionTree.png

<<<<<<< HEAD

=======
Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
None
>>>>>>> 522e0d3b... WIP: fix integration doc warning
