#!/usr/bin/env bash

# To use an OpenStack cloud you need to authenticate against the Identity
# service named keystone, which returns a **Token** and **Service Catalog**.
# The catalog contains the endpoints for all services the user/tenant has
# access to - such as Compute, Image Service, Identity, Object Storage, Block
# Storage, and Networking (code-named nova, glance, keystone, swift,
# cinder, and neutron).
#
# *NOTE*: Using the 3 *Identity API* does not necessarily mean any other
# OpenStack API is version 3. For example, your cloud provider may implement
# Image API v1.1, Block Storage API v2, and Compute API v2.0. OS_AUTH_URL is
# only for the Identity API served through keystone.
export OS_AUTH_URL=http://10.12.25.2:5000/v3

# With the addition of Keystone we have standardized on the term **project**
# as the entity that owns the resources.
export OS_PROJECT_ID=3583253e932845a09cd4c8ca2f31d095
export OS_PROJECT_NAME="Integration-Stable"
export OS_USER_DOMAIN_NAME="Default"
if [ -z "$OS_USER_DOMAIN_NAME" ]; then unset OS_USER_DOMAIN_NAME; fi

# unset v2.0 items in case set
unset OS_TENANT_ID
unset OS_TENANT_NAME

# In addition to the owning entity (tenant), OpenStack stores the entity
# performing the action as the **user**.
export OS_USERNAME="gary_wu"

# Remote Openstack clients will need to set this environment if
# connecting to an HTTPS enabled endpoint
CERT_MSG="Please enter a path for your CA certificate pem file, \
or press enter if you are not using HTTPS "
read -p "$CERT_MSG" OS_CACERT_INPUT
if [ ! -z "$OS_CACERT_INPUT" ]
then
    export OS_CACERT=$(readlink -f $OS_CACERT_INPUT)
fi

# With Keystone you pass the keystone password.
read -sp "Please enter your OpenStack Password for project $OS_PROJECT_NAME as user $OS_USERNAME: " OS_PASSWORD_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT

# If your configuration has multiple regions, we set that information here.
# OS_REGION_NAME is optional and only valid in certain environments.
export OS_REGION_NAME="RegionOne"
# Don't leave a blank variable, unset it if it was empty
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi

export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
