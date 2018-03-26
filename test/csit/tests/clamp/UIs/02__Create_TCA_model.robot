*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     Selenium2Library
Library     XvfbRobot

*** Variables ***
${SELENIUM_SPEED_FAST}       .2 seconds
${SELENIUM_SPEED_SLOW}       .5 seconds

*** Test Cases ***
Get Requests health check ok
    CreateSession   clamp  http://localhost:8080
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200

Open Browser
# Next line is to be enabled for Headless tests only (jenkins?). To see the tests disable the line.
    Start Virtual Display    1920    1080
    Open Browser    http://localhost:8080/designer/index.html    browser=firefox
    Set Selenium Speed      ${SELENIUM_SPEED_SLOW}
    Set Window Size    1920    1080
    ${title}=    Get Title
    Should Be Equal    CLDS    ${title}

Good Login to Clamp UI and Verify logged in
    Input Text      locator=username    text=admin
    Input Text      locator=password    text=password
    Press Key    locator=password       key=\\13
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
    Select From List By Label       id=actionSet      eNodeB
    Select From List By Label       id=location      Data Center 1      Data Center 3
    Click Button    locator=Save

Set Policy Box properties for TCAModel1
    Wait Until Element Is Visible       xpath=//*[@data-element-id="Policy_12lup3h"]      timeout=60
    Click Element    xpath=//*[@data-element-id="Policy_12lup3h"]
    Click Button    locator=New Policy
    Input Text      locator=//*[@id="pname"]      text=Policy2
    Select From List By Label       id=recipe      Reset
    Input Text      locator=maxRetries      text=6
    Input Text      locator=retryTimeLimit      text=280
    Input Text      locator=timeout      text=400
    Click Button    locator=Close

### Cannot set TCA box attributes due to element not interractable with Selenium

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

Verify TCA CL well create
    ${auth}=    Create List     admin    password
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/model-names
    Should Contain Match    ${resp}   *TCAModel1*
    Should Not Contain Match    ${resp}   *TCAModel99*
