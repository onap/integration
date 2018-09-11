*** Settings ***
Library       DcaeAppSimulatorLibrary

Resource      resources/common-keywords.robot

Suite Setup       Multiple Clients Handling Suite Setup
Suite Teardown    VES-HV Collector Suite Teardown
Test Teardown     VES-HV Collector Test Shutdown

*** Keywords ***
Multiple Clients Handling Suite Setup
    Log   Started Suite: VES-HV Multiple Clients Handling
    ${XNF_PORTS_LIST}=    Create List    7000   7001   7002
    Configure xNF Simulators Using Valid Certificates On Ports    ${XNF_PORTS_LIST}
    Log   Suite setup finished

*** Test Cases ***
Handle Multiple Connections
    [Documentation]   VES-HV Collector should handle multiple incoming transmissions

    ${SIMULATORS_LIST}=   Get xNF Simulators Using Valid Certificates   3
    Send Messages From xNF Simulators   ${SIMULATORS_LIST}   ${XNF_SMALLER_PAYLOAD_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_15000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_SMALLER_PAYLOAD_REQUEST}


*** Variables ***
${VES_HV_SCENARIOS}                            %{WORKSPACE}/test/csit/tests/dcaegen2-collectors-hv-ves/testcases/resources/scenarios

${XNF_SMALLER_PAYLOAD_REQUEST}                 ${VES_HV_SCENARIOS}/multiple-simulators-payload/xnf-simulator-smaller-valid-request.json
${DCAE_SMALLER_PAYLOAD_REQUEST}                ${VES_HV_SCENARIOS}/multiple-simulators-payload/dcae-smaller-valid-request.json

${AMOUNT_15000}                                15000
