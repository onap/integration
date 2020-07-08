.. _release_notes:

.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

Integration Release Notes
=========================

Integration Repo
----------------

Version: 6.0.0
..............

:Release Date: 2020-06-15

**New Features**

- provide a new testsuite docker version (1.6.3) including several test updates
  for the different tests
- Creation of new repositories to host the use cases: bbs, mdons
- Creation of new repositories to host the simulators: dc-simulator, ran-simulator,
  pnf-simulator
- Creation of new repositories to host baseline images: java11, python
- Update oparent library to fix security Vulnerabilities
- Support new use cases (mdons, vCPE_tosca,..)
- Creation of a web page to host CI daily results
- Creation and Integration in CI of new security tests (http public end points,
  rooted pods, kubernetes CIS verification, jdpw ports)
- Update of the onap-k8s use case to report the full status of the cluster after
  the installation and provide a dashboard
- Include healthdist and postinstall robot tests in healthcheck tests
- Add new smoke use cases in CI (pnf-registrate, 5gbulkpm,...)

Quick Links:

  - `Integration project page <https://wiki.onap.org/display/DW/Integration+Project>`_
  - ` Frankfurt use testing status page <https://wiki.onap.org/display/DW/2%3A+Frankfurt+Release+Integration+Testing+Status>`

ONAP Maturity Testing Notes
---------------------------

A Frankfurt daily CI chain has bee put in place after the RC0 milestone. This CI
chain is used to track the stability of the release from the RC0. it will be
maintained as the latest stable CI branch and replaces the El Alto branch.
The daily results can be found in <https://gating-results.onap.eu/results/>.
A 72 stability test has been executed after RC1.

See :ref:`S3P page<integration-s3p>` for further details.

Verified Use Cases and Functional Requirements
----------------------------------------------

The Integration team verified 31 use cases.
The details can be found at
:ref:`Verified Use Cases and Functional Requirements <docs_usecases>` session.

O-Parent
--------

Version: 3.0.2
..............

:Release Date: 2020-05-08

**New Features**

- Update tomcat 9.0.30
- Update latest security dependencies
- Update settings.xml to use https maven
- Update sonar configuration
- Update checkstyle rules to exclude methods
- Upgrade oparent to checkstyle 8.27
- Revert "update version of checkstyle for latest google style and jdk 8"
- update version of checkstyle for latest google style and jdk 8
- Add compiler-plugin example
- Uprev to 3.0.0 for Java 11
- qos logback to 1.2.3

Demo Artifacts (HEAT Templates)
-------------------------------

Version: 1.6.0
..............

:Release Date: 2020-06-15

https://nexus.onap.org/content/repositories/releases/org/onap/demo/vnf/

**New Features**

* Update POM and heat env to use 1.6.0
* Helm chart for visualization operator
* bug fixes
* Robot enhancements for various use cases

Robot Test Suites
-----------------

Version: 1.6.4
..............

:Release Date: 2020-07-07
:sha1: f863e0060b9e0b13822074d0180cab11aed87ad5


**New Features**

- Some corrections for vLB CDS
- Change owning-entity-id from hard coded to variable
