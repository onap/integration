*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections
Library           String

*** Variables ***
${TARGETURL_NAMESPACE}     http://${AAF_IP}:8101/authz/nss/org.openecomp
${TARGETURL_PERMS}         http://${AAF_IP}:8101/authz/perms/user/dgl@openecomp.org
${TARGETURL_ROLES}         http://${AAF_IP}:8101/authz/roles/user/dgl@openecomp.org
${username}               dgl@openecomp.org 
${password}               ecomp_admin

*** Test Cases ***

Run View By Role
    [Documentation]    			  	Topic Creation
    [Timeout]    			  	  	1 minute
    ${resp}=    			  	  	GetCall      					${TARGETURL_NAMESPACE}    	${username}    	${password} 
    log    				          	${TARGETURL_NAMESPACE}
    log    				          	${resp.text}
    Should Be Equal As Strings    	${resp.status_code}           	200
    ${count}=    	              	Evaluate     					$resp.json().get('count')
    log    				  			'JSON Response Code:'${resp}

Run View By Permission
    [Documentation]    		        Subscribide message status
    [Timeout]    			  		1 minute
	${resp}=    			  		GetCall    						${TARGETURL_PERMS}    	${username}    	${password} 
    log    				  			${TARGETURL_PERMS}
    Should Be Equal As Strings      ${resp.status_code}           	200
    log    		                  	'JSON Response Code :'${resp}
    


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
	
*** Keywords ***
| Log in to our application with
| | [Arguments] | ${username} | ${password}
| | Input text | id=username | ${username}
| | Input password | id=password | ${password}
| | Click button | id=submit_button
