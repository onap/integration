.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_5G_oof_son:

:orphan:

OOF-SON
--------

Description
~~~~~~~~~~~

The 5G OOF-SON (earlier name was OOF-PCI) use case is an implementation of a **SON (Self-Organizing Networks)** algorithm for Physical Cell ID (PCI) optimization and the centralized Automatic Neighbor Relations (ANR) function (blacklisting a neighbor for handovers) in a 4G/5G network using the ONAP Optimization Framework (OOF).

The use case is a multi-releases effort initiated in Casablanca release. This use case began with the implementation of PCI optimization in Casablanca. In Dublin release, the SON-Handler MS was onboarded as a micro-service in DCAE. Enhancements were made to Policy and SDN-C components.

In Frankfurt release, the following were the main enhancements:

- Introduction of Control Loop Coordination functionality, wherein a second control loop execution is denied by Policy component when another control loop is in progress.
- Introduction of adaptive SON, wherein a set of cells whose PCI values are fixed (i.e., cannot be changed during PCI optimization) are considered during the PCI optimization.
- In addition, the first step towards O-RAN alignment is being taken with SDN-C (R) being able to receive a DMaaP message containing configuration updates (which would be triggered when a neighbor-list-change occurs in the RAN and is communicated to ONAP over VES). `Details of this implementation <https://wiki.onap.org/display/DW/CM+Notification+Support+in+ONAP>`_


In the Istanbul release, the following are the main enhancements:

- Updates in FM reporting and fault handling to be in line with VES 7.2, 3GPP and smoother future alignment with O-RAN O1
- Alignment with 3GPP NRM/O-RAN yang models for SON use case
- Use CPS for storing/retrieving RAN config data for this use case (was stretch goal, partially addressed)
- Configuration Management (CM) notifications over VES based on VES 7.2 (was stretch goal, partially addressed)



The end-to-end setup for the use case requires a database which stores the cell related details of the RAN. This database is ConfigDB till we complete the transition to using CPS DB/TBDMT. The database is updated by SDN-C (R), and is accessed by SON-Handler MS and OOF for fetching (e.g., neighbor list, PNF id, etc):

- `The Config DB implementation <https://github.com/onap-oof-pci-poc/sdnc/tree/master/ConfigDB/Dublin>`_
- `Swagger JSON API documentation <https://github.com/onap-oof-pci-poc/sdnc/blob/master/ConfigDB/Dublin/SDNC_ConfigDB_API_v3.0.0.json>`_

As part of Istanbul release work, progress was made towards the goal of transitioning from ConfigDB to CPS DB. CPS DB is fully based on yang models, and we have developed a modeling approach using two yang models:

- Primary model: (e.g., ran-network). This is a modular sub-set of, and fully aligned with, ORAN/3GPP 28.541 NRM yang model. This aligns with device models and vendor models (base and extensions)

- Secondary model: (e.g, cps-ran-schema-model) This model captures information which is not present in ORAN model, e.g., region-to-cell (CU) mapping, latitude/longitude of DU. This also has derived information for API/query efficiency, e.g., list of neighbor cells. This aligns with operator network model for use cases and applications.

As part of this use case work, a RAN Simulator providing a simulated Radio Access Network
(RAN) with a number of netconf servers simulating PNF elements has been implemented. The
functionality of the RAN Simulator includes:

- Generation of neighbor-list-update messages
- Generation of alarms for PCI collision/confusion and
- Generation of handover metrics for different neighbor pairs (for the ANR use case).

All above functionality are enabled using a simple UI.

Please see also `OOF (SON) wiki page <https://wiki.onap.org/display/DW/5G+-+OOF+%28ONAP+Optimization+Framework%29+and+PCI+%28Physical+Cell+ID%29+Optimization>`_.
Additional information are available related to previous releases can be found
in `El Alto & Frankfurt OOF (SON) wiki page <https://wiki.onap.org/display/DW/OOF+%28SON%29+in+R5+El+Alto%2C+OOF+%28SON%29+in+R6+Frankfurt>`_.

How to Use
~~~~~~~~~~

The OOF-PCI use case is implemented in the Rutgers University (Winlab) ONAP Wireless Lab (OWL).
For details, please see
`lab details <https://wiki.onap.org/pages/viewpage.action?pageId=45298557>`_.

This page includes instructions for access to the lab. Setup and testing is done manually up to now.

For all instructions about installing the components, please see:

- `Wiki Installation page <https://wiki.onap.org/display/DW/Demo+setup+steps+for+Frankfurt>`_
- `Son-Handler installation <https://docs.onap.org/projects/onap-dcaegen2/en/frankfurt/sections/services/son-handler/installation.html?highlight=dcaegen2>`_

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~

OOF was enhanced with handling cells with fixed PCI values during the optimization,
SON-Handler MS was functionally enhanced for adaptive SON functionality, SDN-C (R)
was enhanced to include handling of DMaaP message for config changes in the RAN,
and Policy was also enhanced with Control Loop Co-ordination function.

See `test plans <https://wiki.onap.org/display/DW/Testing>`_ for details.

Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(a) It is intended to have the RAN Simulator support sufficient Honeycomb netconf server instances to simulate 2000 cells.
    However, this number may be lower if there are hardware limitations.
(b) For Control Loop Co-ordination, the denial of a second Control Loop based on Target Lock (i.e., when a second Control
    Loop tries to operate on the same target (in this case, a PNF) is successfully tested. The CLC is also applied at Control
    Loop level only. However, some code updates are required in Policy to properly update the Operations History DB entry, and
    to check the existence of active Control Loops by Policy. This will be addressed in Jakarta release, and tracked via
    https://jira.onap.org/browse/POLICY-2484