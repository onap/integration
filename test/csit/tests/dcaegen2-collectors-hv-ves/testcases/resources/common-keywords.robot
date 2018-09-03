*** Settings ***
Library       XnfSimulatorLibrary
Library       VesHvContainersUtilsLibrary
Library       Collections

*** Keywords ***
Configure Valid xNF Simulators On Ports
    [Arguments]    ${XNF_PORTS_LIST}
    ${VALID_XNF_SIMULATORS_ADDRESSES}=   Start Xnf Simulators    ${XNF_PORTS_LIST}    ${true}
    Set Suite Variable    ${VALID_XNF_SIMULATORS_ADDRESSES}


Configure Invalid xNF Simulators On Ports
    [Arguments]    ${XNF_PORTS_LIST}
    ${INVALID_XNF_SIMULATORS_ADDRESSES}=   Start Xnf Simulators    ${XNF_PORTS_LIST}    ${false}
    Set Suite Variable    ${INVALID_XNF_SIMULATORS_ADDRESSES}


Get Valid xNF Simulators
    [Arguments]  ${AMOUNT}
    ${SIMULATORS}=   Get Slice From List   ${VALID_XNF_SIMULATORS_ADDRESSES}   0   ${AMOUNT}
    [Return]   ${SIMULATORS}


Get Invalid xNF Simulators
    [Arguments]  ${AMOUNT}
    ${SIMULATORS}=   Get Slice From List   ${INVALID_XNF_SIMULATORS_ADDRESSES}   0   ${AMOUNT}
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
    Stop And Remove All Xnf Simulators   ${SUITE NAME}

*** Variables ***
${HTTP_METHOD_URL}                             http://

${XNF_SIM_API_PATH}                            /simulator/async

