.. This work is licensed under a
   Creative Commons Attribution 4.0 International License.
.. _integration-s3p:

Stability/Resiliency
====================

.. important::
    The Release stability has been evaluated by:

    - The daily Istanbul CI/CD chain
    - Stability tests
    - Resiliency tests

.. note:
    The scope of these tests remains limited and does not provide a full set of
    KPIs to determinate the limits and the dimensioning of the ONAP solution.

CI results
----------

As usual, a daily CI chain dedicated to the release is created after RC0.
An Istanbul chain has been created on the 5th of November 2021.

The daily results can be found in `LF daily results web site
<https://logs.onap.org/onap-integration/daily/onap_daily_pod4_istanbul/>`_.

Infrastructure Healthcheck Tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These tests deal with the Kubernetes/Helm tests on ONAP cluster.

The global expected criteria is **75%**.
The onap-k8s and onap-k8s-teardown  providing a snapshop of the onap namespace in
Kubernetes as well as the onap-helm tests are expected to be PASS.

nodeport_check_certs test is expected to fail. Even tremendous progress have
been done in this area, some certificates (unmaintained, upstream or integration
robot pods) are still not correct due to bad certificate issuers (Root CA
certificate non valid) or extra long validity. Most of the certificates have
been installed using cert-manager and will be easily renewable.

.. image:: files/s3p/istanbul_daily_infrastructure_healthcheck.png
   :align: center

Healthcheck Tests
~~~~~~~~~~~~~~~~~

These tests are the traditionnal robot healthcheck tests and additional tests
dealing with a single component.

The expectation is **100% OK**.

.. image:: files/s3p/istanbul_daily_healthcheck.png
  :align: center

Smoke Tests
~~~~~~~~~~~

These tests are end to end and automated use case tests.
See the :ref:`the Integration Test page <integration-tests>` for details.

The expectation is **100% OK**.

.. figure:: files/s3p/istanbul_daily_smoke.png
  :align: center

An error has been reported since Guilin (https://jira.onap.org/browse/SDC-3508) on
a possible race condition in SDC preventing the completion of the certification in
SDC and leading to onboarding errors.
This error may occur in case of parallel processing.

Security Tests
~~~~~~~~~~~~~~

These tests are tests dealing with security.
See the  :ref:`the Integration Test page <integration-tests>` for details.

Waivers have been granted on different projects for the different tests.
The list of waivers can be found in
https://git.onap.org/integration/seccom/tree/waivers?h=istanbul.

The expectation is **100% OK**. The criteria is met.

.. figure:: files/s3p/istanbul_daily_security.png
  :align: center

Resiliency tests
----------------

The goal of the resiliency testing was to evaluate the capability of the
Istanbul solution to survive a stop or restart of a Kubernetes worker node.

This test has been automated thanks to the
[Litmus chaos framework](https://litmuschaos.io/) and automated in the CI on the
weekly chains.

2 additional tests based on Litmus chaos scenario have been added but will be tuned
in Jakarta.

- node cpu hog (temporary increase of CPU on 1 kubernetes node)
- node memory hog (temporary increase of Memory on 1 kubernetes node)

The main test for Istanbul is node  drain corresponding  to the resiliency scenario
previously managed manually.

The test sequence can be define as follows:

- Cordon a compute node (prevent any new scheduling)
- Launch node drain chaos scenario, all the pods on the given compute node
  are evicted

Once all the pods have been evicted:

- Uncordon the compute node
- Replay a basic_vm test

This test has been successfully executed.

.. important::

  Please note that the chaos framework select one compute node (the first one).
  The distribution of the pods is random, on our target architecture about 15
  pods are scheduled on each node. The chaos therefore affects only a limited
  number of pods.

For the Istanbul tests, the evicted pods were:

```
NAME                                          READY    STATUS    RESTARTS   AGE
onap-aaf-service-dbd8fc76b-vnmqv               1/1     Running      0      2d19h
onap-aai-graphadmin-5799bfc5bb-psfvs           2/2     Running      0      2d19h
onap-cassandra-1                               1/1     Running      0      2d19h
onap-dcae-ves-collector-856fcb67bd-lb8sz       2/2     Running      0      2d19h
onap-dcaemod-distributor-api-85df84df49-zj9zn  1/1     Running      0      2d19h
onap-msb-consul-86975585d9-8nfs2               1/1     Running      0      2d19h
onap-multicloud-pike-88bb965f4-v2qc8           2/2     Running      0      2d19h
onap-netbox-nginx-5b9b57d885-hjv84             1/1     Running      0      2d19h
onap-portal-app-66d9f54446-sjhld               2/2     Running      0      2d19h
onap-sdnc-ueb-listener-5b6bb95c68-d24xr        1/1     Running      0      2d19h
onap-sdnc-web-8f5c9fbcc-2l8sp                  1/1     Running      0      2d19h
onap-so-779655cb6b-9tzq4                       2/2     Running      1      2d19h
onap-so-oof-adapter-54b5b99788-x7rlk           2/2     Running      0      2d19h
```

Stability tests
---------------

Stability tests have been performed on Istanbul release:

- SDC stability test
- Parallel instantiation test

The results can be found in the weekly backend logs
https://logs.onap.org/onap-integration/weekly/onap_weekly_pod4_istanbul.

SDC stability test
~~~~~~~~~~~~~~~~~~

In this test, we consider the basic_onboard automated test and we run 5
simultaneous onboarding procedures in parallel during 24h.

The basic_onboard test consists in the following steps:

- [SDC] VendorOnboardStep: Onboard vendor in SDC.
- [SDC] YamlTemplateVspOnboardStep: Onboard vsp described in YAML file in SDC.
- [SDC] YamlTemplateVfOnboardStep: Onboard vf described in YAML file in SDC.
- [SDC] YamlTemplateServiceOnboardStep: Onboard service described in YAML file
  in SDC.

The test has been initiated on the Istanbul weekly lab on the 6th of November.

As already observed in daily|weekly|gating chain, we got race conditions on
some tests (https://jira.onap.org/browse/INT-1918).

The success rate is expected to be above 95% on the 100 first model upload
and above 80% until we onboard more than 500 models.

We may also notice that the function test_duration=f(time) increases
continuously. At the beginning the test takes about 200s, 24h later the same
test will take around 1000s.
Finally after 36h, the SDC systematically answers with a 500 HTTP answer code
explaining the linear decrease of the success rate.

The following graphs provides a good view of the SDC stability test.

.. image:: files/s3p/istanbul_sdc_stability.png
  :align: center

.. important::
   A regression is observed on SDC onboarding.
   Results are not as good as for honolulu.
   The onboarding duration increases linearly with the number of on-boarded
   models
   After a while, the SDC is no more usable.
   No major Cluster resource issues have been detected during the test. The
   memory consumption is however relatively high regarding the load.

Parallel instantiations stability test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The test is based on the single test basic_vm that can be described as follows:

- [SDC] VendorOnboardStep: Onboard vendor in SDC.
- [SDC] YamlTemplateVspOnboardStep: Onboard vsp described in YAML file in SDC.
- [SDC] YamlTemplateVfOnboardStep: Onboard vf described in YAML file in SDC.
- [SDC] YamlTemplateServiceOnboardStep: Onboard service described in YAML file
  in SDC.
- [AAI] RegisterCloudRegionStep: Register cloud region.
- [AAI] ComplexCreateStep: Create complex.
- [AAI] LinkCloudRegionToComplexStep: Connect cloud region with complex.
- [AAI] CustomerCreateStep: Create customer.
- [AAI] CustomerServiceSubscriptionCreateStep: Create customer's service
  subscription.
- [AAI] ConnectServiceSubToCloudRegionStep: Connect service subscription with
  cloud region.
- [SO] YamlTemplateServiceAlaCarteInstantiateStep: Instantiate service described
  in YAML using SO a'la carte method.
- [SO] YamlTemplateVnfAlaCarteInstantiateStep: Instantiate vnf described in YAML
  using SO a'la carte method.
- [SO] YamlTemplateVfModuleAlaCarteInstantiateStep: Instantiate VF module
  described in YAML using SO a'la carte method.

10 instantiation attempts are done simultaneously on the ONAP solution during 24h.

The results can be described as follows:

.. image:: files/s3p/istanbul_instantiation_stability_10.png
 :align: center

The results are good with a success rate above 97%. After 24h more than 1300
VNF have been created and deleted.
As for SDC, we can observe a linear increase of the test duration. This issue
has been reported since Guilin. For SDC as it is not possible to delete the
model, it is possible to imagine that the duration increases due to the fact
that the database of models continuously increases. Therefore teh client has
to retrieve a always increasing list of model.
But for the instantiation, it is not teh case as the references
(module, VNF, service) are cleaned at the end of each test and all the tests
use teh same model. Then the duration of an instantiation test should be
almost constant, which is not the case. Further investigations are needed.

.. important::
  The test has been executed with the mariadb-galera replicaset set to 1
  (3 by default). With this configuration the results during 24h are very
  good. When set to 3, the error rate is higher and after some hours
  most of the instantiation are failing.
  However, even with a replicaset set to 1, a test on Master weekly chain
  showed that the system is hitting another limit after about 35h
  (https://jira.onap.org/browse/SO-3791).
