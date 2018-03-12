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


*** Keywords ***

