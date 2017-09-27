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
View Namesapce
    [Tags]    get
    CreateSession    aaf    http://${AAF_IP}:8101
    &{headers}=  Create Dictionary    Authorization=Basic ZGdsQG9wZW5lY29tcC5vcmc6ZWNvbXBfYWRtaW4=    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    aaf    /authz/nss/org.openecomp    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    log    		                  	'JSON Response Code :'${resp.text}	
	
View by User Permission 
    [Tags]    get
    CreateSession    aaf    http://${AAF_IP}:8101
    &{headers}=  Create Dictionary    Authorization=Basic ZGdsQG9wZW5lY29tcC5vcmc6ZWNvbXBfYWRtaW4=    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    aaf    authz/perms/user/dgl@openecomp.org    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    log    		                  	'JSON Response Code :'${resp.text}	
	
View by User Role 
    [Tags]    get
    CreateSession    aaf    http://${AAF_IP}:8101
    &{headers}=  Create Dictionary    Authorization=Basic ZGdsQG9wZW5lY29tcC5vcmc6ZWNvbXBfYWRtaW4=    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    aaf    authz/roles/user/dgl@openecomp.org    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    log    		                  	'JSON Response Code :'${resp.text}	

Cleanup Namespace ( 424 Response - Delete dependencies and try again) 
    [Tags]    delete
    CreateSession    aaf    http://${AAF_IP}:8101
    &{headers}=  Create Dictionary    Authorization=Basic ZGdsQG9wZW5lY29tcC5vcmc6ZWNvbXBfYWRtaW4=    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    aaf    authz/ns/org.openecomp.dmaapBC   headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    424
    log    		                  	'JSON Response Code :'${resp.text}	
	
Add Data ( Add Admin to Namespace Explicit ) 
    [Tags]    post
    CreateSession    aaf    http://${AAF_IP}:8101
    &{headers}=  Create Dictionary    Authorization=Basic ZGdsQG9wZW5lY29tcC5vcmc6ZWNvbXBfYWRtaW4=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    aaf    authz/ns/org.openecomp.dmaapBC/admin/alexD@openecomp.org   headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    403
    log    		                  	'JSON Response Code :'${resp.text}	
	
View Explicit Permission 
    [Tags]    post
    CreateSession    aaf    http://${AAF_IP}:8101
    &{headers}=  Create Dictionary    Authorization=Basic ZGdsQG9wZW5lY29tcC5vcmc6ZWNvbXBfYWRtaW4=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    aaf    authz/perms/user/m99751@dmaapBC.openecomp.org   headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    406
    log    		                  	'JSON Response Code :'${resp.text}	