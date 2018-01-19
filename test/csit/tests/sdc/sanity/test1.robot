*** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           json

*** Test Cases ***
Get Requests health check ok
    [Tags]    get
    CreateSession    sdc-be    http://localhost:8080
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=    Get Request    sdc-be    /sdc2/rest/healthCheck    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    500
    @{ITEMS}=    Copy List    ${resp.json()['componentsInfo']}
    : FOR    ${ELEMENT}    IN    @{ITEMS}
    \    Log    ${ELEMENT['healthCheckComponent']} ${ELEMENT['healthCheckStatus']}
