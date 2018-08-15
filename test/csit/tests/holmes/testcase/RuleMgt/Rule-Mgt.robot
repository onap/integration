*** Settings ***
Suite Setup
Suite Teardown    Delete All Sessions
Test Timeout
Library           demjson
Resource          Rule-Keywords.robot

*** Test Cases ***
add_valid_rule
    [Documentation]    Add a valid rule.
    ${dict2}    create dictionary    ruleName=youbowu0314    description=create a new rule!    content=package ruleqwertasd;\n\nimport java.util.Locale;    enabled=1    loopControlName=closedControlLoop
    ${jsonParams}    encode    ${dict2}
    ${response}    createRule    ${jsonParams}
    ${respJson}    to json    ${response.content}
    ${RULEID}    get from dictionary    ${respJson}    ruleId
    set global variable    ${RULEID}
    log    ${RULEID}

add_invalid_content_rule
    [Documentation]    Add an invalid rule of which the content is incorrect!!
    ${dict1}    create dictionary    ruleName=gy0307001    description=create a new rule!    content=123123123    enabled=1
    ${jsonParams}    encode    ${dict1}
    ${response}    createRule    ${jsonParams}    -1
    log    ${response.content}

add_deficient_rule
    [Documentation]    Add an invalid rule of which some mandatory fields are missing.(rulename)
    ${dict3}    create dictionary    description=create a valid rule!    content=package rule2017    enabled=1
    ${jsonParams}    encode    ${dict3}
    ${response}    createRule    ${jsonParams}    -1

query_rule_with_existing_id
    [Documentation]    Query a rule with an existing ID.
    should not be empty    ${RULEID}
    ${response}    queryConditionRule    {"ruleid":"${RULEID}"}
    ${respJson}    to json    ${response.content}
    ${count}    get from dictionary    ${respJson}    totalCount
    run keyword if    ${count}!=1    fail    Can't find the rule with the specified ruleid.

query_rule_with_non_existing_id
    [Documentation]    Query a rule with a non-existing ID.
    ${response}    queryConditionRule    {"ruleId":"invalidid"}
    ${respJson}    to json    ${response.content}
    ${count}    get from dictionary    ${respJson}    totalCount
    run keyword if    ${count}!=0    fail

query_rule_with_partial_existing_name
    [Documentation]    Query rules with (a part of) an existing name.
    ${response}    queryConditionRule    {"ruleName":"youbowu"}
    ${respJson}    to json    ${response.content}
    ${count}    get from dictionary    ${respJson}    totalCount
    run keyword if    ${count}<1    fail    Can't find the rule with (a part of) an existing name

query_rule_with_partial_non_existing_name
    [Documentation]    Query rules with (a part of) a non-existing name.
    ${response}    queryConditionRule    {"ruleName":"zte2017"}
    ${respJson}    to json    ${response.content}
    ${count}    get from dictionary    ${respJson}    totalCount
    run keyword if    ${count}!=0    fail

query_rule_with_vaild_status
    [Documentation]    Query rules with a valid status.
    ${response}    queryConditionRule    {"enabled":1}
    ${respJson}    to json    ${response.content}
    ${count}    get from dictionary    ${respJson}    totalCount
    run keyword if    ${count}<0    fail    Can't find the rule with the status valued 1.

query_rule_with_invalid_status
    [Documentation]    Query rules with an invalid status.
    ${response}    queryConditionRule    {"enabled":99}
    ${respJson}    to json    ${response.content}
    ${count}    get from dictionary    ${respJson}    totalCount
    run keyword if    ${count}!=0    fail

query_rule_with_empty_status
    [Documentation]    Query rules with the status left empty.
    ${response}    queryConditionRule    {"enabled":null}
    ${respJson}    to json    ${response.content}
    ${count}    get from dictionary    ${respJson}    totalCount
    run keyword if    ${count}!=0    fail

query_rule_with_combinational_fields
    [Documentation]    Query rules using the combination of different fields.
    ${dic}    create dictionary    ruleName=youbowu0314    enabled=1
    ${paramJson}    encode    ${dic}
    ${response}    queryConditionRule    ${paramJson}
    ${respJson}    to json    ${response.content}
    ${count}    get from dictionary    ${respJson}    totalCount
    run keyword if    ${count}<1    fail    Can't find the rules with the combination of different fields.    ELSE    traversalRuleAttribute    ${respJson}
    ...    ${dic}

modify_rule_with_status
    [Documentation]    modify the rule with a valid status.
    ${dic}    create dictionary    ruleId=${RULEID}    enabled=0    content=package rule03140002    loopControlName=closedControlLoop
    ${modifyParam}    encode    ${dic}
    ${modifyResp}    modifyRule    ${modifyParam}
    ${response}    queryConditionRule    {"ruleId":"${RULEID}"}
    ${respJson}    to json    ${response.content}
    ${count}    get from dictionary    ${respJson}    totalCount
    run keyword if    ${count}!=1    fail    query rule fails! (can't find the rule modified!)    ELSE    traversalRuleAttribute    ${respJson}
    ...    ${dic}

modify_rule_with_invalid_status
    [Documentation]    modify the rule with an invalid status.
    ${dic}    create dictionary    ruleId=${RULEID}    enabled=88    content=package rule03140002
    ${modifyParam}    encode    ${dic}
    ${modifyResponse}    modifyRule    ${modifyParam}    -1

modify_rule_with_description
    [Documentation]    modify the description of the rule with the new string.
    ${dic}    create dictionary    ruleId=${RULEID}    description=now, i modifying the description of the rule.    content=package rule03140002    loopControlName=closedControlLoop
    ${modifyParam}    encode    ${dic}
    ${modifyResp}    modifyRule    ${modifyParam}
    ${response}    queryConditionRule    {"ruleId":'${RULEID}'}    1
    ${respJson}    to json    ${response.content}
    ${count}    get from dictionary    ${respJson}    totalCount
    run keyword if    ${count}!=1    fail    query rule fails!    ELSE    traversalRuleAttribute    ${respJson}
    ...    ${dic}

delete_existing_rule
    [Documentation]    Delete an existing rule.
    should not be empty    ${RULEID}
    deleteRule    ${RULEID}

delete_non_existing_rule
    [Documentation]    Delete a non-existing rule.
    deleteRule    ${RULEID}    -1
