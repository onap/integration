==================
OpenStack Provider
==================

It's possible to use Vagrant to provision VMs on OpenStack using the
`Vagrant OpenStack Cloud Provider <https://github.com/ggiamarchi/vagrant-openstack-provider/>`.
The only requirement for the Cloud provider is to have an Ubuntu Cloud
image accesible to your tenant and a Security Rule that allows to do
SSH into the instance.

Environment variables
---------------------

The usage of environment variables in OpenStack command-line clients
is to avoid repeating some values.  These variables have *OS_* as
prefix. This provider will use them for authentication to Keystone
service.

.. code-block:: console

    export OS_AUTH_URL=http://<keystone_ip>:5000/v3
    export OS_TENANT_NAME=<project_or_tenant_name>
    export OS_PROJECT_NAME=<project_or_tenant_name>
    export OS_USERNAME=<openstack_username>
    export OS_PASSWORD=<openstack_password>
    export OS_REGION_NAME=<openstack_region_name>
    export OS_IDENTITY_API_VERSION=<keystone_version_number>
    export OS_PROJECT_DOMAIN_ID=<openstack_domain_name>

.. end

OpenStack Vagrant provider needs additional information about the
name of the image to be used and the networking where the instance
will be provisioned.  That information can be passed using the
following variables

.. code-block:: console

    export OS_IMAGE=<ubuntu_cloud_image_name>
    export OS_NETWORK=<neutron_private_network>
    export OS_FLOATING_IP_POOL=<neutron_floating_ip_pool>
    export OS_SEC_GROUP=<onap-ssh-secgroup>

.. end

Tenant setup
------------

The *tools/setup_openstack.sh* script can be useful to get an idea
of the process to setup the OpenStack environment with the necessary
requirements. This script depends on the Environment Variables
explained previously.

----

Devstack
--------

It's possible to use this plugin to provision instances on
`Devstack <https://docs.openstack.org/devstack/latest/>`. This is
an example of the *local.conf* file that can be used as input
for Devstack

.. path local.conf
.. code-block:: ini

    [[local|localrc]]
    ADMIN_PASSWORD=<password>
    DATABASE_PASSWORD=<password>
    RABBIT_PASSWORD=<password>
    SERVICE_PASSWORD=<password>
    SERVICE_TOKEN=<token>

    # Used to only upload the Ubuntu Cloud Image
    DOWNLOAD_DEFAULT_IMAGES=False
    IMAGE_URLS+="http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img"

    # (Optional) These values helps to improve the experience deploying and using Devstack
    GIT_BASE=https://git.openstack.org
    FORCE_CONFIG_DRIVE="True"
    disable_service tempest

.. end

.. note::

    There is a validation that checks if the
    *vagrant-openstack-provider* plugin is installed raising an error
    for those cases when it isn't.
