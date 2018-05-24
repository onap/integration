*** Settings ***
Documentation     Testing PRH with various use scenarios
Suite Setup       PRH Suite Setup
Suite Teardown    PRH Suite Shutdown
Library           Collections
Library           resources/PrhLibrary.py
Resource          resources/prh_keywords.robot

*** Variables ***
${DMaaP_URL}      http://localhost:3904
${AAI_URL}        http://localhost:3905
${PNF_READY}      %{WORKSPACE}/test/csit/tests/dcaegen2/prh_testcases/assets/json_events/pnf_ready.json

*** Test Cases ***
New test
    [Documentation]    First positive TC
    [Tags]    PRH
    #First TC will be added after initial commit
    Should Be True    True
