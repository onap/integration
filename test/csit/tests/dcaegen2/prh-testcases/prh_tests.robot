*** Settings ***
Documentation     Integration tests for PRH.
...               PRH receive events from DMaaP and produce or not PNF_READY notification depends on required fields in received event.
Suite Setup       Run keywords    Create header 
...                               Create sessions
Library           resources/PrhLibrary.py
Resource          resources/prh_library.robot

*** Variables ***
${DMAAP_SIMULATOR_URL}    http://${DMAAP_SIMULATOR}
${AAI_SIMULATOR_URL}    http://${AAI_SIMULATOR}
${PRH_URL}        http://${PRH}
${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}    {"event": {"commonEventHeader": {"sourceName":"NOK6061ZW1"}, "pnfRegistrationFields": {"oamV4IpAddress":"10.16.123.234", "oamV6IpAddress":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}}
${Not_json_format}    ""

*** Test Cases ***
Valid DMaaP event can be converted to PNF_READY notification
    [Documentation]    PRH get valid event from DMaaP with required fields - PRH produce PNF_READY notification
    [Tags]    PRH    Valid event
    [Template]    Valid event processing
    ${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    {"event": {"commonEventHeader": {"sourceName":"NOK6061ZW2"}, "pnfRegistrationFields": {"oamV4IpAddress":"10.17.123.234", "oamV6IpAddress":""}}}
    {"event": {"commonEventHeader": {"sourceName":"ERI6061ZW3"}, "pnfRegistrationFields": {"oamV4IpAddress":"", "oamV6IpAddress":"2001:0db8:85a3:0000:0000:8b2e:0370:7334"}}}

Invalid DMaaP event cannot be converted to PNF_READY notification
    [Documentation]    PRH get invalid event from DMaaP with missing required fields - PRH does not produce PNF_READY notification
    [Tags]    PRH    Invalid event
    [Template]    Invalid event processing
    {"event": {"commonEventHeader": {"sourceName":"NOK6061ZW4"}, "pnfRegistrationFields": {"oamV4IpAddress":"", "oamV6IpAddress":""}}}
    {"event": {"commonEventHeader": {"sourceName":""}, "pnfRegistrationFields": {"oamV4IpAddress":"10.18.123.234", "oamV6IpAddress":"2001:0db8:85a3:0000:0000:8a2a:0370:7334"}}}
    {"event": {"commonEventHeader": {"sourceName":""}, "pnfRegistrationFields": {"oamV4IpAddress":"10.17.163.234", "oamV6IpAddress":""}}}
    {"event": {"commonEventHeader": {"sourceName":""}, "pnfRegistrationFields": {"oamV4IpAddress":"", "oamV6IpAddress":"2001:0db8:85a3:0000:0000:8b2f:0370:7334"}}}
    {"event": {"commonEventHeader": {"sourceName":""}, "pnfRegistrationFields": {"oamV4IpAddress":"", "oamV6IpAddress":""}}}

Get valid event from DMaaP and record in AAI does not exist
    [Documentation]    PRH get valid event from DMaaP with all required fields and in AAI record doesn't exist - PRH does not produce PNF_READY notification
    [Tags]    PRH    Missing AAI record
    [Timeout]    30s
    Set PNF name in AAI    wrong_aai_record
    Set event in DMaaP    ${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    Wait Until Keyword Succeeds    100x    300ms    Check PRH log    java.io.IOException: Connection closed prematurely

Event in DMaaP is not JSON format
    [Documentation]    PRH get not JSON format event from DMaaP - PRH does not produce PNF_READY notification
    [Tags]    PRH
    Set event in DMaaP    ${Not_json_format}
    Wait Until Keyword Succeeds    100x    300ms    Check PRH log    |java.lang.IllegalStateException: Not a JSON Array:

Get valid event from DMaaP and AAI is not responding
    [Documentation]    PRH get valid event from DMaaP with all required fields and AAI is not responding - PRH does not produce PNF_READY notification
    [Tags]    PRH    AAI
    [Timeout]    180s
    Stop AAI
    Set event in DMaaP    ${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    Wait Until Keyword Succeeds    100x    300ms    Check PRH log    java.net.UnknownHostException: aai
