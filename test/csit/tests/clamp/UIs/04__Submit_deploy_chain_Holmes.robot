*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     Selenium2Library
Library     XvfbRobot

*** Variables ***
${login}                     admin
${passw}                     password
${SELENIUM_SPEED_FAST}       .2 seconds
${SELENIUM_SPEED_SLOW}       .5 seconds
${BASE_URL}                  https://localhost:8443

*** Test Cases ***
Get Requests health check ok
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200

Open Browser
# Next line is to be enabled for Headless tests only (jenkins?). To see the tests disable the line.
    Start Virtual Display    1920    1080
    Open Browser    ${BASE_URL}/designer/index.html    browser=firefox
    Set Selenium Speed      ${SELENIUM_SPEED_SLOW}
    Set Window Size    1920    1080
    ${title}=    Get Title
    Should Be Equal    CLDS    ${title}

Good Login to Clamp UI and Verify logged in
    Wait Until Element Is Visible       xpath=//*[@class="navbar-brand logo_name ng-binding"]       timeout=60
    Element Text Should Be      xpath=//*[@class="navbar-brand logo_name ng-binding"]       expected=Hello:admin

Open Holmes CL
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[1]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Open CL       timeout=60
    Click Element    locator=Open CL
    Select From List By Label       id=modelName      HolmesModel1
    Click Button    locator=OK
    Element Should Contain      xpath=//*[@id="modeler_name"]     Closed Loop Modeler - HolmesModel1
    Element Should Contain      xpath=//*[@id="status_clds"]     DESIGN

Validate-Test Holmes CL
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[2]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[2]/a
    Wait Until Element Is Visible       locator=Validation Test       timeout=60
    Click Element    locator=Validation Test
    Wait Until Element Is Visible       xpath=//*[@id="alert_message_"]      timeout=60
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:TEST
    Element Should Contain      xpath=//*[@id="status_clds"]     DESIGN

Submit Holmes CL
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[2]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[2]/a
    Wait Until Element Is Visible       locator=Submit       timeout=60
    Click Element    locator=Submit
    Click Button    locator=Yes
    Wait Until Element Is Visible       xpath=//*[@id="alert_message_"]      timeout=60
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:SUBMIT
    Element Should Contain      xpath=//*[@id="status_clds"]     DISTRIBUTED

Resubmit Holmes CL
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[2]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[2]/a
    Wait Until Element Is Visible       locator=Resubmit       timeout=60
    Click Element    locator=Resubmit
    Click Button    locator=Yes
    Wait Until Element Is Visible       xpath=//*[@id="alert_message_"]      timeout=60
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:RESUBMIT
    Element Should Contain      xpath=//*[@id="status_clds"]     DISTRIBUTED

Deploy Holmes CL
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[2]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[2]/a
    Wait Until Element Is Visible       locator=Deploy       timeout=60
    Click Element    locator=Deploy
#    Wait Until Element Is Visible       xpath=//*[@id="deployProperties"]       timeout=60
#    Input Text      xpath=//*[@id="deployProperties"]      text={}
    Click Button    locator=Deploy
    Click Button    locator=Yes
    Wait Until Element Is Visible       xpath=//*[@id="alert_message_"]      timeout=60
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:deploy
    Element Should Contain      xpath=//*[@id="status_clds"]     ACTIVE

Update Holmes CL
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[2]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[2]/a
    Wait Until Element Is Visible       locator=Update       timeout=60
    Click Element    locator=Update
    Click Button    locator=Yes
    Wait Until Element Is Visible       xpath=//*[@id="alert_message_"]      timeout=60
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:UPDATE
    Element Should Contain      xpath=//*[@id="status_clds"]     ACTIVE

Stop Holmes CL
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[2]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[2]/a
    Wait Until Element Is Visible       locator=Stop       timeout=60
    Click Element    locator=Stop
    Click Button    locator=Yes
    Wait Until Element Is Visible       xpath=//*[@id="alert_message_"]      timeout=60
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:STOP
    Element Should Contain      xpath=//*[@id="status_clds"]     STOPPED

Restart Holmes CL
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[2]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[2]/a
    Wait Until Element Is Visible       locator=Restart       timeout=60
    Click Element    locator=Restart
    Click Button    locator=Yes
    Wait Until Element Is Visible       xpath=//*[@id="alert_message_"]      timeout=60
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:RESTART
    Element Should Contain      xpath=//*[@id="status_clds"]     ACTIVE

UnDeploy Holmes CL
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[2]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[2]/a
    Wait Until Element Is Visible       locator=UnDeploy       timeout=60
    Click Element    locator=UnDeploy
    Click Button    locator=Yes
    Wait Until Element Is Visible       xpath=//*[@id="alert_message_"]      timeout=60
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:undeploy
    Element Should Contain      xpath=//*[@id="status_clds"]     DISTRIBUTED

Close Browser
    Close Browser
