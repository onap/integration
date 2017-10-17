*** Settings ***
Documentation     The main interface for interacting with Portal. It handles low level stuff like managing the selenium request library and Portal required steps
Library 	    ExtendedSelenium2Library
Library	          RequestsClientCert
Library 	      RequestsLibrary
Library	          UUID 
Library         DateTime  
Resource        ../global_properties.robot
Resource        ../browser_setup.robot

*** Variables ***
${PORTAL_ENV}            /ECOMPPORTAL
${PORTAL_LOGIN_URL}                http://localhost:8080/login.htm
${PORTAL_HOME_PAGE}        ${GLOBAL_PORTAL_URL}${PORTAL_ENV}/applicationsHome
${PORTAL_MICRO_ENDPOINT}    ${GLOBAL_PORTAL_URL}${PORTAL_ENV}/commonWidgets
${PORTAL_HOME_URL}                ${GLOBAL_PORTAL_URL}${PORTAL_ENV}/applicationsHome
${App_First_Name}    appdemo    
${App_Last_Name}    demo
${App_Email_Address}    appdemo@onap.com
${App_LoginID}    appdemo 
${App_Loginpwd}    demo123456!
${App_LoginPwdCheck}    demo123456!
${Sta_First_Name}    stademo   
${Sta_Last_Name}    demo
${Sta_Email_Address}    stademo@onap.com
${Sta_LoginID}    stademo
${Sta_Loginpwd}    demo123456!
${Sta_LoginPwdCheck}    demo123456!
${Existing_User}    portal
${PORTAL_HEALTH_CHECK_PATH}        /ECOMPPORTAL/portalApi/healthCheck
#${Application}     'Virtual Infrastructure Deployment'  
#${Application_tab}     'select-app-Virtual-Infrastructure-Deployment'   
#${Application_dropdown}    'div-app-name-dropdown-Virtual-Infrastructure-Deployment'
#${Application_dropdown_select}    'div-app-name-Virtual-Infrastructure-Deployment'  
${APPC_LOGIN_URL}     http://104.130.74.99:8282/apidoc/explorer/index.html 
${PORTAL_ASSETS_DIRECTORY}    C:\\Users\\kk707x\\Downloads


  


*** Keywords ***


Run Portal Get Request
     [Documentation]    Runs Portal Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session 	portal	${GLOBAL_PORTAL_URL}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
     ${resp}= 	Get Request 	portal 	${data_path}     headers=${headers}
     Log    Received response from portal ${resp.text}
     [Return]    ${resp}     
     

Standared user Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    # Setup Browser Now being managed by test case
    ##Setup Browser
    Go To    ${PORTAL_LOGIN_URL}
    Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${GLOBAL_PORTAL_SERVER}${PORTAL_ENV}
   # Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${GLOBAL_STA_USER_USER}
    Input Password    xpath=//input[@ng-model='password']    ${GLOBAL_STA_USER_PWD}
    Click Link    xpath=//a[@id='loginBtn']
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}    
    Log    Logged in to ${GLOBAL_PORTAL_SERVER}${PORTAL_ENV}       
     
 
Standared user Navigation Application Link Tab    
    [Documentation]   Logs into Portal GUI as application admin
    #Portal admin Go To Portal HOME
    Click Element    xpath=.//h3[contains(text(),'Virtual Infras...')]/following::div[1]
    Page Should Contain    Welcome to VID    
    Click Element    xpath=(.//span[@id='tab-Home'])[1]
    
    
Standared user Navigation Functional Menu     
    [Documentation]   Logs into Portal GUI as application admin
    Click Link    xpath=//a[contains(.,'Manage')]
     Mouse Over    xpath=//*[contains(text(),'Technology Insertion')]
     Click Link    xpath= //*[contains(text(),'Infrastructure VNF Provisioning')] 
     Page Should Contain    Welcome to VID
     Click Element    xpath=(.//span[@id='tab-Home'])[1]   
     
     
     
Standared user Broadcast Notifications 
    [Documentation]   Logs into Portal GUI as application admin 
    [Arguments]    ${AdminBroadCastMsg}
    Click element    xpath=//*[@id='megamenu-notification-button'] 
    Click element    xpath=//*[@id='notification-history-link'] 
    Wait until Element is visible    xpath=//*[@id='app-title']    timeout=10 
    Table Column Should Contain    xpath=//*[@id='notification-history-table']    2    ${AdminBroadCastMsg} 
    log    ${AdminBroadCastMsg}   
    
   
Standared user Category Notifications 
    [Documentation]   Logs into Portal GUI as application admin 
    [Arguments]    ${AdminCategoryMsg}
    #click element    xpath=//*[@id='megamenu-notification-button'] 
    #click element    xpath=//*[@id="notification-history-link"] 
    Wait until Element is visible    xpath=//*[@id='app-title']    timeout=10 
    Table Column Should Contain    xpath=//*[@id='notification-history-table']    2    ${AdminCategoryMsg} 
    log    ${AdminCategoryMsg} 
    
    
Standared user Logout from Portal GUI
    [Documentation]   Logout from Portal GUI
    Click Element    xpath=//div[@id='header-user-icon']
    Click Button    xpath=//button[contains(.,'Log out')]
    #Confirm Action	
    Title Should Be    Login     
        
     
     
     
Tear Down     
    [Documentation]   Close all browsers
    Close All Browsers
    

 
 
 
    
    
