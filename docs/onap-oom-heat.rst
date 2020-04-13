Integration Environment Installation
-------------------------------------

ONAP is deployed on top of kubernetes through the OOM installer.
Kubernetes can be installed on bare metal or on different environments such as
OpenStack (private or public cloud), Azure, AWS,..

The integration team maintains a heat template to install ONAP on OpenStack.
This template creates the needed resources (VMs, networks, security groups,
...) in order to support a HA Kubernetes then a full ONAP installation.

Sample OpenStack RC (credential) files environment files or deployment scripts
are provided, they correspond to files used on windriver environment.
This environment is used by the integration team to validate the installation,
perform tests and troubleshoot.

If you intend to deploy your own environment, they can be used as reference but
must be adapted according to your context.

Source files
~~~~~~~~~~~~

- HEAT template files: https://git.onap.org/integration/tree/deployment/heat/onap-rke?h=elalto
- Sample OpenStack RC file: https://git.onap.org/integration/tree/deployment/heat/onap-rke/env/windriver/Integration-SB-00-openrc?h=elalto
- Sample environment file: https://git.onap.org/integration/tree/deployment/heat/onap-rke/env/windriver/onap-oom.env?h=elalto
- Deployment script: https://git.onap.org/integration/tree/deployment/heat/onap-rke/scripts/deploy.sh?h=elalto


Heat Template Description
~~~~~~~~~~~~~~~~~~~~~~~~~

The ONAP Integration Project provides a sample HEAT template that
fully automates the deployment of ONAP using OOM as described in
OOM documentation (https://docs.onap.org/en/elalto/guides/onap-developer/settingup/index.html#installing-onap).

The ONAP OOM HEAT template deploys the entire ONAP platform.  It spins
up an HA-enabled Kubernetes cluster, and deploys ONAP using OOM onto
this cluster.

- 1 Shared NFS server (called Rancher VM for legacy reasons)
- 3 orch VMs for Kubernetes HA controller and etcd roles
- 12 k8s VMs for Kubernetes HA worker roles

See OOM documentation for details.


Quick Start
~~~~~~~~~~~

Using the Wind River lab configuration as an example, here is what
you need to do to deploy ONAP:

::

   git clone https://git.onap.org/integration
   cd integration/deployment/heat/onap-rke/
   source ./env/windriver/Integration-SB-00-openrc
   ./scripts/deploy.sh ./env/windriver/onap-oom.env


Environment and RC files
~~~~~~~~~~~~~~~~~~~~~~~~

Before deploying ONAP to your own environment, it is necessary to
customize the environment and RC files.  You should make a copy of the
sample RC and environment files shown above and customize the values
for your specific OpenStack environments.

The environment file contains a block called integration_override_yaml.

The content of this block will be used by OOM to overwrite some parts of its
installation parameters used in the helm charts.

This file may deal with:

* Cloud adaptation (use the defined flavors, available images)
* Proxies (apt, docker,..)
* Pre-defined resources for use cases (networks, tenant references)
* performance tuning (initialization timers)

Performance tuning reflects the adaptation to the hardware at a given time.
The lab may evolve and the timers shall follow.

Be sure to customize the necessary values within this block to match your
OpenStack environment as well.

**Notes on select parameters**

::

   apt_proxy: 10.12.5.2:8000
   docker_proxy: 10.12.5.2:5000

   rancher_vm_flavor: m1.large
   k8s_vm_flavor: m1.xlarge
   etcd_vm_flavor: m1.medium # not currently used
   orch_vm_flavor: m1.medium

   key_name: onap_key

   helm_deploy_delay: 2.5m

It is recommended that you set up an apt proxy and a docker proxy
local to your lab.  If you do not wish to use such proxies, you can
set the apt_proxy and docker_proxy parameters to the empty string "".

rancher_vm_flavor needs to have 8 GB of RAM.
k8s_vm_flavor needs to have at least 16 GB of RAM.
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
- Hosts the /dockerdata-nfs/ NFS export shared by all the k8s VMs for persistent volumes
- git clones the oom repo into /root/oom
- git clones the integration repo into /root/integration
- Creates the helm override file at /root/integration-override.yaml
- Deploys ONAP using helm and OOM
