.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0
   
.. _docs_5G_oof_pci:

OOF-PCI
--------

Description
~~~~~~~~~~~
The 5G OOF-PCI use case is an implementation of a SON (Self-Organizing Networks) algorithm for Physical Cell ID (PCI) optimization in a 4G/5G network using the ONAP Optimization Framework (OOF). For Casablanca release, there are enhancements for OOF, and all the other aspects of the full use case are only a Proof Of Concept (POC). 

As part of non-release impacting functionality, there are code additions in Policy and SDN-C. There is a new stand-alone PCI Handler microservice. These are all targeted for submission to Dublin release. In addition, the POC also has a RAN Simulator providing a simulated Radio Access Network (RAN) with a number of netconf servers simulating PNF elements. 

All details regarding the use case can be found here: 
https://wiki.onap.org/display/DW/5G+-+OOF+%28ONAP+Optimization+Framework%29+and+PCI+%28Physical+Cell+ID%29+Optimization 

How to Use
~~~~~~~~~~
The OOF-PCI use case is implemented in the Rutgers University (Winlab) ONAP Wireless Lab (OWL). For details, please see: https://wiki.onap.org/pages/viewpage.action?pageId=45298557 .
This page includes instructions for access to the lab. Since this is a POC at this stage, testing is done manually. 

For all instructions about installing the components and test plans, please see the main use case page:
https://wiki.onap.org/display/DW/5G+-+OOF+%28ONAP+Optimization+Framework%29+and+PCI+%28Physical+Cell+ID%29+Optimization 


Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
For Casablanca release, the OOF-PCI use case is only a Proof of Concept (POC). OOF was enhanced with a PCI interface & Solver, and pairwise testing with ConfigDB API was done in Windriver lab. Other non-release functions are all tested as part of the PoC in the Rutgers University (Winlab) ONAP Wireless Lab (OWL). To see information about test plans, please see https://wiki.onap.org/display/DW/POC+Test+aspects


Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Due to server capacity limit, the RAN Simulator is currently limited to 27 Honeycomb netconf server instances and 350 cells. The plan is to install more server capacity to test up to 2000 cells.
