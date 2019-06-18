.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0
   
.. _docs_5G_oof_pci:

OOF-PCI
--------

Description
~~~~~~~~~~~
The 5G OOF-PCI use case is an implementation of a SON (Self-Organizing Networks) algorithm for Physical Cell ID (PCI) optimization and the centralized Automatic Neighbor Relations (ANR) function (blacklisting a neighbor for handovers) in a 4G/5G network using the ONAP Optimization Framework (OOF). This use case began with just PCI optimization use case in Casablanca. Further details of Casablanca scope and impacts are described in https://docs.onap.org/en/casablanca/submodules/integration.git/docs/docs_5G_oof_pci.html#docs-5g-oof-pci

For Dublin release, the earlier PCI-Handler MS which was a standalone MS is renamed as SON-Handler MS and onboarded as a micro-service in DCAE. Enhancements were made to Policy and SDN-C. The Config DB functionality (containing configuration details of the RAN), and some of the additions/fixes done to SDN-C are not part of the official Dublin release functionality, but are part of the full use case are only a Proof Of Concept (POC). These code changes in SDN-C are targeted for submission in El Alto release.

In addition, the POC also has a RAN Simulator providing a simulated Radio Access Network (RAN) with a number of netconf servers simulating PNF elements. The functionality of the RAN Simulator has also been enhanced from the Casablanca use case to (a) generate alarms for PCI collision/confusion and (b) generate handover metrics for the different neighbor pairs (for the ANR use case). 

All details regarding the use case for Dublin can be found here:
https://wiki.onap.org/display/DW/OOF-PCI+Use+Case+-+Dublin+Release+-+ONAP+based+SON+for+PCI+and+ANR

The main use case page is https://wiki.onap.org/display/DW/5G+-+OOF+%28ONAP+Optimization+Framework%29+and+PCI+%28Physical+Cell+ID%29+Optimization


How to Use
~~~~~~~~~~
The OOF-PCI use case is implemented in the Rutgers University (Winlab) ONAP Wireless Lab (OWL). For details, please see: https://wiki.onap.org/pages/viewpage.action?pageId=45298557 .
This page includes instructions for access to the lab. Since this is a POC at this stage, testing is done manually. 

For all instructions about installing the components and test plans, please see:

https://wiki.onap.org/display/DW/Installation+Aspects
Son-handler installation -  https://onap.readthedocs.io/en/latest/submodules/dcaegen2.git/docs/sections/services/son-handler/installation.html



Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
For Dublin release, the OOF-PCI use case is a Proof of Concept (POC). OOF was enhanced with joint PCI-ANR optimization, SON-Handler MS was functionally enhanced and also onboarded on to DCAE, and Policy was also enhanced with a new control loop for ANR and control loop extension to receive feedback of actions. The pairwise testing was done in Windriver lab (https://wiki.onap.org/display/DW/Integration+Testing). Other non-release functions are all tested as part of the PoC in the Rutgers University (Winlab) ONAP Wireless Lab (OWL). To see information about test plans, please see https://wiki.onap.org/display/DW/Functional+Testing and https://wiki.onap.org/display/DW/Use+case+testing.


Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(a) 2 known issues (Medium): CCSDK-1399 and CCSDK-1400
(b) It is intended to have the RAN Simulator support sufficient Honeycomb netconf server instances to simulate 2000 cells. However, this number may be lower if there are hardware limitatons.
