.. _docs_bbs:

BBS (Broadband Service)
-----------------------

Overview
~~~~~~~~
The BBS use case proposes using ONAP for the design, provisioning, life-cycle
management and assurance of broadband services. BBS focuses on multi-Gigabit
Internet Connectivity services based on PON (Passive Optical Network) access
technology.

In Frankfurt release, BBS enables ONAP to

1. Establish a subscriber's HSIA (High Speed Internet Access) service from an ONT (Optical Network Termination unit) to the Internet drain

   - The HSIA service is designed and deployed using ONAP's design and deployment capabilities
   - The HSIA service activation is initiated via ONAP's External APIs and orchestrated and controlled using ONAP orchestration and control capabilities. The control capabilities leverage a 3rd party controller to implement the requested actions within the technology domain/location represented by the domain specific SDN management and control function.

2. Detect the change of location for ONT devices (Nomadic ONT devices)

   - PNF (Re-)Registration for an ONT

     - Subscriber association to an ONT via ONAP's External APIs
     - ONT association with a expected Access UNI (PON port) when a HSIA service is created/deployed for a subscriber
     - PNF (Re-)Registration using ONAP's PNF registration capabilities

   - Service location modification that is detected by ONAP's analytic and initiated via the closed loop capabilities

     - The closed loop capabilities invoke a HSIA location change service that
       is orchestrated and controlled using ONAP capabilities and 3rd party controllers

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
         oof:
           auth: test:testpwd
           callbackEndpoint: http://so-bpmn-infra.onap:8081/mso/WorkflowMessage
           endpoint: https://oof-osdf.onap:8698/api/oof/v1/placement
           timeout: PT30M
         workflow:
  +        custom:
  +          BBS_E2E_Service:
  +            sdnc:
  +              need: true
  +            resource:
  +              sequence: VnfVirtualLink,CPE,AccessConnectivity,InternetProfile,PonUni,OltNni,OntNni
           CreateGenericVNFV1:
             aai:
               volume-group:
                 uri: /aai/v6/cloud-infrastructure/volume-groups/volume-group
           default:
             aai:
     ...

  ## Restart the pod
  ~/oom/kubernetes# kubectl delete po dev-so-so-bpmn-infra-7556d7f6bc-8fthk


As shown below, new entries need to be inserted manually in SO database (mariadb-galera) in order to map a given resource model to a specific BPMN recipe. For instance, the CPE is modeled in SDC as a VF but it is treated as PNF resource by SO by using the handlePNF BPMN recipe. Those entries need to be inserted in catalogdb database > vnf_recipe table.

IMPORTANT: make sure vnf_recipe.NF_ROLE matches vnf_resource.MODEL_NAME, and vnf_recipe.VERSION_STR matches vnf_resource.MODEL_VERSION.

::

  root@onap-rancher-daily:/home/ubuntu# kubectl exec -ti dev-mariadb-galera-mariadb-galera-0 sh
  sh-4.2$ mysql -u root -p
  MariaDB [(none)]> use catalogdb;
  MariaDB [catalogdb]> INSERT INTO vnf_recipe (NF_ROLE, ACTION, SERVICE_TYPE, VERSION_STR, DESCRIPTION, ORCHESTRATION_URI, VNF_PARAM_XSD, RECIPE_TIMEOUT)
  VALUES
    ("InternetProfile", "createInstance", "NF", "1.0", "create InternetProfile", "/mso/async/services/CreateSDNCNetworkResource", '{"operationType":"AccessConnectivity"}', 180000),
    ("AccessConnectivity", "createInstance", "NF", "1.0", "create AccessConnectivity", "/mso/async/services/CreateSDNCNetworkResource", '{"operationType":"InternetProfile"}', 180000),
    ("CPE", "createInstance", "NF", "1.0", "create CPE", "/mso/async/services/HandlePNF", NULL, 180000);

  MariaDB [catalogdb]> select * from vnf_recipe where NF_ROLE IN ('AccessConnectivity','InternetProfile', 'CPE');
  +-------+--------------------+----------------+--------------+-------------+---------------------------+-----------------------------------------------+----------------------------------------+----------------+---------------------+--------------+
  | id    | NF_ROLE            | ACTION         | SERVICE_TYPE | VERSION_STR | DESCRIPTION               | ORCHESTRATION_URI                             | VNF_PARAM_XSD                          | RECIPE_TIMEOUT | CREATION_TIMESTAMP  | VF_MODULE_ID |
  +-------+--------------------+----------------+--------------+-------------+---------------------------+-----------------------------------------------+----------------------------------------+----------------+---------------------+--------------+
  | 10048 | InternetProfile    | createInstance | NF           | 1.0         | create InternetProfile    | /mso/async/services/CreateSDNCNetworkResource | {"operationType":"InternetProfile"}    |        1800000 | 2020-01-20 17:43:07 | NULL         |
  | 10051 | AccessConnectivity | createInstance | NF           | 1.0         | create AccessConnectivity | /mso/async/services/CreateSDNCNetworkResource | {"operationType":"AccessConnectivity"} |        1800000 | 2020-01-20 17:43:07 | NULL         |
  | 10054 | CPE                | createInstance | NF           | 1.0         | create CPE                | /mso/async/services/HandlePNF                 | NULL                                   |        1800000 | 2020-01-20 17:43:07 | NULL         |
  +-------+--------------------+----------------+--------------+-------------+---------------------------+-----------------------------------------------+----------------------------------------+----------------+---------------------+--------------+
  3 rows in set (0.00 sec)


DMaaP Message Router
====================

Create the required topics in DMaaP

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

Description: :doc:`BBS-ep <https://docs.onap.org/en/latest/submodules/dcaegen2.git/docs/sections/services/bbs-event-processor/index.html>`

The following BBS event processor blueprints will be used:
- `k8s-bbs-event-processor.yaml <https://git.onap.org/dcaegen2/services/plain/components/bbs-event-processor/dpo/blueprints/k8s-bbs-event-processor.yaml-template?h=frankfurt>`_
- `bbs-event-processor-input.yaml <https://git.onap.org/dcaegen2/services/plain/components/bbs-event-processor/dpo/blueprints/bbs-event-processor-input.yaml?h=frankfurt>`_

The BBS-ep deployment procedure:

::

  ~/oom/kubernetes# kubectl exec -ti dev-dcaegen2-dcae-bootstrap-85f664d489-54pmt bash

  [root@dev-dcaegen2-dcae-bootstrap-85f664d489-54pmt /]# cfy blueprints validate /blueprints/k8s-bbs-event-processor.yaml
  Validating blueprint: /blueprints/k8s-bbs-event-processor.yaml-template
  Blueprint validated successfully

  [root@dev-dcaegen2-dcae-bootstrap-85f664d489-54pmt /]# cfy blueprints upload -b bbs-ep /blueprints/k8s-bbs-event-processor.yaml
  Uploading blueprint /blueprints/k8s-bbs-event-processor.yaml...
  k8s-bbs-event-pro... |################################################| 100.0%
  Blueprint uploaded. The blueprint's id is bbs-ep
  [root@dev-dcaegen2-dcae-bootstrap-85f664d489-54pmt /]# cfy deployments create -b bbs-ep -i /bbs-event-processor-input.yaml bbs-ep
  Creating new deployment from blueprint bbs-ep...
  Deployment created. The deployment's id is bbs-ep

  [root@dev-dcaegen2-dcae-bootstrap-85f664d489-54pmt /]# cfy executions start -d bbs-ep install
  Executing workflow install on deployment bbs-ep [timeout=900 seconds]
  2019-05-01 11:35:32.007  CFY <bbs-ep> Starting 'install' workflow execution
  2019-05-01 11:35:32.587  CFY <bbs-ep> [bbs-event-processor_yd5ucp] Creating node instance
  2019-05-01 11:35:32.587  CFY <bbs-ep> [bbs-event-processor_yd5ucp.create] Sending task 'k8splugin.create_for_components'
  2019-05-01 11:35:33.953  LOG <bbs-ep> [bbs-event-processor_yd5ucp.create] INFO: Added config for s4d51b24f52264857b7ef520be9efc46b-bbs-event-processor
  2019-05-01 11:35:33.953  LOG <bbs-ep> [bbs-event-processor_yd5ucp.create] INFO: Added config for s4d51b24f52264857b7ef520be9efc46b-bbs-event-processor
  2019-05-01 11:35:34.596  CFY <bbs-ep> [bbs-event-processor_yd5ucp.create] Task succeeded 'k8splugin.create_for_components'
  2019-05-01 11:35:34.596  CFY <bbs-ep> [bbs-event-processor_yd5ucp] Node instance created
  2019-05-01 11:35:34.596  CFY <bbs-ep> [bbs-event-processor_yd5ucp] Configuring node instance: nothing to do
  2019-05-01 11:35:35.227  CFY <bbs-ep> [bbs-event-processor_yd5ucp] Starting node instance
  2019-05-01 11:35:35.227  CFY <bbs-ep> [bbs-event-processor_yd5ucp.start] Sending task 'k8splugin.create_and_start_container_for_components'
  2019-05-01 11:35:36.818  LOG <bbs-ep> [bbs-event-processor_yd5ucp.start] INFO: Passing k8sconfig: {'tls': {u'cert_path': u'/opt/tls/shared', u'image': u'nexus3.onap.org:10001/onap/org.onap.dcaegen2.deployments.tls-init-container:1.0.3-STAGING-latest'}, 'filebeat': {u'config_map': u'dcae-filebeat-configmap', u'config_path': u'/usr/share/filebeat/filebeat.yml', u'log_path': u'/var/log/onap', u'image': u'docker.elastic.co/beats/filebeat:5.5.0', u'data_path': u'/usr/share/filebeat/data', u'config_subpath': u'filebeat.yml'}, 'consul_dns_name': u'consul-server.onap', 'image_pull_secrets': [u'onap-docker-registry-key'], 'namespace': u'onap', 'consul_host': 'consul-server:8500', 'default_k8s_location': u'central'}
  2019-05-01 11:35:36.818  LOG <bbs-ep> [bbs-event-processor_yd5ucp.start] INFO: k8s deployment initiated successfully for s4d51b24f52264857b7ef520be9efc46b-bbs-event-processor: {'services': ['s4d51b24f52264857b7ef520be9efc46b-bbs-event-processor', 'xs4d51b24f52264857b7ef520be9efc46b-bbs-event-processor'], 'namespace': u'onap', 'location': u'central', 'deployment': 'dep-s4d51b24f52264857b7ef520be9efc46b-bbs-event-processor'}
  2019-05-01 11:35:36.818  LOG <bbs-ep> [bbs-event-processor_yd5ucp.start] INFO: Waiting up to 1800 secs for s4d51b24f52264857b7ef520be9efc46b-bbs-event-processor to become ready
  2019-05-01 11:36:58.376  LOG <bbs-ep> [bbs-event-processor_yd5ucp.start] INFO: Done starting: s4d51b24f52264857b7ef520be9efc46b-bbs-event-processor
  2019-05-01 11:36:57.873  LOG <bbs-ep> [bbs-event-processor_yd5ucp.start] INFO: k8s deployment is ready for: s4d51b24f52264857b7ef520be9efc46b-bbs-event-processor
  2019-05-01 11:36:59.119  CFY <bbs-ep> [bbs-event-processor_yd5ucp.start] Task succeeded 'k8splugin.create_and_start_container_for_components'
  2019-05-01 11:36:59.119  CFY <bbs-ep> [bbs-event-processor_yd5ucp] Node instance started
  2019-05-01 11:36:59.119  CFY <bbs-ep> 'install' workflow execution succeeded
  Finished executing workflow install on deployment bbs-ep
  * Run 'cfy events list -e 7f285182-4f85-478c-95f3-b8b6970f7c8d' to retrieve the execution's events/logs

IMPORTANT: Make sure that the configuration of BBS-ep in Consul contains the following version for the close loop policy in order to match the version expected by BBS APEX policy:

::

  "application.clVersion": "1.0.2"

DCAE: RESTCONF Collector
========================

Description: :doc:`RESTCONF Collector <https://docs.onap.org/en/latest/submodules/dcaegen2.git/docs/sections/services/bbs-event-processor/index.html>`

The following RESTCONF collector blueprints will be used:
- `k8s-rcc-policy.yaml <https://git.onap.org/dcaegen2/collectors/restconf/plain/dpo/blueprints/k8s-rcc-policy.yaml-template?h=frankfurt>`_

RESTCONF Collector deployment procedure:

::

  [root@dev-dcaegen2-dcae-bootstrap-779767c49c-7cvdw /]# cfy blueprints validate blueprints/k8s-rcc-policy.yaml
  Validating blueprint: blueprints/k8s-rcc-policy.yaml
  Blueprint validated successfully

  [root@dev-dcaegen2-dcae-bootstrap-779767c49c-7cvdw /]# cfy blueprints upload -b restconfcollector /blueprints/k8s-rcc-policy.yaml
  Uploading blueprint /blueprints/k8s-rcc-policy.yaml...
   k8s-rcc-policy.yaml |#################################################| 100.0%
  Blueprint uploaded. The blueprint's id is restconfcollector

  [root@dev-dcaegen2-dcae-bootstrap-779767c49c-7cvdw /]# cfy deployments create -b restconfcollector
  Creating new deployment from blueprint restconfcollector...
  Deployment created. The deployment's id is restconfcollector

  [root@dev-dcaegen2-dcae-bootstrap-779767c49c-7cvdw /]# cfy executions start -d restconfcollector install
  Executing workflow install on deployment restconfcollector [timeout=900 seconds]
  2020-01-13 15:12:52.119  CFY <restconfcollector> Starting 'install' workflow execution
  2020-01-13 15:12:52.701  CFY <restconfcollector> [rcc_k8s_8qm5me] Creating node instance
  2020-01-13 15:12:52.701  CFY <restconfcollector> [rcc_k8s_8qm5me.create] Sending task 'k8splugin.create_for_platforms'
  2020-01-13 15:12:55.168  LOG <restconfcollector> [rcc_k8s_8qm5me.create] INFO: Added config for dcaegen2-collectors-rcc
  2020-01-13 15:12:55.747  LOG <restconfcollector> [rcc_k8s_8qm5me.create] INFO: Done setting up: dcaegen2-collectors-rcc
  2020-01-13 15:12:55.747  CFY <restconfcollector> [rcc_k8s_8qm5me.create] Task succeeded 'k8splugin.create_for_platforms'
  2020-01-13 15:12:55.747  CFY <restconfcollector> [rcc_k8s_8qm5me] Node instance created
  2020-01-13 15:12:56.341  CFY <restconfcollector> [rcc_k8s_8qm5me] Configuring node instance: nothing to do
  2020-01-13 15:12:56.341  CFY <restconfcollector> [rcc_k8s_8qm5me] Starting node instance
  2020-01-13 15:12:56.341  CFY <restconfcollector> [rcc_k8s_8qm5me.start] Sending task 'k8splugin.create_and_start_container_for_platforms'
  2020-01-13 15:12:57.559  LOG <restconfcollector> [rcc_k8s_8qm5me.start] INFO: Starting k8s deployment for dcaegen2-collectors-rcc, image: nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.restconfcollector:1.1.1, env: {'CONSUL_HOST': u'consul-server.onap.svc.cluster.local', u'DMAAPHOST': u'message-router.onap.svc.cluster.local', 'CONFIG_BINDING_SERVICE': u'config_binding_service', u'CBS_HOST': u'config-binding-service.dcae.svc.cluster.local', u'DMAAPPORT': u'3904', u'CBS_PORT': u'10000', u'CONSUL_PORT': u'8500', u'DMAAPPUBTOPIC': u'unauthenticated.DCAE_RCC_OUTPUT'}, kwargs: {'readiness': {u'endpoint': u'/healthcheck', u'type': u'http', u'timeout': u'1s', u'interval': u'15s'}, 'tls_info': {}, 'replicas': 1, u'envs': {u'CONSUL_HOST': u'consul-server.onap.svc.cluster.local', u'DMAAPHOST': u'message-router.onap.svc.cluster.local', u'CONFIG_BINDING_SERVICE': u'config_binding_service', u'CBS_HOST': u'config-binding-service.dcae.svc.cluster.local', u'DMAAPPORT': u'3904', u'CBS_PORT': u'10000', u'CONSUL_PORT': u'8500', u'DMAAPPUBTOPIC': u'unauthenticated.DCAE_RCC_OUTPUT'}, 'labels': {'cfydeployment': u'restconfcollector', 'cfynodeinstance': u'rcc_k8s_8qm5me', 'cfynode': u'rcc_k8s'}, 'ctx': <cloudify.context.CloudifyContext object at 0x7fb63e5872d0>, 'always_pull_image': False, 'resource_config': {}, 'log_info': {u'log_directory': u'/opt/app/RCCollector/logs'}, u'ports': [u'8080:30416'], 'k8s_location': u'central'}
  2020-01-13 15:12:58.275  LOG <restconfcollector> [rcc_k8s_8qm5me.start] INFO: Passing k8sconfig: {'tls': {u'cert_path': u'/opt/tls/shared', u'image': u'nexus3.onap.org:10001/onap/org.onap.dcaegen2.deployments.tls-init-container:1.0.3', u'ca_cert_configmap': u'dev-dcaegen2-dcae-bootstrap-dcae-cacert', u'component_ca_cert_path': u'/opt/dcae/cacert/cacert.pem'}, 'filebeat': {u'config_map': u'dcae-filebeat-configmap', u'config_path': u'/usr/share/filebeat/filebeat.yml', u'log_path': u'/var/log/onap', u'image': u'docker.elastic.co/beats/filebeat:5.5.0', u'data_path': u'/usr/share/filebeat/data', u'config_subpath': u'filebeat.yml'}, 'consul_dns_name': u'consul-server.onap', 'image_pull_secrets': [u'onap-docker-registry-key'], 'namespace': u'onap', 'consul_host': 'consul-server:8500', 'default_k8s_location': u'central'}
  2020-01-13 15:12:58.275  LOG <restconfcollector> [rcc_k8s_8qm5me.start] INFO: k8s deployment initiated successfully for dcaegen2-collectors-rcc: {'services': ['dcaegen2-collectors-rcc', 'xdcaegen2-collectors-rcc'], 'namespace': u'onap', 'location': u'central', 'deployment': 'dep-dcaegen2-collectors-rcc'}
  2020-01-13 15:12:58.275  LOG <restconfcollector> [rcc_k8s_8qm5me.start] INFO: Waiting up to 1800 secs for dcaegen2-collectors-rcc to become ready
  2020-01-13 15:13:29.970  LOG <restconfcollector> [rcc_k8s_8qm5me.start] INFO: k8s deployment is ready for: dcaegen2-collectors-rcc
  2020-01-13 15:13:30.550  CFY <restconfcollector> [rcc_k8s_8qm5me.start] Task succeeded 'k8splugin.create_and_start_container_for_platforms'
  2020-01-13 15:13:30.550  CFY <restconfcollector> [rcc_k8s_8qm5me] Node instance started
  2020-01-13 15:13:31.265  CFY <restconfcollector> 'install' workflow execution succeeded
  Finished executing workflow install on deployment restconfcollector
  * Run 'cfy events list -e 2ea4f906-536b-48b1-aa34-dd6b4baed255' to retrieve the execution's events/logs

DCAE: VES mapper
================

Installation instructions: :doc:`VES Mapper <https://docs.onap.org/en/latest/submodules/dcaegen2.git/docs/sections/services/bbs-event-processor/index.html>`

The following VES mapper blueprints will be used:
- `k8s-vesmapper.yaml <https://gerrit.onap.org/r/gitweb?p=dcaegen2/services/mapper.git;a=blob_plain;f=UniversalVesAdapter/dpo/blueprints/k8s-vesmapper.yaml-template.yaml>`_

IMPORTANT: Set the image to nexus3.onap.org:10001/onap/org.onap.dcaegen2.services.mapper.vesadapter.universalvesadaptor:1.0.0 in the blueprint

DCAE: VES collector
===================

Configure the mapping of the VES event domain to the correct DMaaP topic in Consul: ves-statechange --> unauthenticated.CPE_AUTHENTICATION

1. Access Consul UI <http://<consul_server_ui>:30270/ui/#/dc1/services>

2. Modify the dcae-ves-collector configuration by adding a new VES domain to DMaaP topic mapping

::

  "ves-statechange": {"type": "message_router", "dmaap_info": {"topic_url": "http://message-router:3904/events/unauthenticated.CPE_AUTHENTICATION"}}

3. Click on UPDATE in order to apply the new configuration


SDNC: BBS DGs (Directed Graphs)
===============================

Make sure that the following BBS DGs in the SDNC DGBuilder are in Active state

::

  bbs-access-connectivity-vnf-topology-operation-create-huawei
  bbs-access-connectivity-vnf-topology-operation-delete-huawei
  bbs-internet-profile-vnf-topology-operation-change-huawei
  bbs-internet-profile-vnf-topology-operation-common-huawei
  bbs-internet-profile-vnf-topology-operation-create-huawei
  bbs-internet-profile-vnf-topology-operation-delete-huawei
  validate-bbs-vnf-input-parameters

DGBuilder URL: `<https://sdnc.api.simpledemo.onap.org:30203>`_

Access SDN M&C DG
=================
Configure Access SDN M&C IP address in SDNC DG using dgbuilder. For instance:

> GENERIC-RESOURCE-API: bbs-access-connectivity-vnf-topology-operation-create-huawei.json
> GENERIC-RESOURCE-API: bbs-access-connectivity-vnf-topology-operation-delete-huawei.json

1. Export the relevant DG

2. Modify the IP address

3. Import back the DG and Activate it

DGBuilder URL: `<https://sdnc.api.simpledemo.onap.org:30203>`_

Edge SDN M&C DG
===============
Configure Edge SDN M&C IP address in SDNC DG using dgbuilder. For instance:

> GENERIC-RESOURCE-API: bbs-access-connectivity-vnf-topology-operation-common-huawei.json

1. Export the relevant DG

2. Modify the IP address

3. Import back the DG and Activate it

DGBuilder URL: `<https://sdnc.api.simpledemo.onap.org:30203>`_

Add SSL certificate of the 3rd party controller into the SDNC trust store
=========================================================================

::

  kubectl exec -ti dev-sdnc-sdnc-0 -n onap -- bash

  openssl s_client -connect <IP_ADDRESS_EXT_CTRL>:<PORT>
  # copy server certificate and paste in /tmp/<CA_CERT_NAME>.crt
  sudo keytool -importcert -file /tmp/<CA_CERT_NAME>.crt -alias <CA_CERT_NAME>_key -keystore truststore.onap.client.jks -storepass adminadmin
  keytool -list -keystore truststore.onap.client.jks -storepass adminadmin | grep <CA_CERT_NAME>


Policy: BBS APEX policy
=======================

Deployment procedure of BBS APEX Policy (master, apex-pdp image v2.3+)

1. Make Sure APEX PDP is running and in Active state

::

  API:  GET
  URL: {{POLICY-PAP-URL}}/policy/pap/v1/pdps

2. Create the operational control loop APEX policy type

::

  API: POST
  URL: {{POLICY-API-URL}}/policy/api/v1/policytypes

3. Create BBS APEX policy

::

  API: POST
  URL: {{POLICY-API-URL}}/policy/api/v1/policytypes/onap.policies.controlloop.operational.Apex/versions/1.0.0/policies

4. Deploy BBS policy

::

  API: POST
  URL: {{POLICY-PAP-URL}}/policy/pap/v1/pdps/deployments/batch

5. Verify the deployment

::

  API: GET
  URL: {{POLICY-API-URL}}/policy/api/v1/policytypes/onap.policies.controlloop.operational.Apex/versions/1.0.0/policies/

Edge Services: vBNG+AAA+DHCP, Edge SDN M&C
==========================================

Installation and setup instructions: `Swisscom Edge SDN M&C and virtual BNG <https://wiki.onap.org/pages/viewpage.action?pageId=63996962>`_

References
==========

Please refer to the following wiki page for further steps related to the BBS service design and instantiation:

- `BBS Documentation <https://wiki.onap.org/pages/viewpage.action?pageId=75303137#BBSDocumentation(Frankfurt)-BBSServiceConfiguration>`_

Known Issues
------------

- E2E Service deletion workflow does not delete the PNF resource in AAI (`SO-2609 <https://jira.onap.org/browse/SO-2609>`_)

.. |image1| image:: files/bbs/BBS_arch_overview.png
   :width: 6.5in
.. |image2| image:: files/bbs/BBS_system_view.png
   :width: 6.5in
