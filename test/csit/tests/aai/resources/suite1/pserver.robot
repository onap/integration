*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${TARGETURL}  https://${HOST_IP}:8443/v11/cloud-infrastructure/pservers/pserver/pesrver-test1
${PSERVERDATA}  {"hostname": "pserver-test1"}

*** Test Cases ***

Run AAI Put Pserver
    [Documentation]             Create an index and verify success
    ${resp}=                    PutWithCert              ${TARGETURL}              ${PSERVERDATA}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get Pserver
    [Documentation]             Get the document that was just created
    ${resp}                     GetWithCert              ${TARGETURL}
    ${content}=                 Evaluate                 $resp.json()
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json()['resource-version']

Run AAI Get Pserver
    [Documentation]             Delete the index
    ${resp}=                    DeleteWithCert           ${TARGETURL}?resource-version=${resource_version}
    Should Be Equal As Strings  ${resp.status_code}      204

*** Keywords ***
PutWithCert
    [Arguments]      ${url}      ${data}
    ${auth}=         Create List  AAI AAI
    ${uuid}=         Generate UUID
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${uuid}    X-FromAppId=integration-aai
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.put('${url}', data='${data}', auth=${auth}, headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

PostWithCert
    [Arguments]      ${url}      ${data}
    ${auth}=         Create List  AAI AAI
    ${uuid}=         Generate UUID
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${uuid}    X-FromAppId=integration-aai
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.post('${url}', data='${data}', auth=${auth}, headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

GetWithCert
    [Arguments]      ${url}
    ${auth}=         Create List  AAI AAI
    ${uuid}=         Generate UUID
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${uuid}    X-FromAppId=integration-aai
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.get('${url}', auth=${auth}, headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

DeleteWithCert
    [Arguments]      ${url}
    ${auth}=         Create List  AAI AAI
    ${uuid}=         Generate UUID
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${uuid}    X-FromAppId=integration-aai
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.delete('${url}', auth=${auth}, headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}
    
