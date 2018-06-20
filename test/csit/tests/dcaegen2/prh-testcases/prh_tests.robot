*** Settings ***
Library           RequestsLibrary
Library           Process
Library           resources/PrhLibrary.py

*** Variables ***
${DMAAP_SIM_URL}    http://${DMAAP_SIMULATOR}
${AAI_SIM_URL}    http://${AAI_SIMULATOR}
${PRH_URL}        http://${PRH}

*** Test Cases ***
Getting and Consuming Positive Scenario
    [Documentation]    Get message from new topic and consume it - positive scenarios
    [Tags]    PRH
    [Setup]    Start prh
    [Template]    Run Getting and Consuming
    {"pnfName":"NOKQTFCOC540002E","ipv4":"10.16.123.234","ipv6":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}    NOKQTFCOC540002E    {"event": {"commonEventHeader": {"sourceId":"QTFCOC540002E", "startEpochMicrosec":1519837825682, "eventId":"QTFCOC540002E-reg", "nfcNamingCode":"5DU", "internalHeaderFields":{"collectorTimeStamp":"Fri, 04 27 2018 09:01:10 GMT"}, "eventType":"pnfRegistration", "priority":"Normal", "version":3, "reportingEntityName":"5GRAN_DU", "sequence":0, "domain":"other", "lastEpochMicrosec":1519837825682, "eventName":"pnfRegistration_5GDU", "sourceName":"5GRAN_DU", "nfNamingCode":"5GRAN"}, "otherFields": {"pnfLastServiceDate":1517206400, "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334", "pnfVendorName":"Nokia", "pnfModelNumber":"AJ02", "pnfFamily":"BBU", "pnfType":"AirScale", "otherFieldsVersion":1, "pnfOamIpv4Address":"10.16.123.234", "pnfSoftwareVersion":"v4.5.0.1", "pnfSerialNumber":"QTFCOC540002E", "pnfManufactureDate":1516406400}}}
    {"pnfName":"NOKQTFCOC540002F","ipv4":"","ipv6":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}    NOKQTFCOC540002F    {"event": {"commonEventHeader": {"sourceId":"QTFCOC540002F", "startEpochMicrosec":1519837825682, "eventId":"QTFCOC540002F-reg", "nfcNamingCode":"5DU", "internalHeaderFields":{"collectorTimeStamp":"Fri, 04 27 2018 09:01:10 GMT"}, "eventType":"pnfRegistration", "priority":"Normal", "version":3, "reportingEntityName":"5GRAN_DU", "sequence":0, "domain":"other", "lastEpochMicrosec":1519837825682, "eventName":"pnfRegistration_5GDU", "sourceName":"5GRAN_DU", "nfNamingCode":"5GRAN"}, "otherFields": {"pnfLastServiceDate":1517206400, "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334", "pnfVendorName":"Nokia", "pnfModelNumber":"AJ02", "pnfFamily":"BBU", "pnfType":"AirScale", "otherFieldsVersion":1, "pnfOamIpv4Address":"", "pnfSoftwareVersion":"v4.5.0.1", "pnfSerialNumber":"QTFCOC540002F", "pnfManufactureDate":1516406400}}}
    {"pnfName":"NOKQTFCOC540002G","ipv4":"10.16.123.234","ipv6":""}    NOKQTFCOC540002G    {"event": {"commonEventHeader": {"sourceId":"QTFCOC540002G", "startEpochMicrosec":1519837825682, "eventId":"QTFCOC540002G-reg", "nfcNamingCode":"5DU", "internalHeaderFields":{"collectorTimeStamp":"Fri, 04 27 2018 09:01:10 GMT"}, "eventType":"pnfRegistration", "priority":"Normal", "version":3, "reportingEntityName":"5GRAN_DU", "sequence":0, "domain":"other", "lastEpochMicrosec":1519837825682, "eventName":"pnfRegistration_5GDU", "sourceName":"5GRAN_DU", "nfNamingCode":"5GRAN"}, "otherFields": {"pnfLastServiceDate":1517206400, "pnfOamIpv6Address":"", "pnfVendorName":"Nokia", "pnfModelNumber":"AJ02", "pnfFamily":"BBU", "pnfType":"AirScale", "otherFieldsVersion":1, "pnfOamIpv4Address":"10.16.123.234", "pnfSoftwareVersion":"v4.5.0.1", "pnfSerialNumber":"QTFCOC540002G", "pnfManufactureDate":1516406400}}}
    {"pnfName":"ERIQTFCOC5400000","ipv4":"10.16.123.23","ipv6":""}    ERIQTFCOC5400000    {"event": {"commonEventHeader": {"sourceId":"QTFCOC5400000", "startEpochMicrosec":1519837825682, "eventId":"QTFCOC5400000-reg", "nfcNamingCode":"5DU", "internalHeaderFields":{"collectorTimeStamp":"Fri, 04 27 2018 09:01:10 GMT"}, "eventType":"pnfRegistration", "priority":"Normal", "version":3, "reportingEntityName":"5GRAN_DU", "sequence":0, "domain":"other", "lastEpochMicrosec":1519837825682, "eventName":"pnfRegistration_5GDU", "sourceName":"5GRAN_DU", "nfNamingCode":"5GRAN"}, "otherFields": {"pnfLastServiceDate":1517206400, "pnfOamIpv6Address":"", "pnfVendorName":"Ericsson", "pnfModelNumber":"AJ02", "pnfFamily":"BBU", "pnfType":"AirScale", "otherFieldsVersion":1, "pnfOamIpv4Address":"10.16.123.23", "pnfSoftwareVersion":"v4.5.0.1", "pnfSerialNumber":"QTFCOC5400000", "pnfManufactureDate":1516406400}}}
    [Teardown]    Stop prh

Missing IPv4 and IPv6
    [Documentation]    Test get event from DMaaP without IPv4 and IPv6
    [Tags]    PRH    no_IPv4    no_IPv6
    [Setup]    Start prh
    Missing IP    {"event": {"commonEventHeader": {"sourceId":"QTFCOC540002E", "startEpochMicrosec":1519837825682, "eventId":"QTFCOC540002E-reg", "nfcNamingCode":"5DU", "internalHeaderFields":{"collectorTimeStamp":"Fri, 04 27 2018 09:01:10 GMT"}, "eventType":"pnfRegistration", "priority":"Normal", "version":3, "reportingEntityName":"5GRAN_DU", "sequence":0, "domain":"other", "lastEpochMicrosec":1519837825682, "eventName":"pnfRegistration_5GDU", "sourceName":"5GRAN_DU", "nfNamingCode":"5GRAN"}, "otherFields": {"pnfLastServiceDate":1517206400, "pnfOamIpv6Address":"", "pnfVendorName":"Nokia", "pnfModelNumber":"AJ02", "pnfFamily":"BBU", "pnfType":"AirScale", "otherFieldsVersion":1, "pnfOamIpv4Address":"", "pnfSoftwareVersion":"v4.5.0.1", "pnfSerialNumber":"QTFCOC540002E", "pnfManufactureDate":1516406400}}}
    [Teardown]    Stop prh

Wrong AAI record
    [Documentation]    Wrong or missing record in AAI
    [Tags]    PRH    AAI
    [Setup]    Start prh
    Wrong AAI record    {"event": {"commonEventHeader": {"sourceId":"QTFCOC540002E", "startEpochMicrosec":1519837825682, "eventId":"QTFCOC540002E-reg", "nfcNamingCode":"5DU", "internalHeaderFields":{"collectorTimeStamp":"Fri, 04 27 2018 09:01:10 GMT"}, "eventType":"pnfRegistration", "priority":"Normal", "version":3, "reportingEntityName":"5GRAN_DU", "sequence":0, "domain":"other", "lastEpochMicrosec":1519837825682, "eventName":"pnfRegistration_5GDU", "sourceName":"5GRAN_DU", "nfNamingCode":"5GRAN"}, "otherFields": {"pnfLastServiceDate":1517206400, "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334", "pnfVendorName":"Nokia", "pnfModelNumber":"AJ02", "pnfFamily":"BBU", "pnfType":"AirScale", "otherFieldsVersion":1, "pnfOamIpv4Address":"10.16.123.234", "pnfSoftwareVersion":"v4.5.0.1", "pnfSerialNumber":"QTFCOC540002E", "pnfManufactureDate":1516406400}}}
    [Teardown]    Stop prh

*** Keywords ***
Wrong AAI record
    [Arguments]    ${event_in_dmaap}
    [Timeout]    1m
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Set get event in DMAAP    ${event_in_dmaap}    ${headers}
    Set pnfs name in AAI    wrong_aai_record
    ${check}=    check for log    org.onap.dcaegen2.services.prh.exceptions.AAINotFoundException: Incorrect response code for continuation of tasks workflow
    Should Be Equal As Strings    ${check}    True

Missing IP
    [Arguments]    ${event_in_dmaap}
    [Timeout]    1m
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Set get event in DMAAP    ${event_in_dmaap}    ${headers}
    ${check}=    check for log    org.onap.dcaegen2.services.prh.exceptions.DmaapNotFoundException: IPV4 and IPV6 are empty
    Should Be Equal As Strings    ${check}    True

Run Getting and Consuming
    [Arguments]    ${posted_event_to_dmaap}    ${pnfs_name}    ${event_in_dmaap}
    [Timeout]    1m
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Set pnfs name in AAI    ${pnfs_name}
    Set get event in DMAAP    ${event_in_dmaap}    ${headers}
    : FOR    ${Index}    IN RANGE    1    30
    \    Create Session    prh_ready    ${DMAAP_SIM_URL}
    \    ${resp}=    Get Request    prh_ready    /events/pnfReady    headers=${headers}
    \    Exit For Loop If    '${resp.text}' == '${posted_event_to_dmaap}'
    \    Sleep    1s
    Should Be Equal    ${resp.text}    ${posted_event_to_dmaap}

Start prh
    [Timeout]    1m
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Create Session    prh_start    ${PRH_URL}
    ${resp}=    Get Request    prh_start    /start    headers=${headers}
    Should Be Equal    ${resp.text}    "PRH Service has been started!"

Stop prh
    [Timeout]    1m
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Create Session    prh_stop    ${PRH_URL}
    ${resp}=    Get Request    prh_stop    /stopPrh    headers=${headers}
    Should Be Equal    ${resp.text}    "PRH Service has already been stopped!"

Set pnfs name in AAI
    [Arguments]    ${pnfs_name}
    [Timeout]    1 minute
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    Create Session    set_pnfs_in_aai    ${AAI_SIM_URL}
    ${resp}=    Put Request    set_pnfs_in_aai    /set_pnfs    headers=${headers}    data=${pnfs_name}
    Should Be Equal As Strings    ${resp.status_code}    200
    Log To Console    ${resp.text}

Set get event in DMAAP
    [Arguments]    ${event_in_dmaap}    ${headers}
    [Timeout]    1m
    Create Session    set_get_event    ${DMAAP_SIM_URL}
    ${resp}=    Put Request    set_get_event    /set_get_event    headers=${headers}    data=${event_in_dmaap}
    Should Be Equal As Strings    ${resp.status_code}    200
    Log To Console    ${resp.text}
