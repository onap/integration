.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. _master_index:

INTEGRATION
===========

The Integration project is in charge of:

- Providing testing environment and support for the release use cases
- Executing Cross-project Continuous System Integration Testing (CSIT)
- Managing full ONAP CI chains (daily master, staging, stable) to ensure the
  stability of the integration
- Developing and performing tests within full ONAP context (healthcheck, End to
  End, performance, robustness...)
- Validating the ONAP release

For each release, the integration team provides the following artifacts:

- Test suites and tools to check the various ONAP components
- Use-case documentation and artifacts
- a testsuite docker ncluded in ONAP cluster to execute the tests
- Configuration fiales and Heat templates to simplify the creation of the virtual
  ressources needed for the ONAP deployment and the use cases.

The integration team manages several official ONAP repositories:

- integration/*
- testsuite/*
- demo/*
- oparent/*.


.. include:: onap-oom-heat.rst


.. include:: onap-integration-ci.rst
