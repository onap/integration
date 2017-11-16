*** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           json

# http://localhost:8000/vvp/v1/engmgr/vendors
# vvp-engagementmgr

*** Test Cases ***
Get Requests health check ok
    [Tags]    get
    CreateSession    vvp-engagementmgr    http://localhost:8000
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=    Get Request    vvp-engagementmgr    /vvp/v1/engmgr/vendors    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    @{ITEMS}=    Copy List    ${resp.json()}
    : FOR    ${ELEMENT}    IN    @{ITEMS}
    \    Log    ${ELEMENT['uuid']} ${ELEMENT['name']}
