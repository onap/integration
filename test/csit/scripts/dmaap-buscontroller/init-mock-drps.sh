#!/bin/bash

# $1 is the IP address of the DRPS (Data Router Provisioning Server) mock server

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

