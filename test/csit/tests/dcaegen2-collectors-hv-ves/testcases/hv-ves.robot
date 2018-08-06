*** Settings ***
Library    DcaeAppSimulatorLibrary

*** Test Cases ***
Initial testcase
    [Documentation]   Testing dcae app connection
    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   0
