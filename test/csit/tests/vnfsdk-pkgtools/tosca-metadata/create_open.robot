*** settings ***
Library           OperatingSystem


*** Variables ***
${csarpath}       ${SCRIPTS}/../tests/vnfsdk-pkgtools/tosca-metadata/csar
${create_output}  ${OUTPUT DIR}/test.csar
${open_dir}       ${OUTPUT DIR}/extracted

*** Test Cases ***
Create CSAR package
    [Documentation]    Create CSAR package
    ${output}=    Run    vnfsdk csar-create -d ${create_output} --manifest test_entry.mf --history ChangeLog.txt --tests Tests --licenses Licenses ${csarpath} test_entry.yaml
    Log  ${output}
    File Should Exist  ${create_output}

Open CSAR package
    [Documentation]    Open CSAR package
    ${output}=    Run    vnfsdk csar-open -d ${open_dir} ${create_output}
    Log  ${output}
    Directory Should Not Be Empty  ${open_dir}
    ${rc}  ${output}=    Run and Return RC And Output    diff -r -x TOSCA-Metadata ${open_dir} ${csarpath}
    Should Be Equal As Integers  ${rc}  0
    Log  ${output}
