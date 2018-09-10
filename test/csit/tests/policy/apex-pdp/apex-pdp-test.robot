*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***

Call Apex Policy
    Create Session   apexSession  http://127.0.0.1:23324   max_retries=3
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}event.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    Put Request    apexSession    /apex/FirstConsumer/EventIn    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
