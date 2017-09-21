*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections
Library           String

*** Variables ***
${TARGETURL_PUBLISH}        http://${DMAAP_MR_IP}:3904/events/TestTopic1
${TARGETURL_TOPICS}         http://${DMAAP_MR_IP}:3904/topics
${TARGETURL_SUBSCR}         http://${DMAAP_MR_IP}:3904/events/TestTopic1/CG1/C1?timeout=1000
${TEST_DATA}                {"topicName": "TestTopic1"}
${TOPIC_DATA}               {"topicName":"FirstTopic","topicDescription":"This is a TestTopic","partitionCount":"1","replicationCount":"3","transactionEnabled":"true"}

*** Test Cases ***
Run Topic Creation and Publish
    [Documentation]    			  	Topic Creation
    [Timeout]    			  	  	1 minute
    ${resp}=    			  	  	PostCall      					${TARGETURL_PUBLISH}    	${TEST_DATA}
    log    				          	${TARGETURL_PUBLISH}
    log    				          	${resp.text}
    Should Be Equal As Strings    	${resp.status_code}           	200
    ${count}=    	              	Evaluate     					$resp.json().get('count')
    log    				  			'JSON Response Code:'${resp}

Run Subscribing a message status
    [Documentation]    		        Subscribide message status
    [Timeout]    			  		1 minute
	${resp}=    			  		GetCall    						${TARGETURL_SUBSCR}
    log    				  			${TARGETURL_SUBSCR}
    Should Be Equal As Strings      ${resp.status_code}           	200
    log    		                  	'JSON Response Code :'${resp}
    
Run check topics are exisiting
    [Documentation]    		  		Get the count of the Topics
    [Timeout]    			  		1 minute
    ${resp}=    			  		GetCall                       	${TARGETURL_TOPICS}
    log              		  		${TARGETURL_TOPICS}
    Should Be Equal As Strings      ${resp.status_code}           	200
    log    				  			'JSON Response Code :'${resp}
    ${topics}=       			  	Evaluate                 	  	$resp.json().get('topics')
    log					  			${topics}
    ${ListLength}=    			  	Get Length                    	${topics}
    log    				  			${ListLength}
    List Should Contain Value 		${topics}                       TestTopic1

Run Publich and Subscribe a message
    [Documentation]    		        Publish and Subscribe the message
    [Timeout]    			  		1 minute
	${resp}=    			  	  	PostCall      					${TARGETURL_PUBLISH}    	${TEST_DATA}
    log    				          	${TARGETURL_PUBLISH}
    log    				          	${resp.text}
    Should Be Equal As Strings    	${resp.status_code}           	200
    ${sub_resp}=    			  		GetCall    						${TARGETURL_SUBSCR}
    log    				  			${TARGETURL_SUBSCR}
    Should Be Equal As Strings      ${sub_resp.status_code}           	200
    log    		                  	'JSON Response Code :'${sub_resp}
    ${ListLength}=                  Get Length                    	${sub_resp.json()}
    log    				  			${ListLength}
    List Should Contain Value       ${sub_resp.json()}    				{"topicName":"TestTopic1"}    case_insensitive=yes

*** Keywords ***
PostCall
    [Arguments]    ${url}    		${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}

GetCall
    [Arguments]     ${url}
    ${headers}=     Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=    	Evaluate    requests.get('${url}', headers=${headers}, verify=False)    requests
    [Return]    	${resp}
