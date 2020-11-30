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

Description
~~~~~~~~~~~
This use case is a combination of `vFW CDS Dublin`_ and `vFW EDGEX K8S`_ use cases. The aim is to continue improving Kubernetes based Network Functions (a.k.a CNF) support in ONAP. Use case continues where `vFW EDGEX K8S`_ left and brings CDS support into picture like `vFW CDS Dublin`_ did for the old vFW Use case. Predecessor use case is also documented here `vFW EDGEX K8S In ONAP Wiki`_.

In a higher level this use case brings only two improvements yet important ones i.e. the ability to instantiate more than single CNF instance of same type (with same Helm package) and ability to embed into singular onboarding package more than one helm package what brings more service design options.

Following improvements were made in the Use Case or related ONAP components:

- Changed vFW Kubernetes Helm charts to support overrides (previously mostly hardcoded values)
- Combined all models (Heat, Helm, CBA) in to same git repo and a creating single onboarding package `vFW_CNF_CDS Model`_
- Compared to `vFW EDGEX K8S`_ use case **MACRO** workflow in SO is used instead of VNF a'la carte workflow. (this is general requirement to utilize CDS as part of instantiation flow)
- SDC accepts Onboarding Package with many helm packages what allows to keep decomposition of service instance similar to `vFW CDS Dublin`_
- CDS is used to resolve instantiation time parameters (Helm override)
  - Ip addresses with IPAM
  - Unique names for resources with ONAP naming service
- Multicloud/k8s plugin changed to support identifiers of vf-module concept
- **multicloud/k8s** creates automatically default empty RB profile and profile upload becomes optional for instantiation of CNF
- CDS is used to create **multicloud/k8s profile** as part of instantiation flow (previously manual step)

Use case does not contain Closed Loop part of the vFW demo.

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

All changes to related ONAP components and Use Case can be found from this `Jira Epic`_ ticket.

Modeling Onboarding Package/Helm
................................

The starting point for this demo was Helm package containing one Kubernetes application, see `vFW_Helm Model`_. In this demo we decided to follow SDC/SO vf-module concept the same way as original vFW demo was split into multiple vf-modules instead of one (`vFW_NextGen`_). The same way we splitted Helm version of vFW into multiple Helm packages each matching one dedicated vf-module.

Produced onboarding package has following MANIFEST file (package/MANIFEST.json) having all Helm packages modeled as dummy Heat resources matching to vf-module concept (that is originated from Heat), so basically each Helm application is visible to ONAP as own vf-module. Actual Helm package is delivered as CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT package through SDC and SO. Dummy heat templates are matched to helm packages by the same prefix of the file name.

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

Multicloud/k8s
..............

K8s plugin was changed to support new way to identify k8s application and related multicloud/k8s profile.

Changes done:

- SDC distribution broker

    SDC distribution broker is responsible for transformation of the CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT into *Definition* object holding the helm package. The change for Frankfurt release considers that singular onboarding package can have many CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT, each one for dedicated vf-module associated with dummy heat template. The mapping between vf-module and CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT is done on file prefixes. In example, *vfw.yaml* Heat template will result with creation of *vfw* vf-module and its Definition will be created from CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT file of name vfw_cloudtech_k8s_charts.tgz. More examples can be found in `Modeling Onboarding Package/Helm`_ section.

- K8S plugin APIs changed to use VF Module Model Identifiers

    Previously K8S plugin's used user given values in to identify object created/modified. Names were basing on VF-Module's "model-name"/"model-version" like "VfwLetsHopeLastOne..vfw..module-3" and "1". SO request has user_directives from where values was taken.

    **VF Module Model Invariant ID** and **VF Module Model Version ID** is now used to identify artifact in SO request to Multicloud/k8s plugin. This does not require user to give extra parameters for the SO request as vf-module related parameters are there already by default. `MULTICLOUD-941`_
    Note that API endpoints are not changed but only the semantics.

    *Examples:*

      Definition

      ::

          /api/multicloud-k8s/v1/v1/rb/definition/{VF Module Model Invariant ID}/{VF Module Model Version ID}/content


      Profile creation API

      ::

          curl -i -d @create_rbprofile.json -X POST http://${K8S_NODE_IP}:30280/api/multicloud-k8s/v1/v1/rb/definition/{VF Module Model Invariant ID}/{VF Module Model Version ID}/profile
          {    "rb-name": “{VF Module Model Invariant ID}",
               "rb-version": "{VF Module Model Version ID}",
               "profile-name": "p1",
               "release-name": "r1",
               "namespace": "testns1",
               "kubernetes-version": "1.13.5"
          }

      Upload Profile content API

      ::

          curl -i --data-binary @profile.tar.gz -X POST http://${K8S_NODE_IP}:30280/api/multicloud-k8s/v1/v1/rb/definition/{VF Module Model Invariant ID}/{VF Module Model Version ID}/profile/p1/content

- Instantiation broker

    The broker implements `infra_workload`_ API used to handle vf-module instantiation request comming from the SO. User directives were changed by SDNC directives what impacts also the way how a'la carte instantiation method works from the VID. There is no need to specify the user directives delivered from the separate file. Instead SDNC directives are delivered through SDNC preloading (a'la carte instantiation) or through the resource assignment performed by the CDS (Macro flow instantiation).


    For helm package instantiation following parameters have to be delivered in the SDNC directives:


    ======================== ==============================================

    Variable                 Description

    ------------------------ ----------------------------------------------

    k8s-rb-profile-name      Name of the override profile

    k8s-rb-profile-namespace Name of the namespace for created helm package

    ======================== ==============================================

- Default profile support was added to the plugin

    K8splugin now creates dummy "default" profile on each resource bundle registration. Such profile doesn't contain any content inside and allows instantiation of CNF without the need to define additional profile, however this is still possible. In this use-case, CBA has been defined in a way, that it can template some simple profile that can be later put by CDS during resource-assignment instantiation phase and later picked up for instantiation. This happens when using second prepared instantiation call for instantiation: **Postman -> LCM -> 6. [SO] Self-Serve Service Assign & Activate - Second**

- Instantiation time override support was added to the plugin

    K8splugin allows now specifying override parameters (similar to --set behavior of helm client) to instantiated resource bundles. This allows for providing dynamic parameters to instantiated resources without the need to create new profiles for this purpose.


CDS Model (CBA)
...............

Creating CDS model was the core of the use case work and also the most difficult and time consuming part. There are many reasons for this e.g.

- CDS documentation (even being new component) is inadequate or non-existent for service modeler user. One would need to be CDS developer to be able to do something with it.
- CDS documentation what exists is non-versioned (in ONAP wiki when should be in git) so it's mostly impossible to know what features are for what release.
- Our little experience of CDS (not CDS developers)

Although initial development of template wasn't easy, current template used by use-case should be easily reusable for anyone. Once CDS GUI will be fully working, we think that CBA development should be much easier. For CBA structure reference, please visit it's documentation page `CDS Modeling Concepts`_.

At first the target was to keep CDS model as close as possible to `vFW_CNF_CDS Model`_ use case model and only add smallest possible changes to enable also k8s usage. That is still the target but in practice model deviated from the original one already and time pressure pushed us to not care about sync. Basically the end result could be possible much streamlined if wanted to be smallest possible to working only for K8S based network functions.

As K8S application was split into multiple Helm packages to match vf-modules, CBA modeling follows the same and for each vf-module there's own template in CBA package.

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

Another advance of the presented use case over solution presented in the Dublin release is possibility of the automatic generation and upload to multicloud/k8s plugin the RB profile content.
RB profile can be used to enrich or to modify the content of the original helm package. Profile can be also used to add additional k8s helm templates for helm installation or can be used to
modify existing k8s helm templates for each create CNF instance. It opens another level of CNF customization, much more than customization og helm package with override values.

::

  ---
  version: v1
  type:
    values: “override_values.yaml”
    configresource:
      - filepath: resources/deployment.yaml
        chartpath: templates/deployment.yaml


Above we have exemplary manifest file of the RB profile. Since Frankfurt *override_values.yaml* file does not need to be used as instantiation values are passed to the plugin over Instance API of k8s plugin. In the example profile contains additional k8s helm template which will be added on demand
to the helm package during its installation. In our case, depending on the SO instantiation request input parameters, vPGN helm package can be enriched with additional ssh service. Such service will be dynamically added to the profile by CDS and later on CDS will upload whole custom RB profile to multicloud/k8s plugin.

In order to support generation and upload of profile, our vFW CBA model has enhanced **resource-assignment** workflow which contains additional steps, **profile-modification** and **profile-upload**. For the last step custom Kotlin script included in the CBA is used to upload K8S profile into multicloud/k8s plugin.

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
                    "profile-modification"
                ]
            },
            "profile-modification": {
                "description": "Profile Modification Resources",
                "target": "profile-modification",
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
                "description": "Upload K8s Profile",
                "target": "profile-upload",
                "activities": [
                    {
                        "call_operation": "ComponentScriptExecutor.process"
                    }
                ]
            }
        },

Profile generation step uses embedded into CDS functionality of templates processing and on its basis ssh port number (specified in the SO request as vpg-management-port) is included in the ssh service helm template.

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

To upload of the profile is conducted with the CDS capability to execute Kotlin scripts. It allows to define any required controller logic. In our case we use to implement decision point and mechanisms of profile generation and upload.
During the generation CDS extracts the RB profile template included in the CBA, includes there generated ssh service helm template, modifies the manifest of RB template by adding there ssh service and after its archivisation sends the profile to
k8s plugin.

::

    "profile-modification": {
        "type": "component-resource-resolution",
        "interfaces": {
            "ResourceResolutionComponent": {
                "operations": {
                    "process": {
                        "inputs": {
                            "artifact-prefix-names": [
                                "ssh-service"
                            ]
                        }
                    }
                }
            }
        },
        "artifacts": {
            "ssh-service-template": {
                "type": "artifact-template-velocity",
                "file": "Templates/k8s-profiles/ssh-service-template.vtl"
            },
            "ssh-service-mapping": {
                "type": "artifact-mapping-resource",
                "file": "Templates/k8s-profiles/ssh-service-mapping.json"
            }
        }
    },
    "profile-upload": {
        "type": "component-script-executor",
        "interfaces": {
            "ComponentScriptExecutor": {
                "operations": {
                    "process": {
                        "inputs": {
                            "script-type": "kotlin",
                            "script-class-reference": "org.onap.ccsdk.cds.blueprintsprocessor.services.execution.scripts.K8sProfileUpload",
                            "dynamic-properties": "*profile-upload-properties"
                        }
                    }
                }
            }
        }
    }

Kotlin script expects that K8S profile template named like "k8s-rb-profile-name".tar.gz is present in CBA "Templates/k8s-profiles" directory where **k8s-rb-profile-name** is one of the CDS resolved parameters (user provides as input parameter) and in our case it has a value **vfw-cnf-cds-base-profile**.

Finally, `Data Dictionary`_ is also included into demo git directory, re-modeling and making changes into model utilizing CDS model time / runtime is easier as used DD is also known.

UAT
+++


UAT is a nice concept where CDS CBA can be tested isolated after all external calls it makes are recorded. UAT framework in CDS has spy mode that enables such recording of requets. Recording is initiated with structured yaml file having all CDS requests and spy mode executes all those requests in given yaml file and procuding another yaml file where external requetsts and payloads are recorded.

During this use case we had several problems with UAT testing and finally we where not able to get it fully working. UAT framework is not taking consideration that of subsequent CDS calls does have affects to external componenets like SDNC MDSAL (particularly the first resource-assignment call comING FROM sdnc stored resolved values to MDSAL and those are needed by subsequent calls by CBA model).

It was possible to record CDS calls with UAT spy after successfull instantition when SDNC was alredy populated with resolved values are re-run of CDS model was able to fetch needed values.

During testing of the use case **uat.yml** file was recorded according to `CDS UAT Testing`_ instructions. Generated uat.yml could be stored (if usable) within CBA package into **Tests** folder.

Recorded uat.yml is an example run with example values (the values we used when demo was run) and can be used later to test CBA model in isolation (unit test style). This could be very useful when changes are made to CBA model and those changes are needed to be tested fast. With uat.yml file only CDS is needed as all external interfaces are mocked. However, note that mocking is possible for REST interfaces only (e.g. Netconf is not supported).

Another benefit of uat.yml is that it documents the runtime functionality of the CBA and that's the main benefit on this use case as the UAT test (verify) part was not really successful.

To verify CBA with uat.yaml and CDS runtime do following:

- Enable UAT testing for CDS runtime

  ::

      kubectl -n onap edit deployment onap-cds-blueprints-processor

      # add env variable for cds-blueprints-processor container:
                name: spring_profiles_active
                value: uat

- Spy CBA functionality with UAT initial seed file

::

    curl -X POST -u ccsdkapps:ccsdkapps -F cba=@my_cba.zip -F uat=@input_uat.yaml http://<kube-node>:30499/api/v1/uat/spy

where my_cba.zip is the cba model of this use case and input_uat.yml is following in this use case:

::

    %YAML 1.1
    ---
    processes:
      - name: resource-assignment for vnf
        request:
          commonHeader: &commonHeader
            originatorId: SDNC_DG
            requestId: "98397f54-fa57-485f-a04e-1e220b7b1779"
            subRequestId: "6bfca5dc-993d-48f1-ad27-a7a9ea91836b"
          actionIdentifiers: &actionIdentifiers
            blueprintName: vFW_CNF_CDS
            blueprintVersion: "1.0.45"
            actionName: resource-assignment
            mode: sync
          payload:
            resource-assignment-request:
              template-prefix:
                - "vnf"
              resource-assignment-properties:
                service-instance-id: &service-id "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                vnf-model-customization-uuid: &vnf-model-cust-uuid "86dc8af4-aa17-4fc7-9b20-f12160d99718"
                vnf-id: &vnf-id "93b3350d-ed6f-413b-9cc5-a158c1676eb0"
                aic-cloud-region: &cloud-region "k8sregionfour"
      - name: resource-assignment for base_template
        request:
          commonHeader: *commonHeader
          actionIdentifiers: *actionIdentifiers
          payload:
            resource-assignment-request:
              template-prefix:
                - "base_template"
              resource-assignment-properties:
                nfc-naming-code: "base_template"
                k8s-rb-profile-name: &k8s-profile-name "default"
                service-instance-id: *service-id
                vnf-id: *vnf-id
                vf-module-model-customization-uuid: "b27fad11-44da-4840-9256-7ed8a32fbe3e"
                vnf-model-customization-uuid: *vnf-model-cust-uuid
                vf-module-id: "274f4bc9-7679-4767-b34d-1df51cdf2496"
                aic-cloud-region: *cloud-region
      - name: resource-assignment for vpkg
        request:
          commonHeader: *commonHeader
          actionIdentifiers: *actionIdentifiers
          payload:
            resource-assignment-request:
              template-prefix:
                - "vpkg"
              resource-assignment-properties:
                nfc-naming-code: "vpkg"
                k8s-rb-profile-name: *k8s-profile-name
                service-instance-id: *service-id
                vnf-id: *vnf-id
                vf-module-model-customization-uuid: "4e7028a1-4c80-4d20-a7a2-a1fb3343d5cb"
                vnf-model-customization-uuid: *vnf-model-cust-uuid
                vf-module-id: "011b5f61-6524-4789-bd9a-44cfbf321463"
                aic-cloud-region: *cloud-region
      - name: resource-assignment for vsn
        request:
          commonHeader: *commonHeader
          actionIdentifiers: *actionIdentifiers
          payload:
            resource-assignment-request:
              template-prefix:
                - "vsn"
              resource-assignment-properties:
                nfc-naming-code: "vsn"
                k8s-rb-profile-name: *k8s-profile-name
                service-instance-id: *service-id
                vnf-id: *vnf-id
                vf-module-model-customization-uuid: "4cac0584-c0d6-42a7-bdb3-29162792e07f"
                vnf-model-customization-uuid: *vnf-model-cust-uuid
                vf-module-id: "0cbf558f-5a96-4555-b476-7df8163521aa"
                aic-cloud-region: *cloud-region
      - name: resource-assignment for vfw
        request:
          commonHeader: *commonHeader
          actionIdentifiers: *actionIdentifiers
          payload:
            resource-assignment-request:
              template-prefix:
                - "vfw"
              resource-assignment-properties:
                nfc-naming-code: "vfw"
                k8s-rb-profile-name: *k8s-profile-name
                service-instance-id: *service-id
                vnf-id: *vnf-id
                vf-module-model-customization-uuid: "1e123e43-ba40-4c93-90d7-b9f27407ec03"
                vnf-model-customization-uuid: *vnf-model-cust-uuid
                vf-module-id: "0de4ed56-8b4c-4a2d-8ce6-85d5e269204f "
                aic-cloud-region: *cloud-region


.. note::  This call will run all the calls (given in input_uat.yml) towards CDS and records the functionality, so there needs to be working environment (SDNC, AAI, Naming, Netbox, etc.) to record valid final uat.yml.
           As an output of this call final uat.yml content is received. Final uat.yml in this use case looks like this:

::

    processes:
    - name: resource-assignment for vnf
      request:
        commonHeader:
          originatorId: SDNC_DG
          requestId: 98397f54-fa57-485f-a04e-1e220b7b1779
          subRequestId: 6bfca5dc-993d-48f1-ad27-a7a9ea91836b
        actionIdentifiers:
          blueprintName: vFW_CNF_CDS
          blueprintVersion: 1.0.45
          actionName: resource-assignment
          mode: sync
        payload:
          resource-assignment-request:
            template-prefix:
            - vnf
            resource-assignment-properties:
              service-instance-id: 8ead0480-cf44-428e-a4c2-0e6ed10f7a72
              vnf-model-customization-uuid: 86dc8af4-aa17-4fc7-9b20-f12160d99718
              vnf-id: 93b3350d-ed6f-413b-9cc5-a158c1676eb0
              aic-cloud-region: k8sregionfour
      expectedResponse:
        commonHeader:
          originatorId: SDNC_DG
          requestId: 98397f54-fa57-485f-a04e-1e220b7b1779
          subRequestId: 6bfca5dc-993d-48f1-ad27-a7a9ea91836b
          flags: null
        actionIdentifiers:
          blueprintName: vFW_CNF_CDS
          blueprintVersion: 1.0.45
          actionName: resource-assignment
          mode: sync
        status:
          code: 200
          eventType: EVENT_COMPONENT_EXECUTED
          errorMessage: null
          message: success
        payload:
          resource-assignment-response:
            meshed-template:
              vnf: |
                {
                    "capability-data": [
                        {
                            "capability-name": "generate-name",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vnf_name",
                                            "resource-value": "${vnf_name}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "resource-name",
                                            "param-value": "vnf_name"
                                        },
                                        {
                                            "param-name": "resource-value",
                                            "param-value": "${vnf_name}"
                                        },
                                        {
                                            "param-name": "external-key",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0_vnf_name"
                                        },
                                        {
                                            "param-name": "policy-instance-name",
                                            "param-value": "SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP"
                                        },
                                        {
                                            "param-name": "naming-type",
                                            "param-value": "VNF"
                                        },
                                        {
                                            "param-name": "AIC_CLOUD_REGION",
                                            "param-value": "k8sregionfour"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "netbox-ip-assign",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "int_private1_gw_ip",
                                            "resource-value": "${int_private1_gw_ip}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "service-instance-id",
                                            "param-value": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                                        },
                                        {
                                            "param-name": "prefix-id",
                                            "param-value": "2"
                                        },
                                        {
                                            "param-name": "vnf-id",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0"
                                        },
                                        {
                                            "param-name": "external_key",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0-int_private1_gw_ip"
                                        }
                                    ]
                                },
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "int_private2_gw_ip",
                                            "resource-value": "${int_private2_gw_ip}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "service-instance-id",
                                            "param-value": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                                        },
                                        {
                                            "param-name": "prefix-id",
                                            "param-value": "1"
                                        },
                                        {
                                            "param-name": "vnf-id",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0"
                                        },
                                        {
                                            "param-name": "external_key",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0-int_private2_gw_ip"
                                        }
                                    ]
                                },
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vfw_int_private2_ip_0",
                                            "resource-value": "${vfw_int_private2_ip_0}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "service-instance-id",
                                            "param-value": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                                        },
                                        {
                                            "param-name": "prefix-id",
                                            "param-value": "1"
                                        },
                                        {
                                            "param-name": "vnf-id",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0"
                                        },
                                        {
                                            "param-name": "external_key",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0-vfw_int_private2_ip_0"
                                        }
                                    ]
                                },
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vfw_int_private1_ip_0",
                                            "resource-value": "${vfw_int_private1_ip_0}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "service-instance-id",
                                            "param-value": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                                        },
                                        {
                                            "param-name": "prefix-id",
                                            "param-value": "2"
                                        },
                                        {
                                            "param-name": "vnf-id",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0"
                                        },
                                        {
                                            "param-name": "external_key",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0-vfw_int_private1_ip_0"
                                        }
                                    ]
                                },
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vsn_int_private2_ip_0",
                                            "resource-value": "${vsn_int_private2_ip_0}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "service-instance-id",
                                            "param-value": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                                        },
                                        {
                                            "param-name": "prefix-id",
                                            "param-value": "1"
                                        },
                                        {
                                            "param-name": "vnf-id",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0"
                                        },
                                        {
                                            "param-name": "external_key",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0-vsn_int_private2_ip_0"
                                        }
                                    ]
                                },
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vpg_int_private1_ip_0",
                                            "resource-value": "${vpg_int_private1_ip_0}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "service-instance-id",
                                            "param-value": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                                        },
                                        {
                                            "param-name": "prefix-id",
                                            "param-value": "2"
                                        },
                                        {
                                            "param-name": "vnf-id",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0"
                                        },
                                        {
                                            "param-name": "external_key",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0-vpg_int_private1_ip_0"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "unresolved-composite-data",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "int_private2_net_id",
                                            "resource-value": "${vnf_name}-protected-network"
                                        },
                                        {
                                            "resource-name": "int_private1_net_id",
                                            "resource-value": "${vnf_name}-unprotected-network"
                                        },
                                        {
                                            "resource-name": "onap_private_net_id",
                                            "resource-value": "${vnf_name}-management-network"
                                        },
                                        {
                                            "resource-name": "net_attachment_definition",
                                            "resource-value": "${vnf_name}-ovn-nat"
                                        }
                                    ]
                                }
                            ]
                        }
                    ],
                    "resource-accumulator-resolved-data": [
                        {
                            "param-name": "vf-naming-policy",
                            "param-value": "SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP"
                        },
                        {
                            "param-name": "dcae_collector_ip",
                            "param-value": "10.0.4.1"
                        },
                        {
                            "param-name": "dcae_collector_port",
                            "param-value": "30235"
                        },
                        {
                            "param-name": "int_private1_net_cidr",
                            "param-value": "192.168.10.0/24"
                        },
                        {
                            "param-name": "int_private2_net_cidr",
                            "param-value": "192.168.20.0/24"
                        },
                        {
                            "param-name": "onap_private_net_cidr",
                            "param-value": "10.0.101.0/24"
                        },
                        {
                            "param-name": "demo_artifacts_version",
                            "param-value": "1.5.0"
                        },
                        {
                            "param-name": "k8s-rb-profile-name",
                            "param-value": "vfw-cnf-cds-base-profile"
                        },
                        {
                            "param-name": "k8s-rb-profile-namespace",
                            "param-value": "default"
                        }
                    ]
                }
    - name: resource-assignment for base_template
      request:
        commonHeader:
          originatorId: SDNC_DG
          requestId: 98397f54-fa57-485f-a04e-1e220b7b1779
          subRequestId: 6bfca5dc-993d-48f1-ad27-a7a9ea91836b
        actionIdentifiers:
          blueprintName: vFW_CNF_CDS
          blueprintVersion: 1.0.45
          actionName: resource-assignment
          mode: sync
        payload:
          resource-assignment-request:
            template-prefix:
            - base_template
            resource-assignment-properties:
              nfc-naming-code: base_template
              k8s-rb-profile-name: default
              service-instance-id: 8ead0480-cf44-428e-a4c2-0e6ed10f7a72
              vnf-id: 93b3350d-ed6f-413b-9cc5-a158c1676eb0
              vf-module-model-customization-uuid: b27fad11-44da-4840-9256-7ed8a32fbe3e
              vnf-model-customization-uuid: 86dc8af4-aa17-4fc7-9b20-f12160d99718
              vf-module-id: 274f4bc9-7679-4767-b34d-1df51cdf2496
              aic-cloud-region: k8sregionfour
      expectedResponse:
        commonHeader:
          originatorId: SDNC_DG
          requestId: 98397f54-fa57-485f-a04e-1e220b7b1779
          subRequestId: 6bfca5dc-993d-48f1-ad27-a7a9ea91836b
          flags: null
        actionIdentifiers:
          blueprintName: vFW_CNF_CDS
          blueprintVersion: 1.0.45
          actionName: resource-assignment
          mode: sync
        status:
          code: 200
          eventType: EVENT_COMPONENT_EXECUTED
          errorMessage: null
          message: success
        payload:
          resource-assignment-response:
            meshed-template:
              base_template: |
                {
                    "capability-data": [
                        {
                            "capability-name": "netbox-ip-assign",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "onap_private_gw_ip",
                                            "resource-value": "${onap_private_gw_ip}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "service-instance-id",
                                            "param-value": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                                        },
                                        {
                                            "param-name": "prefix-id",
                                            "param-value": "3"
                                        },
                                        {
                                            "param-name": "vnf-id",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0"
                                        },
                                        {
                                            "param-name": "external_key",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0-onap_private_gw_ip"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "generate-name",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vf_module_name",
                                            "resource-value": "${vf-module-name}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "resource-name",
                                            "param-value": "vf_module_name"
                                        },
                                        {
                                            "param-name": "resource-value",
                                            "param-value": "${vf-module-name}"
                                        },
                                        {
                                            "param-name": "external-key",
                                            "param-value": "274f4bc9-7679-4767-b34d-1df51cdf2496_vf-module-name"
                                        },
                                        {
                                            "param-name": "policy-instance-name",
                                            "param-value": "SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP"
                                        },
                                        {
                                            "param-name": "naming-type",
                                            "param-value": "VF-MODULE"
                                        },
                                        {
                                            "param-name": "VNF_NAME",
                                            "param-value": "k8sregionfour-onap-nf-20200601t073308018z"
                                        },
                                        {
                                            "param-name": "VF_MODULE_TYPE",
                                            "param-value": "vfmt"
                                        },
                                        {
                                            "param-name": "VF_MODULE_LABEL",
                                            "param-value": "base_template"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "aai-vf-module-put",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "aai-vf-module-put",
                                            "resource-value": ""
                                        }
                                    ]
                                }
                            ]
                        }
                    ],
                    "resource-accumulator-resolved-data": [
                        {
                            "param-name": "vf-module-model-invariant-uuid",
                            "param-value": "52842255-b7be-4a1c-ab3b-2bd3bd4a5423"
                        },
                        {
                            "param-name": "vf-module-model-version",
                            "param-value": "274f4bc9-7679-4767-b34d-1df51cdf2496"
                        },
                        {
                            "param-name": "k8s-rb-profile-name",
                            "param-value": "default"
                        },
                        {
                            "param-name": "k8s-rb-profile-namespace",
                            "param-value": "default"
                        },
                        {
                            "param-name": "int_private1_subnet_id",
                            "param-value": "unprotected-network-subnet-1"
                        },
                        {
                            "param-name": "int_private2_subnet_id",
                            "param-value": "protected-network-subnet-1"
                        },
                        {
                            "param-name": "onap_private_subnet_id",
                            "param-value": "management-network-subnet-1"
                        }
                    ]
                }
    - name: resource-assignment for vpkg
      request:
        commonHeader:
          originatorId: SDNC_DG
          requestId: 98397f54-fa57-485f-a04e-1e220b7b1779
          subRequestId: 6bfca5dc-993d-48f1-ad27-a7a9ea91836b
        actionIdentifiers:
          blueprintName: vFW_CNF_CDS
          blueprintVersion: 1.0.45
          actionName: resource-assignment
          mode: sync
        payload:
          resource-assignment-request:
            template-prefix:
            - vpkg
            resource-assignment-properties:
              nfc-naming-code: vpkg
              k8s-rb-profile-name: default
              service-instance-id: 8ead0480-cf44-428e-a4c2-0e6ed10f7a72
              vnf-id: 93b3350d-ed6f-413b-9cc5-a158c1676eb0
              vf-module-model-customization-uuid: 4e7028a1-4c80-4d20-a7a2-a1fb3343d5cb
              vnf-model-customization-uuid: 86dc8af4-aa17-4fc7-9b20-f12160d99718
              vf-module-id: 011b5f61-6524-4789-bd9a-44cfbf321463
              aic-cloud-region: k8sregionfour
      expectedResponse:
        commonHeader:
          originatorId: SDNC_DG
          requestId: 98397f54-fa57-485f-a04e-1e220b7b1779
          subRequestId: 6bfca5dc-993d-48f1-ad27-a7a9ea91836b
          flags: null
        actionIdentifiers:
          blueprintName: vFW_CNF_CDS
          blueprintVersion: 1.0.45
          actionName: resource-assignment
          mode: sync
        status:
          code: 200
          eventType: EVENT_COMPONENT_EXECUTED
          errorMessage: null
          message: success
        payload:
          resource-assignment-response:
            meshed-template:
              vpkg: |
                {
                    "capability-data": [
                        {
                            "capability-name": "netbox-ip-assign",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vpg_onap_private_ip_0",
                                            "resource-value": "${vpg_onap_private_ip_0}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "service-instance-id",
                                            "param-value": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                                        },
                                        {
                                            "param-name": "prefix-id",
                                            "param-value": "3"
                                        },
                                        {
                                            "param-name": "vnf-id",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0"
                                        },
                                        {
                                            "param-name": "external_key",
                                            "param-value": "93b3350d-ed6f-413b-9cc5-a158c1676eb0-vpg_onap_private_ip_0"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "generate-name",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vf_module_name",
                                            "resource-value": "${vf-module-name}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "VF_MODULE_TYPE",
                                            "param-value": "vfmt"
                                        },
                                        {
                                            "param-name": "resource-name",
                                            "param-value": "vf_module_name"
                                        },
                                        {
                                            "param-name": "resource-value",
                                            "param-value": "${vf-module-name}"
                                        },
                                        {
                                            "param-name": "external-key",
                                            "param-value": "011b5f61-6524-4789-bd9a-44cfbf321463_vf-module-name"
                                        },
                                        {
                                            "param-name": "policy-instance-name",
                                            "param-value": "SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP"
                                        },
                                        {
                                            "param-name": "naming-type",
                                            "param-value": "VF-MODULE"
                                        },
                                        {
                                            "param-name": "VNF_NAME",
                                            "param-value": "k8sregionfour-onap-nf-20200601t073308018z"
                                        },
                                        {
                                            "param-name": "VF_MODULE_LABEL",
                                            "param-value": "vpkg"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "aai-vf-module-put",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "aai-vf-module-put",
                                            "resource-value": ""
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "unresolved-composite-data",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vpg_name_0",
                                            "resource-value": "${vf_module_name}"
                                        }
                                    ]
                                }
                            ]
                        }
                    ],
                    "resource-accumulator-resolved-data": [
                        {
                            "param-name": "vf-module-model-invariant-uuid",
                            "param-value": "4e2b9975-5214-48b8-861a-5701c09eedfa"
                        },
                        {
                            "param-name": "vf-module-model-version",
                            "param-value": "011b5f61-6524-4789-bd9a-44cfbf321463"
                        },
                        {
                            "param-name": "k8s-rb-profile-name",
                            "param-value": "default"
                        },
                        {
                            "param-name": "k8s-rb-profile-namespace",
                            "param-value": "default"
                        }
                    ]
                }
    - name: resource-assignment for vsn
      request:
        commonHeader:
          originatorId: SDNC_DG
          requestId: 98397f54-fa57-485f-a04e-1e220b7b1779
          subRequestId: 6bfca5dc-993d-48f1-ad27-a7a9ea91836b
        actionIdentifiers:
          blueprintName: vFW_CNF_CDS
          blueprintVersion: 1.0.45
          actionName: resource-assignment
          mode: sync
        payload:
          resource-assignment-request:
            template-prefix:
            - vsn
            resource-assignment-properties:
              nfc-naming-code: vsn
              k8s-rb-profile-name: default
              service-instance-id: 8ead0480-cf44-428e-a4c2-0e6ed10f7a72
              vnf-id: 93b3350d-ed6f-413b-9cc5-a158c1676eb0
              vf-module-model-customization-uuid: 4cac0584-c0d6-42a7-bdb3-29162792e07f
              vnf-model-customization-uuid: 86dc8af4-aa17-4fc7-9b20-f12160d99718
              vf-module-id: 0cbf558f-5a96-4555-b476-7df8163521aa
              aic-cloud-region: k8sregionfour
      expectedResponse:
        commonHeader:
          originatorId: SDNC_DG
          requestId: 98397f54-fa57-485f-a04e-1e220b7b1779
          subRequestId: 6bfca5dc-993d-48f1-ad27-a7a9ea91836b
          flags: null
        actionIdentifiers:
          blueprintName: vFW_CNF_CDS
          blueprintVersion: 1.0.45
          actionName: resource-assignment
          mode: sync
        status:
          code: 200
          eventType: EVENT_COMPONENT_EXECUTED
          errorMessage: null
          message: success
        payload:
          resource-assignment-response:
            meshed-template:
              vsn: |
                {
                    "capability-data": [
                        {
                            "capability-name": "generate-name",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vf_module_name",
                                            "resource-value": "${vf-module-name}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "VF_MODULE_TYPE",
                                            "param-value": "vfmt"
                                        },
                                        {
                                            "param-name": "resource-name",
                                            "param-value": "vf_module_name"
                                        },
                                        {
                                            "param-name": "resource-value",
                                            "param-value": "${vf-module-name}"
                                        },
                                        {
                                            "param-name": "external-key",
                                            "param-value": "0cbf558f-5a96-4555-b476-7df8163521aa_vf-module-name"
                                        },
                                        {
                                            "param-name": "policy-instance-name",
                                            "param-value": "SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP"
                                        },
                                        {
                                            "param-name": "naming-type",
                                            "param-value": "VF-MODULE"
                                        },
                                        {
                                            "param-name": "VNF_NAME",
                                            "param-value": "k8sregionfour-onap-nf-20200601t073308018z"
                                        },
                                        {
                                            "param-name": "VF_MODULE_LABEL",
                                            "param-value": "vsn"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "netbox-ip-assign",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vsn_onap_private_ip_0",
                                            "resource-value": "${vsn_onap_private_ip_0}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "service-instance-id",
                                            "param-value": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                                        },
                                        {
                                            "param-name": "prefix-id",
                                            "param-value": "3"
                                        },
                                        {
                                            "param-name": "vf_module_id",
                                            "param-value": "0cbf558f-5a96-4555-b476-7df8163521aa"
                                        },
                                        {
                                            "param-name": "external_key",
                                            "param-value": "0cbf558f-5a96-4555-b476-7df8163521aa-vsn_onap_private_ip_0"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "aai-vf-module-put",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "aai-vf-module-put",
                                            "resource-value": ""
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "unresolved-composite-data",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vsn_name_0",
                                            "resource-value": "${vf_module_name}"
                                        }
                                    ]
                                }
                            ]
                        }
                    ],
                    "resource-accumulator-resolved-data": [
                        {
                            "param-name": "vf-module-model-invariant-uuid",
                            "param-value": "36f25e1b-199b-4de2-b656-c870d341cf0e"
                        },
                        {
                            "param-name": "vf-module-model-version",
                            "param-value": "0cbf558f-5a96-4555-b476-7df8163521aa"
                        },
                        {
                            "param-name": "k8s-rb-profile-name",
                            "param-value": "default"
                        },
                        {
                            "param-name": "k8s-rb-profile-namespace",
                            "param-value": "default"
                        }
                    ]
                }
    - name: resource-assignment for vfw
      request:
        commonHeader:
          originatorId: SDNC_DG
          requestId: 98397f54-fa57-485f-a04e-1e220b7b1779
          subRequestId: 6bfca5dc-993d-48f1-ad27-a7a9ea91836b
        actionIdentifiers:
          blueprintName: vFW_CNF_CDS
          blueprintVersion: 1.0.45
          actionName: resource-assignment
          mode: sync
        payload:
          resource-assignment-request:
            template-prefix:
            - vfw
            resource-assignment-properties:
              nfc-naming-code: vfw
              k8s-rb-profile-name: default
              service-instance-id: 8ead0480-cf44-428e-a4c2-0e6ed10f7a72
              vnf-id: 93b3350d-ed6f-413b-9cc5-a158c1676eb0
              vf-module-model-customization-uuid: 1e123e43-ba40-4c93-90d7-b9f27407ec03
              vnf-model-customization-uuid: 86dc8af4-aa17-4fc7-9b20-f12160d99718
              vf-module-id: '0de4ed56-8b4c-4a2d-8ce6-85d5e269204f '
              aic-cloud-region: k8sregionfour
      expectedResponse:
        commonHeader:
          originatorId: SDNC_DG
          requestId: 98397f54-fa57-485f-a04e-1e220b7b1779
          subRequestId: 6bfca5dc-993d-48f1-ad27-a7a9ea91836b
          flags: null
        actionIdentifiers:
          blueprintName: vFW_CNF_CDS
          blueprintVersion: 1.0.45
          actionName: resource-assignment
          mode: sync
        status:
          code: 200
          eventType: EVENT_COMPONENT_EXECUTED
          errorMessage: null
          message: success
        payload:
          resource-assignment-response:
            meshed-template:
              vfw: |
                {
                    "capability-data": [
                        {
                            "capability-name": "generate-name",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vf_module_name",
                                            "resource-value": "${vf-module-name}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "VF_MODULE_TYPE",
                                            "param-value": "vfmt"
                                        },
                                        {
                                            "param-name": "resource-name",
                                            "param-value": "vf_module_name"
                                        },
                                        {
                                            "param-name": "resource-value",
                                            "param-value": "${vf-module-name}"
                                        },
                                        {
                                            "param-name": "external-key",
                                            "param-value": "0de4ed56-8b4c-4a2d-8ce6-85d5e269204f _vf-module-name"
                                        },
                                        {
                                            "param-name": "policy-instance-name",
                                            "param-value": "SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP"
                                        },
                                        {
                                            "param-name": "naming-type",
                                            "param-value": "VF-MODULE"
                                        },
                                        {
                                            "param-name": "VNF_NAME",
                                            "param-value": "k8sregionfour-onap-nf-20200601t073308018z"
                                        },
                                        {
                                            "param-name": "VF_MODULE_LABEL",
                                            "param-value": "vfw"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "netbox-ip-assign",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vfw_onap_private_ip_0",
                                            "resource-value": "${vfw_onap_private_ip_0}"
                                        }
                                    ],
                                    "payload": [
                                        {
                                            "param-name": "service-instance-id",
                                            "param-value": "8ead0480-cf44-428e-a4c2-0e6ed10f7a72"
                                        },
                                        {
                                            "param-name": "prefix-id",
                                            "param-value": "3"
                                        },
                                        {
                                            "param-name": "vf_module_id",
                                            "param-value": "0de4ed56-8b4c-4a2d-8ce6-85d5e269204f "
                                        },
                                        {
                                            "param-name": "external_key",
                                            "param-value": "0de4ed56-8b4c-4a2d-8ce6-85d5e269204f -vfw_onap_private_ip_0"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "aai-vf-module-put",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "aai-vf-module-put",
                                            "resource-value": ""
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "capability-name": "unresolved-composite-data",
                            "key-mapping": [
                                {
                                    "output-key-mapping": [
                                        {
                                            "resource-name": "vfw_name_0",
                                            "resource-value": "${vf_module_name}"
                                        }
                                    ]
                                }
                            ]
                        }
                    ],
                    "resource-accumulator-resolved-data": [
                        {
                            "param-name": "vf-module-model-invariant-uuid",
                            "param-value": "9ffda670-3d77-4f6c-a4ad-fb7a09f19817"
                        },
                        {
                            "param-name": "vf-module-model-version",
                            "param-value": "0de4ed56-8b4c-4a2d-8ce6-85d5e269204f"
                        },
                        {
                            "param-name": "k8s-rb-profile-name",
                            "param-value": "default"
                        },
                        {
                            "param-name": "k8s-rb-profile-namespace",
                            "param-value": "default"
                        }
                    ]
                }
    externalServices:
    - selector: sdnc
      expectations:
      - request:
          method: GET
          path: /restconf/config/GENERIC-RESOURCE-API:services/service/8ead0480-cf44-428e-a4c2-0e6ed10f7a72/service-data/vnfs/vnf/93b3350d-ed6f-413b-9cc5-a158c1676eb0/vnf-data/vnf-topology/vnf-parameters-data/param/vf-naming-policy
        responses:
        - status: 200
          body:
            param:
            - name: vf-naming-policy
              value: SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP
              resource-resolution-data:
                capability-name: RA Resolved
                status: SUCCESS
          headers:
            Content-Type: application/json
        times: '>= 1'


- Verify CBA with UAT

  ::

      curl -X POST -u ccsdkapps:ccsdkapps -F cba=@my_cba.zip http://<kube-node>:30499/api/v1/uat/verify

where my_cba.zip is the CBA model with uat.yml (generated in spy step) inside Test folder.

This verify call failed for us with above uat.yaml file generated in spy. Issue was not investigated further in the scope of this use case.

Instantiation Overview
----------------------

The figure below shows all the interactions that take place during vFW CNF instantiation. It's not describing flow of actions (ordered steps) but rather component dependencies.

.. figure:: files/vFW_CNF_CDS/Instantiation_topology.png
   :align: center

   vFW CNF CDS Use Case Runtime interactions.

PART 1 - ONAP Installation
~~~~~~~~~~~~~~~~~~~~~~~~~~

1-1 Deployment components
.........................

In order to run the vFW_CNF_CDS use case, we need ONAP Frankfurt Release (or later) and at least following components:

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

After completing the first part above, we should have a functional ONAP deployment for the Frankfurt Release.

We will need to apply a few modifications to the deployed ONAP Frankfurt instance in order to run the use case.

Retrieving logins and passwords of ONAP components
++++++++++++++++++++++++++++++++++++++++++++++++++

Since Frankfurt release hardcoded passwords were mostly removed and it is possible to configure passwords of ONAP components in time of their installation. In order to retrieve these passwords with associated logins it is required to get them with kubectl. Below is the procedure on mariadb-galera DB component example.

::

    kubectl get secret `kubectl get secrets | grep mariadb-galera-db-root-password | awk '{print $1}'` -o jsonpath="{.data.login}" | base64 --decode
    kubectl get secret `kubectl get secrets | grep mariadb-galera-db-root-password | awk '{print $1}'` -o jsonpath="{.data.password}" | base64 --decode

In this case login is empty as the secret is dedicated to root user.

Postman collection setup
++++++++++++++++++++++++

In this demo we have on purpose created all manual ONAP preparation steps (which in real life are automated) by using Postman so it will be clear what exactly is needed. Some of the steps like AAI population is automated by Robot scripts in other ONAP demos (**./demo-k8s.sh onap init**) and Robot script could be used for many parts also in this demo. Later when this demo is fully automated we probably update also Robot scripts to support this demo.

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


AAI
...

Some basic entries are needed in ONAP AAI. These entries are needed ones per onap installation and do not need to be repeated when running multiple demos based on same definitions.

Create all these entries into AAI in this order. Postman collection provided in this demo can be used for creating each entry.

**Postman -> Initial ONAP setup -> Create**

- Create Customer
- Create Owning-entity
- Create Platform
- Create Project
- Create Line Of Business

Corresponding GET operations in "Check" folder in Postman can be used to verify entries created. Postman collection also includes some code that tests/verifies some basic issues e.g. gives error if entry already exists.

SO BPMN endpoint fix for VNF adapter requests (v1 -> v2)
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SO Openstack adapter needs to be updated to use newer version. Here is also possible improvement area in SO. OpenStack adapter is confusing in context of this use case as VIM is not Openstack but Kubernetes cloud region. In this use case we did not used Openstack at all.

::

    kubectl -n onap edit configmap onap-so-bpmn-infra-app-configmap
      - .data."override.yaml".mso.adapters.vnf.rest.endpoint: http://so-openstack-adapter.onap:8087/services/rest/v1/vnfs
      + .data."override.yaml".mso.adapters.vnf.rest.endpoint: http://so-openstack-adapter.onap:8087/services/rest/v2/vnfs
    kubectl -n onap delete pod -l app=so-bpmn-infra

Naming Policy
+++++++++++++

Naming policy is needed to generate unique names for all instance time resources that are wanted to be modeled in the way naming policy is used. Those are normally VNF, VNFC and VF-module names, network names etc. Naming is general ONAP feature and not limited to this use case.

This usecase leverages default ONAP naming policy - "SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP".
To check that the naming policy is created and pushed OK, we can run the command below from inside any ONAP pod.

::

  curl --silent -k --user 'healthcheck:zb!XztG34' -X GET "https://policy-api:6969/policy/api/v1/policytypes/onap.policies.Naming/versions/1.0.0/policies/SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP/versions/1.0.0"

.. note:: Please change credentials respectively to your installation. The required credentials can be retrieved with instruction `Retrieving logins and passwords of ONAP components`_

**Network Naming mS**

FIXME - Verify if on RC2 this still needs to be performed

There's a strange feature or bug in naming service still at ONAP Frankfurt and following hack needs to be done to make it work.

.. note:: Please change credentials respectively to your installation. The required credentials can be retrieved with instruction `Retrieving logins and passwords of ONAP components`_

::

  # Go into naming service database
  kubectl -n onap exec onap-mariadb-galera-0 -it -- mysql -uroot -psecretpassword -D nengdb
    select * from EXTERNAL_INTERFACE;
    # Delete entries from EXTERNAL_INTERFACE table
    delete from EXTERNAL_INTERFACE;
    select * from EXTERNAL_INTERFACE;

PART 2 - Installation of managed Kubernetes cluster
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this demo the target cloud region is a Kubernetes cluster of your choice basically just like with Openstack. ONAP platform is a bit too much hard wired to Openstack and it's visible in many demos.

2-1 Installation of Managed Kubernetes
......................................

In this demo we use Kubernetes deployment used by ONAP multicloud/k8s team to test their plugin features see `KUD readthedocs`_. There's also some outdated instructions in ONAP wiki `KUD in Wiki`_.

KUD deployment is fully automated and also used in ONAP's CI/CD to automatically verify all `Multicloud k8s gerrit`_ commits (see `KUD Jenkins ci/cd verification`_) and that's quite good (and rare) level of automated integration testing in ONAP. KUD deployemnt is used as it's installation is automated and it also includes bunch of Kubernetes plugins used to tests various k8s plugin features. In addition to deployement, KUD repository also contains test scripts to automatically test multicloud/k8s plugin features. Those scripts are run in CI/CD.

See `KUD subproject in github`_ for a list of additional plugins this Kubernetes deployment has. In this demo the tested CNF is dependent on following plugins:

- ovn4nfv
- Multus
- Virtlet

Follow instructions in `KUD readthedocs`_ and install target Kubernetes cluster in your favorite machine(s), simplest being just one machine. Your cluster nodes(s) needs to be accessible from ONAP Kuberenetes nodes.

2-2 Cloud Registration
......................

Managed Kubernetes cluster is registered here into ONAP as one cloud region. This obviously is done just one time for this particular cloud. Cloud registration information is kept in AAI.

Postman collection have folder/entry for each step. Execute in this order.

**Postman -> K8s Cloud Region Registration -> Create**

- Create Complex
- Create Cloud Region
- Create Complex-Cloud Region Relationship
- Create Service
- Create Service Subscription
- Create Cloud Tenant
- Create Availability Zone
- Upload Connectivity Info

.. note:: For "Upload Connectivity Info" call you need to provide kubeconfig file of existing KUD cluster. You can find that kubeconfig on deployed KUD in directory `~/.kube/config` and can be easily retrieved e.g. via SCP. Please ensure that kubeconfig contains external IP of K8s cluster in kubeconfig and correct it, if it's not.

**SO Cloud region configuration**

SO database needs to be (manually) modified for SO to know that this particular cloud region is to be handled by multicloud. Values we insert needs to obviously match to the ones we populated into AAI.

The related code part in SO is here: `SO Cloud Region Selection`_
It's possible improvement place in SO to rather get this information directly from AAI.

.. note:: Please change credentials respectively to your installation. The required credentials can be retrieved with instruction `Retrieving logins and passwords of ONAP components`_

::

    kubectl -n onap exec onap-mariadb-galera-0 -it -- mysql -uroot -psecretpassword -D catalogdb
        select * from cloud_sites;
        insert into cloud_sites(ID, REGION_ID, IDENTITY_SERVICE_ID, CLOUD_VERSION, CLLI, ORCHESTRATOR) values("k8sregionfour", "k8sregionfour", "DEFAULT_KEYSTONE", "2.5", "clli2", "multicloud");
        select * from cloud_sites;
        exit

PART 3 - Execution of the Use Case
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This part contains all the steps to run the use case by using ONAP GUIs and Postman.

Following picture describes the overall sequential flow of the use case.

.. figure:: files/vFW_CNF_CDS/vFW_CNF_CDS_Flow.png
   :align: center

   vFW CNF CDS Use Case sequence flow.

3-1 Onboarding
..............

Creating Onboarding Package
+++++++++++++++++++++++++++

Whole content of this use case is stored into single git repository and ONAP user content package of onboarding package can be created with provided Makefile.

Complete content can be packaged to single onboarding package file in the following way:

.. note::  Requires Helm installed

::

  git clone https://gerrit.onap.org/r/demo
  cd heat/vFW_CNF_CDS/templates
  make

The output looks like:
::

  mkdir package/
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
  mv helm/*.tgz package/
  cp base/* package/
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
  mv cba/vFW_CDS_CNF.zip package/
  #Can't use .package extension or SDC will panic
  cd package/ && zip -r vfw_k8s_demo.zip .
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
  mv package/vfw_k8s_demo.zip .
  $

and package **vfw_k8s_demo.zip** file is created containing all sub-models.

Import this package into SDC and follow onboarding steps.

Service Creation with SDC
+++++++++++++++++++++++++

Service Creation in SDC is composed of the same steps that are performed by most other use-cases. For reference, you can relate to `vLB use-case`_

Onboard VSP

- Remember during VSP onboard to choose "Network Package" Onboarding procedure

Create VF and Service
Service -> Properties Assignment -> Choose VF (at right box):

- skip_post_instantiation_configuration - True
- sdnc_artifact_name - vnf
- sdnc_model_name - vFW_CNF_CDS
- sdnc_model_version - 1.0.45

Distribution Of Service
+++++++++++++++++++++++

Distribute service.

Verify in SDC UI if distribution was successful. In case of any errors (sometimes SO fails on accepting CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACT), try redistribution. You can also verify distribution for few components manually:

- SDC:

    SDC Catalog database should have our service now defined.

    **Postman -> LCM -> [SDC] Catalog Service**

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

    **Postman -> LCM -> [SO] Catalog DB Service xNFs**

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
                | vFW_CNF_CDS     | 1.0.45             | vnf                |
                +-----------------+--------------------+--------------------+
                1 row in set (0.00 sec)


.. note:: customization_uuid value is the modelCustomizationUuid of the VNF (serviceVnfs response in 2nd Postman call from SO Catalog DB)

- CDS:

    CDS should onboard CBA uploaded as part of VF.

    **Postman -> Distribution Verification -> [CDS] List CBAs**

    ::

                [
                        {
                                "blueprintModel": {
                                        "id": "c505e516-b35d-4181-b1e2-bcba361cfd0a",
                                        "artifactUUId": null,
                                        "artifactType": "SDNC_MODEL",
                                        "artifactVersion": "1.0.45",
                                        "artifactDescription": "Controller Blueprint for vFW_CNF_CDS:1.0.45",
                                        "internalVersion": null,
                                        "createdDate": "2020-05-29T06:02:20.000Z",
                                        "artifactName": "vFW_CNF_CDS",
                                        "published": "Y",
                                        "updatedBy": "Samuli Silvius <s.silvius@partner.samsung.com>",
                                        "tags": "Samuli Silvius, vFW_CNF_CDS"
                                }
                        }
                ]

    The list should have the matching entries with SDNC database:

    - sdnc_model_name == artifactName
    - sdnc_model_version == artifactVersion

        You can also use **Postman -> Distribution Verification -> [CDS] CBA Download** to download CBA for further verification but it's fully optional.

- K8splugin:

    K8splugin should onboard 4 resource bundles related to helm resources:

    **Postman -> Distribution Verification -> [K8splugin] List Resource Bundle Definitions**

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

3-2 CNF Instantiation
.....................

This is the whole beef of the use case and furthermore the core of it is that we can instantiate any amount of instances of the same CNF each running and working completely of their own. Very basic functionality in VM (VNF) side but for Kubernetes and ONAP integration this is the first milestone towards other normal use cases familiar for VNFs.

Use again Postman to trigger instantion from SO interface. Postman collection is automated to populate needed parameters when queries are run in correct order. If you did not already run following 2 queries after distribution (to verify distribution), run those now:

- **Postman -> LCM -> 1.[SDC] Catalog Service**
- **Postman -> LCM -> 2. [SO] Catalog DB Service xNFs**

Now actual instantiation can be triggered with:

**Postman -> LCM -> 3. [SO] Self-Serve Service Assign & Activate**

Follow progress with SO's GET request:

**Postman -> LCM -> 4. [SO] Infra Active Requests**

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


Progress can be followed also with `SO Monitoring`_ dashboard.

.. note::  In Frankfurt release *SO Monitoring* dashboard was removed from officail release and before it can be used it must be exposed and default user credentials must be configured


You can finally terminate this instance (now or later) with another call:

**Postman -> LCM -> 5. [SO] Service Delete**

Second instance Instantiation
+++++++++++++++++++++++++++++

To finally verify that all the work done within this demo, it should be possible to instantiate second vFW instance successfully.

Trigger new instance createion. You can use previous call or a separate one that will utilize profile templating mechanism implemented in CBA:

**Postman -> LCM -> 6. [SO] Self-Serve Service Assign & Activate - Second**

3-3 Results and Logs
....................

Now multiple instances of Kubernetes variant of vFW are running in target VIM (KUD deployment).

.. figure:: files/vFW_CNF_CDS/vFW_Instance_In_Kubernetes.png
   :align: center

   vFW Instance In Kubernetes

To review situation after instantiation from different ONAP components, most of the info can be found using Postman queries provided. For each query, example response payload(s) is/are saved and can be found from top right corner of the Postman window.

**Postman -> Instantiation verification**

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

FIXME - needs updated output with newest naming policy

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

All logs from the use case execution are here:

  :download:`logs <files/vFW_CNF_CDS/logs.zip>`

- `so-bpmn-infra_so-bpmn-infra_debug.log`
- SO openstack adapter
- `sdnc_sdnc_karaf.log`

  From karaf.log all requests (payloads) to CDS can be found by searching following string:

  ``'Sending request below to url http://cds-blueprints-processor-http:8080/api/v1/execution-service/process'``

- `cds-blueprints-processor_cds-blueprints-processor_POD_LOG.log`
- `multicloud-k8s_multicloud-k8s_POD_LOG.log`
- network naming

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

PART 4 - Summary and Future improvements needed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This use case made CNFs onboarding and instantiation a little bit easier and closer to "normal" VNF way. Also CDS resource resolution capabilities were taken into use (compared to earlier demos) together with SO's MACRO workflow.

CNF application in vFW (Helm charts) were divided to multiple Helm charts comply with vf-module structure of a Heat based VNF.

Future development areas for this use case and in general for CNF support could be:

- Automate manual initialization steps in to Robot init. Now all was done with Postman or manual step on command line.
- Automate use case in ONAP daily CI
- Include Closed Loop part of the vFW demo.
- Use multicloud/k8S API v2. Also consider profile concept future.
- Sync CDS model with `vFW_CNF_CDS Model`_ use case i.e. try to keep only single model regardless of xNF being Openstack or Kubernetes based.
- TOSCA based service and xNF models instead of dummy Heat wrapper. Won't work directly with current vf-module oriented SO workflows.
- vFW service with Openstack VNF and Kubernetes CNF
- Post instantiation configuration with Day 2 configuration APIs of multicloud/k8S API
- Auto generation of instantiation specific helm resources in CDS and their population through profiles


Multiple lower level bugs/issues were also found during use case development

- Distribution of Helm package directly from onboarding package `SDC-2776`_
- CDS: UAT testing is broken `CCSDK-2155`_

.. _ONAP Deployment Guide: https://docs.onap.org/en/frankfurt/submodules/oom.git/docs/oom_quickstart_guide.html#quick-start-label
.. _CDS Modeling Concepts: https://wiki.onap.org/display/DW/Modeling+Concepts
.. _vLB use-case: https://wiki.onap.org/pages/viewpage.action?pageId=71838898
.. _vFW_CNF_CDS Model: https://git.onap.org/demo/tree/heat/vFW_CNF_CDS?h=frankfurt
.. _vFW CDS Dublin: https://wiki.onap.org/display/DW/vFW+CDS+Dublin
.. _vFW CBA Model: https://git.onap.org/ccsdk/cds/tree/components/model-catalog/blueprint-model/service-blueprint/vFW?h=frankfurt
.. _vFW_Helm Model: https://git.onap.org/multicloud/k8s/tree/kud/demo/firewall?h=elalto
.. _vFW_NextGen: https://git.onap.org/demo/tree/heat/vFW_NextGen?h=elalto
.. _vFW EDGEX K8S: https://onap.readthedocs.io/en/elalto/submodules/integration.git/docs/docs_vfw_edgex_k8s.html
.. _vFW EDGEX K8S In ONAP Wiki: https://wiki.onap.org/display/DW/Deploying+vFw+and+EdgeXFoundry+Services+on+Kubernets+Cluster+with+ONAP
.. _KUD readthedocs: https://docs.onap.org/en/frankfurt/submodules/multicloud/k8s.git/docs
.. _KUD in Wiki: https://wiki.onap.org/display/DW/Kubernetes+Baremetal+deployment+setup+instructions
.. _Multicloud k8s gerrit: https://gerrit.onap.org/r/q/status:open+project:+multicloud/k8
.. _KUD subproject in github: https://github.com/onap/multicloud-k8s/tree/master/kud
.. _KUD Jenkins ci/cd verification: https://jenkins.onap.org/job/multicloud-k8s-master-kud-deployment-verify-shell/
.. _SO Cloud Region Selection: https://git.onap.org/so/tree/adapters/mso-openstack-adapters/src/main/java/org/onap/so/adapters/vnf/MsoVnfPluginAdapterImpl.java?h=elalto#n1149
.. _SO Monitoring: https://wiki.onap.org/display/DW/SO+Monitoring+User+Guide
.. _Jira Epic: https://jira.onap.org/browse/INT-1184
.. _Data Dictionary: https://git.onap.org/demo/tree/heat/vFW_CNF_CDS/templates/cba-dd.json?h=frankfurt
.. _Helm Healer: https://git.onap.org/oom/offline-installer/tree/tools/helm-healer.sh
.. _CDS UAT Testing: https://wiki.onap.org/display/DW/Modeling+Concepts
.. _postman.zip: files/vFW_CNF_CDS/postman.zip
.. _logs.zip: files/vFW_CNF_CDS/logs.zip
.. _SDC-2776: https://jira.onap.org/browse/SDC-2776
.. _MULTICLOUD-941: https://jira.onap.org/browse/MULTICLOUD-941
.. _CCSDK-2155: https://jira.onap.org/browse/CCSDK-2155
.. _infra_workload: https://docs.onap.org/projects/onap-multicloud-framework/en/latest/specs/multicloud_infra_workload.html?highlight=multicloud
.. _SDNC-1116: https://jira.onap.org/browse/SDNC-1116
.. _SO-2727: https://jira.onap.org/browse/SO-2727
.. _SDNC-1109: https://jira.onap.org/browse/SDNC-1109
.. _SDC-2776: https://jira.onap.org/browse/SDC-2776
.. _INT-1255: https://jira.onap.org/browse/INT-1255
.. _SDNC-1130: https://jira.onap.org/browse/SDNC-1130
