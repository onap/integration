
.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0
   Copyright 2017 AT&T Intellectual Property.  All rights reserved.

.. _doc-release-notes:

Integration Release Notes
=============


Integration Repo
================

Version: 2.0.0
--------------

:Release Date: 2018-06-06

**New Features**

* Added deployment scripts and HEAT template for automated deployment of OOM onto 1 Rancher VM and 11 k8s VMS
* Updated scripts for OOM and HEAT daily automated deployment tests
* Added various helper scripts and configuration files for assisting the ONAP community's work on the various OpenLab test environments
* Updated docker and java artifact versions for ONAP Beijing release
* Added automation scripts for vCPE use case
* Updates and enhancements to the CSIT test plans across projects to support the ONAP Beijing use cases



O-Parent
========

Version: 1.1.1
--------------

:Release Date: 2018-05-09

**Bug Fixes**

Updated dependency on lombok project due to license issues.


Version: 1.1.0
--------------

:Release Date: 2018-03-02

**New Features**

Updated library versions of various toolchain dependencies.



Demo Artifacts (HEAT Templates)
==============

Version: 1.2.1
--------------

:Release Date: 2018-06-07

**New Features**

The main change in this release is that the boot scripts used by the ONAP HEAT template deployment method
are no longer retrieved from the nexus raw repo.  Instead, they are zipped and deployed to nexus like
regular maven artifacts so that they can be version-tracked.


Version: 1.2.0
--------------

:Release Date: 2018-05-15

**New Features**

Updated the ONAP HEAT template to reflect the changes in the ONAP Beijing Release deployment footprint.
The major changes include:

* New DCAEGEN2 MVP single VM deployment method
* New VMs for:
  * AAF
  * AAF-SMS
  * OOF
  * MUSIC
  * NBI



Robot Test Suite
===========

Version: 1.2.1
--------------

:Release Date: 2018-05-31

**Bug Fixes**

* Remove the use/dependency on the nexus raw repo
* Various minor fixes to improve the reproducibility and consistency of the test runs


Version: 1.2.0
--------------

:Release Date: 2018-05-14

**New Features**

* Added new ete.sh healthdist test
* New health check test cases to support the ONAP components that are new to Beijing Release, including:
  * AAF
  * AAF SMS
  * External API NBI
  * OOF-Homing
  * OOF-SNIRO


