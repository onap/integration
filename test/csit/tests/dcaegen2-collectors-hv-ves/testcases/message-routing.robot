*** Settings ***
Library       DcaeAppSimulatorLibrary
Library       XnfSimulatorLibrary
Library       VesHvContainersUtilsLibrary
Library       Collections

Resource      resources/common-keywords.robot

Suite Setup       Message Routing Suite Setup
Suite Teardown    VES-HV Collector Suite Teardown
Test Teardown     VES-HV Collector Test Shutdown

*** Keywords ***
Message Routing Suite Setup
    Log   Started Suite: VES-HV Message Routing
    ${XNF_PORTS_LIST}=    Create List    7000
    Configure xNF Simulators Using Valid Certificates On Ports    ${XNF_PORTS_LIST}
    Log   Suite setup finished

*** Test Cases ***
Correct Messages Routing
    [Documentation]   VES-HV Collector should route all valid messages to topics specified in configuration
    ...               and do not change message payload generated in XNF simulator

    ${XNF_SIMULATOR}=   Get xNF Simulators Using Valid Certificates
    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_FIXED_PAYLOAD_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_25000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_FIXED_PAYLOAD_REQUEST}


Too big payload message handling
    [Documentation]   VES-HV Collector should interrupt the stream when encountered message with too big payload

    ${XNF_SIMULATOR}=   Get xNF Simulators Using Valid Certificates
    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_TOO_BIG_PAYLOAD_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed Less Equal Than   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_25000}


Invalid wire frame message handling
    [Documentation]  VES-HV Collector should skip messages with invalid wire frame

    ${XNF_SIMULATOR}=   Get xNF Simulators Using Valid Certificates
    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_INVALID_WIRE_FRAME_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_50000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_INVALID_WIRE_FRAME_REQUEST}


Invalid GPB data message handling
    [Documentation]   VES-HV Collector should skip messages with invalid GPB data

    ${XNF_SIMULATOR}=   Get xNF Simulators Using Valid Certificates
    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_INVALID_GPB_DATA_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}  ${AMOUNT_50000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_INVALID_GPB_DATA_REQUEST}


Unsupported domain message handling
    [Documentation]   VES-HV Collector should skip messages with unsupported domain

    ${XNF_SIMULATOR}=   Get xNF Simulators Using Valid Certificates
    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_UNSUPPORTED_DOMAIN_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed  ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_50000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_UNSUPPORTED_DOMAIN_REQUEST}

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
