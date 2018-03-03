#!/bin/bash

# $1 is the IP address of the MRC (MR Central) mock server

curl -v -X PUT -d @- http://$1:1080/expectation << EOF
{
	"httpRequest": {
		"method": "GET",
		"path": "/hello"
	},
	"httpResponse": {
		"body": "Hello world!",
		"statusCode": 200
	}
}
EOF

