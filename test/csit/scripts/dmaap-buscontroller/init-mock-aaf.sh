#!/bin/bash

# $1 is the IP address of the AAF mock server

#curl -v -X PUT -d @- http://$1:1080/expectation << EOF
#{
#	"httpRequest": {
#		"method": "GET",
#		"path": "/hello"
#	},
#	"httpResponse": {
#		"body": "Hello world!",
#		"statusCode": 200
#	},
#	"times" : {
#		"unlimited" : true
#	}
#}
#EOF
#	"httpRequest": {
#		"method": "POST",
#		"path": "/proxy/authz/.*"
#	},

curl -v -X PUT -d @- http://$1:1080/expectation << EOF
{
	"httpRequest": {
		"method": ".*",
		"path": "/.*"
	},
	"httpResponse": {
		"body": "Hello world!",
		"statusCode": 200
	},
	"times" : {
		"unlimited" : true
	}
}
EOF

#curl -v -X PUT -d @- http://$1:1080/expectation << EOF
#{
#	"httpRequest": {
#		"method": "POST",
#		"path": "/proxy/authz/role/perm"
#	},
#	"httpResponse": {
#		"body": "Hello world!",
#		"statusCode": 200
#	}
#}
#EOF

