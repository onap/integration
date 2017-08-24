*** Settings ***
Library           OperatingSystem
Library           Process

*** Variables ***

${bundle_query}    ${SCRIPTS}/bundle_query.sh
${health_check}    ${SCRIPTS}/health_check.sh


*** Test Cases ***
Health check test case for APPC
    [Documentation]   Health check
    ${result_hc}=    Run Process   bash ${health_check} > log_hc.txt    shell=yes
    Should Be Equal As Integers    ${result_hc.rc}    0

Query bundle test case for APPC
    [Documentation]   Query bundles 
    ${result_bq}=    Run Process   bash ${bundle_query} > log_bq.txt    shell=yes
    Should Be Equal As Integers    ${result_bq.rc}    0


