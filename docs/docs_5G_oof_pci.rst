.. This work is licensed under a Creative Commons Attribution 4.0

   International License. http://creativecommons.org/licenses/by/4.0


.. contents::

   :depth: 3

..


.. _docs_5G_oof_pci:





OOF-PCI

--------



Description

~~~~~~~~~~~



The 5G OOF-PCI use case is an implementation of a SON (Self-Organizing Networks) algorithm

for Physical Cell ID (PCI) optimization and the centralized Automatic Neighbor Relations

(ANR) function (blacklisting a neighbor for handovers) in a 4G/5G network using the ONAP

Optimization Framework (OOF). This use case began with the implementation of PCI

optimization in Casablanca. In Dublin release, the SON-Handler MS was onboarded as a

micro-service in DCAE. Enhancements were made to Policy and SDN-C components. Further

details of Dublin release scope and impacts for this use case are described in:



https://docs.onap.org/en/dublin/submodules/integration.git/docs/docs_5G_oof_pci.html#docs-5g-oof-pci





In Frankfurt release, the following are the main enhancements:



- Introduction of Control Loop Coordination functionality, wherein a second control loop execution is

  denied by Policy component when another control loop is in progress.

- Introduction of adaptive SON, wherein a set of cells whose PCI values are fixed (i.e., cannot be changed

  during PCI optimization) are considered during the PCI optimization.

- In addition, the first step towards O-RAN alignment is being taken with SDN-C (R) being able to receive a DMaaP

  message containing configuration updates (which would be triggered when a neighbor-list-change occurs in the RAN

  and is communicated to ONAP over VES). Details of this implementation is available at:

  https://wiki.onap.org/display/DW/CM+Notification+Support+in+ONAP



In Guilin release, the main enhancement was related to taking the first steps for enabling Machine-Learning (ML) based

SON functionality. Training is assumed to be done offline, and the ML model is then onboarded to ONAP as part

of OOF. The ML model provides additional inputs (based on the handover PM data) to the optimizer about cells

whose PCI values should not be modified during the PCI optimization process. To be able to do this, the ML model

that is part of OOF fetches historical PM data from a data base/data lake using the DES micro-service (in DCAE)

APIs. This is a new capability introduced in OOF which can be extended further for other scenarios. To be backward

compatible, the functionality in OOF to invoke the ML model for additional inputs before PCI optimization is

performed is configurable.



The end-to-end setup for the use case requires a Config DB which stores the cell related details of the RAN. This is

updated by SDN-C (R), and is accessed by SON-Handler MS and OOF for fetching, e.g., neighbor list, PNF id, etc.



The Config DB implementation is available at:



https://github.com/onap-oof-pci-poc/sdnc/tree/master/ConfigDB/Dublin.



Swagger JSON API documentation can be found at:



https://github.com/onap-oof-pci-poc/sdnc/blob/master/ConfigDB/Dublin/SDNC_ConfigDB_API_v3.0.0.json.



As part of this use case work, a RAN Simulator providing a simulated Radio Access Network (RAN) with a number of

netconf servers simulating PNF elements has been implemented. The functionality of the RAN Simulator includes:



- Generation of neighbor-list-update messages

- Generation of alarms for PCI collision/confusion and

- Generation of handover metrics for different neighbor pairs (for the ANR use case).



All above functionality are enabled using a simple UI.



All details regarding the use case for Guilin can be found here:

https://wiki.onap.org/display/DW/R7+OOF+SON+Use+Case



All details regarding the use case for Frankfurt can be found here:

https://wiki.onap.org/display/DW/OOF+%28SON%29+in+R5+El+Alto%2C+OOF+%28SON%29+in+R6+Frankfurt



The main use case page is:

https://wiki.onap.org/display/DW/5G+-+OOF+%28ONAP+Optimization+Framework%29+and+PCI+%28Physical+Cell+ID%29+Optimization




How to Use

~~~~~~~~~~



The OOF-PCI use case is set up in the Rutgers University (Winlab) ONAP Wireless Lab (OWL). For details, please see:

https://wiki.onap.org/pages/viewpage.action?pageId=45298557.


This page includes instructions for access to the lab. Setup and testing is done manually up to now.


For all instructions about installing the components, please see:


Frankfurt Installation: https://wiki.onap.org/display/DW/Demo+setup+steps+for+Frankfurt


Guilin Installation: https://wiki.onap.org/display/DW/SON+use+case+demo+setup+steps+for+Guilin


Son-Handler installation:

https://docs.onap.org/projects/onap-dcaegen2/en/frankfurt/sections/services/son-handler/installation.html?highlight=dcaegen2



Test Status and Plans

~~~~~~~~~~~~~~~~~~~~~

For Guilin release, the enhancements described above were implemented. OOF was enhanced with invoking the onboarded

ML model for additional inputs on cells with fixed PCI values during the optimization.


To see information about test plans, please see https://wiki.onap.org/display/DW/Integration+Test+for+Guilin.



Known Issues and Resolutions

~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(a) It is intended to have the RAN Simulator support sufficient Honeycomb netconf server instances to simulate 2000 cells.

    However, this number may be lower if there are hardware limitatons.

(b) For Control Loop Co-ordination, the denial of a second Control Loop based on Target Lock (i.e., when a second Control

    Loop tries to operate on the same target (in this case, a PNF) is successfully tested. The CLC is also applied at

    Control Loop level only.

(c) There are some limitations in the DES APIs with respect to supporting generic queries. These will be addressed in

    Honolulu release and beyond.
