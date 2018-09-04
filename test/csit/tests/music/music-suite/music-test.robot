*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       json

*** Variables ***
${MESSAGE}    {"ping": "ok"}

#global variables
${generatedAID}

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

Music AddOnBoarding
    [Documentation]    It sends a REST POST request to Music to Onboard a new application
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}onboard.json
    &{headers}=      Create Dictionary    ns=lb7254    userId=music    password=music   Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        musicaas   /MUSIC/rest/v2/admin/onboardAppWithMusic    data=${data}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    ${response_json}    json.loads    ${resp.content}
    ${generatedAID}=    Convert To String      ${response_json['Generated AID']}
    Set Global Variable     ${generatedAID}
    Log To Console              generatedAID = ${generatedAID}
    Should Be Equal As Integers    ${resp.status_code}    200

Music CreateKeyspace
    [Documentation]    It sends a REST POST request to Music to create a new keyspace in Cassandra
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}createkeyspace.json
    &{headers}=      Create Dictionary    ns=lb7254    Authorization=Basic bXVzaWM6bXVzaWM=   aid=${generatedAID}   Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        musicaas   /MUSIC/rest/v2/keyspaces/MusicOnapKeyspace    data=${data}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Music CreateTable
    [Documentation]    It sends a REST POST request to Music to create a new Table in Cassandra
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}createtable.json
    &{headers}=      Create Dictionary    ns=lb7254    Authorization=Basic bXVzaWM6bXVzaWM=   aid=${generatedAID}   Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        musicaas   /MUSIC/rest/v2/keyspaces/MusicOnapKeyspace/tables/MusicOnapTable    data=${data}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Music InsertRow
    [Documentation]    It sends a REST POST request to Music to create a new row in Cassandra
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}insertrow_eventual.json
    &{headers}=      Create Dictionary    ns=lb7254    Authorization=Basic bXVzaWM6bXVzaWM=   aid=${generatedAID}   Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        musicaas   /MUSIC/rest/v2/keyspaces/MusicOnapKeyspace/tables/MusicOnapTable/rows/?row=emp1   data=${data}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Music ReadRowJustInserted
    [Documentation]    It sends a REST GET request to Music to Read the row just inserted in Cassandra
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    &{headers}=      Create Dictionary    ns=lb7254    Authorization=Basic bXVzaWM6bXVzaWM=   aid=${generatedAID}   Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        musicaas   /MUSIC/rest/v2/keyspaces/MusicOnapKeyspace/tables/MusicOnapTable/rows?name=emp1   headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Music UpdateRowInAtomicWay
    [Documentation]    It sends a REST PUT request to Music to create a new row in Cassandra
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}updaterow_atomic.json
    &{headers}=      Create Dictionary    ns=lb7254    Authorization=Basic bXVzaWM6bXVzaWM=   aid=${generatedAID}   Content-Type=application/json  Accept=application/json
    ${resp}=         Put Request        musicaas   /MUSIC/rest/v2/keyspaces/MusicOnapKeyspace/tables/MusicOnapTable/rows?name=emp1   data=${data}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Music ReadRowAfterUpdate
    [Documentation]    It sends a REST GET request to Music to Read the row just inserted in Cassandra
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    &{headers}=      Create Dictionary    ns=lb7254    Authorization=Basic bXVzaWM6bXVzaWM=   aid=${generatedAID}   Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        musicaas   /MUSIC/rest/v2/keyspaces/MusicOnapKeyspace/tables/MusicOnapTable/rows?name=emp1   headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Music DeleteRow
    [Documentation]    It sends a REST DELETE request to Music to delete a row in Cassandra
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}deleterow_eventual.json
    &{headers}=      Create Dictionary    ns=lb7254    Authorization=Basic bXVzaWM6bXVzaWM=   aid=${generatedAID}   Content-Type=application/json  Accept=application/json
    ${resp}=         Delete Request        musicaas   /MUSIC/rest/v2/keyspaces/MusicOnapKeyspace/tables/MusicOnapTable/rows?name=emp1   data=${data}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Music DropTable
    [Documentation]    It sends a REST Delete request to Music to drop one existing Table in Cassandra
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}droptable.json
    &{headers}=      Create Dictionary    ns=lb7254    Authorization=Basic bXVzaWM6bXVzaWM=   aid=${generatedAID}   Content-Type=application/json   Accept=application/json
    ${resp}=         Delete Request        musicaas   /MUSIC/rest/v2/keyspaces/MusicOnapKeyspace/tables/MusicOnapTable    data=${data}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Music DropKeyspace
    [Documentation]    It sends a REST DELETE request to Music to drop one existing keyspace in Cassandra
    Create Session   musicaas            ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}dropkeyspace.json
    &{headers}=      Create Dictionary    ns=lb7254    Authorization=Basic bXVzaWM6bXVzaWM=   aid=${generatedAID}   Content-Type=application/json   Accept=application/json
    ${resp}=         Delete Request        musicaas   /MUSIC/rest/v2/keyspaces/MusicOnapKeyspace    data=${data}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200


Music DeleteOnBoarding
    [Documentation]    It sends a REST DELETE request to Music to remove a previosly onboarded application
    Create Session   musicaas             ${MUSIC_HOSTNAME}:${MUSIC_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}onboard.json
    &{headers}=      Create Dictionary    ns=lb7254    Authorization=Basic bXVzaWM6bXVzaWM=   aid=${generatedAID}   Content-Type=application/json   Accept=application/json
    ${resp}=         Delete Request        musicaas   /MUSIC/rest/v2/admin/onboardAppWithMusic    data=${data}    headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200


*** Keywords ***

