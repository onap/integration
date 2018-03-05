# ONAP on Vagrant

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
| ccsdk      | Common Controller SDK               |
| dcae       | Data Collection Analytics & Events  |
| mr         | Message Router                      |
| mso        | Master Service Orchestrator         |
| msb        | Microservices Bus Project           |
| multicloud | Multi Cloud                         |
| oom        | ONAP Operations Manager             |
| policy     | Policy                              |
| portal     | Portal                              |
| robot      | Robot                               |
| sdc        | Service Design & Creation           |
| sdnc       | Software Defined Network Controller |
| vfc        | Virtual Function Controller         |
| vid        | Virtual Infrastructure Development  |
| vnfsdk     | VNF SDK                             |
| vvp        | VNF Validation Program              |

| app_name   | description                              |
|:----------:|------------------------------------------|
| all_in_one | All ONAP services in a VM (experimental) |
| testing    | Unit Test VM                             |

| app_name   | description          |
|:----------:|----------------------|
| openstack  | OpenStack Deployment |

#### Generating documentation

The documentation of this project was written in reStructuredText
format which is located under the [docs folder](../blob/master/doc/source/index.rst).
It's possible to format these documents to HTML using Sphinix python
tool.

    $ tox -e docs

This results in the creation of a new *doc/build/html* folder with
the documentation converted in HTML pages that can be viewed through
the preferred Web Browser.

## Contributing

Bug reports and patches are most welcome.
See the [contribution guidelines](CONTRIBUTING.md).

## License

Apache-2.0
