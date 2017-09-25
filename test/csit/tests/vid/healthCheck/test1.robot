*** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           json

*** Test Cases ***
Get Requests health check ok
    [Tags]    get
    CreateSession    vid    http://localhost:8080
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=    Get Request    vid    /vid/healthCheck    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    Log to console   statusCode: ${resp.json()['statusCode']}
    Should Be Equal As Strings  ${resp.json()['statusCode']}  200    
