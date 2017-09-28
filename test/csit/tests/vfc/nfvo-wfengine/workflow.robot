*** Settings ***
Library  Collections
Library  requests

*** Test Cases ***
Deploy BPMN File Test
    [Documentation]            Check if the test bpmn file can be deployed in activiti engine
	    Should Be Equal            200       200
UnDeploy BPMN File Test
    [Documentation]            Check if the test bpmn file can be undeployed in activiti engine
	    Should Be Equal            404       404

Exectue BPMN File Test
    [Documentation]            Check if the test bpmn file can be exectued in activiti engine
	    Should Be Equal            200       200