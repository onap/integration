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

*** Test Cases ***
Get Requests health check ok
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
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[2]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Create CL       timeout=60
    Click Element    locator=Create CL
    Input Text      locator=modelName       text=TCAModel1
    Select From List By Label       id=templateName      templateTCA1
    Click Button    locator=Create

Set Properties for TCAModel1
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[1]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Properties CL       timeout=60
    Click Element    locator=Properties CL
    Select From List By Label       id=service       vLoadBalancer
    Select From List By Label       id=vf       vLoadBalancer 0
    Select From List By Label       id=actionSet      VNF
    Select From List By Label       id=location      Data Center 1      Data Center 3
    Input Text      locator=deployParameters       text={}
    Click Button    locator=Save

Set Policy Box properties for TCAModel1
    Wait Until Element Is Visible       xpath=//*[@data-element-id="Policy_12lup3h"]      timeout=60
    Click Element    xpath=//*[@data-element-id="Policy_12lup3h"]
    Click Button    locator=New Policy
    Input Text      locator=//*[@id="pname"]      text=Policy2
    Select From List By Label       id=recipe      Restart
    Input Text      locator=maxRetries      text=6
    Input Text      locator=retryTimeLimit      text=280
    Input Text      locator=timeout      text=400
    Click Button    locator=Close

Set TCA Box properties for TCAModel1
    Wait Until Element Is Visible       xpath=//*[@data-element-id="Policy_12lup3h"]      timeout=60
    Click Element    xpath=//*[@data-element-id="TCA_1d13unw"]
    Input Text      xpath=(//input[@id='tname'])[2]      text=TCA1
    Select From List By Label       xpath=//*[@id="tcaPol"]      Policy2
    Select From List By Label       xpath=//*[@id="eventName"]      vLoadBalancer
### Cannot set all TCA box attributes due to element not interractable with Selenium
#    Select From List By Label       xpath=//*[@id="controlLoopSchemaType"]       VNF
#    Select From List By Index       xpath=//*[@id="controlLoopSchemaType"]       1
    Click Element    xpath=(//button[@id='createNewThresh'])[2]
    Input Text      xpath=(//input[@id='threshold'])[2]          6
#    Select From List By Label       xpath=//*[@id="closedLoopEventStatus"]        ONSET
    Click Button    id=savePropsBtn

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
