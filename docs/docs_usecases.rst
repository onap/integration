.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_usecases:

Verified Use Cases and Functional Requirements
==============================================

Description
-----------
This session includes use cases and functional requirements which have been
officially verified in Frankfurt release by the ONAP community.

For each use case or functional requirement, you can find contact names and a
link to the associated documentation.

This documentation deals with

  1. What has been implemented
  2. Step by step instructions to deploy and execute the tests, including the
     links to download the related assets and resources
  3. Known issues and workarounds

Use cases
~~~~~~~~~

.. csv-table:: use case table
   :file: ./files/csv/usecases.csv
   :widths: 10,40,20,30
   :delim: ;
   :header-rows: 1

Functional Requirements
~~~~~~~~~~~~~~~~~~~~~~~

.. csv-table:: functional requirements table
    :file: ./files/csv/usecases-functional-requirements.csv
    :widths: 10,40,10,10,30
    :delim: ;
    :header-rows: 1

Automated Use Cases
~~~~~~~~~~~~~~~~~~~

.. csv-table:: Infrastructure Healthcheck Tests
    :file: ./files/csv/tests-infrastructure-healthcheck.csv
    :widths: 20,40,20,20
    :delim: ;
    :header-rows: 1

.. csv-table:: Healthcheck Tests
    :file: ./files/csv/tests-healthcheck.csv
    :widths: 20,40,20,20
    :delim: ;
    :header-rows: 1

.. csv-table:: Smoke Tests
    :file: ./files/csv/tests-smoke.csv
    :widths: 20,40,20,20
    :delim: ;
    :header-rows: 1

.. csv-table:: Security Tests
    :file: ./files/csv/tests-security.csv
    :widths: 20,40,20,20
    :delim: ;
    :header-rows: 1

Deprecated Use Cases
~~~~~~~~~~~~~~~~~~~~

The following use cases were included in Frankfurt or previous release but have
not been tested in Frankfurt, usually due to a lack of resources.
The resources are still available in previous branches, some adaptations may
however be needed for Frankfurt.

.. csv-table:: deprecated use case table
    :file: ./files/csv/usecases-deprecated.csv
    :widths: 50,20,10,20
    :header-rows: 1
