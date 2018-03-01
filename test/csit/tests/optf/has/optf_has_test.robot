*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       json

*** Variables ***
${MESSAGE}    {"ping": "ok"}
${RESP_STATUS}     "error"
${RESP_MESSAGE_WRONG_VERSION}    "conductor_template_version must be one of: 2016-11-01"
${RESP_MESSAGE_WITHOUT_DEMANDS}    Undefined Demand

#global variables
${generatedPlanId}

*** Test Cases ***
Get Root Url
    [Documentation]    It sends a REST GET request to root url
    Create Session   optf-cond            ${COND_HOSTNAME}:${COND_PORT}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        optf-cond   /v1/plans/     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200


*** Keywords ***


