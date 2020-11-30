.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_CM_flexible_designer_orchestrator:

:orphan:

Dublin Workflow Designer Release Notes
--------------------------------------

The Workflow Editor was developed in the Beijing release by Amdocs and
is available in SDC for users to create workflows.

NOTE: For the Dublin release only FlowCompleteActivity, Set/UnSet
InMaint Flags Building Blocks were tested. Testing for the other
Building Blocks for an InPlaceSWUpdate will be tested in the El Alto
release.

Building Blocks Available
~~~~~~~~~~~~~~~~~~~~~~~~~~

The following building blocks will be visible in the SDC Workflow
Designer Editor. Those that were tested are marked with an “\*”. Those
that are unmarked were not tested.

-  VNFSetInMaintFlagActivity  \*

-  VNFUnsetInMaintFlagActivity  \*                     

-  FlowCompleteActivity \*                 

-  VNFCheckInMaintFlagActivity  

-  PauseForManualTaskActivity            

-  VNFCheckClosedLoopDisabledFlagActivity      

-  VNFCheckPserversLockedFlagActivity    

-  VNFHealthCheckActivity                

-  VnfInPlaceSoftwareUpdate             

-  VNFLockActivity                      

-  VNFQuiesceTrafficActivity             

-  VNFResumeTrafficActivity              

-  VNFSetClosedLoopDisabledFlagActivity  

-  VNFSnapShotActivity                   

-  VNFStartActivity                      

-  VNFStopActivity                       

-  VNFUnlockActivity                     

-  VNFUnsetClosedLoopDisabledFlagActivity

-  VNFUpgradeBackupActivity              

-  VNFUpgradePostCheckActivity  

-  VNFUpgradePreCheckActivity 

-  VNFUpgradeSoftwareActivity

-  DistributeTrafficActivity Check Release Notes for this BB

-  DistributeTrafficCheckActivity   Check Release Notes for this BB

Pre-Workflow Execution
~~~~~~~~~~~~~~~~~~~~~~

1. Users must ensure that the required Ansible scripts are available and
   loaded the appropriate Ansible server prior to attempting to execute
   a workflow. Building blocks for InPlaceSWUpgrade that require Ansible
   Scripts include:

-  VNFUpgradePreCheck,

-  VNFUpgradeSoftware,

-  VNFUpgradePostCheck,

1. If a building block exists in SO and is not showing up in the SDC
   Workflow Designer (WFD), activities can be manually uploaded by
   following instructions in the Change Managmenet Extension Release
   Notes for CasaBlanca. This was tested and SO is expected to
   automatically push the activities/BuildingBlocks (BBs) to SDC.

2. User must create a workflow, attach it to the vNF model. It is
   recommended that they test it in a test environment prior to
   executing in a production environment.

3. NOTE: The workflow distribution mechanism was working until after
   Dublin code freeze in the test environment. Since we are not sure if
   something broke, we are including instructions in to manually upload
   the WF to SO. The Steps to upload a BPMN directly to SO are:

    | - populate\_wfd\_tbl.sh ,
    | - workflow\_template.xml
    | - workflowtbl.sql
    | It is recommended that the user cleanup the workflow tables. The
      Sqls to do so are in
    | -<cleanup\_rerun.txt.>.

    Here are the steps to populate the wfd tables

    A. Create an absolute path directory

    This will be the directory where the files and the scripts reside
    for populating the WFD tables.

    Eg: /home/uid/workflows

    B. Save the following files into the directory created in step 1
    (eg:/home/uid/workflows)

    populate\_wfd\_tbl.sh ,

    workflow\_template.xml ,

    WorkflowSample.bpmn,

    workflowtbl.sql

    C. Change the user, password, and db in populate\_wfd\_tbl.sh

    EG: mysql -u<user> -p<password> -D<schema>

    In the script right now we used user=root, password=password,
    schema=catalogdb

                                 

    D. Create your workflow bpmn (WorkflowSample.bpmn provided as a
    sample)

    Attributes from the workflow bpmn created for testing are used in
    the workflow\_template.xml file so that the related WFD tables are
    populated.

    E. Edit the Workflow\_template.xml based on your workflow bpm that
    you have created.

    Template is populated with sample values as examples.

    <?xml version="1.0" encoding="UTF-8"?>

    <workflow-template>

      <workflow ARTIFACT\_UUID="a90f8eaa-7c20-422f-8c81-aacbca6fb9e7"
    ARTIFACT\_NAME="workflowSample.bpmn" NAME="workflowSample.bpmn"
    OPERATION\_NAME="inPlaceSoftwareUpdate"

      VERSION="1.0" DESCRIPTION="Workflow Artifact Description" BODY=""
    RESOURCE\_TARGET="VNF" SOURCE="SDC" TIMEOUT\_MINUTES="120"

      ARTIFACT\_CHECKSUM="ZjUzNjg1NDMyMTc4MWJmZjFlNDcyOGQ0Zjc1YWQwYzQ\\u003d">

      </workflow>

    //VNF to be used

      <vnf NAME="abcd-abcd-abcd-abcd-abcd" VERSION="1.0"/>

    //list the activities you are designed in the workflow bpmn and the
    sequence order.

      <activity\_spec\_sequence NAME="VNFSetInMaintFlagActivity"
    VERSION="1.0" SEQUENCE="1"/>

      <activity\_spec\_sequence NAME="VNFUnsetInMaintFlagActivity"
    VERSION="1.0" SEQUENCE="2"/>

      <activity\_spec\_category NAME="VNF"/>

    </workflow-template>

     

    F.  => ./populate\_wfd\_tbl.sh <directory with absolute path that we
    have created in step 1>

    Eg:=> ./populate\_wfd\_tbl.sh '/home/uid/workflows'

1. There is a correction in the code to connect the WF to the vNF in the
   SO table, however, due to environment issues, it was not tested prior
   to code freeze. We do expect it to work, however, in the event that
   it does not, the user needs manually update the SO database to link
   the WF to the vNF by following these instructions.

   a. Login to dev-mariadb-galera-mariadb-galera-0 pod

   b. mysql -ucataloguser -pcatalog123

   c. use catalogdb;

   d. select id from workflow where name = '<your workflow name>;

   e. insert into vnf\_resource\_to\_workflow
      (‘VNF\_RESOURCE\_MODEL\_UUID’, ‘WORKFLOW\_ID’)VALUES (‘<model uuid
      of your VNF Resource>’,<workflow id obtained in the query in step
      4>);

Workflow Initiation
~~~~~~~~~~~~~~~~~~~

After creating a workflow, attaching it to the vNF model and
distributing the model, the workflow can now be initiated at the VID
interface by: (Note – a vNF of the same model version must also be
instantiated)

1. Go to VID and Select “vNF Changes” from the left menu.

2. Select the “+ New” icon at the top of the window.

   a. Enter the fields displayed by VID. As selections are made, other
      fields will appear. Any field where the entry “box” turns red when
      selected, is mandatory.

   b. Target Model is displayed but not needed for InPlaceSWUpdate or
      Configupdate WFs

   c. A configuration file must be uploaded to execute the ConfigUpdate
      WF. This input is not used for InPlaceSWUpdate.

   d. Operations Timeout is a mandatory field.

   e. Existing and New SW Version fields are mandatory for
      InPlaceSWUpdate.

3. Available vNF dropdown

   a. To select more than one vNF instance, just select the desired
      instances from the dropdown list. You may select one or many.

   b. To delete a selected vNF instance, click the “X” to the left of
      that instance.

   c. To exit the vNF instance selection mode, click in the blank space
      on the Pop-Up. DO NOT click outside the Pop-Up as this is
      equivalent to clicking <Cancel>.

4. If the workflow desired is not displayed when clicking on the
   Workflow “Box”, it means that the workflow is either not attached to
   the vNF Model Version of the selected instance or the vNF Modell has
   not been distributed and deployed in SO. Go back to steps 3-5 of the
   previous section to correct.

5. Once all fields are populated, select <Confirm> at the bottom of the
   pop-up window to execute the workflow.

6. To cancel your selections, click <Cancel> at the bottom of the pop-up
   window.

Workflow Status
~~~~~~~~~~~~~~~

Once the workflow is initiated, the user can view status of the workflow
by Selecting the Active and Completed TABS.

1. Click the Refresh icon above and to the right of the status table
   being viewed to refresh the data.

2. Click the icon in the status column to view specific status about the
   workflow in that row.

   a. Red icon indicates a failure or issue.

   b. Green icon indicates in Progress or successful completion.

Pause for Manual Task Building Block Handling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Descoped from Dublin. To be tested in El Alto.

Native (Hard Coded) SO Workflows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The user will also see Native (Hard Coded) workflows along with
workflows they create for the selected vNF type in the dropdown menu on
the VID screen when initiating a workflow. These require ansible scripts
and are available to test with your particular vNF. Only Scale out was
part of the Dublin release. The others were not part of the release but
are available to test with your vNF. Please refer to the Scale out
release notes for further information.

https://docs.onap.org/projects/onap-integration/en/frankfurt/docs_scaleout.html
