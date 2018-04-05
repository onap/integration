*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${MESSAGE}    Test

*** Test Cases ***
Create vCPE_HPA Service
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}create_vcpe_hpa_service.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    # Is the POST endpoint to create a service this? "/ecomp/mso/infra/e2eServiceInstances/v3"
    ${resp}=    Post Request    refrepo    /ecomp/mso/infra/e2eServiceInstances/v3    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

# How to call this mocked OOF API from inside the SO container?
Mock OOF API
    [Documentation]        Check /oof endpoint
    Create Session         hello              http://${REPO_IP}:8080
    CheckUrl               hello              /oof
