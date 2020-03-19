
.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

Integration Release Notes
=========================


Integration Repo
----------------

Version: 4.0.0
..............

:Release Date: 2019-10-21

**New Features**

* Add new integration labs
* Introduction of OOM Gating
* Updated scripts for OOM daily automated deployment tests
* Refactoring of the Integration wiki home page
* Automation script for use cases
* Updated java artifact versions for ONAP El Alto release
* Cleaning of CSIT jobs
* Update oparent library to fix security Vulnerabilities
* Update Postman collection for test

Quick Links:
  - `Integration project page <https://wiki.onap.org/display/DW/Integration+Project>`_
  - ` El Alto use testing status page <https://wiki.onap.org/display/DW/2%3A+El+Alto+Release+Integration+Testing+Status>`

ONAP Maturity Testing Notes
---------------------------

For El Alto release, ONAP continues to improve in multiple areas of
Scalability, Security, Stability and Performance (S3P) metrics.

In addition of the windriver lab, Master and El Alto use cases have been tested
on Ericcson (Daily Master CI chain), Orange (Daily Master chain, Gating) and
windriver labs (use cases, daily, long duration). See `Integration Lab portal
<http://testresults.opnfv.org/onap-integration>`


A gating chain has been setup for OOM. This CI chain provides feedback to the
integration team. For each OOM change, a full ONAP deployment is triggered then
several tests are executed (k8s verification, helm chart verification, 61 robot
healthcheck, healthdist and end to end basic VNF tests).
For El Alto, more than 1000 pipelines have been executed (gating, daily master
and stable).
The results of the tests for the OOM gating can be found ` here
<https://orange-opensource.gitlab.io/lfn/onap/xtesting-onap-view/index.html>`

Tests dealing with more than 25 test cases are executed on Windriver
environment.

The Integration team ran the 72 hours stability testing (xx% passing rate) and
full resilience testing (xx% passing rate) at ONAP OpenLabs.
More details in :ref:`ONAP Maturity Testing Notes <integration-s3p>`.


Verified Use Cases and Functional Requirements
----------------------------------------------

The Integration team verified 22 use cases and functional requirements.
The details can be found at
:ref:`Verified Use Cases and Functional Requirements <docs_usecases>` session.

O-Parent
--------

Version: 2.2.0
..............

:Release Date: 2019-09-03

**New Features**

* Updated oparent POM files to support LF's new global job template.
* commons-beanutils 1.9.4
* tomcat-embed-core 9.0.24
* jquery 3.4.1


Version: 2.0.0
..............

:Release Date: 2019-03-08

**New Features**

* Updated oparent POM files to support LF's new global job template.

Version: 1.2.3
..............

:Release Date: 2019-02-11

**Bug Fixes**

* Updated various library dependency versions per SECCOM input
* Fixed Checkstyle configuration issues


Version: 1.2.2
..............

:Release Date: 2018-11-11

**Bug Fixes**

* Updated Spring dependency version to fix CLM issues
* Remove hard-coding of ONAP nexus repos


Version: 1.2.1
..............

:Release Date: 2018-09-14

**New Features**

* Refactor oparent pom to support running builds against local nexus
  repos without having to modify oparent source code
* Standardize 3rd party library versions

Version: 1.2.0
..............

:Release Date: 2018-08-24

**New Features**

* Add depedencyManagement sub-module to declare dependecies


Demo Artifacts (HEAT Templates)
-------------------------------

Version: 1.5.0
..............

:Release Date: 2019-10-11

**New Features**

* vFW DT tutorial improvement
* Helm chart for visualization operator
* bug fixes
* Robot enhancements for various use cases


Version: 1.4.0
..............

:Release Date: 2019-06-13

**New Features**

The main changes for this release are the additional templates and
other changes to support Use Cases such as vFWCL, vFWDT, vCPE, Scale-out,
and TOSCA templates.


Version: 1.3.0
..............

:Release Date: 2018-11-15

**New Features**

The main changes for this release are the additional templates and
other changes to support Use Cases such as HPA, vCPE, Scale-out,
and TOSCA templates.


Robot Test Suites
-----------------

Version: 1.5.4

:Release Date: 2019-10-24

**New Features**

* bug Fixes(Teardown, control loop, alotteed properties)
* Add repush Policy
* CDS support
* HV-VES SSL support
* Add testsuite for VNF Lifecycle validation
* Cleaning (remaining openecomp ref, ocata and lenovo healthcheck, unused or
  redundant variables and scripts)


Version: 1.4.1

:Release Date: 2019-06-09

**New Features**

* Update vFWCL use case test script


Version: 1.4.0

:Release Date: 2019-05-24

**New Features**

* Update vFWCL use case closed loop policy
* Fix vCPE use case test bugs
* Support resource VL type in test script
* Add test script for new use cases
* Enhance existing use cases test script

Version: 1.3.2
..............

:Release Date: 2018-11-20

**New Features**

* Fully automated vFW Closed Loop instantiation and testing
* Instantiation of 5 new vCPE models


Version: 1.3.1
..............

:Release Date: 2018-11-14

**New Features**

* Additional health checks for new ONAP components in Casablanca
* New ETE test suite to test Portal functionality
* Various enhancements to improve stability of Robot tests
