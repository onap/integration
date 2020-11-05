.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. _master_index:

INTEGRATION
===========

The Integration project is in charge of:

- Providing testing environment and support for the release use cases
- Executing project-specific Continuous System Integration Testing (CSIT)
- Managing full ONAP CI chains (daily master, staging, stable) to ensure the
  stability of the integration
- Developing and performing tests within full ONAP context (healthcheck, End to
  End, performance, robustness...)
- Validating the ONAP release

For each release, the integration team provides the following artifacts:

- Test suites and tools to check the various ONAP components
- Use-case documentation and artifacts
- a testsuite docker included in ONAP cluster to execute the tests
- baseline JAVA and Python images, as well as a docker managing Java libraries
- Configuration files and Heat templates to simplify the creation of the virtual
  resources needed for the ONAP deployment and the use cases.

The integration team manages several official ONAP repositories:

.. csv-table:: Integration repositories table
    :file: integration-repositories.csv
    :widths: 30,50,20
    :delim: ;
    :header-rows: 1

Since Frankfurt, we tried to create smaller repositories for the use cases and
the simulators. It shall help us to maintain the use cases and the simulators.
It shall also help to leverage and adopt existing simulators rather than
systematically re-inventing the wheel.

The main wiki page of the Integration team can be found in
https://wiki.onap.org/display/DW/Integration+Project, you will find different
menus, Q&As, and release pages.

Environment Installation
------------------------

In addition of the official OOM scripts, Integration provides some guidelines to
install your OpenStack configuration thanks to a heat template.
See :ref:`Integration heat guideline <integration-installation>` for details.

Integration CI
--------------

Integration project is responsible of the Continuous Integration Chains.
A guide has been created to setup your own CI chain.
See :ref:`Integration CI guideline  <integration-ci>` for details.

Stability Testing
-----------------

Ensuring the stability of ONAP is one of the missions of the Integration team.
CI chains and stability tests are performed to help stabilising the release.
See :ref:`Integration stability tests  <integration-s3p>` for details.
