.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_5g_pnf_software_upgrade:

5G PNF Software Upgrade
----------------------------

Description
~~~~~~~~~~~
The 5G PNF Software upgrade use case shows how users/network operators can modify the software of PNF instance during installation or regular maintaince. This use case is one aspect of Software Management. This could be used to update the PNF software to a newer or older version of software.

**Useful Links**
- `5G - PNF software upgrade use case documentation <https://wiki.onap.org/pages/viewpage.action?pageId=40206496>`_
- `5G - PNF software upgrade Integration test case status for Dublin release <https://wiki.onap.org/display/DW/5G+-+PNF+SW+Upgrade+-+Integration+Test+Cases>`_

**Current status in Dublin**
- with the support of an EM
- LCM API (focus on controller only)
- integration of basic 3GPP SwM interfaces (*)
- ansible protocol only
Note: In Dublin, Controller provided four related APIs (precheck, postcheck, upgrade and rollback), which were finally translated to invoke interfaces provided by EM. Rollback API  is to call swFallback operation, and Upgrade API is to call downloadNESw, installNESw and activateNESw operations (Ref. 3GPP TS 32.532[1]).

**Future Plans**
- E2E PNF Software upgrade both for design and runtime
- Generic workflow for demonstration

How to Use
~~~~~~~~~~
Upgrading PNF (instance) software requires the user/network operator to trigger the upgrade operation from the UI, e.g. VID or UUI. In Dublin, users need use ONAP Controllers GUI or publish DMaaP messages to trigger the LCM opeations, which are pre-check, post-check, upgrade and rollback. After receiving the API requests, the ONAP controllers will communicate to EMS through south-bound adaptors, which is Ansible protocol only in Dublin.

Note that, both APPC and SDNC in R4 supported Ansible. Taking SDNC and Prechecking as an example, the steps are as follows:

1) In ansible server container, prepare the ssh connection conditions to the external controller, both ssh key file and ansible inventory configuration

2) In sdnc controller container, update the dg configuration file: lcm-dg.properties.

For example:
::
lcm.pnf.upgrade-pre-check.playbookname=ansible_huawei_precheck
lcm.pnf.upgrade-post-check.playbookname=ansible_huawei_postcheck
lcm.pnf.upgrade-software.playbookname=ansible_huawei_upgrade
lcm.pnf.upgrade-rollback.playbookname=ansible_huawei_rollback

3) Login controller UI, access the pre-check LCM operation (or other operations) and send request, the detailed request parameters can be found in corresponding test case link.

4) The HTTP API response code 200 and LCM retured code 400 (See APPC return code design specification) indicate success, otherwise failed.

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
To see information on the status of the test case: https://wiki.onap.org/display/DW/5G+-+PNF+SW+Upgrade+-+Integration+Test+Cases

References
==========
[1] TS 32.532,Telecommunication management; Software management (SwM); Integration Reference Point (IRP); Information Service (IS)

Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
None
