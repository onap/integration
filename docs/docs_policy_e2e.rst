.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_policy_e2e:

Policy Framework End to End Tests
---------------------------------

Three automated smoke tests exercise the ONAP Policy Framework end to end:
``basic_policy``, ``basic_acm`` and ``basic_opa``. All three are pythonsdk-tests
scenarios and all three are listed in the smoke test table of
:ref:`Automated Use Cases <release_automated_usecases>`.

They cover the two ways a policy reaches an enforcement point - an operator
deploying it by hand and an automation composition doing it by delegation - and
the two enforcement points that can then answer a decision request, XACML and
Open Policy Agent.

This page explains what an operator actually gets out of each test, which
services each one drives, why they have to run inside the Kubernetes cluster,
and what has to be true of the deployment before ``basic_acm`` can pass. No
prior knowledge of Automation Composition Management (ACM) or of Rego, the Open
Policy Agent policy language, is assumed.

The use cases
~~~~~~~~~~~~~

``basic_policy``: the decision point
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Policy Framework lets an operator write a rule once and then have every
other component ask whether an action is allowed, instead of hard coding that
judgement into each component.

The rule used by this test is deliberately small and readable: *a slice request
naming cell* ``448903300002`` *is valid*. The operator authors it, publishes it,
and from that moment on any ONAP component can ask "may I?" and receive a
machine answer with the reason attached - here the advice string
``Cell ID is valid``.

The test walks that whole loop: author the policy, publish it, wait for it to be
distributed to the enforcement point, then ask two questions.

* A legitimate request must be **permitted, and must carry the advice**. The
  advice is the part a caller acts on, so a Permit without it is not good enough.
* An illegitimate request - a different cell identifier - must be **refused, and
  must not carry the advice**, because the policy's default decision is Deny.

The negative case is the point of the test. A policy that permits everything
would sail through the positive check while being worse than having no policy at
all; only the Deny case can catch that.

``basic_acm``: closed loop automation by delegation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Automation Composition Management inverts the model above. Instead of an
operator hand deploying policies, a declarative *automation composition*
describes the automation that is wanted, and the ACM runtime drives
*participants* to realise it. A participant is a component that has registered
with the runtime and advertised the kinds of element it can look after.

In this test the participant being driven is the Policy Framework itself
(``policy-clamp-ac-pf-ppnt``), so the meaning of the composition is simply
"this policy must be deployed and running". The scenario therefore has two
layers, and both are asserted:

#. The **ACM lifecycle** works. A composition definition is commissioned,
   primed, instantiated and deployed, and each transition reaches its expected
   terminal state with ``stateChangeResult == NO_ERROR``. Teardown then walks
   the ladder back down.
#. The **delegation actually terminates in a deployed policy**. After the
   instance reports ``DEPLOYED``, the test queries policy-pap directly and
   requires the policy that the participant was told to deploy to be reported
   as deployed in its PDP group.

The second assertion is what makes this an end to end test rather than an ACM
internal state check. ``DEPLOYED`` only says that the participant answered the
runtime; policy-pap saying ``SUCCESS`` says the policy is really in a PDP group.

Vocabulary, in one place:

commissioning
   Uploading the TOSCA service template that defines a composition and its
   elements. The definition exists but nobody has been told about it yet.
priming
   Distributing that definition to the participants that will own its elements,
   so they can prepare. Ends in ``PRIMED``.
instantiation
   Creating a concrete instance of the definition, with the values for this
   particular automation.
deployment
   Asking the participants to make the instance real. Ends in ``DEPLOYED``. For
   the Policy participant this is where the policy is created and deployed.

``basic_opa``: the same question, answered by Open Policy Agent
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Policy Framework has a second enforcement point: policy-opa-pdp embeds Open
Policy Agent, so a rule can be written in Rego instead of XACML. The operational
promise is the one from ``basic_policy`` - ask "may I?", get an answer with a
reason - but the authoring model is different in a way that matters to the test.

A native OPA policy carries two things: a **Rego module**, the rule itself, and a
**data document**, the values the rule reads. Separating them is what makes the
model useful: a threshold, a whitelist or a capacity limit can be changed by
publishing new data, without touching the logic.

The rule used here is a slicing admission check: *deny a slice request for a cell
whose requested capacity crosses the limit*. The limit lives in the data document
(70), and the Rego rule reads it from there rather than hard coding it. The test
then asks two questions:

* A request for 80, above the limit, must be **denied, with the reason the rule
  builds from the data document** - ``Slicing capacity in cell crosses limit of
  70``. That exact string is the assertion that carries the most information: the
  number in it can only be there if the PDP loaded the data document, so a single
  check covers both halves of the policy.
* A request for 60 must be **permitted**, falling through to the policy's default
  decision. Without it a rule that denies everything would pass the first check.

The value added over ``basic_policy`` is not the loop - that is the same loop -
but the enforcement point. Before this test the OPA PDP was covered only by its
liveness probe and its registration with policy-pap: a regression in Rego
evaluation, in loading the data document or in the shape of the decision response
would have left every job green.

Architecture
~~~~~~~~~~~~

Each diagram shows a single test run and the direction of control. Numbers are
the order in which the test drives the calls.

``basic_policy``
^^^^^^^^^^^^^^^^

The path is short and entirely synchronous from the test's point of view, with
one asynchronous hop: policy-pap accepts the deployment before the policy
decision point has confirmed it, which is why the test polls the deployment
status instead of trusting the response to the deploy call.

.. mermaid::

   flowchart LR
       JOB["xtesting Kubernetes Job<br/>scenario basic_policy"]
       API["policy-api<br/>authoring and storage"]
       PAP["policy-pap<br/>deployment and PDP groups"]
       PDP["policy-xacml-pdp<br/>policy decision point"]

       JOB -->|"1. store the policy, expect 201"| API
       JOB -->|"2. deploy it to a PDP group"| PAP
       PAP -.->|"3. distribute over Kafka"| PDP
       JOB -->|"4. poll status until SUCCESS"| PAP
       JOB -->|"5. ask for a decision, expect Permit with advice"| PDP
       JOB -->|"6. ask again with a value the rule rejects, expect Deny"| PDP

``basic_acm``
^^^^^^^^^^^^^

Here the test never talks to the participant. It talks only to the ACM runtime,
and the runtime reaches the participant over Kafka. Every request that returns
``202 Accepted`` is a Kafka round trip in disguise, so the test polls for a
terminal state after each one rather than treating ``202`` as success.

.. mermaid::

   flowchart TB
       JOB["xtesting Kubernetes Job<br/>scenario basic_acm"]
       ACM["policy-clamp-runtime-acm<br/>ACM runtime, path /onap/policy/clamp/acm/v2"]
       PPNT["policy-clamp-ac-pf-ppnt<br/>Policy participant"]
       API["policy-api<br/>authoring and storage"]
       PAP["policy-pap<br/>deployment and PDP groups"]
       PDP["policy-apex-pdp<br/>subgroup apex of defaultGroup"]

       JOB -->|"1. commission, 2. prime, 3. instantiate, 4. deploy"| ACM
       ACM -->|"Kafka topic policy-acruntime-participant"| PPNT
       PPNT -.->|"Kafka state, acknowledgements, heartbeat"| ACM
       JOB -->|"poll the runtime for PRIMED and DEPLOYED"| ACM
       PPNT -->|"5. create the policy"| API
       PPNT -->|"6. deploy the policy"| PAP
       PAP -.->|"7. distribute over Kafka"| PDP
       JOB -->|"8. poll policy status until SUCCESS"| PAP

Teardown is the same ladder in reverse, and it matters: a composition definition
cannot be deprimed while an instance still exists, and it cannot be deleted
until it is back in ``COMMISSIONED``. The order is undeploy, wait for
``UNDEPLOYED``, delete the instance, deprime, wait for ``COMMISSIONED``, delete
the definition.

``basic_opa``
^^^^^^^^^^^^^

The shape is ``basic_policy``'s, with two differences that both come from the OPA
PDP being a separate component rather than another flavour of the same one: it
listens on its own port, 8282, under its own base path ``/policy/pdpo/v1``, and it
validates its own credentials rather than the Policy Framework's shared ones.

.. mermaid::

   flowchart LR
       JOB["xtesting Kubernetes Job<br/>scenario basic_opa"]
       API["policy-api<br/>authoring and storage"]
       PAP["policy-pap<br/>deployment and PDP groups"]
       PDP["policy-opa-pdp<br/>Open Policy Agent, port 8282"]
       SEC[("Kubernetes secret<br/>onap-policy-opa-pdp-api-creds")]

       JOB -->|"1. store Rego module plus data document, expect 201"| API
       JOB -->|"2. deploy it to opaGroup"| PAP
       PAP -.->|"3. distribute over Kafka"| PDP
       JOB -->|"4. poll status until SUCCESS"| PAP
       SEC -.->|"5. read the PDP credentials"| JOB
       JOB -->|"6. decide on 80, expect Deny with the reason from the data"| PDP
       JOB -->|"7. decide on 60, expect Permit"| PDP

Two details of the payload are worth knowing before reading the fixture, because
both fail silently rather than loudly:

* The Rego module's ``package`` has to equal the policy name
  (``onap.policy.test.opa``), and the data document is keyed
  ``node.<policy name>``. policy-api turns the dotted policy name into the OPA
  data path, so a mismatch leaves the rule unresolvable.
* The decision request needs a non-empty ``policyFilter`` naming the rule to
  evaluate. A filter that matches nothing still answers ``200``, with a
  ``statusMessage`` listing the valid filters in place of the rule's value - so a
  test that only inspects the decision content, and not whether the filtered key
  is present at all, passes against a policy that was never evaluated.

Teardown undeploys the policy through policy-pap and then deletes it through
policy-api, so a rerun gets its ``201`` from a clean database.

.. note::
   Neither diagram draws the databases. Both the ACM runtime and policy-pap
   persist their state (PostgreSQL or MariaDB, depending on the deployment), so
   a wedged composition or a leftover policy survives a pod restart and has to
   be cleaned up deliberately - restarting a pod will not clear it.

Services exercised
~~~~~~~~~~~~~~~~~~

Every Policy service is ClusterIP only, and all of them listen on port 6969
except the OPA PDP, which listens on 8282, so the addresses below are the only
ones the tests can use. Substitute the real namespace for ``onap`` if the
deployment uses a different one.

.. list-table::
   :widths: 22 26 12 40
   :header-rows: 1

   * - Service
     - In-cluster address
     - Test
     - What the test proves
   * - policy-api
     - ``http://policy-api.onap:6969``
     - all three
     - A policy can be authored and stored, in two of the three TOSCA policy
       types the framework supports natively: XACML for ``basic_policy`` and
       ``onap.policies.native.opa`` for ``basic_opa``. Both call it directly and
       require ``201``; a ``200`` would mean the policy was left behind by an
       earlier run. In ``basic_acm`` the Policy participant calls it on the
       test's behalf.
   * - policy-pap
     - ``http://policy-pap.onap:6969``
     - all three
     - A policy can be deployed to a PDP group, and the deployment converges:
       the status endpoint reaches ``SUCCESS`` rather than staying ``WAITING``
       or reporting ``FAILURE``. ``basic_opa`` additionally shows that policy-pap
       routes by policy type, reporting ``pdpType: opa`` for the group
       ``opaGroup``. This is also the assertion that closes ``basic_acm``.
   * - policy-xacml-pdp
     - ``http://policy-xacml-pdp.onap:6969``
     - ``basic_policy``
     - The enforcement point received the policy and applies it. A matching
       request is permitted and carries the policy's advice; a non-matching one
       falls through to the default Deny and carries no advice.
   * - policy-opa-pdp
     - ``http://policy-opa-pdp.onap:8282``
     - ``basic_opa``
     - The Open Policy Agent enforcement point received both halves of the
       policy and evaluates them: a request above the threshold is denied with
       the reason the Rego rule composes from the data document, and one below it
       falls through to the default Permit. Its base path is
       ``/policy/pdpo/v1``.
   * - policy-clamp-runtime-acm
     - ``http://policy-clamp-runtime-acm.onap:6969``
     - ``basic_acm``
     - The full ACM state machine works over its deployed base path
       ``/onap/policy/clamp/acm/v2``: commission, prime, instantiate, deploy and
       the reverse ladder, each reaching a terminal state with
       ``stateChangeResult == NO_ERROR``.
   * - policy-clamp-ac-pf-ppnt
     - not called directly; reached over the Kafka topic
       ``policy-acruntime-participant``
     - ``basic_acm``
     - The Policy participant is registered, claims the composition element and
       translates a deploy order into policy-api and policy-pap calls. If no
       participant claims the element, priming times out instead of failing
       loudly.
   * - policy-apex-pdp
     - not called by the test
     - ``basic_acm``
     - Observed indirectly: the policy the participant deploys is of type
       ``onap.policies.native.Apex``, which lands in the ``apex`` subgroup of
       ``defaultGroup``. That is the group the closing assertion queries.

Why the tests run as an in-cluster Kubernetes Job
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Most smoke tests run in a Docker container on the jumphost and reach ONAP
through ingress. These three cannot, for two independent reasons.

**The APIs are not exposed.** Every Policy service the tests call is ClusterIP
only - port 6969, or 8282 for the OPA PDP - with no NodePort and no ingress host.
The jumphost container defines no ``POLICY_*`` URL at all: its only policy
adjacent setting points at the policy UI, not at the APIs. There is nothing to
connect to from outside.

**Two of the credentials are generated per deployment.** The ACM runtime's
application user password and the OPA PDP's REST server password are generated at
install time, so they cannot be baked into a settings module or an environment
file the way a static demo credential can. They live in the Kubernetes secrets
``onap-policy-app-user-creds`` and ``onap-policy-opa-pdp-api-creds``, keys
``login`` and ``password``, and each test reads the one it needs through the
Kubernetes API at the moment it needs it, then passes it per request. Nothing
writes the value to a log or an artefact: the scenarios log every setting they
hold, so the secret's *coordinates* are configuration but the secret's *value*
never is.

.. note::
   The OPA PDP's chart injects two credential pairs into the container,
   ``API_USER``/``API_PASSWORD`` and
   ``RESTSERVER_USER``/``RESTSERVER_PASSWORD``, but the component binds the basic
   auth of its REST server to the first pair only. Authenticating a decision
   request with the restserver credentials returns ``401``, which is why
   ``basic_opa`` reads ``onap-policy-opa-pdp-api-creds`` and not the
   similarly named restserver secret.

Consequences worth knowing when reading or changing the job:

* The scenario runs with ``IN_CLUSTER = True`` and no kubeconfig; it uses the
  service account token mounted into the pod.
* That service account needs ``get`` on secrets in the ONAP namespace. Nothing
  else.
* The Istio sidecar is disabled on the job pod - otherwise the pod never
  terminates and the job never reports a result.
* ``ONAP_PYTHON_SDK_SETTINGS`` has to be a container environment variable. The
  jumphost path passes it through a Docker environment file, which does not
  exist here.

Running the tests
~~~~~~~~~~~~~~~~~

In the CI chain, each test is one job that renders the settings, creates the
Kubernetes Job and waits for it:

.. code-block:: bash

   ansible-playbook -i inventory/infra xtesting-onap-incluster.yaml \
     --extra-vars "run_type=basic_acm run_tiers=smoke-usecases \
     run_timeout=1800 incluster_settings=onaptests.configuration.basic_acm_settings"

Substitute ``run_type=basic_policy`` or ``run_type=basic_opa``, with the matching
``incluster_settings=onaptests.configuration.<run_type>_settings``, for the other
scenarios.

By hand, from a pod running the smoke test image in the ONAP namespace:

.. code-block:: bash

   ONAP_PYTHON_SDK_SETTINGS=onaptests.configuration.basic_acm_settings \
     run_tests --test basic_acm --report

The per-step verdicts and the raw request and response bodies land in
``pythonsdk.debug.log`` next to the xtesting report. For ``basic_acm`` that log
is the fastest way to see which participant, if any, answered a prime or deploy
order.

Known limitations
~~~~~~~~~~~~~~~~~

**Priming has to be allowed to succeed, and by default it is not.** This is the
first thing to check when ``basic_acm`` fails. The participant intermediary
reads ``participant.intermediaryParameters.failUnsupportedOperation`` and
defaults it to ``true``. With that default, any operation a participant does not
implement is reported as a failure - and no participant implements ``prime``.
Priming therefore always comes back as ``COMMISSIONED`` / ``FAILED`` with the
message ``Not supported``, and the composition is then stuck: it cannot be
deleted either, because deletion requires the ``COMMISSIONED`` state to have
been reached cleanly, so the API answers ``400 ACM not in COMMISSIONED state``.

The upstream participant configuration sets the key to ``false``. If a
deployment's charts omit it, the default wins and this test cannot pass. **If
you see** ``COMMISSIONED`` / ``FAILED`` / ``Not supported``, **look at that
setting before looking at anything else.**

**Priming is a no-op for the Policy participant even when it succeeds.** With
the key set to ``false``, ``prime`` reports ``PRIMED`` with the message
``Not implemented``; it does no real work. The concrete Policy participant
handler overrides only ``deploy`` and ``undeploy``, so everything meaningful
happens at deploy time. ``basic_acm`` therefore proves the ACM state machine,
the participant's deploy path and the bridge into policy-api and policy-pap. It
does not prove that priming does anything useful, because upstream it does not.

**Teardown is best effort.** Every cleanup step logs a warning instead of
raising, so a wedged composition leaves residue rather than failing the run a
second time and masking the original error. The trade is deliberate, but it
means an occasional ``GET /compositions`` is worth doing to spot leftovers.

**The XACML decision assertions match on the serialised response body** rather
than on an exact JSON path, which is robust to key casing and to single versus
array wrapping, but less precise than it could be. Tightening it requires a
recorded response body from a real run.

**A native OPA policy only reaches the OPA PDP through** ``opaGroup``. The group
name is compiled into policy-opa-pdp, so it is not configurable: deploying such a
policy to any other group is accepted by policy-pap and then never enforced.
``basic_opa`` uses ``opaGroup`` for that reason, which also means it shares no PDP
group with the other two tests and can run beside them.

**basic_opa evaluates one rule, not the OPA feature surface.** It covers the parts
every native OPA policy depends on - authoring, distribution, data document
loading, rule evaluation and the response contract. It does not cover Rego
imports across policies, updating a live policy's data document in place, or the
PDP's own data API.

**All three jobs are non-blocking** in the smoke tier, in line with the rest of
that tier: a flake is reported without turning the pipeline red. That should be
tightened once a stability baseline exists.
