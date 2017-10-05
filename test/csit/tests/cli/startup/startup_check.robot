*** Settings ***
Library       RequestsLibrary
Library       Process

*** Variables ***

${cli_exec}    docker exec cli onap
${cli_exec_cli_10_help}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=cli-1.0 && onap --help"
${cli_exec_cli_10_version}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=cli-1.0 && onap --version"
${cli_exec_cli_10_schema_refresh}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=cli-1.0 && onap schema-refresh"
${cli_exec_cli_10_schema_validate}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=cli-1.0 && onap schema-validate -i -l schema-refresh.yaml"
${cli_exec_cli_10_schema_validate_invalid}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=cli-1.0 && onap schema-validate -i -l invalid-yaml-path.yaml"
${cli_exec_cli_10_schema_validate_empty}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=cli-1.0 && onap schema-validate"

${cli_exec_onap_11}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=onap-1.1 && onap"
${cli_exec_onap_11_microservice_create}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=onap-1.1 && onap microservice-create --service-name test-service --service-version v1 --service-url /api/test/v1 --host-url http://${MSB_IAG_IP}:80 23.14.15.156 80"
${cli_exec_onap_11_microservice_list}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=onap-1.1 && onap microservice-list --host-url http://${MSB_IAG_IP}:80 --long"
${cli_exec_onap_11_microservice_show}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=onap-1.1 && onap microservice-show --service-name test-service --service-version v1 --host-url http://${MSB_IAG_IP}:80"
${cli_exec_onap_11_microservice_delete}    docker exec cli bash -c "export CLI_PRODUCT_VERSION=onap-1.1 && onap microservice-delete --service-name test-service --service-version v1 --host-url http://${MSB_IAG_IP}:80 --node-ip 23.14.15.156 --node-port 80"

*** Test Cases ***
Liveness Test
    [Documentation]        Check cli liveness check
    Create Session         cli              http://${CLI_IP}:8080
    CheckUrl               cli              /

Check Cli help
    [Documentation]    check cli help command
    ${cli_cmd_output}=    Run Process    ${cli_exec_cli_10_help}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    CLI version

Check Cli Version Default
    [Documentation]    check cli default version
    ${cli_cmd_output}=    Run Process   ${cli_exec_cli_10_version}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    : cli-1.0

Check Cli Scheam Refresh
    [Documentation]    check cli schema-refresh command
    ${cli_cmd_output}=    Run Process   ${cli_exec_cli_10_schema_refresh}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    sl-no
    Should Contain    ${cli_cmd_output.stdout}    command
    Should Contain    ${cli_cmd_output.stdout}    product-version
    Should Contain    ${cli_cmd_output.stdout}    schema
    Should Contain    ${cli_cmd_output.stdout}    version

Check Cli Schema Validate With Valid Path
    [Documentation]    check cli schema-validate command with valid path
    ${cli_cmd_output}=    Run Process   ${cli_exec_cli_10_schema_validate}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    sl-no
    Should Contain    ${cli_cmd_output.stdout}    error

Check Cli Scheam Validate With Invalid Path
    [Documentation]    check cli schema-validate command with invalid path
    ${cli_cmd_output}=    Run Process    ${cli_exec_cli_10_schema_validate_invalid}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    1
    Should Contain    ${cli_cmd_output.stdout}    0x0007

Check Cli Scheam Validate Empty Argument
    [Documentation]    check cli schema-validate with empty argument
    ${cli_cmd_output}=    Run Process    ${cli_exec_cli_10_schema_validate_empty}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    1
    Should Contain    ${cli_cmd_output.stdout}    0x0015

Check Cli create microservice
    [Documentation]    check create microservice
    ${cli_cmd_output}=    Run Process    ${cli_exec_onap_11_microservice_create}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0

Check Cli list microservice
    [Documentation]    check list microservice
    ${cli_cmd_output}=    Run Process    ${cli_exec_onap_11_microservice_list}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0

Check Cli show microservice
    [Documentation]    check show microservice
    ${cli_cmd_output}=    Run Process    ${cli_exec_onap_11_microservice_show}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0

Check Cli delete microservice
    [Documentation]    check delete microservice
    ${cli_cmd_output}=    Run Process    ${cli_exec_onap_11_microservice_delete}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0



*** Keywords ***
CheckUrl
    [Arguments]                   ${session}  ${path}
    ${resp}=                      Get Request          ${session}  ${path}
    Should Be Equal As Integers   ${resp.status_code}  200
