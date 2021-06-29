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

- Required python packages (including Ansible) can be found in ``requirements.txt`` pip file.
  Tested on Python 3.6.9.
- Ansible:
    - Collections
        - community.crypto: tested on 1.7.1
        - ansible.posix: tested on 1.2.0
        - openstack.cloud: tested on 1.5.0
    - Roles
        - geerlingguy.ansible: tested on 2.1.0

Expected output
---------------

Ephemeral (disposable) ONAP instance.
