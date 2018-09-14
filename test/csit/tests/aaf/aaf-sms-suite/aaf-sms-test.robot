*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       json

*** Variables ***
${MESSAGE}    {"ping": "ok"}

#global variables
${generatedDomId}

*** Test Cases ***
SMS Check SMS API Docker Container
    [Documentation]    Checks if SMS docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    nexus3.onap.org:10001/onap/aaf/sms

SMS GetStatus
    [Documentation]    Gets Backend Status
    Create Session   SMS            ${SMS_HOSTNAME}:${SMS_PORT}
    &{headers}=      Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        SMS   /v1/sms/quorum/status   headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

SMS CreateDomain
    [Documentation]    Creates a Secret Domain to hold Secrets
    Create Session   SMS            ${SMS_HOSTNAME}:${SMS_PORT}
    ${data}          Get Binary File    ${CURDIR}${/}data${/}create_domain.json
    &{headers}=      Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        SMS   /v1/sms/domain   data=${data} headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    ${response_json}    json.loads    ${resp.content}
    ${generatedDomId}=    Convert To String      ${response_json['uuid']}
    Set Global Variable     ${generatedDomId}
    Should Be Equal As Integers    ${resp.status_code}    201

SMS CreateSecret
    [Documentation]  Create A Secret within the Domain
    Create Session   SMS            ${SMS_HOSTNAME}:${SMS_PORT}
    ${data}          Get Binary File    ${CURDIR}${/}data${/}create_secret.json
    &{headers}=      Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request       SMS   /v1/sms/domain/${generatedDomId}/secret   data=${data}  headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    201

SMS ListSecret
    [Documentation]    Lists all Secret Names within Domain
    Create Session   SMS            ${SMS_HOSTNAME}:${SMS_PORT}
    &{headers}=      Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        SMS   /v1/sms/domain/${generatedDomId}/secret   headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

SMS GetSecret
    [Documentation]    Gets a single Secret with Values from Domain
    Create Session   SMS            ${SMS_HOSTNAME}:${SMS_PORT}
    &{headers}=      Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        SMS   /v1/sms/domain/${generatedDomId}/secret/curltestsecret1   headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

SMS DeleteSecret
    [Documentation]    Deletes a Secret referenced by Name from Domain
    Create Session   SMS            ${SMS_HOSTNAME}:${SMS_PORT}
    &{headers}=      Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=         Delete Request        SMS   /v1/sms/domain/${generatedDomId}/secret/curltestsecret1   headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    204

SMS DeleteDomain
    [Documentation]    Deletes a Domain referenced by Name
    Create Session   SMS            ${SMS_HOSTNAME}:${SMS_PORT}
    &{headers}=      Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=         Delete Request        SMS   /v1/sms/domain/${generatedDomId}   headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    204

*** Keywords ***
