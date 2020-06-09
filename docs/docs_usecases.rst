.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_usecases:

Verified Use Cases and Functional Requirements
----------------------------------------------

Description
~~~~~~~~~~~
This session includes use cases and functional requirements which have been
officially verified in Frankfurt release by the ONAP community.

For each use case or functional requirement, you can find contact names and a
link to the associated documentation.

This documentation deals with

  1. What has been implemented
  2. Step by step instructions to deploy and execute the tests, including the
     links to download the related assets and resources
  3. Known issues and workarounds

The final testing status can be found at `Frankfurt Release Integration Testing
Status <https://wiki.onap.org/display/DW/2%3A+Frankfurt+Release+Integration+Testing+Status>`_

31 use cases/functional requirements have been considered for the Frankfurt release.

Use cases
~~~~~~~~~

.. csv-table:: use case table
   :file: usecases.csv
   :widths: 60,20,20
   :header-rows: 1

Functional Requirements
~~~~~~~~~~~~~~~~~~~~~~~

.. csv-table:: functional requirements table
    :file: functional-requirements.csv
    :widths: 60,20,20
    :header-rows: 1

.. csv-table:: 5G functional requirements table
    :file: functional-requirements-5g.csv
    :widths: 60,20,20
    :header-rows: 1

Automated Use Cases
~~~~~~~~~~~~~~~~~~~

Most of the use cases include some automation through robot or bash scripts.
These scripts are detailed in the documentation.

Some use cases have been integrated in ONAP gates. It means the tests are run on
each daily or gating CI chain. The goal is to detect any regression as soon as
possible and demonstrate the ability to automate the use cases.

.. csv-table:: automated use cases table
    :file: automated-usecases.csv
    :widths: 10,80,10
    :delim: ;
    :header-rows: 1

The robot scripts can be found in ONAP testsuite repository, an execution
run-time is provided through the robot pod.

The python onap_tests framework is hosted on
https://gitlab.com/Orange-OpenSource/lfn/onap/onap-tests. Please not that this
framework is valid up to Frankfurk and will be deprecated in Guilin. It will
be replaced by scenarios leveraging python-onapsdk
https://gitlab.com/Orange-OpenSource/lfn/onap/python-onapsdk.

Deprecated Use Cases
~~~~~~~~~~~~~~~~~~~~

The following use cases were included in El Alto or previous release but have
not been tested in Frankfurt, usually due to a lack of resources.
The resources are still available in previous branches, some adaptations may
however be needed for Frankfurt.

.. csv-table:: deprecated use case table
    :file: usecases-deprecated.csv
    :widths: 50,20,10,20
    :header-rows: 1
