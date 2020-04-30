.. _docs_vcpe_tosca:

vCPE with Tosca VNF
----------------------------

VNF Packages and NS Packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vCPE tosca file url: https://git.onap.org/demo/tree/tosca/vCPE_F

5 VNFs are here for the ONAP vCPE use case. The vnf csar file includes Infra, vGW, vBNG, vBRGEMU and vGMUX, and the ns csar file is ns.

Description
~~~~~~~~~~~
The vCPE with Tosca VNF shows how to use ONAP to deploy tosca based vCPE. ONAP Casablanca release supports deployment,termination and manual heal Tosca based vCPE. User can trigger the above operation via UUI. and User can first chose Network serivce type and conrresponding service template in UUI and then UUI will directly invoke VF-C Northbound interfaces to do the life cycle management. In Casablanca release, we bypass SO, in the following release, we can add SO to the workflow. The main projects involved in this use case include: SDC, A&AI, UUI，VF-C, Multicloud，MSB, Policy，OOF.
The use case is composed of five virtual functions (VFs): Infrastructure including vDNS, vDHCP, vAAA(Authorization, Authentication, Accounting) and vWEB, vBNG(Virtual Broadband Network Gateway), vGMUX(Virtual Gateway Multiplexer), vBRGEMU(Bridged Residential Gateway) and vGW(Virtual Gateway). Infrastructure VF run in one VM. the other VFs run in separate four VMs. We will send much data from vBRGEMU to vGW. we need to accelarate it using SRIOV-NIC.
The original vCPE Use Case Wiki Page can be found here: https://wiki.onap.org/pages/viewpage.action?pageId=3246168

How to Use
~~~~~~~~~~


Configuration:
~~~~~~~~~~~~~~
1) VIM Configuration

   Prepare openstack test environment.

   * Create project(tenant) and user on openstack

   Openstack Horizon--Identity--Projects page

   .. image:: files/vcpe_tosca/create_project.png

   Openstack Horizon--Identity--Users page

   .. image:: files/vcpe_tosca/create_user.png

   Manage Project Members

   .. image:: files/vcpe_tosca/manage_project_user.png

   * Create and upload image for VNF

   * Register VIM using CLI command or ESR GUI

   .. image:: files/vcpe_tosca/vim.png

2) VNFM Configuration

   Register vnfm using CLI command or ESR GUI.

   .. image:: files/vcpe_tosca/vnfm.png

Design Time:
~~~~~~~~~~~~
1) We put the real ETSI aligned package as package artifact.
2) When design Network service in SDC, should assign "gvnfmdriver" as the value of nf_type in Properties Assignment. so that VF-C can know will use gvnfm to manage VNF life cycle.

   .. image:: files/vcpe_tosca/sdc.png

Run Time:
~~~~~~~~~
1) First onboard VNF/NS package from SDC to modeling etsicatalog in sequence.
2) Trigger the NS operation via UUI guide

a) VNF/NS csar package on-boarded guide

   Note:

   * VNF/NS csar package can be distributed from SDC.
   * VNF csar package should be distributed first, then NS csar package can be distributed.
   * The csar package list page shows both the on-boarded/distributed csar package and the package from SDC.
   * When the package from SDC is on-boarded, it will be dropped from the list, and the on-boarded package will be displayed in the list.

   The following shows the guide of on-boarded a NS csar package via UUI:

   Step 1. Select the SDC NS csar package vcpe_test_001 in csar package list package, and click the onboard button, the SDC NS csar package will be on-boarded to Modeling:

   .. image:: files/vcpe_tosca/ns_package_list.png

   Step 2. When the onboard is completed, the SDC csar vcpe_test_001 is dropped from the list, and the on-boarded csar info(vcpe) will be displayed in the csar file list:

   .. image:: files/vcpe_tosca/ns_package_onboard.png

   You can also onboard a VNF csar package by click the VNF tab in the csar package list page, then follow the upper two steps. You should onboard vnfs before ns.

b) NS Instantiate guide

   Note:

   * When an NS package is on-boarded or distributed,  you can start NS Instantiating.

   The following steps show the guide of Instantiating NS:

   Step 1. Open the service list page, first select Customer and Service Type, then click Create button.

   .. image:: files/vcpe_tosca/customer_service.png

   Step 2. First select the Service with Network Service, then select the TEMPLATE, then click OK button:

   .. image:: files/vcpe_tosca/ns_create.png

   Step 3. First input the NS Name and Description, then select the vf_location of each vnf, then click Create button:

   .. image:: files/vcpe_tosca/ns_create_input.png

   Step 4. A new record will be added to the list package, the Status column will show the Instantiating progress.

   .. image:: files/vcpe_tosca/ns_instance.png

   Step 5. When NS Instantiating is completed, the Status will updated to completed, and you can refresh the package, the Status will be updated to Active.

   .. image:: files/vcpe_tosca/ns_active.png

c) NS heal guide

   Note:

   * VF-C R3 healing only suport restart a vm of an VNF.

   The following shows the guide of healing an VNF of  an Instantiated NS:

   Step 1. Click + button of an  an Instantiated NS, the VNF list of the NS will be displayed:

   .. image:: files/vcpe_tosca/ns_vnf_list.png

   Step 2. Click the heal button of a VNF, select the vm of the VNF, and click OK button:

   .. image:: files/vcpe_tosca/ns_vnf_heal.png

   Step 3. When VNF healing is started, the Status of VNF will shows the progress of healing.

   .. image:: files/vcpe_tosca/ns_vnf_healing.png

   Step 4. When VNF healing is completed, the Status will be updated to completed, you can refresh the page, the Status will be updated to Active again.

   .. image:: files/vcpe_tosca/ns_vnf_healed.png

d) NS delete guide

   The following shows the guide of deleting an VNF of an Instantiated NS:

   Step 1. Select an Instantiated NS record in the list page, then click the delete button:

   .. image:: files/vcpe_tosca/ns_active.png

   Step 2. Select the termination Type and the graceful Termination Timeout, then click OK button:

   .. image:: files/vcpe_tosca/ns_delete.png

   Step 3. When the deleting is started, the Status will be updated to the progress of deleting.

   .. image:: files/vcpe_tosca/ns_deleting.png

   when deleting is completed, the Status will be update to completed, and soon it will be drop from the list.

   .. image:: files/vcpe_tosca/ns_deleted.png

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
This case completed all tests as found here: https://wiki.onap.org/display/DW/vCPE%28tosca%29+-++Integration+test+cases

Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1) There is time out issue when terminating vnf, the solution is refer to

   https://gerrit.onap.org/r/c/vfc/nfvo/driver/vnfm/gvnfm/+/105192

2) The process of terminating job is chaotic, the solution is refer to

   https://gerrit.onap.org/r/c/vfc/nfvo/lcm/+/105449

3) Failed to fetch NS package from SDC when having VL resource, the solution is refer to

   https://gerrit.onap.org/r/c/modeling/etsicatalog/+/106074

4) The model msg is error when deleting the vnf package via UUI, the solution is refer to

   https://gerrit.onap.org/r/c/usecase-ui/+/106729

5) Wrong number of services displayed for services-list via UUI, the solution is refer to

   https://gerrit.onap.org/r/c/usecase-ui/+/106719

6) The picture cannot be displayed of ns create model page via UUI, the solution is refer to

   https://gerrit.onap.org/r/c/usecase-ui/+/106715
