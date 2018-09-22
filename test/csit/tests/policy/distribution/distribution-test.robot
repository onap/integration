*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***
Healthcheck
     [Documentation]    Runs Policy Distribution Health check
     ${auth}=    Create List    healthcheck    zb!XztG34 
     Log    Creating session http://${POLICY_DISTRIBUTION_IP}:6969
     ${session}=    Create Session      policy  http://${POLICY_DISTRIBUTION_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200
