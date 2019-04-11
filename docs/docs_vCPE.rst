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
The use case had been tested for Casablanca Maintenance release 3.0.1, the regression test is reported on https://wiki.onap.org/display/DW/Casablanca+Maintenance+Release+Integration+Testing+Status 
The use case had been tested for Casablanca release, the test report can be found on https://wiki.onap.org/display/DW/vCPE+-+Test+Status

Known Issues and Workaround for Casablanca Maintenance Releases 3.0.1 and 3.0.2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1) vCPE infra service model distribution will fail due to a bug in SO, see the JIRA on https://jira.onap.org/browse/SO-1400. Follow the instructions below to expand database table field size

   a) Connect to SO mariadb POD from rancher node
   
   b) Login to mysql: mysql -uroot -ppassword
   
   c) Select database: use catalogdb;
   
   d) Update tables:

::

  mysql>ALTER TABLE vnf_resource_customization MODIFY IF EXISTS RESOURCE_INPUT varchar(20000);
  mysql>ALTER TABLE network_resource_customization MODIFY IF EXISTS RESOURCE_INPUT varchar(20000);
  mysql>ALTER TABLE allotted_resource_customization MODIFY IF EXISTS RESOURCE_INPUT varchar(20000);

2) Firewalls are installed on BRG and vBNG. In order to allow SDNC to send BRG configuration message through vBNG, SDNC host VM IP address is preloaded on BRG and vBNG, and provisioned into the firewalls. If SDNC changes its host VM, SDNC host VM IP changes and we need to manually update the IP in /opt/config/sdnc_ip.txt. Then run:

::

  root>vppctl tap delete tap-0
  root>vppctl tap delete tap-1
  root>/opt/bind_nic.sh
  root>/opt/set_nat.sh

3) Neutron HEAT template in database is invalid, see https://jira.onap.org/browse/SO-1609. The workaround is to download neutron.sh from the JIRA attachment and run neutron.sh on SO mariadb pod to update database table

4) vGMUX doesn't send VES event in the right format. You need to follow vCPE tutorial to update libevel.so, then you may also need to restart vGMUX after running ldconfig command

5) No ONSET event received by Policy. Check if TCA app is loaded from CDAT portal http://{{oom_cluster_node_ip}}:32010, click on top right corner drop down box to see if TCA app is listed. If TCA is not loaed, delete pod dcae-tca-analytics to let it restart

6) The very first RESTART DMaaP event is not received by APPC. It is because the first RESTART message only creates the topic. You just need to wait a few minutes for the subsequent event to be triggered to see the closed loop action by APPC.


Known Issues and Workaround for Casablanca Release
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1) Firewalls are installed on BRG and vBNG. In order to allow SDNC to send BRG configuration message through vBNG, SDNC host VM IP address is preloaded on BRG and vBNG, and provisioned into the firewalls. If SDNC changes its host VM, SDNC host VM IP changes and we need to manually update the IP in /opt/config/sdnc_ip.txt. Then run:

::

  root>vppctl tap delete tap-0
  root>vppctl tap delete tap-1
  root>/opt/bind_nic.sh
  root>/opt/set_nat.sh

2) APPC has a bug which prevents DG from reading AAI info. We needs an DG update. See the JIRA on https://jira.onap.org/browse/APPC-1249

3) In closed loop, APPC fails to send response back to Policy via an DMAAP message. Policy will keep sending reboot action request until timed out or ABATED message is received. User may see 3 or 4 vGMUX reboots before service returns normal. See the JIRA on https://jira.onap.org/browse/APPC-1247

