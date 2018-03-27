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
${generatedAID}
${resultStatus}

*** Test Cases ***
Check Cassandra Docker Container
    [Documentation]    It checks cassandra docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    music-db

Check Zookeeper Docker Container
    [Documentation]    It checks zookeeper docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    music-zk

Check Tomcat Docker Container
    [Documentation]    It checks tomcat docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    music-tomcat

Check Music War Docker Container
    [Documentation]    It checks music.war docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    music-war

Get Music Version
    [Documentation]    It sends a REST GET request to retrieve the Music.war version
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        musicaas   /MUSIC/rest/v2/version     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Check ConductorApi Docker Container
    [Documentation]    It checks conductor-api docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    cond-api

Check ConductorController Docker Container
    [Documentation]    It checks conductor-controller docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    cond-cont

Check ConductorSolver Docker Container
    [Documentation]    It checks conductor-solver docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    cond-solv

Check ConductorReservation Docker Container
    [Documentation]    It checks conductor-reservation docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    cond-resv

Check ConductorData Docker Container
    [Documentation]    It checks conductor-data docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    cond-data

Get Root Url
    [Documentation]    It sends a REST GET request to root url
    Create Session   optf-cond            ${COND_HOSTNAME}:${COND_PORT}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        optf-cond   /     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Conductor AddHealthcheck Row Into Music
    [Documentation]    It sends a REST PUT request to Music to inject healthcheck plan
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}healthcheck.json
    &{headers}=      Create Dictionary    ns=conductor    userId=conductor    password=c0nduct0r   Content-Type=application/json  Accept=application/json
    ${resp}=         Put Request        musicaas   /MUSIC/rest/v2/keyspaces/conductor/tables/plans/rows?id=healthcheck    data=${data}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Integers    ${resp.status_code}    200
    Sleep    5s    Wait Injection effectiveness

Healthcheck
    [Documentation]    It sends a REST GET request to healthcheck url
    Create Session   optf-cond            ${COND_HOSTNAME}:${COND_PORT}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        optf-cond   /v1/plans/healthcheck     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

SendPlanWithWrongVersion
    [Documentation]    It sends a POST request to conductor
    Create Session   optf-cond            ${COND_HOSTNAME}:${COND_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}plan_with_wrong_version.json
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        optf-cond   /v1/plans     data=${data}     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    ${response_json}    json.loads    ${resp.content}
    ${generatedPlanId}=    Convert To String      ${response_json['id']}
    Set Global Variable     ${generatedPlanId}
    Log To Console              generatedPlanId = ${generatedPlanId}
    Should Be Equal As Integers    ${resp.status_code}    201
    Sleep    10s    Wait Plan Resolution

GetPlanWithWrongVersion
    [Documentation]    It sends a REST GET request to capture error
    Create Session   optf-cond            ${COND_HOSTNAME}:${COND_PORT}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        optf-cond   /v1/plans/${generatedPlanId}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    ${response_json}    json.loads    ${resp.content}
    ${resultStatus}=    Convert To String      ${response_json['plans'][0]['status']}
    Set Global Variable     ${resultStatus}
    Log To Console              resultStatus = ${resultStatus}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200
    Should Be Equal    error    ${resultStatus}



SendPlanWithoutDemandSection
    [Documentation]    It sends a POST request to conductor
    Create Session   optf-cond            ${COND_HOSTNAME}:${COND_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}plan_without_demand_section.json
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        optf-cond   /v1/plans     data=${data}     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    ${response_json}    json.loads    ${resp.content}
    ${generatedPlanId}=    Convert To String      ${response_json['id']}
    Set Global Variable     ${generatedPlanId}
    Log To Console              generatedPlanId = ${generatedPlanId}
    Should Be Equal As Integers    ${resp.status_code}    201
    Sleep    10s    Wait Plan Resolution

GetPlanWithoutDemandSection
    [Documentation]    It sends a REST GET request to capture error
    Create Session   optf-cond            ${COND_HOSTNAME}:${COND_PORT}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        optf-cond   /v1/plans/${generatedPlanId}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    ${response_json}    json.loads    ${resp.content}
    ${resultStatus}=    Convert To String      ${response_json['plans'][0]['status']}
    Set Global Variable     ${resultStatus}
    Log To Console              resultStatus = ${resultStatus}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200
    Should Be Equal    error    ${resultStatus}


SendPlanWithLatiAndLongi
    [Documentation]    It sends a POST request to conductor
    Create Session   optf-cond            ${COND_HOSTNAME}:${COND_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}plan_with_lati_and_longi.json
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        optf-cond   /v1/plans     data=${data}     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    ${response_json}    json.loads    ${resp.content}
    ${generatedPlanId}=    Convert To String      ${response_json['id']}
    Set Global Variable     ${generatedPlanId}
    Log To Console              generatedPlanId = ${generatedPlanId}
    Should Be Equal As Integers    ${resp.status_code}    201
    Sleep    60s    Wait Plan Resolution

GetPlanWithLatiAndLongi
    [Documentation]    It sends a REST GET request to capture recommendations
    Create Session   optf-cond            ${COND_HOSTNAME}:${COND_PORT}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        optf-cond   /v1/plans/${generatedPlanId}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    ${response_json}    json.loads    ${resp.content}
    ${resultStatus}=    Convert To String      ${response_json['plans'][0]['status']}
    Set Global Variable     ${resultStatus}
    Log To Console              resultStatus = ${resultStatus}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200
    Should Be Equal    done    ${resultStatus}


*** Keywords ***


