.. This file is licensed under the CREATIVE COMMONS ATTRIBUTION 4.0 INTERNATIONAL LICENSE
.. Full license text at https://creativecommons.org/licenses/by/4.0/legalcode

.. contents::
   :depth: 3
..
.. _docs_E2E_network_slicing:


E2E Network Slicing Use Case
============================

Overall Blueprint
-----------------

The objective of this use case is to realize End-to-End 5G Network
Slicing using ONAP. An End-to-End Network Slice consists of RAN (Radio
Access Network), Transport Network (TN) and Core Network (CN) slice
sub-nets. This use case intends to demonstrate the modeling,
orchestration (life cycle and resources) and assurance of a network
slice which are implemented in alignment with relevant standards. The
key highlights of this use case include:

-  Modular architecture providing building blocks and flexibility under
   various deployment scenarios

-  Functionality aligned with 3GPP and other relevant standards such as
   ETSI and IETF

-  Interfaces and APIs aligned with relevant standards (3GPP, IETF,
   ETSI, TM Forum, etc.) while enabling easy customization through use
   of appropriate plug-ins. This would enable easier interoperability of
   slice management functions realized within ONAP with 3\ :sup:`rd`
   party slice management functions, as well as northbound and
   southbound systems.

-  Taking a step-by-step approach to realizing different architectural
   options in an extendable manner.

-  Providing flexibility in network slice selection by providing an
   option of manual intervention, as well as abstracting the network
   internals as needed.

-  The use case implementation team is composed of service providers,
   software and hardware vendors, solution providers and system
   integrators thereby taking into consideration different perspectives
   and requirements.

This use case is a multi-release effort in ONAP with the first steps
taken in Frankfurt release. It will continue to expand in scope both in
breadth and depth, and along the journey it shall also align with
updates to the relevant standards which are also currently evolving.
This use case shall also collaborate with other open initiatives such as
O-RAN to enable wider adoption and use.

Further details can be obtained from:
https://wiki.onap.org/display/DW/Use+Case+Description+and+Blueprint


Abbreviations
-------------

+---------------+--------------------------------------------+
|  Abbreviation |                   Meaning                  |
+===============+============================================+
| CSMF          | Communication Service Management Function  |
+---------------+--------------------------------------------+
| CSI           | Communication Service Instance             |
+---------------+--------------------------------------------+
| CST           | Communication Service Template             |
+---------------+--------------------------------------------+
| NSI           | Network Slice Instance                     |
+---------------+--------------------------------------------+
| NSMF          | Network Slice Management Function          |
+---------------+--------------------------------------------+
| NSSI          | Network Slice Sub-net Instance             |
+---------------+--------------------------------------------+
| NSSMF         | Network Slice Sub-net Management Function  |
+---------------+--------------------------------------------+
| NST           | Network Slice Template                     |
+---------------+--------------------------------------------+
| NSST          | Network Slice Sub-net Template             |
+---------------+--------------------------------------------+


Scope for Frankfurt
-------------------

To realize the three layers of the slice management function, we need to decide whether to implement CSMF, NSMF or NSMF within ONAP, or use the external CSMF, NSMF or NSSMF. This implies that for ONAP-based network slice management, we have different choices from an architectural perspective. For Frankfurt release, our scope is to implement CSMF and NSMF within ONAP, while connecting to an external Core NSSMF.

From the NSI Life Cycle perspective, the scope for Frankfurt includes NSI design and pre-provision, NSI instantiation and configuration, and NSI activation and deactivation. In particular:

- CSMF: Functions of slice service creation, slice service activation and deactivation are implemented.

- NSMF: Functions of NSI instantiation, NSI activation and deactivation are
  implemented. In addition, manual intervention is also provided in NSMF slice task
  management portal to ensure the selected NSI/NSSI as well as ServiceProfile and
  SliceProfile are fine or need adjustment.

- Design of CST, NST and onboarding NSST that are required to support the run-time   orchestration functions is also provided.

- To connect to the external (core) NSSMF, an adaptor is implemented to provide
  interface between ONAP and 3rd party core NSSMF.

To support the above functions, code impacts in U-UI, SO, OOF and ExtAPI components, and schema change in A&AI are implemented.

Further details can be obtained from:
https://wiki.onap.org/display/DW/Proposed+Functions+for+R6+and+Impacted+Modules


Impacted Modules for Frankfurt
------------------------------

SO
~~

CSMF and NSMF are implemented using SO BPMN workflows to support 5G
network slicing use case. CSMF workflow will process the user input
(service request) that comes from CSMF portal (UUI) and save the order
information into a communication service instance in AAI. Then CSMF will
send network slice request to NSMF workflow, and NSMF will then create
service profile, NSI and NSSI. Service profile is a logical concept
which exists only in AAI - it contains two AAI instances, one is a
profile instance that will hold the slice parameters, and the other is a
service instance which will be used to organize the NSI. NSI is also a
service instance in AAI which will be used to organize NSSI. NSSI is the
actual entity which will be created by NSSMF and an AAI service instance
will also be created to represent NSSI in ONAP context. NSI and NSSI can
both be shared.

SO queries OOF for slice template selection and then slice instance
selection. In response to slice instance selection query, OOF may return
an existing slice instance or may recommend SO to create a new slice
instance. A new process called Orchestration Task is created to manage
recalibration of NSI&NSSI selection with manual intervention from the
portal. A new SO adapter is created to be the adapter of NSSMF which
will interact with external NSSMF for NSSI management.

Further details can be obtained from:
https://wiki.onap.org/display/DW/SO%3A+Impacts+and+Interfaces

U-UI
~~~~

Usecase-UI (UUI) has added CSMF and NSMF portal components to ONAP to
support this use case.

CSMF component includes the functions of creating network slicing, as
well as displaying and processing all the created network slices. The
customers need to fill the create communication service form to create a
network slice and then they can see the created network slice in the
list and execute operations of activating, deactivating or terminating
the network slice.

NSMF component mainly includes two modules: slicing task management and
slice resource management which provides the functions of displaying and
processing all the slicing tasks and slice resources. In slicing task
management module, network operators can find all the slicing tasks
created by customers in CSMF component and executing proper operations
according to different task status. In slice resource management module,
there are three sub-modules which provide the functions of displaying
and processing the existing NS, NSI and NSSI. In addition, the NSMF
component provides the monitoring function so that users can check the
statistics of network slices. In this page, the statistics of slice
usage (traffic), online users and total bandwidth can be monitored and
displayed in the form of pi-charts and lines.

Further details can be obtained from:
https://wiki.onap.org/display/DW/UUI%3A+Impacts

OOF
~~~

For this use case OOF introduced two APIs which are used by SO, one for
slice template selection, and another for NSI/NSSI selection. Within
OOF, both the OSDF and HAS sub-components were enhanced for this use
case. OSDF maps the new API request contents to the appropriate format
for HAS to perform the optimization. After the optimization is done by
HAS, OSDF maps the response in the API response format as expected by
SO. Further, HAS always returns NSSI info (when existing NSSIs can be
reused) and OSDF then determines whether it refers to reuse of an
existing NSI or creation of a new NSI, and then prepares sends the
response to SO.

HAS sub-component of OOF has been enhanced to use a couple of new policy
types, the AAI plug-in within HAS was enhanced to fetch the slice and
slice sub-net related details from AAI. Two new plug-ins were developed
in HAS – one for fetching slice templates and another for generating
slice profile candidates. Existing policies were reused and suitably
adapted for constraints and optimal selection of slice template and
slice instance. In case of new NSSI creation, HAS returns appropriate
slice profile for the sub-net for which a new NSSI has to be created.

Further details can be obtained from:
https://wiki.onap.org/display/DW/OOF%3A+Impacts+and+Interfaces

EXT-API
~~~~~~~

The EXT-API has undergone some minimal enhancements for this use case in
Frankfurt release. A new value “CST” for the serviceType attribute in
the Service Order API has been introduced.

The CSMF Portal in UUI captures the values for the requested
serviceCharacteristics that are required as inputs to CST Service model.
The relatedParty attribute in the Service Order is set according to the
Customer, where relatedParty.id will map to the AAI "global-customer-id“
in the “customer” object. The serviceSpecification.id is to be set to
the UUID of the CST from SDC (i.e., this is the template for the Service
we are ordering from CSMF). The action field will be set to “add” to
indicate creation of a new service instance. CSMF Portal in UUI then
sends POST with the JSON body to /{api_url}/nbi/api/v4/serviceOrder/.
ExtAPI will generate a Service Order ID and send it in the response –
this ID can be used to track the order. ExtAPI will then invoke SO’s API
for creating the service.

As can be seen from above explanation, the existing constructs of ExtAPI
has been reused with minor enhancements.

Further details can be obtained from:
https://wiki.onap.org/display/DW/ExtAPI%3A+Impacts+and+Interfaces

A&AI
~~~~

To support this use case，A&AI module has added 3 new nodes
(Communication-service-profile, Service-profile and
Slice-profile)，modified service-instance nodes, added 3 new nodes as
new attributes of service-instance node. To map to SDC templates
(Communication Service Template/Service Profile
Template/NST/NSST)，run-time instances of this use case have
Communication Service Instance/Service Profile Instance/NSI/NSSI. To
align with ONAP’s model-driven approach, this use case reuses
"service-instance" for all run-time instances. The relationship between
service-instances use the existing attribute "relationship-list" or
"allotted-resources". Communication-service-profile means the original
requirement of Communication-service-instance, such as latency,
data-rate, mobility-level and so on. Service-profile means the slice
parameter info of Service-profile-instance. Slice-profile holds the
slice sub-net parameter info of different network domain NSSIs, such as
(Radio) Access Network (AN), Transport Network (TN) and Core Network
(CN) NSSI.

A&AI provides query APIs to CSMF and NSMF, such as:

-  Query
   Communication-service-instances/Service-profile-instances/NSI/NSSI

-  Query Service-profile-instance by specified
   Communication-service-instance

-  Query NSI by specified Service-profile-instance, query NSSI by
   specified NSSI.

A&AI also supply creation APIs to SO, such as:

-  Create Communication-service-profile/Service-profile/Slice-profile,
   and

-  Create relationship between service-instances.

Further details can be obtained from:
https://wiki.onap.org/pages/viewpage.action?pageId=76875989


Functional Test Cases
---------------------

The functional testing of this use case shall cover creation and
activation of a service with an E2E Network Slice Instance which
contains a Core Slice Sub-net instance. It also addresses the
termination of an E2E Network Slice Instance. It covers the following
aspects:

-  Creation of a new customer service via CSMF portal in UUI resulting
   in creation of a new NSI

-  Creation of a new customer service via CSMF portal in UUI resulting
   in re-use of an existing NSI

-  Activation of a customer service via CSMF portal in UUI

-  Creation of a new customer service via postman request to EXT-API
   resulting in creation of a new NSI

-  Creation of a new customer service via via postman request to ExtAPI
   resulting in re-use of an existing NSI

-  Manual intervention via NSMF portal during NSI selection (NSI
   selection adjustment)

-  Termination of a NSI and associated NSSI

-  Interaction between ONAP and external NSSMF for new core NSSI
   creation

-  Checking inventory updates in AAI for NSIs, service and slice
   profiles and NSSIs.

Further details can be obtained from:
https://wiki.onap.org/display/DW/Functional+Test+Cases


How to install 5G E2E Slicing Minimum Scope
-------------------------------------------

For 5G E2E Slicing use case, we support the minimum-scope installation
of ONAP to reduce the resource requirements. From the module
perspective, 5G E2E Slicing use case involves SDC, SO, A&AI, UUI,
EXT-API, OOF and Policy modules of ONAP. So we will configure these
required modules along with the mandatory common modules such as DMaaP.
Further, for each module, the use case also does not use all of the
charts，so we removed the not needed Charts under those modules to
optimize the resources required for setting up the use case. This
approach will help to install a minimum-scope version ONAP for 5G E2E
Slicing use case.

Further details of the installation steps are available at:
https://wiki.onap.org/display/DW/Install+Minimum+Scope+ONAP+for+5G+Network+Slicing
