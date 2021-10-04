.. This work is licensed under a
   Creative Commons Attribution 4.0 International License.
.. integration-repositories:

Integration repositories
========================

.. important::
   The Integration project deals with lots of code repositories.


Most of the repositories are internal ONAP repositories.

.. code-block:: bash

   ├── demo
   ├── integration
   │   ├── csit
   │   ├── docker
   │   │   ├── onap-java11
   │   │   └── onap-python
   │   ├── ietf-actn-tools
   │   ├── integration
   │   ├── seccom
   │   ├── simulators
   │   │   ├──5G-core-nf-simulator
   │   │   ├──A1-policy-enforcement-simulator
   │   │   ├──core-nssmf-simulator
   │   │   ├──nf-simulator
   │   │   │  ├──avcn-manager
   │   │   │  ├──netconf-server
   │   │   │  ├──pm-https-server
   │   │   │  └──ves-client
   │   │   ├──pnf-simulator
   │   │   ├──ran-nssmf-simulator
   │   │   └──ran-simulator
   │   ├── usecases
   │   │   ├── A1-policy-enforcement
   │   │   ├── A1-policy-enforcement-r-apps
   │   └── xtesting
   ├── oparent
   │   └── cia
   └── testsuite
      ├── cds
      ├── cds-mock-odl
      ├── cds-mock-server
      ├── cds-mock-ssh
      ├── oom
      ├── python-testing-utils
      ├── pythonsdk-tests
      └── robot-utils

Please note that integration and teststuite are repositories and groups hosting
several sub-repositories.

Integration
-----------

The integration repository is the historical repository.
As a consequence it includes several elements in the same repository:

- Deployment scripts (deployment directory)
- Tests: the first non robot tests (security, vCPE,..)
- Simulators/emulators (test/mocks)
- Integration and use cases documentation (docs)
- Tools (bootstrap, S3Ptools)

Since Frankfurt version, we created more smaller repositories especially for the use
cases and the simulators.
It shall help improving the maintenance of the different elements.
It shall also help identifying, leveraging and adopting existing simulators
rather than systematically re-inventing the wheel.

.. csv-table:: Integration Repositories
    :file: ./files/csv/repo-integration.csv
    :widths: 30,50,20
    :delim: ;
    :header-rows: 1

.. csv-table:: Integration Simulators
    :file: ./files/csv/repo-simulators.csv
    :widths: 30,50,20
    :delim: ;
    :header-rows: 1


Testsuite
---------

The testsuite repository and its sub repositories deal exclusively with tests.

The testsuite repository includes all the robotframework scripts.
The robot pod that can be installed as part of the ONAP cluster is built from
this repository.

Several tooling repositories are associated with the robot tests (heatbridge,
robot-python-testing-utils).

.. csv-table:: Testsuite Repositories
    :file: ./files/csv/repo-testsuite.csv
    :widths: 30,50,20
    :delim: ;
    :header-rows: 1

Demo
----

In this repository you will find any artifacts needed for demo, PoC and use cases
if they do not have their own repository (mainly old use cases).

.. csv-table:: Demo Repository
    :file: ./files/csv/repo-demo.csv
    :widths: 30,50,20
    :delim: ;
    :header-rows: 1

Oparent
-------

.. csv-table:: Oparent Repository
    :file: ./files/csv/repo-oparent.csv
    :widths: 30,50,20
    :delim: ;
    :header-rows: 1

Archived repositories
---------------------

Some repositories are archived and marked as "read-only" due to the lack of any activity in them.

.. csv-table:: Archived Repositories
    :file: ./files/csv/repo-archived.csv
    :widths: 30,50,20
    :delim: ;
    :header-rows: 1


External repositories
---------------------

Additionally, the Integration team also deals with external gitlab.com
repositories.

.. csv-table:: Integration external repositories table
    :file: ./files/csv/repo-integration-external.csv
    :widths: 30,50,20
    :delim: ;
    :header-rows: 1

The python-onapsdk has been developed outside of ONAP as gitlab provided more
enhanced built-in features for this kind of development.

The xtesting-onap repository is also hosted in gitlab.com as the CD part of
Integration work is based on public gitlab-ci chains.
