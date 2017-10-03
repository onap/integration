*** Settings ***
Documentation    This is RobotFrame work script
Library    ExtendedSelenium2Library
Library    OperatingSystem
Library	          eteutils/RequestsClientCert.py
Library 	      RequestsLibrary
Library	          eteutils/UUID.py 
Library         DateTime  
Library           Collections
Library           eteutils/OSUtils.py
Library 		eteutils/StringTemplater.py
Library     	XvfbRobot
#Resource   ../resources/browser_setup.robot
Resource        json_templater.robot


*** Variables ***
#${PORTAL_URL}      http://%{DOCKER_IP}:8989
#${PORTAL_URL}      http://%{HOST_IP}:8989
#${PORTAL_URL}		http://localhost:8989
${PORTAL_URL}		http://portal.api.simpledemo.openecomp.org:8989
#${PORTAL_URL}		http://104.239.203.25:8989
${PORTAL_ENV}            /ECOMPPORTAL
${PORTAL_LOGIN_URL}                ${PORTAL_URL}${PORTAL_ENV}/login.htm
${PORTAL_HOME_PAGE}        ${PORTAL_URL}${PORTAL_ENV}/applicationsHome
${PORTAL_MICRO_ENDPOINT}    ${PORTAL_URL}${PORTAL_ENV}/commonWidgets
${PORTAL_HOME_URL}                ${PORTAL_URL}${PORTAL_ENV}/applicationsHome
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
${Test_First_Name}    portal    
${Test_Last_Name}    demo
${Test_Email_Address}    portal@onap.com
${Test_LoginID}    portal 
${Test_Loginpwd}    demo123456!
${Test_LoginPwdCheck}    demo123456!
${Existing_User}    portal
${PORTAL_HEALTH_CHECK_PATH}        /ECOMPPORTAL/portalApi/healthCheck
${PORTAL_ASSETS_DIRECTORY}    ${CURDIR}
${GLOBAL_APPLICATION_ID}           robot-functional
${GLOBAL_PORTAL_ADMIN_USER}		demo
${GLOBAL_PORTAL_ADMIN_PWD}		demo123456!
${GLOBAL_MSO_STATUS_PATH}    /ecomp/mso/infra/orchestrationRequests/v2/
${GLOBAL_SELENIUM_BROWSER}        chrome
${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}        Create Dictionary
${GLOBAL_SELENIUM_DELAY}          0
${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}        5
${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}        15
${GLOBAL_OPENSTACK_HEAT_SERVICE_TYPE}    orchestration
${GLOBAL_OPENSTACK_CINDER_SERVICE_TYPE}    volume
${GLOBAL_OPENSTACK_NOVA_SERVICE_TYPE}    compute
${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    network
${GLOBAL_OPENSTACK_GLANCE_SERVICE_TYPE}    image
${GLOBAL_OPENSTACK_KEYSTONE_SERVICE_TYPE}    identity
${GLOBAL_BUILD_NUMBER}    0
${GLOBAL_VM_PRIVATE_KEY}   ${EXECDIR}/robot/assets/keys/robot_ssh_private_key.pvt
${jira}    jira
${RESOURCE_PATH}    ECOMPPORTAL/auxapi/ticketevent
${GLOBAL_PORTAL_SERVER_URL}         http://vm-ep-dev3.client.research.att.com:8989/
${portal_Template}    ${CURDIR}/portal.template



*** Test Cases ***

Portal Health Check    
     Run Portal Health Check
	 
Portal admin Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    # Setup Browser Now being managed by test case
#    Setup Browser
	Start Virtual Display    1920    1080
	Open Browser    ${PORTAL_LOGIN_URL}    chrome
    #Go To    ${PORTAL_LOGIN_URL}
    Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${PORTAL_URL}${PORTAL_ENV}
   # Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${GLOBAL_PORTAL_ADMIN_USER}
    Input Password    xpath=//input[@ng-model='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Link    xpath=//a[@id='loginBtn']
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}    
    Log    Logged in to ${PORTAL_URL}${PORTAL_ENV}	 
	 
	 
Notification on ONAP Portal
    [Documentation]     Create Config portal
    ${configportal}=     Create Dictionary     jira_id=${jira}
    ${output} =     Fill JSON Template File     ${portal_Template}     ${configportal}
    ${post_resp} =     Enhanced Notification on ONAP Portal     ${RESOURCE_PATH}     ${output}
    Should Be Equal As Strings     ${post_resp.status_code}     200
 
Portal Application Account Management validation   
        [Documentation]    Naviage to user notification tab  
     Click Link    xpath=//a[@id='parent-item-User-Notifications']
     click element    xpath=//*[@id="megamenu-notification-button"] 
        Click element    xpath=//*[@id="notification-history-link"] 
    Wait until Element is visible    xpath=//*[@id="notification-history-table"]    timeout=10 
     Table Column Should Contain    xpath=//*[@id="notification-history-table"]    1    JIRA
     
     
#Portal AAF new fields    
#     [Documentation]    Naviage to user Application details tab 
#    Click Link    xpath=//a[@title='Application Onboarding']
#    Click Element    xpath=//td[contains(.,'Virtual Infrastructure Deployment')]
#    Page Should Contain    Name Space
#    Page Should Contain    Centralized
#	Click Element    xpath=//button[@id='button-notification-cancel']
	
Portal admin Microservice Onboarding
     [Documentation]    Naviage to Edit Functional menu tab
     Click Link    xpath=//a[@title='Microservice Onboarding']
     Click Button    xpath=//button[@id='microservice-onboarding-button-add']
     Input Text    xpath=//input[@name='name']    Test Microservice
     Input Text    xpath=//*[@name='desc']    Test
     Click Element    xpath=//input[@id='microservice-details-input-app']
     Scroll Element Into View    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Click Element     xpath=//*[@name='desc']
     Input Text    xpath=//input[@name='url']    ${PORTAL_MICRO_ENDPOINT}
     Click Element    xpath=//input[@id='microservice-details-input-security-type']
     Scroll Element Into View    xpath=//li[contains(.,'Basic Authentication')]
     Click Element    xpath=//li[contains(.,'Basic Authentication')]
     Input Text    xpath=//input[@name='username']    ${GLOBAL_PORTAL_ADMIN_USER}
     Input Text    xpath=//input[@name='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
     Click Button    xpath=//button[@id='microservice-details-save-button']
     Table Column Should Contain    xpath=//*[@table-data='serviceList']    1    Test Microservice
     #Element Text Should Be    xpath=//*[@table-data='serviceList']    Test Microservice    
     
     
Functional Top Menu Get Access     
    [Documentation]    Naviage to Support tab
     Click Link    xpath=//a[contains(.,'Support')]
     Mouse Over    xpath=//*[contains(text(),'Get Access')]
     Click Link    xpath=//a[contains(.,'Get Access')]
     Element Text Should Be    xpath=//h1[contains(.,'Get Access')]    Get Access
     
     
Functional Top Menu Contact Us     
    [Documentation]    Naviage to Support tab
     Click Link    xpath=//a[contains(.,'Support')]
     Mouse Over    xpath=//*[contains(text(),'Contact Us')]
     Click Link    xpath=//a[contains(.,'Contact Us')]
     Element Text Should Be    xpath=//h1[contains(.,'Contact Us')]    Contact Us    
     Click Image    xpath=//img[@alt='Onap Logo'] 
	 
	 
Notification functionality 
    [Documentation]    Notification functionality
    #Setup Browser
    ${AdminBroadCastMsg}=    Portal Admin Broadcast Notifications 
    set global variable    ${AdminBroadCastMsg} 


Portal admin Logout from Portal GUI
    [Documentation]   Logout from Portal GUI
    Click Element    xpath=//div[@id='header-user-icon']
    Click Button    xpath=//button[contains(.,'Log out')]
    Title Should Be    Login	
	
	
	
#Portal Admin functionality 
#    [Documentation]    ONAP Portal Admin functionality  test
    #Setup Browser
#    Portal admin Login To Portal GUI
#    Portal admin Microservice Onboarding
#    Portal Admin Create Widget for All users
#    Portal Admin Delete Widget for All users 
#    Portal Admin Create Widget for Application Roles
#    Portal Admin Delete Widget for Application Roles 
#    Portal admin Add Application admin User New user -Test
#    Portal admin Add Standard User New user
#    Portal admin Add Application Admin Exiting User -APPDEMO
#    Portal admin Add Application Admin Exiting User 
#    Portal admin Delete Application Admin Existing User
#    Portal admin Add Standard User Existing user  
#    Portal admin Edit Standard User Existing user 
#    Portal admin Delete Standard User Existing user
#    Functional Top Menu Get Access   
#    Functional Top Menu Contact Us
#    Portal admin Edit Functional menu
#    ${AdminBroadCastMsg}=    Portal Admin Broadcast Notifications 
#    set global variable    ${AdminBroadCastMsg}
#    ${AdminCategoryMsg}=   Portal Admin Category Notifications
#    set global variable    ${AdminCategoryMsg}
#    Portal admin Logout from Portal GUI
    
    
#Application Admin functionality 
#   [Documentation]    ONAP Application Admin functionality test 
#   Application admin Login To Portal GUI
#   Application Admin Navigation Application Link Tab 
#   Application Admin Navigation Functional Menu
#   Application admin Add Standard User Existing user  
#   Application admin Edit Standard User Existing user 
#   Application admin Delete Standard User Existing user
#   Application admin Logout from Portal GUI
    
#Standared User functionality 
#    [Documentation]    ONAP Standared User functionality test     
#     Standared user Login To Portal GUI
#     Standared user Navigation Application Link Tab
#     Standared user Navigation Functional Menu 
#     Standared user Broadcast Notifications    ${AdminBroadCastMsg} 
#     Standared user Category Notifications    ${AdminCategoryMsg} 
   
Teardown  
    [Documentation]    Close All Open browsers     
    Close All Browsers    
    

    

    

*** Keywords ***

Setup Browser
    [Documentation]   Sets up browser based upon the value of ${GLOBAL_SELENIUM_BROWSER}
#    Run Keyword If    '${GLOBAL_SELENIUM_BROWSER}' == 'firefox'    Setup Browser Firefox
    Run Keyword If    '${GLOBAL_SELENIUM_BROWSER}' == 'chrome'    Setup Browser Chrome
    Log    Running with ${GLOBAL_SELENIUM_BROWSER}
    
          
 Setup Browser Chrome
    ${os}=   Get Normalized Os 
    Log    Normalized OS=${os}
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${chrome options}    add_argument    no-sandbox
    ${dc}   Evaluate    sys.modules['selenium.webdriver'].DesiredCapabilities.CHROME  sys, selenium.webdriver
    Set To Dictionary   ${dc}   elementScrollBehavior    1
    Create Webdriver    Chrome   chrome_options=${chrome_options}    desired_capabilities=${dc}  
    Set Global Variable    ${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}    ${dc}       

Handle Proxy Warning    
    [Documentation]    Handle Intermediate Warnings from Proxies
    ${status}    ${data}=    Run Keyword And Ignore Error   Variable Should Exist    \${GLOBAL_PROXY_WARNING_TITLE}           
    Return From Keyword if    '${status}' != 'PASS'
    ${status}    ${data}=    Run Keyword And Ignore Error   Variable Should Exist    \${GLOBAL_PROXY_WARNING_CONTINUE_XPATH}          
    Return From Keyword if    '${status}' != 'PASS'
    Return From Keyword if    "${GLOBAL_PROXY_WARNING_TITLE}" == ''
    Return From Keyword if    "${GLOBAL_PROXY_WARNING_CONTINUE_XPATH}" == ''
    ${test}    ${value}=    Run keyword and ignore error    Title Should Be     ${GLOBAL_PROXY_WARNING_TITLE}
    Run keyword If    '${test}' == 'PASS'    Click Element    xpath=${GLOBAL_PROXY_WARNING_CONTINUE_XPATH}






Run Portal Health Check
     [Documentation]    Runs Portal Health check
     ${resp}=    Run Portal Get Request    ${PORTAL_HEALTH_CHECK_PATH}    
     Should Be Equal As Strings 	${resp.status_code} 	200
     Should Be Equal As Strings 	${resp.json()['statusCode']} 	200
Run Portal Get Request
     [Documentation]    Runs Portal Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session 	portal	${PORTAL_URL}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
     ${resp}= 	Get Request 	portal 	${data_path}     headers=${headers}
     Log    Received response from portal ${resp.text}
     [Return]    ${resp}     
     

Portal admin Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    ## Setup Browser Now being managed by test case
    #Setup Browser
	Start Virtual Display    1920    1080
	Open Browser    ${PORTAL_LOGIN_URL}    chrome
    #Go To    ${PORTAL_LOGIN_URL}
    Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${PORTAL_URL}${PORTAL_ENV}
   # Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${GLOBAL_PORTAL_ADMIN_USER}
    Input Password    xpath=//input[@ng-model='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Link    xpath=//a[@id='loginBtn']
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}    
    Log    Logged in to ${PORTAL_URL}${PORTAL_ENV}

Portal admin Go To Portal HOME
    [Documentation]    Naviage to Portal Home
    Go To    ${PORTAL_HOME_URL}
    Wait Until Page Contains Element    xpath=//div[@class='applicationWindow']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}   
    
Portal admin User Notifications 
    [Documentation]    Naviage to User notification tab
    Click Link    xpath=//a[@id='parent-item-User-Notifications']
    Wait Until Element Is Visible    xpath=//h1[@class='heading-page']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Click Button    xpath=//button[@id='button-openAddNewApp']
    Click Button    xpath=(//button[@id='undefined'])[1]
    #Click Button    xpath=//input[@id='datepicker-start']
    

    
    
Portal admin Add Application Admin Exiting User 
    [Documentation]    Naviage to Admins tab
    Wait Until Element Is Visible    xpath=//a[@title='Admins']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Click Link    xpath=//a[@title='Admins']
    Wait Until Element Is Visible    xpath=//h1[contains(.,'Admins')]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Page Should Contain      Admins
	Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@ng-click='admins.openAddNewAdminModal()']
	Input Text    xpath=//input[@id='input-user-search']    ${Existing_User}   
    Click Button    xpath=//button[@id='button-search-users']
    Click Element    xpath=//span[@id='result-uuid-0']
    Click Button    xpath=//button[@id='search-users-button-next']
    Click Button    xpath=//input[@value='Select application']
    Scroll Element Into View    xpath=(//input[@value='Select application']/following::*[contains(text(),'Virtual Infrastructure Deployment' )])[1]
    
    Click Element    xpath=(//li[contains(.,'Virtual Infrastructure Deployment' )])[2]
    #Select From List    xpath=(//input[@value='Select application']/following::*[contains(text(),'Virtual Infrastructure Deployment')])[1]   Virtual Infrastructure Deployment
    Click Button    xpath=//button[@id='div-updateAdminAppsRoles']
    Click Element    xpath=//button[@id='admin-div-ok-button']
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Get Selenium Implicit Wait
    Click Link    xpath=//a[@aria-label='Admins']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment' )]
    Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
    Element Text Should Be      xpath=(//span[contains(.,'portal')])[1]   ${Existing_User}
    
    
Portal admin Delete Application Admin Existing User  
    [Documentation]    Naviage to Admins tab
    Click Element    xpath=(//span[contains(.,'portal')] )[1] 
    Click Element    xpath=//*[@id='select-app-Virtual-Infrastructure-Deployment']/following::i[@id='i-delete-application']
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Click Button    xpath=//button[@id='div-updateAdminAppsRoles']
    Click Element    xpath=//button[@id='admin-div-ok-button']
    #Is Element Visible      xpath=(//span[contains(.,'Portal')] )[2]
    #Is Element Visible    xpath=(//*[contains(.,'Portal')] )[2]
    Element Should Not Contain     xpath=//*[@table-data='admins.adminsTableData']    portal
    
    
Portal admin Add Application admin User New user
    [Documentation]    Naviage to Users tab
    Click Link    xpath=//a[@title='Users']
    Page Should Contain      Users
	Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
    Click Button    xpath=//button[@id='Create-New-User-button']
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.firstName']    ${App_First_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.lastName']    ${App_Last_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.emailAddress']    ${App_Email_Address}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginId']    ${App_LoginID}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwd']    ${App_Loginpwd}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwdCheck']    ${App_LoginPwdCheck}
    Click Button    xpath=//button[@ng-click='searchUsers.addNewUserFun()']
    Click Button    xpath=//button[@id='next-button']
    #Scroll Element Into View    xpath=//div[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
    Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
    Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Go To    ${PORTAL_HOME_PAGE}
     Click Link    xpath=//a[@title='Users']
     Click Element    xpath=//input[@id='dropdown1']
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Input Text    xpath=//input[@id='input-table-search']    ${App_First_Name}
    Element Text Should Be      xpath=(//span[contains(.,'appdemo')] )[1]   ${App_First_Name}
    
    
Portal admin Add Standard User New user
    [Documentation]    Naviage to Users tab
    Click Link    xpath=//a[@title='Users']
    Page Should Contain      Users
	Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
    Click Button    xpath=//button[@id='Create-New-User-button']
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.firstName']    ${Sta_First_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.lastName']    ${Sta_Last_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.emailAddress']    ${Sta_Email_Address}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginId']    ${Sta_LoginID}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwd']    ${Sta_Loginpwd}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwdCheck']    ${Sta_LoginPwdCheck}
    Click Button    xpath=//button[@ng-click='searchUsers.addNewUserFun()']
    Click Button    xpath=//button[@id='next-button']
    #Scroll Element Into View    xpath=//div[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
    Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
    Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Go To    ${PORTAL_HOME_PAGE}
     Click Link    xpath=//a[@title='Users']
     Click Element    xpath=//input[@id='dropdown1']
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Input Text    xpath=//input[@id='input-table-search']    ${Sta_First_Name}
    Element Text Should Be      xpath=(//span[contains(.,'appdemo')] )[1]   ${Sta_First_Name} 
    
    
    
Portal admin Add Application admin User New user -Test
    [Documentation]    Naviage to Users tab
    Click Link    xpath=//a[@title='Users']
    Page Should Contain      Users
	Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
    Click Button    xpath=//button[@id='Create-New-User-button']
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.firstName']    ${Test_First_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.lastName']    ${Test_Last_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.emailAddress']    ${Test_Email_Address}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginId']    ${Test_LoginID}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwd']    ${Test_Loginpwd}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwdCheck']    ${Test_LoginPwdCheck}
    Click Button    xpath=//button[@ng-click='searchUsers.addNewUserFun()']
    Click Button    xpath=//button[@id='next-button']
    #Scroll Element Into View    xpath=//div[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
    Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
    Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Go To    ${PORTAL_HOME_PAGE}
     Click Link    xpath=//a[@title='Users']
     Click Element    xpath=//input[@id='dropdown1']
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Input Text    xpath=//input[@id='input-table-search']    ${Test_First_Name}
    Element Text Should Be      xpath=(//span[contains(.,'appdemo')] )[1]   ${Test_First_Name} 
    
    
    
Portal admin Add Application Admin Exiting User -APPDEMO 
    [Documentation]    Naviage to Admins tab
    Wait Until Element Is Visible    xpath=//a[@title='Admins']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Click Link    xpath=//a[@title='Admins']
    Wait Until Element Is Visible    xpath=//h1[contains(.,'Admins')]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Page Should Contain      Admins
	Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@ng-click='admins.openAddNewAdminModal()']
    Input Text    xpath=//input[@id='input-user-search']    ${App_First_Name}   
    Click Button    xpath=//button[@id='button-search-users']
    Click Element    xpath=//span[@id='result-uuid-0']
    Click Button    xpath=//button[@id='search-users-button-next']
    Click Button    xpath=//input[@value='Select application']
    Scroll Element Into View    xpath=(//input[@value='Select application']/following::*[contains(text(),'Virtual Infrastructure Deployment' )])[1]
    
    Click Element    xpath=(//li[contains(.,'Virtual Infrastructure Deployment' )])[2]
    #Select From List    xpath=(//input[@value='Select application']/following::*[contains(text(),'Virtual Infrastructure Deployment')])[1]   Virtual Infrastructure Deployment
    Click Button    xpath=//button[@id='div-updateAdminAppsRoles']
    Click Element    xpath=//button[@id='admin-div-ok-button']
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Get Selenium Implicit Wait
    Click Link    xpath=//a[@aria-label='Admins']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment' )]
    Input Text    xpath=//input[@id='input-table-search']    ${App_First_Name}
    Element Text Should Be      xpath=(//span[contains(.,'appdemo')])[1]   ${App_First_Name}   
    
    
    
   
    
    
      
Portal admin Add Standard User Existing user   
     [Documentation]    Naviage to Users tab
     Click Link    xpath=//a[@title='Users']
     Page Should Contain      Users
	 Click Button	xpath=//button[@ng-click='toggleSidebar()']
     Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
     Input Text    xpath=//input[@id='input-user-search']    ${Existing_User}
     Click Button    xpath=//button[@id='button-search-users']
     Click Element    xpath=//span[@id='result-uuid-0']
     Click Button    xpath=//button[@id='next-button']
     Click Element    xpath=//*[@id='div-app-name-dropdown-xDemo-App']
     Click Element    xpath=//*[@id='div-app-name-xDemo-App']/following::input[@id='Standard-User-checkbox']
     #Click Element    xpath=//div[@id='div-app-name-dropdown-xDemo-App']
     #Click Element    xpath=//div[@id='div-app-name-xDemo-App']/following::input[@id='Standard-User-checkbox']
     
     Set Selenium Implicit Wait    3000
     Click Button    xpath=//button[@id='new-user-save-button']
     Set Selenium Implicit Wait    3000
     #Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
     #Select From List    xpath=//input[@value='Select application']    xDemo App
     #Click Link    xpath=//a[@title='Users']
     #Page Should Contain      Users
     #Focus    xpath=//input[@name='dropdown1']
    
     Go To    ${PORTAL_HOME_PAGE}
     Click Link    xpath=//a[@title='Users']
     Click Element    xpath=//input[@id='dropdown1']
     #Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Click Element    xpath=//li[contains(.,'XDemo App')]
     Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   Standard User
     
     
Portal admin Edit Standard User Existing user  
     [Documentation]    Naviage to Users tab
     Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
     Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='System-Administrator-checkbox']
     Set Selenium Implicit Wait    3000
     Click Button    xpath=//button[@id='new-user-save-button']
     Set Selenium Implicit Wait    3000
     Page Should Contain      Users
     #Click Button    xpath=//input[@id='dropdown1']
     #Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   System Administrator
     
     
 Portal admin Delete Standard User Existing user    
     [Documentation]    Naviage to Users tab
     Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
     Scroll Element Into View    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::*[@id='app-item-delete'][1]
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::*[@id='app-item-delete'][1]
     Click Element    xpath=//button[@id='div-confirm-ok-button']
     Click Button    xpath=//button[@id='new-user-save-button']
     #Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     #Is Element Visible    xpath=(//*[contains(.,'Portal')] )[2]  
      Element Should Not Contain     xpath=//*[@table-data='users.accountUsers']    portal  
     
     
     
     
Functional Top Menu Get Access     
    [Documentation]    Naviage to Support tab
     Click Link    xpath=//a[contains(.,'Support')]
     Mouse Over    xpath=//*[contains(text(),'Get Access')]
     Click Link    xpath=//a[contains(.,'Get Access')]
     Element Text Should Be    xpath=//h1[contains(.,'Get Access')]    Get Access
     
     
Functional Top Menu Contact Us     
    [Documentation]    Naviage to Support tab
     Click Link    xpath=//a[contains(.,'Support')]
     Mouse Over    xpath=//*[contains(text(),'Contact Us')]
     Click Link    xpath=//a[contains(.,'Contact Us')]
     Element Text Should Be    xpath=//h1[contains(.,'Contact Us')]    Contact Us    
     Click Image    xpath=//img[@alt='Onap Logo'] 
     

Portal admin Edit Functional menu  
    [Documentation]    Naviage to Edit Functional menu tab
    Click Link    xpath=//a[@title='Edit Functional Menu']
    Click Link    xpath=.//*[@id='Manage']/div/a
    Click Link    xpath=.//*[@id='Design']/div/a
    Click Link    xpath=.//*[@id='Product_Design']/div/a
    Open Context Menu    xpath=//*[@id='Product_Design']/div/span
    Click Link    xpath=//a[@href='#add']
    Input Text    xpath=//input[@id='input-title']    ONAP Test
    #Input Text    xpath=//input[@id='input-url']    http://google.com
    Click Element     xpath=//input[@id='select-app']
    Scroll Element Into View    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Input Text    xpath=//input[@id='input-url']    http://google.com
    Click Button    xpath=//button[@id='button-save-continue']
    #Click Button    xpath=//div[@title='Select Roles']
    Click Element    xpath=//*[@id='app-select-Select Roles']
    Click Element    xpath=//input[@id='Standard-User-checkbox']
    Click Element    xpath=//button[@id='button-save-add']
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//a[contains(.,'Manage')]
     Mouse Over    xpath=//*[contains(text(),'Design')]
     Set Selenium Implicit Wait    3000
     Element Text Should Be    xpath=//a[contains(.,'ONAP Test')]      ONAP Test  
     Set Selenium Implicit Wait    3000
      Click Link    xpath=//a[@title='Edit Functional Menu']
    Click Link    xpath=.//*[@id='Manage']/div/a
    Click Link    xpath=.//*[@id='Design']/div/a
    Click Link    xpath=.//*[@id='Product_Design']/div/a
    Open Context Menu    xpath=//*[@id='ONAP_Test']
    Click Link    xpath=//a[@href='#delete']
     Set Selenium Implicit Wait    3000
     Click Element    xpath=//button[@id='div-confirm-ok-button']
     Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//a[contains(.,'Manage')]
     Mouse Over    xpath=//*[contains(text(),'Design')]
     Set Selenium Implicit Wait    3000
     Element Should Not Contain    xpath=(.//*[contains(.,'Design')]/following::ul[1])[1]      ONAP Test  
     
    
        
Portal admin Microservice Onboarding
     [Documentation]    Naviage to Edit Functional menu tab
     Click Link    xpath=//a[@title='Microservice Onboarding']
     Click Button    xpath=//button[@id='microservice-onboarding-button-add']
     Input Text    xpath=//input[@name='name']    Test Microservice
     Input Text    xpath=//*[@name='desc']    Test
     Click Element    xpath=//input[@id='microservice-details-input-app']
     Scroll Element Into View    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Click Element     xpath=//*[@name='desc']
     Input Text    xpath=//input[@name='url']    ${PORTAL_MICRO_ENDPOINT}
     Click Element    xpath=//input[@id='microservice-details-input-security-type']
     Scroll Element Into View    xpath=//li[contains(.,'Basic Authentication')]
     Click Element    xpath=//li[contains(.,'Basic Authentication')]
     Input Text    xpath=//input[@name='username']    ${GLOBAL_PORTAL_ADMIN_USER}
     Input Text    xpath=//input[@name='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
     Click Button    xpath=//button[@id='microservice-details-save-button']
     Table Column Should Contain    xpath=//*[@table-data='serviceList']    1    Test Microservice
     #Element Text Should Be    xpath=//*[@table-data='serviceList']    Test Microservice
     
    
    
Portal Admin Create Widget for All users 
    [Documentation]    Naviage to Create Widget menu tab
    ${WidgetAttachment}=    Catenate    ${PORTAL_ASSETS_DIRECTORY}//widget_news.zip
    Click Link    xpath=//a[@title='Widget Onboarding']
	Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@id='widget-onboarding-button-add']
    Input Text    xpath=//*[@name='name']    ONAP-VID
    Input Text    xpath=//*[@name='desc']    ONAP VID
    Click Element    xpath=//*[@id='widgets-details-input-endpoint-url']
    Scroll Element Into View    xpath=//li[contains(.,'Test Microservice')]
    Click Element    xpath=//li[contains(.,'Test Microservice')]
    Click Element    xpath=//*[contains(text(),'Allow all user access')]/preceding::input[@ng-model='widgetOnboardingDetails.widget.allUser'][1] 
    Choose File    xpath=//input[@id='widget-onboarding-details-upload-file']    ${WidgetAttachment}
    Click Button    xpath=//button[@id='widgets-details-save-button']
    Wait Until Page Contains    ONAP-VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Page Should Contain    ONAP-VID
     Set Selenium Implicit Wait    3000
    GO TO    ${PORTAL_HOME_PAGE}
    
    
Portal Admin Delete Widget for All users 
     [Documentation]    Naviage to delete Widget menu tab
     #Wait Until Page Contains    ONAP-VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
     #Page Should Contain    ONAP-VID
     #Click Image    xpath=//img[@alt='Onap Logo']
     Click Link    xpath=//a[@title='Widget Onboarding']
     Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     #Wait Until Page Contains    xpath=(.//*[contains(text(),'ONAP-VID')]/followi
     #Wait Until Page Contains    xpath=(.//*[contains(text(),'ONAP-VID')]/following::*[@ng-click='widgetOnboarding.deleteWidget(rowData)'])[1]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
     Click Element    xpath=(.//*[contains(text(),'ONAP-VID')]/following::*[@ng-click='widgetOnboarding.deleteWidget(rowData)'])[1]
     Click Element    xpath=//button[@id='div-confirm-ok-button']
     Set Selenium Implicit Wait    3000
     Element Should Not Contain     xpath=//*[@table-data='portalAdmin.portalAdminsTableData']    ONAP-VID
     #Is Element Visible    xpath=//*[@table-data='portalAdmin.portalAdminsTableData']
     #Table Column Should Contain    .//*[@table-data='portalAdmin.portalAdminsTableData']    0       ONAP-VID    
     #Set Selenium Implicit Wait    3000
    
    
Portal Admin Create Widget for Application Roles 
    [Documentation]    Naviage to Create Widget menu tab 
    ${WidgetAttachment}=    Catenate    ${PORTAL_ASSETS_DIRECTORY}//widget_news.zip 
    Click Link    xpath=//a[@title='Widget Onboarding'] 
	Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@id='widget-onboarding-button-add'] 
    Input Text    xpath=//*[@name='name']    ONAP-VID 
    Input Text    xpath=//*[@name='desc']    ONAP VID 
    Click Element    xpath=//*[@id='widgets-details-input-endpoint-url'] 
    Scroll Element Into View    xpath=//li[contains(.,'Test Microservice')] 
    Click Element    xpath=//li[contains(.,'Test Microservice')] 
    Click element    xpath=//*[@id="app-select-Select Applications"] 
    click element    xpath=//*[@id="Virtual-Infrastructure-Deployment-checkbox"] 
    Click element    xpath=//*[@name='desc'] 
    click element    xpath=//*[@id="app-select-Select Roles"] 
    click element    xpath=//*[@id="Standard-User-checkbox"] 
    Click element    xpath=//*[@name='desc'] 
    Scroll Element Into View    xpath=//input[@id='widget-onboarding-details-upload-file'] 
    Choose File    xpath=//input[@id='widget-onboarding-details-upload-file']    ${WidgetAttachment} 
    Click Button    xpath=//button[@id='widgets-details-save-button'] 
     Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    #Wait Until Page Contains    ONAP-VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Click Link    xpath=//a[@title='Widget Onboarding'] 
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Page Should Contain    ONAP-VID 
    Set Selenium Implicit Wait    3000 
    GO TO    ${PORTAL_HOME_PAGE}
    
    
    
    
 Portal Admin Delete Widget for Application Roles 
     [Documentation]    Naviage to delete Widget menu tab
     #Wait Until Page Contains    ONAP-VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
     #Page Should Contain    ONAP-VID
     #Click Image    xpath=//img[@alt='Onap Logo']
     Click Link    xpath=//a[@title='Widget Onboarding']
     Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     #Wait Until Page Contains    xpath=(.//*[contains(text(),'ONAP-VID')]/following::*[@ng-click='widgetOnboarding.deleteWidget(rowData)'])[1]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
     Click Element    xpath=(.//*[contains(text(),'ONAP-VID')]/following::*[@ng-click='widgetOnboarding.deleteWidget(rowData)'])[1]
     Click Element    xpath=//button[@id='div-confirm-ok-button']
     Set Selenium Implicit Wait    3000
     Element Should Not Contain     xpath=//*[@table-data='portalAdmin.portalAdminsTableData']    ONAP-VID
     #Is Element Visible    xpath=//*[@table-data='portalAdmin.portalAdminsTableData']
     #Table Column Should Contain    .//*[@table-data='portalAdmin.portalAdminsTableData']    0       ONAP-VID    
     #Set Selenium Implicit Wait    3000   
    
    
    
Portal Admin Edit Widget
    [Documentation]    Naviage to Home tab  
    #Mouse Over    xpath=(//h3[contains(text(),'News')]/following::span[1])[1]
    Click Element    xpath=(//h3[contains(text(),'News')]/following::span[1])[1]
    Set Browser Implicit Wait    8000
    #Wait Until Element Is Visible    xpath=(//h3[contains(text(),'News')]/following::span[1]/following::a[contains(text(),'Edit')])[1]    60
    Mouse Over    xpath=(//h3[contains(text(),'News')]/following::span[1]/following::a[contains(text(),'Edit')])[1] 
    Click Link    xpath=(//h3[contains(text(),'News')]/following::span[1]/following::a[contains(text(),'Edit')])[1]
    Input Text    xpath=//input[@name='title']    ONAP_VID
    Input Text    xpath=//input[@name='url']    http://about.att.com/news/international.html
    Input Text    xpath=//input[@id='widget-input-add-order']    5
    Click Link    xpath=//a[contains(.,'Add New')]
    Click Element    xpath=//div[@id='close-button']
    Element Should Contain    xpath=//*[@table-data='ignoredTableData']    ONAP_VID
    Click Element    xpath=.//div[contains(text(),'ONAP_VID')]/following::*[contains(text(),'5')][1]/following::div[@ng-click='remove($index);'][1]
    Click Element    xpath=//div[@id='confirmation-button-next']
    Element Should Not Contain    xpath=//*[@table-data='ignoredTableData']    ONAP_VID
    Click Link    xpath=//a[@id='close-button']
    
    
    
    
Portal Admin Broadcast Notifications 
    [Documentation]   Portal Test Admin Broadcast Notifications 
    ${CurrentDay}=    Get Current Date    result_format=%m/%d/%Y 
    ${NextDay}=    Get Current Date    increment=24:00:00    result_format=%m/%d/%Y 
    ${CurrentDate}=    Get Current Date    result_format=%m%d%y%H%M
    ${AdminBroadCastMsg}=    catenate    ONAP VID Broadcast Automation${CurrentDate} 
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//*[@id="parent-item-User-Notifications"] 
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10 
    Click button    xpath=//*[@id="button-openAddNewApp"] 
    Input Text    xpath=//input[@id='datepicker-start']     ${CurrentDay} 
    Input Text    xpath=//input[@id='datepicker-end']     ${NextDay} 
    Input Text    xpath=//*[@id="add-notification-input-title"]    ONAP VID Broadcast Automation 
    Input Text    xpath=//*[@id="user-notif-input-message"]    ${AdminBroadCastMsg} 
    click element    xpath=//*[@id="button-notification-save"] 
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10 
    click element    xpath=//*[@id="megamenu-notification-button"] 
    click element    xpath=//*[@id="notification-history-link"] 
    Wait until Element is visible    xpath=//*[@id="notification-history-table"]    timeout=10 
    Table Column Should Contain    xpath=//*[@id="notification-history-table"]    2    ${AdminBroadCastMsg} 
    log    ${AdminBroadCastMsg} 
    [Return]     ${AdminBroadCastMsg}
        
Portal Admin Category Notifications 
    [Documentation]   Portal Admin Broadcast Notifications 
    ${CurrentDay}=    Get Current Date    result_format=%m/%d/%Y 
    ${NextDay}=    Get Current Date    increment=24:00:00    result_format=%m/%d/%Y 
    ${CurrentDate}=    Get Current Date    result_format=%m%d%y%H%M
    ${AdminCategoryMsg}=    catenate    ONAP VID Category Automation${CurrentDate} 
    Click Link    xpath=//a[@id='parent-item-Home'] 
    Click Link    xpath=//*[@id="parent-item-User-Notifications"] 
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10 
    Click button    xpath=//*[@id="button-openAddNewApp"]
    #Select Radio Button    NO     radio-button-no
    Click Element    //*[contains(text(),'Broadcast to All Categories')]/following::*[contains(text(),'No')][1]
    #Select Radio Button    //label[@class='radio']    radio-button-approles
    Click Element    xpath=//*[contains(text(),'Categories')]/following::*[contains(text(),'Application Roles')][1]
    Click Element    xpath=//*[contains(text(),'Virtual Infrastructure Deployment')]/preceding::input[@ng-model='member.isSelected'][1] 
    Input Text    xpath=//input[@id='datepicker-start']     ${CurrentDay} 
    Input Text    xpath=//input[@id='datepicker-end']     ${NextDay} 
    Input Text    xpath=//*[@id="add-notification-input-title"]    ONAP VID Category Automation 
    Input Text    xpath=//*[@id='user-notif-input-message']    ${AdminCategoryMsg} 
    click element    xpath=//*[@id="button-notification-save"] 
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10 
    click element    xpath=//*[@id="megamenu-notification-button"] 
    click element    xpath=//*[@id="notification-history-link"] 
    Wait until Element is visible    xpath=//*[@id="notification-history-table"]    timeout=10 
    Table Column Should Contain    xpath=//*[@id="notification-history-table"]    2    ${AdminCategoryMsg} 
    log    ${AdminCategoryMsg}   
     [Return]     ${AdminCategoryMsg}  
    
    
 Portal admin Logout from Portal GUI
    [Documentation]   Logout from Portal GUI
    Click Element    xpath=//div[@id='header-user-icon']
    Click Button    xpath=//button[contains(.,'Log out')]
    Title Should Be    Login
    
    
    
Application admin Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    # Setup Browser Now being managed by test case
    ##Setup Browser
    Go To    ${PORTAL_LOGIN_URL}
    Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${PORTAL_URL}${PORTAL_ENV}
   # Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${App_LoginID}
    Input Password    xpath=//input[@ng-model='password']    ${App_Loginpwd}
    Click Link    xpath=//a[@id='loginBtn']
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}    
    Log    Logged in to ${PORTAL_URL}${PORTAL_ENV}    
    
Application Admin Navigation Application Link Tab    
    [Documentation]   Logs into Portal GUI as application admin
    Click Link    xpath=//a[@id='parent-item-Home']
    Click Element    xpath=.//h3[contains(text(),'Virtual Infras...')]/following::div[1]
    Page Should Contain    Welcome to VID
    Click Element    xpath=//i[@class='ion-close-round']    
    Click Element    xpath=(.//span[@id='tab-Home'])[1]
    
    
Application Admin Navigation Functional Menu     
    [Documentation]   Logs into Portal GUI as application admin
    Click Link    xpath=//a[contains(.,'Manage')]
     Mouse Over    xpath=//*[contains(text(),'Technology Insertion')]
     Click Link    xpath= //*[contains(text(),'Infrastructure VNF Provisioning')] 
     Page Should Contain    Welcome to VID
     Click Element    xpath=//i[@class='ion-close-round']
     Click Element    xpath=(.//span[@id='tab-Home'])[1]
     
     
Application admin Add Standard User Existing user   
     [Documentation]    Naviage to Users tab
     Click Link    xpath=//a[@title='Users']
     Page Should Contain      Users
	 Click Button	xpath=//button[@ng-click='toggleSidebar()']
     Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
     Input Text    xpath=//input[@id='input-user-search']    ${Existing_User}
     Click Button    xpath=//button[@id='button-search-users']
     Click Element    xpath=//span[@id='result-uuid-0']
     Click Button    xpath=//button[@id='next-button']
     Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
     Set Selenium Implicit Wait    3000
     Click Button    xpath=//button[@id='new-user-save-button']
     Set Selenium Implicit Wait    3000
     #Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
     #Select From List    xpath=//input[@value='Select application']    Virtual Infrastructure Deployment
     #Click Link    xpath=//a[@title='Users']
     #Page Should Contain      Users
     Go To    ${PORTAL_HOME_PAGE}
     Set Selenium Implicit Wait    3000
     Click Link    xpath=//a[@title='Users']
     Click Element    xpath=//input[@id='dropdown1']
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   Standard User
     
     
Application admin Edit Standard User Existing user  
     [Documentation]    Naviage to Users tab
     Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
     Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='System-Administrator-checkbox']
     Set Selenium Implicit Wait    3000
     Click Button    xpath=//button[@id='new-user-save-button']
     Set Selenium Implicit Wait    3000
     Page Should Contain      Users
     #Click Button    xpath=//input[@id='dropdown1']
     #Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   System Administrator
     
     
Application admin Delete Standard User Existing user    
     [Documentation]    Naviage to Users tab
     Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
     Scroll Element Into View    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::*[@id='app-item-delete'][1]
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::*[@id='app-item-delete'][1]
     Click Element    xpath=//button[@id='div-confirm-ok-button']
     Click Button    xpath=//button[@id='new-user-save-button']
     #Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     #Is Element Visible    xpath=(//*[contains(.,'Portal')] )[2] 
     Element Should Not Contain     xpath=//*[@table-data='users.accountUsers']    Portal   
     
     
     
Application admin Logout from Portal GUI
    [Documentation]   Logout from Portal GUI
    Click Element    xpath=//div[@id='header-user-icon']
    Click Button    xpath=//button[contains(.,'Log out')]
    #Confirm Action	
    Title Should Be    Login   
    
    
Standared user Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    # Setup Browser Now being managed by test case
    ##Setup Browser
    Go To    ${PORTAL_LOGIN_URL}
    Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${PORTAL_URL}${PORTAL_ENV}
   # Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${Sta_LoginID}
    Input Password    xpath=//input[@ng-model='password']    ${Sta_Loginpwd}
    Click Link    xpath=//a[@id='loginBtn']
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}    
    Log    Logged in to ${PORTAL_URL}${PORTAL_ENV}       
     
 
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
	
	
Enhanced Notification on ONAP Portal
    [Documentation]     Runs portal Post request
    [Arguments]     ${data_path}     ${data}
#   Log     Creating session         ${PORTAL_URL}
    ${session}=         Create Session     portal         ${PORTAL_URL}
    ${headers}=     Create Dictionary     Accept=application/json    Content-Type=application/json    Authorization=Basic amlyYTpfcGFzcw==    username=jira    password=_pass
    ${resp}=     Post Request     portal     ${data_path}     data=${data}     headers=${headers}
#    Log     Received response from portal     ${resp.text}
    [Return]     ${resp}    
    

 
Notification on ONAP Portal
    [Documentation]     Create Config portal
    ${configportal}=     Create Dictionary     jira_id=${jira}
    ${output} =     Fill JSON Template File     ${portal_Template}     ${configportal}
    ${post_resp} =     Enhanced Notification on ONAP Portal     ${RESOURCE_PATH}     ${output}
    Should Be Equal As Strings     ${post_resp.status_code}     200
 
    
   
    
Portal Application Account Management
     [Documentation]    Naviage to Application Account Management tab
     Click Link    xpath=//a[@title='App Account Management']
     Click Button    xpath=//button[@id='account-onboarding-button-add']
     Input Text    xpath=//input[@name='name']    JIRA
     Input Text    xpath=//input[@name='username']    jira
     Input Text    xpath=//input[@name='password']    _pass
     Input Text    xpath=//input[@name='repassword']    _pass
     Click Element    xpath=//div[@ng-click='accountAddDetails.saveChanges()']
     Element Text Should Be    xpath=//*[@table-data='serviceList']    JIRA  
     
Portal Application Account Management validation   
        [Documentation]    Naviage to user notification tab  
     Click Link    xpath=//a[@id='parent-item-User-Notifications']
     click element    xpath=//*[@id="megamenu-notification-button"] 
        Click element    xpath=//*[@id="notification-history-link"] 
    Wait until Element is visible    xpath=//*[@id="notification-history-table"]    timeout=10 
     Table Column Should Contain    xpath=//*[@id="notification-history-table"]    1    JIRA
     
     
Portal AAF new fields    
     [Documentation]    Naviage to user Application details tab 
    Click Link    xpath=//a[@title='Application Onboarding']
    Click Element    xpath=//td[contains(.,'Virtual Infrastructure Deployment')]
    Page Should Contain    Name Space
    Page Should Contain    Centralized
	Click Element    xpath=//button[@id='button-notification-cancel']
	
	
