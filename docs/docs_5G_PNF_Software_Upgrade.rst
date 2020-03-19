.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

.. _docs_5g_pnf_software_upgrade:


5G PNF Software Upgrade
-----------------------

Description
~~~~~~~~~~~

The 5G PNF Software upgrade use case shows how users/network operators can modify the software of a PNF instance during installation or regular maintenance. This use case is one aspect of Software Management. This could be used to update the PNF software to a different version of software.

Useful Link
~~~~~~~~~~~

`PNF Software Upgrade Wiki Page <https://wiki.onap.org/display/DW/PNF+software+upgrade+in+R6+Frankfurt>`_


Current Status in Frankfurt
~~~~~~~~~~~~~~~~~~~~~~~~~~~

PNF Software Upgrade Scenarios
------------------------------

There are 3 PNF software upgrade scenarios supported in Frankfurt release:

* `Using direct Netconf/Yang interface with PNF <docs_5G_PNF_Software_Upgrade_direct_netconf_yang.html>`_

  - (https://wiki.onap.org/pages/viewpage.action?pageId=64007309)

* `Using Ansible protocol with EM <docs_5G_PNF_Software_Upgrade_ansible_with_EM.html>`_

  - (https://wiki.onap.org/pages/viewpage.action?pageId=64007357)

* `Using Netconf/Yang interface with EM <docs_5G_PNF_Software_Upgrade_netconf_with_EM.html>`_

  - (https://wiki.onap.org/pages/viewpage.action?pageId=64008675)

Common tasks for all scenarios
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SO Workflows
~~~~~~~~~~~~

Common SO workflows are used with generic SO building blocks which can be used for any PNF software upgrade scenarios. In Frankfurt release, a PNF software upgrade workflow and a PNF preparation workflow have been created.

	.. image:: files/softwareUpgrade/SWUPWorkflow.png

LCM evolution with API Decision Tree
====================================

A decision point has been introduced in the Frankfurt release. The service designer needs to indicate which LCM API they would like to use for the LCM operations on the selected PNF source at design time (via SDC). The possible LCM APIs are: SO-REF-DATA (default), CDS, SDNC, or APPC.

	.. image:: files/softwareUpgrade/APIDecisionTree.png
