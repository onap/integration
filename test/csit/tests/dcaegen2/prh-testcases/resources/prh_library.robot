*** Settings ***
Library           RequestsLibrary
Library           Collections

*** Keywords ***
Create header
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Set Suite Variable    ${suite_headers}    ${headers}

Create sessions
    Create Session    dmaap_session    ${DMAAP_SIMULATOR_URL}
    Set Suite Variable    ${suite_dmaap_session}    dmaap_session
    Create Session    aai_session    ${AAI_SIMULATOR_URL}
    Set Suite Variable    ${suite_aai_session}    aai_session

Invalid event processing
    [Arguments]    ${input_invalid_event_in_dmaap}
    [Timeout]    30s
    Set event in DMaaP    ${input_invalid_event_in_dmaap}
    Wait Until Keyword Succeeds    100x    100ms    Check PRH log    INFO 1 --- [pool-2-thread-1] o.o.d.s.prh.tasks.DmaapConsumerTaskImpl \ : Consumed model from DmaaP: ${input_invalid_event_in_dmaap}

Valid event processing
    [Arguments]    ${input_valid_event_in_dmaap}
    [Timeout]    30s
    ${posted_event_to_dmaap}=    Create PNF_Ready notification    ${input_valid_event_in_dmaap}
    ${pnf_name}=    Create PNF name    ${input_valid_event_in_dmaap}
    Set PNF name in AAI    ${pnf_name}
    Set event in DMaaP    ${input_valid_event_in_dmaap}
    Wait Until Keyword Succeeds    100x    300ms    Check PNF_READY notification    ${posted_event_to_dmaap}

Check PRH log
    [Arguments]    ${searched_log}
    ${status}=    Check for log    ${searched_log}
    Should Be Equal As Strings    ${status}    True

Check PNF_READY notification
    [Arguments]    ${posted_event_to_dmaap}
    ${resp}=    Get Request    ${suite_dmaap_session}    /events/pnfReady    headers=${suite_headers}
    Should Be Equal    ${resp.text}    ${posted_event_to_dmaap}

Set PNF name in AAI
    [Arguments]    ${pnfs_name}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    ${resp}=    Put Request    ${suite_aai_session}    /set_pnfs    headers=${headers}    data=${pnfs_name}
    Should Be Equal As Strings    ${resp.status_code}    200

Set event in DMaaP
    [Arguments]    ${event_in_dmaap}
    ${resp}=    Put Request    ${suite_dmaap_session}    /set_get_event    headers=${suite_headers}    data=${event_in_dmaap}
    Should Be Equal As Strings    ${resp.status_code}    200
