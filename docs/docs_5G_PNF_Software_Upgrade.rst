5G PNF Software Upgrade
----------------------------

Description
~~~~~~~~~~~
The 5G PNF Software upgrade use case shows how users/network operators can modify the software running on an existing PNF. This use case is one aspect of Software Management. This could be used to update the PNF software to a newer or older version of software.

The Casablanca 5G PNF Software Upgrade Use Case Wiki Page can be found here: https://wiki.onap.org/display/DW/5G+-+PNF+Software+Update

How to Use
~~~~~~~~~~
Upgrading PNF (instance) software requires the user/network operator to trigger the upgrade operation from the UI, e.g. VID or UUI. In Cacablanca, users need use ONAP Controllers GUI to trigger the LCM opeations, like pre-check, post-check and upgrade. After receiving the API requests, the ONAP controllers will communicate to the external controller(EC) through south-bound adaptors, which is Ansible in R3.

Note that, both APPC and SDNC in R3 supported Ansible. Taking SDNC and Prechecking as an example, the steps are as follows:

1) In ansible server container, prepare the ssh connection conditions to the external controller, both ssh key file and ansible inventory configuration;

2) In sdnc controller container, update the dg configuration file: lcm-dg.properties.
For example:
::
lcm.pnf.upgrade-pre-check.playbookname=ansible_huawei_precheck
lcm.pnf.upgrade-post-check.playbookname=ansible_huawei_postcheck
lcm.pnf.upgrade-software.playbookname=ansible_huawei_upgrade

3) Login controller UI, access the pre-check LCM operation and send request.
Post upgrade-pre-check with the following request body:
::
{
    "input": {
      "common-header": {
      "timestamp": "2018-10-10T09:40:04.244Z",
      "api-ver": "2.00",
      "originator-id": "664be3d2-6c12-4f4b-a3e7-c349acced203",
      "request-id":"664be3d2-6c12-4f4b-a3e7-c349acced203",
      "sub-request-id": "1",
      "flags": {
                    "force" : "TRUE",
                    "ttl" : 60000
             }
      },
      "action": "UpgradePreCheck",
      "action-identifiers": {
        "vnf-id":"5gDU0001"
      },
      "payload": "{\"pnf-flag\":\"true\", \"pnf-name\": \"5gDU0001\",\"pnfId\": \"5gDU0001\", \"ipaddress-v4-oam\": \"EC_IP_address\",\"oldSwVersion\": \"v1\", \"targetSwVersion\": \"v2\", \"ruleName\": \"r001\", \"Id\": \"10\", \"additionalData\":\"{}\"}"}}

4) The HTTP API response code 200 and LCM retured code 400 (See APPC return code design specification) indicate success, otherwise failed.

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
To see information on the status of the test see: https://wiki.onap.org/display/DW/5G+-+PNF+Software+Update+Test+Status

Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
None

