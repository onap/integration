.. _docs_bbs:

BBS (Broadband Service)
-----------------------

Overview
~~~~~~~~
The BBS use case proposes using ONAP for the design, provisioning, life-cycle
management and assurance of broadband services. BBS focuses on multi-Gigabit
Internet Connectivity services based on PON (Passive Optical Network) access
technology.

In Dublin release, BBS enables ONAP to

1. Establish a subscriber's HSIA (High Speed Internet Access) service from an ONT (Optical Network Termination unit) to the Internet drain

   - The HSIA service is designed and deployed using ONAP's design and deployment capabilities
   - The HSIA service activation is initiated via ONAP's External APIs and orchestrated and controlled using ONAP orchestration and control capabilities. The control capabilities leverage a 3rd party controller to implement the requested action within the technology domain/location represented by the domain specific SDN management and control function.

2. Detect the change of location for ONT devices (Nomadic ONT devices)

   - PNF (Re-)Registration for an ONT

     - Subscriber association to an ONT via ONAP's External APIs
     - ONT association with a expected Access UNI (PON port) when a HSIA service is created/deployed for a subscriber
     - PNF (Re-)Registration using ONAP's PNF registration capabilities

   - Service location modification that is detected by ONAP's analytic and initiated via the closed loop capabilities

     - The closed loop capabilities invoke a HSIA location change service that is orchestrated and controlled using ONAP capabilities and 3rd party controllers

|image1|

**Figure 1. Architecture Overview**

System View
~~~~~~~~~~~
BBS relies on key ONAP components such as External API, SO, AAI, SDC, Policy
(APEX engine), DCAE (PRH, BBS Event Processor, VES collector, VES mapper,
RESTCONF collector) and SDNC

|image2|

**Figure 2. System View**

System Set Up and configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SO: Custom Workflow Configuration
=================================

::

  ~/oom/kubernetes# kubectl edit cm dev-so-so-bpmn-infra-app-configmap

  mso:
  ...
    workflow:
      custom:
        BBS_E2E_Service:
          sdnc:
            need: true
  ...

  ## Restart the pod
  ~/oom/kubernetes# kubectl delete po dev-so-so-bpmn-infra-7556d7f6bc-8fthk


As shown below, new entries need to be inserted manually in SO database (mariadb-galera) in order to map a given resource model to a specific BPMN recipe. For instance, the CPE is modeled in SDC as a VF but it is treated as PNF resource by SO by using the handlePNF BPMN recipe. Those entries need to be inserted in catalogdb database > vnf_recipe table.

IMPORTANT: make sure vnf_recipe.NF_ROLE matches vnf_resource.MODEL_NAME, and vnf_recipe.VERSION_STR matches vnf_resource.MODEL_VERSION.

::

  root@onap-rancher-daily:/home/ubuntu# kubectl exec -ti dev-mariadb-galera-mariadb-galera-0 sh
  sh-4.2$ mysql -u root -p
  MariaDB [(none)]> use catalogdb;
  MariaDB [catalogdb]> select * from vnf_recipe;
  ...
  +-------+---------------------+-----------------------+--------------+-------------+--------------------------------------------------------------------------------+-----------------------------------------------+---------------+----------------+---------------------+--------------------------------------+
  | id    | NF_ROLE             | ACTION                | SERVICE_TYPE | VERSION_STR | DESCRIPTION                                                                    | ORCHESTRATION_URI                             | VNF_PARAM_XSD | RECIPE_TIMEOUT | CREATION_TIMESTAMP  | VF_MODULE_ID                         |
  +-------+---------------------+-----------------------+--------------+-------------+--------------------------------------------------------------------------------+-----------------------------------------------+---------------+----------------+---------------------+--------------------------------------+
  | 10043 | InternetProfile     | createInstance        | NF           | 1.0         | create InternetProfile                                                         | /mso/async/services/CreateSDNCNetworkResource | NULL          |         180000 | 2019-02-18 08:34:39 | NULL                                 |
  | 10044 | AccessConnectivity  | createInstance        | NF           | 1.0         | create AccessConnectivity                                                      | /mso/async/services/CreateSDNCNetworkResource | NULL          |         180000 | 2019-02-18 08:34:39 | NULL                                 |
  | 10045 | CPE                 | createInstance        | NF           | 1.0         | create CPE                                                                     | /mso/async/services/HandlePNF                 | NULL          |         180000 | 2019-02-18 08:34:39 | NULL                                 |
  +-------+---------------------+-----------------------+--------------+-------------+--------------------------------------------------------------------------------+-----------------------------------------------+---------------+----------------+---------------------+--------------------------------------+
  ...
  MariaDB [catalogdb]> select * from vnf_resource;
  +--------------------+-----------------------+---------------------+--------------------------------------+-----------------+-----------------+--------------------------------------+---------------+--------------------+----------------------------------------------+-----------------------------+-------------------+-----------------------+
  | ORCHESTRATION_MODE | DESCRIPTION           | CREATION_TIMESTAMP  | MODEL_UUID                           | AIC_VERSION_MIN | AIC_VERSION_MAX | MODEL_INVARIANT_UUID                 | MODEL_VERSION | MODEL_NAME         | TOSCA_NODE_TYPE                              | HEAT_TEMPLATE_ARTIFACT_UUID | RESOURCE_CATEGORY | RESOURCE_SUB_CATEGORY |
  +--------------------+-----------------------+---------------------+--------------------------------------+-----------------+-----------------+--------------------------------------+---------------+--------------------+----------------------------------------------+-----------------------------+-------------------+-----------------------+
  | HEAT               | CPE VF                | 2019-05-15 22:11:07 | 8f5fe623-c5e3-4ab3-90f9-3a28daea6601 | NULL            | NULL            | 0ee07fe6-a156-4e59-9dee-09a775d02bca | 1.0           | CPE                | org.openecomp.resource.vf.Cpe                | NULL                        | Generic           | Infrastructure        |
  | HEAT               | InternetProfile VF    | 2019-05-15 22:11:11 | a8de16d8-0d1a-4a19-80ac-2bcb2790e9a6 | NULL            | NULL            | acbe6358-6ce4-43a9-9385-111fe5cadad3 | 1.0           | InternetProfile    | org.openecomp.resource.vf.Internetprofile    | NULL                        | Generic           | Infrastructure        |
  | HEAT               | AccessConnectivity VF | 2019-05-15 22:11:13 | b464fd87-3663-46c9-adc5-6f7d9e98ff26 | NULL            | NULL            | 53018dba-c934-415d-b4b1-0b1cae9553b8 | 1.0           | AccessConnectivity | org.openecomp.resource.vf.Accessconnectivity | NULL                        | Generic           | Infrastructure        |
  +--------------------+-----------------------+---------------------+--------------------------------------+-----------------+-----------------+--------------------------------------+---------------+--------------------+----------------------------------------------+-----------------------------+-------------------+-----------------------+

Modify the MODEL_UUID and MODEL_INVARIANT_UUID for each resource in the SQL query below accordingly to your environment.

::

  INSERT INTO `vnf_resource` (`ORCHESTRATION_MODE`, `DESCRIPTION`, `CREATION_TIMESTAMP`, `MODEL_UUID`, `AIC_VERSION_MIN`, `AIC_VERSION_MAX`, `MODEL_INVARIANT_UUID`, `MODEL_VERSION`, `MODEL_NAME`, `TOSCA_NODE_TYPE`, `HEAT_TEMPLATE_ARTIFACT_UUID`, `RESOURCE_CATEGORY`, `RESOURCE_SUB_CATEGORY`)
  VALUES
      ('HEAT', 'CPE VF', '2019-05-15 22:11:07', '8f5fe623-c5e3-4ab3-90f9-3a28daea6601', NULL, NULL, '0ee07fe6-a156-4e59-9dee-09a775d02bca', '1.0', 'CPE', 'org.openecomp.resource.vf.Cpe', NULL, 'Generic', 'Infrastructure'),
      ('HEAT', 'InternetProfile VF', '2019-05-15 22:11:11', 'a8de16d8-0d1a-4a19-80ac-2bcb2790e9a6', NULL, NULL, 'acbe6358-6ce4-43a9-9385-111fe5cadad3', '1.0', 'InternetProfile', 'org.openecomp.resource.vf.Internetprofile', NULL, 'Generic', 'Infrastructure'),
      ('HEAT', 'AccessConnectivity VF', '2019-05-15 22:11:13', 'b464fd87-3663-46c9-adc5-6f7d9e98ff26', NULL, NULL, '53018dba-c934-415d-b4b1-0b1cae9553b8', '1.0', 'AccessConnectivity', 'org.openecomp.resource.vf.Accessconnectivity', NULL, 'Generic', 'Infrastructure');

Adding is_pnf flag to CPE resource input in catalogdb database. Needed in DoCreateResource BPMN for pausing the flow until a PNF is ready

::

  INSERT INTO `vnf_resource_customization` (`ID`, `MODEL_CUSTOMIZATION_UUID`, `MODEL_INSTANCE_NAME`, `MIN_INSTANCES`, `MAX_INSTANCES`, `AVAILABILITY_ZONE_MAX_COUNT`, `NF_TYPE`, `NF_ROLE`, `NF_FUNCTION`, `NF_NAMING_CODE`, `MULTI_STAGE_DESIGN`, `CREATION_TIMESTAMP`, `VNF_RESOURCE_MODEL_UUID`, `SERVICE_MODEL_UUID`, `RESOURCE_INPUT`, `CDS_BLUEPRINT_NAME`, `CDS_BLUEPRINT_VERSION`, `SKIP_POST_INSTANTIATION_CONFIGURATION`)
  VALUES
      (16, '0cea1cea-e4e4-4c91-be41-675e183a8983', 'CPE 0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', '2019-05-21 11:15:42', '8f5fe623-c5e3-4ab3-90f9-3a28daea6601', '0187be8c-8efb-4531-97fa-dbe984ed9cdb', '{\\\"nf_naming\\\":\\\"true\\\",\\\"skip_post_instantiation_configuration\\\":\\\"true\\\",\\\"multi_stage_design\\\":\\\"false\\\",\\\"availability_zone_max_count\\\":\\\"1\\\",\\\"is_pnf\\\":\\\"ont_0_is_pnf|true\\\"}', NULL, NULL, 1);

We need to ensure that the order in which the resources are processed by SO engine is correct. In BBS case, the PNF resource should go right after VnfVirtualLink (NOTE: the BPMN flow waits until PNF is ready in order to create AccessConnectivity and InternetProfile resources)

::

  MariaDB [catalogdb]> select RESOURCE_ORDER from service where MODEL_NAME="BBS_E2E_Service";
  +----------------------------------------------------------------------------+
  | RESOURCE_ORDER                                                             |
  +----------------------------------------------------------------------------+
  | VnfVirtualLink,CPE,AccessConnectivity,InternetProfile,PonUni,OltNni,OntNni |
  | VnfVirtualLink,CPE,AccessConnectivity,InternetProfile,PonUni,OltNni,OntNni |
  +----------------------------------------------------------------------------+
  2 rows in set (0.00 sec)

DMaaP Message Router
====================

Create required topics

::

  curl -X POST \
    http://mr.api.simpledemo.openecomp.org:30227/topics/create \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    -d '{
      "topicName": "unauthenticated.DCAE_CL_OUTPUT",
      "topicDescription": "",
      "partitionCount": "",
      "replicationCount": "3"
  }'

  curl -X POST \
    http://mr.api.simpledemo.openecomp.org:30227/topics/create \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    -d '{
      "topicName": "unauthenticated.CPE_AUTHENTICATION",
      "topicDescription": "",
      "partitionCount": "",
      "replicationCount": "3"
  }'

  curl -X POST \
    http://mr.api.simpledemo.openecomp.org:30227/topics/create \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    -d '{
      "topicName": "unauthenticated.PNF_READY",
      "topicDescription": "",
      "partitionCount": "",
      "replicationCount": "3"
  }'

  curl -X POST \
    http://mr.api.simpledemo.openecomp.org:30227/topics/create \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    -d '{
      "topicName": "unauthenticated.PNF_UPDATE",
      "topicDescription": "",
      "partitionCount": "",
      "replicationCount": "3"
  }'

DCAE: BBS Event Processor (BBS-ep)
==================================

Installation instructions: `BBS-ep <https://wiki.onap.org/pages/viewpage.action?pageId=60891185>`_

Update the configuration of BBS-ep in Consul with the following version for close loop (see screenshot below) in order to match the version expected by BBS APEX policy:

::

  "application.clVersion": "1.0.0"

DCAE: RESTCONF Collector
========================

Installation instructions: `RESTCONF Collector <https://wiki.onap.org/pages/viewpage.action?pageId=60891182>`_

DCAE: VES mapper
================

Installation instructions: `VES Mapper <https://wiki.onap.org/pages/viewpage.action?pageId=60891188>`_

DCAE: VES collector
===================

Configure mapping VES event domain to DMaaP topic: ves-statechange --> unauthenticated.CPE_AUTHENTICATION

Access Consul UI: http://<consul_server_ui>:30270/ui/#/dc1/services

Modify dcae-ves-collector configuration by adding a new VES domain to DMaaP topic mapping

::

  "ves-statechange": {"type": "message_router", "dmaap_info": {"topic_url": "http://message-router:3904/events/unauthenticated.CPE_AUTHENTICATION"}}

SDNC: BBS DGs (Directed Graphs)
===============================

Make sure that BBS DGs in SDNC DGBuilder are in Active state

http://dguser:test123@{{sdnc-dgbuilder_Node-IP}}:30203/#

::

  bbs-access-connectivity-network-topology-operation-create-huawei
  bbs-access-connectivity-network-topology-operation-delete-huawei
  bbs-internet-profile-network-topology-operation-change-huawei
  bbs-internet-profile-network-topology-operation-common-huawei
  bbs-internet-profile-network-topology-operation-create-huawei
  bbs-internet-profile-network-topology-operation-delete-huawei
  validate-bbs-network-input-parameters

Policy: BBS APEX policy
=======================

Inside APEX container,

1) Edit DCAEConsumer URL in `examples/config/ONAPBBS/NomadicONTPolicyModel_config.json`

2) Edit AAI and SDNC URLs in `examples/config/ONAPBBS/config.txt`

::

  AAI_URL=aai:8443
  AAI_USERNAME=AAI
  AAI_PASSWORD=AAI
  SDNC_URL=sdnc:8282
  SDNC_USERNAME=admin
  SDNC_PASSWORD=Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U
  SVC_NOTIFICATION_URL=http://c1.vm1.mso.simpledemo.openecomp.org:8080

3) Launch APEX BBS policy as a background process

::

  nohup /opt/app/policy/apex-pdp/bin/apexApps.sh engine -c examples/config/ONAPBBS/NomadicONTPolicyModel_config.json &

Edge Services: vBNG+AAA+DHCP, Edge SDN M&C
==========================================

Installation and setup instructions: `Swisscom Edge SDN M&C and virtual BNG <https://wiki.onap.org/pages/viewpage.action?pageId=63996962>`_

References
==========

Please refer to the following wiki page for additional set up and configuration
instructions:

- `BBS Documentation <https://wiki.onap.org/display/DW/BBS+Documentation>`_

Known Issues
------------

- PNF registration timeout is limited to 60s due HTTP timeout in inter-BPMN workflow calls (`SO-1938 <https://jira.onap.org/browse/SO-1938>`_)

- E2E Service deletion workflow does not delete the PNF resource in AAI (`SO-1994 <https://jira.onap.org/browse/SO-1994>`_)

- Under certain circumstances, multiple attachment points (logical links) are associated to a single PNF (`DCAEGEN2-1611 <https://jira.onap.org/browse/DCAEGEN2-1611>`_)


.. |image1| image:: files/bbs/BBS_arch_overview.png
   :width: 6.5in
.. |image2| image:: files/bbs/BBS_system_view.png
   :width: 6.5in
