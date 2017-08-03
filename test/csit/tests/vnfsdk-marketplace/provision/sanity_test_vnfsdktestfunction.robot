*** settings ***
Library           OperatingSystem
Library           Process


*** Variables ***
${csarpath}    ${SCRIPTS}/../plans/vnfsdk-marketplace/sanity-check/enterprise2DC.csar
${upload}    ${SCRIPTS}/../plans/vnfsdk-marketplace/sanity-check/uploadCSAR.sh


*** Test Cases ***
Upload CSAR to marketplace repository 
    [Documentation]    Upload the VNF Package
    ${status}=    Run    curl -i -X POST -H "Content-Type: multipart/form-data" -F "data=@RobotScript.zip" http://${MSB_IP}/openoapi/vnfsdk/v1/functest/  
    
E2E Test case for VNF SDK
    [Documentation]    Upload the VNF Package
    ${status}=    Run Process   bash ${upload} ${MSB_IP} ${csarpath} > log.txt    shell=yes

