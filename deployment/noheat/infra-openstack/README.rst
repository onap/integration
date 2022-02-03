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

Tested on Python 3.8.10. Required Python dependencies can be found in ``../requirements.txt``.
Required Ansible roles and collections can be found in ``../requirements.yml``

.. _openstacksdk: https://pypi.org/project/openstacksdk


Expected output
---------------

Ephemeral (disposable) OpenStack virtual machines for a Kubernetes cluster.
