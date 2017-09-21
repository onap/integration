*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${CUSTOMERKEYVALUE}        customer-integration-test3
${LOGICALLINKKEYVALUE}     logical-link-integration-test3
${CUSTOMERURL}             https://${HOST_IP}:8443/aai/v11/business/customers/customer/${CUSTOMERKEYVALUE}
${LOGICALLINKURL}          https://${HOST_IP}:8443/aai/v11/network/logical-links/logical-link/${LOGICALLINKKEYVALUE}
${CUSTOMERDATA}  {"global-customer-id":"${CUSTOMERKEYVALUE}","subscriber-name":"subscriber-name-integration-test","subscriber-type":"subscriber-type-integration-test","service-subscriptions":{"service-subscription":{"service-type":"service-type-987654321-04","service-instances":{"service-instance":{"service-instance-id":"service-instance-id-integration-test","relationship-list":{"relationship":[{"related-to":"logical-link","relationship-data":[{"relationship-key":"logical-link.link-name","relationship-value":"${LOGICALLINKKEYVALUE}"}]}]}}}}}}
${LOGICALLINKDATA}  {"link-name":"${LOGICALLINKKEYVALUE}","link-type":"example-link-type-value-val-126","speed-value":"example-speed-value-val-126","speed-units":"example-speed-units-val-126","ip-version":"example-ip-version-val-126","routing-protocol":"example-routing-protocol-val-126","resource-model-uuid":"example-resource-model-uuid-val-5465"}

*** Test Cases ***
Run AAI Put logical-link
    [Documentation]             Create an logical-link object
    ${resp}=                    PutWithCert              ${LOGICALLINKURL}              ${LOGICALLINKDATA}
    log                         ${LOGICALLINKURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get logical-link
    [Documentation]             Get the logical-link object just created
    ${resp}                     GetWithCert              ${LOGICALLINKURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
	
Run AAI Put customer rel with logical-link
    [Documentation]             Create customer rel with logical-link
    ${resp}=                    PutWithCert              ${CUSTOMERURL}              ${CUSTOMERDATA}
    log                         ${CUSTOMERURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get customer to delete
    [Documentation]             Get the customer
    ${resp}                     GetWithCert              ${CUSTOMERURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete customer
    [Documentation]             Delete the customer
    ${resp}=                    DeleteWithCert           ${CUSTOMERURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204
	
Run AAI Get logical-link should not found error 404
    [Documentation]             Get logical-link should not found error 404
    ${resp}                     GetWithCert              ${LOGICALLINKURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      404

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