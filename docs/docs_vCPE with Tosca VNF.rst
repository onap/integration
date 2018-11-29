.. _docs_vcpe_tosca:

vCPE with Tosca VNF
----------------------------

VNF Packages and NS Packages 
~~~~~~~~~~~~

- VNF packages: https://wiki.onap.org/display/DW/vCPE+with+Tosca+VNF+Test+Guide
- NS packages: https://wiki.onap.org/display/DW/vCPE+with+Tosca+VNF+Test+Guide

Description
~~~~~~~~~~~
The vCPE with Tosca VNF shows how to use ONAP to deploy tosca based vCPE. ONAP Casablanca release supports deployment,termination and manual heal Tosca based vCPE. User can trigger the above operation via UUI. and User can first chose Network serivce type and conrresponding service template in UUI and then UUI will directly invoke VF-C Northbound interfaces to do the life cycle management. In Casablanca release, we bypass SO, in the following release, we can add SO to the workflow. The main projects involved in this use case include: SDC, A&AI, UUI，VF-C, Multicloud，MSB, Policy，OOF.

The original vCPE Use Case Wiki Page can be found here: https://wiki.onap.org/pages/viewpage.action?pageId=3246168

How to Use
~~~~~~~~~~
Design Time:

1) Because SDC doesn't export ETSI aigned VNF package and NS package, so in this release, we put the real ETSI aligned package as package artifact.
2) When design Network service in SDC, should assign "gvnfmdriver" as the value of nf_type in Properties Assignment. so that VF-C can know will use gvnfm to manage VNF life cycle.

Run Time:
1) First onboard VNF/NS package from SDC to VF-C catalog in sequence.
2) Trigger the NS operation via UUI

More details can be fonud here: https://wiki.onap.org/display/DW/vCPE+with+Tosca+VNF+Test+Guide

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
This case completed all tests as found here: https://wiki.onap.org/display/DW/vCPE+with+TOSCA+VNF+Integration+Test++-+Test+status

Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1) VF-C catalog config should be updated with the right SDC URL and user/pwd

Resolution: Disable VFC catalog livenessprobe and update configuration

- edit dev-vfc-catalog deployment
- remove livenessprobe section
- enter into catalog pod and update configuration
kubectl -n onap exec -it dev-vfc-catalog-6978b76c86-87722  /bin/bash
config file location: service/vfc/nfvo/catalog/catalog/pub/config/config.py 
Update the SDC configuration as follows:
SDC_BASE_URL = "http://msb-iag:80/api"
SDC_USER = "aai"
SDC_PASSWD = "Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U"

2) nfvtosca parser bug

nfvtoscaparse has error when parse sdc distribution package.
To ignore that error, we need either apply the patch at https://jira.opnfv.org/browse/PARSER-187 locally in nfv-toscaparser which VFC uses or wait for nfv-toscaparser got that fixed. 

3) grant error patch
https://gerrit.onap.org/r/#/c/73833/
https://gerrit.onap.org/r/#/c/73770/

4) vnflcm notification error patch
https://gerrit.onap.org/r/#/c/73852/

