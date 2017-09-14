*** Settings ***
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Library           OperatingSystem
Library           RequestsLibrary
Library           Process
Library           ../../../../testsuite/python-testing-utils/eteutils/UUID.py

*** Variables ***
${GLOBAL_APPLICATION_ID}    csit-vCPE
${GLOBAL_MSO_USERNAME}    InfraPortalClient
${GLOBAL_MSO_PASSWORD}    password1$

*** Test Cases ***
SO ServiceInstance health check
    ${auth}=    Create List    ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    ${session}=    Create Session    so    http://${SO_IP}:8080
    ${uuid}=    Generate UUID
    ${headers}=    Create Dictionary    Accept=text/html    Content-Type=text/html    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Get Request    so    /ecomp/mso/infra/globalhealthcheck    headers=${headers}
    &{headers}=    Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    so    /ecomp/mso/infra/orchestrationRequests/v2    headers=${headers}
    Should Not Contain    ${resp.content}    null

*** Keywords ***
Run Docker
    [Arguments]    ${image}    ${name}    ${parameters}=${EMPTY}
    ${result}=    Run Process    docker run --name ${name} ${parameters} -d ${image}    shell=True
    Should Be Equal As Integers    ${result.rc}    0
    Log    ${result.stdout}
    ${result}=    Run Process    docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${name}    shell=True
    Should Be Equal As Integers    ${result.rc}    0
    Log    ${result.stdout}
    [Return]    ${result.stdout}

Kill Docker
    [Arguments]    ${name}
    ${result}=    Run Process    docker logs ${name}    shell=True
    Should Be Equal As Integers    ${result.rc}    0
    Log    ${result.stdout}
    ${result}=    Run Process    docker kill ${name}    shell=True
    Should Be Equal As Integers    ${result.rc}    0
    Log    ${result.stdout}
    ${result}=    Run Process    docker rm ${name}    shell=True
    Should Be Equal As Integers    ${result.rc}    0
    Log    ${result.stdout}

CheckUrl
    [Arguments]    ${url}
    Create Session    session    ${url}    disable_warnings=True
    ${resp}=    Get Request    session    /
    Should Be Equal As Integers    ${resp.status_code}    200

Suite Setup
    ${SO_IP}=    Run Docker    nexus3.onap.org:10001/openecomp/mso    i-so
    Wait Until Keyword Succeeds    1 min    5 sec    CheckUrl    http://${SO_IP}:8080
    Set Suite Variable    ${SO_IP}

Suite Teardown
    Kill Docker    i-so
