#!/bin/bash

# $1 is the IP address of the buscontroller
# $2 is the IP address of the DRPS
# $3 is the IP address of the MRC

# INITIALIZE: dmaap object
JSON=/tmp/$$.dmaap
cat << EOF > $JSON
{
	"version": "1",
	"topicNsRoot": "org.onap.dmaap",
	"drProvUrl": "http://${2}:8080",
	"dmaapName": "onapCSIT",
	"bridgeAdminTopic": "MM_AGENT_PROV"

}
EOF

curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/dmaap 



# INITIALIZE: dcaeLocation object
JSON=/tmp/$$.loc
cat << EOF > $JSON
{
	"dcaeLocationName": "csit-sanfrancisco",
	"dcaeLayer": "central-cloud",
	"clli": "CSIT12345",
	"zone": "zoneA"

}
EOF

curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/dcaeLocations 


# INITIALIZE: MR object in 1 site
JSON=/tmp/$$.mrc
cat << EOF > $JSON
{
	"dcaeLocationName": "csit-sanfrancisco",
	"fqdn": "$3",
	"hosts" : [ "$3", "$3", "$3" ],
	"protocol" : "https",
	"port": "3094"

}
EOF

curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/mr_clusters
