.. This work is licensed under a
   Creative Commons Attribution 4.0 International License.
.. integration-tooling:

Tooling
=======

.. important::
   Integration team deals with lots of tools to complete its missions. The goal
   of this section is to highlight some of them and redirect to their official
   documentation. These tools can be used for CI/CD, Testing or platform management.

   **Upstream tools** are priviledged but when needed specific developments can be done.

   Please note that none of these tools are imposed to test developers, in other
   words, any kind of test is accepted and can be integrated, the list of tools
   is just indicative.

Testing
-------

Test frameworks
~~~~~~~~~~~~~~~

Robotframework
..............

`robotframework <https://robotframework.org/>`_ is a well known test framework.
Lots of ONAP tests are leveraging this framework.
This framework is fully developed upstream even if some extensions (python
modules) were created especially to deal with OpenStack (see
`python-testing-utils project <https://git.onap.org/testsuite/python-testing-utils/>`_).

Some GUI tests (using Robotframework Selenium extension) had been initiated but
not maintained, as a consequence there are not integrated in CI/CD.


Python-onapsdk
..............

The Openstack and Kubernetes python SDK are references widely adopted by the
developers and the industry. Developing a python ONAP SDK aimed to follow the
examples of the infrastructure SDK with the same expectations in term of code
quality.
After an evaluation of the CLI project (JAVA SDK re-exposing primitives through
python system calls), and a first prototype (onap_tests used until Frankfurt for
end to end tests) it was decided to develop a new python SDK.

This SDK has been developed in gitlab.com to benefit from the numerous built-in
options offered by gitlab and ensure the best possible code quality.

- `python SDK repositoy <https://gitlab.com/Orange-OpenSource/lfn/onap/python-onapsdk>`_
- `python SDK documentation <https://python-onapsdk.readthedocs.io/en/latest/?badge=develop>`_

The project is fully Open Source, released under the Apache v2 license.
Integration committers are invited to join the project. The main maintainers are
ONAP integration and OOM committers.

Any new feature shall respect the code quality criteria:

- unit test coverage > 98%
- functional tests (several components mock objects have been developed)

.. attention::
    Python-onapsdk is a **SDK**, it means it is a tool allowing to communicate
    with ONAP. It is a **middleware** that can be used by test projects but it is
    **NOT a test**.

A compagnon project has been created in ONAP:
`pythonsdk-tests <https://git.onap.org/testsuite/pythonsdk-tests/>`_.

The pythonsdk-test project defines tests based on python-onapsdk.

The tests are hosted in this repository. They consume the different needed SDK:
python-onapsdk but also the kubernetes, the OpenStack SDK and or any needed
additional middlewares.
The project developed the notion of steps that can been combined and reorganized
as need to design a test. This project interacts with ONAP only through the
python-onapsdk library.
The tests are described in :ref:`The Integration Test page <integration-tests>`.

The available steps are:

- [CLAMP] OnboardClampStep: Onboard a SDC including a TCA blueprint
- [CDS] ExposeCDSBlueprintprocessorNodePortStep: expose CDS blueprint nodeport (Guilin workaround)
- [CDS] BootstrapBlueprintprocessor: Bootstrap a blueprint processor
- [CDS] DataDictionaryUploadStep: Upload a Data Dictionary to CDS
- [CDZ] CbaEnrichStep: Enrich CBA
- [K8S plugin] K8SProfileStep: Create K8S profile
- [SO] YamlTemplateVfModuleAlaCarteInstantiateStep: Instantiate VF module described in YAML using SO a'la carte method
- [SO] YamlTemplateVlAlaCarteInstantiateStep: Instantiate network link described in YAML using SO a'la carte method.
- [SO] YamlTemplateVfModuleAlaCarteInstantiateStep: Instantiate VF module described in YAML using SO a'la carte method
- [SO] YamlTemplateVnfAlaCarteInstantiateStep: Instantiate vnf described in YAML using SO a'la carte method
- [SO] YamlTemplateServiceAlaCarteInstantiateStep: Instantiate service described in YAML using SO a'la carte method
- [AAI] ConnectServiceSubToCloudRegionStep: Connect service subscription with cloud region
- [AAI] CustomerServiceSubscriptionCreateStep: Create customer's service subscription
- [AAI] CustomerCreateStep: Create customer
- [AAI] LinkCloudRegionToComplexStep: Connect cloud region with complex
- [AAI] ComplexCreateStep: Create complex
- [AAI] RegisterCloudRegionStep: Register cloud region
- [SDC] YamlTemplateServiceOnboardStep: Onboard service described in YAML file in SDC
- [SDC] YamlTemplateVfOnboardStep: Onboard vf described in YAML file in SDC
- [SDC] YamlTemplateVspOnboardStep: Onboard vsp described in YAML file in SDC
- [SDC] VendorOnboardStep: Onboard vendor in SDC

You can reuse the existing steps to compose your test and/or code your own step
if it is not supported yet.

The procedure to start a test is described in `pythonsdk-test README <https://git.onap.org/testsuite/pythonsdk-tests/tree/README.md>`_

Simulators
~~~~~~~~~~

Several simulators are created to support the use cases.

.. important::
    Before starting the development of a new simulator, please consider the existing
    ones, you may fine a simulator that already partially fulfills your needs..
    if so priviledge contributing to the simulator than creating a new one.

pnf simulator
.............

The `pnf-simulator <https://git.onap.org/integration/simulators/pnf-simulator/>`_
can be used for several tasks:

- Simulate PNF and interact with CDS (reconfiguration, template update)
- Send VES event to the VES collector and trigger closed loops

A Rest API has been integrated in Guilin, allowing a http control interface of
the simulator.

See 'README.md <https://gerrit.onap.org/r/gitweb?p=integration/simulators/pnf-simulator.git;a=blob_plain;f=pnfsimulator/README.md;hb=43d113d683ab082f8e2b7ce062e9601e74ffde3a>'__
for details.

Please note that this simulator has optional python CLI, see
'README.md <https://gerrit.onap.org/r/gitweb?p=integration/simulators/pnf-simulator.git;a=blob_plain;f=simulator-cli/README.md;hb=43d113d683ab082f8e2b7ce062e9601e74ffde3a>'__
for details.

.. note::
    There are several pnf-simulators. This simulator is a legacy simulator. It
    was forked and one of the fork is known as Mass PNF simulator (hosted in
    integration repository).


CI/CD
-----

The CI/CD is key for integration. It consolidates the trustability in the solution
by the automated verification of the deployment and the execution of tests.
Integration tests complete the component tests (unit and functional known as
CSIT tests).

Xtesting
~~~~~~~~

As the tests can be very heterogeneous (framework, language, outputs), the
integration team integrates the tests in simple isolated execution context based
on docker called **xtesting dockers**.

Xtesting is a python library harmonizing the way to setup, run, teardown,
manage the artifacts, manage the reporting of the tests (automatic push of the
results on a DB backend). It was developed by
`OPNFV functest project <https://git.opnfv.org/functest-xtesting/>`_.
This python library is included in an alpine docker and contains the needed
tests, their associated libraries as well as a testcases.yaml listing these tests.
These docker files are built on any change in the integration/xtesting repository
and daily to take into account the upstream changes.

The integration project manages 5 xtesting dockers, see
:ref:`Integration Test page <integration-tests>`.

.. important::
    **xtesting is a CI/CD framework, neither a test nor a test framework**

    Testers can provide tests independently from xtesting.
    However to be part of the CI/CD chains, an integration of the test in xtesting
    will be required.

The configuration files are provided as volumes and defined in each docker.
The use of this CI/CD abstraction for the tests simplify the integration
of the test suites in any CI/CD systems and harmonize the inputs and the outputs.

The official documentation can be found on
`xtesting official web site <https://xtesting.readthedocs.io/en/latest/>`_
