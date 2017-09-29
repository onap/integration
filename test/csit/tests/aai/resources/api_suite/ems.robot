*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${TARGETURL}  https://${HOST_IP}:8443/aai/v11/external-system/esr-ems-list/esr-ems/ems-test1
${EMSDATA}  { "ems-id": "ems-test1", "esr-system-info-list": { "esr-system-info": [{ "esr-system-info-id": "ems-esr-system-info1", "system-name": "fff", "type": "ftp", "vendor": "ZTE", "version": "v1.0", "user-name": "root", "password": "123456", "system-type": "EMS_PERFORMANCE", "ip-address": "10.74.15.28", "port": "6767", "passive": true, "remote-path": "/data/peroformance"},{ "esr-system-info-id": "ems-esr-system-info2", "system-name": "fff", "type": "ftp", "vendor": "ZTE", "version": "v1.0", "user-name": "root", "password": "123456", "system-type": "EMS_RESOUCE", "ip-address": "10.74.15.29", "port": "6666", "passive": true, "remote-path": "/opt/Gcp/data/"},{ "esr-system-info-id": "ems-esr-system-info3", "system-name": "fff", "vendor": "ZTE", "version": "v1.0", "user-name": "root", "password": "123456", "system-type": "EMS_ALARM", "ip-address": "10.74.15.30", "port": "2000"}]}}

*** Test Cases ***

Run AAI Put ems
    [Documentation]             Create an ems object
    ${resp}=                    PutWithCert              ${TARGETURL}              ${EMSDATA}
    log                         ${TARGETURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get ems
    [Documentation]             Get the ems object just created
    ${resp}                     GetWithCert              ${TARGETURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete ems
    [Documentation]             Delete the ems just created
    ${resp}=                    DeleteWithCert           ${TARGETURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204

*** Keywords ***
PutWithCert
    [Arguments]      ${url}      ${data}
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.put('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
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
    
