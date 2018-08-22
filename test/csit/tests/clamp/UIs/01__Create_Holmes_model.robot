*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     ../../../scripts/clamp/python-lib/CustomSeleniumLibrary.py
Library     XvfbRobot

*** Variables ***
${login}                     admin
${passw}                     password
${SELENIUM_SPEED_FAST}       .2 seconds
${SELENIUM_SPEED_SLOW}       .5 seconds
${BASE_URL}                  https://localhost:8443

*** Keywords ***
Create the sessions
    ${auth}=    Create List     ${login}    ${passw}
    Create Session   clamp  ${BASE_URL}    auth=${auth}   disable_warnings=1
    Set Global Variable     ${clamp_session}      clamp

*** Test Cases ***
Get Requests health check ok
    Create the sessions
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200

Open Browser
# Next line is to be enabled for Headless tests only (jenkins?). To see the tests disable the line.
    Start Virtual Display    1920    1080
    Set Selenium Speed      ${SELENIUM_SPEED_SLOW}
    Open Browser    ${BASE_URL}/designer/index.html    browser=firefox

Reply to authentication popup
    Run Keyword And Ignore Error    Insert into prompt    ${login} ${passw}
    Confirm action

Good Login to Clamp UI and Verify logged in
    Set Window Size    1920    1080
    ${title}=    Get Title
    Should Be Equal    CLDS    ${title}
    Wait Until Element Is Visible       xpath=//*[@class="navbar-brand logo_name ng-binding"]       timeout=60
    Element Text Should Be      xpath=//*[@class="navbar-brand logo_name ng-binding"]       expected=Hello:admin

Create Model from Menu
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[1]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Create CL       timeout=60
    Click Element    locator=Create CL
    Input Text      locator=modelName       text=HolmesModel1
    Select From List By Label       id=templateName      templateHolmes1
    Click Button    locator=Create

Set Properties for HolmesModel1
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[1]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Properties CL       timeout=60
    Click Element    locator=Properties CL
    Select From List By Label       id=service      vFirewall
    Select From List By Label       id=vf      vFirewall 0
    Select From List By Label       id=actionSet      VNF
    Select From List By Label       id=location      Data Center 2      Data Center 3
    Input Text      locator=deployParameters       text={}
    Click Button    locator=Save

Set Policy Box properties for HolmesModel1
    Wait Until Element Is Visible       xpath=//*[@data-element-id="Policy_136qatf"]      timeout=60
    Click Element    xpath=//*[@data-element-id="Policy_136qatf"]
    Click Button    locator=New Policy
    Input Text      locator=//*[@id="pname"]      text=Policy1
    Select From List By Label       id=recipe      Migrate
    Input Text      locator=maxRetries      text=5
    Input Text      locator=retryTimeLimit      text=240
    Input Text      locator=timeout      text=390
    Click Button    locator=Close

Set Holmes Box properties for HolmesModel1
    Wait Until Element Is Visible       xpath=//*[@data-element-id="Holmes_1gxp0mm"]      timeout=60
    Click Element    xpath=//*[@data-element-id="Holmes_1gxp0mm"]
    Input Text      locator=correlationalLogic     text=correlational Logic1
    Input Text      locator=configPolicyName     text=config Policy Name1
    Click Button    locator=Save

Save Model from Menu
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[1]/a      timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Save CL      timeout=60
    Set Selenium Speed      ${SELENIUM_SPEED_FAST}
    Click Element    locator=Save CL
    Wait Until Element Is Visible       xpath=//*[@id="alert_message_"]      timeout=60
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:SAVE
    Set Selenium Speed      ${SELENIUM_SPEED_SLOW}

Close Browser
    Close Browser
