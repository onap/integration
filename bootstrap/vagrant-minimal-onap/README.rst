=====================================================
 ONAP Integration > Bootstrap > Vagrant Minimal ONAP
=====================================================

This directory contains a set of Vagrant scripts that will automatically set up:

- Devstack,
- RKE-based Kubernetes cluster (single control plane node and single worker plane node),
- Operator's machine with configured tools (kubectl, helm).

This is intended to show a beginning ONAP operator how to set up and configure an environment that
can successfully deploy minimal ONAP instance from scratch. Its main purpose are ONAP demos and
proofs of concepts. It is not intended to be used as a production ONAP environment.

NOTE: the Devstack instance is NOT SECURED, with default credentials:

+-------+----------------+
| User  | Password       |
+-------+----------------+
| admin | default123456! |
+-------+----------------+
| demo  | default123456! |
+-------+----------------+


Quickstart
----------

Following set of commands can be used to prepare a machine running Ubuntu 18.04 for this setup:

.. code-block:: sh

   sudo sed -i'.bak' 's/^#.*deb-src/deb-src/' /etc/apt/sources.list
   sudo apt-get update
   sudo apt-get build-dep vagrant ruby-libvirt
   sudo apt-get install qemu libvirt-bin ebtables dnsmasq-base
   sudo apt-get install libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev

   sudo apt-get install sshfs

   wget https://releases.hashicorp.com/vagrant/2.2.7/vagrant_2.2.7_x86_64.deb
   sudo dpkg -i vagrant_2.2.7_x86_64.deb

   vagrant plugin install vagrant-libvirt
   vagrant plugin install vagrant-sshfs

   sudo mv /etc/apt/sources.list{.bak,}
   rm vagrant_2.2.7_x86_64.deb


Requirements
------------

+-------------+-----+-------+---------+
| Machine     | CPU |  RAM  | Storage |
+-------------+-----+-------+---------+
| Operator    |  1  | 1GiB  |  32GiB  |
+-------------+-----+-------+---------+
| Devstack    |  1  | 4GiB  |  32GiB  |
+-------------+-----+-------+---------+
| K8s Control |  1  | 1GiB  |  32GiB  |
+-------------+-----+-------+---------+
| K8s Worker  |  8  | 64GiB |  64GiB  |
+-------------+-----+-------+---------+
| TOTAL       | 11  | 70GiB |  160GiB |
+-------------+-----+-------+---------+

Table above is based on current experience and may be subject to change.


Prerequisites
-------------

Virtualisation provider
~~~~~~~~~~~~~~~~~~~~~~~

Environment has been tested using libvirt_ provider with vagrant-libvirt_ plugin. Plugin
documentation provides detailed `installation instructions`_ that will guide through the process.

.. note::
   Remember to uncomment `deb-src` repositories for `apt-get build-dep` step on Debian/Ubuntu.

.. _libvirt: https://libvirt.org
.. _vagrant-libvirt: https://github.com/vagrant-libvirt/vagrant-libvirt
.. _`installation instructions`: https://github.com/vagrant-libvirt/vagrant-libvirt#installation

Virtual machine manager
~~~~~~~~~~~~~~~~~~~~~~~

Environment has been tested using latest Vagrant_ as of writing this documentation (`v2.2.6`_). Some
features (e.g. triggers_) might not be supported on older versions.

.. _Vagrant: https://www.vagrantup.com/downloads.html
.. _`v2.2.6`: https://github.com/hashicorp/vagrant/blob/v2.2.6/CHANGELOG.md#226-october-14-2019
.. _triggers: https://www.vagrantup.com/docs/triggers/

Synced Folders
~~~~~~~~~~~~~~

Environment uses reverse-SSHFS-based file synchronization for applying non-upstream changes. This
requires installing vagrant-sshfs_ plugin and presence of `sshfs` package on the host system.

.. _vagrant-sshfs: https://github.com/dustymabe/vagrant-sshfs#install-plugin


Running
-------

Additional `--provider` flag or setting `VAGRANT_DEFAULT_PROVIDER` environmental variable might be
useful in case there are multiple providers available.

.. note::
   Following command should be executed within the directory where `Vagrantfile` is stored
   (`integration/bootstrap/vagrant-minimal-onap`).

.. code-block:: sh

   vagrant up --provider=libvirt


Usage
-----

Once ready (bringing up machines might initially take some time), tools for cluster management will
be available on Operator's machine. It can be accessed by executing:

.. code-block:: sh

   vagrant ssh operator

Although appropriate context is set for `kubectl` on login, when interacting with the cluster the
`onap` namespace has to be explicitly specified. Example:

.. code-block:: sh

   # Operator's machine shell
   kubectl -nonap get pods
