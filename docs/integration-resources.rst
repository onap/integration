.. This work is licensed under a
   Creative Commons Attribution 4.0 International License.
.. _integration-resources:

.. integration_main-doc:

Integration resources
=====================

.. important::
   The Integration project maintains several community resources:

      - Public Portal: http://testresults.opnfv.org/onap-integration/
      - Test Database & API: http://testresults.opnfv.org/onap/api/v1/projects
      - CI/CD logs & artifacts: https://logs.onap.org/onap-integration
      - VNF demo artifacts: https://nexus.onap.org/content/repositories/releases/org/onap/demo/vnf/
      - :ref:`Simulators <integration-simulators>`
      - Test frameworks (e.g. python-onapsdk)

Integration portal
------------------

A portal is built to report the status of the different labs collaborating in
Integration, see http://testresults.opnfv.org/onap-integration/

.. figure:: files/CI/ONAP_CI_3.png
   :align: center
   :width: 6.5in

The code of this web site is shared on a public gitlab project.

Integration Test database
-------------------------

The integration team shares a Test Result Database with the OPNFV project. All
the test results of the CD are automatically pushed to this database.
It is possible to retrieve the results through the Test API associated with this
test Database.

The following information are available:

- List of pods allowed to push results: http://testresults.opnfv.org/onap/api/v1/pods
- List of projects that declared test cases for CI/CD: http://testresults.opnfv.org/onap/api/v1/projects
- List of integration test cases:
  http://testresults.opnfv.org/onap/api/v1/projects/integration/cases
- List of security test cases:
  http://testresults.opnfv.org/onap/api/v1/projects/security/cases
- Results with lots of possible filter combinations: http://testresults.opnfv.org/onap/api/v1/results?last=3

It is possible to get results according to several criteria (version, case name,
lab, period, last, CI id,..)
See the `OPNFV test API documentation <https://wiki.opnfv.org/pages/viewpage.action?pageId=2926452>`_.

Any company running ONAP Integration tests can be referenced to push their results
to this database.
This Database is hosted on a LF OPNFV server. Results are backuped daily.
Integration committers can have access to this server.

VNF demo Artifacts
------------------

VNF demo artifacts are hosted in the demo repositories and published in
https://nexus.onap.org/content/repositories/releases/org/onap/demo/vnf/.

Communication channels
----------------------

The main communication channel for real time support is the rocket chat channel
http://team.onap.eu.
You can also send a mail to onap-discuss AT lists.onap.org
with [ONAP] [Integration] prefix in the title.

All the different links are reachable from the Integration portal.
