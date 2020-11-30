.. _release_notes:

.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

Integration Release Notes
=========================

.. csv-table:: Integration Releases
    :file: ./files/csv/release-integration-ref.csv
    :widths: 50,50
    :delim: ;
    :header-rows: 1

.. important::


    - Creation of a Guilin Daily CI/CD chain
    - Setup of a staging lab on Azure
    - Setup of a staging lab on Windriver/Intel lab (with performance audit of the Windriver/Intel labs)
    - Creation of java and python baseline images
    - Update of oparent (java dependencies)
    - Update of Seccom waivers and version recommendations
    - New security tests (versions, pod limits, nonssl, nodeport certificate verification)
    - New automated smoke tests (basic_vm, basic_network, basic_cnf)
    - New requirement automated tests (ves-collector, cmpv2)
    - Development of a new test framework pythonsdk
    - onap_tests framework is now deprecated
    - Heavy refactory of CSIT initiated
    - Documentation refactoring (official documentation and wiki)
    - New repositories (see dedicated section)
    - Bug fixes

    Quick Links:

      - `Guilin Integration page <https://wiki.onap.org/display/DW/Integration+G+Release>`_
      - `Guilin Integration JIRA follow-up <https://wiki.onap.org/display/DW/Guilin+Docker+version+follow-up>`_
      - `Guilin use case testing status page <https://wiki.onap.org/display/DW/Guilin+Integration+blocking+points>`_
      - `Guilin Integration weather Board <https://wiki.onap.org/display/DW/0%3A+Integration+Weather+Board+for+Guilin+Release>`_


Code changes
------------

Integration Repo
.................

Version: 7.0.0 (aka Guilin)
^^^^^^^^^^^^^^^^^^^^^^^^^^^

:Release Date: 2020-11-24

.. csv-table:: Integration Changes
    :file: ./files/csv/release-integration-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1


Robot (Testsuite)
.................

Version: 1.7.3
^^^^^^^^^^^^^^

:Release Date: 2020-11-xx

.. csv-table:: Testsuite Changes
    :file: ./files/csv/release-testsuite-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1


O-Parent
........

Version: 3.0.2
^^^^^^^^^^^^^^

:Release Date: 2020-11-24

.. csv-table:: Oparent Changes
    :file: ./files/csv/release-oparent-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1

Demo Artifacts (HEAT Templates)
...............................

Version: 1.7.0
^^^^^^^^^^^^^^

:Release Date: 2020-11-24

.. csv-table:: Demo Changes
    :file: ./files/csv/release-demo-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1

The demo artifacts are pushed to https://nexus.onap.org/content/repositories/releases/org/onap/demo/vnf

Other Repositories
..................

New Guilin repositories:

- 5G-core-nf-simulator
- terraform
- terragrunt
- testsuite/cds
- pythonsdk-test
- robot-utils


Verified Use Cases and Functional Requirements
----------------------------------------------

:ref:`Use Cases page <docs_usecases_release>`

ONAP Maturity Testing Notes
---------------------------

:ref:`Maturity testing page <integration-s3p>`

Open JIRAs/Known issues
-----------------------

Integration
...........

.. csv-table:: Integration Known Issues
    :file: ./files/csv/issues-integration.csv
    :widths: 10,10,40,10,10,20
    :delim: ;
    :header-rows: 1

`Integration JIRA page <https://jira.onap.org/issues/?jql=project%20%3D%20Integration%20>`_

Testsuite
.........

.. csv-table:: Testsuite Known Issues
    :file: ./files/csv/issues-testsuite.csv
    :widths: 10,10,40,10,10,20
    :delim: ;
    :header-rows: 1

`Testsuite JIRA page <https://jira.onap.org/issues/?jql=project%20%3D%20Test>`_
