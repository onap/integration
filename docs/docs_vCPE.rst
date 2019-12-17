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
vcpe test scripts: https://git.onap.org/integration/tree/test/vcpe?h=dublin

How to Use
~~~~~~~~~~
Most part of the use case has been automated by vcpe scripts. For the details on how to run the scripts, please refer to the use case tutorial on https://wiki.onap.org/display/DW/vCPE+Use+Case+Tutorial%3A+Design+and+Deploy+based+on+ONAP.

Here are the main steps to run the use case in Integration lab environment, where vCPE script is pre-installed on Rancher node under /root/integration/test/vcpe:

1. Run Robot script from Rancher node to onboard VNFs, create and distribute models for vCPE four infrastructure services, i.e. infrastructure, brg, bng and gmux

::

   demo-k8s.sh onap init

2. Add route on sdnc cluster VM node, which is the cluster VM node where pod sdnc-sdnc-0 is running on. This will allow ONAP SDNC to configure BRG later on.

::

   ip route add 10.3.0.0/24 via 10.0.101.10 dev ens3


3. Install Python and other Python libraries

::

   integration/test/vcpe/bin/setup.sh


4. Setup vcpe scripts by adjusting relevant parts of provided vcpeconfig.yaml config file. Most importantly adjust the Openstack env parameters shown below. Please issue 'vcpe.py --help' for detailed usage info.

::

    cloud:
        '--os-auth-url': 'http://10.12.25.2:5000'
        '--os-username': 'xxxxxxxxxx'
        '--os-user-domain-id': 'default'
        '--os-project-domain-id': 'default'
        '--os-tenant-id': 'xxxxxxxxxxxxxxxx'
        '--os-region-name': 'RegionOne'
        '--os-password': 'xxxxxxxxxxx'
        '--os-project-domain-name': 'xxxxxxxxx'
        '--os-identity-api-version': '3'

    common_preload_config:
        'oam_onap_net': 'xxxxxxxx'
        'oam_onap_subnet': 'xxxxxxxxxx'
        'public_net': 'xxxxxxxxx'
        'public_net_id': 'xxxxxxxxxxxxx'


5. Run Robot to create and distribute for vCPE customer service. This step assumes step 1 has successfully distributed all vcpe models except customer service model

::

   ete-k8s.sh onap distributevCPEResCust

6. If running with oom_mode=False initialize SDNC ip pool by running below command from k8s control node. It will be done automatically otherwise.

::

    kubectl -n onap exec -it dev-sdnc-sdnc-0 -- /opt/sdnc/bin/addIpAddresses.sh VGW 10.5.0 22 250

7. Initialize vcpe

::

   vcpe.py init

8. If running with oom_mode=False run a command printed at the end of the above step from k8s control node to insert vcpe customer service workflow entry in SO catalogdb. It will be done automatically otherwise.


9. Instantiate vCPE infra services

::

    vcpe.py infra

10. From Rancher node run vcpe healthcheck command to check connectivity from sdnc to brg and gmux, and vpp configuration of brg and gmux.

::

    healthcheck-k8s.py --namespace <namespace name> --environment <env name>

11. Instantiate vCPE customer service.

::

    vcpe.py customer

12. Update libevel.so in vGMUX VM and restart the VM. This allows vGMUX to send events to VES collector in close loop test. See tutorial wiki for details

13. Run heatbridge. The heatbridge command usage: demo-k8s.sh <namespace> heatbridge <stack_name> <service_instance_id> <service> <oam-ip-address>, please refer to vCPE tutorial page on how to fill in those paraemters. See an example as following:

::

    ~/integration/test/vcpe# ~/oom/kubernetes/robot/demo-k8s.sh onap heatbridge vcpe_vfmodule_e2744f48729e4072b20b_201811262136 d8914ef3-3fdb-4401-adfe-823ee75dc604 vCPEvGMUX 10.0.101.21

14. Start closed loop test by triggering packet drop VES event, and monitor if vGMUX is restarting. You may need to run the command twice if the first run fails

::

    vcpe.py loop


Test Status
~~~~~~~~~~~~~~~~~~~~~
The use case has been tested for Dublin release, the test report can be found on https://wiki.onap.org/display/DW/vCPE+%28Heat%29+-+Dublin+Test+Status

Known Issues and Workaround
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1) NATs are installed on BRG and vBNG. In order to allow SDNC to send BRG configuration message through vBNG, SDNC host VM IP address is preloaded on BRG and vBNG during VM instantiation, and provisioned into the NATs. If SDNC changes its host VM, SDNC host VM IP changes and we need to manually update the IP in /opt/config/sdnc_ip.txt. Then run:

::

  root>vppctl tap delete tap-0
  root>vppctl tap delete tap-1
  root>/opt/nat_service.sh
  root>vppctl restart

2) During vCPE customer service instantiation, though vGW should come up successfully BRG vxlan tunnel configuration is likely to fail in SDNC cluster environment due to SDNC unreachable to BRG. See more detail in JIRA INT-1127. One workaround is to run vCPE use case with SDNC cluster disabled.

3) In some Openstack environments (e.g. Ocata version), there is an issue with DHCP anti-spoofing rules preventing BRG to receive DHCP reply (Option 82) from DHCP. By default Openstack neutron is using *IptablesFirewallDriver*, which is actively inserting *Prevent DHCP Spoofing by VM* rules into linuxbridge firewall rules. This feature should prevent mailicious traffic from rogue VM inside Openstack, however it's affecting also vCPE usecase. Manual tweaking of fw rules is not persistent and those rules are automatically regenerated, but one can disable this logic by switching to *neutron.agent.firewall.NoopFirewallDriver*. More details can be found on https://codesomniac.com/2017/07/how-to-run-a-dhcp-server-as-openstack-instance/

   **NOTE:** To propagate change in firewall_driver one needs to restart neutron-linuxbridge-agent and also openstack-nova-compute services.

   Additionally Neutron's Port Security Extension Driver is by default preventing any routing functions of an instance (be it a router or VNF). Hence for smoothest vCPE experience it's advised to either disable the packet filtering by setting port_security_enabled flag for a network/port to "False" or alternatively add allowed_address_pairs to relevant VNFs ports with appropriate network prefixes. Port security driver can be also disabled globally, for more insight into Port Security Extension Driver please visit https://wiki.openstack.org/wiki/Neutron/ML2PortSecurityExtensionDriver
