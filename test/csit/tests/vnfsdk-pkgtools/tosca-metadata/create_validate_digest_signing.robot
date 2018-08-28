*** settings ***
Library           OperatingSystem


*** Variables ***
${csarpath}       ${SCRIPTS}/../tests/vnfsdk-pkgtools/tosca-metadata/csar
${keyfile}       ${SCRIPTS}/../tests/vnfsdk-pkgtools/tosca-metadata/test.key
${create_output}  ${OUTPUT DIR}/test_signing.csar

*** Test Cases ***
Create CSAR package
    [Documentation]    Create CSAR package
    ${output}=    Run    vnfsdk csar-create -d ${create_output} --manifest test_entry.mf --history ChangeLog.txt --tests Tests --licenses Licenses --certificate test.crt --privkey ${keyfile} ${csarpath} test_entry.yaml
    Log  ${output}
    File Should Exist  ${create_output}

Validate CSAR package
    [Documentation]    Validate CSAR package
    ${rc}  ${output}=    Run and Return RC And Output    vnfsdk csar-validate ${create_output}
    Should Be Equal As Integers  ${rc}  0
    Log  ${output}
