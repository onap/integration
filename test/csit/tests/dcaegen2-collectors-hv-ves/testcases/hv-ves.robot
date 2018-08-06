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

${AMOUNT_25000}                                25000