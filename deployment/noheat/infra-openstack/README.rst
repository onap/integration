==================================================
 Cloud infrastructure: OpenStack virtual machines
==================================================

Ansible roles and sample playbooks for creating virtual machines on OpenStack without Heat support.

They will be used to create virtual machines hosting Service Mesh lab cluster.

Prerequisites
-------------

Infrastructure
~~~~~~~~~~~~~~

- OpenStack cloud (no Heat support required)

Configuration
~~~~~~~~~~~~~

- OpenStack ``clouds.yaml`` file

Dependencies
~~~~~~~~~~~~

- Ansible: tested on 2.9.9 (using Python 3.5.2)
    - Collections
        - community.crypto: tested on 1.3.0
        - ansible.posix: tested on 1.1.1
    - Roles
        - geerlingguy.ansible: tested on 2.1.0
- openstacksdk_: tested on 0.46.0 (using Python 3.5.2)

.. _openstacksdk: https://pypi.org/project/openstacksdk


Expected output
---------------

Ephemeral (disposable) OpenStack virtual machines for a Kubernetes cluster.
