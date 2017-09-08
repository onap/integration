*** Settings ***
Library       RequestsLibrary
Library       Process

*** Variables ***

${cli_exec}    docker exec cli onap
${cli_exec_onap_11}    docker exec -e CLI_PRODUCT_VERSION=onap-1.1 onap
${cli_exec_onap_10}    docker exec -e CLI_PRODUCT_VERSION=onap-1.0 onap
${cli_exec_cli_10}    docker exec -e CLI_PRODUCT_VERSION=cli-1.0 onap

*** Test Cases ***
Liveness Test
    [Documentation]        Check cli liveness check
    Create Session         cli              http://${CLI_IP}:8080
    CheckUrl               cli              /

Check Cli help
    [Documentation]    check cli help command
    ${cli_cmd_output}=    Run Process   ${cli_exec} --help    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    ONAP Command-line interface

Check Cli Version Default
    [Documentation]    check cli default version
    ${cli_cmd_output}=    Run Process   ${cli_exec} --version    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    : cli-1.0

Check Cli Scheam Refresh
    [Documentation]    check cli schema-refresh command
    ${cli_cmd_output}=    Run Process   ${cli_exec} schema-refresh    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    sl-no
    Should Contain    ${cli_cmd_output.stdout}    command
    Should Contain    ${cli_cmd_output.stdout}    product-version
    Should Contain    ${cli_cmd_output.stdout}    schema
    Should Contain    ${cli_cmd_output.stdout}    version

Check Cli Schema Validate With Valid Path
    [Documentation]    check cli schema-validate command with valid path
    ${cli_cmd_output}=    Run Process   ${cli_exec} schema-validate -i -l schema-refresh.yaml    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    sl-no
    Should Contain    ${cli_cmd_output.stdout}    error

Check Cli Scheam Validate With Invalid Path
    [Documentation]    check cli version
    ${cli_cmd_output}=    Run Process    ${cli_exec} schema-validate -i -l invalid-yaml-path.yaml    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    1
    Should Contain    ${cli_cmd_output.stdout}    0x0007

Check Cli Scheam Validate Empty Argument
    [Documentation]    check cli schema validate with empty argument
    ${cli_cmd_output}=    Run Process    ${cli_exec} schema-validate    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    1
    Should Contain    ${cli_cmd_output.stdout}    0x0015


*** Keywords ***
CheckUrl
    [Arguments]                   ${session}  ${path}
    ${resp}=                      Get Request          ${session}  ${path}
    Should Be Equal As Integers   ${resp.status_code}  200
