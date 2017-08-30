*** settings ***
Library           OperatingSystem
Library           Process


*** Variables ***
${csarpath}    enterprise2DC.csar
${upload}      uploadCSAR.sh


*** Test Cases ***
    
E2E Test case for VNF SDK
    [Documentation]    Upload the VNF Package
    ${status}=    Run Process   bash ${upload} ${REPO_IP} ${csarpath} > log.txt    shell=yes

