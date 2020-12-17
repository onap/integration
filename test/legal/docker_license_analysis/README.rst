#####################################
License Analysis of Docker Containers
#####################################

Vagrantfile that includes tern+scancode for performing dynamic license analysis
of docker containers. It takes either a Dockerfile or image name to analyse.


*********
Reasoning
*********

While there are tools supporting ONAP development that perform license analysis
and produce SBoM, they do it via static static analysis. When base image
introduces licensing issue we will have no way to know from those tools.
Additionally, the tools performing those static analysis require special access
rights which only few people have. This Vagrant box is meant to be run as close
to Docker build as possible to give feedback directly to developers.

It has been placed in a VM due to following reasons:
- reproducibility
- tern requires:

    * access to /dev/fuse
    * access to docker.sock

  Due to the above, running in Docker would require:

    * running container in --priviliged mode
    * passing host's /dev/fuse to the container
    * passing host's docker.sock to the container

  Running it in VM creates new instances of both which should alleviate security
  issues that could be present when running on host/docker


***************
Getting started
***************

Prerequisites
=============

`Vagrant <https://www.vagrantup.com/downloads>`_


Running
=======

Dockerfile analysis
-------------------

Substitute the DOCKER_FILE_ANALYSE value with location of the Dockerfile
you want to analyse::

  export DOCKER_FILE_ANALYSE="/path/to/Dockerfile"
  vagrant up

Please mind that the Docker on the VM needs to be able to download the base
image for analysis to take place.

Keep the DOCKER_FILE_ANALYSE exported as it is required to run other Vagrant
commands (else Vagrant complains that the file pointed in Vagrantfile is not
present)

Docker image analysis
---------------------


Substitute the DOCKER_IMAGE_ANALYSE value with your image of choice::

  export DOCKER_FILE_ANALYSE="./tools/analysis.sh"
  DOCKER_IMAGE_ANALYSE="debian:buster" vagrant up

Please mind that the Docker on the VM needs to be able to download the image
for analysis to take place.

The DOCKER_FILE_ANALYSE needs to be filled with dummy file, as Vagrant does not
allow optional/conditional provisioning with files.


Gathering results
=================

::

  vagrant ssh-config > ssh-config
  scp -F ssh-config default:~/ternvenv/report-scancode.json report-scancode.json

