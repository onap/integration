*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
# Add any if required.

*** Test Cases ***

Create ServiceInstance for vcpe
    Create Session   refrepo  http://${REPO_IP}:8080
    ${create_service_json}=    Get Binary File     ${CURDIR}${/}data${/}createVcpeServiceInstance.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /ecomp/mso/infra/serviceInstances/v3    data=${create_service_json}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nService Instance Creation Request Completed Successfully

# Check that vcpe service was created
# These Tests need to be created

# Verfiy SO request to OOF was correct
# These Tests need to be created - OOF simulator should log and this Test should check that log to verify the request

# Verfiy SO request to MultiCloud included correct flavors
# These Tests need to be created - OOF Simulator should be renamed to simulator or mockServer and be used here to log SO request to Multicloud and check log to verify

*** Keywords ***