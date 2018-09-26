*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       json

*** Variables ***
${MESSAGE}    {"ping": "ok"}
${RESP_STATUS}     "error"
${resultStatus}
${placement_user} =  test
${placement_passwd} =  testpwd
${pciopt_user} =  pci_test
${pciopt_passwd} =  pci_testpwd

*** Test Cases ***
Check OSDF_SIM Docker Container
    [Documentation]    It checks osdf_simulator docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    osdf_sim

Check OSDF Docker Container
    [Documentation]    It checks optf-osdf docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    optf-osdf

Healthcheck
    [Documentation]    It sends a REST GET request to healthcheck url
    Create Session   optf-osdf            ${OSDF_HOSTNAME}:${OSDF_PORT}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Get Request        optf-osdf   /api/oof/v1/healthcheck     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

SendPlacementWithInvalidAuth
    [Documentation]    It sends a POST request to osdf fail authentication
    Create Session   optf-osdf            ${OSDF_HOSTNAME}:${OSDF_PORT}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}placement_request.json
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        optf-osdf   /api/oof/v1/placement     data=${data}     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Integers    ${resp.status_code}    401

SendPlacementWithValidAuth
    [Documentation]    It sends a POST request to osdf with correct authentication
    ${auth}=    Create List    ${placement_user}    ${placement_passwd}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    Create Session   optf-osdf            ${OSDF_HOSTNAME}:${OSDF_PORT}    headers=${headers}   auth=${auth}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}placement_request.json

    ${resp}=         Post Request        optf-osdf   /api/oof/v1/placement     data=${data}     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Integers    ${resp.status_code}    202

SendPCIOptimizationWithAuth
    [Documentation]    It sends a POST request PCI Optimization service
    ${auth}=    Create List    ${pciopt_user}   ${pciopt_passwd}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    Create Session   optf-osdf            ${OSDF_HOSTNAME}:${OSDF_PORT}    headers=${headers}   auth=${auth}
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}pci-opt-request.json

    ${resp}=         Post Request        optf-osdf   /api/oof/v1/pci     data=${data}     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Integers    ${resp.status_code}    401





