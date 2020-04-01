.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

.. _docs_5g_pnf_software_upgrade_ansible_with_EM:

PNF Software Upgrade Scenario: Using Ansible protocol with EM
-------------------------------------------------------------

Software Upgrade Procedure
~~~~~~~~~~~~~~~~~~~~~~~~~~

With this scenario, the pre-conditions are:

* SO PNF software upgrade workflows are ready to use. For this scenario, the CONTROLLER_ACTOR is set for SDNC client for the API selection decision.
* Service instantiation is completed, including PNF PnP. It means a PNF instance is in operation and is avaibale for ONAP (maybe via EMS).
* ONAP Controller (SDNC and ansible server) and DMaaP are ready to use. It means necessary ansible connection and DMaaP topics are ready.
* EMS has direct ansible interface to the ansible server. The underlying protocol is SSH.

At run time, the service provider in R6 can use CLI to trigger the PNF in-place software upgrade procedure by selecting the existing PNF software upgrade workflow or uploading a custom workflow, as well as an identifier of a PNF instance, the target software version and optional json-formatted payload.

Then the software upgrade workflow is executed as follows:

a. SO sends request(s) with input {action, action-identifiers, common header, and optional payload} to SDNC API handler using traditional LCM API.
b. SDNC API handler executes corresponding DG and sends requests to the ansible server.
c. The ansible server executes ansible playbook with the EMS. Then EMS is responsible of software upgrade procedure of the selected PNF instance.
d. Repeat above steps for each SO building block in the corresponding PNF software upgrade workflow.

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~

To see information on the status of the test cases, please follow the link below:

`Enhancement on PNF software upgrade using Ansible Test Status <https://wiki.onap.org/pages/viewpage.action?pageId=64007357#EnhancementonPNFS/WUpgradeusingAnsible-TestStatus>`_
