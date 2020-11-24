----------------------------------------------
Heat template for deploying Mass PNF Simulator
----------------------------------------------

About
=====

This directory contains the setup that allows the deploy of Mass PNF Simulator to an OpenStack cloud instance. After successful VM run a predefined number of PNF instances will be spawned on it and VES event sending will be triggered.

Prerequisites
=============

1) In order to instantiate the VM with the simulator a running OpenStack infrastructure is needed with HOT (Heat Orchestration Template) support and a preconfigured floating ip network for accessing the instance.

2) An Ubuntu 18.04 image is required to boot the instance. It may also work on 16.04 or newer images albeit the setup was only validated on Ubuntu Bionic.

3) A running instance of ONAP with VES Collector is required only if it's desired to send the PM events from simulator to a real collector instance. In other case any arbitrary mockup service e.g. *netcat* can be used to listen to the events. In either case a valid http link is required.

Configuration
=============

Prior running the Heat template *heat.env* needs to be filled with appropriate parameters:

**image_name: ubuntu-18.04-server-cloudimg-amd64**
  Name of the image for the instance. See remarks above concerning validated setup.

**flavor_name:**
  Flavor name should depend on the number of simulator instances required. Tests show that a setup with 50 PNF simulator instances require approximately 16GB of RAM

**key_name:**
  Name of the existing key for passwordless login

**instance_net_id:**
  Id of the tenant network for instance

**float_net_id:**
  Id of the public network with floating IPs

**simulator_instances:**
  Requested number of PNF simulator instances to run on the VM

**ves_url:**
  A http link to the VES Collector's event listener. Can be any arbitrary mock service that will merely receive the events for debugging purposes.

**ftp_user:**
  A username for the ftp service exposed by the running setup that serves the PM files

**ftp_password:**
  A password for the ftp service

Running
=======

To instantiate the Heat template run from *openstack* CLI:

::

  stack create -t integration/test/mocks/masspnfsim/deployment/heat/heat.yaml -e integration/test/mocks/masspnfsim/deployment/heat/heat.env
