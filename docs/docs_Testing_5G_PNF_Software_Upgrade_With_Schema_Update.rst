.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

.. _docs_testing_5g_pnf_software_upgrade_with_schema_update:


:orphan:

Testing xNF Software Upgrade in association to schema updates
-------------------------------------------------------------

Description
~~~~~~~~~~~
This procedure only describes the test instruction to upgrade schema of a service instance with at least one PNF resource based on a new onboarding package.

This procedure can be used to upgrade a service instance with more than one PNF resource.

A. Pre-conditions
~~~~~~~~~~~~~~~~~
* A service template with at least one PNF resource has been created in SDC and distributed to run time

* At least one service instance has been instantiated, including PNF registration and configuration, in run time

* This service instance is in health condition

* A new PNF onboarding package, which contains a new software version and new artifacts, is ready for onboarding

* This procedure does not support addition of new PNF resource or deletion of existing PNF resource in the service template.


B. Update and re-distribute the service template:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    The service template must be updated with updated schema information for the PNF resources, and then redistributed to run time.

    1. Update an existing PNF resource artifact and attach the same to an existing service template.

        - url to portal: https://portal.api.simpledemo.onap.org:30225/ONAPPORTAL/login.htm

        - password for users: demo123456!

        - Login as cs0008, go to "ONBOARD", where all the available VSPs and Services are listed.


    2. Follow below mentioned procedure to update VSP and Service.

        - `Update VF/PNF <https://docs.onap.org/en/kohn/guides/onap-user/design/resource-onboarding/index.html#update-vfcs-in-a-vsp-optional>`_

        - `Update Service <https://docs.onap.org/en/kohn/guides/onap-user/design/service-design/index.html#update-service-optional>`_


C. Trigger PNF service level software upgrade with schema update:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Schema update procedure can be triggered manually by invoking appropriate rest end points through the postman client.

    3. Get the service level workflow uuid by fetching all the available workflows from SO:

        - GET http://REPO_IP:SO_PORT/onap/so/infra/workflowSpecifications/v1/workflows

        - From the response, fetch the workflow uuid against the workflow name “ServiceLevelUpgrade”.

        .. image:: files/softwareUpgrade/workflowList.png


    4. Select one service instance which need to be upgraded

        - Retrieve all services instance from AAI using:

        - GET https://REPO_IP:AAI_PORT/business/customers/customer/{global-customer-id}/service-subscriptions/service-subscription/{service-type}/service-instances

        - Select one service instance from the service instance list received from above query.


    5. Get all Service-Model-Version from AAI Using Service-Model-InVariant-UUId:

        - Use the Service-Model-InVariant-UUId from the selected service instance (previous step) as model-invariant-id in this query.

        - GET https://REPO_IP:AAI_PORT/aai/v21/service-design-and-creation/models/model/${model-invariant-id}/model-vers

        - Select one model version Id from the model version list received from above querying. The selected model version Id will be used as the target service model version at upgrade procedure.

        .. image:: files/softwareUpgrade/serviceModelVersions.png


    6. Invoke the service level upgrade workflow to update the schema of xNF resources.

        - Invoke the service level workflow by passing the older version service model id and the service level workflow uuid for “Service Level workflow” fetched in the previous steps.

        - In the body of the POST request, json input needs to be supplied that contains info on the model version to which we are going to trigger the update. (2.0)

        - POST http://REPO_IP:SO_PORT/onap/so/infra/instanceManagement/v1/serviceInstances/${serviceInstanceId}/workflows/${serviceLevel_workflow_uuid}

        - Attaching below a sample request json :

{

  "requestDetails": {

    "subscriberInfo": {

      "globalSubscriberId": "807c7a02-249c-4db8-9fa9-bee973fe08ce"

    },

    "modelInfo": {

      "modelVersion": "2.0",

      "modelVersionId": "8351245d-50da-4695-8756-3a22618377f7",

      "modelInvariantId": "fe41489e-1563-46a3-b90a-1db629e4375b",

      "modelName": "Service_with_pnfs",

      "modelType": "service"

    },

    "requestInfo": {

      "suppressRollback": false,

      "requestorId": "demo",

      "instanceName": "PNF 2",

      "source": "VID"

    },

    "requestParameters": {

      "subscriptionServiceType": "pNF",

      "userParams": [

        {

          "name": "targetSoftwareVersion",

          "value": "pnf_sw_version-4.0.0"

        }

      ],

      "aLaCarte": false,

      "payload": "{\"k1\": \"v1\"}"

    },

    "project": {

      "projectName": "ServiceLevelUpgrade"

    },

    "owningEntity": {

      "owningEntityId": "67f2e84c-734d-4e90-a1e4-d2ffa2e75849",

      "owningEntityName": "OE-Test"

    }

  }

}

Note down the request id for the schema update request that can be used in the subsequent steps to track the progress.


    7. Verify the service level upgrade workflow status

        - GET http://REPO_IP:SO_PORT/onap/so/infra/orchestrationRequests/v7/${requestID}

        - Verify the response status code and message for the request id fetched in the previous step.

        - For successful upgrade completion, the response code must be “200” with appropriate success message.


    8. Verify PNF Configuration for Service Level Upgrade from AAI

        - GET https://REPO_IP:AAI_PORT/aai/v16/network/pnfs/pnf/{PNF_NAME}

        - Verify the software version of the pnf resource updated in AAI.

        .. image:: files/softwareUpgrade/verifyPNF.png
