==============================
Using the provisioning scripts
==============================

Vagrant is a platform that uses prebaked images called
*vagrant boxes* to guarranty that running multiple times a
provisioning script will result in an expected output. This
mechanism is crucial for reducing the number of external factors
during the creation, development and testing of provisioning scripts. 
However, it's possible to provide an ONAP development enviroment
without having to install Vagrant tool. This document explains how to
consume the provisioning scripts localed in **./lib** folder to
provision a development environment and the environment variables
that modifies their behavior.

This project was built on an Ubuntu 14.04 ("Trusty") Operating System,
therefore it's necessary to have an user who has *sudo* permissions to
access to a Bare Metal or Virtual Machine.

The following instructions retrieve the provisioning scripts and place
them into the */var/onap/* folder.

.. code-block:: console

    $ sudo su -
    # apt-get install git -y
    # git clone https://git.onap.org/integration
    # mkdir -p /var/onap/
    # cp -r integration/bootstrap/vagrant-onap/lib/ /var/onap/

.. end

Loading a provisioning script will be based on the desired ONAP
service, for example to setup the development environment for Active
and Available Inventory (AAI) service will be required to load the
*/var/onap/lib/aai* script.

.. note::

    The **git_src_folder** environment variable specifies the
    source code destination folder, it's default value is */opt/*
    but it can be changed only after is loaded the provisioning
    scripts.

.. end

.. code-block:: console

    # source /var/onap/lib/aai

.. end

Lastly, every script has defined a initialization function with
*init_* as prefix. This function is the starting point to provision
the chosen ONAP service. This example uses the *init_aai* function
to provision a AAI Developement environment.

.. note::

    The **compile_repo** environment variable defines whether or not
    the source code located on the repositories of the service.
    Enabling this value can impact the provisioning time of the
    service.

.. end
.. note::

    **nexus_docker_repo**, **nexus_username** and **nexus_password**
    environment variables specify the connectivity to a private Docker
    Hub.

.. end
.. note::

    **build_image** environment variable allows the Docker images
    from source code.  Enabling this value can impact the
    provisioning time of the service.

.. end

.. code-block:: console

    # export nexus_docker_repo="nexus3.onap.org:10001"
    # export nexus_username="docker"
    # export nexus_password="docker"
    # init_aai

.. end

As result, the source code is pulled into */opt/aai/* folder and the
AAI services are up and running with the proper connection to the
Titan Distributed Graph Database.
