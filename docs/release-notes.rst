.. _release_notes:

.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

Integration Jakarta Release Notes
==================================

.. csv-table:: Integration Releases
    :file: ./files/csv/release-integration-ref.csv
    :widths: 50,50
    :delim: ;
    :header-rows: 1

.. important::

    - Creation of an Jakarta Daily CI/CD chain
    - Creation of Java and Python baseline images for Jakarta
    - Update of Seccom waivers and version recommendations
    - Adapt robot tests to DCAE project changes
    - New tests (basic_cnf_macro)
    - New repositories (see dedicated section)
    - Release ONAP Data Provider tool
    - Automate repositories INFO.yaml updates
    - Bug fixes
    - ONAP tests library gating tests

    Quick Links:

      - `Jakarta Integration page <https://wiki.onap.org/display/DW/Integration+Jakarta>`_
      - `Jakarta Integration JIRA follow-up <https://wiki.onap.org/display/DW/Jakarta+Integration+Blocking+points>`_
      - `Jakarta Integration weather Board <https://wiki.onap.org/display/DW/0%3A+Integration+Weather+Board+for+Jakarta+Release>`_

Code changes
------------

Integration Repo
.................

:Release Date: 2021-10-14


Version: 10.0.0 (aka Istanbul)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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

Version: 1.10.0
^^^^^^^^^^^^^^^

Main changes:

.. csv-table:: Testsuite Changes
    :file: ./files/csv/release-testsuite-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1


O-Parent
........

Version: 3.3.1
^^^^^^^^^^^^^^

.. csv-table:: Oparent Changes
    :file: ./files/csv/release-oparent-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1

Demo Artifacts (Heat Templates)
...............................

Version: 1.10.0
^^^^^^^^^^^^^^^

.. csv-table:: Demo Changes
    :file: ./files/csv/release-demo-features.csv
    :widths: 30,70
    :delim: ;
    :header-rows: 1

The demo artifacts are pushed to https://nexus.onap.org/content/repositories/releases/org/onap/demo/vnf


Use Cases and Requirements
--------------------------

See dedicated :ref:`Istanbul Use Cases and requirements page <docs_usecases_release>`

Maturity Testing Notes
----------------------

:ref:`Maturity testing page <integration-s3p>`

Open JIRAs/Known issues
-----------------------

Integration
...........

`Integration JIRA page <https://jira.onap.org/issues/?jql=project%20%3D%20Integration%20>`_

Testsuite
.........

`Testsuite JIRA page <https://jira.onap.org/issues/?jql=project%20%3D%20Test>`_
