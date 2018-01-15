*** Settings ***
Documentation        store all properties that can change or are used in multiple places here
...                    format is all caps with underscores between words and prepended with GLOBAL
...                   make sure you prepend them with GLOBAL so that other files can easily see it is from this file.


*** Variables ***
${GLOBAL_VNF_RESTART_REQUESTFILE}    ${CURDIR}/LCM_VNF_RESTART_REQUEST.txt
${GLOBAL_VM_RESTART_REQUESTFILE}     ${CURDIR}/LCM_VM_RESTART_REQUEST.txt
${GLOBAL_HEALTHCHECK_REQUESTFILE}    ${CURDIR}/LCM_VM_HEALTHCHECK_REQUEST.txt