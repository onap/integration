*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     Selenium2Library
Library     XvfbRobot


*** Test Cases ***
Get Requests health check ok
    CreateSession   clamp  http://localhost:8080
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200

Open Browser
# Next line is to be enabled for Headless tests only (jenkins?). To see the tests desable the line.
    Start Virtual Display    1920    1080
    Open Browser    http://localhost:8080/designer/index.html    browser=firefox
    Set Selenium Speed      2 seconds
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
    Click Element    xpath=//*[@id="navbar"]/ul/li[2]/a
    Wait Until Element Is Visible       locator=Create CL       timeout=60
    Click Element    locator=Create CL
    Input Text      locator=modelName       text=TCAModel
    Select From List By Label       id=templateName      TCATemplate
    Click Button    locator=Create

Save Model from Menu
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[2]/a      timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[2]/a
    Wait Until Element Is Visible       locator=Save CL      timeout=60
    Click Element    locator=Save CL
    Wait Until Element Is Visible       xpath=//*[@id="alert_message_"]      timeout=60
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:SAVE

Close Browser
    Close Browser
