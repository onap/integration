*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections
Library           String

*** Variables ***
${TARGETURL_FEED}       https://${DR_PROV_IP}:8443
${CREATE_FEED_DATA}     {"name": "CSIT_Test", "version": "m1.0", "description": "CSIT_Test", "business_description": "CSIT_Test", "suspend": false, "deleted": false, "changeowner": true, "authorization": {"classification": "unclassified", "endpoint_addrs": ["${DR_PROV_IP}"],  "endpoint_ids": [{"password": "rs873m", "id": "rs873m"}]}}

*** Test Cases ***
Run Feed Creation
    [Documentation]    			  	Feed Creation
    [Timeout]    			  	  	1 minute
    ${resp}=    			  	  	PostFeed     					${TARGETURL_FEED}    	${CREATE_FEED_DATA}
    log    				          	${TARGETURL_FEED}
    log    				          	${resp.text}
    Should Be Equal As Strings    	${resp.status_code}           	201
    log    				  			'JSON Response Code:'${resp}


*** Keywords ***
PostFeed
    [Arguments]    ${url}    		${data}
    ${headers}=    Create Dictionary    X-ATT-DR-ON-BEHALF-OF=rs873m    Content-Type=application/vnd.att-dr.feed
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}
