.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0
   
.. _docs_5g_a1_adaptor:

5G - A1 Adaptor
----------------------

Description
~~~~~~~~~~~

A1 is an O-RAN defined interface between Non-Real Time RIC (Ran Intelligent Controller) in the management platform (ONAP) and RAN network element called Near-Real Time RIC. A1 interface is used to communicate policy choices, AI/ML model updates, and other RAN functions that are not included in the traditional network configuration. O-RAN defines architecture of RT RIC and relevant interfaces. O-RAN WG2 has released the first version of A1 specifications September 2019. ONAP needed to implement a module serving a communication channel between other ONAP components and RT RIC for A1 interface. ONAP community has a harmonization project with mobilty standard and A1 adaptor has been proposed in the project (https://wiki.onap.org/display/DW/MOBILITY+STANDARDS+HARMONIZATION+WITH+ONAP). A1 adaptor has been implemented as a component in CCSDK. All implementation details are explained here: https://wiki.onap.org/display/DW/A1+Adapter+in+ONAP

How to Use
~~~~~~~~~~

Following steps describe a general procedure about how to use A1 adaptor. Further details with specific commands described here: https://wiki.onap.org/display/DW/A1+Adapter+in+OAP 
1) ONAP Frankfurt includes A1 adaptor. 
2) Edit A1 adaptor property file in SDNC container.
3) Configure proper IP address and port number for Non RT RIC. (e.g. A1 mediator in OSC)


Test Status and Plans
~~~~~~~~~~

For ONAP Frankfurt, A1 adaptor has not been involved in a full closed loop use case. A1 adaptor has gone through a unit test with A1 mediator in OSC as a underlying device. It has been tested for receiving A1 policy via DMaaP and publishing a response back to DMaaP as well as notification. More details are presented in https://wiki.onap.org/pages/viewpage.action?pageId=71837463.
