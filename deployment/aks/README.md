# ONAP on AKS

## License

Copyright 2019 AT&T Intellectual Property. All rights reserved.

This file is licensed under the CREATIVE COMMONS ATTRIBUTION 4.0 INTERNATIONAL LICENSE

Full license text at https://creativecommons.org/licenses/by/4.0/legalcode


## About

ONAP on AKS will orchestrate an Azure Kubernetes Service (AKS) deployment, a DevStack deployment, an ONAP + NFS deployment, as well as configuration to link the Azure resources together. After ONAP is installed, a cloud region will also be added to ONAP with the new DevStack details that can be used to instantiate a VNF. 


### Pre-Reqs

The following software is required to be installed:

- bash
- [helm](https://helm.sh/docs/using_helm/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [azure command line](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
- make, openjdk-8-jdk, openjdk-8-jre (``apt-get update && apt-get install make openjdk-8-jre openjdk-8-jdk``)

Check the [OOM Cloud Setup Guide](https://docs.onap.org/en/latest/submodules/oom.git/docs/oom_cloud_setup_guide.html#cloud-setup-guide-label) for the versions of kubectl and helm to use. 

After installing the above software, run ``az login`` and follow the instructions to finalize the azure command line installation. **You'll need to be either an owner or co-owner of the azure subscription, or some of the deployment steps may not complete successfully**. If you have multiple azure subscriptions, use ``az account set --subscription <subscription name>`` prior to running ``az login`` so that resources are deployed to the correct subscription. See [the azure docs](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest) for more details on using the azure command line.


### The following resources will be created in Azure

- Kubernetes cluster via AKS (Azure Kubernetes Service)
- VM running NFS server application
- VM running latest DevStack version


## Usage


### cloud.sh


``cloud.sh`` is the main driver script, and deploys a Kubernetes Cluster (AKS), DevStack, NFS, and bootstraps ONAP with configuration needed to instantiate a VNF. The script creates ONAP in "about" an hour. 

```

$ ./cloud.sh --help
./cloud.sh [options]
 
 
options:
-f, --no-prompt           executes with no prompt for confirmation
-n, --no-install          don't install ONAP
-o, --override            create integration override for robot configuration
-d, --no-validate         dont validate pre-reqs before executing deployment
-p, --post-install        execute post-install scripts
-h, --help                provide brief overview of script
 
This script deploys a cloud environment in Azure.
It: 
- Uses Azure Kubernetes Service (AKS) to bootstrap a kubernetes cluster.
- Creates a VM to be used as NFS storage.
- Creates a VM and installs DevStack, to be used with ONAP.
- Creates an openstack cli pod that can be used for cli access to devstack
- Creates an integration-override.yaml file to configure robot
- Launches ONAP onto the AKS Cluster via OOM.
- Configures Networking, SSH Access, and Security Group Rules

```

#### Example

```
$ ./cloud.sh --override
```


### cloud.conf


This file contains the parameters that will be used when executing ``cloud.sh``. The parameter ``BUILD`` will be generated at runtime.

For an example with all of the parameters filled out, check [here](./cloud.conf.example). You can copy this and modify to suit your deployment. The parameters that MUST be modified from ``cloud.conf.example`` are ``USER_PUBLIC_IP_PREFIX`` and ``BUILD_DIR``.

All other parameters will work out of the box, however you can also customize them to suit your own deployment. See below for a description of the available parameters and how they're used.


```

# The variable $BUILD will be generated dynamically when this file is sourced

RANDOM_STRING=`cat /dev/urandom | env LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 4`
BUILD=                     This is just a helper variable to create a random string to assign to various resources. Look at cloud.conf.example to see how it can be used.

# GLOBAL PARAMS
LOCATION=                  Location in Azure to deploy resources
USER_PUBLIC_IP_PREFIX=     Space delimited list of ip addresses/CIDR blocks that will be added to azure secuirty groups for access. Add the CIDR blocks to grant access for ssh, ONAP portal, and DevStack horizon access.
BUILD_DIR=                 /path/to/directory where build files, artifacts, and other files will be created.

# AKS PARAMS
AKS_RESOURCE_GROUP_NAME=   Name of resource group in azure that will be created for the AKS resource. Must not already exist.
AKS_NAME=                  Name of AKS resource.
AKS_K8_VERSION=            Kubernetes version, use az aks get-versions --location <location> to see available versions.
AKS_NODE_COUNT=            Number of nodes that will comprise the AKS cluster.
AKS_NODE_SIZE=             Flavor to use for AKS nodes.
AKS_VNET_NAME=             Name of VNET that AKS nodes will attach to.
AKS_DNS_PREFIX=            DNS prefix that will be used by kubernetes dns service.
AKS_POD_CIDR=              CIDR used for pod ip allocation.
AKS_NODE_CIDR=             CIDR used for node ip allocation.
AKS_SERVICE_CIDR=          CIDR used for kubernetes service allocation.
AKS_DNS_IP=                IP address to assign to kubernetes dns service. Should be from AKS_SERVICE_CIDR range.
AKS_ADMIN_USER=            User name that will be created on AKS nodes. Use this user to ssh into AKS nodes if needed.

# NFS PARAMS
NFS_NAME=                  Name of NFS VM created in Azure.
NFS_RG=                    Name of resource group that will be created in Azure for the NFS VM. Must not already exist.
NFS_VM_SIZE=               Flavor to use for NFS VM.
NFS_LOCATION=              Azure location to deploy NFS VM.
NFS_CIDR=                  CIDR for NFS VNET.
NFS_ADMIN_USER=            User name that will be created on NFS VM. Use this to ssh to NFS VM if needed.
NFS_VNET_NAME=             Name of VNET that NFS VM will attach to. 
NFS_SUBNET_NAME=           Name of SUBNET attached to NFS_VNET_NAME.
NFS_DISK_SIZE=             Size of OS Disk for NFS VM.

# DEVSTACK PARAMS
DEVSTACK_NAME=             Name of DevStack VM created in Azure.
DEVSTACK_RG=               Name of resource group that will be created in Azure for the DevStack VM. Must not already exist.
DEVSTACK_VM_SIZE=          Flavor to use for DevStack VM. 
DEVSTACK_LOCATION=         Azure location to deploy DevStack VM.
DEVSTACK_CIDR=             CIDR for DevStack VNET.
DEVSTACK_PRIVATE_IP=       IP to allocate to DevStack VM. This should be from DEVSTACK_CIDR range, and will be used to communicate with DevStack from ONAP.
DEVSTACK_ADMIN_USER=       User name that will be created on DevStack VM. Use this to ssh to DevStack VM if needed.
DEVSTACK_VNET_NAME=        Name of VNET that DevStack VM will attach to. 
DEVSTACK_SUBNET_NAME=      Name of SUBNET attached to DEVSTACK_VNET_NAME.
DEVSTACK_DISK_SIZE=        Size of OS Disk for DevStack VM.
DEVSTACK_BRANCH=           Branch to use when installing devstack.
OPENSTACK_USER=            User name that will be added to OpenStack after devstack has finished installing. This is also the username that will be used to create a cloud site in ONAP SO.
OPENSTACK_PASS=            Password to use for OPENSTACK_USER.
OPENSTACK_TENANT=          Tenant name that will be added to OpenStack after devstack has finished installing. This is also the username that will be used to create a cloud site in ONAP SO.
OPENSTACK_REGION=          Only allows RegionOne for now, future enhancements will be added to allow multi-region.
IMAGE_LIST=                Space delimited list of image urls to add to DevStack. Not required.

# ONAP PARAMS
CLLI=                      Name of CLLI to be created in AAI.
CLOUD_OWNER=               Name of Cloud Owner to be created in AAI.
CLOUD_REGION=              Name of Cloud Region to be created in AAI.
CUSTOMER=                  Name of Customer to be created in AAI.
SUBSCRIBER=                Name of Subscriber to be created in AAI.
SERVICE_TYPE=              Name of Service Type to be created in AAI.
AZ=                        Name of Availability Zone to be created in AAI.
OE=                        Name of Owning Entity to be created in VID.
LOB=                       Name of Line of Business to be created in VID.
PROJECT=                   Name of Project to be created in VID.
PLATFORM=                  Name of Platform to be created in VID.
OS_ID=                     Primary key to be used when adding cloud site to mariadb pod.
OS_TENANT_ROLE=            Only supports admin for now.
OS_KEYSTONE=               Use KEYSTONE_V3 for now.
OOM_BRANCH=                Branch of OOM to clone and use to install ONAP.
CHART_VERSION=             Version of charts to use for ONAP install. This is needed in case multiple versions of the onap helm charts are present on the machine being used for the install.
OOM_OVERRIDES=             Command line overrides to use when running helm deploy. --set <override value>, etc...
DOCKER_REPOSITORY=         Image repository url to pull ONAP images to use for installation. 

```

### Integration Override

When you execute ``cloud.sh``, you have the option to create an ``integration-override.yaml`` file that will be used during ``helm deploy ...`` to install ONAP. This is done by passing the ``--override`` flag to cloud.sh. 

The template used to create the override file is ``./util/integration-override.template``, and is invoked by ``./util/create_robot_config.sh``. It's very possible this isn't complete or sufficient for how you'd like to customize your deployment. You can update the template file and/or the script to provide additional customization for your ONAP install.


### OOM Overrides

In ``cloud.conf``, there's a parameter ``OOM_OVERRIDES`` available that's used to provide command line overrides to ``helm deploy``. This uses the standard helm syntax, so if you're using it the value should look like ``OOM_OVERRIDES="--set vid.enabled=false,so.image=abc"``. If you don't want to override anything, just set this value to an empty string.


### Pre Install

When you run ``cloud.sh`` it will execute ``pre_install.sh`` first, which checks a few things:

- It checks you have the correct pre-reqs installed. So, it'll make sure you have kubectl, azure cli, helm, etc...
- It checks that the version of kubernetes in ``cloud.conf`` is available in Azure.
- It checks the version of azure cli is >= to the baselined version (you can check this version by looking at the top of ``pre_install.sh``). The Azure cli is introduced changes in minor versions that aren't backwards compatible.
- It checks that the version of kubectl installed is at **MOST** 1 minor version different than the version of kubernetes in ``cloud.conf``.

If you would like to skip ``pre_install.sh`` and run the deployment anyways, pass the flag ``--no-validate`` to ``cloud.sh``, like this:

```
$ ./cloud.sh --no-validate

```


### Post Install

After ONAP is deployed, you have the option of executing an arbitrary set of post-install scripts. This is enabled by passing the ``--post-install`` flag to ``cloud.sh``, like this:

```
$ ./cloud.sh --post-install

```

These post-install scripts need to be executable from the command line, and will be provided two parameters that they can use to perform their function:

- /path/to/onap.conf : This is created during the deployment, and has various ONAP and OpenStack parameters.
- /path/to/cloud.conf : this is the same ``cloud.conf`` that's used during the original deployment.


Your post-install scripts can disregard these parameters, or source them and use the parameters as-needed.

Included with this repo is one post-install script (``000_bootstrap_onap.sh``)that bootstraps AAI, VID, and SO with cloud and customer details so that ONAP is ready to model and instantiate a VNF.

In order to include other custom post-install scripts, simply put them in the ``post-install`` directory, and make sure to set its mode to executable. They are executed in alphabetical order. 


## Post Deployment

After ONAP and DevStack are deployed, there will be a ``deployment.notes`` file with instructions on how to access the various components. The ``BUILD_DIR`` specified in ``cloud.conf`` will contain a new ssh key, kubeconfig, and other deployment artifacts as well. 

All of the access information below will be in ``deployment.notes``.


### Kubernetes Access

To access the Kubernetes dashboard:

``az aks browse --resource-group $AKS_RESOURCE_GROUP_NAME --name $AKS_NAME``

To use kubectl:
```

export KUBECONFIG=$BUILD_DIR/kubeconfig
kubectl ...

```

### Devstack Access

To access Horizon:

Find the public IP address via the Azure portal, and go to
``http://$DEVSTACK_PUBLIC_IP``

SSH access to DevStack node:

``ssh -i $BUILD_DIR/id_rsa ${DEVSTACK_ADMIN_USER}@${DEVSTACK_PUBLIC_IP}``

OpenStack cli access:

There's an openstack cli pod that's created in the default kubernetes default namespace. To use it, run:

``kubectl exec $OPENSTACK_CLI_POD -- sh -lc "<openstack command>"``


### NFS Access

``ssh -i $BUILD_DIR/id_rsa ${NFS_ADMIN_USER}@${NFS_PUBLIC_IP}``


## Deleting the deployment

After deployment, there will be a script named ``$BUILD_DIR/clean.sh`` that can be used to delete the resource groups that were created during deployment. This script is not required; you can always just navigate to the Azure portal to delete the resource groups manually.


## Running the scripts separately

Below are instructions for how to create DevStack, NFS, or AKS cluster separately if you don't want to create everything all at once.

**NOTE: The configuration to link components together (network peering, route table modification, NFS setup, etc...) and the onap-bootstrap will not occur if you run the scripts separately**


### DevStack creation

```

$ ./create_devstack.sh --help
./create_devstack.sh [options]
 
 
required:
--public-key                public key to add for admin user [required]
--user-public-ip            public ip that will be granted access to VM [required]
-l, --location              location to deploy VM [required]
-u, --admin-user            admin user to create on VM [required]
 
additional options:
-f, --no-prompt             executes with no prompt for confirmation
-h, --help                  provide brief overview of script
-n, --name                  VM name [optional]
-g, --resource-group        provide brief overview of script [optional]
-s, --size                  Azure flavor size for VM [optional]
-c, --cidr                  cidr for VNET to create for VM [optional]. If provided, must also provide --devstack-private-ip from same range.
-d, --directory             directory to store cloud config data [optional]
--vnet-name                 name of Vnet to create for VM [optional]
--image-list                space delimited list of image urls that will be added to devstack [optional]
--devstack-private-ip       private ip assigned to VM [optional]. If provided, this value must come from the CIDR range of VNET.
--devstack-subnet-name      subnet name created on VNET [optional]
--devstack-disk-size        size of OS disk to be allocated [optional]
--openstack-username        default user name for openstack [optional]
--openstack-password        default password for openstack [optional]
--openstack-tenant          default tenant name for openstack [optional]

```


### NFS Creation

```

$ ./create_nfs.sh --help
./create_nfs.sh [options]
 
 
required:
--public-key                public key to add for admin user [required]
--user-public-ip            public ip that will be granted access to VM [required]
-l, --location              location to deploy VM [required]
-u, --admin-user            admin user to create on VM [required]
--aks-node-cidr             CIDR for Kubernetes nodes [required]. This is used during the NFS deploy to grant access to the NFS server from Kubernetes.
 
additional options:
-f, --no-prompt             executes with no prompt for confirmation
-h, --help                  provide brief overview of script
-n, --name                  VM name [optional]
-g, --resource-group        resource group that will be created [optional]
-s, --size                  Azure flavor size for VM [optional]
-c, --cidr                  cidr for VNET to create for VM [optional].
-d, --directory             directory to store cloud config data [optional]
--vnet-name                 name of Vnet to create for VM [optional]
--nfs-subnet-name           subnet name created on VNET [optional]
--nfs-disk-size             size of external disk to be mounted on NFS VM [optional]

```


### AKS Creation

```

$ ./create_aks.sh --help
./create_aks.sh [options]
 
 
required:
--user-public-ip            public ip that will be granted access to AKS [required]
--admin-user                admin user created on AKS nodes [required]
--public-key                public key added for admin user [required]
-l, --location              location to deploy AKS [required]
 
additional options:
-f, --no-prompt             executes with no prompt for confirmation
-h, --help                  provide brief overview of script
-n, --name                  AKS name [optional]
-g, --resource-group        name of resource group that will be created [optional]
-s, --size                  azure flavor size for Kube nodes [optional]
-v, --kube-version          version of Kubernetes for cluster [optional]
-c, --node-count            number of nodes for cluster [optional]
--service-cidr              cidr for Kuberenetes services [optional].
--dns-ip                    IP for Kuberenetes dns service [optional]. This should be from --service-cidr.
--pod-cidr                  cidr for Kuberenetes pods [optional].
--node-cidr                 cidr for Kuberenetes nodes [optional].
--vnet-name                 name of Vnet to create for Kubernetes Cluster [optional]

```
