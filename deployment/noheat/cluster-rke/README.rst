====================================
 Kubernetes cluster: RKE deployment
====================================

Bootstrap scripts for Openstack infrastructure nodes to create RKE-based Kubernetes cluster. They are based on `OOM offline-installer`_ components.

They will be later rewritten as Ansible roles and sample playbooks for Service Mesh lab cluster.

.. _`OOM offline-installer`: https://git.onap.org/oom/offline-installer

Prerequisites
-------------

Infrastructure
~~~~~~~~~~~~~~

- OpenStack virtual machines for a Kubernetes cluster

Configuration
~~~~~~~~~~~~~

- Ansible ``hosts.yaml`` inventory file with OpenStack virtual machines information on ``installer-server`` node


Expected output
---------------

RKE-based Kubernetes cluster for an ONAP deployment.
