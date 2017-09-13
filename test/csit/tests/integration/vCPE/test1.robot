*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           Process

*** Test Cases ***
SO ServiceInstance health check
    ${SO_IP}=    Run Docker    nexus3.onap.org:10001/openecomp/mso    i-so
    Wait Until Keyword Succeeds    1 min    5 sec    CheckUrl    http://${SO_IP}:8080
    Create Session    refrepo    http://${SO_IP}:8080
    &{headers}=    Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    refrepo    /ecomp/mso/infra/orchestrationRequests/v2    headers=${headers}
    Should Not Contain    ${resp.content}    null
    Kill Docker    i-so

*** Keywords ***
Run Docker
    [Arguments]    ${image}    ${name}    ${parameters}=${EMPTY}
    ${result}=    Run Process    docker run --name ${name} ${parameters} -d ${image}    shell=True
    Log    all output: ${result.stdout}
    ${result}=    Run Process    docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${name}    shell=True
    [Return]    ${result.stdout}

Kill Docker
    [Arguments]    ${name}
    ${result}=    Run Process    docker logs ${name}    shell=True
    ${result}=    Run Process    docker kill ${name}    shell=True
    ${result}=    Run Process    docker rm ${name}    shell=True

CheckUrl
    [Arguments]    ${url}
    Create Session    session    ${url}    disable_warnings=True
    ${resp}=    Get Request    session    /
    Should Be Equal As Integers    ${resp.status_code}    200
