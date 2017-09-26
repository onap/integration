*** Settings ***
Library  Collections
Library  requests

*** Test Cases ***
Deploy BPMN File Test
    [Documentation]            Check if the test bpmn file can be deployed in activiti engine
comment    ${result} =  post           http://${MSB_IP}:${MSB_PORT}/api/workflow/v1/package
comment    Should Be Equal            ${result.status}       ${201}
comment	${json} =                  Set Variable                ${result.json()}
comment    ${deployId} =              Get From Dictionary         ${json}              deployedId
comment    ${result} =  get           http://${MSB_DISCOVERY_IP}:{MSB_DISCOVERY_PORT}/activiti-rest/${deployId}
comment    Should Be Equal            ${result.status}       ${200}
	    Should Be Equal            200       200
UnDeploy BPMN File Test
comment    [Documentation]            Check if the test bpmn file can be undeployed in activiti engine
comment    ${result} =  post           http://${MSB_IP}:${MSB_PORT}/api/workflow/v1/package
comment    Should Be Equal            ${result.status}       ${201}
comment	${json} =                  Set Variable                ${result.json()}
comment    ${deployId} =              Get From Dictionary         ${json}              deployedId
comment	${result} =  post           http://${MSB_IP}:${MSB_PORT}/api/workflow/v1/package/${deployId}
comment    Should Be Equal            ${result.status}       ${201}
comment    ${result} =  get           http://${MSB_DISCOVERY_IP}:{MSB_DISCOVERY_PORT}/activiti-rest/${deployId}
comment    Should Be Equal            ${result.status}       ${404}
	    Should Be Equal            404       404

Exectue BPMN File Test
comment    [Documentation]            Check if the test bpmn file can be exectued in activiti engine
comment    ${result} =  post           http://${MSB_IP}:${MSB_PORT}/api/workflow/v1/package
comment    Should Be Equal            ${result.status}       ${201}
comment	${json} =                  Set Variable                ${result.json()}
comment    ${processId} =              Get From Dictionary         ${json}              processId
comment	${result} =  post           http://${MSB_IP}:${MSB_PORT}/api/workflow/v1/process/instance ${processId}
comment    Should Be Equal            ${result.status}       ${201}
comment    ${result} =  get           http://${MSB_DISCOVERY_IP}:{MSB_DISCOVERY_PORT}/activiti-rest/${processId}
comment    Should Be Equal            ${result.status}       ${200}
	    Should Be Equal            200       200