*** Settings ***
Library       DcaeAppSimulatorLibrary

Resource      resources/common-keywords.robot

Suite Setup       Client Authorization Suite Setup
Suite Teardown    VES-HV Collector Suite Teardown
Test Teardown     VES-HV Collector Test Shutdown

*** Keywords ***
Client Authorization Suite Setup
    Log   Started Suite: VES-HV Client Authorization
    ${XNF_PORTS_LIST}=    Create List    7000
    Configure Invalid xNF Simulators On Ports    ${XNF_PORTS_LIST}
    Log   Suite setup finished


*** Test Cases ***
Authorization
    [Documentation]   VES-HV Collector should not authorize XNF with invalid certificate and not route any message
    ...               to topics

    ${SIMULATORS_LIST}=   Get Invalid xNF Simulators   1
    Send Messages From xNF Simulators   ${SIMULATORS_LIST}   ${XNF_VALID_MESSAGES_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_0}


*** Variables ***
${VES_HV_SCENARIOS}                            %{WORKSPACE}/test/csit/tests/dcaegen2-collectors-hv-ves/testcases/resources/scenarios

${XNF_VALID_MESSAGES_REQUEST}                  ${VES_HV_SCENARIOS}/authorization/xnf-valid-messages-request.json

${AMOUNT_0}                                    0
