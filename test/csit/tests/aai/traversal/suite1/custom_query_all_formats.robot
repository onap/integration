*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections

*** Variables ***
${GENERICVNFKEYVALUE}    generic-vnf-integration-test1
${PSERVERKEYVALUE}    pserver-integration-test1
${GENERICVNFURL}    https://${HOST_IP}:8443/aai/v11/network/generic-vnfs/generic-vnf/${GENERICVNFKEYVALUE}
${PSERVERURL}     https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/pservers/pserver/${PSERVERKEYVALUE}
${RELATIONSHIPURL}    https://${HOST_IP}:8443/aai/v11/network/generic-vnfs/generic-vnf/${GENERICVNFKEYVALUE}/relationship-list/relationship
${CUSTOMQUERYURL}    https://${HOST_IP}:8443/aai/v11/query?format=simple
${CUSTOMQUERYURL_GRAPHSON}    https://${HOST_IP}:8443/aai/v11/query?format=graphson
${CUSTOMQUERYURL_ID}    https://${HOST_IP}:8443/aai/v11/query?format=id
${CUSTOMQUERYURL_PATHED}    https://${HOST_IP}:8443/aai/v11/query?format=pathed
${CUSTOMQUERYURL_RESOURCE}    https://${HOST_IP}:8443/aai/v11/query?format=resource
${CUSTOMQUERYURL_RESOURCE_URL}    https://${HOST_IP}:8443/aai/v11/query?format=resource_and_url
${CUSTOMQUERYURL_RAW}    https://${HOST_IP}:8443/aai/v11/query?format=raw
${GENERICVNFDATA}    {"vnf-id":"${GENERICVNFKEYVALUE}","vnf-name":"example-vnf-name-val-51663","vnf-name2":"example-vnf-name2-val-15450","vnf-type":"example-vnf-type-val-32726"}
${PSERVERDATA}    { "hostname": "${PSERVERKEYVALUE}", "ptnii-equip-name": "example-ptnii-equip-name-val-91724", "number-of-cpus": 56461, "disk-in-gigabytes": 13534, "ram-in-megabytes": 66589, "equip-type": "example-equip-type-val-94149", "equip-vendor": "example-equip-vendor-val-91811", "equip-model": "example-equip-model-val-26157", "fqdn": "example-fqdn-val-19743", "pserver-selflink": "example-pserver-selflink-val-67676", "ipv4-oam-address": "example-ipv4-oam-address-val-12819", "serial-number": "example-serial-number-val-33384", "ipaddress-v4-loopback-0": "example-ipaddress-v4-loopback0-val-63311", "ipaddress-v6-loopback-0": "example-ipaddress-v6-loopback0-val-70485", "ipaddress-v4-aim": "example-ipaddress-v4-aim-val-23497", "ipaddress-v6-aim": "example-ipaddress-v6-aim-val-24473", "ipaddress-v6-oam": "example-ipaddress-v6-oam-val-38196", "inv-status": "example-inv-status-val-10016", "pserver-id": "example-pserver-id-val-90123", "internet-topology": "example-internet-topology-val-17042", "in-maint": true, "pserver-name2": "example-pserver-name2-val-12304", "purpose": "example-purpose-val-86719", "prov-status": "example-prov-status-val-68126", "management-option": "example-management-option-val-86521", "host-profile": "example-host-profile-val-48679" }
${CUSTOMQUERYDATA}    {"gremlin":"g.V().has(\\'hostname\\', \\'${PSERVERKEYVALUE}\\')"}
${PSERVER_GENERIC_VNF_RELATIONSHIPDATA}    {"related-to":"pserver","relationship-data":[{"relationship-key":"pserver.hostname","relationship-value":"${PSERVERKEYVALUE}"}]}

*** Test Cases ***
Run AAI Put generic-vnf
    [Documentation]    Create an generic-vnf object
    ${resp}=    PutWithCert    ${GENERICVNFURL}    ${GENERICVNFDATA}
    log    ${GENERICVNFURL}
    log    ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}    201

Run AAI Put pserver
    [Documentation]    Create an pserver object
    ${resp}=    PutWithCert    ${PSERVERURL}    ${PSERVERDATA}
    log    ${PSERVERURL}
    log    ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}    201

Run AAI Put relationship of pserver and generic-vnf
    [Documentation]    Create relationship of pserver and generic-vnf
    ${resp}=    PutWithCert    ${RELATIONSHIPURL}    ${PSERVER_GENERIC_VNF_RELATIONSHIPDATA}
    log    ${RELATIONSHIPURL}
    log    ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}    200

Run AAI Get pserver
    [Documentation]    Get the pserver object just relationship
    ${resp}    GetWithCert    ${PSERVERURL}
    log    ${resp}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

Run AAI Get generic-vnf
    [Documentation]    Get the generic-vnf object just relationship
    ${resp}    GetWithCert    ${GENERICVNFURL}
    log    ${resp}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

Run AAI Put custom query simple format
    [Documentation]    custom query simple format
    log    ${CUSTOMQUERYDATA}
    ${resp}=    PutWithCert    ${CUSTOMQUERYURL}    ${CUSTOMQUERYDATA}
    log    ${CUSTOMQUERYURL}
    log    ${resp.text}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

Run AAI Put custom query graphson format
    [Documentation]    custom query graphson format
    log    ${CUSTOMQUERYDATA}
    ${resp}=    PutWithCert    ${CUSTOMQUERYURL_GRAPHSON}    ${CUSTOMQUERYDATA}
    log    ${CUSTOMQUERYURL_GRAPHSON}
    log    ${resp.text}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

Run AAI Put custom query id format
    [Documentation]    custom query id format
    log    ${CUSTOMQUERYDATA}
    ${resp}=    PutWithCert    ${CUSTOMQUERYURL_ID}    ${CUSTOMQUERYDATA}
    log    ${CUSTOMQUERYURL_ID}
    log    ${resp.text}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

Run AAI Put custom query pathed format
    [Documentation]    custom query pathed format
    log    ${CUSTOMQUERYDATA}
    ${resp}=    PutWithCert    ${CUSTOMQUERYURL_PATHED}    ${CUSTOMQUERYDATA}
    log    ${CUSTOMQUERYURL_PATHED}
    log    ${resp.text}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

Run AAI Put custom query resource format
    [Documentation]    custom query resource format
    log    ${CUSTOMQUERYDATA}
    ${resp}=    PutWithCert    ${CUSTOMQUERYURL_RESOURCE}    ${CUSTOMQUERYDATA}
    log    ${CUSTOMQUERYURL_RESOURCE}
    log    ${resp.text}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

Run AAI Put custom query resource url format
    [Documentation]    custom query resource url format
    log    ${CUSTOMQUERYDATA}
    ${resp}=    PutWithCert    ${CUSTOMQUERYURL_RESOURCE_URL}    ${CUSTOMQUERYDATA}
    log    ${CUSTOMQUERYURL_RESOURCE_URL}
    log    ${resp.text}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

Run AAI Put custom query raw format
    [Documentation]    custom query raw format
    log    ${CUSTOMQUERYDATA}
    ${resp}=    PutWithCert    ${CUSTOMQUERYURL_RAW}    ${CUSTOMQUERYDATA}
    log    ${CUSTOMQUERYURL_RAW}
    log    ${resp.text}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

Run AAI Get generic-vnf to delete
    [Documentation]    Get the generic-vnf object to delete
    ${resp}    GetWithCert    ${GENERICVNFURL}
    log    ${resp}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resource_version}=    Evaluate    $resp.json().get('resource-version')
    Set Global Variable    ${resource_version}

Run AAI Delete generic-vnf
    [Documentation]    Delete the generic-vnf
    ${resp}=    DeleteWithCert    ${GENERICVNFURL}?resource-version=${resource_version}
    log    ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}    204

Run AAI Get pserver to delete
    [Documentation]    Get the pserver object to delete
    ${resp}    GetWithCert    ${PSERVERURL}
    log    ${resp}
    log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resource_version}=    Evaluate    $resp.json().get('resource-version')
    Set Global Variable    ${resource_version}

Run AAI Delete pserver
    [Documentation]    Delete the pserver
    ${resp}=    DeleteWithCert    ${PSERVERURL}?resource-version=${resource_version}
    log    ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}    204

*** Keywords ***
PutWithCert
    [Arguments]    ${url}    ${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai    Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=    Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=    Evaluate    requests.put('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [Return]    ${resp}

PatchWithCert
    [Arguments]    ${url}    ${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/merge-patch+json    X-TransactionId=integration-aai    X-FromAppId=integration-aai    Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=    Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=    Evaluate    requests.patch('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [Return]    ${resp}

PostWithCert
    [Arguments]    ${url}    ${data}
    ${auth}=    Create List    AAI AAI
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai    Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=    Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=    Evaluate    requests.post('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [Return]    ${resp}

GetWithCert
    [Arguments]    ${url}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai    Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=    Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=    Evaluate    requests.get('${url}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [Return]    ${resp}

DeleteWithCert
    [Arguments]    ${url}
    ${auth}=    Create List    AAI AAI
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai    Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=    Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=    Evaluate    requests.delete('${url}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [Return]    ${resp}
