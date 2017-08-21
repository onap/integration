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
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Create Template       timeout=60
    Click Element    locator=Create Template
    Input Text      locator=modelName       text=template1
    Click Button    locator=OK

Close Browser
    Close Browser