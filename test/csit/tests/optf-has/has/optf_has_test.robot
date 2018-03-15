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


*** Keywords ***


