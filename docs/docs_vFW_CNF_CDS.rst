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

- Import this postman collection into postman `vFW_CNF_CDS.postman_collection.json <files/vFW_CNF_CDS/vFW_CNF_CDS.postman_collection.json>`__
- Import this postman environment into postman `vFW_CNF_CDS.postman_environment.json <files/vFW_CNF_CDS/vFW_CNF_CDS.postman_environment.json>`__
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

- customer
- owning-entity
- platform
- project
- line-of-business

Create all these entries into AAI in this order. Postman collection provided in this demo can be used for creating each entry.

Cloud Registration:

One per cloud
- complex
- cloud-region
- complex-cloud-region relationship
- service
- service-subscription
- tenant
- availability-zone


Multicloud
- Register cloud (maybe removed?)
- Upload Connectivity-info


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
    - sdnc_model_version - 1.0.0 (update accordingly to repository content)

Distributing
............

Distribute service.

Verify distribution for:
    SDNC:
        SDNC should have it's database updated with sdnc_* properties that were set during service modeling
        ``
        kubectl exec -n onap onap-mariadb-galera-mariadb-galera-0 -it
        SELECT * from VF_MODEL;
        exit
        ``
    CDS:
        CDS should onboard CBA uploaded as part of VF.
        Postman -> CDS -> CDS Blueprint List CBAs
    K8splugin:
        K8splugin should onboard 4 resource bundles related to helm resources:
        ``
        kubectl logs onap-multicloud-multicloud-k8s-54d9b669bf-zcd8b framework-artifactbroker
        ``
        or with Postman -> Multicloud -> List Resource Bundle Definitions


3-2 Cloud Registration
~~~~~~~~~~~~~~~~~~~~~~

Cloud Registration
..................

Managed Kubernetes cluster is registered here into ONAP as one cloud region. This obviously is done just one time for this particular cloud.

- complex
- cloud-region
- complex-cloud-region relationship
- service
- service-subscription
- tenant
- availability-zone

Postman collection should have folder/entry for each step with similar name. Execute in this order.

Multicloud setup (better name?)
...............................

To setup multicloud/k8s plugin to work within multicloud framework execute following steps.

- Register cloud (maybe removed?)
- Upload Connectivity-info  (where to get kubeconfig file?)

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
.. _SO Cloud Region Selection: https://git.onap.org/so/tree/adapters/mso-openstack-adapters/src/main/java/org/onap/so/adapters/vnf/MsoVnfPluginAdapterImpl.java?h=elalto#n1149
.. _Jira Epic: https://jira.onap.org/browse/INT-1184
.. _Data Dictionary: https://git.onap.org/demo/tree/heat/vFW_CNF_CDS/templates/cba-dd.json?h=frankfurt
