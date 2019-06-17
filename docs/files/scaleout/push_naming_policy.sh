#!/bin/bash

echo "Create Generic SDNC Naming Policy for VNF"

sleep 1

curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
    "configBody": "{ \"service\": \"SDNC-GenerateName\", \"version\": \"CSIT\", \"content\": { \"policy-instance-name\": \"ONAP_VNF_NAMING_TIMESTAMP\", \"naming-models\": [ { \"naming-properties\": [ { \"property-name\": \"AIC_CLOUD_REGION\" }, { \"property-name\": \"CONSTANT\", \"property-value\": \"ONAP-NF\" }, { \"property-name\": \"TIMESTAMP\" }, { \"property-value\": \"_\", \"property-name\": \"DELIMITER\" } ], \"naming-type\": \"VNF\", \"naming-recipe\": \"AIC_CLOUD_REGION|DELIMITER|CONSTANT|DELIMITER|TIMESTAMP\" }, { \"naming-properties\": [ { \"property-name\": \"VNF_NAME\" }, { \"property-name\": \"SEQUENCE\", \"increment-sequence\": { \"max\": \"zzz\", \"scope\": \"ENTIRETY\", \"start-value\": \"001\", \"length\": \"3\", \"increment\": \"1\", \"sequence-type\": \"alpha-numeric\" } }, { \"property-name\": \"NFC_NAMING_CODE\" }, { \"property-value\": \"_\", \"property-name\": \"DELIMITER\" } ], \"naming-type\": \"VNFC\", \"naming-recipe\": \"VNF_NAME|DELIMITER|NFC_NAMING_CODE|DELIMITER|SEQUENCE\" }, { \"naming-properties\": [ { \"property-name\": \"VNF_NAME\" }, { \"property-value\": \"_\", \"property-name\": \"DELIMITER\" }, { \"property-name\": \"VF_MODULE_LABEL\" }, { \"property-name\": \"VF_MODULE_TYPE\" }, { \"property-name\": \"SEQUENCE\", \"increment-sequence\": { \"max\": \"zzz\", \"scope\": \"PRECEEDING\", \"start-value\": \"01\", \"length\": \"3\", \"increment\": \"1\", \"sequence-type\": \"alpha-numeric\" } } ], \"naming-type\": \"VF-MODULE\", \"naming-recipe\": \"VNF_NAME|DELIMITER|VF_MODULE_LABEL|DELIMITER|VF_MODULE_TYPE|DELIMITER|SEQUENCE\" } ] } }",
    "policyName": "SDNC_Policy.ONAP_VNF_NAMING_TIMESTAMP",
    "policyConfigType": "MicroService",
    "onapName": "SDNC",
    "riskLevel": "4",
    "riskType": "test",
    "guard": "false",
    "priority": "4",
    "description": "ONAP_VNF_NAMING_TIMESTAMP"
}' 'https://pdp:8081/pdp/api/createPolicy'

sleep 10

echo "Pushing SDNC Naming Policy"

sleep 1

echo "pushPolicy : PUT : SDNC_Policy.ONAP_VNF_NAMING_TIMESTAMP"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "SDNC_Policy.ONAP_VNF_NAMING_TIMESTAMP",
  "policyType": "MicroService"
}' 'https://pdp:8081/pdp/api/pushPolicy'

sleep 10

echo "Validate that SDNC Naming Policy has been successfully created"

sleep 1

curl -k -v --silent -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{"policyName": ".*"}' 'https://pdp:8081/pdp/api/getConfig'