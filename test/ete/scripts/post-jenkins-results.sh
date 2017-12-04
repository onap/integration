#!/bin/bash -x

CRUMB=$(curl -s -u "lf:lf" 'http://12.234.32.117/jenkins/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')

curl -v -u "lf:929b8c2bea4c4c6847778f8cd6241cbf" -H "$CRUMB" -d '<run><log encoding="hexBinary">4142430A</log><result>0</result><duration>17</duration></run>' http://12.234.32.117/jenkins/job/external-job/postBuildResult

