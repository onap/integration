*** Settings ***
Resource          ../../common.robot
Library           Collections
Library           json
Library           OperatingSystem
Library           RequestsLibrary
Library           HttpLibrary.HTTP

*** Variables ***
${MSB_IP}         127.0.0.1
${MSB_PORT}       10550
${ACTIVITI_IP}    127.0.0.1
${ACTIVITI_PORT}    8804
${MGRSERVICE_IP}    127.0.0.1
${MGRSERVICE_PORT}    8805
${processId}      demo
${deployid}       0
${bmpfilepath}    ${SCRIPTS}/nfvo-wfengine/demo.bpmn20.xml

*** Test Cases ***
Deploy BPMN File Test On Activiti
    [Documentation]    Check if the test bpmn file can be deployed in activiti engine
    ${auth}=    Create List    kermit    kermit
    ${headers}=    Create Dictionary    Accept=application/json
    Create Session    web_session    http://${ACTIVITI_IP}:${ACTIVITI_PORT}    headers=${headers}    auth=${auth}
    ${files}=    evaluate    {"file":open('${bmpfilepath}','rb')}
    ${resp}=    Post Request    web_session    /activiti-rest/service/repository/deployments    files=${files}
    Should Be Equal    ${resp.status_code}    ${201}
    Log    ${resp.json()}
    ${deployedId}=    Set Variable    ${resp.json()["id"]}
    Set Global Variable    ${deployedId}

Exectue BPMN File Testt On Activiti
    [Documentation]    Check if the test bpmn file can be exectued in activiti engine
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json    Authorization=Basic a2VybWl0Omtlcm1pdA==
    Create Session    web_session    http://${ACTIVITI_IP}:${ACTIVITI_PORT}    headers=${headers}
    ${body}    Create Dictionary    processDefinitionKey=${processId}
    ${body}    dumps    ${body}
    ${resp}=    Post Request    web_session    /activiti-rest/service/runtime/process-instances    ${body}
    Should Be Equal    ${resp.status_code}    ${201}

UnDeploy BPMN File Testt On Activiti
    [Documentation]    Check if the test bpmn file can be undeployed in activiti engine
    log    ${deployedId}
    ${auth}=    Create List    kermit    kermit
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${ACTIVITI_IP}:${ACTIVITI_PORT}    headers=${headers}    auth=${auth}
    ${resp}=    Delete Request    web_session    /activiti-rest/service/repository/deployments/${deployedId}?cascade=true
    Should Be Equal    ${resp.status_code}    ${204}

Deploy BPMN File Test On MgrService
    [Documentation]    Check if the test bpmn file can be deployed in Management Service
    ${auth}=    Create List    kermit    kermit
    ${headers}=    Create Dictionary    Accept=application/json
    Create Session    web_session    http://${MGRSERVICE_IP}:${MGRSERVICE_PORT}    headers=${headers}    auth=${auth}
    ${files}=    evaluate    {"file":open('${bmpfilepath}','rb')}
    ${resp}=    Post Request    web_session    api/workflow/v1/package    files=${files}
    Should Be Equal    ${resp.status_code}    ${200}
    Log    ${resp.json()}
    ${deployedId}=    Set Variable    ${resp.json()["deployedId"]}
    Set Global Variable    ${deployedId}

Exectue BPMN File Testt On MgrService
    [Documentation]    Check if the test bpmn file can be exectued in Management Service
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json    Authorization=Basic a2VybWl0Omtlcm1pdA==
    Create Session    web_session    http://${MGRSERVICE_IP}:${MGRSERVICE_PORT}    headers=${headers}
    ${body}    Create Dictionary    processDefinitionKey=${processId}
    ${body}    dumps    ${body}
    ${resp}=    Post Request    web_session    api/workflow/v1/process/instance    ${body}
    Should Be Equal    ${resp.status_code}    ${200}
    Log    ${resp.json()}
    Should Be Equal    ${resp.json()["processDefinitionKey"]}    ${processId}

UnDeploy BPMN File Testt On MgrService
    [Documentation]    Check if the test bpmn file can be undeployed in Management Service
    log    ${deployedId}
    ${auth}=    Create List    kermit    kermit
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MGRSERVICE_IP}:${MGRSERVICE_PORT}    headers=${headers}    auth=${auth}
    ${resp}=    Delete Request    web_session    /api/workflow/v1/package/${deployedId}
    Should Be Equal    ${resp.status_code}    ${200}

Deploy BPMN File Test On MSB
    [Documentation]    Check if the test bpmn file can be deployed in activiti engine
    ${auth}=    Create List    kermit    kermit
    ${headers}=    Create Dictionary    Accept=application/json
    Create Session    web_session    http://${MSB_IP}:${MSB_PORT}    headers=${headers}    auth=${auth}
    ${files}=    evaluate    {"file":open('${bmpfilepath}','rb')}
    ${resp}=    Post Request    web_session    api/workflow/v1/package    files=${files}
    Should Be Equal    ${resp.status_code}    ${200}
    Log    ${resp.json()}
    ${deployedId}=    Set Variable    ${resp.json()["deployedId"]}
    Set Global Variable    ${deployedId}

# Exectue BPMN File Testt On MSB
#     [Documentation]    Check if the test bpmn file can be exectued in MSB
#     ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json    Authorization=Basic a2VybWl0Omtlcm1pdA==
#     Create Session    web_session    http://${MSB_IP}:${MSB_PORT}    headers=${headers}
#     ${body}    Create Dictionary    processDefinitionKey=${processId}
#     ${body}    dumps    ${body}
#     ${resp}=    Post Request    web_session    api/workflow/v1/process/instance    ${body}
#     Should Be Equal    ${resp.status_code}    ${200}
#     Log    ${resp.json()}
#     Should Be Equal    ${resp.json()["processDefinitionKey"]}    ${processId}

# UnDeploy BPMN File Testt On MSB
#     [Documentation]    Check if the test bpmn file can be undeployed in MSB
#     log    ${deployedId}
#     ${auth}=    Create List    kermit    kermit
#     ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
#     Create Session    web_session    http://${MSB_IP}:${MSB_PORT}    headers=${headers}    auth=${auth}
#     ${resp}=    Delete Request    web_session    /api/workflow/v1/package/${deployedId}
#     Should Be Equal    ${resp.status_code}    ${200}
