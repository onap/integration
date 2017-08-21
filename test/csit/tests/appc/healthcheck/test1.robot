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
    CreateSession   appc  http://localhost:8282
    ${resp}=    Get Request    appc   /restconf/operations/SLI-API:healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200
