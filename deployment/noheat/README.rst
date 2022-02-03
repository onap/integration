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
  Tested on Python 3.8.10.
- Ansible required collections & roles can be found in ``requirements.yml`` file for installation
  with ansible-galaxy tool.

Expected output
---------------

Ephemeral (disposable) ONAP instance.

Running
-------

There are 4 playbooks available:

- infa-openstack/ansible/create.yml: creates and prepares OpenStack VMs, generates inventory.
  Must be run as a first playbook. Run on your machine.
- devstack/ansible/create.yml: deploys Devstack on appropriate VM. Run on jumphost VM (operator0).
- cluster-rke/ansible/create.yml: deploys NFS, k8s, helm charts and ONAP. Run on jumphost VM.
- deploy-all.yml: runs above playbooks. Run on your machine.

User may run deploy-all.yml or manually run infra-openstack, devstack and cluster-rke playbooks.
