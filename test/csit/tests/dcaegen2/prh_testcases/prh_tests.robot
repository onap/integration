*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections
Library           String

*** Variables ***
${PNF_REGISTER_URL}         http://${DMAAP_SIMULATOR}/events/unauthenticated.SEC_OTHER_OUTPUT
${PNF_READY_URL}            http://${DMAAP_SIMULATOR}/events/pnfReady
${PRH_START_URL}            http://${PRH}/start
${PNF_REGISTER_EVENT}       %{WORKSPACE}/test/csit/tests/dcaegen2/prh_testcases/resources/events/pnf_register_event.json


*** Test Cases ***
Run Posting and Consuming
    [Documentation]    			  	  Post message to new topic and consume it
    [Timeout]    			  	  	    1 minute
    ${req_data}=                  Get Binary File       ${PNF_REGISTER_EVENT}
    ${resp}=    			  	  	    PostCall      				${PNF_REGISTER_URL}    	${req_data}
    log    				          	    ${PNF_REGISTER_URL}
    log    				          	    ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}   200
   # ${count}=    	              	Evaluate     					$resp.json().get('count')
    log    				  			        'JSON Response Code:' ${resp}
    ${resp}=    			  	  	    GetCall      				  ${PRH_START_URL}
    log                           ${PRH_START_URL}
    log    				          	    ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}   201
    ${resp}=    			  		      GetCall    						${PNF_READY_URL}
    log    				  			        ${PNF_READY_URL}
    log    				          	    ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}   200
    log    		                  	'JSON Response Code:' ${resp}


*** Keywords ***
PostCall
    [Arguments]    ${url}    	 ${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}

GetCall
    [Arguments]    ${url}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=    	 Evaluate    requests.get('${url}', headers=${headers}, verify=False)    requests
    [Return]    	 ${resp}
