*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${MESSAGE}    Hello, world!

*** Test Cases ***

Call Apex Policy
    Create Session   refrepo  http://${REPO_IP}:23324   max_retries=10
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}activateService.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    Put Request    refrepo    /apex/FirstConsumer/EventIn    data=${data}   headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result
