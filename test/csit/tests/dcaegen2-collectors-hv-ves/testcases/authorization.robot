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
    ${XNF_WITH_INVALID_CERTIFICATES}=   Configure xNF Simulators    ${XNF_PORTS_LIST}
    ...                                               should_use_valid_certs=${false}
    Set Suite Variable   ${XNF_WITH_INVALID_CERTIFICATES}
    ${XNF_PORTS_LIST}=    Create List    7001
    ${XNF_WITHOUT_SSL}=   Configure xNF Simulators    ${XNF_PORTS_LIST}
    ...                                               should_disable_ssl=${true}
    Set Suite Variable   ${XNF_WITHOUT_SSL}
    ${XNF_PORTS_LIST}=    Create List    7002
    ${XNF_WITHOUT_SSL_CONNECTING_TO_UNENCRYPTED_HV_VES}=   Configure xNF Simulators    ${XNF_PORTS_LIST}
    ...                                                                                should_disable_ssl=${true}
    ...                                                                                should_connect_to_unencrypted_hv_ves=${true}
    Set Suite Variable   ${XNF_WITHOUT_SSL_CONNECTING_TO_UNENCRYPTED_HV_VES}
    Log   Suite setup finished

*** Test Cases ***
Authorization
    [Documentation]   VES-HV Collector should not authorize XNF with invalid certificate and not route any message
    ...               to topics

    Send Messages From xNF Simulators   ${XNF_WITH_INVALID_CERTIFICATES}   ${XNF_VALID_MESSAGES_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_0}

Unencrypted connection from client
    [Documentation]   VES-HV Collector should not authorize XNF trying to connect through unencrypted connection

    Send Messages From xNF Simulators   ${XNF_WITHOUT_SSL}   ${XNF_VALID_MESSAGES_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_0}

Unencrypted connection on both ends
    [Documentation]   When run without SSL turned on, VES-HV Collector should route all valid messages
    ...               from xNF trying to connect through unencrypted connection

    Send Messages From xNF Simulators   ${XNF_WITHOUT_SSL_CONNECTING_TO_UNENCRYPTED_HV_VES}   ${XNF_VALID_MESSAGES_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_5000}


*** Variables ***
${VES_HV_SCENARIOS}                            %{WORKSPACE}/test/csit/tests/dcaegen2-collectors-hv-ves/testcases/resources/scenarios

${XNF_VALID_MESSAGES_REQUEST}                  ${VES_HV_SCENARIOS}/authorization/xnf-valid-messages-request.json

${AMOUNT_0}                                    0
${AMOUNT_5000}                                 5000
