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
The 5G OOF-PCI use case is an implementation of a SON (Self-Organizing Networks) algorithm for Physical Cell ID (PCI) optimization and the centralized Automatic Neighbor Relations (ANR) function (blacklisting a neighbor for handovers) in a 4G/5G network using the ONAP Optimization Framework (OOF). This use case began with the implementation of PCI optimization in Casablanca. In Dublin release, the SON-Handler MS was onboarded as a micro-service in DCAE. Enhancements were made to Policy and SDN-C components. Further details of Dublin release scope and impacts for this use case are described in https://docs.onap.org/en/dublin/submodules/integration.git/docs/docs_5G_oof_pci.html#docs-5g-oof-pci

In Frankfurt release, the following are the main enhancements:

- Introduction of Control Loop Coordination functionality, wherein a second control loop execution is denied by Policy component when another control loop is in progress.

- Introduction of adaptive SON, wherein a set of cells whose PCI values are fixed (i.e., cannot be changed during PCI optimization) are considered during the PCI optimization. Such situations may arise for example, when Policy specifies that certain cells' PCI values cannot be changed, a netconf server (acting as DU) is not reachable hence PCI updates to the cells connected to it cannot be communicated, etc.

- In addition, the first step towards O-RAN alignment is being taken with SDN-C (R) being able to receive a DMaaP message containing configuration updates (which would be triggered when a neighbor-list-change occurs in the RAN and is communicated to ONAP over VES).

As part of this use case work, a RAN Simulator providing a simulated Radio Access Network (RAN) with a number of netconf servers simulating PNF elements has been implemented. The functionality of the RAN Simulator includes (a) generation of neighbor-list-update messages (b) generate alarms for PCI collision/confusion and (c) generate handover metrics for the different neighbor pairs (for the ANR use case). 

All details regarding the use case for Frankfurt can be found here:
https://wiki.onap.org/display/DW/OOF+%28SON%29+in+R5+El+Alto%2C+OOF+%28SON%29+in+R6+Frankfurt

The main use case page is https://wiki.onap.org/display/DW/5G+-+OOF+%28ONAP+Optimization+Framework%29+and+PCI+%28Physical+Cell+ID%29+Optimization


How to Use
~~~~~~~~~~
The OOF-PCI use case is implemented in the Rutgers University (Winlab) ONAP Wireless Lab (OWL). For details, please see: https://wiki.onap.org/pages/viewpage.action?pageId=45298557 .
This page includes instructions for access to the lab. Setup and testing is done manually up to now. 

For all instructions about installing the components, please see:

Installation - https://wiki.onap.org/display/DW/Demo+setup+steps

Son-handler installation -  https://onap.readthedocs.io/en/latest/submodules/dcaegen2.git/docs/sections/services/son-handler/installation.html


Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
For Frankfurt release, the enhancements described above were implemented. OOF was enhanced with handling cells with fixed PCI values during the optimization, SON-Handler MS was functionally enhanced for adaptive SON functionality, SDN-C (R) was enhanced to include handling of DMaaP message for config changes in the RAN, and Policy was also enhanced with Control Loop Co-ordination function. To see information about test plans, please see https://wiki.onap.org/display/DW/Testing.


Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(a) It is intended to have the RAN Simulator support sufficient Honeycomb netconf server instances to simulate 2000 cells. However, this number may be lower if there are hardware limitatons.
