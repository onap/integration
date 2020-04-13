ONAP HEAT Template
------------------

Source files
~~~~~~~~~~~~

- Template file: https://git.onap.org/integration/plain/deployment/heat/onap-rke/onap-oom.yaml
- Environment file: https://git.onap.org/integration/plain/deployment/heat/onap-rke/env/windriver/onap-oom.env

The files are based on the windriver environement used by the integration team.

Description
~~~~~~~~~~~

The ONAP HEAT template spins up the entire ONAP platform. The template,
onap_openstack.yaml, comes with an environment file,
onap_openstack.env, in which all the default values are defined.

.. note::
 onap_openstack.yaml AND onap_openstack.env ARE THE HEAT TEMPLATE
 AND ENVIRONMENT FILE CURRENTLY SUPPORTED.
 onap_openstack_float.yaml/env AND onap_openstack_nofloat.yaml/env
 AREN'T UPDATED AND THEIR USAGE IS NOT SUGGESTED.

The HEAT template is composed of two sections: (i) parameters, and (ii)
resources.
The parameter section contains the declaration and
description of the parameters that will be used to spin up ONAP, such as
public network identifier, URLs of code and artifacts repositories, etc.
The default values of these parameters can be found in the environment
file.

The resource section contains the definition of:

- ONAP Private Management Network, which ONAP components use to communicate with each other and with VNFs
- ONAP Virtual Machines (VMs)
- Public/private key pair used to access ONAP VMs
- Virtual interfaces towards the ONAP Private Management Network
- Disk volumes.

Each VM specification includes Operating System image name, VM size
(i.e. flavor), VM name, etc. Each VM has two virtual network interfaces:
one towards the public network and one towards the ONAP Private
Management network, as described above. Furthermore, each VM runs a
post-instantiation script that downloads and installs software
dependencies (e.g. Java JDK, gcc, make, Python, ...) and ONAP software
packages and docker containers from remote repositories.

When the HEAT template is executed, the Openstack HEAT engine creates
the resources defined in the HEAT template, based on the parameters
values defined in the environment file.

Environment file
~~~~~~~~~~~~~~~~

Before running HEAT, it is necessary to customize the environment file.
Indeed, some parameters, namely public_net_id, pub_key,
openstack_tenant_id, openstack_username, and openstack_api_key,
need to be set depending on the user's environment:

**Global parameters**

::

 public_net_id:       PUT YOUR NETWORK ID/NAME HERE
 pub_key:             PUT YOUR PUBLIC KEY HERE
 openstack_tenant_id: PUT YOUR OPENSTACK PROJECT ID HERE
 openstack_username:  PUT YOUR OPENSTACK USERNAME HERE
 openstack_api_key:   PUT YOUR OPENSTACK PASSWORD HERE
 horizon_url:         PUT THE HORIZON URL HERE
 keystone_url:        PUT THE KEYSTONE URL HERE (do not include version number)

openstack_region parameter is set to RegionOne (OpenStack default). If
your OpenStack is using another Region, please modify this parameter.

public_net_id is the unique identifier (UUID) or name of the public
network of the cloud provider. To get the public_net_id, use the
following OpenStack CLI command (ext is the name of the external
network, change it with the name of the external network of your
installation)

::

 openstack network list  | grep ext |  awk '{print $2}'

pub_key is string value of the public key that will be installed in
each ONAP VM. To create a public/private key pair in Linux, please
execute the following instruction:

::

 user@ubuntu:~$ ssh-keygen -t rsa

The following operations to create the public/private key pair occur:

::

 Generating public/private rsa key pair.
 Enter file in which to save the key (/home/user/.ssh/id_rsa):
 Created directory '/home/user/.ssh'.
 Enter passphrase (empty for no passphrase):
 Enter same passphrase again:
 Your identification has been saved in /home/user/.ssh/id_rsa.
 Your public key has been saved in /home/user/.ssh/id_rsa.pub.

openstack_username, openstack_tenant_id (password), and
openstack_api_key are user's credentials to access the
OpenStack-based cloud.

**Images and flavors parameters**

::

 ubuntu_1404_image: PUT THE UBUNTU 14.04 IMAGE NAME HERE
 ubuntu_1604_image: PUT THE UBUNTU 16.04 IMAGE NAME HERE
 flavor_small:       PUT THE SMALL FLAVOR NAME HERE
 flavor_medium:      PUT THE MEDIUM FLAVOR NAME HERE
 flavor_large:       PUT THE LARGE FLAVOR NAME HERE
 flavor_xlarge:      PUT THE XLARGE FLAVOR NAME HERE
 flavor_xxlarge:     PUT THE XXLARGE FLAVOR NAME HERE

To get the images in your OpenStack environment, use the following
OpenStack CLI command:

::

        openstack image list | grep 'ubuntu'

To get the flavor names used in your OpenStack environment, use the
following OpenStack CLI command:

::

        openstack flavor list

**DNS parameters**

::

 dns_list: PUT THE ADDRESS OFTHE EXTERNAL DNS HERE (e.g. a comma-separated list of IP addresses in your /etc/resolv.conf in UNIX-based Operating Systems). THIS LIST MUST INCLUDE THE DNS SERVER THAT OFFERS DNS AS AS SERVICE (see DCAE section below for more details)
 external_dns: PUT THE FIRST ADDRESS OF THE EXTERNAL DNS LIST HERE oam_network_cidr: 10.0.0.0/16

You can use the Google Public DNS 8.8.8.8 and 4.4.4.4 address or your internal DNS servers

**DCAE Parameters**

DCAE spins up ONAP's data collection and analytics system in two phases.
The first is the launching of a bootstrap VM that is specified in the
ONAP Heat template. This VM requires a number of deployment specific
conifiguration parameters being provided so that it can subsequently
bring up the DCAE system. There are two groups of parameters.

The first group relates to the launching of DCAE VMs, including parameters such as
the keystone URL and additional VM image IDs/names. DCAE VMs are
connected to the same internal network as the rest of ONAP VMs, but
dynamically spun up by the DCAE core platform. Hence these parameters
need to be provided to DCAE. Note that although DCAE VMs will be
launched in the same tenant as the rest of ONAP, because DCAE may use
MultiCloud node as the agent for interfacing with the underying cloud,
it needs a separate keystone URL (which points to MultiCloud node
instead of the underlying cloud).

The second group of configuration parameters relate to DNS As A Service support (DNSaaS).
DCAE requires DNSaaS for registering its VMs into organization-wide DNS service. For
OpenStack, DNSaaS is provided by Designate. Designate support can be
provided via an integrated service endpoint listed under the service
catalog of the OpenStack installation; or proxyed by the ONAP MultiCloud
service. For the latter case, a number of parameters are needed to
configure MultiCloud to use the correct Designate service. These
parameters are described below:

::

 dcae_keystone_url: PUT THE KEYSTONE URL OF THE OPENSTACK INSTANCE WHERE DCAE IS DEPLOYED (Note: put the MultiCloud proxy URL if the DNSaaS is proxyed by MultiCloud)
 dcae_centos_7_image: PUT THE CENTOS7 IMAGE ID/NAME AVAILABLE AT THE OPENSTACK INSTANCE WHERE DCAE IS DEPLOYED
 dcae_security_group: PUT THE SECURITY GROUP ID/NAME TO BE USED AT THE OPENSTACK INSTANCE WHERE DCAE IS DEPLOYED
 dcae_key_name: PUT THE ACCESS KEY-PAIR NAME REGISTER AT THE OPENSTACK INSTANCE WHERE DCAE IS DEPLOYED
 dcae_public_key: PUT THE PUBLIC KEY OF A KEY-PAIR USED FOR DCAE BOOTSTRAP NODE TO COMMUNICATE WITH DCAE VMS
 dcae_private_key: PUT THE PRIVATE KEY OF A KEY-PAIR USED FOR DCAE BOOTSTRAP NODE TO COMMUNICATE WITH DCAE VMS

 dnsaas_config_enabled: true or false FOR WHETHER DNSAAS IS PROXYED
 dnsaas_region: PUT THE REGION OF THE OPENSTACK INSTANCE WHERE DNSAAS IS PROVIDED
 dnsaas_tenant_id: PUT THE TENANT ID/NAME OF THE OPENSTACK INSTANCE WHERE DNSAAS IS PROVIDED
 dnsaas_keystone_url: PUT THE KEYSTONE URL OF THE OPENSTACK INSTANCE WHERE DNSAAS IS PROVIDED
 dnsaas_username: PUT THE USERNAME OF THE OPENSTACK INSTANCE WHERE DNSAAS IS PROVIDED
 dnsaas_password: PUT THE PASSWORD OF THE OPENSTACK INSTANCE WHERE DNSAAS IS PROVIDED

Instantiation
~~~~~~~~~~~~~

The ONAP platform can be instantiated via Horizon (OpenStack dashboard)
or Command Line.

**Instantiation via Horizon:**

- Login to Horizon URL with your personal credentials
- Click "Stacks" from the "Orchestration" menu
- Click "Launch Stack"
- Paste or manually upload the HEAT template file (onap_openstack.yaml) in the "Template Source" form
- Paste or manually upload the HEAT environment file (onap_openstack.env) in the "Environment Source" form
- Click "Next" - Specify a name in the "Stack Name" form
- Provide the password in the "Password" form
- Click "Launch"

**Instantiation via Command Line:**

- Install the HEAT client on your machine, e.g. in Ubuntu (ref. http://docs.openstack.org/user-guide/common/cli-install-openstack-command-line-clients.html):

::

 apt-get install python-dev python-pip
 pip install python-heatclient        # Install heat client
 pip install python-openstackclient   # Install the Openstack client to support multiple services

-  Create a file (named i.e. ~/openstack/openrc) that sets all the
   environmental variables required to access Rackspace:

::

 export OS_AUTH_URL=INSERT THE AUTH URL HERE
 export OS_USERNAME=INSERT YOUR USERNAME HERE
 export OS_TENANT_ID=INSERT YOUR TENANT ID HERE
 export OS_REGION_NAME=INSERT THE REGION HERE
 export OS_PASSWORD=INSERT YOUR PASSWORD HERE

-  Run the script from command line:

::

 source ~/openstack/openrc

-  In order to install the ONAP platform, type:

::

 heat stack-create STACK_NAME -f PATH_TO_HEAT_TEMPLATE(YAML FILE) -e PATH_TO_ENV_FILE       # Old HEAT client, OR
 openstack stack create -t PATH_TO_HEAT_TEMPLATE(YAML FILE) -e PATH_TO_ENV_FILE STACK_NAME  # New Openstack client
