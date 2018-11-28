.. _onap-oom-heat:

ONAP OOM HEAT Template
----------------------


Source files
~~~~~~~~~~~~

- HEAT template files: https://git.onap.org/integration/tree/deployment/heat/onap-oom?h=casablanca
- Sample OpenStack RC file: https://git.onap.org/integration/tree/deployment/heat/onap-oom/env/windriver/Integration-SB-00-openrc?h=casablanca
- Sample environment file: https://git.onap.org/integration/tree/deployment/heat/onap-oom/env/windriver/onap-oom.env?h=casablanca
- Deployment script: https://git.onap.org/integration/tree/deployment/heat/onap-oom/scripts/deploy.sh?h=casablanca


Description
~~~~~~~~~~~

The ONAP Integration Project provides a sample HEAT template that
fully automates the deployment of ONAP using OOM as described in
:ref:`ONAP Operations Manager (OOM) over Kubernetes<installing-onap>`.

The ONAP OOM HEAT template deploys the entire ONAP platform.  It spins
up an HA-enabled Kubernetes cluster, and deploys ONAP using OOM onto
this cluster.
- 1 Rancher VM that also serves as a shared NFS server
- 3 etcd VMs for the Kubernetes HA etcd plane
- 2 orch VMs for the Kubernetes HA orchestration plane
- 12 k8s VMs for the Kubernetes HA compute hosts


Quick Start
~~~~~~~~~~~

Using the Wind River lab configuration as an example, here is what
you need to do to deploy ONAP:

::

   git clone https://git.onap.org/integration
   cd integration/deployment/heat/onap-oom/
   source ./env/windriver/Integration-SB-00-openrc
   ./scripts/deploy.sh ./env/windriver/onap-oom.env


Environment and RC files
~~~~~~~~~~~~~~~~~~~~~~~~

Before deploying ONAP to your own environment, it is necessary to
customize the environment and RC files.  You should make a copy of the
sample RC and environment files shown above and customize the values
for your specific OpenStack environments.

The environment file contains a block called
integration_override_yaml.  The content of this block will be created
as the file integration_override.yaml in the deployed Rancher VM, and
used as the helm override files during the OOM deployment.  Be sure to
customize the necessary values within this block to match your
OpenStack environment as well.

**Notes on select parameters**

::

   apt_proxy: 10.12.5.2:8000
   docker_proxy: 10.12.5.2:5000

   rancher_vm_flavor: m1.large
   k8s_vm_flavor: m1.xlarge
   etcd_vm_flavor: m1.medium
   orch_vm_flavor: m1.medium

   key_name: onap_key

   helm_deploy_delay: 2.5m

It is recommended that you set up an apt proxy and a docker proxy
local to your lab.  If you do not wish to use such proxies, you can
set the apt_proxy and docker_proxy parameters to the empty string "".

rancher_vm_flavor needs to have 8 GB of RAM.
k8s_vm_flavor needs to have 16 GB of RAM.
etcd_vm_flavor needs to have 4 GB of RAM.
orch_vm_flavor needs to have 4 GB of RAM.

By default the template assumes that you have already imported a
keypair named "onap_key" into your OpenStack environment.  If the
desired keypair has a different name, change the key_name parameter.

The helm_deploy_delay parameter introduces a delay in-between the
deployments of each ONAP helm subchart to help alleviate system load or
contention issues caused by trying to spin up too many pods
simultaneously.  The value of this parameter is passed to the Linux
"sleep" command.  Adjust this parameter based on the performance and
load characteristics of your OpenStack environment.


Exploring the Rancher VM
~~~~~~~~~~~~~~~~~~~~~~~~

The Rancher VM that is spun up by this HEAT template serves the
following key roles:
- Installaion of the Rancher server
- Hosts the /dockerdata-nfs/ NFS export shared by all the k8s VMs for persistent volumes
- git clones the oom repo into /root/oom
- git clones the integration repo into /root/integration
- Creates the helm override file at /root/integration-override.yaml
- Deploys ONAP using helm and OOM



.. _deploy-updated-manifest:

Deploying an Updated Docker Manifest
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some late changes in the ONAP docker images did not make it in time
for the Casablanca release.  Depending on the Use Case you are trying
deploy, you may need to update the docker image manifest with certain
newer docker image versions than what was shipped with ONAP Casablanca
release.

The ONAP integration repo contains a script that will apply the docker
versions specified in a given manifest into the OOM helm chart
definitions.

To apply an updated manifest (on the Rancher VM):

::

   cd /root/integration/version-manifest/src/main/resources
   cp docker-manifest.csv docker-manifest-custom.csv

   # customize docker-manifest-custom.csv per your requirements

   ../scripts/update-oom-image-versions.sh ./docker-manifest-custom.csv /root/oom/

   cd /root/oom/kubernetes/
   git diff # verify that the desired docker image changes are applied successfully
   make all # recompile the helm charts

After that you can update or redeploy ONAP OOM as described here:

.. toctree::
   :maxdepth: 1
   :titlesonly:

   ../../../../submodules/oom.git/docs/oom_quickstart_guide.rst
