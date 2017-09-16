*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${L3NETWORKKEYVALUE}   l3-network-integration-test1
${L3NETWORKURL}        https://${HOST_IP}:8443/aai/v11/network/l3-networks/l3-network/${L3NETWORKKEYVALUE}
${L3NETWORKDATA}  {"network-id":"${L3NETWORKKEYVALUE}","network-name":"example-network-name-val-5468","network-type":"example-network-type-val-5468","network-role":"example-network-role-val-5468","network-technology":"example-network-technology-val-5468","neutron-network-id":"example-neutron-network-id-val-5468","is-bound-to-vpn":"true","service-id":"example-service-id-val-5468","orchestration-status":"example-orchestration-status-val-5468","heat-stack-id":"example-heat-stack-id-val-5468","mso-catalog-key":"example-mso-catalog-key-val-5468"}
${L3NETWORKPATCHDATA}  {"network-id":"${L3NETWORKKEYVALUE}","network-name":"example-network-name-val-5468-patched","network-type":"example-network-type-val-5468-patched"}

*** Test Cases ***
Run AAI Put l3-network
    [Documentation]             Create l3-network object
    ${resp}=                    PutWithCert              ${L3NETWORKURL}              ${L3NETWORKDATA}
    log                         ${L3NETWORKURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get l3-network
    [Documentation]             Get the l3-network object just created
    ${resp}                     GetWithCert              ${L3NETWORKURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
	
Run AAI Patch l3-network
    [Documentation]             Update (Parch) l3-network object
    ${resp}=                    PatchWithCert              ${L3NETWORKURL}              ${L3NETWORKPATCHDATA}
    log                         ${L3NETWORKURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      200	
	
Run AAI Get l3-network
    [Documentation]             Get the l3-network object just patched
    ${resp}                     GetWithCert              ${L3NETWORKURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete l3-network
    [Documentation]             Delete the l3-network
    ${resp}=                    DeleteWithCert           ${L3NETWORKURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204	
	
*** Keywords ***
PutWithCert
    [Arguments]      ${url}      ${data}
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.put('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}
	
PatchWithCert
    [Arguments]      ${url}      ${data}
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/merge-patch+json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.patch('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}	

PostWithCert
    [Arguments]      ${url}      ${data}
    ${auth}=         Create List  AAI AAI
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.post('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

GetWithCert
    [Arguments]      ${url}
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.get('${url}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

DeleteWithCert
    [Arguments]      ${url}
    ${auth}=         Create List  AAI AAI
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.delete('${url}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}