.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_5G_oof_son:

:orphan:

5G-SON (earlier name was OOF-SON)
---------------------------------

Description
~~~~~~~~~~~

The 5G OOF-SON (earlier name was OOF-PCI) use case is an implementation of a **SON (Self-Organizing Networks)** algorithm for Physical Cell ID (PCI) optimization and the centralized Automatic Neighbor Relations (ANR) function (blacklisting a neighbor for handovers) in a 4G/5G network using the ONAP Optimization Framework (OOF).

The use case is a multi-release effort. This use case began with the implementation of PCI optimization in the Casablanca release. In the Dublin release, the SON-Handler MS was onboarded as a micro-service in DCAE. Enhancements were made to Policy and SDN-C components.


RAN Simulator
~~~~~~~~~~~~~

As part of this use case work, the SON Use Case team developed RAN-Sim, which is a RAN Simulator providing a simulated Radio Access Network (RAN) with a number of netconf servers simulating PNF elements representing gNodeBs. The functionality of the RAN Simulator includes:

- Input of a sample topology of cells, with netconf servers (representing DUs) representing groups of cells
- Represenation of cell locations and cell neighbor relations
- Generation of neighbor-list-update messages
- Generation of alarms for PCI collision/confusion and
- Generation of handover metrics for different neighbor pairs (for the ANR use case).
- Implementation of an O1 interface termination for CU/DU NFs
- Implementation of an A1 interface termination with A1-Termination and RAN-App (new for Kohn release)

All above functionality are enabled using a simple UI.


Frankfurt Release
~~~~~~~~~~~~~~~~~

In Frankfurt release, the following were the main enhancements:

- Introduction of Control Loop Coordination functionality, wherein a second control loop execution is denied by Policy component when another control loop is in progress.
- Introduction of adaptive SON, wherein a set of cells whose PCI values are fixed (i.e., cannot be changed during PCI optimization) are considered during the PCI optimization.
- In addition, the first step towards O-RAN alignment is being taken with SDN-C (R) being able to receive a DMaaP message containing configuration updates (which would be triggered when a neighbor-list-change occurs in the RAN and is communicated to ONAP over VES). `Details of this implementation <https://wiki.onap.org/display/DW/CM+Notification+Support+in+ONAP>`_


Istanbul Release
~~~~~~~~~~~~~~~~~

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


Jakarta Release
~~~~~~~~~~~~~~~

The following are the enhancements in the Jakarta release:

- Update of SDN-R netconf code to use the new O1 yang models
- Update of RAN-Sim to use the new O1 yang models

In the Jakarta release, the SON Use Case work was impacted by the fact RAN-Sim needed enhancements to implement new features. We have made progress in the following areas in planning for future releases.

- Convergence on the VES message formats to be used for FM/PM/CM
- Inclusion of A1 based actions for the end-to-end SON Use Case
- Enhancement of RAN-Sim to include abstraction of RAN App and A1 Termination which would process an A1 message and update of a CU/DU
- Planning for replacement of Honeycomb netconf engine (project is archived)

Kohn Release
~~~~~~~~~~~~

We have introduced a new paradigm in the Kohn release and taken steps to harmonize with O-RAN SC and new approaches for ONAP Control Loops. The following are the enhancements in the Kohn release:

- We introduced a new paradigm of marking the RAN action SON control flows as being O1-based or A1-based. The PCI control flow is now an O1-based flow which goes to SDN-R for netconf-based configurations over O1 interface to the CU/DU (simulated in RAN-Sim). The ANR control flow is now an A1-based flow which goes to SDN-R/A1-PMS to generate A1 Policy messages over the A1 interface to the xApp/Near-RT RIC (simulated in RAN-Sim).
- The formats of the Control Loop Message between SON Handler MS, Policy, and SDN-R have been updated. Policies in Policy Function have been updated. The PCI flow remains as an O1-based netconf action from SDN-R, while major changes were made for the ANR flow
- We have introduce a new A1-based SON action flow leveraging the use of A1-PMS in SDN-R and A1-Termination in RAN-Sim. We have harmonized ONAP and O-RAN SC work, and cross-linked ONAP JIRAs to use O-RAN SC projects.
- We have major changes for RAN-Sim. There is a new A1-Termination module as well as a new RAN-App module. The RAN-App module abstracts the function of an xApp in the Near-RT RIC. RAN-App processes the A1 policy message payload and sends a message to the RAN-Sim controller to make configuration changes in the RAN NF (CU or DU) in the RAN-Sim.


London Release
~~~~~~~~~~~~~~~
For the London release, we have converged on an architecture and workflow for generating and processing CM VES messages from the simulated RAN NFs, and updating the network configuration in the ONAP CPS DB which maintains a consistent copy of the network configuration. The solution is aligned with 3GPP/O-RAN and reusable for configuration management of other NFs using a yang-based configuration model.The following are the enhancements in the London release:
- Define a CM Notification VES format aligned with the latest consensus in O-RAN, OSC, 3GPP
  (e.g. O1 spec v08.00, 3GPP Rel 18 see OpenAPI/TS28532_ProvMnS.yaml · Rel-18 · SA5 – Management & Orchestration and Charging / Management and Orchestration APIs · GitLab (3gpp.org))
- Define an efficient, model-driven path to identify the MOI and attribute whose value has been changed (e.g. use notifyMOIAttributeValueChanges or notifyMOIChanges as appropriate)
- Configuration Management (CM) update notification VES messages from RAN-Sim
- Processing of CM update notifications to update CPS DB

For more information, please see:

- `5G-SON London release wiki page <https://wiki.onap.org/display/DW/R12+SON+Use+Case>`_.

- `5G-SON Kohn release wiki page <https://wiki.onap.org/pages/viewpage.action?pageId=149029149>`_.

- `5G-SON Jakarta release wiki page <https://wiki.onap.org/display/DW/R10+5G+SON+use+case>`_.

- `5G-OOF-SON Base wiki page <https://wiki.onap.org/display/DW/5G+-+OOF+%28ONAP+Optimization+Framework%29+and+PCI+%28Physical+Cell+ID%29+Optimization>`_.

- `OOF-SON El Alto & Frankfurt OOF (SON) wiki page <https://wiki.onap.org/display/DW/OOF+%28SON%29+in+R5+El+Alto%2C+OOF+%28SON%29+in+R6+Frankfurt>`_.


How to Use
~~~~~~~~~~

The 5G-SON use case is implemented in the Rutgers University (Winlab) ONAP Wireless Lab (OWL).
For details, please see
`lab details <https://wiki.onap.org/pages/viewpage.action?pageId=45298557>`_.

This page includes instructions for access to the lab. Setup and testing is done manually up to now.

For all instructions about installing the components, please see:

- `Wiki Installation page <https://wiki.onap.org/display/DW/Demo+setup+steps+for+Frankfurt>`_


Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~

See `test plans <https://wiki.onap.org/display/DW/R11+5G+SON+Integration+Tests>`_ for details.

Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(a) It is intended to have the RAN Simulator support sufficient Honeycomb netconf server instances to simulate 2000 cells. However, this number may be lower if there are hardware limitations.
(b) For Control Loop Co-ordination, the denial of a second Control Loop based on Target Lock (i.e., when a second Control Loop tries to operate on the same target (in this case, a PNF) is successfully tested. The CLC is also applied at Control Loop level only. However, some code updates are required in Policy to properly update the Operations History DB entry, and to check the existence of active Control Loops by Policy. This will be addressed in Jakarta release, and tracked via    https://jira.onap.org/browse/POLICY-2484
(c) Honeycomb netconf server project has been archived. The plan is to migrate to netopeer. As an interim step, we have a new ran-app module which interacts with the ran-sim controller.
