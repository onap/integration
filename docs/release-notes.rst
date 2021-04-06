.. _release_notes:

.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

Integration Honolulu Release Notes
==================================

.. csv-table:: Integration Releases
    :file: ./files/csv/release-integration-ref.csv
    :widths: 50,50
    :delim: ;
    :header-rows: 1

.. important::

    - Creation of an Honolulu Daily CI/CD chain
    - Creation of a dual stack IPv4/Ipv6 chain
    - Creation of java and python baseline images for Honolulu
    - Update of oparent (java dependencies)
    - Update of Seccom waivers and version recommendations
    - New security test (tern, internal port certificate verification)
    - New automated smoke tests (basic_onboard, basic_cds, dcaemod, basic_clamp,
      pnf_macro, basic_vm_macro)
    - Update of existing automated tests (5gbulkpm, cmpv2, full)
    - Heavy refactor of CSIT
    - New repositories (see dedicated section)
    - Bug fixes

    Quick Links:

      - `Honolulu Integration page <https://wiki.onap.org/display/DW/Integration+H+Release>`_
      - `Honolulu Integration JIRA follow-up <https://wiki.onap.org/display/DW/Honolulu+Integration+Blocking+Points>`_
      - `Honolulu Integration weather Board <https://wiki.onap.org/display/DW/0%3A+Integration+Weather+Board+for+Honolulu+Release>`_

Code changes
------------

Integration Repo
.................

Version: 8.0.0 (aka Honolulu)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:Release Date: 2021-04-24

.. csv-table:: Integration Changes
    :file: ./files/csv/release-integration-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1


Onaptests (pythonsdk_tests)
...........................

Main changes:

.. csv-table:: pythonsdk_tests Changes
    :file: ./files/csv/release-pythonsdk-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1

Robot (Testsuite)
.................

Version: 1.8.0
^^^^^^^^^^^^^^

:Release Date: 2021-04-28

Main changes:

.. csv-table:: Testsuite Changes
    :file: ./files/csv/release-testsuite-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1


O-Parent
........

Version: 3.2.0
^^^^^^^^^^^^^^

:Release Date: 2021-01-25

.. csv-table:: Oparent Changes
    :file: ./files/csv/release-oparent-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1

Demo Artifacts (HEAT Templates)
...............................

Version: 1.8.0
^^^^^^^^^^^^^^

:Release Date: 2021-04-08

.. csv-table:: Demo Changes
    :file: ./files/csv/release-demo-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1

The demo artifacts are pushed to https://nexus.onap.org/content/repositories/releases/org/onap/demo/vnf

Other Repositories
..................

New Honolulu repositories:

- integration/ietf-actn-tools
- integration/usecases/A1-policy-enforcement
- integration/usecases/A1-policy-enforcement-r-apps
- integration/simulators/5G-core-nf-simulator
- integration/simulators/A1-policy-enforcement-simulator
- integration/simulators/core-nssmf-simulator;Core NSSMF Simulator
- integration/simulators/nf-simulator
- integration/simulators/nf-simulator/avcn-manager
- integration/simulators/nf-simulator/netconf-server
- integration/simulators/nf-simulator/pm-https-server
- integration/simulators/nf-simulator/ves-client
- testsuite/cds
- testsuite/pythonsdk-tests
- testsuite/robot-utils


Use Cases and Requirements
--------------------------

See dedicated :ref:`Honolulu Use Cases and requirements page <docs_usecases_release>`

Maturity Testing Notes
----------------------

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
