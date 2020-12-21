.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. Copyright 2020 ONAP

.. _docs_vFW_CNF_CDS:

:orphan:

vFirewall CNF Use Case
----------------------

Source files
~~~~~~~~~~~~
- Heat/Helm/CDS models: `vFW_CNF_CDS Model`_
- Automation Scripts: `vFW_CNF_CDS Automation`_

Description
~~~~~~~~~~~
This use case is a combination of `vFW CDS Dublin`_ and `vFW EDGEX K8S`_ use cases. The aim is to continue improving Kubernetes based Network Functions (a.k.a CNF) support in ONAP. Use case continues where `vFW EDGEX K8S`_ left and brings CDS support into picture like `vFW CDS Dublin`_ did for the old vFW Use case. Predecessor use case is also documented here `vFW EDGEX K8S In ONAP Wiki`_.

This use case shows how to onboard helm packages and to instantiate them with help of ONAP. Following improvements were made in the vFW CNF Use Case:

- vFW Kubernetes Helm charts support overrides (previously mostly hardcoded values)
- SDC accepts Onboarding Package with many helm packages what allows to keep decomposition of service instance similar to `vFW CDS Dublin`_
- Compared to `vFW EDGEX K8S`_ use case **MACRO** workflow in SO is used instead of VNF a'la carte workflow
- No VNF data preloading used, instead resource-assignment feature of CDS is used
- CDS is used to resolve instantiation time parameters (Helm overrides)
  - Ip addresses with IPAM
  - Unique names for resources with ONAP naming service
  - CDS is used to create and upload **multicloud/k8s profile** as part of instantiation flow
- Combined all models (Heat, Helm, CBA) in to same git repo and a created single onboarding package `vFW_CNF_CDS Model`_
- Use case does not contain Closed Loop part of the vFW demo.

All changes to related ONAP components and Use Case can be found in the following tickets:

- `REQ-182`_
- `REQ-341`_

**Since Guilin ONAP supports Helm packages as a native onboarding artifacts and SO natively orchestrates Helm packages what brings significant advantages in the future. Also since this release ONAP has first mechanisms for monitoring of the status of deployed CNF resources**.

The vFW CNF Use Case
~~~~~~~~~~~~~~~~~~~~
The vFW CNF CDS use case shows how to instantiate multiple CNF instances in similar way as VNFs bringing CNFs closer to first class citizens in ONAP.

One of the biggest practical change compared to the old demos (any ONAP demo) is that whole network function content (user provided content) is collected to one place and more importantly into git repository (`vFW_CNF_CDS Model`_) that provides version control (that is pretty important thing). That is very basic thing but unfortunately this is a common problem when running any ONAP demo and trying to find all content from many different git repositories and even some files only in ONAP wiki.

Demo git directory has also `Data Dictionary`_ file (CDS model time resource) included.

Another founding idea from the start was to provide complete content in single onboarding package available directly from that git repository. Not any revolutionary idea as that's the official package format ONAP supports and all content supposed to be in that same package for single service regardless of the models and closed loops and configurations etc.

Following table describes all the source models to which this demo is based on.

===============  =================       ===========
Model            Git reference           Description
---------------  -----------------       -----------
Heat             `vFW_NextGen`_          Heat templates used in original vFW demo but split into multiple vf-modules
Helm             `vFW_Helm Model`_       Helm templates used in `vFW EDGEX K8S`_ demo
CDS model        `vFW CBA Model`_        CDS CBA model used in `vFW CDS Dublin`_ demo
===============  =================       ===========

.. note::  Since the Guilin release `vFW_CNF_CDS Model`_ contains sources that allow to model and instantiate CNF with VNF/Heat orchestration approach (Frankfurt) and with native Helm orchestration approach. Please follow README.txt description and further documentation here to generate and select appropriate onboarding package which will leverage appropriate SO orchestration path.

Modeling Onboarding Package/Helm
................................

The starting point for this demo was Helm package containing one Kubernetes application, see `vFW_Helm Model`_. In this demo we decided to follow SDC/SO vf-module concept the same way as original vFW demo was split into multiple vf-modules instead of one (`vFW_NextGen`_). The same way we splitted Helm version of vFW into multiple Helm packages each matching one dedicated vf-module.

The Guilin version of the `vFW_CNF_CDS Model`_ contains files required to create **VSP onboarding packages in two formats**: the **Dummy Heat** (available in Frankfurt release already) one that considers association of each Helm package with dummy heat templates and the **Native Helm** one where each Helm package is standalone and is natively understood in consequence by SO. For both variants of VSP Helm packages are matched to the vf-module concept, so basically each Helm application after instantiation is visible to ONAP as a separate vf-module. The chosen format for onboarding has **crucial** role in the further orchestration approach applied for Helm package instantiation. The **Dummy Heat** will result with orchestration through the **Openstack Adapter** component of SO while **Native Helm** will result with **CNF Adapter**. Both approaches will result with instantiation of the same CNF, however the **Native Helm** approach will be enhanced in the future releases while **Dummy Heat** approach will become deprecated in the future.

Produced **Dummy Heat** VSP onboarding package `Creating Onboarding Package`_ format has following MANIFEST file (package_dummy/MANIFEST.json). The Helm package is delivered as CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT package through SDC and SO. Dummy heat templates are matched to Helm packages by the same prefix <vf_module_label> of the file name that for both dummy Heat teamplate and for CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT must be the same, like i.e. *vpg* vf-module in the manifest file below. The name of the CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT artifact is predefined and needs to match the pattern: <vf_module_label>_cloudtech_k8s_charts.tgz. More examples can be found in `Modeling Onboarding Package/Helm`_ section.

::

    {
        "name": "virtualFirewall",
        "description": "",
        "data": [
            {
                "file": "CBA.zip",
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
                "type": "CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT"
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
                "type": "CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT"
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
                "type": "CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT"
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
                "type": "CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT"
            }
        ]
    }

Produced **Native Helm** VSP onboarding package `Creating Onboarding Package`_ format has following MANIFEST file (package_native/MANIFEST.json). The Helm package is delivered as HELM package through SDC and SO. The *isBase* flag of HELM artifact is ignored by SDC but in the manifest one HELM or HEAT artifacts must be defined as isBase = true. If both HEAT and HELM are present in the same manifest file the base one must be always one of HELM artifacts. Moreover, the name of HELM type artifact must match the specified pattern: *helm_<some_name>* and the HEAT type artifacts, if present in the same manifest, cannot contain keyword *helm*. These limitations are a consequence of current limitations of the SDC onboarding and VSP validation engine and will be adresssed in the future releases.

::

    {
        "name": "virtualFirewall",
        "description": "",
        "data": [
            {
                "file": "CBA.zip",
                "type": "CONTROLLER_BLUEPRINT_ARCHIVE"
            },
            {
                "file": "helm_base_template.tgz",
                "type": "HELM",
                "isBase": "true"
            },
            {
                "file": "helm_vfw.tgz",
                "type": "HELM",
                "isBase": "false"
            },
            {
                "file": "helm_vpkg.tgz",
                "type": "HELM",
                "isBase": "false"
            },
            {
                "file": "helm_vsn.tgz",
                "type": "HELM",
                "isBase": "false"
            }
        ]
    }

.. note::  CDS model (CBA package) is delivered as SDC supported own type CONTROLLER_BLUEPRINT_ARCHIVE but the current limitation of VSP onbarding forces to use the artifact name *CBA.zip* to automaticaly recognize CBA as a CONTROLLER_BLUEPRINT_ARCHIVE.

CDS Model (CBA)
...............

Creating CDS model was the core of the use case work and also the most difficult and time consuming part. Current template used by use-case should be easily reusable for anyone. Once CDS GUI will be fully working, we think that CBA development should be much easier. For CBA structure reference, please visit it's documentation page `CDS Documentation`_.

At first the target was to keep CDS model as close as possible to `vFW_CNF_CDS Model`_ use case model and only add smallest possible changes to enable also k8s usage. That is still the target but in practice model deviated from the original one already and time pressure pushed us to not care about sync. Basically the end result could be possible much streamlined if wanted to be smallest possible to working only for K8S based network functions.

As K8S application was split into multiple Helm packages to match vf-modules, CBA modeling follows the same and for each vf-module there's own template in CBA package. The list of artifact with the templates is different for **Dummy Heat** and **Native Helm** approach. The second one has artifact names starting with *helm_* prefiks, in the same way like names of artifacts in the MANIFEST file of VSP differs. The **Dummy Heat** artifacts' list is following:

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

The **Native Helm** artifacts' list is following:

::

    "artifacts" : {
      "helm_base_template-template" : {
        "type" : "artifact-template-velocity",
        "file" : "Templates/base_template-template.vtl"
      },
      "helm_base_template-mapping" : {
        "type" : "artifact-mapping-resource",
        "file" : "Templates/base_template-mapping.json"
      },
      "helm_vpkg-template" : {
        "type" : "artifact-template-velocity",
        "file" : "Templates/vpkg-template.vtl"
      },
      "helm_vpkg-mapping" : {
        "type" : "artifact-mapping-resource",
        "file" : "Templates/vpkg-mapping.json"
      },
      "helm_vfw-template" : {
        "type" : "artifact-template-velocity",
        "file" : "Templates/vfw-template.vtl"
      },
      "helm_vfw-mapping" : {
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
      "helm_vsn-template" : {
        "type" : "artifact-template-velocity",
        "file" : "Templates/vsn-template.vtl"
      },
      "helm_vsn-mapping" : {
        "type" : "artifact-mapping-resource",
        "file" : "Templates/vsn-mapping.json"
      }
    }

Only **resource-assignment** workflow of the CBA model is utilized in this demo. If final CBA model contains also **config-deploy** workflow it's there just to keep parity with original vFW CBA (for VMs). Same applies for the related template *Templates/nf-params-template.vtl* and it's mapping file.

Another advance of the presented use case over solution presented in the Dublin release is possibility of the automatic generation and upload to multicloud/k8s plugin the RB profile content.
RB profile can be used to enrich or to modify the content of the original helm package. Profile can be also used to add additional k8s helm templates for helm installation or can be used to
modify existing k8s helm templates for each create CNF instance. It opens another level of CNF customization, much more than customization of helm package with override values.

::

  ---
  version: v1
  type:
    values: “override_values.yaml”
    configresource:
      - filepath: resources/deployment.yaml
        chartpath: templates/deployment.yaml


Above we have exemplary manifest file of the RB profile. Since Frankfurt *override_values.yaml* file does not need to be used as instantiation values are passed to the plugin over Instance API of k8s plugin. In the example, profile contains additional k8s helm template which will be added on demand to the helm package during its installation. In our case, depending on the SO instantiation request input parameters, vPGN helm package can be enriched with additional ssh service. Such service will be dynamically added to the profile by CDS and later on CDS will upload whole custom RB profile to multicloud/k8s plugin.

In order to support generation and upload of profile, our vFW CBA model has enhanced **resource-assignment** workflow which contains additional step: **profile-upload**. It leverages dedicated functionality introduced in Guilin release that can be used to upload predefined profile or to generate and upload content of the profile with Velocity templating mechanism.

::

    "resource-assignment": {
        "steps": {
            "resource-assignment": {
                "description": "Resource Assign Workflow",
                "target": "resource-assignment",
                "activities": [
                    {
                        "call_operation": "ResourceResolutionComponent.process"
                    }
                ],
                "on_success": [
                    "profile-upload"
                ]
            },
            "profile-upload": {
                "description": "Generate and upload K8s Profile",
                "target": "k8s-profile-upload",
                "activities": [
                    {
                        "call_operation": "ComponentScriptExecutor.process"
                    }
                ]
            }
        },

.. note:: In the Frankfurt reelase profile upload was implementes as a custom Kotlin script included into the CBA. It was responsible for upload of K8S profile into multicloud/k8s plugin. It is still a good example of  the integration of Kotlin scripting into the CBA. For those interested in this functionaliy we recommend to look into the `Frankfurt CBA Definition`_ and `Frankfurt CBA Script`_.

In our example for vPKG helm package we may select *vfw-cnf-cds-vpkg-profile* profile that is included into CBA as a folder. Profile generation step uses embedded into CDS functionality of Velocity templates processing and on its basis ssh port number (specified in the SO request as *vpg-management-port*).

::

    {
        "name": "vpg-management-port",
        "property": {
            "description": "The number of node port for ssh service of vpg",
            "type": "integer",
            "default": "0"
        },
        "input-param": false,
        "dictionary-name": "vpg-management-port",
        "dictionary-source": "default",
        "dependencies": []
    }

*vpg-management-port* can be included directly into the helm template and such template will be included into vPKG helm package in time of its instantiation.

::

  apiVersion: v1
  kind: Service
  metadata:
    name: {{ .Values.vpg_name_0 }}-ssh-access
    labels:
      vnf-name: {{ .Values.vnf_name }}
      vf-module-name: {{ .Values.vpg_name_0 }}
      release: {{ .Release.Name }}
      chart: {{ .Chart.Name }}
  spec:
    type: NodePort
    ports:
      - port: 22
        nodePort: ${vpg-management-port}
    selector:
      vf-module-name: {{ .Values.vpg_name_0 }}
      release: {{ .Release.Name }}
      chart: {{ .Chart.Name }}


The mechanism of profile generation and upload requires specific node teamplate in the CBA definition. In our case it comes with the declaration of two profiles: one static *vfw-cnf-cds-base-profile* in a form of an archive and the second complex *vfw-cnf-cds-vpkg-profile* in a form of a folder for processing and profile generation.

::

    "k8s-profile-upload": {
        "type": "component-k8s-profile-upload",
        "interfaces": {
            "K8sProfileUploadComponent": {
                "operations": {
                    "process": {
                        "inputs": {
                            "artifact-prefix-names": {
                                "get_input": "template-prefix"
                            },
                            "resource-assignment-map": {
                                "get_attribute": [
                                    "resource-assignment",
                                    "assignment-map"
                                ]
                            }
                        }
                    }
                }
            }
        },
        "artifacts": {
            "vfw-cnf-cds-base-profile": {
                "type": "artifact-k8sprofile-content",
                "file": "Templates/k8s-profiles/vfw-cnf-cds-base-profile.tar.gz"
            },
            "vfw-cnf-cds-vpkg-profile": {
                "type": "artifact-k8sprofile-content",
                "file": "Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile"
            },
            "vfw-cnf-cds-vpkg-profile-mapping": {
                "type": "artifact-mapping-resource",
                "file": "Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/ssh-service-mapping.json"
            }
        }
    }

Artifact file determines a place of the static profile or the content of the complex profile. In the latter case we need a pair of profile folder and mappimng file with a declaration of the parameters that CDS needs to resolve first, before the Velocity templating is applied to the *.vtl files present in the profile content. After Velovity templating the *.vtl extensions will be ropped from the file names. The embedded mechanism will include in the profile only files present in the profile MANIFEST file that needs to contain the list of final names of the files to be included into the profile. Th figure below shows the idea of profile templating.

.. figure:: files/vFW_CNF_CDS/profile-templating.png
   :align: center

   K8s Profile Templating

SO requires for instantiation name of the profile in the parameter: *k8s-rb-profile-name*. The *component-k8s-profile-upload* that stands behind the profile uploading mechanism has input parameters that can be passed directly (checked in the first order) or can be taken from the *resource-assignment-map* parameter which can be a result of associated *component-resource-resolution* result, like in our case their values are resolved on vf-module level resource assignment. The *component-k8s-profile-upload* inputs are following:

- k8s-rb-profile-name – (mandatory) the name of the profile under which it will be created in k8s plugin. Other parameters are required only when profile must be uploaded
- k8s-rb-definition-name – the name under which RB definition was created - **VF Module Model Invariant ID** in ONAP
- k8s-rb-definition-version – the version of created RB definition name - **VF Module Model Version ID**  in ONAP
- k8s-rb-profile-namespace – the k8s namespace name associated with profile being created
- k8s-rb-profile-source – the source of profile content - name of the artifact of the profile
- resource-assignment-map – result of the associated resource assignment step
- artifact-prefix-names – (mandatory) the list of artifact prefixes like for resource-assigment step

In the SO request user can pass parameter of name *k8s-rb-profile-name* which in our case may have value: *vfw-cnf-cds-base-profile*, *vfw-cnf-cds-vpkg-profile* or *default*. The *default* profile doesn’t contain any content inside and allows instantiation of CNF without the need to define and upload any additional profiles. *vfw-cnf-cds-vpkg-profile* has been prepard to test instantiation of the second modified vFW CNF instance `Second Service Instance Instantiation`_.

K8splugin allows to specify override parameters (similar to --set behavior of helm client) to instantiated resource bundles. This allows for providing dynamic parameters to instantiated resources without the need to create new profiles for this purpose and should be used with *default* profile but may be used also with custom profiles. The overall flow of helm overrides parameters processing is visible on following figure.

.. figure:: files/vFW_CNF_CDS/helm-overrides.png
   :align: center

   The overall flow of helm overrides

Finally, `Data Dictionary`_ is also included into demo git directory, re-modeling and making changes into model utilizing CDS model time / runtime is easier as used DD is also known. 

.. note:: The CBA for this use case is already enriched and there is no need to perform enrichment process for it. It is also automatically uploaded into CDS in time of the model distribution from the SDC.

Instantiation Overview
----------------------

.. note:: Since Guilin release use case is equipped with automated method **<AUTOMATED>** with python scripts to replace Postman method **<MANUAL>** used in Frankfurt. Nevertheless, Postman collection is good to understand the entire process but should be used **separably** with automation scripts. **For the entire process use only scripts or only Postman collection**. Both options are described in the further steps of this instruction.

The figure below shows all the interactions that take place during vFW CNF instantiation. It's not describing flow of actions (ordered steps) but rather component dependencies.

.. figure:: files/vFW_CNF_CDS/Instantiation_topology.png
   :align: center

   vFW CNF CDS Use Case Runtime interactions.

PART 1 - ONAP Installation
~~~~~~~~~~~~~~~~~~~~~~~~~~

1-1 Deployment components
.........................

In order to run the vFW_CNF_CDS use case, we need ONAP Guilin Release (or later) with at least following components:

=======================================================   ===========
ONAP Component name                                       Describtion
-------------------------------------------------------   -----------
AAI                                                       Required for Inventory Cloud Owner, Customer, Owning Entity, Service, Generic VNF, VF Module
SDC                                                       VSP, VF and Service Modeling of the CNF
DMAAP                                                     Distribution of the onboarding package including CBA to all ONAP components
SO                                                        Requires for Macro Orchestration using the generic building blocks
CDS                                                       Resolution of cloud parameters including Helm override parameters for the CNF. Creation of the multicloud/k8s profile for CNF instantion.
SDNC (needs to include netbox and Naming Generation mS)   Provides GENERIC-RESOURCE-API for cloud Instantiation orchestration via CDS.
Policy                                                    Used to Store Naming Policy
AAF                                                       Used for Authentication and Authorization of requests
Portal                                                    Required to access SDC.
MSB                                                       Exposes multicloud interfaces used by SO.
Multicloud                                                K8S plugin part used to pass SO instantiation requests to external Kubernetes cloud region.
Contrib                                                   Chart containing multiple external components. Out of those, we only use Netbox utility in this use-case for IPAM
Robot                                                     Optional. Can be used for running automated tasks, like provisioning cloud customer, cloud region, service subscription, etc ..
Shared Cassandra DB                                       Used as a shared storage for ONAP components that rely on Cassandra DB, like AAI
Shared Maria DB                                           Used as a shared storage for ONAP components that rely on Maria DB, like SDNC, and SO
=======================================================   ===========

1-2 Deployment
..............

In order to deploy such an instance, follow the `ONAP Deployment Guide`_

As we can see from the guide, we can use an override file that helps us customize our ONAP deployment, without modifying the OOM Folder, so you can download this override file here, that includes the necessary components mentioned above.

**override.yaml** file where enabled: true is set for each component needed in demo (by default all components are disabled).

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

Then deploy ONAP with Helm with your override file.

::

    helm deploy onap local/onap --namespace onap -f ~/override.yaml

In case redeployment needed `Helm Healer`_ could be a faster and convenient way to redeploy.

::

    helm-healer.sh -n onap -f ~/override.yaml -s /dockerdata-nfs --delete-all

Or redeploy (clean re-deploy also data removed) just wanted components (Helm releases), cds in this example.

::

    helm-healer.sh -f ~/override.yaml -s /dockerdata-nfs/ -n onap -c onap-cds

There are many instructions in ONAP wiki how to follow your deployment status and does it succeeded or not, mostly using Robot Health checks. One way we used is to skip the outermost Robot wrapper and use directly ete-k8s.sh to able to select checked components easily. Script is found from OOM git repository *oom/kubernetes/robot/ete-k8s.sh*.

::

    {
    failed=
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
    }

And check status of pods, deployments, jobs etc.

::

    kubectl -n onap get pods | grep -vie 'completed' -e 'running'
    kubectl -n onap get deploy,sts,jobs


1-3 Post Deployment
...................

After completing the first part above, we should have a functional ONAP deployment for the Guilin Release.

We will need to apply a few modifications to the deployed ONAP Guilin instance in order to run the use case.

Retrieving logins and passwords of ONAP components
++++++++++++++++++++++++++++++++++++++++++++++++++

Since Frankfurt release hardcoded passwords were mostly removed and it is possible to configure passwords of ONAP components in time of their installation. In order to retrieve these passwords with associated logins it is required to get them with kubectl. Below is the procedure on mariadb-galera DB component example.

::

    kubectl get secret `kubectl get secrets | grep mariadb-galera-db-root-password | awk '{print $1}'` -o jsonpath="{.data.login}" | base64 --decode
    kubectl get secret `kubectl get secrets | grep mariadb-galera-db-root-password | awk '{print $1}'` -o jsonpath="{.data.password}" | base64 --decode

In this case login is empty as the secret is dedicated to root user.


Postman collection setup
++++++++++++++++++++++++

In this demo we have on purpose created all manual ONAP preparation steps (which in real life are automated) by using Postman so it will be clear what exactly is needed. Some of the steps like AAI population is automated by Robot scripts in other ONAP demos (**./demo-k8s.sh onap init**) and Robot script could be used for many parts also in this demo.

Postman collection is used also to trigger instantiation using SO APIs.

Following steps are needed to setup Postman:

- Import this Postman collection zip

  :download:`Postman collection <files/vFW_CNF_CDS/postman.zip>`

- Extract the zip and import Postman collection into Postman. Environment file is provided for reference, it's better to create own environment on your own providing variables as listed in next chapter.
    - `vFW_CNF_CDS.postman_collection.json`
    - `vFW_CNF_CDS.postman_environment.json`

- For use case debugging purposes to get Kubernetes cluster external access to SO CatalogDB (GET operations only), modify SO CatalogDB service to NodePort instead of ClusterIP. You may also create separate own NodePort if you wish, but here we have just edited directly the service with kubectl.

::

    kubectl -n onap edit svc so-catalog-db-adapter
         - .spec.type: ClusterIP
         + .spec.type: NodePort
         + .spec.ports[0].nodePort: 30120

.. note::  The port number 30120 is used in included Postman collection

- You may also want to inspect after SDC distribution if CBA has been correctly delivered to CDS. In order to do it, there are created relevant calls later described in doc, however CDS since Frankfurt doesn't expose blueprints-processor's service as NodePort. This is OPTIONAL but if you'd like to use these calls later, you need to expose service in similar way as so-catalog-db-adapter above:

::

    kubectl edit -n onap svc cds-blueprints-processor-http
          - .spec.type: ClusterIP
          + .spec.type: NodePort
          + .spec.ports[0].nodePort: 30499

.. note::  The port number 30499 is used in included Postman collection

**Postman variables:**

Most of the Postman variables are automated by Postman scripts and environment file provided, but there are few mandatory variables to fill by user.

=====================  ===================
Variable               Description
---------------------  -------------------
k8s                    ONAP Kubernetes host
sdnc_port              port of sdnc service for accessing MDSAL
service-name           name of service as defined in SDC
service-version        version of service defined in SDC (if service wasn't updated, it should be set to "1.0")
service-instance-name  name of instantiated service (if ending with -{num}, will be autoincremented for each instantiation request)
=====================  ===================

You can get the sdnc_port value with

::

    kubectl -n onap get svc sdnc -o json | jq '.spec.ports[]|select(.port==8282).nodePort'

Automation Environment Setup
............................

Whole content of this use case is stored into single git repository and it contains both the required onboarding information as well as automation scripts for onboarding and instantiation of the use case.

::

  git clone --single-branch --branch guilin "https://gerrit.onap.org/r/demo"
  cd demo/heat/vFW_CNF_CDS/templates

In order to prepare environment for onboarding and instantiation of the use case make sure you have *git*, *make*, *helm* and *pipenv* applications installed.

The automation scripts are based on `Python SDK`_ and are adopted to automate process of service onboarding, instantiation, deletion and cloud region registration. To configure them for further use:

::

  cd demo/heat/vFW_CNF_CDS/automation

1. Install required packages with
::

    pipenv pipenv install

2. Run virtual python environment
::

    pipenv shell --fancy

3. Add kubeconfig files, one for ONAP cluster, and one for k8s cluster that will host vFW

.. note:: Both files can be configured after creation of k8s cluster for vFW instance `2-1 Installation of Managed Kubernetes`_. Make sure that they have configured external IP address properly. If any cluster uses self signed certificates set also *insecure-skip-tls-verify* flag in the config file.

- artifacts/cluster_kubeconfig - IP address must be reachable by ONAP pods, especially *mutlicloud-k8s* pod

- artifacts/onap_kubeconfig - IP address must be reachable by automation scripts

4. Modify config.py file

- NATIVE - when enabled **Native Helm** path will be used, otherwise **Dummy Heat** path will be used
- CLOUD_REGION - name of your k8s cluster from ONAP perspective
- GLOBAL_CUSTOMER_ID - identifier of customer in ONAP
- VENDOR - name of the Vendor in ONAP
- SERVICENAME - **Name of your service model in SDC**
- CUSTOMER_RESOURCE_DEFINITIONS - add list of CRDs to be installed on non KUD k8s cluster - should be used ony to use some non-KUD cluster like i.e. ONAP one to test instantiation of Helm package. For KUD should be empty list

.. note:: For automation script it is necessary to modify only NATIVE and SERVICENAME constants. Other constants may be modified if needed.

AAI
...

Some basic entries are needed in ONAP AAI. These entries are needed ones per onap installation and do not need to be repeated when running multiple demos based on same definitions.

Create all these entries into AAI in this order. Postman collection provided in this demo can be used for creating each entry.

**<MANUAL>**
::

    Postman -> Initial ONAP setup -> Create

- Create Customer
- Create Owning-entity
- Create Platform
- Create Project
- Create Line Of Business

Corresponding GET operations in "Check" folder in Postman can be used to verify entries created. Postman collection also includes some code that tests/verifies some basic issues e.g. gives error if entry already exists.

**<AUTOMATED>**

This step is performed jointly with onboarding step `3-1 Onboarding`_

Naming Policy
+++++++++++++

Naming policy is needed to generate unique names for all instance time resources that are wanted to be modeled in the way naming policy is used. Those are normally VNF, VNFC and VF-module names, network names etc. Naming is general ONAP feature and not limited to this use case.

This usecase leverages default ONAP naming policy - "SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP".
To check that the naming policy is created and pushed OK, we can run the command below from inside any ONAP pod.

::

  curl --silent -k --user 'healthcheck:zb!XztG34' -X GET "https://policy-api:6969/policy/api/v1/policytypes/onap.policies.Naming/versions/1.0.0/policies/SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP/versions/1.0.0"

.. note:: Please change credentials respectively to your installation. The required credentials can be retrieved with instruction `Retrieving logins and passwords of ONAP components`_

PART 2 - Installation of managed Kubernetes cluster
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this demo the target cloud region is a Kubernetes cluster of your choice basically just like with Openstack. ONAP platform is a bit too much hard wired to Openstack and it's visible in many demos.

2-1 Installation of Managed Kubernetes
......................................

In this demo we use Kubernetes deployment used by ONAP multicloud/k8s team to test their plugin features see `KUD github`_. There's also some outdated instructions in ONAP wiki `KUD in Wiki`_.

KUD deployment is fully automated and also used in ONAP's CI/CD to automatically verify all `Multicloud k8s gerrit`_ commits (see `KUD Jenkins ci/cd verification`_) and that's quite good (and rare) level of automated integration testing in ONAP. KUD deployemnt is used as it's installation is automated and it also includes bunch of Kubernetes plugins used to tests various k8s plugin features. In addition to deployement, KUD repository also contains test scripts to automatically test multicloud/k8s plugin features. Those scripts are run in CI/CD.

See `KUD subproject in github`_ for a list of additional plugins this Kubernetes deployment has. In this demo the tested CNF is dependent on following plugins:

- ovn4nfv
- Multus
- Virtlet

Follow instructions in `KUD github`_ and install target Kubernetes cluster in your favorite machine(s), simplest being just one machine. Your cluster nodes(s) needs to be accessible from ONAP Kuberenetes nodes. Make sure your installed *pip* is of **version < 21.0**. Version 21 do not support python 2.7 that is used in *aio.sh* script. Also to avoid performance problems of your k8s cluster make sure you install only necessary plugins and before running *aio.sh* script execute following command
::

    export KUD_ADDONS="virtlet ovn4nfv"

2-2 Cloud Registration
......................

Managed Kubernetes cluster is registered here into ONAP as one cloud region. This obviously is done just one time for this particular cloud. Cloud registration information is kept in AAI.

**<MANUAL>**

Postman collection have folder/entry for each step. Execute in this order.
::

    Postman -> K8s Cloud Region Registration -> Create

- Create Complex
- Create Cloud Region
- Create Complex-Cloud Region Relationship
- Create Service
- Create Service Subscription
- Create Cloud Tenant
- Create Availability Zone
- Upload Connectivity Info

.. note:: For "Upload Connectivity Info" call you need to provide kubeconfig file of existing KUD cluster. You can find that kubeconfig on deployed KUD in the directory `~/.kube/config` and this file can be easily copied e.g. via SCP. Please ensure that kubeconfig contains external IP of K8s cluster in kubeconfig and correct it, if it's not.

SO database needs to be (manually) modified for SO to know that this particular cloud region is to be handled by multicloud. Values we insert needs to obviously match to the ones we populated into AAI.

.. note:: Please change credentials respectively to your installation. The required credentials can be retrieved with instruction `Retrieving logins and passwords of ONAP components`_

::

    kubectl -n onap exec onap-mariadb-galera-0 -it -- mysql -uroot -psecretpassword -D catalogdb
        select * from cloud_sites;
        insert into cloud_sites(ID, REGION_ID, IDENTITY_SERVICE_ID, CLOUD_VERSION, CLLI, ORCHESTRATOR) values("k8sregionfour", "k8sregionfour", "DEFAULT_KEYSTONE", "2.5", "clli2", "multicloud");
        select * from cloud_sites;
        exit

.. note:: The configuration of the new k8s cloud site is documented also here `K8s cloud site config`_

**<AUTOMATED>**

Please copy the kubeconfig file of existing KUD cluster to automation/artifacts/cluster_kubeconfig location `Automation Environment Setup`_ - step **3**. You can find that kubeconfig on deployed KUD in the directory `~/.kube/config` and this file can be easily copied e.g. via SCP. Please ensure that kubeconfig contains external IP of K8s cluster in kubeconfig and correct it, if it's not.

::

    python create_k8s_region.py

PART 3 - Execution of the Use Case
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This part contains all the steps to run the use case by using ONAP GUIs, Postman or Python automation scripts.

Following pictures describe the overall sequential flow of the use case in two scenarios: **Dummy Heat** path (with OpenStack adapter) and **Native Helm** path (with CNF Adapter)

.. figure:: files/vFW_CNF_CDS/Dummy_Heat_Flow.png
   :align: center

   vFW CNF CDS Use Case sequence flow for *Dummy Heat* (Frankfurt) path.

.. figure:: files/vFW_CNF_CDS/Native_Helm_Flow.png
   :align: center

   vFW CNF CDS Use Case sequence flow for *Native Helm* (Guilin) path.

.. note:: The **Native Helm** path has identified defects in the instantiation process and requires SO images of version 1.7.11 for successfull instantiation of the CNF. Please monitor `SO-3403`_ and `SO-3404`_ tickets to make sure that necessary fixes have been delivered and 1.7.11 SO images are avaialble in your Guilin ONAP instance.


3-1 Onboarding
..............

.. note:: Make sure you have performed `Automation Environment Setup`_ steps before following actions here.

Creating Onboarding Package
+++++++++++++++++++++++++++

Content of the onboarding package can be created with provided Makefile in the *template* folder.

Complete content of both Onboarding Packages for **Dummy Heat**  and **Native Helm** is packaged to the following VSP onboarding package files:

- **Dummy Heat** path: **vfw_k8s_demo.zip**

- **Native Helm** path: **native_vfw_k8s_demo.zip**

.. note::  Procedure requires *make* and *helm* applications installed

::

  git clone --single-branch --branch guilin "https://gerrit.onap.org/r/demo"
  cd demo/heat/vFW_CNF_CDS/templates
  make

The result of make operation execution is following:
::

    make clean
    make[1]: Entering directory '/mnt/c/Users/advnet/Desktop/SOURCES/demo/heat/vFW_CNF_CDS/templates'
    rm -rf package_dummy/
    rm -rf package_native/
    rm -rf cba_dummy
    rm -f vfw_k8s_demo.zip
    rm -f native_vfw_k8s_demo.zip
    make[1]: Leaving directory '/mnt/c/Users/advnet/Desktop/SOURCES/demo/heat/vFW_CNF_CDS/templates'
    make all
    make[1]: Entering directory '/mnt/c/Users/advnet/Desktop/SOURCES/demo/heat/vFW_CNF_CDS/templates'
    mkdir package_dummy/
    mkdir package_native/
    make -C helm
    make[2]: Entering directory '/mnt/c/Users/advnet/Desktop/SOURCES/demo/heat/vFW_CNF_CDS/templates/helm'
    rm -f base_template-*.tgz
    rm -f helm_base_template.tgz
    rm -f base_template_cloudtech_k8s_charts.tgz
    helm package base_template
    Successfully packaged chart and saved it to: /mnt/c/Users/advnet/Desktop/SOURCES/demo/heat/vFW_CNF_CDS/templates/helm/base_template-0.2.0.tgz
    mv base_template-*.tgz helm_base_template.tgz
    cp helm_base_template.tgz base_template_cloudtech_k8s_charts.tgz
    rm -f vpkg-*.tgz
    rm -f helm_vpkg.tgz
    rm -f vpkg_cloudtech_k8s_charts.tgz
    helm package vpkg
    Successfully packaged chart and saved it to: /mnt/c/Users/advnet/Desktop/SOURCES/demo/heat/vFW_CNF_CDS/templates/helm/vpkg-0.2.0.tgz
    mv vpkg-*.tgz helm_vpkg.tgz
    cp helm_vpkg.tgz vpkg_cloudtech_k8s_charts.tgz
    rm -f vfw-*.tgz
    rm -f helm_vfw.tgz
    rm -f vfw_cloudtech_k8s_charts.tgz
    helm package vfw
    Successfully packaged chart and saved it to: /mnt/c/Users/advnet/Desktop/SOURCES/demo/heat/vFW_CNF_CDS/templates/helm/vfw-0.2.0.tgz
    mv vfw-*.tgz helm_vfw.tgz
    cp helm_vfw.tgz vfw_cloudtech_k8s_charts.tgz
    rm -f vsn-*.tgz
    rm -f helm_vsn.tgz
    rm -f vsn_cloudtech_k8s_charts.tgz
    helm package vsn
    Successfully packaged chart and saved it to: /mnt/c/Users/advnet/Desktop/SOURCES/demo/heat/vFW_CNF_CDS/templates/helm/vsn-0.2.0.tgz
    mv vsn-*.tgz helm_vsn.tgz
    cp helm_vsn.tgz vsn_cloudtech_k8s_charts.tgz
    make[2]: Leaving directory '/mnt/c/Users/advnet/Desktop/SOURCES/demo/heat/vFW_CNF_CDS/templates/helm'
    mv helm/helm_*.tgz package_native/
    mv helm/*.tgz package_dummy/
    cp base_dummy/* package_dummy/
    cp base_native/* package_native/
    cp -r cba cba_dummy
    sed -i 's/"helm_/"/g' cba_dummy/Definitions/vFW_CNF_CDS.json
    cd cba_dummy/ && zip -r CBA.zip . -x pom.xml .idea/\* target/\*
    adding: Definitions/ (stored 0%)
    adding: Definitions/artifact_types.json (deflated 69%)
    adding: Definitions/data_types.json (deflated 88%)
    adding: Definitions/node_types.json (deflated 90%)
    adding: Definitions/policy_types.json (stored 0%)
    adding: Definitions/relationship_types.json (stored 0%)
    adding: Definitions/resources_definition_types.json (deflated 94%)
    adding: Definitions/vFW_CNF_CDS.json (deflated 87%)
    adding: Scripts/ (stored 0%)
    adding: Scripts/kotlin/ (stored 0%)
    adding: Scripts/kotlin/README.md (stored 0%)
    adding: Templates/ (stored 0%)
    adding: Templates/base_template-mapping.json (deflated 89%)
    adding: Templates/base_template-template.vtl (deflated 87%)
    adding: Templates/k8s-profiles/ (stored 0%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-base-profile.tar.gz (stored 0%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/ (stored 0%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/manifest.yaml (deflated 35%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/override_values.yaml (stored 0%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/ssh-service-mapping.json (deflated 51%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/ssh-service-template.yaml.vtl (deflated 56%)
    adding: Templates/nf-params-mapping.json (deflated 88%)
    adding: Templates/nf-params-template.vtl (deflated 44%)
    adding: Templates/vfw-mapping.json (deflated 89%)
    adding: Templates/vfw-template.vtl (deflated 87%)
    adding: Templates/vnf-mapping.json (deflated 89%)
    adding: Templates/vnf-template.vtl (deflated 93%)
    adding: Templates/vpkg-mapping.json (deflated 89%)
    adding: Templates/vpkg-template.vtl (deflated 87%)
    adding: Templates/vsn-mapping.json (deflated 89%)
    adding: Templates/vsn-template.vtl (deflated 87%)
    adding: TOSCA-Metadata/ (stored 0%)
    adding: TOSCA-Metadata/TOSCA.meta (deflated 37%)
    cd cba/ && zip -r CBA.zip . -x pom.xml .idea/\* target/\*
    adding: Definitions/ (stored 0%)
    adding: Definitions/artifact_types.json (deflated 69%)
    adding: Definitions/data_types.json (deflated 88%)
    adding: Definitions/node_types.json (deflated 90%)
    adding: Definitions/policy_types.json (stored 0%)
    adding: Definitions/relationship_types.json (stored 0%)
    adding: Definitions/resources_definition_types.json (deflated 94%)
    adding: Definitions/vFW_CNF_CDS.json (deflated 87%)
    adding: Scripts/ (stored 0%)
    adding: Scripts/kotlin/ (stored 0%)
    adding: Scripts/kotlin/README.md (stored 0%)
    adding: Templates/ (stored 0%)
    adding: Templates/base_template-mapping.json (deflated 89%)
    adding: Templates/base_template-template.vtl (deflated 87%)
    adding: Templates/k8s-profiles/ (stored 0%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-base-profile.tar.gz (stored 0%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/ (stored 0%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/manifest.yaml (deflated 35%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/override_values.yaml (stored 0%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/ssh-service-mapping.json (deflated 51%)
    adding: Templates/k8s-profiles/vfw-cnf-cds-vpkg-profile/ssh-service-template.yaml.vtl (deflated 56%)
    adding: Templates/nf-params-mapping.json (deflated 88%)
    adding: Templates/nf-params-template.vtl (deflated 44%)
    adding: Templates/vfw-mapping.json (deflated 89%)
    adding: Templates/vfw-template.vtl (deflated 87%)
    adding: Templates/vnf-mapping.json (deflated 89%)
    adding: Templates/vnf-template.vtl (deflated 93%)
    adding: Templates/vpkg-mapping.json (deflated 89%)
    adding: Templates/vpkg-template.vtl (deflated 87%)
    adding: Templates/vsn-mapping.json (deflated 89%)
    adding: Templates/vsn-template.vtl (deflated 87%)
    adding: TOSCA-Metadata/ (stored 0%)
    adding: TOSCA-Metadata/TOSCA.meta (deflated 37%)
    mv cba/CBA.zip package_native/
    mv cba_dummy/CBA.zip package_dummy/
    cd package_dummy/ && zip -r vfw_k8s_demo.zip .
    adding: base_template.env (deflated 22%)
    adding: base_template.yaml (deflated 59%)
    adding: base_template_cloudtech_k8s_charts.tgz (stored 0%)
    adding: CBA.zip (stored 0%)
    adding: MANIFEST.json (deflated 84%)
    adding: vfw.env (deflated 23%)
    adding: vfw.yaml (deflated 60%)
    adding: vfw_cloudtech_k8s_charts.tgz (stored 0%)
    adding: vpkg.env (deflated 13%)
    adding: vpkg.yaml (deflated 59%)
    adding: vpkg_cloudtech_k8s_charts.tgz (stored 0%)
    adding: vsn.env (deflated 15%)
    adding: vsn.yaml (deflated 59%)
    adding: vsn_cloudtech_k8s_charts.tgz (stored 0%)
    cd package_native/ && zip -r native_vfw_k8s_demo.zip .
    adding: CBA.zip (stored 0%)
    adding: helm_base_template.tgz (stored 0%)
    adding: helm_vfw.tgz (stored 0%)
    adding: helm_vpkg.tgz (stored 0%)
    adding: helm_vsn.tgz (stored 0%)
    adding: MANIFEST.json (deflated 71%)
    mv package_dummy/vfw_k8s_demo.zip .
    mv package_native/native_vfw_k8s_demo.zip .
  $

Import this package into SDC and follow onboarding steps.

Service Creation with SDC
+++++++++++++++++++++++++

**<MANUAL>**

Service Creation in SDC is composed of the same steps that are performed by most other use-cases. For reference, you can relate to `vLB use-case`_

Onboard VSP

- Remember during VSP onboard to choose "Network Package" Onboarding procedure

Create VF and Service
Service -> Properties Assignment -> Choose VF (at right box):

- skip_post_instantiation_configuration - True
- sdnc_artifact_name - vnf
- sdnc_model_name - vFW_CNF_CDS
- sdnc_model_version - 7.0.0

**<AUTOMATED>**
.. note:: The onboarding packages for **Dummy Heat** and **Native Helm** path contain different CBA packages but with the same version and number. In consequence, when one VSP is distributed it replaces the CBA package of the other one and you can instantiate service only for the vFW CNF service service model distributed as a last one. If you want to instantiate vFW CNF service, make sure you have fresh distribution of vFW CNF service model.

::

    python onboarding.py

Distribution Of Service
+++++++++++++++++++++++

**<MANUAL>**

Distribute service.

Verify in SDC UI if distribution was successful. In case of any errors (sometimes SO fails on accepting CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT), try redistribution. You can also verify distribution for few components manually:

- SDC:

    SDC Catalog database should have our service now defined.

    ::

    Postman -> LCM -> [SDC] Catalog Service

    ::

                {
                        "uuid": "64dd38f3-2307-4e0a-bc98-5c2cbfb260b6",
                        "invariantUUID": "cd1a5c2d-2d4e-4d62-ac10-a5fe05e32a22",
                        "name": "vfw_cnf_cds_svc",
                        "version": "1.0",
                        "toscaModelURL": "/sdc/v1/catalog/services/64dd38f3-2307-4e0a-bc98-5c2cbfb260b6/toscaModel",
                        "category": "Network L4+",
                        "lifecycleState": "CERTIFIED",
                        "lastUpdaterUserId": "cs0008",
                        "distributionStatus": "DISTRIBUTED"
                }


    Listing should contain entry with our service name **vfw_cnf_cds_svc**.

.. note:: Note that it's an example name, it depends on how your model is named during Service design in SDC and must be kept in sync with Postman variables.

- SO:

    SO Catalog database should have our service NFs defined now.

    ::

        Postman -> LCM -> [SO] Catalog DB Service xNFs

    ::

                {
                    "serviceVnfs": [
                        {
                            "modelInfo": {
                                "modelName": "vfw_cnf_cds_vsp",
                                "modelUuid": "70edaca8-8c79-468a-aa76-8224cfe686d0",
                                "modelInvariantUuid": "7901fc89-a94d-434a-8454-1e27b99dc0e2",
                                "modelVersion": "1.0",
                                "modelCustomizationUuid": "86dc8af4-aa17-4fc7-9b20-f12160d99718",
                                "modelInstanceName": "vfw_cnf_cds_vsp 0"
                            },
                            "toscaNodeType": "org.openecomp.resource.vf.VfwCnfCdsVsp",
                            "nfFunction": null,
                            "nfType": null,
                            "nfRole": null,
                            "nfNamingCode": null,
                            "multiStageDesign": "false",
                            "vnfcInstGroupOrder": null,
                            "resourceInput": "TBD",
                            "vfModules": [
                                {
                                    "modelInfo": {
                                        "modelName": "VfwCnfCdsVsp..base_template..module-0",
                                        "modelUuid": "274f4bc9-7679-4767-b34d-1df51cdf2496",
                                        "modelInvariantUuid": "52842255-b7be-4a1c-ab3b-2bd3bd4a5423",
                                        "modelVersion": "1",
                                        "modelCustomizationUuid": "b27fad11-44da-4840-9256-7ed8a32fbe3e"
                                    },
                                    "isBase": true,
                                    "vfModuleLabel": "base_template",
                                    "initialCount": 1,
                                    "hasVolumeGroup": false
                                },
                                {
                                    "modelInfo": {
                                        "modelName": "VfwCnfCdsVsp..vsn..module-1",
                                        "modelUuid": "0cbf558f-5a96-4555-b476-7df8163521aa",
                                        "modelInvariantUuid": "36f25e1b-199b-4de2-b656-c870d341cf0e",
                                        "modelVersion": "1",
                                        "modelCustomizationUuid": "4cac0584-c0d6-42a7-bdb3-29162792e07f"
                                    },
                                    "isBase": false,
                                    "vfModuleLabel": "vsn",
                                    "initialCount": 0,
                                    "hasVolumeGroup": false
                                },
                                {
                                    "modelInfo": {
                                        "modelName": "VfwCnfCdsVsp..vpkg..module-2",
                                        "modelUuid": "011b5f61-6524-4789-bd9a-44cfbf321463",
                                        "modelInvariantUuid": "4e2b9975-5214-48b8-861a-5701c09eedfa",
                                        "modelVersion": "1",
                                        "modelCustomizationUuid": "4e7028a1-4c80-4d20-a7a2-a1fb3343d5cb"
                                    },
                                    "isBase": false,
                                    "vfModuleLabel": "vpkg",
                                    "initialCount": 0,
                                    "hasVolumeGroup": false
                                },
                                {
                                    "modelInfo": {
                                        "modelName": "VfwCnfCdsVsp..vfw..module-3",
                                        "modelUuid": "0de4ed56-8b4c-4a2d-8ce6-85d5e269204f",
                                        "modelInvariantUuid": "9ffda670-3d77-4f6c-a4ad-fb7a09f19817",
                                        "modelVersion": "1",
                                        "modelCustomizationUuid": "1e123e43-ba40-4c93-90d7-b9f27407ec03"
                                    },
                                    "isBase": false,
                                    "vfModuleLabel": "vfw",
                                    "initialCount": 0,
                                    "hasVolumeGroup": false
                                }
                            ],
                            "groups": []
                        }
                    ]
                }
.. note:: For **Native Helm** path both modelName will have prefix *helm_* i.e. *helm_vfw* and vfModuleLabel will have *helm_* keyword inside i.e. *VfwCnfCdsVsp..helm_vfw..module-3*

- SDNC:

    SDNC should have it's database updated with sdnc_* properties that were set during service modeling.

.. note:: Please change credentials respectively to your installation. The required credentials can be retrieved with instruction `Retrieving logins and passwords of ONAP components`_


::

    kubectl -n onap exec onap-mariadb-galera-0 -it -- sh
    mysql -uroot -psecretpassword -D sdnctl
            MariaDB [sdnctl]> select sdnc_model_name, sdnc_model_version, sdnc_artifact_name from VF_MODEL WHERE customization_uuid = '86dc8af4-aa17-4fc7-9b20-f12160d99718';
            +-----------------+--------------------+--------------------+
            | sdnc_model_name | sdnc_model_version | sdnc_artifact_name |
            +-----------------+--------------------+--------------------+
            | vFW_CNF_CDS     | 7.0.0              | vnf                |
            +-----------------+--------------------+--------------------+
            1 row in set (0.00 sec)


.. note:: customization_uuid value is the modelCustomizationUuid of the VNF (serviceVnfs response in 2nd Postman call from SO Catalog DB)

- CDS:

    CDS should onboard CBA uploaded as part of VF.

    ::

        Postman -> Distribution Verification -> [CDS] List CBAs

    ::

                [
                        {
                                "blueprintModel": {
                                        "id": "c505e516-b35d-4181-b1e2-bcba361cfd0a",
                                        "artifactUUId": null,
                                        "artifactType": "SDNC_MODEL",
                                        "artifactVersion": "7.0.0",
                                        "artifactDescription": "Controller Blueprint for vFW_CNF_CDS:7.0.0",
                                        "internalVersion": null,
                                        "createdDate": "2020-05-29T06:02:20.000Z",
                                        "artifactName": "vFW_CNF_CDS",
                                        "published": "N",
                                        "updatedBy": "Samuli Silvius <s.silvius@partner.samsung.com>",
                                        "tags": "Samuli Silvius, Lukasz Rajewski, vFW_CNF_CDS"
                                }
                        }
                ]

    The list should have the matching entries with SDNC database:

    - sdnc_model_name == artifactName
    - sdnc_model_version == artifactVersion

    You can also use Postman to download CBA for further verification but it's fully optional.

    ::

        Postman -> Distribution Verification -> [CDS] CBA Download

- K8splugin:

    K8splugin should onboard 4 resource bundles related to helm resources:

    ::

        Postman -> Distribution Verification -> [K8splugin] List Resource Bundle Definitions

    ::

                [
                        {
                                "rb-name": "52842255-b7be-4a1c-ab3b-2bd3bd4a5423",
                                "rb-version": "274f4bc9-7679-4767-b34d-1df51cdf2496",
                                "chart-name": "base_template",
                                "description": "",
                                "labels": {
                                        "vnf_customization_uuid": "b27fad11-44da-4840-9256-7ed8a32fbe3e"
                                }
                        },
                        {
                                "rb-name": "36f25e1b-199b-4de2-b656-c870d341cf0e",
                                "rb-version": "0cbf558f-5a96-4555-b476-7df8163521aa",
                                "chart-name": "vsn",
                                "description": "",
                                "labels": {
                                        "vnf_customization_uuid": "4cac0584-c0d6-42a7-bdb3-29162792e07f"
                                }
                        },
                        {
                                "rb-name": "4e2b9975-5214-48b8-861a-5701c09eedfa",
                                "rb-version": "011b5f61-6524-4789-bd9a-44cfbf321463",
                                "chart-name": "vpkg",
                                "description": "",
                                "labels": {
                                        "vnf_customization_uuid": "4e7028a1-4c80-4d20-a7a2-a1fb3343d5cb"
                                }
                        },
                        {
                                "rb-name": "9ffda670-3d77-4f6c-a4ad-fb7a09f19817",
                                "rb-version": "0de4ed56-8b4c-4a2d-8ce6-85d5e269204f",
                                "chart-name": "vfw",
                                "description": "",
                                "labels": {
                                        "vnf_customization_uuid": "1e123e43-ba40-4c93-90d7-b9f27407ec03"
                                }
                        }
                ]

**<AUTOMATED>**

Distribution is a part of the onboarding step and at this stage is performed

3-2 CNF Instantiation
.....................

This is the whole beef of the use case and furthermore the core of it is that we can instantiate any amount of instances of the same CNF each running and working completely of their own. Very basic functionality in VM (VNF) side but for Kubernetes and ONAP integration this is the first milestone towards other normal use cases familiar for VNFs.

**<MANUAL>**

Postman collection is automated to populate needed parameters when queries are run in correct order. If you did not already run following 2 queries after distribution (to verify distribution), run those now:

::

    Postman -> LCM -> 1.[SDC] Catalog Service

::

    Postman -> LCM -> 2. [SO] Catalog DB Service xNFs

Now actual instantiation can be triggered with:

::

    Postman -> LCM -> 3. [SO] Self-Serve Service Assign & Activate

**<AUTOMATED>**

Required inputs for instantiation process are taken from the *config.py* file.
::

    python instantiation.py


Finally, to follow the progress of instantiation request with SO's GET request:

**<MANUAL>**

::

    Postman -> LCM -> 4. [SO] Infra Active Requests

The successful reply payload in that query should start like this:

::

    {
      "requestStatus": "COMPLETE",
      "statusMessage": "Macro-Service-createInstance request was executed correctly.",
      "flowStatus": "Successfully completed all Building Blocks",
      "progress": 100,
      "startTime": 1590996766000,
      "endTime": 1590996945000,
      "source": "Postman",
      "vnfId": "93b3350d-ed6f-413b-9cc5-a158c1676eb0",
      "tenantId": "aaaa",
      "requestBody": "**REDACTED FOR READABILITY**",
      "lastModifiedBy": "CamundaBPMN",
      "modifyTime": "2020-06-01T07:35:45.000+0000",
      "cloudRegion": "k8sregionfour",
      "serviceInstanceId": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72",
      "serviceInstanceName": "vfw-cnf-16",
      "requestScope": "service",
      "requestAction": "createInstance",
      "requestorId": "11c2ddb7-4659-4bf0-a685-a08dcbb5a099",
      "requestUrl": "http://infra:30277/onap/so/infra/serviceInstantiation/v7/serviceInstances",
      "tenantName": "k8stenant",
      "cloudApiRequests": [],
      "requestURI": "6a369c8e-d492-4ab5-a107-46804eeb7873",
      "_links": {
        "self": {
          "href": "http://infra:30277/infraActiveRequests/6a369c8e-d492-4ab5-a107-46804eeb7873"
        },
        "infraActiveRequests": {
          "href": "http://infra:30277/infraActiveRequests/6a369c8e-d492-4ab5-a107-46804eeb7873"
        }
      }
    }


Progress can be also followed also with `SO Monitoring`_ dashboard.

Service Instance Termination
++++++++++++++++++++++++++++

Service instance can be terminated with the following postman call:

**<MANUAL>**
::

    Postman -> LCM -> 5. [SO] Service Delete

**<AUTOMATED>**
::

    python delete.py

.. note:: Automated service deletion mecvhanism takes information about the instantiated service instance from the *config.py* file and *SERVICE_INSTANCE_NAME* variable. If you modify this value before the deletion of existing service instance then you will loose opportunity to easy delete already created service instance.

Second Service Instance Instantiation
+++++++++++++++++++++++++++++++++++++

To finally verify that all the work done within this demo, it should be possible to instantiate second vFW instance successfully.

Trigger new instance createion. You can use previous call or a separate one that will utilize profile templating mechanism implemented in CBA:

**<MANUAL>**
::

    Postman -> LCM -> 6. [SO] Self-Serve Service Assign & Activate - Second

**<AUTOMATED>**

Before second instance of service is created you need to modify *config.py* file changing the *SERVICENAME* and *SERVICE_INSTANCE_NAME* to different values and by changing the value or *k8s-rb-profile-name* parameter for *vpg* module from value *default* or *vfw-cnf-cds-base-profile* to *vfw-cnf-cds-vpkg-profile* what will result with instantiation of additional ssh service for *vpg* module. Second onboarding in automated case is required due to the existing limitations of *python-sdk* librarier that create vf-module instance name base on the vf-module model name. For manual Postman option vf-module instance name is set on service instance name basis what makes it unique.
::

    python onboarding.py
    python instantiation.py

3-3 Results and Logs
....................

Now multiple instances of Kubernetes variant of vFW are running in target VIM (KUD deployment).

.. figure:: files/vFW_CNF_CDS/vFW_Instance_In_Kubernetes.png
   :align: center

   vFW Instance In Kubernetes

**<MANUAL>**

To review situation after instantiation from different ONAP components, most of the info can be found using Postman queries provided. For each query, example response payload(s) is/are saved and can be found from top right corner of the Postman window.

::

    Postman -> Instantiation verification**

Execute example Postman queries and check example section to see the valid results.

==========================    =================
Verify Target                 Postman query
--------------------------    -----------------
Service Instances in AAI      **Postman -> Instantiation verification -> [AAI] List Service Instances**
Service Instances in MDSAL    **Postman -> Instantiation verification -> [SDNC] GR-API MD-SAL Services**
K8S Instances in KUD          **Postman -> Instantiation verification -> [K8splugin] List Instances**
==========================    =================

.. note:: "[AAI] List vServers <Empty>" Request won't return any vserver info from AAI, as currently such information are not provided during instantiation process.


Query also directly from VIM:

::

    #
    ubuntu@kud-host:~$ kubectl get pods,svc,networks,cm,network-attachment-definition,deployments
    NAME                                                            READY   STATUS    RESTARTS   AGE
    pod/vfw-17f6f7d3-8424-4550-a188-cd777f0ab48f-7cfb9949d9-8b5vg   1/1     Running   0          22s
    pod/vfw-19571429-4af4-49b3-af65-2eb1f97bba43-75cd7c6f76-4gqtz   1/1     Running   0          11m
    pod/vpg-5ea0d3b0-9a0c-4e88-a2e2-ceb84810259e-f4485d485-pln8m    1/1     Running   0          11m
    pod/vpg-8581bc79-8eef-487e-8ed1-a18c0d638b26-6f8cff54d-dvw4j    1/1     Running   0          32s
    pod/vsn-8e7ac4fc-2c31-4cf8-90c8-5074c5891c14-5879c56fd-q59l7    2/2     Running   0          11m
    pod/vsn-fdc9b4ba-c0e9-4efc-8009-f9414ae7dd7b-5889b7455-96j9d    2/2     Running   0          30s

    NAME                                                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
    service/vpg-5ea0d3b0-9a0c-4e88-a2e2-ceb84810259e-management-api   NodePort    10.244.43.245   <none>        2831:30831/TCP   11m
    service/vpg-8581bc79-8eef-487e-8ed1-a18c0d638b26-management-api   NodePort    10.244.1.45     <none>        2831:31831/TCP   33s
    service/vsn-8e7ac4fc-2c31-4cf8-90c8-5074c5891c14-darkstat-ui      NodePort    10.244.16.187   <none>        667:30667/TCP    11m
    service/vsn-fdc9b4ba-c0e9-4efc-8009-f9414ae7dd7b-darkstat-ui      NodePort    10.244.20.229   <none>        667:31667/TCP    30s

    NAME                                                                                    AGE
    network.k8s.plugin.opnfv.org/55118b80-8470-4c99-bfdf-d122cd412739-management-network    40s
    network.k8s.plugin.opnfv.org/55118b80-8470-4c99-bfdf-d122cd412739-protected-network     40s
    network.k8s.plugin.opnfv.org/55118b80-8470-4c99-bfdf-d122cd412739-unprotected-network   40s
    network.k8s.plugin.opnfv.org/567cecc3-9692-449e-877a-ff0b560736be-management-network    11m
    network.k8s.plugin.opnfv.org/567cecc3-9692-449e-877a-ff0b560736be-protected-network     11m
    network.k8s.plugin.opnfv.org/567cecc3-9692-449e-877a-ff0b560736be-unprotected-network   11m

    NAME                                                           DATA   AGE
    configmap/vfw-17f6f7d3-8424-4550-a188-cd777f0ab48f-configmap   6      22s
    configmap/vfw-19571429-4af4-49b3-af65-2eb1f97bba43-configmap   6      11m
    configmap/vpg-5ea0d3b0-9a0c-4e88-a2e2-ceb84810259e-configmap   6      11m
    configmap/vpg-8581bc79-8eef-487e-8ed1-a18c0d638b26-configmap   6      33s
    configmap/vsn-8e7ac4fc-2c31-4cf8-90c8-5074c5891c14-configmap   2      11m
    configmap/vsn-fdc9b4ba-c0e9-4efc-8009-f9414ae7dd7b-configmap   2      30s

    NAME                                                                                       AGE
    networkattachmentdefinition.k8s.cni.cncf.io/55118b80-8470-4c99-bfdf-d122cd412739-ovn-nat   40s
    networkattachmentdefinition.k8s.cni.cncf.io/567cecc3-9692-449e-877a-ff0b560736be-ovn-nat   11m

    NAME                                                             READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.extensions/vfw-17f6f7d3-8424-4550-a188-cd777f0ab48f   1/1     1            1           22s
    deployment.extensions/vfw-19571429-4af4-49b3-af65-2eb1f97bba43   1/1     1            1           11m
    deployment.extensions/vpg-5ea0d3b0-9a0c-4e88-a2e2-ceb84810259e   1/1     1            1           11m
    deployment.extensions/vpg-8581bc79-8eef-487e-8ed1-a18c0d638b26   1/1     1            1           33s
    deployment.extensions/vsn-8e7ac4fc-2c31-4cf8-90c8-5074c5891c14   1/1     1            1           11m
    deployment.extensions/vsn-fdc9b4ba-c0e9-4efc-8009-f9414ae7dd7b   1/1     1            1           30s


Component Logs From The Execution
+++++++++++++++++++++++++++++++++

**<MANUAL>**

All logs from the use case execution can be retrieved with following

::

    kubectl -n onap logs `kubectl -n onap get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep -m1 <COMPONENT_NAME>` -c <CONTAINER>

where <COMPONENT_NAME> and <CONTAINER> should be replaced with following keywords respectively:

- so-bpmn-infra, so-bpmn-infra
- so-openstack-adapter, so-openstack-adapter
- so-cnf-adapter, so-cnf-adapter
- sdnc-0, sdnc

  From karaf.log all requests (payloads) to CDS can be found by searching following string:

  ``'Sending request below to url http://cds-blueprints-processor-http:8080/api/v1/execution-service/process'``

- cds-blueprints-processor, cds-blueprints-processor
- multicloud-k8s, multicloud-k8s
- network-name-gen, network-name-gen, 

**Debug log**

In case more detailed logging is needed, here's instructions how to setup DEBUG logging for few components.

- SDNC

  ::

    kubectl -n onap exec -it onap-sdnc-0 -c sdnc /opt/opendaylight/bin/client log:set DEBUG


- CDS Blueprint Processor

  ::

    # Edit configmap
    kubectl -n onap edit configmap onap-cds-blueprints-processor-configmap

    # Edit logback.xml content change root logger level from info to debug.
    <root level="debug">
        <appender-ref ref="STDOUT"/>
    </root>

    # Delete the Pods to make changes effective
    kubectl -n onap delete pods -l app=cds-blueprints-processor

3-4 Verification of the CNF Status
..................................

**<MANUAL>**

The Guilin introduces new API for verification of the status of instantiated resouces in k8s cluster. The API gives result similar to *kubectl describe* operation for all the resources created for particular *rb-definition*. Status API can be used to verify the k8s resources after instantiation but also can be used leveraged for synchronization of the information with external components, like AAI in the future. To use Status API call

::

    curl -i http://${K8S_NODE_IP}:30280/api/multicloud-k8s/v1/v1/instance/{rb-instance-id}/status

where {rb-instance-id} can be taken from the list of instances resolved the following call

::

    curl -i http://${K8S_NODE_IP}:30280/api/multicloud-k8s/v1/v1/instance/

or from AAI *heat-stack-id* property of created *vf-module* associated with each Helm package from onboarded VSP which holds the *rb-instance-id* value.

Examplary output of Status API is shown below (result of test vFW CNF helm package). It shows the list of GVK resources created for requested *rb-instance* (Helm and vf-module in the same time) with assocated describe result for all of them.

.. note:: The example of how the Stauts API could be integrated into CDS can be found in the Frankfurt version of k8s profile upload mechanism `Frankfurt CBA Definition`_ (*profile-upload* TOSCA node template), implemented in inside of the Kotlin script `Frankfurt CBA Script`_ for profile upload. This method shows how to integrate mutlicloud-k8s API endpoint into Kotlin script executed by CDS. For more details please take a look into Definition file of 1.0.45 version of the CBA and also the kotlin script used there for uploading the profile. 

::

    {
        "request": {
            "rb-name": "vfw",
            "rb-version": "plugin_test",
            "profile-name": "test_profile",
            "release-name": "",
            "cloud-region": "kud",
            "labels": {
                "testCaseName": "plugin_fw.sh"
            },
            "override-values": {
                "global.onapPrivateNetworkName": "onap-private-net-test"
            }
        },
        "ready": false,
        "resourceCount": 7,
        "resourcesStatus": [
            {
                "name": "sink-configmap",
                "GVK": {
                    "Group": "",
                    "Version": "v1",
                    "Kind": "ConfigMap"
                },
                "status": {
                    "apiVersion": "v1",
                    "data": {
                        "protected_net_gw": "192.168.20.100",
                        "protected_private_net_cidr": "192.168.10.0/24"
                    },
                    "kind": "ConfigMap",
                    "metadata": {
                        "creationTimestamp": "2020-09-29T13:36:25Z",
                        "labels": {
                            "k8splugin.io/rb-instance-id": "practical_nobel"
                        },
                        "name": "sink-configmap",
                        "namespace": "plugin-tests-namespace",
                        "resourceVersion": "10720771",
                        "selfLink": "/api/v1/namespaces/plugin-tests-namespace/configmaps/sink-configmap",
                        "uid": "46c8bec4-980c-455b-9eb0-fb84ac8cc450"
                    }
                }
            },
            {
                "name": "sink-service",
                "GVK": {
                    "Group": "",
                    "Version": "v1",
                    "Kind": "Service"
                },
                "status": {
                    "apiVersion": "v1",
                    "kind": "Service",
                    "metadata": {
                        "creationTimestamp": "2020-09-29T13:36:25Z",
                        "labels": {
                            "app": "sink",
                            "chart": "sink",
                            "k8splugin.io/rb-instance-id": "practical_nobel",
                            "release": "test-release"
                        },
                        "name": "sink-service",
                        "namespace": "plugin-tests-namespace",
                        "resourceVersion": "10720780",
                        "selfLink": "/api/v1/namespaces/plugin-tests-namespace/services/sink-service",
                        "uid": "789a14fe-1246-4cdd-ba9a-359240ba614f"
                    },
                    "spec": {
                        "clusterIP": "10.244.2.4",
                        "externalTrafficPolicy": "Cluster",
                        "ports": [
                            {
                                "nodePort": 30667,
                                "port": 667,
                                "protocol": "TCP",
                                "targetPort": 667
                            }
                        ],
                        "selector": {
                            "app": "sink",
                            "release": "test-release"
                        },
                        "sessionAffinity": "None",
                        "type": "NodePort"
                    },
                    "status": {
                        "loadBalancer": {}
                    }
                }
            },
            {
                "name": "test-release-sink",
                "GVK": {
                    "Group": "apps",
                    "Version": "v1",
                    "Kind": "Deployment"
                },
                "status": {
                    "apiVersion": "apps/v1",
                    "kind": "Deployment",
                    "metadata": {
                        "annotations": {
                            "deployment.kubernetes.io/revision": "1"
                        },
                        "creationTimestamp": "2020-09-29T13:36:25Z",
                        "generation": 1,
                        "labels": {
                            "app": "sink",
                            "chart": "sink",
                            "k8splugin.io/rb-instance-id": "practical_nobel",
                            "release": "test-release"
                        },
                        "name": "test-release-sink",
                        "namespace": "plugin-tests-namespace",
                        "resourceVersion": "10720857",
                        "selfLink": "/apis/apps/v1/namespaces/plugin-tests-namespace/deployments/test-release-sink",
                        "uid": "1f50eecf-c924-4434-be87-daf7c64b6506"
                    },
                    "spec": {
                        "progressDeadlineSeconds": 600,
                        "replicas": 1,
                        "revisionHistoryLimit": 10,
                        "selector": {
                            "matchLabels": {
                                "app": "sink",
                                "release": "test-release"
                            }
                        },
                        "strategy": {
                            "rollingUpdate": {
                                "maxSurge": "25%",
                                "maxUnavailable": "25%"
                            },
                            "type": "RollingUpdate"
                        },
                        "template": {
                            "metadata": {
                                "annotations": {
                                    "k8s.plugin.opnfv.org/nfn-network": "{ \"type\": \"ovn4nfv\", \"interface\": [ { \"name\": \"protected-private-net\", \"ipAddress\": \"192.168.20.3\", \"interface\": \"eth1\", \"defaultGateway\": \"false\" }, { \"name\": \"onap-private-net-test\", \"ipAddress\": \"10.10.100.4\", \"interface\": \"eth2\" , \"defaultGateway\": \"false\"} ]}",
                                    "k8s.v1.cni.cncf.io/networks": "[{\"name\": \"ovn-networkobj\", \"namespace\": \"default\"}]"
                                },
                                "creationTimestamp": null,
                                "labels": {
                                    "app": "sink",
                                    "k8splugin.io/rb-instance-id": "practical_nobel",
                                    "release": "test-release"
                                }
                            },
                            "spec": {
                                "containers": [
                                    {
                                        "envFrom": [
                                            {
                                                "configMapRef": {
                                                    "name": "sink-configmap"
                                                }
                                            }
                                        ],
                                        "image": "rtsood/onap-vfw-demo-sink:0.2.0",
                                        "imagePullPolicy": "IfNotPresent",
                                        "name": "sink",
                                        "resources": {},
                                        "securityContext": {
                                            "privileged": true
                                        },
                                        "stdin": true,
                                        "terminationMessagePath": "/dev/termination-log",
                                        "terminationMessagePolicy": "File",
                                        "tty": true
                                    },
                                    {
                                        "image": "electrocucaracha/darkstat:latest",
                                        "imagePullPolicy": "IfNotPresent",
                                        "name": "darkstat",
                                        "ports": [
                                            {
                                                "containerPort": 667,
                                                "protocol": "TCP"
                                            }
                                        ],
                                        "resources": {},
                                        "stdin": true,
                                        "terminationMessagePath": "/dev/termination-log",
                                        "terminationMessagePolicy": "File",
                                        "tty": true
                                    }
                                ],
                                "dnsPolicy": "ClusterFirst",
                                "restartPolicy": "Always",
                                "schedulerName": "default-scheduler",
                                "securityContext": {},
                                "terminationGracePeriodSeconds": 30
                            }
                        }
                    },
                    "status": {
                        "availableReplicas": 1,
                        "conditions": [
                            {
                                "lastTransitionTime": "2020-09-29T13:36:33Z",
                                "lastUpdateTime": "2020-09-29T13:36:33Z",
                                "message": "Deployment has minimum availability.",
                                "reason": "MinimumReplicasAvailable",
                                "status": "True",
                                "type": "Available"
                            },
                            {
                                "lastTransitionTime": "2020-09-29T13:36:25Z",
                                "lastUpdateTime": "2020-09-29T13:36:33Z",
                                "message": "ReplicaSet \"test-release-sink-6546c4f698\" has successfully progressed.",
                                "reason": "NewReplicaSetAvailable",
                                "status": "True",
                                "type": "Progressing"
                            }
                        ],
                        "observedGeneration": 1,
                        "readyReplicas": 1,
                        "replicas": 1,
                        "updatedReplicas": 1
                    }
                }
            },
            {
                "name": "onap-private-net-test",
                "GVK": {
                    "Group": "k8s.plugin.opnfv.org",
                    "Version": "v1alpha1",
                    "Kind": "Network"
                },
                "status": {
                    "apiVersion": "k8s.plugin.opnfv.org/v1alpha1",
                    "kind": "Network",
                    "metadata": {
                        "creationTimestamp": "2020-09-29T13:36:25Z",
                        "finalizers": [
                            "nfnCleanUpNetwork"
                        ],
                        "generation": 2,
                        "labels": {
                            "k8splugin.io/rb-instance-id": "practical_nobel"
                        },
                        "name": "onap-private-net-test",
                        "namespace": "plugin-tests-namespace",
                        "resourceVersion": "10720825",
                        "selfLink": "/apis/k8s.plugin.opnfv.org/v1alpha1/namespaces/plugin-tests-namespace/networks/onap-private-net-test",
                        "uid": "43d413f1-f222-4d98-9ddd-b209d3ade106"
                    },
                    "spec": {
                        "cniType": "ovn4nfv",
                        "dns": {},
                        "ipv4Subnets": [
                            {
                                "gateway": "10.10.0.1/16",
                                "name": "subnet1",
                                "subnet": "10.10.0.0/16"
                            }
                        ]
                    },
                    "status": {
                        "state": "Created"
                    }
                }
            },
            {
                "name": "protected-private-net",
                "GVK": {
                    "Group": "k8s.plugin.opnfv.org",
                    "Version": "v1alpha1",
                    "Kind": "Network"
                },
                "status": {
                    "apiVersion": "k8s.plugin.opnfv.org/v1alpha1",
                    "kind": "Network",
                    "metadata": {
                        "creationTimestamp": "2020-09-29T13:36:25Z",
                        "finalizers": [
                            "nfnCleanUpNetwork"
                        ],
                        "generation": 2,
                        "labels": {
                            "k8splugin.io/rb-instance-id": "practical_nobel"
                        },
                        "name": "protected-private-net",
                        "namespace": "plugin-tests-namespace",
                        "resourceVersion": "10720827",
                        "selfLink": "/apis/k8s.plugin.opnfv.org/v1alpha1/namespaces/plugin-tests-namespace/networks/protected-private-net",
                        "uid": "75c98944-80b6-4158-afed-8efa7a1075e2"
                    },
                    "spec": {
                        "cniType": "ovn4nfv",
                        "dns": {},
                        "ipv4Subnets": [
                            {
                                "gateway": "192.168.20.100/24",
                                "name": "subnet1",
                                "subnet": "192.168.20.0/24"
                            }
                        ]
                    },
                    "status": {
                        "state": "Created"
                    }
                }
            },
            {
                "name": "unprotected-private-net",
                "GVK": {
                    "Group": "k8s.plugin.opnfv.org",
                    "Version": "v1alpha1",
                    "Kind": "Network"
                },
                "status": {
                    "apiVersion": "k8s.plugin.opnfv.org/v1alpha1",
                    "kind": "Network",
                    "metadata": {
                        "creationTimestamp": "2020-09-29T13:36:25Z",
                        "finalizers": [
                            "nfnCleanUpNetwork"
                        ],
                        "generation": 2,
                        "labels": {
                            "k8splugin.io/rb-instance-id": "practical_nobel"
                        },
                        "name": "unprotected-private-net",
                        "namespace": "plugin-tests-namespace",
                        "resourceVersion": "10720829",
                        "selfLink": "/apis/k8s.plugin.opnfv.org/v1alpha1/namespaces/plugin-tests-namespace/networks/unprotected-private-net",
                        "uid": "54995c10-bffd-4bb2-bbab-5de266af9456"
                    },
                    "spec": {
                        "cniType": "ovn4nfv",
                        "dns": {},
                        "ipv4Subnets": [
                            {
                                "gateway": "192.168.10.1/24",
                                "name": "subnet1",
                                "subnet": "192.168.10.0/24"
                            }
                        ]
                    },
                    "status": {
                        "state": "Created"
                    }
                }
            },
            {
                "name": "test-release-sink-6546c4f698-dv529",
                "GVK": {
                    "Group": "",
                    "Version": "v1",
                    "Kind": "Pod"
                },
                "status": {
                    "metadata": {
                        "annotations": {
                            "k8s.plugin.opnfv.org/nfn-network": "{ \"type\": \"ovn4nfv\", \"interface\": [ { \"name\": \"protected-private-net\", \"ipAddress\": \"192.168.20.3\", \"interface\": \"eth1\", \"defaultGateway\": \"false\" }, { \"name\": \"onap-private-net-test\", \"ipAddress\": \"10.10.100.4\", \"interface\": \"eth2\" , \"defaultGateway\": \"false\"} ]}",
                            "k8s.plugin.opnfv.org/ovnInterfaces": "[{\"ip_address\":\"192.168.20.3/24\", \"mac_address\":\"00:00:00:13:40:87\", \"gateway_ip\": \"192.168.20.100\",\"defaultGateway\":\"false\",\"interface\":\"eth1\"},{\"ip_address\":\"10.10.100.4/16\", \"mac_address\":\"00:00:00:49:de:fc\", \"gateway_ip\": \"10.10.0.1\",\"defaultGateway\":\"false\",\"interface\":\"eth2\"}]",
                            "k8s.v1.cni.cncf.io/networks": "[{\"name\": \"ovn-networkobj\", \"namespace\": \"default\"}]",
                            "k8s.v1.cni.cncf.io/networks-status": "[{\n    \"name\": \"cni0\",\n    \"interface\": \"eth0\",\n    \"ips\": [\n        \"10.244.64.46\"\n    ],\n    \"mac\": \"0a:58:0a:f4:40:2e\",\n    \"default\": true,\n    \"dns\": {}\n},{\n    \"name\": \"ovn4nfv-k8s-plugin\",\n    \"interface\": \"eth2\",\n    \"ips\": [\n        \"192.168.20.3\",\n        \"10.10.100.4\"\n    ],\n    \"mac\": \"00:00:00:49:de:fc\",\n    \"dns\": {}\n}]"
                        },
                        "creationTimestamp": "2020-09-29T13:36:25Z",
                        "generateName": "test-release-sink-6546c4f698-",
                        "labels": {
                            "app": "sink",
                            "k8splugin.io/rb-instance-id": "practical_nobel",
                            "pod-template-hash": "6546c4f698",
                            "release": "test-release"
                        },
                        "name": "test-release-sink-6546c4f698-dv529",
                        "namespace": "plugin-tests-namespace",
                        "ownerReferences": [
                            {
                                "apiVersion": "apps/v1",
                                "blockOwnerDeletion": true,
                                "controller": true,
                                "kind": "ReplicaSet",
                                "name": "test-release-sink-6546c4f698",
                                "uid": "72c9da29-af3b-4b5c-a90b-06285ae83429"
                            }
                        ],
                        "resourceVersion": "10720854",
                        "selfLink": "/api/v1/namespaces/plugin-tests-namespace/pods/test-release-sink-6546c4f698-dv529",
                        "uid": "a4e24041-65c9-4b86-8f10-a27a4dba26bb"
                    },
                    "spec": {
                        "containers": [
                            {
                                "envFrom": [
                                    {
                                        "configMapRef": {
                                            "name": "sink-configmap"
                                        }
                                    }
                                ],
                                "image": "rtsood/onap-vfw-demo-sink:0.2.0",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "sink",
                                "resources": {},
                                "securityContext": {
                                    "privileged": true
                                },
                                "stdin": true,
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "tty": true,
                                "volumeMounts": [
                                    {
                                        "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                                        "name": "default-token-gsh95",
                                        "readOnly": true
                                    }
                                ]
                            },
                            {
                                "image": "electrocucaracha/darkstat:latest",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "darkstat",
                                "ports": [
                                    {
                                        "containerPort": 667,
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {},
                                "stdin": true,
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "tty": true,
                                "volumeMounts": [
                                    {
                                        "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                                        "name": "default-token-gsh95",
                                        "readOnly": true
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "enableServiceLinks": true,
                        "nodeName": "localhost",
                        "priority": 0,
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "serviceAccount": "default",
                        "serviceAccountName": "default",
                        "terminationGracePeriodSeconds": 30,
                        "tolerations": [
                            {
                                "effect": "NoExecute",
                                "key": "node.kubernetes.io/not-ready",
                                "operator": "Exists",
                                "tolerationSeconds": 300
                            },
                            {
                                "effect": "NoExecute",
                                "key": "node.kubernetes.io/unreachable",
                                "operator": "Exists",
                                "tolerationSeconds": 300
                            }
                        ],
                        "volumes": [
                            {
                                "name": "default-token-gsh95",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "default-token-gsh95"
                                }
                            }
                        ]
                    },
                    "status": {
                        "conditions": [
                            {
                                "lastProbeTime": null,
                                "lastTransitionTime": "2020-09-29T13:36:25Z",
                                "status": "True",
                                "type": "Initialized"
                            },
                            {
                                "lastProbeTime": null,
                                "lastTransitionTime": "2020-09-29T13:36:33Z",
                                "status": "True",
                                "type": "Ready"
                            },
                            {
                                "lastProbeTime": null,
                                "lastTransitionTime": "2020-09-29T13:36:33Z",
                                "status": "True",
                                "type": "ContainersReady"
                            },
                            {
                                "lastProbeTime": null,
                                "lastTransitionTime": "2020-09-29T13:36:25Z",
                                "status": "True",
                                "type": "PodScheduled"
                            }
                        ],
                        "containerStatuses": [
                            {
                                "containerID": "docker://87c9af78735400606d70ccd9cd85e2545e43cb3be9c30d4b4fe173da0062dda9",
                                "image": "electrocucaracha/darkstat:latest",
                                "imageID": "docker-pullable://electrocucaracha/darkstat@sha256:a6764fcc2e15f6156ac0e56f1d220b98970f2d4da9005bae99fb518cfd2f9c25",
                                "lastState": {},
                                "name": "darkstat",
                                "ready": true,
                                "restartCount": 0,
                                "started": true,
                                "state": {
                                    "running": {
                                        "startedAt": "2020-09-29T13:36:33Z"
                                    }
                                }
                            },
                            {
                                "containerID": "docker://a004f95e7c7a681c7f400852aade096e3ffd75b7efc64e12e65b4ce1fe326577",
                                "image": "rtsood/onap-vfw-demo-sink:0.2.0",
                                "imageID": "docker-pullable://rtsood/onap-vfw-demo-sink@sha256:15b7abb0b67a3804ea5f954254633f996fc99c680b09d86a6cf15c3d7b14ab16",
                                "lastState": {},
                                "name": "sink",
                                "ready": true,
                                "restartCount": 0,
                                "started": true,
                                "state": {
                                    "running": {
                                        "startedAt": "2020-09-29T13:36:32Z"
                                    }
                                }
                            }
                        ],
                        "hostIP": "192.168.255.3",
                        "phase": "Running",
                        "podIP": "10.244.64.46",
                        "podIPs": [
                            {
                                "ip": "10.244.64.46"
                            }
                        ],
                        "qosClass": "BestEffort",
                        "startTime": "2020-09-29T13:36:25Z"
                    }
                }
            }
        ]
    }

PART 4 - Future improvements needed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Future development areas for this use case:

- Automated smoke use case.
- Include Closed Loop part of the vFW demo.
- vFW service with Openstack VNF and Kubernetes CNF

Future development areas for CNF support:

- Validation of Helm package and extraction of override values in time of the package onboarding.
- Post instantiation configuration with Day 2 configuration APIs of multicloud/k8S API.
- Synchroinzation of information about CNF between AAI and K8s.
- Validation of status and health of CNF.
- Use multicloud/k8S API v2.

Many features from the list above are covered by the Honolulu roadmap described in `REQ-458`_. 


.. _ONAP Deployment Guide: https://docs.onap.org/projects/onap-oom/en/guilin/oom_quickstart_guide.html
.. _CDS Documentation: https://docs.onap.org/projects/onap-ccsdk-cds/en/guilin/index.html
.. _vLB use-case: https://wiki.onap.org/pages/viewpage.action?pageId=71838898
.. _vFW_CNF_CDS Model: https://git.onap.org/demo/tree/heat/vFW_CNF_CDS/templates?h=guilin
.. _vFW_CNF_CDS Automation: https://git.onap.org/demo/tree/heat/vFW_CNF_CDS/automation?h=guilin
.. _vFW CDS Dublin: https://wiki.onap.org/display/DW/vFW+CDS+Dublin
.. _vFW CBA Model: https://git.onap.org/ccsdk/cds/tree/components/model-catalog/blueprint-model/service-blueprint/vFW?h=elalto
.. _vFW_Helm Model: https://git.onap.org/multicloud/k8s/tree/kud/demo/firewall?h=elalto
.. _vFW_NextGen: https://git.onap.org/demo/tree/heat/vFW_NextGen?h=elalto
.. _vFW EDGEX K8S: https://docs.onap.org/en/elalto/submodules/integration.git/docs/docs_vfw_edgex_k8s.html
.. _vFW EDGEX K8S In ONAP Wiki: https://wiki.onap.org/display/DW/Deploying+vFw+and+EdgeXFoundry+Services+on+Kubernets+Cluster+with+ONAP
.. _KUD github: https://github.com/onap/multicloud-k8s/tree/master/kud/hosting_providers/baremetal
.. _KUD in Wiki: https://wiki.onap.org/display/DW/Kubernetes+Baremetal+deployment+setup+instructions
.. _Multicloud k8s gerrit: https://gerrit.onap.org/r/q/status:open+project:+multicloud/k8s
.. _KUD subproject in github: https://github.com/onap/multicloud-k8s/tree/master/kud
.. _Frankfurt CBA Definition: https://git.onap.org/demo/tree/heat/vFW_CNF_CDS/templates/cba/Definitions/vFW_CNF_CDS.json?h=frankfurt
.. _Frankfurt CBA Script: https://git.onap.org/demo/tree/heat/vFW_CNF_CDS/templates/cba/Scripts/kotlin/KotlinK8sProfileUpload.kt?h=frankfurt
.. _SO-3403: https://jira.onap.org/browse/SO-3403
.. _SO-3404: https://jira.onap.org/browse/SO-3404
.. _REQ-182: https://jira.onap.org/browse/REQ-182
.. _REQ-341: https://jira.onap.org/browse/REQ-341
.. _REQ-458: https://jira.onap.org/browse/REQ-458
.. _Python SDK: https://docs.onap.org/projects/onap-integration/en/guilin/integration-tooling.html?highlight=python-sdk#python-onapsdk
.. _KUD Jenkins ci/cd verification: https://jenkins.onap.org/job/multicloud-k8s-master-kud-deployment-verify-shell/
.. _K8s cloud site config: https://docs.onap.org/en/guilin/guides/onap-operator/cloud_site/k8s/index.html
.. _SO Monitoring: https://docs.onap.org/projects/onap-so/en/guilin/developer_info/Working_with_so_monitoring.html
.. _Data Dictionary: https://git.onap.org/demo/tree/heat/vFW_CNF_CDS/templates/cba-dd.json?h=guilin
.. _Helm Healer: https://git.onap.org/oom/offline-installer/tree/tools/helm-healer.sh?h=frankfurt
.. _CDS UAT Testing: https://wiki.onap.org/display/DW/Modeling+Concepts
.. _infra_workload: https://docs.onap.org/projects/onap-multicloud-framework/en/latest/specs/multicloud_infra_workload.html?highlight=multicloud
