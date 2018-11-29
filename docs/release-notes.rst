
.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0
   Copyright 2018 Huawei Technologies Co., Ltd.  All rights reserved.

.. _doc-release-notes:

Integration Release Notes
=========================


Integration Repo
================

Version: 3.0.0
--------------

:Release Date: 2018-11-29

**New Features**

* CI/CD with daily summary: `functional tests and health checks <http://onapci.org/grafana/d/8cGRqBOmz/daily-summary>`_. 
* Container optimization through Integration sub-projectCIA project release notes
* Enhanced deployment scripts and HEAT template for automated deployment of OOM onto a HA-enabled Kubernetes cluster
* Updated scripts for OOM daily automated deployment tests
* Added various helper scripts and configuration files for assisting the ONAP community's work on the various OpenLab test environments
* Updated docker and java artifact versions for ONAP Casablanca release
* Additional enhancements to automation test scripts for vCPE use case
* Moved CSIT content to a separate integration/csit repo
* Updates and enhancements to the CSIT test plans across projects to support the ONAP Casablanca use cases
* Offline deployment: deploy ONAP without direct internet access for Beijing release



O-Parent
========

Version: 1.2.2
--------------

:Release Date: 2018-11-11

**Bug Fixes**

* Updated Spring dependency version to fix CLM issues
* Remove hard-coding of ONAP nexus repos


Version: 1.2.1
--------------

:Release Date: 2018-09-14

**New Features**

* Refactor oparent pom to support running builds against local nexus
  repos without having to modify oparent source code
* Standardize 3rd party library versions

Version: 1.2.0
--------------

:Release Date: 2018-08-24

**New Features**

* Add depedencyManagement sub-module to declare dependecies


Demo Artifacts (HEAT Templates)
==============

Version: 1.3.0
--------------

:Release Date: 2018-11-15

**New Features**

The main changes for this release are the additional templates and
other changes to support Use Cases such as HPA, vCPE, Scale-out,
and TOSCA templates.


Robot Test Suite
===========

Version: 1.3.2
--------------

:Release Date: 2018-11-20

**New Features**

* Fully automated vFW Closed Loop instantiation and testing
* Instantiation of 5 new vCPE models


Version: 1.3.1
--------------

:Release Date: 2018-11-14

**New Features**

* Additional health checks for new ONAP components in Casablanca
* New ETE test suite to test Portal functionality
* Various enhancements to improve stability of Robot tests
