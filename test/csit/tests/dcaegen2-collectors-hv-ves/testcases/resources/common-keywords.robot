*** Settings ***
Library       XnfSimulatorLibrary
Library       VesHvContainersUtilsLibrary
Library       Collections

*** Keywords ***
Configure xNF Simulators Using Valid Certificates On Ports
    [Arguments]    ${XNF_PORTS_LIST}
    ${VALID_XNF_SIMULATORS_ADDRESSES}=   Configure xNF Simulators   ${XNF_PORTS_LIST}
    Set Suite Variable    ${VALID_XNF_SIMULATORS_ADDRESSES}

Configure xNF Simulators
    [Arguments]    ${XNF_PORTS_LIST}
    ...            ${should_use_valid_certs}=${true}
    ...            ${should_disable_ssl}=${false}
    ...            ${should_connect_to_unencrypted_hv_ves}=${false}
    ${XNF_SIMULATORS_ADDRESSES}=   Start Xnf Simulators   ${XNF_PORTS_LIST}
    ...                                                           ${should_use_valid_certs}
    ...                                                           ${should_disable_ssl}
    ...                                                           ${should_connect_to_unencrypted_hv_ves}
    [Return]   ${XNF_SIMULATORS_ADDRESSES}

Get xNF Simulators Using Valid Certificates
    [Arguments]  ${AMOUNT}=1
    ${SIMULATORS}=   Get Slice From List   ${VALID_XNF_SIMULATORS_ADDRESSES}   0   ${AMOUNT}
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

