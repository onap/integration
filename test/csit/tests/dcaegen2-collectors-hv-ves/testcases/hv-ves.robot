*** Settings ***
Library    DcaeAppSimulatorLibrary
Library       XnfSimulatorLibrary
Library       VesHvContainersUtilsLibrary
Library       Collections

Suite Setup       Message Routing Suite Setup
Suite Teardown    VES-HV Collector Suite Teardown
Test Teardown     VES-HV Collector Test Shutdown

*** Test Cases ***
Correct Messages Routing
    [Documentation]   VES-HV Collector should route all valid messages to topics specified in configuration
    ...               and do not change message payload generated in XNF simulator

    ${SIMULATORS_LIST}=   Get xNF Simulators   1
    Send Messages From xNF Simulators   ${SIMULATORS_LIST}   ${XNF_FIXED_PAYLOAD_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_25000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_FIXED_PAYLOAD_REQUEST}


Too big payload message handling
    [Documentation]   VES-HV Collector should interrupt the stream when encountered message with too big payload

    ${SIMULATORS_LIST}=   Get xNF Simulators   1
    Send Messages From xNF Simulators   ${SIMULATORS_LIST}   ${XNF_TOO_BIG_PAYLOAD_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed Less Equal Than   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_25000}


Invalid wire frame message handling
    [Documentation]  VES-HV Collector should skip messages with invalid wire frame

    ${SIMULATORS_LIST}=   Get xNF Simulators   1
    Send Messages From xNF Simulators   ${SIMULATORS_LIST}   ${XNF_INVALID_WIRE_FRAME_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_50000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_INVALID_WIRE_FRAME_REQUEST}


Invalid GPB data message handling
    [Documentation]   VES-HV Collector should skip messages with invalid GPB data

    ${SIMULATORS_LIST}=   Get xNF Simulators   1
    Send Messages From xNF Simulators   ${SIMULATORS_LIST}   ${XNF_INVALID_GPB_DATA_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}  ${AMOUNT_50000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_INVALID_GPB_DATA_REQUEST}


Unsupported domain message handling
    [Documentation]   VES-HV Collector should skip messages with unsupported domain

    ${SIMULATORS_LIST}=   Get xNF Simulators   1
    Send Messages From xNF Simulators   ${SIMULATORS_LIST}   ${XNF_UNSUPPORTED_DOMAIN_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed  ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_50000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_UNSUPPORTED_DOMAIN_REQUEST}

*** Keywords ***
Message Routing Suite Setup
    Log   Started Suite: VES-HV Message Routing
    ${XNF_PORTS_LIST}=    Create List    7000
    Configure xNF Simulators On Ports    ${XNF_PORTS_LIST}
    Log   Suite setup finished

Configure xNF Simulators On Ports
    [Arguments]    ${XNF_PORTS_LIST}
    ${XNF_SIMULATORS_ADDRESSES}=   Start Xnf Simulators    ${XNF_PORTS_LIST}    True
    Set Suite Variable    ${XNF_SIMULATORS_ADDRESSES}


Get xNF Simulators
    [Arguments]  ${AMOUNT}
    ${SIMULATORS}=   Get Slice From List   ${XNF_SIMULATORS_ADDRESSES}   0   ${AMOUNT}
    [Return]   ${SIMULATORS}


Send Messages From xNF Simulators
    [Arguments]    ${XNF_HOSTS_LIST}   ${MESSAGE_FILEPATH}
    :FOR   ${HOST}   IN    @{XNF_HOSTS_LIST}
    \    ${XNF_SIM_API_ACCESS}=   Get xNF Sim Api Access Url   ${HTTP_METHOD_URL}   ${HOST}
    \    ${XNF_SIM_API_URL}=  Catenate   SEPARATOR=   ${XNF_SIM_API_ACCESS}   ${XNF_SIM_API_PATH}
    \    Send messages   ${XNF_SIM_API_URL}   ${MESSAGE_FILEPATH}


VES-HV Collector Test Shutdown
    Reset DCAE App Simulator  ${DCAE_APP_API_MESSAGE_RESET_URL}


VES-HV Collector Suite Teardown
    Stop And Remove All Xnf Simulators

*** Variables ***
${HTTP_METHOD_URL}                             http://

${XNF_SIM_API_PATH}                            /simulator/async

${VES_HV_SCENARIOS}                            %{WORKSPACE}/test/csit/tests/dcaegen2-collectors-hv-ves/testcases/resources/scenarios
${XNF_FIXED_PAYLOAD_REQUEST}                   ${VES_HV_SCENARIOS}/fixed-payload/xnf-fixed-payload-request.json
${XNF_TOO_BIG_PAYLOAD_REQUEST}                 ${VES_HV_SCENARIOS}/too-big-payload/xnf-too-big-payload-request.json
${XNF_INVALID_WIRE_FRAME_REQUEST}              ${VES_HV_SCENARIOS}/invalid-wire-frame/xnf-invalid-wire-frame-request.json
${XNF_INVALID_GPB_DATA_REQUEST}                ${VES_HV_SCENARIOS}/invalid-gpb-data/xnf-invalid-gpb-data-request.json
${XNF_UNSUPPORTED_DOMAIN_REQUEST}              ${VES_HV_SCENARIOS}/unsupported-domain/xnf-unsupported-domain-request.json

${DCAE_FIXED_PAYLOAD_REQUEST}                  ${VES_HV_SCENARIOS}/fixed-payload/dcae-fixed-payload-request.json
${DCAE_INVALID_WIRE_FRAME_REQUEST}             ${VES_HV_SCENARIOS}/invalid-wire-frame/dcae-invalid-wire-frame-request.json
${DCAE_INVALID_GPB_DATA_REQUEST}               ${VES_HV_SCENARIOS}/invalid-gpb-data/dcae-invalid-gpb-data-request.json
${DCAE_UNSUPPORTED_DOMAIN_REQUEST}             ${VES_HV_SCENARIOS}/unsupported-domain/dcae-unsupported-domain-request.json

${AMOUNT_25000}                                25000
${AMOUNT_50000}                                50000
