.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_5G_NRM_Configuration:

5G NRM (Network Resource Model) Configuration
---------------------------------------------

Description
~~~~~~~~~~~
Network Resource Management (NRM) configuration management allows service providers to control and monitor the actual configuration on the Network Resources, which are the fundamental resources to the mobility networks. Considering the huge number of existing information object classes (IOC) and increasing IOCs in various domains, this use case is to handle the NRM configuration management in a dynamic manner. Moreover, it uses the http-based restful solution in R6 and other solutions may be possible.

Useful Links
============
`5G NRM Configuration in R6 Wiki Page <https://wiki.onap.org/display/DW/5G+Network+Resource+Model+%28NRM%29+Configuration+in+R6+Frankfurt>`_
`3GPP TS 28541 <https://www.3gpp.org/DynaReport/28541.htm>`_

Current Status in Frankfurt
~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Provide a restful-executor in CDS blueprint processor.
* Provide a simplified generic provisioning management service provider for simulating an external service (may be deployed in EMS or deployed standalone) for integration test.

How to Use
~~~~~~~~~~
The pre-conditions are:
* CDS containers are ready to use.
* The external provisioning management service provider (could be a simulator) is ready to use.
* At design time, CDS controller blueprint provided by xNF vendors is designed and ready for CDS.
* Service instantiation is completed. It means users of ONAP could know the xNF instance. For this use case in R6, one PNF instance is selected.

At run time, NRM configuration management is triggered when the operator provides the selected PNF instance, expected managed object instances. Then the procedure is executed in CDS:
a. CDS sends request(s) with action-identifier{actionName, blueprintName, blueprintVersion} to the blueprint processor inside the controller using CDS self-service API.
b. Controller/blueprint processor use the corresponding executor (and blueprint scripts) and send http requests to the external provisioning management service provider.
c. The external provisioning management service provider is responsible of configuration management and sends responses to CDS.

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
To see information on the status of the test cases, please follow the link below:

`5G NRM Configuration Test Status <https://wiki.onap.org/display/DW/5G+Network+Resource+Model+%28NRM%29+Configuration+in+R6+Frankfurt#id-5GNetworkResourceModel(NRM)ConfigurationinR6Frankfurt-TestStatus>`_

