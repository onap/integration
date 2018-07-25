*** Settings ***
Documentation    This is RobotFrame work script
Library    ExtendedSelenium2Library
Library    OperatingSystem
Library     	XvfbRobot


*** Variables ***
${PORTAL_URL}		http://portal.api.simpledemo.onap.org:8990
${PORTAL_ENV}            /ONAPPORTALSDK
${PORTAL_LOGIN_URL}                ${PORTAL_URL}${PORTAL_ENV}/login.htm
${PORTAL_HOME_PAGE}        ${PORTAL_URL}${PORTAL_ENV}/welcome
${PORTAL_MICRO_ENDPOINT}    ${PORTAL_URL}${PORTAL_ENV}/commonWidgets
${PORTAL_HOME_URL}                ${PORTAL_URL}${PORTAL_ENV}/applicationsHome
${GLOBAL_APPLICATION_ID}           robot-functional
${GLOBAL_PORTAL_ADMIN_USER}		demo
${GLOBAL_PORTAL_ADMIN_PWD}		demo
${GLOBAL_SELENIUM_BROWSER}        chrome
${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}        Create Dictionary
${GLOBAL_SELENIUM_DELAY}          0
${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}        5
${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}        15
${GLOBAL_BUILD_NUMBER}    0
${GLOBAL_VM_PRIVATE_KEY}   ${EXECDIR}/robot/assets/keys/robot_ssh_private_key.pvt


*** Test Cases ***

#Portal admin Login To Portal GUI
#    [Documentation]   Logs into Portal GUI
##    Setup Browser
#	Start Virtual Display    1920    1080
#	Open Browser    ${PORTAL_LOGIN_URL}    chrome
##    Go To    ${PORTAL_LOGIN_URL}
#    Maximize Browser Window
#    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
#    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
#    Log    Logging in to ${PORTAL_URL}${PORTAL_ENV}
#    # Handle Proxy Warning
#    Title Should Be    Login
#    Input Text    xpath=//input[@id='loginId']    ${GLOBAL_PORTAL_ADMIN_USER}
#    Input Password    xpath=//input[@id='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
#    Click Element    //*[@id="loginBtn"]
#    Wait Until Page Contains Element    xpath=//img[@src='app/fusionapp/icons/logo_onap_transbg.png']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
#    Log    Logged in to ${PORTAL_URL}${PORTAL_ENV}

SDKPortalAdmin Navigation Application Link Tab
    [Documentation]    Logs into Portal GUI as Portal admin
    Comment    Click Element    xpath=.//h3[contains(text(),'xDemo App')]/following::div[1]
    Comment    Go To    ${PORTAL_HOME_PAGE}
    Comment    Dismiss Alert    accept=false
    #Scroll Element Into View    xpath=//span[@id='tab-Home']
    #Click Element    xpath=//span[@id='tab-Home']
    #Click Element    xpath=(//span[@id='tab-xDemo-App']/following::i[@class='ion-close-round'])[1]
    Comment    Click Element    xpath=.//h3[contains(text(),'xDemo App')]/following::div[1]

#Validate SDK Sub Menu
#    [Documentation]    Logs into SDK GUI as Portal admin
#    Page Should Contain    Home
#    Page Should Contain    Sample Pages
#    Page Should Contain    Reports
#    Page Should Contain    Profile
#    Page Should Contain    Admin

##Click Sample Pages and validate sub Menu
#    #[Documentation]    Click Sample Pages
#    #Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    #Click Link    xpath=//a[@id='parent-item-Sample-Pages']
#    #Element Text Should Be    xpath=//a[@title='Collaboration']    Collaboration
#    #Element Text Should Be    xpath=//a[@title='Notebook']    Notebook
#    #Click Link    xpath=//a[contains(@title,'Collaboration')]
#    #Page Should Contain    User List
#    #Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    #Click Link    xpath=//a[@id='parent-item-Sample-Pages']
#    #Click Link    xpath=//a[contains(@title,'Notebook')]
#    #Element Text Should Be    xpath=//h1[contains(.,'Notebook')]    Notebook

#Click Reports and validate sub Menu
#    [Documentation]    Click Reports Tab
#    #Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    Click Link    xpath=//a[@id='parent-item-Reports']
#    Element Text Should Be    xpath=//a[@title='All Reports']    All Reports
#    Element Text Should Be    xpath=//a[@title='Create Reports']    Create Reports
#    Click Link    xpath=//a[contains(@title,'All Reports')]
#    Page Should Contain    Report search
#    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    Click Link    xpath=//a[@id='parent-item-Reports']
#    Click Link    xpath=//a[contains(@title,'Create Reports')]
#    Page Should Contain    Report Wizard

#Click Profile and validate sub Menu
#    [Documentation]    Click Profile Tab
#    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    Click Link    xpath=//a[@id='parent-item-Profile']
#    Element Text Should Be    xpath=//a[@title='Search']    Search
#    Element Text Should Be    xpath=//a[@title='Self']    Self
#    Click Link    xpath=//a[contains(@title,'Search')]
#    Page Should Contain    Profile Search
#    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    Click Link    xpath=//a[@id='parent-item-Profile']
#    Click Link    xpath=//a[contains(@title,'Self')]
#    Page Should Contain    Self Profile Detail

#Click Admin and validate sub Menu
#    [Documentation]    Click Admin Tab
#    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    Click Link    xpath=//a[@id='parent-item-Admin']
#    Element Text Should Be    xpath=//a[@title='Roles']    Roles
#    Element Text Should Be    xpath=//a[@title='Role Functions']    Role Functions
#    Element Text Should Be    xpath=//a[@title='Cache Admin']    Cache Admin
#    Element Text Should Be    xpath=//a[@title='Menus']    Menus
#    Element Text Should Be    xpath=//a[@title='Usage']    Usage
#    Click Link    xpath=//a[contains(@title,'Roles')]
#    Page Should Contain    Roles
#    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    Click Link    xpath=//a[@id='parent-item-Admin']
#    Click Link    xpath=//a[contains(@title,'Role Function')]
#    Page Should Contain    Role Function
#    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    Click Link    xpath=.//a[@id='parent-item-Admin']
#    #Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    Click Link    xpath=//a[@id='parent-item-Admin']
#    Click Link    xpath=//a[contains(@title,'Cache Admin')]
#    Page Should Contain    Cache Regions
#    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    Click Link    xpath=.//a[@id='parent-item-Admin']
#    Click Link    xpath=//a[@id='parent-item-Admin']
#    Click Link    xpath=//a[contains(@title,'Menus')]
#    Page Should Contain    Admin Menu Items
#    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
#    Click Link    xpath=//a[@id='parent-item-Admin']
#    Click Link    xpath=//a[@id='parent-item-Admin']
#    Click Link    xpath=//a[contains(@title,'Usage')]
#    Page Should Contain    Current Usage

Teardown
    [Documentation]    Close All Open browsers
    Close All Browsers

*** Keywords ***
