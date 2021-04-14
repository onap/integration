.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _nf_simulator:

:orphan:

NF Simulator
============

Description
-----------
An idea behind NF simulator is to introduce simulator, which supports ORAN defined O1 interface (reporting of NF events to Service Management Orchestrators).
Within the use-case, it is expected, that an NF configuration change, happening due to multiple reasons (network mechanism triggered change - e.g. discovery of neighbours) is reported to the network management system, using ONAP`s VES REST events.
The simulator is expected to cover planned NF behaviour - receive the config change via a NetConf protocol and report that change (also potentially other related changes) to the network management system using ONAP`s VES event.

|image1|

**Figure 1. Architecture Overview**

NF Simulator code is stored in https://gerrit.onap.org/r/admin/repos/integration/simulators/nf-simulator and all it's sub repos are:

* for VES Client - https://gerrit.onap.org/r/admin/repos/integration/simulators/nf-simulator/ves-client
* for Netconf Server - https://gerrit.onap.org/r/admin/repos/integration/simulators/nf-simulator/netconf-server
* for AVCN Manager - https://gerrit.onap.org/r/admin/repos/integration/simulators/nf-simulator/avcn-manager
* for PM HTTPS Server - https://gerrit.onap.org/r/admin/repos/integration/simulators/nf-simulator/pm-https-server

For above components has been prepared docker images stored in Nexus and example helm charts:

- `VES Client images. <https://nexus3.onap.org/#browse/search=keyword%3D*vesclient*>`_
- `AVCN Manager images. <https://nexus3.onap.org/#browse/search=keyword%3D*avcn*>`_
- `PM HTTPS Server images. <https://nexus3.onap.org/#browse/search=keyword%3D*nfsimulator.pmhttpsserver*>`_
- `Netconf Server images. <https://nexus3.onap.org/#browse/search=keyword%3D*netconfserver*>`_
- `Helm charts <https://gerrit.onap.org/r/gitweb?p=integration/simulators/nf-simulator.git;a=tree;f=helm;hb=HEAD>`_

**VES Client, Netconf Server and PM HTTPS Server can be used and deployed separately depending from needs.**

Only AVCN Manger connects VES Client with Netconf Server in order to support O1 interface.

1. VES Client:
-----------

   Simulator that generates VES events on demand.

   **What does it do?**

   * Supports both basic auth and TLS CMPv2 method of authentication.
   * Allows to turn on and turn off hostname, verification in SSL.
   * Allows to send one-time event and periodic events, based on event templates.
   * Exposes API to manage VES Client
   * Provides template mechanism (Template is a draft event. Merging event with patch will result in valid VES event.
     Template itself should be a correct VES event as well as valid json object. )
   * Patching - User is able to provide patch in request, which will be merged into template.
   * Simulator supports corresponding keywords in templates: RandomInteger(start,end), RandomPrimitiveInteger(start,end), RandomInteger,
     RandomString(length), RandomString, Timestamp, TimestampPrimitive, Increment
   * In place variables support - Simulator supports dynamic keywords e.g. #dN to automatically substitute selected phrases in defined json schema.
   * Logging - Every start of simulator will generate new logs that can be found in docker ves-client container.
   * Swagger - Detailed view of simulator REST API is available via Swagger UI
   * History - User is able to view events history.


2. Netconf Server:
-----------

   This server uses sysrepo to simulate network configuration.
   It is base od sysrepo-netopeer2 image.

   **What does it do?**

   Server allows to:

   * install custom configuration models on start up.
   * change configuration of that modules on runtime.
   * use TLS custom certificates
   * configure change subscription for particular YANG modules (Netconf server image run python application on the startup.)
   * manage netconf server using REST interface, with endpoints:

      * /healthcheck
      * /readiness
      * /change_config/<path:module_name>` changes configuration
      * /change_history` returns change history as json
      * /get_config/<path:module_name>` returns current configuration

3. AVCN Manager:
-----------

   Simulator that fetches changes of configuration from kafka and sends them to VES client.

   **What does it do?**

   The simulator processes notifications from NETCONF server. It does this by being a subscriber of a Kafka topic that is fed
   with NETCONF notifications. Incoming notifications are then processed and output of this processing is sent to VES client.

4. PM HTTPS Server
-----------

   Simulator that is used in Bulk PM usecases over HTTPS

   **What does it do?**

   * Supports TLS (CMPv2) method of authentication (used during connection to Data File Collector)
   * Allows to use custom certificates
   * Exposes REST API in order to manage PM files stored in HTTPS server


Guides
======

User And Developer Guide
-----------
User guides:

- `VES Client user guide. <https://gerrit.onap.org/r/gitweb?p=integration/simulators/nf-simulator/avcn-manager.git;a=blob;f=README.md;hb=HEAD>`_
- `AVCN Manager user guide. <https://gerrit.onap.org/r/gitweb?p=integration/simulators/nf-simulator/avcn-manager.git;a=blob;f=README.md;hb=HEAD>`_
- `PM HTTPS Server user guide. <https://gerrit.onap.org/r/gitweb?p=integration/simulators/nf-simulator/pm-https-server.git;a=blob;f=README.md;hb=HEAD>`_
- `Netconf Server user guide. <https://gerrit.onap.org/r/gitweb?p=integration/simulators/nf-simulator/netconf-server.git;a=blob;f=README.md;hb=HEAD>`_
- `Netconf Notification Application user guide. <https://gerrit.onap.org/r/gitweb?p=integration/simulators/nf-simulator/netconf-server.git;a=blob;f=src/python/README.md;hb=HEAD>`_
- `NF Simulator CLI user guide <https://gerrit.onap.org/r/gitweb?p=integration/simulators/nf-simulator.git;a=blob;f=simulator-cli/README.md;hb=HEAD>`_

Jenkins builds:

* `VES Client jenkins builds <https://jenkins.onap.org/view/integration-simulators-nf-simulator-avcn-manager/>`_
* `AVCN Manager jenkins builds <https://jenkins.onap.org/view/integration-simulators-nf-simulator-netconf-server/>`_
* `PM HTTPS Server jenkins builds <https://jenkins.onap.org/view/integration-simulators-nf-simulator-pm-https-server/>`_
* `Netconf Server jenkins builds <https://jenkins.onap.org/view/integration-simulators-nf-simulator-ves-client/>`_

NF Simulator CSIT test cases:

* `Project integration-simulators-nf-simulator-netconf-server-master-verify-csit-testsuites <https://jenkins.onap.org/view/integration-simulators-nf-simulator-netconf-server/job/integration-simulators-nf-simulator-netconf-server-master-verify-csit-testsuites/>`_
* `Project integration-simulators-nf-simulator-netconf-server-master-csit-testsuites <https://jenkins.onap.org/view/integration-simulators-nf-simulator-netconf-server/job/integration-simulators-nf-simulator-netconf-server-master-csit-testsuites/>`_

NF Simulator sanity checks:

* https://gerrit.onap.org/r/gitweb?p=integration/simulators/nf-simulator.git;a=tree;f=sanitycheck;hb=HEAD
* `readme.md <https://gerrit.onap.org/r/gitweb?p=integration/simulators/nf-simulator.git;a=blob;f=sanitycheck/README.md;hb=HEAD>`_

.. |image1| image:: ../files/simulators/NF-Simulator.png
   :width: 10in