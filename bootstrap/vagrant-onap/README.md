# ONAP on Vagrant

[![Build Status](https://api.travis-ci.org/electrocucaracha/vagrant-onap.svg?branch=master)](https://api.travis-ci.org/electrocucaracha/vagrant-onap)

This vagrant project pretends to collect information about a way to deploy
and build [ONAP project](https://www.onap.org/) into a development environment.

### Problem Being Solved

* Reduce the barrier of entry to allow new ONAP developers to ramp up on to
active development quickly
* Reduce the cost to the community in responding to simple environment setup
questions faced by new developers

---

| Component        | Requirement                           |
|------------------|---------------------------------------|
| Vagrant          | >= 1.8.6                              |
| Provider         | VirtualBox, Libvirt or OpenStack      |
| Operating System | Linux, Mac OS or Windows              |
| Hard Disk        | > 8 GB of free disk                   |
| Memory           | > 12 GB                               |

---

## Execution:

#### deploying a single application

* Windows

    PS C:\> cd integration\bootstrap\vagrant-onap
    PS C:\integration\bootstrap\vagrant-onap> Set-ExecutionPolicy Bypass -Scope CurrentUser
    PS C:\integration\bootstrap\vagrant-onap> .\tools\Run.ps1 <app_name>

* Linux or Mac OS

    $ cd integration/bootstrap/vagrant-onap
    $ ./tools/run.sh <app_name>

current options include:

| app_name   | description                         |
|:----------:|-------------------------------------|
| aai        | Active and Available Inventory      |
| appc       | Application Controller              |
| dcae       | Data Collection Analytics & Events  |
| mr         | Message Router                      |
| mso        | Master Service Orchestrator         |
| policy     | Policy                              |
| portal     | Portal                              |
| robot      | Robot                               |
| sdc        | Service Design & Creation           |
| sdnc       | Software Defined Network Controller |
| vid        | Virtual Infrastructure Development  |
| vfc        | Virtual Function Controller (WIP)   |
| all_in_one | All ONAP services in a VM           |
| testing    | Unit Test VM                        |

#### generating documentation

The documentation of this project was written in reStructuredText
format which is located under the [docs folder](../blob/master/doc/source/index.rst).
It's possible to format this documents to HTML using Sphinix python
tool.

    $ tox -e docs

This results in the creation of a new *doc/build/html* folder with
the documentation converted in HTML pages that can be viewed through
the prefered Web Browser.

#### Known Issues

##### Virtualbox guest additions conflict with shared directories

If the vagrant-vbguest plugin is installed on the host, then
an updated version of the Virtualbox guest additions will be installed
on the guest in the /opt directory.  Once this projects
Vagrantfile mounts the ./opt directory on the host to the /opt
directory on the guest during the provisioning process, the 
guest addtions on the guest are hidden and subsequent
mounts of shared directories with the host will fail.

The simplest workaround appears to be uninstalling the
vagrant-vbguest plugin on the host system.  This has been
observed to work on a Windows 10 host using virtualbox 5.1.26.

Check if vagrant-vbguest plugin is installed

Linux or Mac

    $ vagrant plugin list

Windows

    C:\> vagrant plugin list

Remove vagrant-vbguest plugin

Linux or Mac

    $ vagrant plugin uninstall vagrant-vbguest

Windows

    C:\> vagrant plugin uninstall vagrant-vbguest

## Contributing

Bug reports and patches are most welcome.
See the [contribution guidelines](CONTRIBUTING.md).

## License

Apache-2.0
