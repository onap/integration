.. _docs_bbs:

BBS (Broadband Service)
-----------------------

Overview
~~~~~~~~
The BBS use case proposes using ONAP for the design, provisioning, life-cycle
management and assurance of broadband services. BBS focuses on multi-Gigabit
Internet Connectivity services based on PON (Passive Optical Network) access
technology.

In Dublin release, BBS enables ONAP to

1. Establish a subscriber's HSIA (High Speed Internet Access) service
from an ONT (Optical Network Termination unit) to the Internet drain

   - The HSIA service is designed and deployed using ONAP's design and deployment
   capabilities
   - The HSIA service activation is initiated via ONAP's External APIs and
   orchestrated and controlled using ONAP orchestration and control capabilities.
   The control capabilities leverage a 3rd party controller to implement the
   requested action within the technology domain/location represented by the
   domain specific SDN management and control function.

2. Detect the change of location for ONT devices (Nomadic ONT devices)

   - PNF (Re-)Registration for an ONT

     - Subscriber association to an ONT via ONAP's External APIs
     - ONT association with a expected Access UNI (PON port) when a HSIA
     service is created/deployed for a subscriber
     - PNF (Re-)Registration using ONAP's PNF registration capabilities

   - Service location modification that is detected by ONAP's analytic and
   initiated via the closed loop capabilities

     - The closed loop capabilities invoke a HSIA location change service that
     is orchestrated and controlled using ONAP capabilities and 3rd party
     controllers

|image1|

**Figure 1. Architecture Overview**

System View
~~~~~~~~~~~
BBS relies on key ONAP components such as External API, SO, AAI, SDC, Policy
(APEX engine), DCAE (PRH, BBS Event Processor, VES collector, VES mapper,
RESTCONF collector) and SDNC

|image2|

**Figure 2. System View**

System Set Up and configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please refer to the following wiki page for detailed set up and configuration
instructions: `BBS Documentation <https://wiki.onap.org/display/DW/BBS+Documentation>`

.. |image1| image:: files/bbs/BBS_arch_overview.png
   :width: 6.5in
.. |image2| image:: files/bbs/BBS_system_view.png
   :width: 6.5in
