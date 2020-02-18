.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. Copyright 2020 ONAP

.. _docs_vFW_CNF_CDS:

.. contents::
   :depth: 3
..

vFirewall CNF Use Case
----------------------

Source files
~~~~~~~~~~~~
- Heat/Helm/CDS models: `vFW_CNF_CDS Model`_

Description
~~~~~~~~~~~
This use case is a combination of `vFW CDS Dublin`_ and `vFW EDGEX K8S`_ use cases. The aim is to continue improving Kubernetes based Network Functions (a.k.a CNF) support in ONAP. Use case continues where `vFW EDGEX K8S`_ left and brings CDS support into picture like `vFW CDS Dublin`_ did for the old vFW Use case.

In a higher level this use case brings only one improvement yet important one i.e. the ability to instantiate more than single CNF instance of same type (with same Helm package).

Following improvements were made:

- Changed vFW Kubernetes Helm charts to support overrides (previously mostly hardcode values)
- Combined all models (Heat, Helm, CBA) in to same git repo and a creating single CSAR package `vFW_CNF_CDS Model`_
- Compared to `vFW EDGEX K8S`_ use case MACRO workflow in SO is used instead of VNF workflow. (this is general requirement to utilize CDS as part of flow)
- CDS is used to resolve instantion time parameters (Helm override)
  - Ip addresses with IPAM
  - Unique names for resources with ONAP naming service
- Multicloud/k8s plugin changed to support identifiers of vf-module concept
- CDS is used to create **multicloud/k8s profile** as part of instantiation flow (previously manual step)

Use case does not contain Closed Loop part of the vFW demo.

The vFW CNF Use Case
~~~~~~~~~~~~~~~~~~~~
The vFW CNF CDS use case shows how to instantiate multiple CNF instances similar way as VNFs bringing CNFs closer to first class citizens in ONAP.

One of the biggest practical change compared to old demos (any onap demo) is that whole network function content (user provided content) is collected to one place and more importantly into git repository (`vFW_CNF_CDS Model`_) that provides version control (that is pretty important thing). That is very basic thing but unfortunately this is a common problem when running any ONAP demo and trying to find all content from many different git repos and even some files only in ONAP wiki.

Another founding idea from the start was to provide complete content in single CSAR available directly from that git repository. Not any revolutionary idea as that's the official package format ONAP supports and all content supposed to be in that same package for single service regardless of the models and closed loops and configurations etc.

Complete content can be packaged to single CSAR file in following way:
(Note: requires Helm installed)

::

  git clone https://gerrit.onap.org/r/demo
  cd heat/vFW_CNF_CDS/templates
  make
  mkdir csar/
  make -C helm
  make[1]: Entering directory '/home/samuli/onapCode/demo/heat/vFW_CNF_CDS/templates/helm'
  rm -f base_template-*.tgz
  rm -f base_template_cloudtech_k8s_charts.tgz
  helm package base_template
  Successfully packaged chart and saved it to: /home/samuli/onapCode/demo/heat/vFW_CNF_CDS/templates/helm/base_template-0.2.0.tgz
  mv base_template-*.tgz base_template_cloudtech_k8s_charts.tgz
  rm -f vpkg-*.tgz
  rm -f vpkg_cloudtech_k8s_charts.tgz
  helm package vpkg
  Successfully packaged chart and saved it to: /home/samuli/onapCode/demo/heat/vFW_CNF_CDS/templates/helm/vpkg-0.2.0.tgz
  mv vpkg-*.tgz vpkg_cloudtech_k8s_charts.tgz
  rm -f vfw-*.tgz
  rm -f vfw_cloudtech_k8s_charts.tgz
  helm package vfw
  Successfully packaged chart and saved it to: /home/samuli/onapCode/demo/heat/vFW_CNF_CDS/templates/helm/vfw-0.2.0.tgz
  mv vfw-*.tgz vfw_cloudtech_k8s_charts.tgz
  rm -f vsn-*.tgz
  rm -f vsn_cloudtech_k8s_charts.tgz
  helm package vsn
  Successfully packaged chart and saved it to: /home/samuli/onapCode/demo/heat/vFW_CNF_CDS/templates/helm/vsn-0.2.0.tgz
  mv vsn-*.tgz vsn_cloudtech_k8s_charts.tgz
  make[1]: Leaving directory '/home/samuli/onapCode/demo/heat/vFW_CNF_CDS/templates/helm'
  mv helm/*.tgz csar/
  cp base/* csar/
  cd cba/ && zip -r vFW_CDS_CNF.zip .
    adding: TOSCA-Metadata/ (stored 0%)
    adding: TOSCA-Metadata/TOSCA.meta (deflated 38%)
    adding: Templates/ (stored 0%)
    adding: Templates/base_template-mapping.json (deflated 92%)
    adding: Templates/vfw-template.vtl (deflated 87%)
    adding: Templates/nf-params-mapping.json (deflated 86%)
    adding: Templates/vsn-mapping.json (deflated 94%)
    adding: Templates/vnf-template.vtl (deflated 90%)
    adding: Templates/vpkg-mapping.json (deflated 94%)
    adding: Templates/vsn-template.vtl (deflated 87%)
    adding: Templates/nf-params-template.vtl (deflated 44%)
    adding: Templates/base_template-template.vtl (deflated 85%)
    adding: Templates/vfw-mapping.json (deflated 94%)
    adding: Templates/vnf-mapping.json (deflated 92%)
    adding: Templates/vpkg-template.vtl (deflated 86%)
    adding: Templates/k8s-profiles/ (stored 0%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-base-profile.tar.gz (stored 0%)
    adding: Scripts/ (stored 0%)
    adding: Scripts/kotlin/ (stored 0%)
    adding: Scripts/kotlin/KotlinK8sProfileUpload.kt (deflated 75%)
    adding: Scripts/kotlin/README.md (stored 0%)
    adding: Definitions/ (stored 0%)
    adding: Definitions/artifact_types.json (deflated 57%)
    adding: Definitions/vFW_CNF_CDS.json (deflated 81%)
    adding: Definitions/node_types.json (deflated 86%)
    adding: Definitions/policy_types.json (stored 0%)
    adding: Definitions/data_types.json (deflated 93%)
    adding: Definitions/resources_definition_types.json (deflated 95%)
    adding: Definitions/relationship_types.json (stored 0%)
  mv cba/vFW_CDS_CNF.zip csar/
  #Can't use .csar extension or SDC will panic
  cd csar/ && zip -r vfw_k8s_demo.zip .
    adding: base_template_cloudtech_k8s_charts.tgz (stored 0%)
    adding: MANIFEST.json (deflated 83%)
    adding: base_template.yaml (deflated 63%)
    adding: vsn_cloudtech_k8s_charts.tgz (stored 0%)
    adding: vfw_cloudtech_k8s_charts.tgz (stored 0%)
    adding: vpkg_cloudtech_k8s_charts.tgz (stored 0%)
    adding: vsn.yaml (deflated 75%)
    adding: vpkg.yaml (deflated 76%)
    adding: vfw.yaml (deflated 77%)
    adding: vFW_CDS_CNF.zip (stored 0%)
    adding: base_template.env (deflated 23%)
    adding: vsn.env (deflated 53%)
    adding: vpkg.env (deflated 55%)
    adding: vfw.env (deflated 58%)
  mv csar/vfw_k8s_demo.zip .
  $

and package **vfw_k8s_demo.zip** file is created containing all sub-models.

Following table describes all source models to which this demo is based on.

===============  =================       ===========
Model            Git reference           Description
---------------  -----------------       -----------
Heat             `vFW_NextGen`_          Heat templates used in original vFW demo but splitted into multiple vf-modules
Helm             `vFW_Helm Model`_       Helm templates used in `vFW EDGEX K8S`_ demo
CDS model        `vFW CBA Model`_        CDS CBA model used in `vFW CDS Dublin`_ demo
===============  =================       ===========


Modeling CSAR/Helm
..................

The starting point for this demo was Helm package containing one Kubernetes application, see `vFW_Helm Model`_. In this demo we decided to follow SDC/SO vf-module concept same way as original vFW demo was splitted into multiple vf-modules instead of one (`vFW_NextGen`_). Same way we splitted Helm version of vFW into multiple Helm packages each matching one vf-module.

Produced CSAR package has following MANIFEST file (csar/MANIFEST.json) having all Helm packages modeled as dummy Heat resources matching to vf-module concept (that is originated from Heat), so basically each Helm application is visible to ONAP as own vf-module. Actual Helm package is delivered as CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACTS package through SDC and SO.

CDS model (CBA package) is delivered as SDC supported own type CONTROLLER_BLUEPRINT_ARCHIVE.

::

    {
        "name": "virtualFirewall",
        "description": "",
        "data": [
            {
                "file": "vFW_CDS_CNF.zip",
                "type": "CONTROLLER_BLUEPRINT_ARCHIVE"
            },
            {
                "file": "base_template.yaml",
                "type": "HEAT",
                "isBase": "true",
                "data": [
                    {
                        "file": "base_template.env",
                        "type": "HEAT_ENV"
                    }
                ]
            },
            {
                "file": "base_template_cloudtech_k8s_charts.tgz",
                "type": "CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACTS"
            },
            {
                "file": "vfw.yaml",
                "type": "HEAT",
                "isBase": "false",
                "data": [
                    {
                        "file": "vfw.env",
                        "type": "HEAT_ENV"
                    }
                ]
            },
            {
                "file": "vfw_cloudtech_k8s_charts.tgz",
                "type": "CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACTS"
            },
            {
                "file": "vpkg.yaml",
                "type": "HEAT",
                "isBase": "false",
                "data": [
                    {
                        "file": "vpkg.env",
                        "type": "HEAT_ENV"
                    }
                ]
            },
            {
                "file": "vpkg_cloudtech_k8s_charts.tgz",
                "type": "CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACTS"
            },
            {
                "file": "vsn.yaml",
                "type": "HEAT",
                "isBase": "false",
                "data": [
                    {
                        "file": "vsn.env",
                        "type": "HEAT_ENV"
                    }
                ]
            },
            {
                "file": "vsn_cloudtech_k8s_charts.tgz",
                "type": "CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACTS"
            }
        ]
    }

Multicloud/k8s
..............

K8s plugin was changed to support new way to identify k8s application and related multicloud/k8s profile.

Changes done:

- SDC distribution broker (link)
- K8S plugin definition artifact changed to use VF Module Model Identifiers

::

    /api/multicloud-k8s/v1/v1/rb/definition/{VF Module Model Invariant ID}/{VF Module Model Version ID}/content

- Profile creation API identifications changed same way

::

    curl -i -d @create_rbprofile.json -X POST http://${K8S_NODE_IP}:30280/api/multicloud-k8s/v1/v1/rb/definition/{VF Module Model Invariant ID}/{VF Module Model Version ID}/profile
    {    "rb-name": “{VF Module Model Invariant ID}",
         "rb-version": "{VF Module Model Version ID}",
         "profile-name": "p1",
         "release-name": "r1",
         "namespace": "testns1",
         "kubernetes-version": "1.13.5"
    }

- Upload Profile content API

::

    curl -i --data-binary @profile.tar.gz -X POST http://${K8S_NODE_IP}:30280/api/multicloud-k8s/v1/v1/rb/definition/{VF Module Model Invariant ID}/{VF Module Model Version ID}/profile/p1/content

- Default override support was added to plugin (link)

**TODO: Some picture here**

CDS Model (CBA)
...............

Creating CDS model was the core of the use case work and also the most difficult and time consuming part. There are many reasons for this e.g.

- CDS documentation (even being new component) is inadequate or non-existent for service modeler user. One would need to be CDS developer to be able to do something with it.
- CDS documentation what exists is non-versioned (in ONAP wiki when should be in git) so it's mostly impossible to know what features are for what release.
- Our little experience of CDS (not CDS developers)

At first the target was to keep CDS model as close as possible to `vFW_CNF_CDS Model`_ use case model and only add smallest possible changes to enable also k8s usage. That is still the target but in practice model deviated from the original one already and time pressure pushed us to not care about sync. Basically the end result could be possible much streamlined if wanted to be smallest possible to working only for K8S based network functions.

vf-module

Data Dictionary

Instantiation Overview
......................

The figure below shows all the interactions that take place during vFW CNF instantiation. It's not describing flow of actions (ordered steps) but rather component dependencies.

.. figure:: files/vFW_CNF_CDS/Instantiation_topology.png
   :align: center

   vFW CNF CDS Use Case Runtime interactions.

PART 1 - ONAP Installation
--------------------------
1-1 Deployment components
~~~~~~~~~~~~~~~~~~~~~~~~~

In order to run the vFW_CNF_CDS use case, we need ONAP Frankfurt Release (or later) and at least following components:

=======================================================   ===========
ONAP Component name                                       Describtion
-------------------------------------------------------   -----------
AAI                                                       Required for Inventory Cloud Owner, Customer, Owning Entity, Service, Generic VNF, VF Module
SDC                                                       VSP, VF and Service Modeling of the CNF
DMAAP                                                     Distribution of the CSAR including CBA to all ONAP components
SO                                                        Requires for Macro Orchestration using the generic building blocks
CDS                                                       Resolution of cloud parameters including Helm override parameters for the CNF. Creation of the multicloud/k8s profile for CNF instantion.
SDNC (needs to include netbox and Naming Generation mS)   Provides GENERIC-RESOURCE-API for cloud Instantiation orchestration via CDS.
Policy                                                    Used to Store Naming Policy
AAF                                                       Used for Authentication and Authorization of requests
VID                                                       Robot init fills initial data also to VID
Portal                                                    Optional, but can be used to access ONAP components.
Robot                                                     Used for running automated tasks, like provisioning cloud customer, cloud region, service subscription, etc ..
Shared Cassandra DB                                       Used as a shared storage for ONAP components that rely on Cassandra DB, like AAI
Shared Maria DB                                           Used as a shared storage for ONAP components that rely on Maria DB, like SDNC, and SO
=======================================================   ===========

1-2 Deployment
~~~~~~~~~~~~~~

In order to deploy such an instance, follow the `ONAP Deployment Guide`_

As we can see from the guide, we can use an override file that helps us customize our ONAP deployment, without modifying the OOM Folder, so you can download this override file here, that includes the necessary components mentioned above.

Override files has been divided to 2 parts **onap-selected.yaml** where enabled: true is set for each component needed in demo (by default all components are disabled) and **override.yaml** where components are configured.

onap-selected.yaml
::

  aai:
    enabled: true
  aaf:
    enabled: true
  cassandra:
    enabled: true
  cds:
    enabled: true
  consul:
    enabled: true
  contrib:
    enabled: true
  dmaap:
    enabled: true
  log:
    enabled: true
  mariadb-galera:
    enabled: true
  msb:
    enabled: true
  multicloud:
    enabled: true
  policy:
    enabled: true
  portal:
    enabled: true
  robot:
    enabled: true
  sdc:
    enabled: true
  sdnc:
    enabled: true
  so:
    enabled: true
  vid:
    enabled: true


override.yaml

::

  robot:
    appcPassword: demo123456!
    appcUsername: appc@appc.onap.org
      config:
        openStackEncryptedPasswordHere: f7920677e15e2678b0f33736189e8965
    demoArtifactsRepoUrl: https://nexus.onap.org/content/repositories/releases
    demoArtifactsVersion: 1.4.0
    openStackKeyStoneUrl: http://106.120.119.17:5000
    openStackOamNetworkCidrPrefix: '10.1'
    openStackPrivateNetCidr: 10.1.0.0/16
    openStackPrivateNetId: 3c7aa2bd-ba14-40ce-8070-6a0d6a617175
    openStackPrivateSubnetId: 2bcb9938-9c94-4049-b580-550a44dc63b3
    openStackPublicNetId: 3d113a6f-4ed2-43a6-b482-e823b8c65776
    openStackPublicNetworkName: Demo_Network
    openStackSecurityGroup: onap_sg
    openStackTenantId: b1ce7742d956463999923ceaed71786e
    openStackUserName: onap-tieto
    scriptVersion: 1.4.0
    ubuntu14Image: trusty
    vnfPrivateKey: /var/opt/ONAP/onap-dev.pem
    vnfPubKey: ssh-rsa
  AAAAB3NzaC1yc2EAAAADAQABAAABAQDPwF2bYm2QuqZpjuAcZDJTcFdUkKv4Hbd/3qqbxf6g5ZgfQarCi+mYnKe9G9Px3CgFLPdgkBBnMSYaAzMjdIYOEdPKFTMQ9lIF0+i5KsrXvszWraGKwHjAflECfpTAWkPq2UJUvwkV/g7NS5lJN3fKa9LaqlXdtdQyeSBZAUJ6QeCE5vFUplk3X6QFbMXOHbZh2ziqu8mMtP+cWjHNBB47zHQ3RmNl81Rjv+QemD5zpdbK/h6AahDncOY3cfN88/HPWrENiSSxLC020sgZNYgERqfw+1YhHrclhf3jrSwCpZikjl7rqKroua2LBI/yeWEta3amTVvUnR2Y7gM8kHyh
           Generated-by-Nova
  so:
    config:
      openStackEncryptedPasswordHere: 31ECA9F2BA98EF34C9EC3412D071E31185F6D9522808867894FF566E6118983AD5E6F794B8034558
      openStackKeyStoneUrl: http://106.120.119.17:5000
      openStackRegion: RegionOne
      openStackServiceTenantName: services
      openStackUserName: onap-tieto
  so-catalog-db-adapter:
    config:
      openStackEncryptedPasswordHere: 31ECA9F2BA98EF34C9EC3412D071E31185F6D9522808867894FF566E6118983AD5E6F794B8034558
      openStackKeyStoneUrl: http://106.120.119.17:5000/v2.0
      openStackUserName: onap-tieto
  policy:
    config:
      preloadPolicies: true
  sdnc:
    image: onap/sdnc-image:1.7.6
      ueb-listener:
        image: onap/sdnc-ueb-listener-image:1.7.6
      dmaap-listener:
        image: onap/sdnc-dmaap-listener-image:1.7.6
      sdnc-ansible-server:
        image: onap/sdnc-ansible-server-image:1.7.6
  cds:
    #debugEnabled: true
    cds-blueprints-processor:
      image: onap/ccsdk-blueprintsprocessor:0.7.0-STAGING-latest
    cds-command-executor:
      image: onap/ccsdk-commandexecutor:0.7.0-STAGING-latest
    cds-sdc-listener:
      image: onap/ccsdk-sdclistener:0.6.5-STAGING-latest
    cds-ui:
      image: onap/ccsdk-cds-ui-server:0.7.0-STAGING-latest

1-3 Post Deployment
~~~~~~~~~~~~~~~~~~~

After completing the first part above, we should have a functional ONAP deployment for the Frankfurt Release.

We will need to apply a few modifications to the deployed ONAP Frankfurt instance in order to run the use case.

Postman collection setup
........................

In this demo we have on purpose created all manual ONAP preparation steps (which in real life are automated) by using Postman so it will be clear what exactly is needed. Some of the steps like AAI population is automated by Robot scripts in other ONAP demos (**./demo-k8s.sh onap init**) and Robot script could be used for many parts also in this demo. Later when this demo is fully automated we probably update also Robot scripts to support this demo.

Postman collection is used also to trigger instantion using SO APIs.

Following steps are needed to setup postman:

- Import this postman collection into postman `vFW_CNF_CDS.postman_collection.json <files/vFW_CNF_CDS/vFW_CNF_CDS.postman_collection.json>`__
- Import this postman environment into postman `vFW_CNF_CDS.postman_environment.json <files/vFW_CNF_CDS/vFW_CNF_CDS.postman_environment.json>`__
- For use case debugging purposes to get Kubernetes cluster external access to SO CatalogDB (GET operations only), modify SO CatalogDB service to NodePort instead of ClusterIP. You may also create separate own NodePort if you wish, but here we have just edited directly the service with kubectl. Note that the port number 30120 is used in postman collection.

::

    kubectl edit svc so-catalog-db-adapter
         - .spec.type: ClusterIP
         + .spec.type: NodePort
         + .spec.ports[0].nodePort: 30120

AAI
...

Some basic entries are needed in ONAP AAI.

- customer
- owning-entity
- platform
- project
- line-of-business
- complex
- cloud-region
- complex-cloud-region relationship
- service
- service-subscription
- tenant
- availability-zone

Create all these entries into AAI in this order. Postman collection provided in this demo can be used for creating each entry.

SO Cloud region configuration
.............................

SO database needs to (manually) modified for SO to know that this particular cloud region is to be handled by multicloud. Values we insert needs to obviously match to the ones we populated into AAI.

The related code part in SO is here: https://gerrit.onap.org/r/gitweb?p=so.git;a=blob;f=adapters/mso-openstack-adapters/src/main/java/org/onap/so/adapters/vnf/MsoVnfPluginAdapterImpl.java;hb=refs/heads/elalto#l1149
It's possible improvement place in SO to rather get this information directly from AAI.

::

    kubectl exec -n onap onap-mariadb-galera-mariadb-galera-0 -it -- mysql -uroot -psecretpassword -D catalogdb
        select * from cloud_sites;
        insert into cloud_sites(ID, REGION_ID, IDENTITY_SERVICE_ID, CLOUD_VERSION, CLLI, ORCHESTRATOR) values("k8sregionfour", "k8sregionfour", "DEFAULT_KEYSTONE", "2.5", "clli2", "multicloud");
        select * from cloud_sites;
        exit

SO BPMN endpoint fix for VNF adapter requests (v1 -> v2)
........................................................

SO Openstack adapter needs to be updated to use newer version. Here is also possible improvement area in SO.

::

    kubectl -n onap edit configmap onap-so-so-bpmn-infra-app-configmap
      - .data."override.yaml".mso.adapters.vnf.rest.endpoint: http://so-openstack-adapter.onap:8087/services/rest/v1/vnfs
      + .data."override.yaml".mso.adapters.vnf.rest.endpoint: http://so-openstack-adapter.onap:8087/services/rest/v2/vnfs

Naming Policy
.............

Naming policy is needed to generate unique names for all instance time resources that are wanted to be modeled in the way naming policy is used. Those are normally VNF, VNFC and VF-module names, network names etc. Naming is general ONAP feature and not limited to this use case.

The override.yaml file above has an option **"preload=true"**, that will tell the POLICY component to run the push_policies.sh script as the POLICY PAP pod starts up, which will in turn create the Naming Policy and push it.

To check that the naming policy is created and pushed OK, we can run the commands below.

::

  # goto inside of a POD e.g. pap here
  kubectl -n onap exec -it $(kubectl -n onap  get pods -l app=pap --no-headers | cut -d" " -f1) bash

  bash-4.4$ curl -k --silent -X POST \
  --header 'Content-Type: application/json' \
  --header 'ClientAuth: cHl0aG9uOnRlc3Q=' \
  --header 'Authoment: TEST' \
  -d '{ "policyName": "SDNC_Policy.Config_MS_ONAP_VNF_NAMING_TIMESTAMP.1.xml"}' \
  'https://pdp:8081/pdp/api/getConfig'

  [{"policyConfigMessage":"Config Retrieved! ","policyConfigStatus":"CONFIG_RETRIEVED",
  "type":"JSON",
  "config":"{\"service\":\"SDNC-GenerateName\",\"version\":\"CSIT\",\"content\":{\"policy-instance-name\":\"ONAP_VNF_NAMING_TIMESTAMP\",\"naming-models\":[{\"naming-properties\":[{\"property-name\":\"AIC_CLOUD_REGION\"},{\"property-name\":\"CONSTANT\",\"property-value\":\"ONAP-NF\"},{\"property-name\":\"TIMESTAMP\"},{\"property-value\":\"_\",\"property-name\":\"DELIMITER\"}],\"naming-type\":\"VNF\",\"naming-recipe\":\"AIC_CLOUD_REGION|DELIMITER|CONSTANT|DELIMITER|TIMESTAMP\"},{\"naming-properties\":[{\"property-name\":\"VNF_NAME\"},{\"property-name\":\"SEQUENCE\",\"increment-sequence\":{\"max\":\"zzz\",\"scope\":\"ENTIRETY\",\"start-value\":\"001\",\"length\":\"3\",\"increment\":\"1\",\"sequence-type\":\"alpha-numeric\"}},{\"property-name\":\"NFC_NAMING_CODE\"},{\"property-value\":\"_\",\"property-name\":\"DELIMITER\"}],\"naming-type\":\"VNFC\",\"naming-recipe\":\"VNF_NAME|DELIMITER|NFC_NAMING_CODE|DELIMITER|SEQUENCE\"},{\"naming-properties\":[{\"property-name\":\"VNF_NAME\"},{\"property-value\":\"_\",\"property-name\":\"DELIMITER\"},{\"property-name\":\"VF_MODULE_LABEL\"},{\"property-name\":\"VF_MODULE_TYPE\"},{\"property-name\":\"SEQUENCE\",\"increment-sequence\":{\"max\":\"zzz\",\"scope\":\"PRECEEDING\",\"start-value\":\"01\",\"length\":\"3\",\"increment\":\"1\",\"sequence-type\":\"alpha-numeric\"}}],\"naming-type\":\"VF-MODULE\",\"naming-recipe\":\"VNF_NAME|DELIMITER|VF_MODULE_LABEL|DELIMITER|VF_MODULE_TYPE|DELIMITER|SEQUENCE\"}]}}",
  "policyName":"SDNC_Policy.Config_MS_ONAP_VNF_NAMING_TIMESTAMP.1.xml",
  "policyType":"MicroService",
  "policyVersion":"1",
  "matchingConditions":{"ECOMPName":"SDNC","ONAPName":"SDNC","service":"SDNC-GenerateName"},
  "responseAttributes":{},
  "property":null}]

In case the policy is missing, we can manually create and push the SDNC Naming policy.

::

  # goto inside of a POD e.g. pap here
  kubectl -n onap exec -it $(kubectl -n onap  get pods -l app=pap --no-headers | cut -d" " -f1) bash

  #########################################Create SDNC Naming Policies##########################################
  echo "Create Generic SDNC Naming Policy for VNF"
  sleep 2
  echo "Create SDNC vFW Naming Policy"
  curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
      "configBody": "{ \"service\": \"SDNC-GenerateName\", \"version\": \"CSIT\", \"content\": { \"policy-instance-name\": \"ONAP_VNF_NAMING_TIMESTAMP\", \"naming-models\": [ { \"naming-properties\": [ { \"property-name\": \"AIC_CLOUD_REGION\" }, { \"property-name\": \"CONSTANT\",\"property-value\": \"ONAP-NF\"}, { \"property-name\": \"TIMESTAMP\" }, { \"property-value\": \"_\", \"property-name\": \"DELIMITER\" } ], \"naming-type\": \"VNF\", \"naming-recipe\": \"AIC_CLOUD_REGION|DELIMITER|CONSTANT|DELIMITER|TIMESTAMP\" }, { \"naming-properties\": [ { \"property-name\": \"VNF_NAME\" }, { \"property-name\": \"SEQUENCE\", \"increment-sequence\": { \"max\": \"zzz\", \"scope\": \"ENTIRETY\", \"start-value\": \"001\", \"length\": \"3\", \"increment\": \"1\", \"sequence-type\": \"alpha-numeric\" } }, { \"property-name\": \"NFC_NAMING_CODE\" }, { \"property-value\": \"_\", \"property-name\": \"DELIMITER\" } ], \"naming-type\": \"VNFC\", \"naming-recipe\": \"VNF_NAME|DELIMITER|NFC_NAMING_CODE|DELIMITER|SEQUENCE\" }, { \"naming-properties\": [ { \"property-name\": \"VNF_NAME\" }, { \"property-value\": \"_\", \"property-name\": \"DELIMITER\" }, { \"property-name\": \"VF_MODULE_LABEL\" }, { \"property-name\": \"VF_MODULE_TYPE\" }, { \"property-name\": \"SEQUENCE\", \"increment-sequence\": { \"max\": \"zzz\", \"scope\": \"PRECEEDING\", \"start-value\": \"01\", \"length\": \"3\", \"increment\": \"1\", \"sequence-type\": \"alpha-numeric\" } } ], \"naming-type\": \"VF-MODULE\", \"naming-recipe\": \"VNF_NAME|DELIMITER|VF_MODULE_LABEL|DELIMITER|VF_MODULE_TYPE|DELIMITER|SEQUENCE\" } ] } }",
      "policyName": "SDNC_Policy.ONAP_VNF_NAMING_TIMESTAMP",
      "policyConfigType": "MicroService",
      "onapName": "SDNC",
      "riskLevel": "4",
      "riskType": "test",
      "guard": "false",
      "priority": "4",
      "description": "ONAP_VNF_NAMING_TIMESTAMP"
  }' 'https://pdp:8081/pdp/api/createPolicy'
  #########################################Pushing SDNC Naming Policies##########################################
  echo "Pushing SDNC Naming Policies"
  sleep 2
  echo "pushPolicy : PUT : SDNC_Policy.ONAP_VNF_NAMING_TIMESTAMP"
  curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
    "pdpGroup": "default",
    "policyName": "SDNC_Policy.ONAP_VNF_NAMING_TIMESTAMP",
    "policyType": "MicroService"
  }' 'https://pdp:8081/pdp/api/pushPolicy'


Network Naming mS
+++++++++++++++++

There's a strange feature or bug in naming service still at ONAP Frankfurt and floowing hack needs to be done to make it work.

::

  # Go into naming service database pod
  kubectl -n onap exec -it $(kubectl -n onap  get pods --no-headers | grep sdnc-nengdb-0 | cut -d" " -f1) bash

  # Delete entries from EXTERNAL_INTERFACE table
  mysql -unenguser -pnenguser123 nengdb -e 'delete from EXTERNAL_INTERFACE;'


PART 2 - Installation of managed Kubernetes cluster
---------------------------------------------------

In this demo the target cloud region is a Kubernetes cluster of your choice basically just like with Openstack. ONAP platform is a bit too much hard wired to Openstack and it's visible in many demos and unfortunately also in this demo.

Following steps are requiring/dependent on the existense of Openstack and should be streamlined in ONAP:

- **TODO**: list here the points

In this demo we use Kubernetes deployment used by ONAP multicloud/k8s team to test their plugin features see `KUD readthedocs`_. There's also some outdated instructions in ONAP wiki https://wiki.onap.org/display/DW/Kubernetes+Baremetal+deployment+setup+instructions.

KUD deployment is fully automated and also used in ONAP's CI/CD to automatically verify all `Multicloud k8s gerrit`_ commits (see `KUD Jenkins ci/cd verification`_) and that's quite good (and rare) level of automated integration testing in ONAP. KUD deployemnt is used as it's installation is automated and it also includes punch of Kubernetes plugins used to tests various k8s plugin features. In addition to deployement, KUD repository also contains test scripts to automatically test multicloud/k8s plugin features. Those scripts are run in CI/CD.

See `KUD subproject in github`_ for a list of additional plugins this Kubernetes deployment has. In this demo the tested CNF is dependent on following plugins:

- ovn4nfv
- Multus
- Virtlet

Follow instructions in `KUD readthedocs`_ and install target Kubernetes cluster in your favorite machine(s), simplest being just one machine. Your cluster nodes(s) needs to be accessible from ONAP Kuberenetes nodes.

PART 3 - Execution of the Use Case
----------------------------------

This part contains all the steps to run the use case by using ONAP GUIs and Postman.

Following picture describes the overall sequential flow of the use case.

.. figure:: files/vFW_CNF_CDS/vFW_CNF_CDS_Flow.png
   :align: center

   vFW CNF CDS Use Case sequence flow.

3-1 Onboarding and Service Creation with SDC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3-2 CDS Model Distribution
~~~~~~~~~~~~~~~~~~~~~~~~~~

3-3 CNF Instantiation
~~~~~~~~~~~~~~~~~~~~~

PART 4 - CDS Model Testing
--------------------------

PART 5 - Summary and Future improvements needed
-----------------------------------------------

- Distribution of Helm package directly from CSAR package
- Automate manual initialization steps in to Robot init.
- Sync CDS model with `vFW_CNF_CDS Model`_ use case i.e. try to keep only single model regardless of xNF being Openstack or Kubernetes based.
- Include Closed Loop part of the vFW demo.
- TOSCA based service and xNF models instead of Heat.

PART 6 - Known Issues and Resolutions
-------------------------------------


.. _ONAP Deployment Guide: https://docs.onap.org/en/frankfurt/submodules/oom.git/docs/oom_quickstart_guide.html#quick-start-label
.. _vFW_CNF_CDS Model: https://git.onap.org/demo/tree/heat/vFW_CNF_CDS?h=frankfurt
.. _vFW CDS Dublin: https://wiki.onap.org/display/DW/vFW+CDS+Dublin
.. _vFW CBA Model: https://git.onap.org/ccsdk/cds/tree/components/model-catalog/blueprint-model/service-blueprint/vFW?h=frankfurt
.. _vFW_Helm Model: https://git.onap.org/multicloud/k8s/tree/kud/demo/firewall?h=elalto
.. _vFW_NextGen: https://git.onap.org/demo/tree/heat/vFW_NextGen?h=elalto
.. _vFW EDGEX K8S: https://onap.readthedocs.io/en/frankfurt/submodules/integration.git/docs/docs_vfw_edgex_k8s.html
.. _KUD readthedocs: https://docs.onap.org/en/frankfurt/submodules/multicloud/k8s.git/docs
.. _Multicloud k8s gerrit: https://gerrit.onap.org/r/#/q/status:open+project:+multicloud/k8s
.. _KUD subproject in github: https://github.com/onap/multicloud-k8s/tree/master/kud
.. _KUD Jenkins ci/cd verification: https://jenkins.onap.org/job/multicloud-k8s-master-kud-deployment-verify-shell/
