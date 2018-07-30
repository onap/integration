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
${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}    {"event": {"otherFields": {"pnfVendorName":"Nokia", "pnfSerialNumber":"QTFCOC540002E", "pnfOamIpv4Address":"10.16.123.234", "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}}
${Not_json_format}    ""

*** Test Cases ***
Valid DMaaP event can be converted to PNF_READY notification
    [Documentation]    PRH get valid event from DMaaP with required fields - PRH produce PNF_READY notification
    [Tags]    PRH    Valid event
    [Template]    Valid event processing
    ${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    {"event": {"otherFields": {"pnfVendorName":"Nokia", "pnfSerialNumber":"QTFCOC540002G", "pnfOamIpv4Address":"10.16.123.234", "pnfOamIpv6Address":""}}}
    {"event": {"otherFields": {"pnfVendorName":"Nokia", "pnfSerialNumber":"QTFCOC540002F", "pnfOamIpv4Address":"", "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}}
    {"event": {"otherFields": {"pnfVendorName":"Ericsson", "pnfSerialNumber":"QTFCOC5400000", "pnfOamIpv4Address":"", "pnfOamIpv6Address":"2001:0db8:85b3:0000:0000:8a2e:0370:7334"}}}

Invalid DMaaP event cannot be converted to PNF_READY notification
    [Documentation]    PRH get invalid event from DMaaP with missing required fields - PRH does not produce PNF_READY notification
    [Tags]    PRH    Invalid event
    [Template]    Invalid event processing
    {"event": {"otherFields": {"pnfVendorName":"Nokia", "pnfSerialNumber":"QTFCOC540002E", "pnfOamIpv4Address":"", "pnfOamIpv6Address":""}}}
    {"event": {"otherFields": {"pnfVendorName":"Nokia", "pnfSerialNumber":"", "pnfOamIpv4Address":"10.16.123.234", "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}}
    {"event": {"otherFields": {"pnfVendorName":"Nokia", "pnfSerialNumber":"", "pnfOamIpv4Address":"10.16.123.234", "pnfOamIpv6Address":""}}}
    {"event": {"otherFields": {"pnfVendorName":"Nokia", "pnfSerialNumber":"", "pnfOamIpv4Address":"", "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}}
    {"event": {"otherFields": {"pnfVendorName":"Nokia", "pnfSerialNumber":"", "pnfOamIpv4Address":"", "pnfOamIpv6Address":""}}}
    {"event": {"otherFields": {"pnfVendorName":"", "pnfSerialNumber":"QTFCOC540002E", "pnfOamIpv4Address":"10.16.123.234", "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}}
    {"event": {"otherFields": {"pnfVendorName":"", "pnfSerialNumber":"QTFCOC540002E", "pnfOamIpv4Address":"10.16.123.234", "pnfOamIpv6Address":""}}}
    {"event": {"otherFields": {"pnfVendorName":"", "pnfSerialNumber":"QTFCOC540002E", "pnfOamIpv4Address":"", "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}}
    {"event": {"otherFields": {"pnfVendorName":"", "pnfSerialNumber":"QTFCOC540002E", "pnfOamIpv4Address":"", "pnfOamIpv6Address":""}}}
    {"event": {"otherFields": {"pnfVendorName":"", "pnfSerialNumber":"", "pnfOamIpv4Address":"10.16.123.234", "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}}
    {"event": {"otherFields": {"pnfVendorName":"", "pnfSerialNumber":"", "pnfOamIpv4Address":"10.16.123.234", "pnfOamIpv6Address":""}}}
    {"event": {"otherFields": {"pnfVendorName":"", "pnfSerialNumber":"", "pnfOamIpv4Address":"", "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}}
    {"event": {"otherFields": {"pnfVendorName":"", "pnfSerialNumber":"", "pnfOamIpv4Address":"", "pnfOamIpv6Address":""}}}
    ${Not_json_format}

Get valid event from DMaaP and record in AAI does not exist
    [Documentation]    PRH get valid event from DMaaP with all required fields and in AAI record doesn't exist - PRH does not produce PNF_READY notification
    [Tags]    PRH    Missing AAI record
    [Timeout]    30s
    Set PNF name in AAI    wrong_aai_record
    Set event in DMaaP    ${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    Wait Until Keyword Succeeds    100x    300ms    Check PRH log    org.onap.dcaegen2.services.prh.exceptions.AAINotFoundException: Incorrect response code for continuation of tasks workflow

Get valid event from DMaaP and AAI is not responding
    [Documentation]    PRH get valid event from DMaaP with all required fields and AAI is not responding - PRH does not produce PNF_READY notification
    [Tags]    PRH    AAI
    [Timeout]    180s
    Stop AAI
    Set event in DMaaP    ${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    Wait Until Keyword Succeeds    100x    300ms    Check PRH log    java.net.NoRouteToHostException: Host is unreachable (Host unreachable)
