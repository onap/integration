*** settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=         200  201  202
${queryswagger_url}        /api/catalog/v1/swagger.json
${queryVNFPackage_url}     /api/catalog/v1/vnfpackages
${queryNSPackages_url}     /api/catalog/v1/nspackages

*** Test Cases ***
GetVNFPackages
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}             headers=${headers}
    ${resp}=              Get Request          web_session                      ${queryVNFPackage_url}
    ${responese_code}=    Convert To String    ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
