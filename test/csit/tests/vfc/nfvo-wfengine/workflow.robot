*** Settings ***
Library  Collections
Library  requests

*** Test Cases ***
Deploy BPMN File Test
    [Documentation]            Check if the test bpmn file can be deployed in activiti engine
    ${result} =  post           http://${MSB_IP}:${MSB_PORT}/api/workflow/v1/package
    Should Be Equal            ${result.status}       ${201}
	${json} =                  Set Variable                ${result.json()}
    ${deployId} =              Get From Dictionary         ${json}              deployedId
    ${result} =  get           http://${MSB_DISCOVERY_IP}:{MSB_PORT}/activiti-rest/${deployId}
    Should Be Equal            ${result.status}       ${200}
	
UnDeploy BPMN File Test
    [Documentation]            Check if the test bpmn file can be undeployed in activiti engine
    ${result} =  post           http://${MSB_IP}:${MSB_PORT}/api/workflow/v1/package
    Should Be Equal            ${result.status}       ${201}
	${json} =                  Set Variable                ${result.json()}
    ${deployId} =              Get From Dictionary         ${json}              deployedId
	${result} =  post           http://${MSB_IP}:${MSB_PORT}/api/workflow/v1/package/${deployId}
    Should Be Equal            ${result.status}       ${201}
    ${result} =  get           http://${MSB_DISCOVERY_IP}:{MSB_PORT}/activiti-rest/${deployId}
    Should Be Equal            ${result.status}       ${404}

Exectue BPMN File Test
    [Documentation]            Check if the test bpmn file can be exectued in activiti engine
    ${result} =  post           http://${MSB_IP}:${MSB_PORT}/api/workflow/v1/package
    Should Be Equal            ${result.status}       ${201}
	${json} =                  Set Variable                ${result.json()}
    ${processId} =              Get From Dictionary         ${json}              processId
	${result} =  post           http://${MSB_IP}:${MSB_PORT}/api/workflow/v1/process/instance ${processId}
    Should Be Equal            ${result.status}       ${201}
    ${result} =  get           http://${MSB_DISCOVERY_IP}:{MSB_PORT}/activiti-rest/${processId}
    Should Be Equal            ${result.status}       ${200}