.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0
   Copyright 2018 Huawei Technologies Co., Ltd.  All rights reserved.

.. _docs_vcpe:

vCPE Use Case
----------------------------

Description
~~~~~~~~~~~
vCPE use case is based on Network Enhanced Residential Gateway architecture specified in Technical Report 317 (TR-317), which defines how service providers deploy residential broadband services like High Speed Internet Access. The use case implementation has infrastructure services and customer service. The common infrastructure services are deployed first and shared by all customers. The use case demonstrates ONAP capabilities to design, deploy, configure and control sophisticated services.      

More details on the vCPE Use Case can be found on wiki page https://wiki.onap.org/pages/viewpage.action?pageId=3246168

Source Code
~~~~~~~~~~~
vcpe test scripts: https://gerrit.onap.org/r/gitweb?p=integration.git;a=tree;f=test/vcpe;h=76572f4912e7b375e1e4d0177a0e50a61691dc4a;hb=refs/heads/casablanca

How to Use
~~~~~~~~~~
Most part of the use case has been automated by vcpe scripts. For the details on how to run the scripts, please refer to the use case tutorial on https://wiki.onap.org/display/DW/vCPE+Use+Case+Tutorial%3A+Design+and+Deploy+based+on+ONAP.

Test Status
~~~~~~~~~~~~~~~~~~~~~
The use case has been tested for Casablanca release, the test report can be found on https://wiki.onap.org/display/DW/vCPE+-+Test+Status

Known Issues and Workaround
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1) Firewalls are installed on BRG and vBNG. In order to allow SDNC to send BRG configuration message through vBNG, SDNC host VM IP address is preloaded on BRG and vBNG, and provisioned into the firewalls. If SDNC changes its host VM, SDNC host VM IP changes and we need to manually update the IP in /opt/config/sdnc_ip.txt. Then run:

::

  root>vppctl tap delete tap-0
  root>vppctl tap delete tap-1
  root>/opt/nat_service.sh
  root>vppctl restart

2) APPC has a bug which prevents DG from reading AAI info. We needs an DG update. See the JIRA on https://jira.onap.org/browse/APPC-1249

3) In closed loop, APPC fails to send response back to Policy via an DMAAP message. Policy will keep sending reboot action request until timed out or ABATED message is received. User may see 3 or 4 vGMUX reboots before service returns normal. See the JIRA on https://jira.onap.org/browse/APPC-1247

