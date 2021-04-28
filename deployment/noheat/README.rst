================================
 ONAP on Openstack without Heat
================================

Ansible roles and sample playbooks for automatic deployments for system testing and continuous
integration test flows. These will orchestrate Openstack virtual machines setup for a Kubernetes
cluster, a Rancher Kubernetes Engine (RKE) deployment, a DevStack deployment and an ONAP deployment.

They will be used in Service Mesh lab.

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

Ephemeral (disposable) ONAP instance.
