.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0
   Copyright 2020 CMCC Technologies Co., Ltd.  All rights reserved.

.. _docs_vcpe_tosca_local:

vCPE Tosca Local Mode Use Case
------------------------------

Description
~~~~~~~~~~~
vCPE tosca use case is based on Network Enhanced Residential Gateway architecture specified in Technical Report 317 (TR-317), which defines how service providers deploy residential broadband services like High Speed Internet Access. The use case implementation has infrastructure services and customer service. The common infrastructure services are deployed first and shared by all customers. The use case demonstrates ONAP capabilities to design, deploy, configure and control sophisticated services.

More details on the vCPE Use Case can be found on wiki page https://wiki.onap.org/pages/viewpage.action?pageId=3246168

Local is the way how to distribute the network elements. Here we use local means we want upload the csar file to distribute the vnf and ns configurations.

Source Code
~~~~~~~~~~~
vcpe tosca local test scripts: https://git.onap.org/integration/tree/test/vcpe_tosca/local

How to Use
~~~~~~~~~~
The use case has been automated by vcpe_tosca_test scripts. The followings are the main steps to run the use case in Integration lab environment:

1) Install ONAP CLI environment, open_cli_product is onap-elalto.


2) Prepare openstack test environment.

   * Create project(tenant) and user on openstack

   Openstack Horizon--Identity--Projects page

   .. image:: files/vcpe_tosca/create_project.png

   Openstack Horizon--Identity--Users page

   .. image:: files/vcpe_tosca/create_user.png

   Manage Project Members

   .. image:: files/vcpe_tosca/manage_project_user.png

   * Create and upload image for VNF

   Identify the version of the lab server, my lab server is Ubuntu 16.04.3 LTS.

   ::

      root@onap-dengyuanhong-master:~# cat /etc/lsb-release
      DISTRIB_ID=Ubuntu
      DISTRIB_RELEASE=16.04
      DISTRIB_CODENAME=xenial
      DISTRIB_DESCRIPTION="Ubuntu 16.04.3 LTS"


    Download the related ubuntu image from https://cloud-images.ubuntu.com/

    .. image:: files/vcpe_tosca/image.png

    Openstack Horizon--Project--Compute--Images page, create an image named image, the name must be the same with image which is defined in vnf csar file.

    .. image:: files/vcpe_tosca/create_image.png

3) Update the configuration file vcpe_config.json under https://git.onap.org/integration/tree/test/vcpe_tosca/local/config

   You should update the values if you want to run in your environment.

   Firstly, identify the Region name you used on your openstack environment, our Region name is RegionOne, it will be used by the configuration file.

   ::

      [wrsroot@controller-0 ~(keystone_admin)]$ openstack region list
      +-----------+---------------+-------------+
      | Region    | Parent Region | Description |
      +-----------+---------------+-------------+
      | RegionOne | None          |             |
      +-----------+---------------+-------------+


   Secondly, update the values according to your environment.

   ::

      "open_cli_home": set to the oclip home path,
      "aai_url": set to msb ip and port you used,
      "msb_url": set to msb ip and port you used,
      "multicloud_url": set to msb ip and port you used,

      "cloud_region_data": {
           "RegionOne":(update to your Region name) {
               "cloud-region-version": "titanium_cloud",
                "esr-system-info-id": "1111ce1f-aa78-4ebf-8d6f-4b62773e9b01",
                "service-url": the ip change to your openstack ip address,
                "user-name": the user name you created on openstack,
                "password": the user password you created on openstack,
                "system-type": "VIM",
                "ssl-insecure": true,
                "cloud-domain": "Default",
                "default-tenant": the project name you created on openstack,
                "tenant-id": the project id you created on openstack,
                "cloud-type": "openstack",
                "identity-url": the ip change to your openstack ip address,
                "system-status": "active"
           }
      }
      "vfc-url": set to msb ip and port you used,
      "vnfs": {
           "vgw": {
               "path": "vgw.csar", set to your vnf csar file path
                "key": "key2",
                "value": "value2"
           }
        },
       "ns": {
           "key": "key1",
           "value": "value1",
           "path": "ns_vgw.csar", set to you ns csar file path
           "name": "vcpe11"
       },
      "location": "VCPE22_RegionOne", set to CloudOwner_CloudRegion
       "vnfm_params": {
           "GVNFMDRIVER": {
               "type": "gvnfmdriver",
               "vendor": "vfc",
               "version": "v1.0",
                "url": set to msb ip and port you used,
                "vim-id": "VCPE22_RegionOne", set to CloudOwner_CloudRegion
                "user-name": "admin",
                "user-password": "admin",
                "vnfm-version": "v1.0"
            }
        }


4) The vnf csar file include Infra, vGW, vBNG, vBRGEMU and vGMUX, and the ns csar file is ns. https://git.onap.org/integration/tree/test/vcpe_tosca/local/csar


5) The key test script is vcpe_tosca_test.py which is under https://git.onap.org/integration/tree/test/vcpe_tosca/local/

   Run command is

   ::

      python3 -m unittest vcpe_tosca_test.py

   Before run the command, you should install requests: pip install requests, and update the path of configuration file vcpe_config.json.

5) Release of our environment

   ::

      vfc-nslcm: 1.3.8
      vfc-vnflcm: 1.3.8
      vfc-gvnfm: 1.3.8
      modeling-etsicatalog: 1.0.5
      multicloud-framework: 1.5.1
      multicloud-windriver: 1.5.5
      cli: onap-elalto


Note
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1) You should create an image named image before running the test script, the name must be the same with image which is defined in vnf csar file.

2) There are something wrong if you use the cli dublin, so please use elalto instead.


Known Issues and Workaround
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1) There is time out issue when terminating vnf, the solution is refer to

   https://gerrit.onap.org/r/c/vfc/nfvo/driver/vnfm/gvnfm/+/105192

2) The process of terminating job is chaotic, the solution is refer to

   https://gerrit.onap.org/r/c/vfc/nfvo/lcm/+/105449
