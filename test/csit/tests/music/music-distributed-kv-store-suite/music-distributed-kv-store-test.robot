*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       json

Check Distributed KV Store API Docker Container
    [Documentation]    Checks if DKV docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    nexus3.onap.org:10003/onap/music/distributed-kv-store

DKV LoadDefaultProperties
    [Documentation]    Loads default configuration files into Consul
    Create Session   dkv            ${DKV_HOSTNAME}:${DKV_PORT}
    &{headers}=      Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        dkv   /v1/config/load-default   headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200


*** Keywords ***
