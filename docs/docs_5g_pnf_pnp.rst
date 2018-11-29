5G - PNF Plug and Play
----------------------

Source files
~~~~~~~~~~~~

- Base PnP PNF Simulator heat template file: https://git.onap.org/integration/tree/test/mocks/pnfsimulator/deployment/PnP_PNF_sim_heat_template_Ubuntu_16_04.yml

Description
~~~~~~~~~~~

The PNF PnP flow is a method, which allows to register within ONAP/AAI a PNF resource instance.
This PNF resource instance is correlated with an existing service instance.
PNF Plug and Play is used to register a PNF when it comes on-line.
This use case is intended to be applicable to a variety of PNFs such as routers and 5G base stations.
The steps and descriptions have been drafted to be as general as possible and to be applicable
to a relatively wide variety of PNFs. However, the use case was originally developed with a consideration
for 5G PNF Distributed Units (DU).

**Useful Links**

- `5G - PNF Plug and Play use case documentation <https://wiki.onap.org/display/DW/5G+-+PNF+Plug+and+Play>`_
- `5G - PNF Plug and Play - Integration Test Cases <https://wiki.onap.org/display/DW/5G+-+PNF+PnP+-+Integration+Test+Cases>`_
- `5G - PNF Plug and Play test cases status for Casablanca release <https://wiki.onap.org/display/DW/5G+-+PNF+PnP+-+Test+Status>`_
- `Instruction how to setup PnP PNF Simulator <https://wiki.onap.org/display/DW/PnP+PNF+Simulator>`_

How to Use
~~~~~~~~~~

1) `Create and distribute service model which contains PNF <https://wiki.onap.org/display/DW/5G+-+PNF+PnP+-+Integration+Test+Cases#id-5G-PNFPnP-IntegrationTestCases-CreateanddistributeservicewhichcontainsPNF>`_
2) `Create service for PNF and wait for PNF Ready message in DmaaP topic <https://wiki.onap.org/display/DW/5G+-+PNF+PnP+-+Integration+Test+Cases#id-5G-PNFPnP-IntegrationTestCases-PNFReady>`_
3) `Send PNF Registartion request from PnP PNF Simualtor and finish registration <https://wiki.onap.org/display/DW/5G+-+PNF+PnP+-+Integration+Test+Cases#id-5G-PNFPnP-IntegrationTestCases-PNFregistrationacceptingwhenAAIentrycreatedinadvance>`_


Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In SO BPMN in mechanism making re-subscription to /events/unauthenticated.PNF_READY topic there is an issue `SO-1253 <https://jira.onap.org/projects/SO/issues/SO-1253>`_.
By default after ONAP and PRH deploy DMaaP topic /events/unauthenticated.PNF_READY is not present.
It is created by PRH after first expected PNF registration event arrival to ONAP system.
If service for PNF will be created before topic /events/unauthenticated.PNF_READY will be present then service will not be able to read from the topic.


**Workaround**

- Before starting any PNF service verify if unauthenticated.PNF_READY topic exists using command:

::

   curl --header "Content-type: application/json" --request GET http://<kubernetes slave IP>:30227/topics/listAll

- If it doesn't exists send following curl in order to create topic:

::

   curl --header "Content-type: application/json" --request POST --data '[{"correlationId": "test"}]' http://<kubernetes slave IP>:30227/events/unauthenticated.PNF_READY

- Once again verify if topic exists
- If the PNF service will be started before unauthenticated.PNF_READY topic creation, then there will be a need to restart SO-BPMN docker container


