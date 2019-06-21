.. _integration-s3p:

ONAP Maturity Testing Notes
---------------------------

For the Dublin release, ONAP continues to improve in multiple
areas of Scalability, Security, Stability and Performance (S3P)
metrics.



Stability
=========
Integration Stability Testing verifies that the ONAP platform remains fully functional after running for an extended amounts of time.  This is done by repeated running tests against an ONAP instance for a period of 72 hours.

Methodology
~~~~~~~~~~~

The Stability Test has two main components:

- Running "ete stability72hr" Robot suite periodically.  This test suite verifies that ONAP can instantiate vDNS, vFWCL, and VVG.
- Set up vFW Closed Loop to remain running, then check periodically that the closed loop functionality is still working.


Results: 100% PASS
~~~~~~~~~~~~~~~~~~
=================== ======== ========== ======== ========= =========
Test Case           Attempts Env Issues Failures Successes Pass Rate
=================== ======== ========== ======== ========= =========
Stability 72 hours  72       34         0        38        100%
vFW Closed Loop     75       7          0        68        100%
**Total**           147      41         0        106       **100%**
=================== ======== ========== ======== ========= =========

Detailed results can be found at https://wiki.onap.org/display/DW/Dublin+Release+Stability+Testing+Status .

.. note::
 - Overall results were good. All of the test failures were due to
   issues with the unstable environment and tooling framework.
 - JIRAs were created for readiness/liveness probe issues found while
   testing under the unstable environment. Patches applied to oom and
   testsuite during the testing helped reduce test failures due to
   environment and tooling framework issues.
 - The vFW Closed Loop test was very stable and self recovered from
   environment issues.


Resilience
==========

Integration Resilience Testing verifies that ONAP can automatically recover from failures of any of its components.  This is done by deleting the ONAP pods that are involved in each particular Use Case flow and then checking that the Use Case flow can again be executed successfully after ONAP recovers.

Methodology
~~~~~~~~~~~
For each Use Case, a list of the ONAP components involved is identified.  The pods of each of those components are systematically deleted one-by-one; after each pod deletion, we wait for the pods to recover, then execute the Use Case again to verify successful ONAP platform recovery.


Results: 99.4% PASS
~~~~~~~~~~~~~~~~~~~
=============================== ======== ========== ======== ========= =========
Use Case                        Attempts Env Issues Failures Successes Pass Rate
=============================== ======== ========== ======== ========= =========
VNF Onboarding and Distribution 49       0          0        49        100%
VNF Instantiation               64       19         1        44        97.8%
vFW Closed Loop                 66       0          0        66        100%
**Total**                       179      19         1        159       **99.4%**
=============================== ======== ========== ======== ========= =========

Detailed results can be found at https://wiki.onap.org/display/DW/Dublin+Release+Resilience+Testing+Status .


Deployability
=============

Smaller ONAP container images footprint reduces resource consumption,
time to deploy, time to heal, as well as scale out resources.

Minimizing the footprint of ONAP container images reduces resource
consumption, time to deploy, time and time to heal. It also reduces
the resources needed to scale out and time to scale in. For those
reasons footprint minimization postively impacts the scalability of
the ONAP platform.  Smaller ONAP container images footprint reduces
resource consumption, time to deploy, time to heal, as well as scale
out resources.
