curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "GET",
        "path": "/api/huaweivnfmdriver/v1/swagger.json"
    },
    "httpResponse": {
        "statusCode": 200,
        "headers": {
            "content-type": ["application/json"]
        },
    "body": {
         "not": false,
             "type": "JSON",
             "json": "{\"errcode\":\"0\",\"errmsg\":\"get token successfully.\",\"data\":{\"expiredDate\":\"2018-11-10 10:03:33\"}}"
    }
    },
    "times" : {
        "unlimited" : true
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'

curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "POST",
        "path": "/controller/v2/tokens"
    },
    "httpResponse": {
        "statusCode": 200,
        "headers": {
            "content-type": ["application/json"]
        },
        "body": {
         "not": false,
             "type": "JSON",
             "json": "{\"errcode\":\"0\",\"errmsg\":\"get token successfully.\",\"data\":{\"expiredDate\":\"2018-11-10 10:03:33\",\"token_id\":\"7F06BFDDAC33A989:77DAD6058B1BB81EF1A557745E4D9C78399B31C4DB509704ED8A7DF05A362A59\"}}"
        }
    },
    "times" : {
        "unlimited" : true
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'
 
curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "POST",
        "path": "/restconf/data/huawei-ac-net-l3vpn-svc:l3vpn-svc-cfg/vpn-services"
    },
    "httpResponse": {
        "statusCode": 201
    },
    "times" : {
        "unlimited" : true
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'
 
curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "PUT",
        "path": "/restconf/data/huawei-ac-net-l3vpn-svc:l3vpn-svc-cfg/huawei-ac-net-l3vpn-svc-vfi:vrf-attributes"
    },
    "httpResponse": {
        "statusCode": 204
    },
    "times" : {
        "unlimited" : true
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'
 
curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "POST",
        "path": "/restconf/data/huawei-ac-net-l3vpn-svc:l3vpn-svc-cfg/sites"
    },
    "httpResponse": {
        "statusCode": 201
    },
    "times" : {
        "unlimited" : true
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'
 
# ZTE DCI
curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "POST",
        "path": "/v2.0/l3-dci-connects"
    },
    "httpResponse": {
        "statusCode": 201
    },
    "times" : {
        "unlimited" : true
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'
 
# huaweivnfmdriver
curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "POST",
        "path": "/api/huaweivnfmdriver/v1/a0400010-11d7-4875-b4ae-5f42ed5d3a85/vnfs"
    },
    "httpResponse": {
        "statusCode": 200,
        "headers": {
            "content-type": ["application/json"]
        },
        "body": {
             "not": false,
             "type": "JSON",
             "json": "{\"vnfInstanceId\":\"fa3dca847b054f4eb9d3bc8bb9e5eec9\",\"jobId\":\"fa3dca847b054f4eb9d3bc8bb9e5eec9_post\"}"
        }
    },
    "times" : {
        "unlimited" : true
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'
 
# huaweivnfmdriver
curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "GET",
        "path": "/api/huaweivnfmdriver/v1/a0400010-11d7-4875-b4ae-5f42ed5d3a85/jobs/fa3dca847b054f4eb9d3bc8bb9e5eec9_post",
    "queryStringParameters": {
        "responseId": ["0"]
    }
    },
    "httpResponse": {
        "statusCode": 200,
        "headers": {
            "content-type": ["application/json"]
        },
        "body": {
             "not": false,
             "type": "JSON",
             "json": "{\"jobId\":\"fa3dca847b054f4eb9d3bc8bb9e5eec9\",\"responsedescriptor\":{\"progress\":\"50\",\"status\":\"processing\",\"errorCode\":null,\"responseId\":\"0\"}}"
        }
    },
    "times" : {
        "unlimited" : false
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'
 
# huaweivnfmdriver
curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "GET",
        "path": "/api/huaweivnfmdriver/v1/a0400010-11d7-4875-b4ae-5f42ed5d3a85/jobs/fa3dca847b054f4eb9d3bc8bb9e5eec9_post",
    "queryStringParameters": {
        "responseId": ["0"]
    }
    },
    "httpResponse": {
        "statusCode": 200,
        "headers": {
            "content-type": ["application/json"]
        },
        "body": {
             "not": false,
             "type": "JSON",
             "json": "{\"jobId\":\"fa3dca847b054f4eb9d3bc8bb9e5eec9\",\"responsedescriptor\":{\"progress\":\"100\",\"status\":\"processing\",\"errorCode\":null,\"responseId\":\"0\"}}"
        }
    },
    "times" : {
        "unlimited" : true
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'
 
curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "GET",
        "path": "/api/huaweivnfmdriver/v1/a0400010-11d7-4875-b4ae-5f42ed5d3a85/jobs/fa3dca847b054f4eb9d3bc8bb9e5eec9_post",
    "queryStringParameters": {
        "responseId": ["50"]
    }
    },
    "httpResponse": {
        "statusCode": 200,
        "headers": {
            "content-type": ["application/json"]
        },
        "body": {
             "not": false,
             "type": "JSON",
             "json": "{\"jobId\":\"fa3dca847b054f4eb9d3bc8bb9e5eec9\",\"responsedescriptor\":{\"progress\":\"100\",\"status\":\"processing\",\"errorCode\":null,\"responseId\":\"50\"}}"
        }
    },
    "times" : {
        "unlimited" : true
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'
 
 
curl -v -X PUT "http://localhost:1080/expectation" -d '{
    "httpRequest": {
        "method": "GET",
        "path": "/api/huaweivnfmdriver/v1/a0400010-11d7-4875-b4ae-5f42ed5d3a85/jobs/fa3dca847b054f4eb9d3bc8bb9e5eec9_post",
    "queryStringParameters": {
        "responseId": ["2"]
    }
    },
    "httpResponse": {
        "statusCode": 200,
        "headers": {
            "content-type": ["application/json"]
        },
        "body": {
             "not": false,
             "type": "JSON",
             "json": "{\"jobId\":\"fa3dca847b054f4eb9d3bc8bb9e5eec9\",\"responsedescriptor\":{\"progress\":\"100\",\"status\":\"processing\",\"errorCode\":null,\"responseId\":\"2\"}}"
        }
    },
    "times" : {
        "unlimited" : true
    },
    "timeToLive" : {
        "unlimited" : true
    }
}'

