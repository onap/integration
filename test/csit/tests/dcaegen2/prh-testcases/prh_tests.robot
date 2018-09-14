*** Settings ***
Documentation     Integration tests for PRH.
...               PRH receive events from DMaaP and produce or not PNF_READY notification depends on required fields in received event.
Suite Setup       Run keywords    Create header    Create sessions
Library           resources/PrhLibrary.py
Resource          resources/prh_library.robot
Resource          ../../common.robot

*** Variables ***
${DMAAP_SIMULATOR_URL}    http://${DMAAP_SIMULATOR}
${AAI_SIMULATOR_URL}    http://${AAI_SIMULATOR}
${PRH_URL}        http://${PRH}
${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}    %{WORKSPACE}/test/csit/tests/dcaegen2/prh-testcases/assets/json_events/event_with_all_fields.json
${EVENT_WITH_IPV4}    %{WORKSPACE}/test/csit/tests/dcaegen2/prh-testcases/assets/json_events/event_with_IPV4.json
${EVENT_WITH_IPV6}    %{WORKSPACE}/test/csit/tests/dcaegen2/prh-testcases/assets/json_events/event_with_IPV6.json
${EVENT_WITH_MISSING_IPV4_AND_IPV6}    %{WORKSPACE}/test/csit/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_IPV4_and_IPV6.json
${EVENT_WITH_MISSING_SOURCENAME}    %{WORKSPACE}/test/csit/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName.json
${EVENT_WITH_MISSING_SOURCENAME_AND_IPV4}    %{WORKSPACE}/test/csit/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName_and_IPV4.json
${EVENT_WITH_MISSING_SOURCENAME_AND_IPV6}    %{WORKSPACE}/test/csit/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName_and_IPV6.json
${EVENT_WITH_MISSING_SOURCENAME_IPV4_AND_IPV6}    %{WORKSPACE}/test/csit/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName_IPV4_and_IPV6.json
${Not_json_format}    %{WORKSPACE}/test/csit/tests/dcaegen2/prh-testcases/assets/json_events/not_json_format.json

*** Test Cases ***
Valid DMaaP event can be converted to PNF_READY notification
    [Documentation]    PRH get valid event from DMaaP with required fields - PRH produce PNF_READY notification
    [Tags]    PRH    Valid event
    [Template]    Valid event processing
    ${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    ${EVENT_WITH_IPV4}
    ${EVENT_WITH_IPV6}

Invalid DMaaP event cannot be converted to PNF_READY notification
    [Documentation]    PRH get invalid event from DMaaP with missing required fields - PRH does not produce PNF_READY notification
    [Tags]    PRH    Invalid event
    [Template]    Invalid event processing
    ${EVENT_WITH_MISSING_IPV4_AND_IPV6}
    ${EVENT_WITH_MISSING_SOURCENAME}
    ${EVENT_WITH_MISSING_SOURCENAME_AND_IPV4}
    ${EVENT_WITH_MISSING_SOURCENAME_AND_IPV6}
    ${EVENT_WITH_MISSING_SOURCENAME_IPV4_AND_IPV6}

Get valid event from DMaaP and record in AAI does not exist
    [Documentation]    PRH get valid event from DMaaP with all required fields and in AAI record doesn't exist - PRH does not produce PNF_READY notification
    [Tags]    PRH    Missing AAI record
    [Timeout]    30s
    ${data}=    Get Data From File    ${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    Set PNF name in AAI    wrong_aai_record
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check PRH log    java.io.IOException: Connection closed prematurely

Event in DMaaP is not JSON format
    [Documentation]    PRH get not JSON format event from DMaaP - PRH does not produce PNF_READY notification
    [Tags]    PRH
    ${data}=    Get Data From File    ${Not_json_format}
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check PRH log    |java.lang.IllegalStateException: Not a JSON Array:

Get valid event from DMaaP and AAI is not responding
    [Documentation]    PRH get valid event from DMaaP with all required fields and AAI is not responding - PRH does not produce PNF_READY notification
    [Tags]    PRH    AAI
    [Timeout]    180s
    ${data}=    Get Data From File    ${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    Stop AAI
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check PRH log    java.net.UnknownHostException: aai
