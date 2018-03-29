*** settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=   200  201  202
${querysample_vio_url}    /samples

*** Test Cases ***
VioSwaggerTest
    [Documentation]    query swagger info rest test
    ${headers}    Create Dictionary    Content-Type=application/json  X-TRANSACTIONID=123456  Accept=application/json
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    ${querysample_vio_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    # verify logging output
    ${response_json}    json.loads    ${resp.content}
    ${logs}=	Convert To String      ${response_json['logs']}
    Log To Console        ${logs}
    Should Contain        ${logs}  123456
    Should Contain 	  ${logs}  multicloud-vio
    Should Contain 	  ${logs}  vio.samples.views