.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. Copyright 2018 ONAP

.. _docs_vfw_edgex_multicloud_k8s:

vFW/Edgex with Multicloud Kubernetes Plugin: Setting Up and Configuration
-------------------------------------------------------------------------

Description
~~~~~~~~~~~
This use case covers the deployment of vFW and Edgex HELM Charts in a Kubernetes based cloud region via the multicloud-k8s plugin.
The multicloud-k8s plugin provides APIs to upload self contained HELM Charts that can be customized via the profile api and later installed in a particular cloud region.

**Useful Links**

`Multicloud K8s API Page <https://wiki.onap.org/display/DW/MultiCloud+K8s-Plugin-service+API>`_

`Edgex Integration Test Status <https://wiki.onap.org/display/DW/Deploy+EdgeXFoundry+Helm+Chart+using+Multicloud+K8s+Plugin+in+Kubernetes+Cloud>`_

`vFW Integration Test Status <https://wiki.onap.org/pages/viewpage.action?pageId=64000842>`_

`Deploying vFW and EdgexFoundry on Kubernetes with ONAP <https://wiki.onap.org/display/DW/Deploying+vFw+and+EdgeXFoundry+Services+on+Kubernets+Cluster+with+ONAP>`_



Setting Up and Installation
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Instructions for setting up and deploying the vFW and EdgeXFoundry HELM Charts can be found here: https://wiki.onap.org/display/DW/Deploying+vFw+and+EdgeXFoundry+Services+on+Kubernets+Cluster+with+ONAP

Install ONAP via OOM using the deploy script in the integration repo. Instructions for this can be found in this link https://onap.readthedocs.io/en/latest/submodules/oom.git/docs/oom_cloud_setup_guide.html.

When the installation is complete (all the pods are either in running or completed state)

