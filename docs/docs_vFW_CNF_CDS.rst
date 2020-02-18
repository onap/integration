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

Demo git directory has also `Data Dictionary`_ file (CDS model time resource) included.

Another founding idea from the start was to provide complete content in single CSAR available directly from that git repository. Not any revolutionary idea as that's the official package format ONAP supports and all content supposed to be in that same package for single service regardless of the models and closed loops and configurations etc.

Following table describes all source models to which this demo is based on.

===============  =================       ===========
Model            Git reference           Description
---------------  -----------------       -----------
Heat             `vFW_NextGen`_          Heat templates used in original vFW demo but splitted into multiple vf-modules
Helm             `vFW_Helm Model`_       Helm templates used in `vFW EDGEX K8S`_ demo
CDS model        `vFW CBA Model`_        CDS CBA model used in `vFW CDS Dublin`_ demo
===============  =================       ===========

All changes to related ONAP components during this use case can be found from this `Jira Epic`_ ticket.

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

- SDC distribution broker

    **TODO: content here**

- K8S plugin definition artifact changed to use VF Module Model Identifiers

    *VF Module Model Invariant ID* and *VF Module Model Version ID* is now used to identify artifact in Multicloud/k8s plugin integrating it better into ONAP.

    ::

        /api/multicloud-k8s/v1/v1/rb/definition/{VF Module Model Invariant ID}/{VF Module Model Version ID}/content

- Profile creation API identifications changed same way

    Example curl command how it's visible in API.

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

    And same with corresponding content upload path.

    ::

        curl -i --data-binary @profile.tar.gz -X POST http://${K8S_NODE_IP}:30280/api/multicloud-k8s/v1/v1/rb/definition/{VF Module Model Invariant ID}/{VF Module Model Version ID}/profile/p1/content

- Default override support was added to plugin

    **TODO: Some content here, maybe also picture**

CDS Model (CBA)
...............

Creating CDS model was the core of the use case work and also the most difficult and time consuming part. There are many reasons for this e.g.

- CDS documentation (even being new component) is inadequate or non-existent for service modeler user. One would need to be CDS developer to be able to do something with it.
- CDS documentation what exists is non-versioned (in ONAP wiki when should be in git) so it's mostly impossible to know what features are for what release.
- Our little experience of CDS (not CDS developers)

At first the target was to keep CDS model as close as possible to `vFW_CNF_CDS Model`_ use case model and only add smallest possible changes to enable also k8s usage. That is still the target but in practice model deviated from the original one already and time pressure pushed us to not care about sync. Basically the end result could be possible much streamlined if wanted to be smallest possible to working only for K8S based network functions.

As K8S application was splitted into multiple Helm packages to match vf-modules, CBA modeling follows the same and for each vf-module there's own template in CBA package.

::

    "artifacts" : {
      "base_template-template" : {
        "type" : "artifact-template-velocity",
        "file" : "Templates/base_template-template.vtl"
      },
      "base_template-mapping" : {
        "type" : "artifact-mapping-resource",
        "file" : "Templates/base_template-mapping.json"
      },
      "vpkg-template" : {
        "type" : "artifact-template-velocity",
        "file" : "Templates/vpkg-template.vtl"
      },
      "vpkg-mapping" : {
        "type" : "artifact-mapping-resource",
        "file" : "Templates/vpkg-mapping.json"
      },
      "vfw-template" : {
        "type" : "artifact-template-velocity",
        "file" : "Templates/vfw-template.vtl"
      },
      "vfw-mapping" : {
        "type" : "artifact-mapping-resource",
        "file" : "Templates/vfw-mapping.json"
      },
      "vnf-template" : {
        "type" : "artifact-template-velocity",
        "file" : "Templates/vnf-template.vtl"
      },
      "vnf-mapping" : {
        "type" : "artifact-mapping-resource",
        "file" : "Templates/vnf-mapping.json"
      },
      "vsn-template" : {
        "type" : "artifact-template-velocity",
        "file" : "Templates/vsn-template.vtl"
      },
      "vsn-mapping" : {
        "type" : "artifact-mapping-resource",
        "file" : "Templates/vsn-mapping.json"
      }
    }

Only **resource-assignment** workflow of the CBA model is utilized in this demo. If final CBA model contains also **config-deploy** workflow it's there just to keep parity with original vFW CBA (for VMs). Same applies for the related template *Templates/nf-params-template.vtl* and it's mapping file.

The interesting part on CBA model is the **profile-upload** sub step of imperative workflow where Kotlin script is used to upload K8S profile into multicloud/k8s API.

::

    "profile-upload" : {
      "type" : "component-script-executor",
      "interfaces" : {
        "ComponentScriptExecutor" : {
          "operations" : {
            "process" : {
              "inputs" : {
                "script-type" : "kotlin",
                "script-class-reference" : "org.onap.ccsdk.cds.blueprintsprocessor.services.execution.scripts.K8sProfileUpload",
                "dynamic-properties" : "*profile-upload-properties"
              }
            }
          }
        }
      }
    }

Kotlin script expects that K8S profile package named like "k8s-rb-profile-name".tar.gz is present in CBA "Templates/k8s-profiles directory" where "k8s-rb-profile-name" is one of the CDS resolved parameters (user provides as input parameter).

**TODO: something about the content and structure of profile package**

As `Data Dictionary`_ is also included into demo git directory, re-modeling and making changes into model utilizing CDS model time / runtime is easier as used DD is also known.

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
  contrib:
    enabled: true
  dmaap:
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

override.yaml

::

  robot:
    scriptVersion: 1.4.0
    ubuntu14Image: trusty
  so:
    config:
      openStackEncryptedPasswordHere: <your encrypted password>
      openStackKeyStoneUrl: http://<openstack address>:5000
      openStackRegion: RegionOne
      openStackServiceTenantName: services
      openStackUserName: <your openstack username>
  so-catalog-db-adapter:
    config:
      openStackEncryptedPasswordHere: <your encrypted password>
      openStackKeyStoneUrl: http://<openstack address>:5000/v2.0
      openStackUserName: <your openstack username>
  policy:
    config:
      preloadPolicies: true

Then deploy ONAP with Helm with your 2 override files.

::

    helm deploy onap local/onap --namespace onap -f ~/onap-selected.yaml -f ~/override.yaml

In case redeployment needed `Helm Healer`_ could be a faster and convenient way to redeploy.

::

    helm-healer.sh -n onap -f ~/onap-selected.yaml -f ~/override.yaml -s /dockerdata-nfs --delete-all

Or redeploy (clean re-deploy also data removed) just wanted components (Helm releases), cds in this example.

::

    helm-healer.sh -f ~/onap-selected.yaml -f ~/override.yaml -s /dockerdata-nfs/ -n onap -c onap-cds

There are many instructions in ONAP wiki how to follow your deployment status and does it succeeded or not, mostly using Robot Health checks. One way we used is to skip the outermost Robot wrapper and use directly ete-k8s.sh to able to select checked components easily. Script is found from OOM git repository *oom/kubernetes/robot/ete-k8s.sh*.

::

    for comp in {aaf,aai,dmaap,msb,multicloud,policy,portal,sdc,sdnc,so}; do
        if ! ./ete-k8s.sh onap health-$comp; then
            failed=$failed,$comp
        fi
    done
    if [ -n "$failed" ]; then
        echo "These components failed: $failed"
        false
    else
        echo "Healthcheck successful"
    fi

And check status of pods, deployments, jobs etc.

::

    kubectl get pods | grep -vie 'completed' -e 'running'
    kubectl get deploy,sts,jobs


1-3 Post Deployment
~~~~~~~~~~~~~~~~~~~

After completing the first part above, we should have a functional ONAP deployment for the Frankfurt Release.

We will need to apply a few modifications to the deployed ONAP Frankfurt instance in order to run the use case.

Postman collection setup
........................

In this demo we have on purpose created all manual ONAP preparation steps (which in real life are automated) by using Postman so it will be clear what exactly is needed. Some of the steps like AAI population is automated by Robot scripts in other ONAP demos (**./demo-k8s.sh onap init**) and Robot script could be used for many parts also in this demo. Later when this demo is fully automated we probably update also Robot scripts to support this demo.

Postman collection is used also to trigger instantion using SO APIs.

Following steps are needed to setup postman:

- Import this postman collection into postman `vFW_CNF_CDS.postman_collection.json`_
- Import this postman environment into postman `vFW_CNF_CDS.postman_environment.json`_
- For use case debugging purposes to get Kubernetes cluster external access to SO CatalogDB (GET operations only), modify SO CatalogDB service to NodePort instead of ClusterIP. You may also create separate own NodePort if you wish, but here we have just edited directly the service with kubectl. Note that the port number 30120 is used in postman collection.

::

    kubectl edit svc so-catalog-db-adapter
         - .spec.type: ClusterIP
         + .spec.type: NodePort
         + .spec.ports[0].nodePort: 30120

**Postman variables:**

Most of the postman variables are automated by postman scripts and environment file provided, but there are few mandatory variables to fill by user.

===================  ===================
Variable             Description
-------------------  -------------------
sdnc_port            port of sdnc service for accessing MDSAL
cds-service-model    name of service as defined in SDC
cds-service-version  version of distributed service (typically: 1.0)
cba_name             name of cba to use
cba_version          version of cba to use
cba_vnf_target       name of RA prefix to use for VNF level RA
cds-instance-name    name of instantiated service (if ending with -{num}, will be autoincremented for each instantiation request)
===================  ===================

You can get the sdnc_port value with

::

    kubectl get svc sdnc -o json | jq '.spec.ports[]|select(.port==8282).nodePort'


**TODO: change variable names something else than cds-xxx**


AAI
...

Some basic entries are needed in ONAP AAI. These entries are needed ones per onap installation and do not need to be repeated when running multiple demos based on same definitions.

Create all these entries into AAI in this order. Postman collection provided in this demo can be used for creating each entry.

**Postman -> Robot Init Stuff**

- Create Customer
- Create Owning-entity
- Create Platform
- Create Project
- Create Line Of Business

Corresponding GET operations in postman can be used to verify entries created. Postman collection also includes some code that tests/verifies some basic issues e.g. gives error if entry already exists.

SO Cloud region configuration
.............................

SO database needs to (manually) modified for SO to know that this particular cloud region is to be handled by multicloud. Values we insert needs to obviously match to the ones we populated into AAI.

The related code part in SO is here: `SO Cloud Region Selection`_
It's possible improvement place in SO to rather get this information directly from AAI.

::

    kubectl exec -n onap onap-mariadb-galera-mariadb-galera-0 -it -- mysql -uroot -psecretpassword -D catalogdb
        select * from cloud_sites;
        insert into cloud_sites(ID, REGION_ID, IDENTITY_SERVICE_ID, CLOUD_VERSION, CLLI, ORCHESTRATOR) values("k8sregionfour", "k8sregionfour", "DEFAULT_KEYSTONE", "2.5", "clli2", "multicloud");
        select * from cloud_sites;
        exit

SO BPMN endpoint fix for VNF adapter requests (v1 -> v2)
........................................................

SO Openstack adapter needs to be updated to use newer version. Here is also possible improvement area in SO. Openstack adapter is confusing in context of this use case as VIM is not Openstack but Kubernetes cloud region. In this use case we did not integrated Openstack at all into ONAP.

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

KUD deployment is fully automated and also used in ONAP's CI/CD to automatically verify all `Multicloud k8s gerrit`_ commits (see `KUD Jenkins ci/cd verification`_) and that's quite good (and rare) level of automated integration testing in ONAP. KUD deployemnt is used as it's installation is automated and it also includes bunch of Kubernetes plugins used to tests various k8s plugin features. In addition to deployement, KUD repository also contains test scripts to automatically test multicloud/k8s plugin features. Those scripts are run in CI/CD.

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

3-1 Onboarding
~~~~~~~~~~~~~~

Creating CSAR
.............

Whole content of this use case is stored into single git repository and ONAP user content package CSAR package can be created with provided Makefile.

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

Import this package into SDC and follow onboarding steps.

Service Creation with SDC
.........................

Create VSP, VLM, VF, ..., Service in SDC
    - Remember during VSP onboard to choose "Network Package" Onboarding procedure

Attaching CDS Model
...................

On VF level, add CBA separately as it's not onboarded by default from CSAR correctly

Service -> Properties Assignment -> Choose VF (at right box):
    - skip_post_instantiation_configuration - True
    - sdnc_artifact_name - vnf
    - sdnc_model_name - vFW_CNF_CDS
    - sdnc_model_version - 1.0.0

Distributing
............

Distribute service.

Verify distribution for:

- SDC:

    SDC Catalog database should have our service now defined.

    **Postman -> SDC/SO -> SDC Catalog Service**

    ::

        {
            "uuid": "40f4cca8-1025-4f2e-8435-dda898f0caab",
            "invariantUUID": "b0ecfa3b-4394-4727-be20-c2c718002093",
            "name": "TestvFWService",
            "version": "3.0",
            "toscaModelURL": "/sdc/v1/catalog/services/40f4cca8-1025-4f2e-8435-dda898f0caab/toscaModel",
            "category": "Mobility",
            "lifecycleState": "CERTIFIED",
            "lastUpdaterUserId": "jm0007",
            "distributionStatus": "DISTRIBUTED"
        }

    Listing should contain entry with our service name **TestvFWService** *TODO: Let's use service name different from other demos*

- SO:

    SO Catalog database should have our service NFs defined now.

    *Pre-requirement for this Postman query is the above SDC query (Postman -> SDC/SO -> SDC Catalog Service) as Postman script is populating "service-name" variable used in this query.*

    **Postman -> SDC/SO -> SO Catalog DB Service xNFs**

    ::

        {
           "serviceVnfs":[
              {
                 "modelInfo":{
                    "modelName":"FixedVFW",
                    "modelUuid":"a6c43cc8-677d-447d-afc2-795212182dc0",
                    "modelInvariantUuid":"074555e3-21b9-47ba-9ad9-78028029a36d",
                    "modelVersion":"1.0",
                    "modelCustomizationUuid":"366c007e-7684-4a0b-a2f4-9815174bec55",
                    "modelInstanceName":"FixedVFW 0"
                 },
                 "toscaNodeType":"org.openecomp.resource.vf.Fixedvfw",
                 "nfFunction":null,
                 "nfType":null,
                 "nfRole":null,
                 "nfNamingCode":null,
                 "multiStageDesign":"false",
                 "vnfcInstGroupOrder":null,
                 "resourceInput":"{\"vf_module_id\":\"vFirewallCL\",\"skip_post_instantiation_configuration\":\"true\",\"vsn_flavor_name\":\"PUT THE VM FLAVOR NAME HERE (m1.medium suggested)\",\"vfw_int_private2_ip_0\":\"192.168.20.100\",\"int_private1_subnet_id\":\"zdfw1fwl01_unprotected_sub\",\"public_net_id\":\"PUT THE PUBLIC NETWORK ID HERE\",\"vnf_name\":\"vFW_NextGen\",\"onap_private_subnet_id\":\"PUT THE ONAP PRIVATE NETWORK NAME HERE\",\"vsn_int_private2_ip_0\":\"192.168.20.250\",\"sec_group\":\"PUT THE ONAP SECURITY GROUP HERE\",\"vfw_name_0\":\"zdfw1fwl01fwl01\",\"nexus_artifact_repo\":\"https://nexus.onap.org\",\"onap_private_net_cidr\":\"10.0.0.0/16\",\"vpg_onap_private_ip_0\":\"10.0.100.2\",\"dcae_collector_ip\":\"10.0.4.1\",\"vsn_image_name\":\"PUT THE VM IMAGE NAME HERE (UBUNTU 1404)\",\"vnf_id\":\"vSink_demo_app\",\"vpg_flavor_name\":\"PUT THE VM FLAVOR NAME HERE (m1.medium suggested)\",\"dcae_collector_port\":\"30235\",\"vfw_int_private2_floating_ip\":\"192.168.10.200\",\"vpg_name_0\":\"zdfw1fwl01pgn01\",\"int_private2_subnet_id\":\"zdfw1fwl01_protected_sub\",\"int_private2_net_cidr\":\"192.168.20.0/24\",\"nf_naming\":\"true\",\"vsn_name_0\":\"zdfw1fwl01snk01\",\"multi_stage_design\":\"false\",\"vpg_image_name\":\"PUT THE VM IMAGE NAME HERE (UBUNTU 1404)\",\"onap_private_net_id\":\"PUT THE ONAP PRIVATE NETWORK NAME HERE\",\"availability_zone_max_count\":\"1\",\"sdnc_artifact_name\":\"vnf\",\"vsn_onap_private_ip_0\":\"10.0.100.3\",\"vfw_flavor_name\":\"PUT THE VM FLAVOR NAME HERE (m1.medium suggested)\",\"demo_artifacts_version\":\"1.6.0-SNAPSHOT\",\"pub_key\":\"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQXYJYYi3/OUZXUiCYWdtc7K0m5C0dJKVxPG0eI8EWZrEHYdfYe6WoTSDJCww+1qlBSpA5ac/Ba4Wn9vh+lR1vtUKkyIC/nrYb90ReUd385Glkgzrfh5HdR5y5S2cL/Frh86lAn9r6b3iWTJD8wBwXFyoe1S2nMTOIuG4RPNvfmyCTYVh8XTCCE8HPvh3xv2r4egawG1P4Q4UDwk+hDBXThY2KS8M5/8EMyxHV0ImpLbpYCTBA6KYDIRtqmgS6iKyy8v2D1aSY5mc9J0T5t9S2Gv+VZQNWQDDKNFnxqYaAo1uEoq/i1q63XC5AD3ckXb2VT6dp23BQMdDfbHyUWfJN\",\"key_name\":\"vfw_key\",\"vfw_int_private1_ip_0\":\"192.168.10.100\",\"sdnc_model_version\":\"1.0.0\",\"int_private1_net_cidr\":\"192.168.10.0/24\",\"install_script_version\":\"1.6.0-SNAPSHOT\",\"vfw_image_name\":\"PUT THE VM IMAGE NAME HERE (UBUNTU 1404)\",\"vfw_onap_private_ip_0\":\"10.0.100.1\",\"vpg_int_private1_ip_0\":\"192.168.10.200\",\"int_private2_net_id\":\"zdfw1fwl01_protected\",\"cloud_env\":\"PUT openstack OR rackspace HERE\",\"sdnc_model_name\":\"vFW_CNF_CDS\",\"int_private1_net_id\":\"zdfw1fwl01_unprotected\"}",
                 "vfModules":[
                    {
                       "modelInfo":{
                          "modelName":"Fixedvfw..base_template..module-0",
                          "modelUuid":"8bb9fa50-3e82-4664-bd1c-a29267be726a",
                          "modelInvariantUuid":"750b39d0-7f99-4b7f-9a22-c15c7348221d",
                          "modelVersion":"1",
                          "modelCustomizationUuid":"603eadfe-50d6-413a-853c-46f5a8e2ddc7"
                       },
                       "isBase":true,
                       "vfModuleLabel":"base_template",
                       "initialCount":1,
                       "hasVolumeGroup":false
                    },
                    {
                       "modelInfo":{
                          "modelName":"Fixedvfw..vsn..module-1",
                          "modelUuid":"027696a5-a605-44ea-9362-391a6b217de0",
                          "modelInvariantUuid":"2e3b182d-7ee3-4a8d-9c2b-056188b6eb53",
                          "modelVersion":"1",
                          "modelCustomizationUuid":"f75c3628-12e9-4c70-be98-d347045a3f70"
                       },
                       "isBase":false,
                       "vfModuleLabel":"vsn",
                       "initialCount":0,
                       "hasVolumeGroup":false
                    },
                    {
                       "modelInfo":{
                          "modelName":"Fixedvfw..vpkg..module-2",
                          "modelUuid":"64af8ad0-cb81-42a2-a069-7d246d8bff5d",
                          "modelInvariantUuid":"5c9f3097-26ba-41fb-928b-f7ddc31f6f52",
                          "modelVersion":"1",
                          "modelCustomizationUuid":"32ffad03-d38d-46d5-b4a6-a3b0b6112ffc"
                       },
                       "isBase":false,
                       "vfModuleLabel":"vpkg",
                       "initialCount":0,
                       "hasVolumeGroup":false
                    },
                    {
                       "modelInfo":{
                          "modelName":"Fixedvfw..vfw..module-3",
                          "modelUuid":"55d889e4-ff38-4ed0-a159-60392c968042",
                          "modelInvariantUuid":"5c6a06e9-1168-4b01-bd2a-38d544c6d131",
                          "modelVersion":"1",
                          "modelCustomizationUuid":"f9afd9bb-7796-4aff-8f53-681513115742"
                       },
                       "isBase":false,
                       "vfModuleLabel":"vfw",
                       "initialCount":0,
                       "hasVolumeGroup":false
                    }
                 ],
                 "groups":[

                 ]
              }
           ]
        }

- SDNC:

    SDNC should have it's database updated with sdnc_* properties that were set during service modeling

    ::

        kubectl exec -n onap onap-mariadb-galera-mariadb-galera-0 -it -- sh
        mysql -uroot -psecretpassword -D sdnctl
        MariaDB [sdnctl]> select sdnc_model_name, sdnc_model_version, sdnc_artifact_name from VF_MODEL WHERE customization_uuid = '88e0e9a7-5bd2-4689-ae9e-7fc167d685a2';
        +-----------------+--------------------+--------------------+
        | sdnc_model_name | sdnc_model_version | sdnc_artifact_name |
        +-----------------+--------------------+--------------------+
        | vFW_CNF_CDS     | 1.0.0              | vnf                |
        +-----------------+--------------------+--------------------+
        1 row in set (0.00 sec)

        # Where customization_uuid is the modelCustomizationUuid of the VNf (serviceVnfs response in 2nd postman call from SO Catalog DB)

- CDS:

    CDS should onboard CBA uploaded as part of VF.

    **Postman -> CDS -> CDS Blueprint List CBAs**

    ::

        {
            "blueprintModel": {
                "id": "761bbe69-8357-454b-9f37-46d9da8ecad6",
                "artifactUUId": null,
                "artifactType": "SDNC_MODEL",
                "artifactVersion": "1.0.0",
                "artifactDescription": "Controller Blueprint for vFW_CNF_CDS:1.0.0",
                "internalVersion": null,
                "createdDate": "2020-02-21T12:57:43.000Z",
                "artifactName": "vFW_CNF_CDS",
                "published": "Y",
                "updatedBy": "Samuli Silvius <s.silvius@partner.samsung.com>",
                "tags": "Samuli Silvius, vFW_CNF_CDS"
            }
        }

    The list should have the matching entries with SDNC database:

    - sdnc_model_name == artifactName
    - sdnc_model_version == artifactVersion

- K8splugin:

    K8splugin should onboard 4 resource bundles related to helm resources:

    **Postman -> Multicloud -> List Resource Bundle Definitions**

    ::

        [
            {
                "rb-name": "750b39d0-7f99-4b7f-9a22-c15c7348221d",
                "rb-version": "8bb9fa50-3e82-4664-bd1c-a29267be726a",
                "chart-name": "base_template",
                "description": "",
                "labels": {
                    "vnf_customization_uuid": "603eadfe-50d6-413a-853c-46f5a8e2ddc7"
                }
            },
            {
                "rb-name": "2e3b182d-7ee3-4a8d-9c2b-056188b6eb53",
                "rb-version": "027696a5-a605-44ea-9362-391a6b217de0",
                "chart-name": "vsn",
                "description": "",
                "labels": {
                    "vnf_customization_uuid": "f75c3628-12e9-4c70-be98-d347045a3f70"
                }
            },
            {
                "rb-name": "5c9f3097-26ba-41fb-928b-f7ddc31f6f52",
                "rb-version": "64af8ad0-cb81-42a2-a069-7d246d8bff5d",
                "chart-name": "vpkg",
                "description": "",
                "labels": {
                    "vnf_customization_uuid": "32ffad03-d38d-46d5-b4a6-a3b0b6112ffc"
                }
            },
            {
                "rb-name": "5c6a06e9-1168-4b01-bd2a-38d544c6d131",
                "rb-version": "55d889e4-ff38-4ed0-a159-60392c968042",
                "chart-name": "vfw",
                "description": "",
                "labels": {
                    "vnf_customization_uuid": "f9afd9bb-7796-4aff-8f53-681513115742"
                }
            }
        ]

3-2 Cloud Registration
~~~~~~~~~~~~~~~~~~~~~~

Cloud Registration into ONAP
............................

Managed Kubernetes cluster is registered here into ONAP as one cloud region. This obviously is done just one time for this particular cloud. Cloud registration information is kept in AAI.

Postman collection have folder/entry for each step. Execute in this order.

**Postman -> AAI -> Create**

- Create Complex
- Create Cloud Region
- Create Complex-Cloud Region Relationship
- Create Service
- Create Service Subscription
- Create Cloud Tenant
- Create Availability Zone

Multicloud Cloud Registration
.............................

To setup multicloud/k8s plugin to work within multicloud framework some configuration is needed.

It's not clear why this separate registration is needed in Multicloud in addition AAI is already populated. Could be again a place for improvement. Also the first step "Register Cloud" uses URL path pointing to **titaniumcloud** that does not sound very reasonable.

::

  /api/multicloud-titaniumcloud/v1/k8scloudowner4/k8sregionfour/registry

**Postman -> Multicloud**

- Register Cloud
- Upload Connectivity Info  **TODO: where to get kubeconfig file?**

3-3 CNF Instantiation
~~~~~~~~~~~~~~~~~~~~~

This is the whole beef of the use case and furthermore the core of it is that we can instantiate any amount of instances of the same CNF each running and working completely of their own. Very basic functionality in VM (VNF) side but for Kubernetes and ONAP integration this is the first milestone towards other normal use cases familiar for VNFs.

Use again Postman to trigger instantion from SO interface. Postman collection is automated to populate needed parameters when queries are run in correct order. If you did not already run following 2 queries after distribution (to verify distribution), run those now:

- **Postman -> SDC/SO -> SDC Catalog Service**
- **Postman -> SDC/SO -> SO Catalog DB Service xNFs**

Now actual instantiation can be triggered with:

**Postman -> SDC/SO -> SO Self-Serve Service Assign & Activate**

Follow progress with SO's GET request:

**Postman -> SDC/SO -> SO Infra Active Requests**

The successful reply payload in that query should start like this:

::

    {
      "clientRequestId": null,
      "action": "createInstance",
      "requestStatus": "COMPLETED",
      "statusMessage": "Failed to create self-serve assignment for vf-module with vf-module-id=b70112fd-f6b2-44fe-a55c-6928d61843bf with error: Encountered error from self-serve-generate-name with error: Error from NameGenerationNode Assign",
      "rollbackStatusMessage": null,
      "flowStatus": "Execution of UnassignVfModuleBB has completed successfully, next invoking UnassignVfModuleBB (Execution Path progress: BBs completed = 1; BBs remaining = 4).",
      "retryStatusMessage": null,
    ...

**TODO: fix COMPLETED payload**

Second instance Instantion
..........................

To finally verify that all the work done within this demo, it should be possible to instantiate second vFW instance successfully.

Trigger again:

**Postman -> SDC/SO -> SO Self-Serve Service Assign & Activate**

3-4 Results and Logs
~~~~~~~~~~~~~~~~~~~~

Now Kubernetes version of vFW multiple instances are running in target VIM (KUD deployment).

.. figure:: files/vFW_CNF_CDS/vFW_Instance_In_Kubernetes.png
   :align: center

   vFW Instance In Kubernetes

To review situation after instantiation from different ONAP components, most of the info can be found using Postman queries provided. For each query, example response payload(s) is/are saved and can be found from top right corner of the Postman window.

Execute following Postman queries and check example section to see the valid results.

========================    =================
Verify Target               Postman query
------------------------    -----------------
Service Instances in AAI    **Postman -> AAI -> List Service Instances**
Generic VNFs in AAI         **Postman -> AAI -> List VNF Instances**
K8S Instances in KUD        **Postman -> Multicloud -> List Instances**
========================    =================

Query also directly from VIM:

::

    # TODO: label filters needed here
    kubectl -n onap get pods,svc,networks,cm,network-attachment-definition,deployments

    # TODO: Example output here


Component Logs
..............

- `SO_bpmn.log`_
- SO vnfm adapter
- `SDNC_karaf.log`_

  From karaf.log all requests (payloads) to CDS can be found by searching following string:

  ``'Sending request below to url http://cds-blueprints-processor-http:8080/api/v1/execution-service/process'``

- `CDS_blueprints-processor.log`_
- CDS sdc listener
- `multicloud-k8s-plugin.log`_
- Multicloud artifactbroker
- network naming

Debug log
+++++++++

In case more detailed logging is needed, here's instructions how to setup DEBUG logging for few components.

- SDNC
- CDS Blueprint Processor

  ::

    # Edit configmap
    kubectl edit configmap onap-cds-cds-blueprints-processor-configmap

    # Edit logback.xml content change root logger level from info to debug.
    <root level="debug">
        <appender-ref ref="STDOUT"/>
    </root>

    # Delete the POd to make changes effective
    kubectl -n onap delete pod $(kubectl -n onap get pod -l app=cds-blueprints-processor --no-headers | cut -d" " -f1)

PART 4 - CDS Model Testing
--------------------------

During testing of the use case **uat.yml** file was recorded according to `CDS UAT Testing`_ instructions. Generated uat.yml is stored within CBA package into **Tests** folder.

Recorded uat.yml is an example run with example values (the values we used when demo was run) and can be used later to test CBA model in isolation (unit test style). This is very useful when changes are made to CBA model and those changes are needed to be tested fast. With uat.yml file only CDS is needed as all external interfaces are mocked. However, note that mocking is possible for REST interfaces only (e.g. Netconf is not supported).

Another benefit of uat.yml is that it documents the runtime functionality of the CBA.

To verify CBA (if it's changed) with uat.yaml and CDS runtime do following:

- Enable UAT testing for CDS runtime

  ::

      kubectl -n onap edit deployment onap-cds-cds-blueprints-processor

      # add env variable for cds-blueprints-processor container:
                name: spring_profiles_active
                value: uat

- Verify CBA with UAT

  ::

      curl -X POST -u ccsdkapps:ccsdkapps -F cba=@my_cba.zip http://<kube-node>:30499/api/v1/uat/verify

**TODO: add UAT POST to postman**

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
.. _SO Cloud Region Selection: https://git.onap.org/so/tree/adapters/mso-openstack-adapters/src/main/java/org/onap/so/adapters/vnf/MsoVnfPluginAdapterImpl.java?h=elalto#n1149
.. _Jira Epic: https://jira.onap.org/browse/INT-1184
.. _Data Dictionary: https://git.onap.org/demo/tree/heat/vFW_CNF_CDS/templates/cba-dd.json?h=frankfurt
.. _Helm Healer: https://git.onap.org/oom/offline-installer/tree/tools/helm-healer.sh
.. _CDS UAT Testing: https://wiki.onap.org/display/DW/Modeling+Concepts#Concepts-2603186
.. _vFW_CNF_CDS.postman_collection.json: files/vFW_CNF_CDS/vFW_CNF_CDS.postman_collection.json
.. _vFW_CNF_CDS.postman_environment.json: files/vFW_CNF_CDS/vFW_CNF_CDS.postman_environment.json
.. _SO_bpmn.log: files/vFW_CNF_CDS/logs/so-bpmn-infra_so-bpmn-infra_debug.log
.. _SDNC_karaf.log: files/vFW_CNF_CDS/logs/sdnc_sdnc_karaf.log
.. _CDS_blueprints-processor.log: files/vFW_CNF_CDS/logs/cds-blueprints-processor_cds-blueprints-processor_POD_LOG.log
.. _multicloud-k8s-plugin.log: files/vFW_CNF_CDS/logs/multicloud-k8s_multicloud-k8s_POD_LOG.log
