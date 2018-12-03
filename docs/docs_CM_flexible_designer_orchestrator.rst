.. _docs_CM_flexible_designer_orchestrator: 

Change Management Flexible Designer and Orchestrator  
-----------------------------------------------------------------------------

Description 
~~~~~~~~~~~~~~

The change management flexible designer and orchestrator enables a user to design a change workflow in SDC using a catalog of activities and distribute and deploy the workflow to SO for execution. 

How to Use
~~~~~~~~~~~
To use the flexible designer and orchestrator functionality, one has to execute the following steps: 

1) Activity upload (SO to SDC) 

2) Change workflow design and certification (in SDC) 

3) Change workflow testing (in SDC) 

4) Change workflow distribution and deployment (SDC to SO) 

For steps 2-4, use the ONAP portal: 

https://portal.api.simpledemo.onap.org:30225/ONAPPORTAL/login.htm 

Login in designer: cs0008 

Password for all users is: demo123456!

Activity upload - Source files 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SO Activity Specs: 

https://git.onap.org/so/tree/bpmn/so-bpmn-building-blocks/src/main/resources/ActivitySpec

Activity upload - How to use
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the manual activity spec upload process for now - for every json file in ActivitySpec directory run the curl commands below

Deploy SO Activity Spec to SDC:
curl -X POST http://sdc-wfd-be:8080/v1.0/activity-spec -H "C
ontent-Type: application/json" -d @<activity name>.json

The output will be of the form:{"id":"...","versionId":"..."}

Make a note of id from the output.

Certify SO Activity Spec in SDC:
curl -X PUT "http://sdc-wfd-be:8080/v1.0/activity-spec/<id returned on deployment>/versions/latest/actions" -H  "accept: */*" -H  "Content-Type: application/json" -d "{  \"action\": \"CERTIFY\"}"

Example:

curl -X POST http://sdc-wfd-be:8080/v1.0/activity-spec -H "C
ontent-Type: application/json" -d @VNFUnsetInMaintFlagActivitySpec.json

Output:
{"id":"fad363f616d5422b94fe2351c8b44c48","versionId":"cd6af48e3c8247d2ab7568849d"}
curl -X PUT "http://sdc-wfd-be:8080/v1.0/activity-spec/fad363f616d5422b94fe2351c8b44c48/versions/latest/actions" -H  "accept: */*" -H  "Content-Type: application/json" -d "{  \"action\": \"CERTIFY\"}"

Change workflow design and certification
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1) Go to SDC on the ONAP portal. Use login with role of designer (cs0008)  

2) Disable protection for now 

3) Go to Workflow and click on Add a workflow. Provide a Name and Description for the new workflow. After clicking on Create, it will display a page with General, Input/Output and Composition. In Input/output, provide a NF_id as input and status as output. Save the workflow 

4) Go to Composition and design the new workflow. 

5) Start and End indicates the start and end of the workflow. Add an activity after start. Make it a service event and add an activity using the details option on the right. Select the Activity Spec. 

6) Save the workflow 

7) Certify the workflow. Once certified, the workflow design cannot be changed. If one needs to change it post certification, one can create a new version of the workflow. 

8) Go back to Home and add a VF. Provide a name, category, description, Contact ID, vendor and vendor release for the VF. Save the VF. Go to Operation and Add a new operation. This is the step where you link the workflow to the VF. 

9) Go to Home and add a Service. Provide a name, category, description, contact ID, project Code for the service. Save the service.  Then go to Composition, select the VF previously created. Click on submit for testing. The service is ready for testing. 

Change workflow testing 
~~~~~~~~~~~~~~~~~~~~~~~~~~

1) Switch the user with tester role (jm0007) 

2) In Home, the service would be displayed as Ready for Testing 

3) Click on the service and then start testing. 

4) Click on Accept and provide Certification confirmation. Now the workflow is ready for distribution. 

Change workflow distribution and deployment 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1) Switch the user with governor role (gv0001). Governor is responsible for approving the distribution 

2) Click on the service name and click on Approve. Provide the distribution confirmation comment. This approves the workflow distribution. 

3) Switch the user with operator role (op0001).

4) Click on the service name and then click on Distribution. Click on Distribute to distribute the workflow to SO. Then click on Monitor to check the distribution status. The CSAR along with BPMN is distributed from SDC to SO. 

5) Once distribution is completed from SDC to SO, SO will automatically deploy the workflow. SO automatically makes the workflow ready for execution. 

Known Issues and Resolution 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SO has an issue with workflow validation during execution. 
https://jira.onap.org/browse/SO-1243 
We would be resolving this as a maintenance patch in Casablanca. 
For Casablanca, the workflow design, testing, distribution and deployment have been successfully tested. 

SDC user guide can be found here: https://wiki.onap.org/display/DW/Design