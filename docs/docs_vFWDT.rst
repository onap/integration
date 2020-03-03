.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0
   
.. _docs_vfw_traffic:

.. contents::
   :depth: 3
..

vFW In-Place Software Upgrade with Traffic Distribution Use Case
----------------------------------------------------------------
Description
~~~~~~~~~~~

The purpose of this work is to show In-Place Software Upgrade Traffic Distribiution functionality implemented in El Alto release for vFW Use Case.
The use case is an evolution of vFW Traffic Distribution Use Case whicjh was developed for Casablanca and Dublin releases.
The orchstration workflow triggers a change to traffic distribution (redistribution) done by a traffic balancing/distribution entity (aka anchor point). 
The DistributeTraffic action targets the traffic balancing/distribution entity, in some cases DNS, other cases a load balancer external to the VNF instance, as examples. 
Traffic distribution (weight) changes intended to take a VNF instance out of service are completed only when all in-flight traffic/transactions have been completed. 
DistributeTrafficCheck command may be used to verify initial conditions of redistribution or can be used to verify the state of VNFs and redistribution itself. 
To complete the traffic redistribution process, gracefully taking a VNF instance out-of-service/into-service, without dropping in-flight calls or sessions, 
QuiesceTraffic/ResumeTraffic command may need to follow traffic distribution changes. The VNF application remains in an active state.


Traffic Distribution functionality is an outcome of Change Management project. Further details can be found on following pages

- Frankfurt: https://wiki.onap.org/display/DW/Change+Management+Frankfurt+Extensions (Traffic Distribution workflow enhancements)

- Dublin: https://wiki.onap.org/display/DW/Change+Management+Extensions (DistributeTraffic LCM and Use Case)

- Casablanca https://wiki.onap.org/display/DW/Change+Management+Dublin+Extensions (Distribute Traffic Workflow with Optimization Framework)

Test Scenario
~~~~~~~~~~~~~

.. figure:: files/dt-use-case.png
   :scale: 40 %
   :align: center

   Figure 1 The idea of Traffic Distribution Use Case

The idea of the simplified scenario presented in the Casablanca release is shown on Figure 1. In a result of the DistributeTraffic LCM action traffic flow originated from vPKG to vFW 1 and vSINK 1 is redirected to vFW 2 and vSINK 2 (as it is seen on Figure 2).
Result of the change can be observed also on the vSINKs' dashboards which show a current incoming traffic. Observation of the dashboard from vSINK 1 and vSINK 2 proves workflow works properly.

.. figure:: files/dt-result.png
   :scale: 60 %
   :align: center

   Figure 2 The result of traffic distribution

The purpose of the work in the Dublin release was to built a Traffic Distribution Workflow that takes as an input configuration parameters delivered by Optimization Framework and on their basis several traffic distribution LCM actions are executed by APPC in the specific workflow.

.. figure:: files/dt-workflow.png
   :scale: 60 %
   :align: center

   Figure 3 The Traffic Distribution Workflow

The prepared Traffic Distribution Workflow has following steps:

- Workflow sends placement request to Optimization Framework (**1**) specific information about the vPKG and vFW-SINK models and VNF-ID of vFW that we want to migrate traffic out from. 
  Optimization Framework role is to find the vFW-SINK VNF/VF-module instance where traffic should be migrated to and vPKG which will be associated with this vFW. 
  Although in our case the calculation is very simple, the mechanism is ready to work for instances of services with VNF having houndreds of VF-modules spread accross different cloud regions.

- Optimization Framework takes from the Policy Framework policies (**2-3**) for VNFs and for relations between each other (in our case there is checked ACTIVE status of vFW-SINK and vPKG VF-modules and the Region to which they belong)

- Optimization Framework, base on the information from the polcies and service topology information taken from A&AI (**4-11**), offers traffic distribution anchor and destination canidates' pairs (**12-13**) (pairs of VF-modules data with information about their V-Servers and their network interfaces). This information is returned to the workflow script (**14**).

- Information from Optimization Framework can be used to construct APPC LCM requests for DistributeTrafficCheck and DistributeTraffic commands (**15, 24, 33, 42**). This information is used to fill CDT templates with proper data for further Ansible playbooks execution (**17, 26, 35, 44**)

- In the first DistributeTrafficCheck LCM request on vPGN VNF/VF-Module APPC, over Ansible, checks if already configured destinatrion of vPKG packages is different than already configured. If not workflow is stopped (**23**).

- Next, APPC performs the DistributeTraffic action like it is shown on Figure 1 and Figure 2 (**25-31**). If operation is completed properly traffic should be redirected to vFW 2 and vSINK 2 instance. If not, workflow is stopped (**32**).

- Finally, APPC executes the DistributeTrafficCheck action on vFW 1 in order to verify that it does not receives any traffic anymore (**34-40**) and on vFW 2 in order to verify that it receives traffic forwarded from vFW 2 (**43-49**)

Scenario Setup
--------------

In order to setup the scenario and to test the DistributeTraffic LCM API in action you need to perform the following steps:

1. Create an instance of vFWDT (vPKG , 2 x vFW, 2 x vSINK) – dedicated for the DistributeTraffic LCM API tests

#. Gather A&AI facts for Traffic Distribution use case configuration

#. Install Traffic Distribution workflow packages

#. Configure Optimization Framework for Traffic Distribution workflow

#. Configure vPKG and vFW VNFs in APPC CDT tool

#. Configure Ansible Server to work with vPKG and vFW VMs

#. Execute Traffic Distribution Workflow 

You will use the following ONAP K8s VMs or containers:

-  ONAP Rancher Server – workflow setup and its execution

-  APPC MariaDB container – setup Ansible adapter for vFWDT VNFs

-  APPC Ansible Server container – setup of Ansible Server, configuration of playbook and input parameters for LCM actions

.. note:: In all occurences <K8S-NODE-IP> constant is the IP address of any K8s Node of ONAP OOM installation which hosts ONAP pods i.e. k8s-node-1 and <K8S-RANCHER-IP> constant is the IP address of K8S Rancher Server

vFWDT Service Instantiation
~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to test a DistributeTraffic LCM API functionality a dedicated vFW instance must be prepared. It differs from a standard vFW instance by having an additional VF-module with a second instance of vFW and a second instance of vSINK. Thanks to that when a service instance is deployed there are already available two instances of vFW and vSINK that can be used for verification of DistributeTraffic LCM API – there is no need to use the ScaleOut function to test DistributeTraffic functionality what simplifies preparations for tests.

In order to instantiate vFWDT service please follow the procedure for standard vFW with following changes. You can create such service manually or you can use robot framework. For manual instantiation:

1. Please use the following HEAT templates:

https://github.com/onap/demo/tree/master/heat/vFWDT

2. Create Virtual Service in SDC with composition like it is shown on Figure 3

.. figure:: files/vfwdt-service.png
   :scale: 60 %
   :align: center

   Figure 3 Composition of vFWDT Service

3. Use the following payload files in the SDNC-Preload phase during the VF-Module instantiation

- :download:`vPKG preload example <files/vpkg-preload.json>`

- :download:`vFW/SNK 1 preload example <files/vfw-1-preload.json>`

- :download:`vFW/SNK 2 preload example <files/vfw-2-preload.json>`

.. note:: Use publikc-key that is a pair for private key files used to log into ONAP OOM Rancher server. It will simplify further configuration

.. note:: vFWDT has a specific configuration of the networks – different than the one in original vFW use case (see Figure 4). Two networks must be created before the heat stack creation: *onap-private* network (10.0.0.0/16 typically) and *onap-external-private* (e.g. "10.100.0.0/16"). The latter one should be connected over a router to the external network that gives an access to VMs. Thanks to that VMs can have a floating IP from the external network assigned automatically in a time of stacks' creation. Moreover, the vPKG heat stack must be created before the vFW/vSINK stacks (it means that the VF-module for vPKG must be created as a first one). The vPKG stack creates two networks for the vFWDT use case: *protected* and *unprotected*; so these networks must be present before the stacks for vFW/vSINK are created.

.. figure:: files/vfwdt-networks.png
   :scale: 15 %
   :align: center

   Figure 4 Configuration of networks for vFWDT service

4. Go to *robot* folder in Rancher server (being *root* user)

Go to the Rancher node and locate *demo-k8s.sh* script in *oom/kubernetes/robot* directory. This script will be used to run heatbridge procedure which will update A&AI information taken from OpenStack

5. Run robot *heatbridge* in order to upload service topology information into A&AI

::

    ./demo-k8s.sh onap heatbridge <stack_name> <service_instance_id> <service> <oam-ip-address>

where:

- <stack_name> - HEAT stack name from: OpenStack -> Orchestration -> Stacks
- <service_instance_id> - is service_instance_id which you can get from VID or AAI REST API
- <service> - in our case it should be vFWDT but may different (vFW, vFWCL) if you have assigned different service type in SDC
- <oam-ip-address> - it is the name of HEAT input which stores ONAP management network name

Much easier way to create vFWDT service instance is to trigger it from the robot framework. Robot automates creation of service instance and it runs also heatbridge. To create vFWDT this way:

1. Go to *robot* folder in Rancher server (being *root* user)

Go to the Rancher node and locate *demo-k8s.sh* script in *oom/kubernetes/robot* directory. This script will be used to run instantiate vFWDT service

2. Run robot scripts for vFWDT instantiation

::

    ./demo-k8s.sh onap init
    ./ete-k8s.sh onap instantiateVFWDT


.. note:: You can verify the status of robot's service instantiation process by going to http://<K8S-NODE-IP>:30209/logs/ (login/password: test/test)

After successful instantiation of vFWDT service go to the OpenStack dashboard and project which is configured for VNFs deployment and locate vFWDT VMs. Choose one and try to ssh into one them to proove that further ansible configuration action will be possible

::

    ssh -i <rancher_private_key> ubuntu@<VM-IP>


.. note:: The same private key file is used to ssh into Rancher server and VMs created by ONAP

Preparation of Workflow Script Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Enter over ssh Rancher server using root user

::

    ssh -i <rancher_private_key> root@<K8S-RANCHER-IP>

2. Clone onap/demo repository

::

    git clone --single-branch --branch dublin "https://gerrit.onap.org/r/demo"

3. Enter vFWDT tutorial directory

::

    cd demo/tutorials/vFWDT
    ls

what should show following folders

::

    root@sb01-rancher:~/demo/tutorials/vFWDT# ls
    playbooks  preloads  workflow


.. note:: Remember vFWDT tutorial directory `~/demo/tutorials/vFWDT` for the further use

4. Install python dependencies

::

    sudo apt-get install python3-pip
    pip3 install -r workflow/requirements.txt --user

Gathering Scenario Facts
------------------------
In order to configure CDT tool for execution of Ansible playbooks and for execution of Traffic distribution workflow we need following A&AI facts for vFWDT service

- **vnf-id** of generic-vnf vFW instance that we want to migrate traffic out from
- **vnf-type** of vPKG VNF - required to configure CDT for Distribute Traffic LCMs
- **vnf-type** of vFW-SINK VNFs - required to configure CDT for Distribute Traffic LCMs

Gathering facts from VID Portal
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Enter the VID portal

:: 
    
    https://<K8S-NODE-IP>:30200/vid/welcome.htm

2. In the left hand menu enter **Search for Existing Service Instances**

3. Select proper subscriber from the list and press **Submit** button. When service instance of vFWDT Service Type appears Click on **View/Edit** link

.. note:: The name of the subscriber you can read from the robot logs if your have created vFWDT instance with robot. Otherwise this should be *Demonstration* subscriber

4. For each VNF in vFWDT service instance note its *vnf-id* and *vnf-type*

.. figure:: files/vfwdt-vid-vpkg.png
   :scale: 60 %
   :align: center

   Figure 5 vnf-type and vnf-id for vPKG VNF

.. figure:: files/vfwdt-vid-vnf-1.png
   :scale: 60 %
   :align: center

   Figure 6 vnf-type and vnf-id for vFW-SINK 1 VNF

.. figure:: files/vfwdt-vid-vnf-2.png
   :scale: 60 %
   :align: center

   Figure 7 vnf-type and vnf-id for vFW-SINK 2 VNF

Gathering facts directly from A&AI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Enter OpenStack dashboard on whicvh vFWDT instance was created and got to **Project->Compute->Instances** and read VM names of vPKG VM and 2 vFW VMs created in vFWDT service instance

2. Open Postman or any other REST client

3. In Postman in General Settings disable *SSL Certificate verification*

4. You can use also following Postman Collection for AAI :download:`AAI Postman Collection <files/vfwdt-aai-postman.json>`

5. Alternatively create Collection and set its *Authorization* to *Basic Auth* type with login/password: AAI/AAI

6. Create new GET query for *tenants* type with following link and read *tenant-id* value

::

    https://<K8S-NODE-IP>:30233/aai/v14/cloud-infrastructure/cloud-regions/cloud-region/CloudOwner/RegionOne/tenants/

.. note:: *CloudOwner* and *Region* names are fixed for default setup of ONAP

7. Create new GET query for *vserver* type with following link replacing <tenant-id> with value read before and <vm-name> with vPKG VM name read from OpenStack dashboard

::

    https://<K8S-NODE-IP>:30233/aai/v14/cloud-infrastructure/cloud-regions/cloud-region/CloudOwner/RegionOne/tenants/tenant/<tenant-id>/vservers/?vserver-name=<vm-name>

Read from the response (realtionship with *generic-vnf* type) vnf-id of vPKG VNF

.. note:: If you do not receive any vserver candidate it means that heatbridge procedure was not performed or was not completed successfuly. It is mandatory to continue this tutorial

8. Create new GET query for *generic-vnf* type with following link replacing <vnf-id> with value read from previous GET response

::

    https://<K8S-NODE-IP>:30233/aai/v14/network/generic-vnfs/generic-vnf/<vnf-id>

9. Repeat this procedure also for 2 vFW VMs and note their *vnf-type* and *vnf-id*

Configuration of ONAP Environment
---------------------------------
This sections show the steps necessary to configure Policies, CDT and Ansible server what is required for execution of APPC LCM actions in the workflow script

Configuration of Policies for Optimization Framework
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
We need to enter the Policy editor in order to upload policy types and then the policy rules for the demo. The polcies are required for the Optimization Framework and they guide OOF how to determine
vFW and vPGN instances used in the Traffic Distribution workflow.

1. Enter the Policy portal

Specify *demo*:*demo* as a login and password

::

    https://<K8S-NODE-IP>:30219/onap/login.htm

From the left side menu enter *Dictionary* section and from the combo boxes select *MicroService Policy* and *MicroService Models* respectively. Below you can see the result.

.. figure:: files/vfwdt-policy-type-list.png
   :scale: 70 %
   :align: center

   Figure 8 List of MicroService policy types in the Policy portal

2. Upload the policy types

Before policy rules for Traffic Distribution can be uploaded we need to create policy types to store these rules. For that we need to create following three types:

- VNF Policy - it used to filter vf-module instances i.e. base on their attributes from the AAI like *provStatus*, *cloudRegionId* etc.
- Query Policy - it is used to declare extra inpt parameters for OOF placement request  - in our case we need to specify cloud region name
- Affinity Policy - it is used to specify the placement rule used for selection vf-module candiate pairs of vFW vf-module instance (traffic destination) and vPGN vf-module instance (anchor point). In this case the match is done by belonging to the same cloud region

Enter vFWDT tutorial directory on Rancher server (already created in `Preparation of Workflow Script Environment`_) and create policy types from the following files

::

    root@sb01-rancher:~/demo/tutorials/vFWDT# ls policies/types/
    affinityPolicy-v20181031.yml  queryPolicy-v20181031.yml  vnfPolicy-v20181031.yml

For each file press *Create* button, choose the policy type file, select the *Micro Service Option* (always one available) and enter the *Version* which must be the same like the one specified for policy instances. In this case pass value *OpenSource.version.1*

.. figure:: files/vfwdt-add-micro-service-policy.png
   :scale: 70 %
   :align: center

   Figure 9 Creation of new MicroService policy type for OOF

In a result you should see in the dictionary all three new types of policies declared

.. figure:: files/vfwdt-completed-policy-type-list.png
   :scale: 70 %
   :align: center

   Figure 10 Completed list of MicroService policy types in the Policy portal

3. Push the policies into the PDP

In order to push policies into the PDP it is required to execute already prepared *uploadPolicies.sh* script that builds policy creation/update requests and automatically sends them to the Policy PDP pod

::

    root@sb01-rancher:~/demo/tutorials/vFWDT# ls policies/rules/
    QueryPolicy_vFW_TD.json  affinity_vFW_TD.json  uploadPolicies.sh  vnfPolicy_vFW_TD.json  vnfPolicy_vPGN_TD.json

When necessary, you can modify policy json files. Script will read these files and will build new PDP requests based on them. To create new policies execute script in the following way

::

    ./policies/rules/uploadPolicies.sh

To update existing policies execute script with an extra argument

::

    ./policies/rules/uploadPolicies.sh U

The result can be verified in the Policy portal, in the *Editor* section, after entering *OSDF_DUBLIN* directory

.. figure:: files/vfwdt-policy-editor-osdf-dublin.png
   :scale: 70 %
   :align: center

   Figure 11 List of policies for OOF and vFW traffic distribution

Testing Gathered Facts on Workflow Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Having collected *vnf-id* and *vnf-type* parameters we can execute Traffic Distribution Workflow Python script. It works in two modes. First one executes ony initial phase where AAI and OOF 
is used to collect neccessary information for configuration of APPC and for further execution phase. The second mode performs also second phase which executes APPC LCM actions.

At this stage we will execute script in the initial mode to generate some configuration helpful in CDT and Ansible configuration.

1. Enter vFWDT tutorial directory on Rancher server (already created in `Preparation of Workflow Script Environment`_) and execute there workflow script with follwoing parameters

::

    python3 workflow.py <VNF-ID> <K8S-NODE-IP> True False True True

For now and for further use workflow script has following input parameters:

- vnf-id of vFW VNF instance that traffic should be migrated out from
- External IP of ONAP Rancher Node i.e. 10.12.5.160 (If Rancher Node is missing this is NFS node)
- External IP of ONAP K8s Worker Node i.e. 10.12.5.212
- if script should use and build OOF response cache (cache it speed-ups further executions of script)
- if instead of vFWDT service instance vFW or vFWCL one is used (should be False always)
- if only configuration information will be collected (True for initial phase and False for full execution of workflow)
- if APPC LCM action status should be verified and FAILURE should stop workflow (when False FAILED status of LCM action does not stop execution of further LCM actions)

2. The script at this stage should give simmilar output 

::

    Executing workflow for VNF ID '909d396b-4d99-4c6a-a59b-abe948873303' on Rancher with IP 10.0.0.10 and ONAP with IP 10.12.5.217

    OOF Cache True, is CL vFW False, only info False, check LCM result True

    vFWDT Service Information:
    {
        "vf-module-id": "0dce0e61-9309-449a-8e3e-f001635aaab1",
        "service-info": {
            "global-customer-id": "DemoCust_ccc04407-1740-4359-b3c4-51bbcb62d9f6",
            "service-type": "vFWDT",
            "service-instance-id": "ab37d391-95c6-4844-b7c3-23d111bfa2ce"
        },
        "vfw-model-info": {
            "model-version-id": "f7fc17ba-48b9-456b-acc1-f89f31eda8cc",
            "vnf-type": "vFWDT 2019-05-20 21:10:/vFWDT_vFWSNK b463aa83-b1fc 0",
            "model-invariant-id": "0dfe8d6d-21c1-42f6-867a-1867cebb7751",
            "vnf-name": "Ete_vFWDTvFWSNK_ccc04407_1"
        },
        "vpgn-model-info": {
            "model-version-id": "0f8a2467-af44-4d7c-ac55-a346dcad9e0e",
            "vnf-type": "vFWDT 2019-05-20 21:10:/vFWDT_vPKG a646a255-9bee 0",
            "model-invariant-id": "75e5ec48-f43e-40d2-9877-867cf182e3d0",
            "vnf-name": "Ete_vFWDTvPKG_ccc04407_0"
        }
    }

    Ansible Inventory:
    [vpgn]
    vofwl01pgn4407 ansible_ssh_host=10.0.210.103 ansible_ssh_user=ubuntu
    [vfw-sink]
    vofwl01vfw4407 ansible_ssh_host=10.0.110.1 ansible_ssh_user=ubuntu
    vofwl02vfw4407 ansible_ssh_host=10.0.110.4 ansible_ssh_user=ubuntu

The result should have almoast the same information for *vnf-id's* of both vFW VNFs. *vnf-type* for vPKG and vFW VNFs should be the same like those collected in previous steps. 
Ansible Inventory section contains information about the content Ansible Inventor file that will be configured later on `Configuration of Ansible Server`_

Configuration of VNF in the APPC CDT tool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Following steps aim to configure DistributeTraffic LCM action for our vPKG and vFW-SINK VNFs in APPC CDT tool.

1. Enter the Controller Design Tool portal

::

    https://<K8S-NODE-IP>:30289/index.html

2. Click on *MY VNFS* button and login to CDT portal giving i.e. *demo* user name

3. Click on the *CREATE NEW VNF TYPE* button

.. figure:: files/vfwdt-create-vnf-type.png
   :scale: 70 %
   :align: center

   Figure 12 Creation of new VNF type in CDT

4. Enter previously retrieved VNF Type for vPKG VNF and press the *NEXT* button

.. figure:: files/vfwdt-enter-vnf-type.png
   :scale: 70 %
   :align: center

   Figure 13 Creation of new VNF type in CDT

5. For already created VNF Type (if the view does not open itself) click the *View/Edit* button. In the LCM action edit view in the first tab please choose:

-  *DistributeTraffic* as Action name

-  *ANSIBLE* as Device Protocol

-  *Y* value in Template dropdown menu

-  *admin* as User Name

-  *8000* as Port Number


.. figure:: files/vfwdt-new-lcm-ref-data.png
   :scale: 70 %
   :align: center

   Figure 14 DistributeTraffic LCM action editing

6. Go to the *Template* tab and in the editor paste the request template of the DistributeTraffic LCM action for vPKG VNF type

::

    {
        "InventoryNames": "VM",
        "PlaybookName": "${()=(book_name)}",
        "NodeList": [{
            "vm-info": [{
                "ne_id": "${()=(ne_id)}", 
                "fixed_ip_address": "${()=(fixed_ip_address)}"
            }], 
            "site": "site",
            "vnfc-type": "vpgn"
        }],
        "EnvParameters": {
            "ConfigFileName": "../traffic_distribution_config.json",
            "vnf_instance": "vfwdt",
        },
        "FileParameters": {
            "traffic_distribution_config.json": "${()=(file_parameter_content)}"
        },
        "Timeout": 3600
    }

.. note:: For all this VNF types and for all actions CDT template is the same except **vnfc-type** parameter that for vPKG VNF type should have value *vpgn* and for vFW-SINK VNF type should have value *vfw-sink*

The meaning of selected template parameters is following:

- **EnvParameters** group contains all the parameters that will be passed directly to the Ansible playbook during the request's execution. *vnf_instance* is an obligatory parameter for VNF Ansible LCMs. In our case for simplification it has predefined value
- **InventoryNames** parameter is obligatory if you want to have NodeList with limited VMs or VNFCs that playbook should be executed on. It can have value *VM* or *VNFC*. In our case *VM* valuye means that NodeList will have information about VMs on which playbook should be executed. In this use case this is always only one VM
- **NodeList** parameter value must match the group of VMs like it was specified in the Ansible inventory file. *PlaybookName* must be the same as the name of playbook that was uploaded before to the Ansible server.
- **FileParameters**


.. figure:: files/vfwdt-create-template.png
   :scale: 70 %
   :align: center

   Figure 15 LCM DistributeTraffic request template

7. Afterwards press the *SYNCHRONIZE WITH TEMPLATE PARAMETERS* button. You will be moved to the *Parameter Definition* tab. The new parameters will be listed there.

.. figure:: files/vfwdt-template-parameters.png
   :scale: 70 %
   :align: center

   Figure 16 Summary of parameters specified for DistributeTraffic LCM action.

.. note:: For each parameter you can define its: mandatory presence; default value; source (Manual/A&AI). For our case modification of this settings is not necessary

8. Finally, go back to the *Reference Data* tab and click *SAVE ALL TO APPC*.

.. note:: Remember to configure DistributeTraffic and DistributeTrafficCheck actions for vPKG VNF type and DistributeTrafficCheck action for vFW-SINK

Configuration of Ansible Server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After an instantiation of the vFWDT service the Ansible server must be configured in order to allow it a reconfiguration of vPKG VM.

1. Copy from Rancher server private key file used for vFWDT VMs' creation and used for access to Rancher server into the :file:`/opt/ansible-server/Playbooks/onap.pem` file

::

    sudo kubectl cp <path/to/file>/onap.pem onap/`kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep appc-ansible`:/opt/ansible-server/Playbooks/

.. note:: The private key file must be the same like configured at this stage `vFWDT Service Instantiation`_

2. Enter the Rancher server and then enter the APPC Ansible server container

::

    kubectl exec -it -n onap `kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep appc-ansible` -- sh

3. Give the private key file a proper access rights

::

    cd /opt/ansible-server/Playbooks/
    chmod 400 onap.pem
    chown ansible:ansible onap.pem

4. Edit the :file:`/opt/ansible-server/Playbooks/Ansible\ \_\ inventory` file including all the hosts of vFWDT service instance used in this use case. 
   The content of the file is generated by workflow script `Testing Gathered Facts on Workflow Script`_

::

    [vpgn]
    vofwl01pgn4407 ansible_ssh_host=10.0.210.103 ansible_ssh_user=ubuntu
    [vfw-sink]
    vofwl01vfw4407 ansible_ssh_host=10.0.110.1 ansible_ssh_user=ubuntu
    vofwl02vfw4407 ansible_ssh_host=10.0.110.4 ansible_ssh_user=ubuntu

.. note:: Names of hosts and their IP addresses will be different. The names of the host groups are the same like 'vnfc-type' attributes configured in the CDT templates

5. Configure the default private key file used by Ansible server to access hosts over ssh

::

    vi /etc/ansible/ansible.cfg

::

    [defaults]
    host_key_checking = False
    private_key_file = /opt/ansible-server/Playbooks/onap.pem


.. note:: This is the default privaye key file. In the `/opt/ansible-server/Playbooks/Ansible\ \_\ inventory` different key could be configured but APPC in time of execution of playbbok on Ansible server creates its own dedicated inventory file which does not have private key file specified. In consequence, this key file configured is mandatory for proper execution of playbooks by APPC


6. Test that the Ansible server can access over ssh vFWDT hosts configured in the ansible inventory 

::

    ansible –i Ansible_inventory vpgn,vfw-sink –m ping


7. Download the distribute traffic playbook into the :file:`/opt/ansible-server/Playbooks` directory

Exit Ansible server pod and enter vFWDT tutorial directory `Preparation of Workflow Script Environment`_ on Rancher server. Afterwards, copy playbooks into Ansible server pod

::

    sudo kubectl cp playbooks/vfw-sink onap/`kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep appc-ansible`:/opt/ansible-server/Playbooks/
    sudo kubectl cp playbooks/vpgn onap/`kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep appc-ansible`:/opt/ansible-server/Playbooks/

8. After the configuration of Ansible serverthe structure of `/opt/ansible-server/Playbooks` directory should be following

::

    /opt/ansible-server/Playbooks $ ls -R
    .:
    Ansible_inventory  onap.pem           vfw-sink           vpgn

    ./vfw-sink:
    latest

    ./vfw-sink/latest:
    ansible

    ./vfw-sink/latest/ansible:
    distributetrafficcheck

    ./vfw-sink/latest/ansible/distributetrafficcheck:
    site.yml

    ./vpgn:
    latest

    ./vpgn/latest:
    ansible

    ./vpgn/latest/ansible:
    distributetraffic       distributetrafficcheck

    ./vpgn/latest/ansible/distributetraffic:
    site.yml

    ./vpgn/latest/ansible/distributetrafficcheck:
    site.yml


Configuration of APPC DB for Ansible
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For each VNF that uses the Ansible protocol you need to configure *PASSWORD* and *URL* field in the *DEVICE_AUTHENTICATION* table. This step must be performed after configuration in CDT which populates data in *DEVICE_AUTHENTICATION* table.

1. Enter the APPC DB container

::

    kubectl exec -it -n onap `kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep appc-db-0` -- sh

2. Enter the APPC DB CLI (password is *gamma*)

::

    mysql -u sdnctl -p

3. Execute the following SQL commands

::

    MariaDB [(none)]> use sdnctl;
    MariaDB [sdnctl]> UPDATE DEVICE_AUTHENTICATION SET URL = 'http://appc-ansible-server:8000/Dispatch' WHERE ACTION LIKE 'DistributeTraffic%';
    MariaDB [sdnctl]> UPDATE DEVICE_AUTHENTICATION SET PASSWORD = 'admin' WHERE ACTION LIKE 'DistributeTraffic%';
    MariaDB [sdnctl]> select * from DEVICE_AUTHENTICATION;

Result should be simmilar to the following one:

::

    +--------------------------+------------------------------------------------------+----------+------------------------+-----------+----------+-------------+------------------------------------------+
    | DEVICE_AUTHENTICATION_ID | VNF_TYPE                                             | PROTOCOL | ACTION                 | USER_NAME | PASSWORD | PORT_NUMBER | URL                                      |
    +--------------------------+------------------------------------------------------+----------+------------------------+-----------+----------+-------------+------------------------------------------+
    |                      137 | vFWDT 2019-05-20 21:10:/vFWDT_vPKG a646a255-9bee 0   | ANSIBLE  | DistributeTraffic      | admin     | admin    |        8000 | http://appc-ansible-server:8000/Dispatch |
    |                      143 | vFWDT 2019-05-20 21:10:/vFWDT_vFWSNK b463aa83-b1fc 0 | ANSIBLE  | DistributeTraffic      | admin     | admin    |        8000 | http://appc-ansible-server:8000/Dispatch |
    |                      149 | vFWDT 2019-05-20 21:10:/vFWDT_vFWSNK b463aa83-b1fc 0 | ANSIBLE  | DistributeTrafficCheck | admin     | admin    |        8000 | http://appc-ansible-server:8000/Dispatch |
    |                      152 | vFWDT 2019-05-20 21:10:/vFWDT_vPKG a646a255-9bee 0   | ANSIBLE  | DistributeTrafficCheck | admin     | admin    |        8000 | http://appc-ansible-server:8000/Dispatch |
    +--------------------------+------------------------------------------------------+----------+------------------------+-----------+----------+-------------+------------------------------------------+
    4 rows in set (0.00 sec)


Testing Traffic Distribution Workflow
-------------------------------------

Since all the configuration of components of ONAP is already prepared it is possible to enter second phase of Traffic Distribution Workflow execution - 
the execution of DistributeTraffic and DistributeTrafficCheck LCM actions with configuration resolved before by OptimizationFramework. 


Workflow Execution
~~~~~~~~~~~~~~~~~~

In order to run Traffic Distribution Workflow execute following commands from the vFWDT tutorial directory `Preparation of Workflow Script Environment`_ on Rancher server.

::

    cd workflow
    python3 workflow.py 909d396b-4d99-4c6a-a59b-abe948873303 10.12.5.217 10.12.5.63 True False False True


The order of executed LCM actions is following:

1. DistributeTrafficCheck on vPKG VM - ansible playbook checks if traffic destinations specified by OOF is not configued in the vPKG and traffic does not go from vPKG already.
   If vPKG send alreadyt traffic to destination the playbook will fail and workflow will break.
2. DistributeTraffic on vPKG VM - ansible playbook reconfigures vPKG in order to send traffic to destination specified before by OOF. When everything is fine at this stage
   change of the traffic should be observed on following dashboards (please turn on automatic reload of graphs)

    ::
        
        http://<vSINK-1-IP>:667/
        http://<vSINK-2-IP>:667/

3. DistributeTrafficCheck on vFW-1 VM - ansible playbook checks if traffic is not present on vFW from which traffic should be migrated out. If traffic is still present after 30 seconds playbook fails
4. DistributeTrafficCheck on vFW-2 VM - ansible playbook checks if traffic is present on vFW from which traffic should be migrated out. If traffic is still not present after 30 seconds playbook fails


Workflow Results
~~~~~~~~~~~~~~~~

Expected result of workflow execution, when everythin is fine, is following:

::

    Distribute Traffic Workflow Execution:
    APPC REQ 0 - DistributeTrafficCheck
    Request Accepted. Receiving result status...
    Checking LCM DistributeTrafficCheck Status
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    SUCCESSFUL
    APPC REQ 1 - DistributeTraffic
    Request Accepted. Receiving result status...
    Checking LCM DistributeTraffic Status
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    SUCCESSFUL
    APPC REQ 2 - DistributeTrafficCheck
    Request Accepted. Receiving result status...
    Checking LCM DistributeTrafficCheck Status
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    SUCCESSFUL
    APPC REQ 3 - DistributeTrafficCheck
    Request Accepted. Receiving result status...
    Checking LCM DistributeTrafficCheck Status
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    SUCCESSFUL

In case of failure the result can be following:

::

    Distribute Traffic Workflow Execution:
    APPC REQ 0 - DistributeTrafficCheck
    Request Accepted. Receiving result status...
    Checking LCM DistributeTrafficCheck Status
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    IN_PROGRESS
    FAILED
    Traceback (most recent call last):
    File "workflow.py", line 563, in <module>
        sys.argv[5].lower() == 'true', sys.argv[6].lower() == 'true')
    File "workflow.py", line 557, in execute_workflow
        confirm_appc_lcm_action(onap_ip, req, check_result)
    File "workflow.py", line 529, in confirm_appc_lcm_action
        raise Exception("LCM {} {} - {}".format(req['input']['action'], status['status'], status['status-reason']))
    Exception: LCM DistributeTrafficCheck FAILED - FAILED

.. note:: When CDT and Ansible is configured properly Traffic Distribution Workflow can fail when you pass as a vnf-id argument the ID of vFW VNF which does not handle traffic at the moment. To solve that pass the VNF ID of the other vFW VNF instance. Because of the same reason you cannot execute twice in a row workflow for the same VNF ID if first execution succedds.
