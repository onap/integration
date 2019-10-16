.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0
   
.. _docs_5g_pnf_pnp:

5G - PNF Plug and Play
----------------------

Source files
~~~~~~~~~~~~

- Base PnP PNF Simulator heat template file: https://gerrit.onap.org/r/gitweb?p=integration.git;a=tree;f=test/mocks/pnfsimulator/deployment/src

Description
~~~~~~~~~~~

The PNF Plug and Play is a procedure that is executed between a PNF and ONAP. In the process of PNF registration, ONAP establishes a PNF resource instance for the PNF with a corresponding A&AI entry. The PNF registration uses a VES exchange with the PNF Registration handler within ONAP to complete the registration. Allowing the PNF resource instance to be associated with an existing service instance. This use case is intended to be applicable to a variety of PNFs such as routers and 5G base stations. The steps and descriptions have been drafted to be as general as possible and to be applicable to a relatively wide variety of PNFs. However, the use case was originally developed with a consideration for 5G PNF Distributed Units (DU).

**Useful Links**

- `5G - PNF Plug and Play use case documentation <https://wiki.onap.org/display/DW/5G+-+PNF+Plug+and+Play>`_
- `5G - PNF Plug and Play - Integration Test Cases <https://wiki.onap.org/display/DW/5G+-+PNF+PnP+-+Integration+Test+Cases>`_
- `Instruction how to setup PnP PNF Simulator <https://wiki.onap.org/display/DW/PnP+PNF+Simulator>`_
- `Instruction how to use PnP PNF Simulator <https://gerrit.onap.org/r/gitweb?p=integration.git;a=blob_plain;f=test/mocks/pnfsimulator/pnfsimulator/README.md>`_

How to Use
~~~~~~~~~~

1) `Create and distribute service model which contains PNF <https://wiki.onap.org/display/DW/5G+-+PNF+PnP+-+Integration+Test+Cases#id-5G-PNFPnP-IntegrationTestCases-CreateanddistributeservicewhichcontainsPNF>`_
2) `Create service for PNF and wait for PNF Ready message in DmaaP topic <https://wiki.onap.org/display/DW/5G+-+PNF+PnP+-+Integration+Test+Cases#id-5G-PNFPnP-IntegrationTestCases-PNFReady>`_
3) `Send PNF Registartion request from PnP PNF Simualtor and finish registration <https://wiki.onap.org/display/DW/5G+-+PNF+PnP+-+Integration+Test+Cases#id-5G-PNFPnP-IntegrationTestCases-PNFregistrationacceptingwhenAAIentrycreatedinadvance>`_



