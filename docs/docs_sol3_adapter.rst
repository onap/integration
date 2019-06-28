.. docs_sol3_adapter:

VNFM adapter in SO (support ETSI SOL003 interface)
--------------------------------------------------------------

Overview
========
In ONAP Dublin release service orchestrator(SO) project is leveraged to support ETSI standards for VNF LCM as an adapter.
This functional feature provides capability to 

* Build SO VNFM Adapter
* Use SOL003 APIs (2.5.1) for VNF LCM
* Support operations such as create, instantiate, terminate and delete including granting, subscription and notification
* Enhance So BPMN workflows and recipes
* ETSI VNF-level Building Block workflows, leveraging the new VNFM Adapter
* Passing VNF LCM requests to VNFMs using the new VNFM Adapter
 

Requirements
============

Following are the details of the implementations:

* ONAPARC-310: SO Adapter which uses SOL003 to connect S/G VNFM
* ONAPARC-315: ONAP interfaces with an external VNF Manager using ETSI NFV SOL003
* ONAPARC-390: ONAP tracking of VNF dependency on an external ETSI compliant VNF Manager (VNFM)
* SO-1508: ETSI Alignment – SO SOL003 plugin support to connect to external VNFMs
    * Leverage ETSI standards for VNF LCM
    * Generic VNFm Adapter, supporting SOL003-compliant SVNFMs
    * Support SOL003 APIs for VNF LCM
        * Create/Instantiate/Terminate/Delete (including Granting/Subscription/Notification) in Dublin
        * More APIs to support in El Alto and Frankfurt


Further Reading
================

For more architecture and design details: https://wiki.onap.org/pages/viewpage.action?pageId=48529911