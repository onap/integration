*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP
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
    Set Selenium Speed      .2 seconds
    Set Window Size    1920    1080
    ${title}=    Get Title
    Should Be Equal    CLDS    ${title}

Bad Login to Clamp UI and Verify not logged in
    Input Text      locator=username    text=bad_login
    Input Text      locator=password    text=This_is_bad_password
    Press Key    locator=password       key=\\13
    Wait Until Element Is Visible       locator=username       timeout=5
    Page Should Not Contain Element      xpath=//*[@class="navbar-brand logo_name ng-binding"]       expected=*Hello:admin*

Good Login to Clamp UI and Verify logged in
    Input Text      locator=username    text=admin
    Input Text      locator=password    text=password
    Press Key    locator=password       key=\\13
    Wait Until Element Is Visible       xpath=//*[@class="navbar-brand logo_name ng-binding"]       timeout=60
    Element Text Should Be      xpath=//*[@class="navbar-brand logo_name ng-binding"]       expected=Hello:admin

Create Template from Menu
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[1]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Create Template       timeout=60
    Click Element    locator=Create Template
    Input Text      locator=modelName       text=template1
    Click Button    locator=OK

Drag and Drop Boxes for template
    Wait Until Element Is Visible       xpath=//*[@id="js-canvas"]/div/div/div[4]/div[1]/div/div[2]       timeout=60
    Drag And Drop By Offset     xpath=//*[@id="js-canvas"]/div/div/div[4]/div[1]/div/div[2]       280      280
    Drag And Drop By Offset     xpath=//*[@id="js-canvas"]/div/div/div[4]/div[1]/div/div[4]       550      280
    Drag And Drop By Offset     xpath=//*[@id="js-canvas"]/div/div/div[4]/div[1]/div/div[5]       800      280
    Drag And Drop By Offset     xpath=//*[@id="js-canvas"]/div/div/div[4]/div[1]/div/div[6]       1000      280

Drag and Drop Connectors for template
    Click Element    xpath=//*[starts-with(@data-element-id, "StartEvent_")]
    Wait Until Element Is Enabled       xpath=//*[@id="js-canvas"]/div/div/div[2]/div[5]/div/div/div[2]/div
    Drag And Drop       xpath=//*[@id="js-canvas"]/div/div/div[2]/div[5]/div/div/div[2]/div      xpath=//*[starts-with(@data-element-id, "Collector_")]
    Wait Until Element Is Enabled       xpath=//*[@id="js-canvas"]/div/div/div[2]/div[1]/div/div/div[3]/div
    Drag And Drop       xpath=//*[@id="js-canvas"]/div/div/div[2]/div[1]/div/div/div[3]/div     xpath=//*[starts-with(@data-element-id, "TCA_")]
    Wait Until Element Is Enabled       xpath=//*[@id="js-canvas"]/div/div/div[2]/div[2]/div/div/div[3]/div
    Drag And Drop       xpath=//*[@id="js-canvas"]/div/div/div[2]/div[2]/div/div/div[3]/div     xpath=//*[starts-with(@data-element-id, "Policy_")]
    Wait Until Element Is Enabled       xpath=//*[@id="js-canvas"]/div/div/div[2]/div[3]/div/div/div[3]/div
    Drag And Drop       xpath=//*[@id="js-canvas"]/div/div/div[2]/div[3]/div/div/div[3]/div      xpath=//*[starts-with(@data-element-id, "EndEvent_")]

Add Template properties yaml from Menu
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Template Properties      timeout=60
    Click Element    locator=Template Properties
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}TCA_template_properties.yml
    Input Text      locator=service       text=${data}
    Click Button    locator=Close

Save Template from Menu
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Save Template      timeout=60
    Click Element    locator=Save Template
    Element Text Should Be      xpath=//*[@id="alert_message_"]       expected=Action Successful:SAVE

Close Browser
    Close Browser