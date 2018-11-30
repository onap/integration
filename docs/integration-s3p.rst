.. _integration-s3p:

ONAP Maturity Testing Notes
---------------------------

For the Casablanca release, ONAP continues to improve in multiple
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

Detailed instructions on how these tests are run can be found at https://wiki.onap.org/display/DW/Casablanca+Stability+Testing+Instructions .

Results: 100% PASS
~~~~~~~~~~~~~~~~~~
=================== ======== ========= =========
Test Case           Attempts Successes Pass Rate
=================== ======== ========= =========
Stability 72 hours   65       65        100%
vFW Closed Loop      71       71        100%
**Total**            136      136       **100%**
=================== ======== ========= =========

Detailed results can be found at https://wiki.onap.org/display/DW/Casablanca+Release+Stability+Testing+Status .

.. note::
 - The Wind River lab OpenStack instance sporadically returns authentication failures or dropped network connections under load.  The 
   Stability 72 hours test runs that failed due to these known infrastructure issues were discarded.
 - The Packet Generator VNF used in the vFW Closed Loop test becomes unstable after long run-times.  The vFWCL test runs that failed 
   due to Packet Generator failures (which are not ONAP platform failures) were discarded.


Resilience
==========

Integration Resilience Testing verifies that ONAP can automatically recover from failures of any of its components.  This is done by deleting the ONAP pods that are involved in each particular Use Case flow and then checking that the Use Case flow can again be executed successfully after ONAP recovers.

Methodology
~~~~~~~~~~~
For each Use Case, a list of the ONAP components involved is identified.  The pods of each of those components are systematically deleted one-by-one; after each pod deletion, we wait for the pods to recover, then execute the Use Case again to verify successful ONAP platform recovery.


Results: 96.9% PASS
~~~~~~~~~~~~~~~~~~~
=============================== ======== ========= =========
Use Case                        Attempts Successes Pass Rate
=============================== ======== ========= =========
VNF Onboarding and Distribution 45       44        97.8%
VNF Instantiation               54       52        96.3%
vFW Closed Loop                 61       59        96.7%
**Total**                       160      155       **96.9%**
=============================== ======== ========= =========

Detailed results can be found at https://wiki.onap.org/display/DW/Casablanca+Release+Stability+Testing+Status .


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
