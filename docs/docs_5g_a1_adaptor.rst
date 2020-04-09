.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_5g_a1_adaptor:

5G - A1 Adaptor
---------------

Description
~~~~~~~~~~~

A1 is an O-RAN defined interface between Non-Real Time RIC (Ran Intelligent Controller) in the management platform (ONAP) and RAN network element called Near-Real Time RIC.
A1 interface is used to communicate policy choices, AI/ML model updates, and other RAN functions that are not included in the traditional network configuration.
O-RAN defines architecture of RT RIC and relevant interfaces.
O-RAN WG2 has released the first version of A1 specifications September 2019.
ONAP needed to implement a module serving a communication channel between other ONAP components and RT RIC for A1 interface.
ONAP community has a harmonization project with mobility standard and A1 adaptor has been proposed in the project (https://wiki.onap.org/display/DW/MOBILITY+STANDARDS+HARMONIZATION+WITH+ONAP).
A1 adaptor has been implemented as a component in CCSDK. All implementation details are explained here: https://wiki.onap.org/display/DW/A1+Adapter+in+ONAP

How to Use
~~~~~~~~~~

Following steps describe a general procedure about how to use A1 adaptor.

1. ONAP Frankfurt includes A1 adaptor.

2. Edit A1 adaptor property file in sdnc container at dev-sdnc-x POD. (dev is an example of release name and x is replica number)

   a. A property file is located at /opt/onap/ccsdk/data/properties/a1-adapter-api-dg.properties.

   b. SSH into a rancher node (NFS/rancher).

   c. sudo su

   d. kubectl get pods -n onap -o wide | grep sdnc

   e. execute the following command to all sdnc PODs to update properties files.

      - kubectl exec -it dev-sdnc-x bash (x=0,1,2, depending on number of sdnc replicas in the setup)

   f. Once in the docker, edit the properties file.

   g. Make following configuration changes per setup

      - Update IP address and port number for Near-Real Time RIC as below

      - near-rt-ric-id=a.b.c.d:port

A1 adaptor has been tested with A1 mediator as an example of Near-Real Time RIC. Detailed information can be found at its repo: https://gerrit.o-ran-sc.org/r/gitweb?p=ric-plt%2Fric-dep.git;a=shortlog;h=refs%2Fheads%2Fmaster.

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~

For ONAP Frankfurt, A1 adaptor has not been involved in a full closed loop use case. A1 adaptor has gone through a unit test with A1 mediator in OSC as a underlying device. It has been tested for receiving A1 policy via DMaaP and publishing a response back to DMaaP as well as notification. More details are presented in https://wiki.onap.org/pages/viewpage.action?pageId=71837463.
