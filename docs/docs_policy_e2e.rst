.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_policy_e2e:

Policy Framework End to End Tests
---------------------------------

Two automated smoke tests exercise the ONAP Policy Framework end to end:
``basic_policy`` and ``basic_acm``. Both are pythonsdk-tests scenarios and both
are listed in the smoke test table of
:ref:`Automated Use Cases <release_automated_usecases>`.

This page explains what an operator actually gets out of each test, which
services each one drives, why they have to run inside the Kubernetes cluster,
and what has to be true of the deployment before ``basic_acm`` can pass. No
prior knowledge of Automation Composition Management (ACM) is assumed.

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

Architecture
~~~~~~~~~~~~

Both diagrams show a single test run and the direction of control. Numbers are
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

.. note::
   Neither diagram draws the databases. Both the ACM runtime and policy-pap
   persist their state (PostgreSQL or MariaDB, depending on the deployment), so
   a wedged composition or a leftover policy survives a pod restart and has to
   be cleaned up deliberately - restarting a pod will not clear it.

Services exercised
~~~~~~~~~~~~~~~~~~

Every Policy service is ClusterIP only and listens on port 6969, so the
addresses below are the only ones the tests can use. Substitute the real
namespace for ``onap`` if the deployment uses a different one.

.. list-table::
   :widths: 22 26 12 40
   :header-rows: 1

   * - Service
     - In-cluster address
     - Test
     - What the test proves
   * - policy-api
     - ``http://policy-api.onap:6969``
     - both
     - A TOSCA XACML policy can be authored and stored. ``basic_policy`` calls
       it directly and requires ``201``; a ``200`` would mean the policy was
       left behind by an earlier run. In ``basic_acm`` the Policy participant
       calls it on the test's behalf.
   * - policy-pap
     - ``http://policy-pap.onap:6969``
     - both
     - A policy can be deployed to a PDP group, and the deployment converges:
       the status endpoint reaches ``SUCCESS`` rather than staying ``WAITING``
       or reporting ``FAILURE``. This is also the assertion that closes
       ``basic_acm``.
   * - policy-xacml-pdp
     - ``http://policy-xacml-pdp.onap:6969``
     - ``basic_policy``
     - The enforcement point received the policy and applies it. A matching
       request is permitted and carries the policy's advice; a non-matching one
       falls through to the default Deny and carries no advice.
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
through ingress. These two cannot, for two independent reasons.

**The APIs are not exposed.** Every Policy service the tests call is ClusterIP
only on port 6969, with no NodePort and no ingress host. The jumphost container
defines no ``POLICY_*`` URL at all - its only policy adjacent setting points at
the policy UI, not at the APIs. There is nothing to connect to from outside.

**The ACM credential is generated per deployment.** The ACM runtime's
application user password is generated at install time, so it cannot be baked
into a settings module or an environment file the way a static demo credential
can. It is stored in the Kubernetes secret ``onap-policy-app-user-creds``, keys
``login`` and ``password``, and the test reads it through the Kubernetes API at
the moment it needs it, then passes it per request. Nothing writes the value to
a log or an artefact: the scenario logs every setting it holds, so the secret's
*coordinates* are configuration but the secret's *value* never is.

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

Substitute ``run_type=basic_policy`` and
``incluster_settings=onaptests.configuration.basic_policy_settings`` for the
other scenario.

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

**Both jobs are non-blocking** in the smoke tier, in line with the rest of that
tier: a flake is reported without turning the pipeline red. That should be
tightened once a stability baseline exists.
