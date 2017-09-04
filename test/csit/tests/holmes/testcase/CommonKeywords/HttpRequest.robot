*** Settings ***
Library           Collections
Library           RequestsLibrary
Resource          ../RuleMgt/Rule-Keywords.robot

*** Keywords ***
httpPut
    [Arguments]    ${restHost}    ${restUrl}    ${data}
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8    Accept=application/json
    create session    microservices    ${restHost}    ${headers}
    log    ${data}
    ${putResponse}    put request    microservices    ${restUrl}    ${data}    \    ${EMPTY}
    ...    ${headers}
    log    ${putResponse}
    [Return]    ${putResponse}

httpGet
    [Arguments]    ${restHost}    ${restUrl}
    create session    microservices    ${restHost}
    ${getResponse}    get request    microservices    ${restUrl}
    [Return]    ${getResponse}

httpPost
    [Arguments]    ${restHost}    ${restUrl}    ${data}
    ${headers}    create dictionary    Content-Type=application/json    Accept=application/json
    create session    microservices    ${restHost}    ${headers}
    log    ${data}
    ${postResponse}    post request    microservices    ${restUrl}    ${data}
    Comment    log    ${postResponse.content}
    [Return]    ${postResponse}

httpDelete
    [Arguments]    ${restHost}    ${restUrl}    ${data}
    ${headers}    create dictionary    Content-Type=application/json    Accept=application/json
    create session    microservices    ${restHost}    ${headers}
    ${deleteResponse}    delete request    microservices    ${restUrl}    ${data}
    [Return]    ${deleteResponse}
