*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests

*** Variables ***
${TARGETURL}  https://10.147.124.100:9509/services/search-data-service/v1/search/indexes/test-index3
${INDEXDATA}  {"fields": [{"name": "Name", "data-type": "string"}, {"name": "Number", "data-type": "long"}]}
${DOCUMENTDATA}  {"Name": "A", "Number": 5}

*** Test Cases ***
Index Create Test
    [Documentation]             Create an index and verify success
    ${resp}=                    PutWithCert              ${TARGETURL}              ${INDEXDATA}
    Should Be Equal As Strings  ${resp.status_code}      201

Insert Document Test
    [Documentation]             Insert a document into the previously created index
    ${resp}=                    PutWithCert             ${TARGETURL}/documents/testdoc   ${DOCUMENTDATA} 
    Should Be Equal As Strings  ${resp.status_code}      201

Get Document Test
    [Documentation]             Get the document that was just created
    ${resp}                     GetWithCert              ${TARGETURL}/documents/testdoc
    ${content}=                 Evaluate                 $resp.json().get('content')
    ${originaljson}=            Evaluate                 json.loads('${DOCUMENTDATA}')   json
    Should Be Equal As Strings  ${resp.status_code}      200
    Should Be Equal             ${content}               ${originaljson}

Delete Index Test
    [Documentation]             Delete the index
    ${resp}=                    DeleteWithCert           ${TARGETURL}
    Should Be Equal As Strings  ${resp.status_code}      200

*** Keywords ***
PutWithCert
    [Arguments]      ${url}      ${data}
    ${certinfo}=     Evaluate    ('${CURDIR}/publickey.crt', '${CURDIR}/private.key')
    ${resp}=         Evaluate    requests.put('${url}', data='${data}', cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

PostWithCert
    [Arguments]      ${url}      ${data}
    ${certinfo}=     Evaluate    ('${CURDIR}/publickey.crt', '${CURDIR}/private.key')
    ${resp}=         Evaluate    requests.post('${url}', data='${data}', cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

GetWithCert
    [Arguments]      ${url}
    ${certinfo}=     Evaluate    ('${CURDIR}/publickey.crt', '${CURDIR}/private.key')
    ${resp}=         Evaluate    requests.get('${url}', cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

DeleteWithCert
    [Arguments]      ${url}
    ${certinfo}=     Evaluate    ('${CURDIR}/publickey.crt', '${CURDIR}/private.key')
    ${resp}=         Evaluate    requests.delete('${url}', cert=${certinfo}, verify=False)    requests
    [return]         ${resp}
    
