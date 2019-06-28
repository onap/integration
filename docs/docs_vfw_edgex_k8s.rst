.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. Copyright 2018 ONAP

.. _docs_vfw_edgex_multicloud_k8s:

vFW/Edgex with Multicloud Kubernetes Plugin: Setting Up and Configuration
-------------------------------------------------------------------------

Description
~~~~~~~~~~~
This use case covers the deployment of vFW and Edgex HELM Charts in a Kubernetes based cloud region via the multicloud-k8s plugin.
The multicloud-k8s plugin provides APIs to upload self-contained HELM Charts that can be customized via the profile API and later installed in a particular cloud region.

When the installation is complete (all the pods are either in running or completed state)

vFW Helm Chart link:
--------------------

https://github.com/onap/multicloud-k8s/tree/master/kud/demo/firewall

EdgeXFoundry Helm Chart link:
-----------------------------

https://github.com/onap/multicloud-k8s/tree/master/kud/tests/vnfs/edgex/helm/edgex


**Create CSAR with Helm chart as an artifact**
----------------------------------------------

The CSAR is a heat template package with Helm chart in it. The basic package
consists of an **environment file**, **base_dummy.yaml file** (example),
**MANIFEST.json** and the **tar.gz** file (of Helm chart).
We need to zip all of these files before onboarding.
One thing to pay much attention to is the naming convention which must
be followed while making the tgz.
**NOTE: The Naming convention is for the helm chart tgz file.**

**Naming convention follows the format:**

<free format string>\_\ ***cloudtech***\ \_<technology>\_<subtype>.extension

1. *Cloudtech:* is a fixed pattern and should not be changed if not
   necessary
2. *Technology:* k8s, azure, aws
3. *Subtype*: charts, day0, config template
4. *Extension*: zip, tgz, csar

NOTE: The .tgz file must be a tgz created from the top level helm chart
folder. I.e. a folder that contains a Chart.yaml file in it.


Listed below is an example of the contents inside a heat template
package
::

     $ vfw-k8s/package$ ls
      MANIFEST.json base_dummy.env base_dummy.yaml
      vfw_cloudtech_k8s_charts.tgz vfw_k8s_demo.zip




**MANIFEST.json**
~~~~~~~~~~~~~~~~~

Key thing is note the addition of cloud artifact
::

  type: "CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACTS"

  {
    "name": "",
    "description": "",
    "data": [
        {
            "file": "base_dummy.yaml",
            "type": "HEAT",
            "isBase": "true",
            "data": [
                {
                    "file": "base_dummy.env",
                    "type": "HEAT_ENV"
                }
            ]
        },
        {
            "file": "vfw_cloudtech_k8s_charts.tgz",
            "type": "CLOUD_TECHNOLOGY_SPECIFIC_ARTIFACTS"
        }
	]
  }

**Base\_dummy.yaml**
~~~~~~~~~~~~~~~~~~~~~
Designed to be minimal HEAT template

::

 ##==================LICENSE_START========================================
  ##
  ## Copyright (C) 2019 Intel Corporation
  ## SPDX-License-Identifier: Apache-2.0
  ##
  ##==================LICENSE_END===========================================

  heat_template_version: 2016-10-14
  description: Heat template to deploy dummy VNF

  parameters:
    dummy_name_0:
      type: string
      label: name of vm
      description: Dummy name

    vnf_id:
      type: string
	    label: id of vnf
      description: Provided by ONAP

    vnf_name:
      type: string
      label: name of vnf
      description: Provided by ONAP

    vf_module_id:
      type: string
      label: vnf module id
      description: Provided by ONAP

    dummy_image_name:
	  type: string
      label: Image name or ID
      description: Dummy image name

    dummy_flavor_name:
      type: string
      label: flavor
      description: Dummy flavor

  resources:
    dummy_0:
      type: OS::Nova::Server
      properties:
        name: { get_param: dummy_name_0 }
        image: { get_param: dummy_image_name }
        flavor: { get_param: dummy_flavor_name } metadata: { vnf_name: { get_param: vnf_name }, vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}






**Base\_dummy.env**

::

  parameters:
    vnf_id: PROVIDED_BY_ONAP
    vnf_name: PROVIDED_BY_ONAP
    vf_module_id: PROVIDED_BY_ONAP
    dummy_name_0: dummy_1_0
    dummy_image_name: dummy
    dummy_flavor_name: dummy.default

**Onboard the CSAR**
--------------------

For onboarding instructions please refer to steps 4-9 from the document
`here <https://wiki.onap.org/display/DW/vFWCL+instantiation%2C+testing%2C+and+debuging>`__.

**Steps for installing KUD Cloud**
----------------------------------

Follow the link to install KUD Kubernetes Deployment. KUD contains all
the packages required for running vfw use case.

Kubernetes Baremetal deployment instructions here_

.. _here: https://wiki.onap.org/display/DW/Kubernetes+Baremetal+deployment+setup+instructions/

**REGISTER KUD CLOUD REGION with K8s-Plugin**
---------------------------------------------

API to support Reachability for Kubernetes Cloud

**The command to POST connectivity info**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::

  {
    "cloud-region" : "<name>",   // Must be unique across
    "cloud-owner" :  "<owner>",
    "other-connectivity-list" : {
           }

This is a multipart upload and here is how you do the POST for this.

#Using a json file (eg: post.json) containing content as above
::

 curl -i -F "metadata=<post.json;type=application/json" -F file=@
  /home/ad_kkkamine/.kube/config -X POST http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/connectivity-info

**Command to GET Connectivity Info**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  curl -i -X GET http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/connectivity-info/{name}


**Command to DELETE Connectivity Info**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  curl -i -X GET http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/connectivity-info/{name}


**Command to UPDATE/PUT Connectivity Info**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  curl -i -X GET http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/connectivity-info/{name}

**Register KUD Cloud region with AAI**
--------------------------------------

With k8s cloud region, we need to add a tenant to the k8s cloud region.
The 'easy' way is to have the ESR information (in step 1 of cloud
registration) point to a real OpenStack tenant (e.g. the OOF tenant in
the lab where we tested).

This will cause multicloud to add the tenant to the k8s cloud region and
then, similar to #10 in the documentation
`here <https://onap.readthedocs.io/en/casablanca/submodules/integration.git/docs/docs_vfwHPA.html#docs-vfw-hpa>`__,
the service-subscription can be added to that object.

NOTE: use same name cloud-region and cloud-owner name

An example is shown below for K8s cloud but following the steps 1,2,3
from
`here <https://onap.readthedocs.io/en/latest/submodules/multicloud/framework.git/docs/multicloud-plugin-windriver/UserGuide-MultiCloud-WindRiver-TitaniumCloud.html#tutorial-onboard-instance-of-wind-river-titanium-cloud>`__.
The sample input below is for k8s cloud type.

**Step 1 - Cloud Registration/ Create a cloud region to represent the instance.**


Note: highlighted part of the body refers to an existing OpenStack
tenant (OOF in this case). Has nothing to do with the K8s cloud region
we are adding.

::

 PUT https://{{AAI1_PUB_IP}}:{{AAI1_PUB_PORT}}/aai/v13/cloud-infrastructure/cloud-regions/cloud-region/k8scloudowner4/k8sregionfour
  {
	"cloud-owner": "k8scloudowner4",
	"cloud-region-id": "k8sregionfour",
	"cloud-type": "k8s",
	"owner-defined-type": "t1",
	"cloud-region-version": "1.0",
	"complex-name": "clli1",
	"cloud-zone": "CloudZone",
	"sriov-automation": false,
    "cloud-extra-info":"{\"openstack-region-id\":\"k8sregionthree\"}",
	"esr-system-info-list": {
               "esr-system-info": [
                              {
                                             	"esr-system-info-id": "55f97d59-6cc3-49df-8e69-926565f00066",
                                             	"service-url": "http://10.12.25.2:5000/v3",
                                             	"user-name": "demo",
                                             	"password": "onapdemo",
                                             	"system-type": "VIM",
                                             	"ssl-insecure": true,
                                             	"cloud-domain": "Default",
                                             	"default-tenant": "OOF",
                                             	"tenant-id": "6bbd2981b210461dbc8fe846df1a7808",
                                             	"system-status": "active"
                                             }
                              ]
	}
  }

**Step 2  add a complex to the cloud**

Note: just adding one that exists already

::

 PUT https://{{AAI1_PUB_IP}}:{{AAI1_PUB_PORT}}/aai/v13/cloud-infrastructure/cloud-regions/cloud-region/k8scloudowner4/k8sregionfour/relationship-list/relationship
  {
  "related-to": "complex",
  "related-link": "/aai/v13/cloud-infrastructure/complexes/complex/clli1",
  "relationship-data": [
    {
       "relationship-key": "complex.physical-location-id",
       "relationship-value": "clli1"
    }
  ]
  }

**Step 3 - Trigger the Multicloud plugin registration process**


::

  POST http://{{MSB_IP}}:{{MSB_PORT}}/api/multicloud-titaniumcloud/v1/k8scloudowner4/k8sregionfour/registry


This registers the K8S cloud with Multicloud  it also reaches out and
adds tenant information to the cloud (see example below  you'll see all
kinds of flavor, image information that is associated with the OOF
tenant).

If we had not done it this way, then wed have to go in to AAI at this
point and manually add a tenant to the cloud region. The first time I
tried this (k8s region one), I just made up some random tenant id and
put it in.)

The tenant is there so you can add the service-subscription to it:

**Making a Service Type:**

::

 PUT https://{{AAI1_PUB_IP}}:{{AAI1_PUB_PORT}}/aai/v13/service-design-and-creation/services/service/vfw-k8s
  {
              "service-description": "vfw-k8s",
              "service-id": "vfw-k8s"
  }

Add subscription to service type to the customer (Demonstration in this
case  which was already created by running the robot demo scripts)

::

 PUT https://{{AAI1_PUB_IP}}:{{AAI1_PUB_PORT}}/aai/v16/business/customers/customer/Demonstration/service-subscriptions/service-subscription/vfw-k8s
  {
           "service-type": "vfw-k8s"
  }

Add Service-Subscription to the tenant (resource-version changes based
on actual value at the time):

::

 PUT https://{{AAI1_PUB_IP}}:{{AAI1_PUB_PORT}}/aai/v16/cloud-infrastructure/cloud-regions/cloud-region/k8scloudowner4/k8sregionfour/tenants/tenant/6bbd2981b210461dbc8fe846df1a7808?resource-version=1559345527327
  {
  "tenant-id": "6bbd2981b210461dbc8fe846df1a7808",
  "tenant-name": "OOF",
  "resource-version": "1559345527327",
  "relationship-list": {
       "relationship": [
           {
               "related-to": "service-subscription",
               "relationship-label": "org.onap.relationships.inventory.Uses",
               "related-link": "/aai/v13/business/customers/customer/Demonstration/service-subscriptions/service-subscription/vfw-k8s",
               "relationship-data": [
                   {
                       "relationship-key": "customer.global-customer-id",
                       "relationship-value": "Demonstration"
                   },
                   {
                       "relationship-key": "service-subscription.service-type",
                       "relationship-value": "vfw-k8s"
                   }
               ]
           }
    ]
  }
  }

**Distribute the CSAR**
-----------------------
Onboard a service it gets stored in SDC final action is distributed. SO
and other services are notified sdc listener in the multicloud sidecar.
When distribution happens it takes tar.gz file and uploads to k8s
plugin.

**Create Profile Manually**
---------------------------

K8s-plugin artifacts start in the form of Definitions. These are nothing
but Helm Charts wrapped with some metadata about the chart itself. Once
the Definitions are created, we are ready to create some profiles so
that we can customize that definition and instantiate it in Kubernetes.

NOTE: Refer this link_ for complete API lists and
documentation:

.. _link : https://wiki.onap.org/display/DW/MultiCloud+K8s-Plugin-service+API

A profile consists of the following:

**manifest.yaml**

- Contains the details for the profile and everything contained within

A **HELM** values override yaml file.

- It can have any name as long as it matches the corresponding entry in the **manifest.yaml**

Any number of files organized in a folder structure

- All these files should have a corresponding entry in **manifest.yaml** file

**Creating a Profile Artifact**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

 > cd multicloud-k8s/kud/tests/vnfs/testrb/helm/profile
  > find .
  manifest.yaml
  override_values.yaml
  testfol
  testfol/subdir
  testfol/subdir/deployment.yaml

  #Create profile tar.gz
  > cd profile
  > tar -cf profile.tar *
  > gzip profile.tar
  > mv profile.tar.gz ../

The manifest file contains the following

::

 ---
 version: v1
 type:
 values: "values_override.yaml"
 configresource:
   - filepath: testfol/subdir/deployment.yaml
     chartpath: vault-consul-dev/templates/deployment.yaml

Note: values: "values\_override.yaml" can **be** empty **file** **if**
you are creating **a** dummy **profile**

Note: A dummy profile does not need any customization. The following is
optional in the manifest file.

::

 configresource:
   - filepath: testfol/subdir/deployment.yaml
     chartpath: vault-consul-dev/templates/deployment.yaml


With this information, we are ready to upload the profile with the
following JSON data

::

 {
   "rb-name": "test-rbdef",
   "rb-version": "v1",
   "profile-name": "p1",
   "release-name": "r1", //If release-name is not provided, profile-name will be used
   "namespace": "testnamespace1",
   "kubernetes-version": "1.12.3"
 }


**Command to create (POST) Profile**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

 curl -i -d @create_rbprofile.json -X POST http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/rb/definition/test-rbdef/v1/profile



**Command to UPLOAD artifact for Profile**

::

 curl -i --data-binary @profile.tar.gz -X POST http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/rb/definition/test-rbdef/v1/profile/p1/content



**Command to GET Profiles**

::

 curl -i http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/rb/definition/test-rbdef/v1/profile
  # Get one Profile
  curl -i http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/rb/definition/test-rbdef/v1/profile/p1



**Command to DELETE Profile**
::

 curl -i -X DELETE http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/rb/definition/test-rbdef/v1/profile/p1


**Instantiation**
-----------------

Instantiation is done by SO. SO then talks to Multi Cloud-broker via MSB
and that in turn looks up the cloud region in AAI to find the endpoint.
If k8sregion one is registered with AAI and SO makes a call with that,
then the broker will know that it needs to talk to k8s-plugin based on
the type of the registration.

**Instantiate the created Profile via the following REST API**

::

 Using the following JSON:
  {
   "cloud-region": "kud",
   "profile-name": "p1",
   "rb-name":"test-rbdef",
   "rb-version":"v1",
   "labels": {
   }
  }

**NOTE**: Make sure that the namespace is already created before
instantiation.

Instantiate the profile with the ID provided above

**Command to Instantiate a Profile**

::

 curl -d @create_rbinstance.json http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/instance


The command returns the following JSON

::

 {
 "id": "ZKMTSaxv",
 "rb-name": "mongo",
 "rb-version": "v1",
 "profile-name": "profile1",
 "cloud-region": "kud",
 "namespace": "testns",
 "resources": [
   {
     "GVK": {
       "Group": "",
       "Version": "v1",
       "Kind": "Service"
     },
     "Name": "mongo"
   },
   {
     "GVK": {
       "Group": "",
       "Version": "v1",
       "Kind": "Service"
     },
     "Name": "mongo-read"
   },
   {
     "GVK": {
       "Group": "apps",
       "Version": "v1beta1",
       "Kind": "StatefulSet"
     },
     "Name": "profile1-mongo"
   }
 ]
 }

**Delete Instantiated Kubernetes resources**

The **id** field from the returned JSON can be used to **DELETE** the
resources created in the previous step. This executes a Delete operation
using the Kubernetes API.

::

 curl -X DELETE http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/instance/ZKMTSaxv


**GET Instantiated Kubernetes resources**


The **id field** from the returned JSON can be used to **GET** the
resources created in the previous step. This executes a get operation
using the Kubernetes API.

::

 curl -X GET http://MSB_NODE_IP:30280/api/multicloud-k8s/v1/v1/instance/ZKMTSaxv


`*\ https://github.com/onap/oom/blob/master/kubernetes/multicloud/resources/config/provider-plugin.json <https://github.com/onap/oom/blob/master/kubernetes/multicloud/resources/config/provider-plugin.json>`__

**Create User parameters**

We need to create parameters that ultimately get translated as:

::

 "user_directives": {
 "attributes": [
 {
 "attribute_name": "definition-name",
 "attribute_value": "edgex"
 },
 {
 "attribute_name": "definition-version",
 "attribute_value": "v1"
 },
 {
 "attribute_name": "profile-name",
 "attribute_value": "profile1"
 }
 ]
 }
