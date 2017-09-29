*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${TARGETURL}  https://${HOST_IP}:8443/aai/v11/external-system/esr-thirdparty-sdnc-list/esr-thirdparty-sdnc/thirdparty-sdnc-test1
${VNFMDATA}  {"thirdparty-sdnc-id": "thirdparty-sdnc-test1", "location": "edge", "product-name": "aaa", "esr-system-info-list": { "esr-system-info": [{ "esr-system-info-id": "thirdparty-sdnc-esr-system-info-id", "system-name": "sdnc1", "type": "WAN", "vendor": "ZTE", "version": "v1.0", "service-url": "http://10.74.66.12:80", "user-name": "admin", "password": "admin", "system-type": "thirdparty_SDNC", "protocol": "netconf"}]}}

*** Test Cases ***

Run AAI Put thirdparty-sdnc
    [Documentation]             Create an thirdparty-sdnc object
    ${resp}=                    PutWithCert              ${TARGETURL}              ${VNFMDATA}
    log                         ${TARGETURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get thirdparty-sdnc
    [Documentation]             Get the thirdparty-sdnc object just created
    ${resp}                     GetWithCert              ${TARGETURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete thirdparty-sdnc
    [Documentation]             Delete the thirdparty-sdnc just created
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
    
