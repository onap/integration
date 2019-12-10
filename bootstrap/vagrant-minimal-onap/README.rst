=====================================================
 ONAP Integration > Bootstrap > Vagrant Minimal ONAP
=====================================================

This directory contains a set of Vagrant scripts that will automatically set up:

- Devstack,
- RKE-based Kubernetes cluster,
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


Requirements
------------

+-------------+-----+-------+
| Machine     | CPU |  RAM  |
+-------------+-----+-------+
| Operator    |  1  | 1GiB  |
+-------------+-----+-------+
| Devstack    |  2  | 6GiB  |
+-------------+-----+-------+
| K8s Control |  1  | 1GiB  |
+-------------+-----+-------+
| K8s Worker  |  2  | 12GiB |
+-------------+-----+-------+
| TOTAL       |  6  | 20GiB |
+-------------+-----+-------+

Table above is based on current experience and may be subject to change.


Prerequisites
-------------

- Virtualisation provider, e.g. libvirt_ (with vagrant-libvirt_ plugin) or VirtualBox_
- Virtual machine manager: Vagrant_

.. _libvirt: https://libvirt.org
.. _vagrant-libvirt: https://github.com/vagrant-libvirt/vagrant-libvirt#installation
.. _VirtualBox: https://www.virtualbox.org
.. _Vagrant: https://www.vagrantup.com/downloads.html


Running
-------

Environment has been test with `libvirt` provider. Additional flag might be useful in case there are
multiple providers available.

.. code-block:: sh
   vagrant up # --provider=libvirt
