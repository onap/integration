vCPE of Tosca Use Case
----------------------

Source files
~~~~~~~~~~~

vCPE tosca file url: https://git.onap.org/demo/tree/tosca/vCPE

5 VNFs are here for the ONAP vCPE use case. This VNFD is transformed manually from vCPE heat template.
Please run "./generate_csar.sh" to create the CSAR package files for these 5 VNFS. CSAR package file is just a zip formatted file. If you want to use SRIOV SRIOV-NIC", please run "./generate_csar.sh sriov" to create the CSAR package files for SRIOV.


Description
~~~~~~~~~~

The use case is composed of five virtual functions (VFs): Infrastructure including vDNS, vDHCP, vAAA(Authorization, Authentication, Accounting) and
vWEB, vBNG(Virtual Broadband Network Gateway), vGMUX(Virtual Gateway Multiplexer), vBRGEMU(Bridged Residential Gateway) and vGW(Virtual Gateway).
Infrastructure VF run in one VM. the other VFs run in separate four VMs. We will send much data from vBRGEMU to vGW. we need to accelarate it using SRIOV-NIC.


Test Plan:
~~~~~~~~~~~~~~~~~~

The test plan 3 in https://wiki.onap.org/pages/viewpage.action?pageId=41421112.
Test Plan 3: VF-C HPA testing
This test plan covers the tests related to testing
Support for the vCPE use case in VF-C

Use vCPE (Infra, vGW, vBNG, vBRGEMU and vGMUX)

Infra part of  policy asking for:
::

  2 vcpus
  >= 2Gbytes of memory
  > 40Gbytes of disk

vGW part of policy asking for:
::

  2 vcpus
  >=4Gbytes of memory
  >= 40Gbytes of disk
  Numa page size: 2Mbytes and pages 1024
  with one SRIOV-NIC

vBNG part of policy asking for:
::

  2 vcpus
  >= 2Gbytes of memory
  > 40Gbytes of disk
  Numa page size: 2Mbytes and pages 1024
  with one SRIOV-NIC

vBGREMU part of policy asking for:
::

  2 vcpus
  >= 2Gbytes of memory
  >= 40Gbytes of disk
  Numa page size: 2Mbytes and pages 1024
  with one SRIOV-NIC

vGMUX part of policy asking for:
::

  2 vcpus
  >= 2Gbytes of memory
  > 40Gbytes of disk
  Numa page size: 2Mbytes and pages 1024
  with one SRIOV-NIC

Instantiate the VNF
Check for results:
It would have selected flavor13 for vGW, vBNG, vBRGEMU and vGMUX VMs. It would have selected flavor13 and flavor12 for Infrastructure.

Test Steps:
~~~~~~~~~~

VIM Configuration:
^^^^^^^^^^^^^^^^^^

If you want to use SRIOV-NIC, you need first config SRIOV NIC to refer to [1].
[1] https://docs.openstack.org/ocata/networking-guide/config-sriov.html

ONAP managing 1 cloud-region which have three flavors.
Flavor 11:
2 vcpus, 1 Gbytes of memory, 20Gb disk
Numa page size: 2Mbytes and number pages 512
::

  openstack flavor create onap.hpa.flavor11 -id auto --ram 1024 --disk 20 --vcpus 2

Flavor 12:
2 vcpus, 2 Gbytes of memory, 20Gb disk
Numa page size: 2Mbytes and number pages 1024
::

  openstack flavor create onap.hpa.flavor12 -id auto --ram 2048 --disk 20 --vcpus 2

Flavor 13:
2 vcpus, 4 Gbytes of memory, 20Gb disk
Huge page size: 2Mbytes and number pages 2048
1 SRIOV-NIC VF
::

  openstack flavor create onap.hpa.flavor13 -id auto --ram 4096 --disk 20 -vcpus 2
  openstack flavor set onap.hpa.flavor11 --property aggregate_instance_extra_specs:sriov_nic=sriov-nic-intel-1234-5678-physnet1:1
  openstack aggregate create --property sriov_nic=sriov-nic-intel-1234-5678-physnet1:1 hpa_aggr11

comments: you must change 1234 and 5678 to real vendor id and product id. you also need change physnet1 to the provider network.

Policy Configuration:
^^^^^^^^^^^^^^^^^^^^^

After the patch https://gerrit.onap.org/r/#/c/73502/ is merged. With the generated policy and do some manually update as follows, the service could be distributed successfully and the Policy/VFC/OOF could work as excepted.

- Need manually modify policy item because the “vendor id” and “PCI device id” and “architecture” must be changed in different VIMs since we have different PCI devices in different VIMs
- The value of mandatory in CSAR is “true”, OOF is case intensive, it needs to use “True”. Have to update it. suggest OOF to use ignoreCase in R4.
- The attribute key in CSAR is pciNumDevices, but the responding one in OOF/Mutlicloud is pciCount.  Suggest keeping alignment in R4.
- The policy scope has to add a value “us” into it which is a configuration issue in OOF side. Policy side also need do improvement to deal with policy scope automatically append instead of replacement so such policy could be used by several services at the same time.


Running the Use Case
~~~~~~~~~~~~~~~~~~~

We design vCPE in SDC and distribute it to VFC and Policy and UUI. We can click onboarding VNF and onboarding NS. we can instance it.

Known issues and resolution
~~~~~~~~~~~~~~~~~~~~~~~~~~

- Some SDC NS data model is not aligned to VFC NS data model, VFC NS also according to ETSI SOL0001. we also can refer to https://jira.onap.org/browse/SDC-1897. we have a workaround for this issue, we put the service as artifact file and distribute to VFC.
- NFV Tosca parser bug https://jira.opnfv.org/browse/PARSER-187. we also filed a bug in VFC https://jira.onap.org/browse/VFC-1196.
- 'artifacts' definition is missing in the exported csar's VDU node, we also can refer to https://jira.onap.org/browse/SDC-1900. It’s a very hacky workaround in VFC’s GVFNM. Because currently the only use case will use GVFNM is vCPE, which only uses the ubuntu16.04 image, so GVFNM just makes the ubuntu16.04 image as the default if the "sw_image" artifact is missing in the SDC’s exported CSAR.
- OOF patch https://gerrit.onap.org/r/#/c/73332/ is not accepted by 1.2.4 image.It will be accepted by 1.2.5 image. but 1.2.5 image is not release. If you want to use it, you can use 1.2.5-SNAPSHOT-latest. If you use 1.2.4 image, you also need to modify code according to the patch.
