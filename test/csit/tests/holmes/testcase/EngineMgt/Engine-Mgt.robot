*** Settings ***
Suite Setup
Suite Teardown    Delete All Sessions
Test Teardown
Test Timeout
Library           demjson
Resource          Engine-Keywords.robot
Resource          ../RuleMgt/Rule-Keywords.robot

*** Test Cases ***
verify_invalid_rule
    [Documentation]    Verify a rule with invalid contents.
    ${dic1}    create dictionary    content=123123123
    ${Jsonparam}    encode    ${dic1}
    verifyEngineRule    ${Jsonparam}    -1

verify_valid_rule
    [Documentation]    Verify a rule with valid contents.
    ${dic2}    create dictionary    content=package rule03080001
    ${Jsonparam}    encode    ${dic2}
    verifyEngineRule    ${Jsonparam}

deploy_invalid_rule
    [Documentation]    Add a rule with invalid contents to the engine.
    ${dic3}    create dictionary    content=789789789    engineId=""
    ${Jsonparam}    encode    ${dic3}
    ${response}    deployEngineRule    ${Jsonparam}    -1

deploy_valid_rule
    [Documentation]    Add a rule with valid contents to the engine.
    ${dic4}    create dictionary    content=package rule03080002;\n\nimport java.util.Locale;    engineId=""    loopControlName=test
    ${Jsonparam}    encode    ${dic4}
    ${response}    deployEngineRule    ${Jsonparam}

delete_existing_rule
    [Documentation]    Delete an existing rule using an existing package ID from the engine.
    deleteEngineRule    rule03080002

delete_non_existing_rule
    [Documentation]    Delete an existing rule using a non-existing package ID from the engine.
    deleteEngineRule    rule03080002    -1
