#!/bin/bash

# $1 is the IP address of the buscontroller
# $2 is the IP address of the DRPS
# $3 is the IP address of the MRC
# $4 is the protocol (defaults to http)

PROTO=${4:-http}
if [ "$PROTO" = "http" ]
then
	PORT=8080
	CURLOPT="-v"
	MRPORT=3904
	DRPORT=8080
else
	PORT=8443
	CURLOPT="-v -k"
	MRPORT=3905
	DRPORT=8443
fi

# INITIALIZE: dmaap object
JSON=/tmp/$$.dmaap
cat << EOF > $JSON
{
	"version": "1",
	"topicNsRoot": "org.onap.dmaap",
	"drProvUrl": "${PROTO}://dmaap-dr-prov:${DRPORT}",
	"dmaapName": "onapCSIT",
	"bridgeAdminTopic": "MM_AGENT_PROV"

}
EOF

echo "Initializing /dmaap endpoint"
curl ${CURLOPT} -X POST -d @${JSON} -H "Content-Type: application/json" ${PROTO}://$1:${PORT}/webapi/dmaap 



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

echo "Initializing /dcaeLocations endpoint"
curl ${CURLOPT} -X POST -d @${JSON} -H "Content-Type: application/json" ${PROTO}://$1:${PORT}/webapi/dcaeLocations 


# INITIALIZE: MR object in 1 site
# since MR is currently deployed via docker-compose, its IP doesn't seem
# to be routable from DBCL. Fortunately, the MR port is mapped from the docker bridge IP address.
# Found this article for how to deterine the docker bridge IP so using it as a workaround.
# https://stackoverflow.com/questions/22944631/how-to-get-the-ip-address-of-the-docker-host-from-inside-a-docker-container
# Used the following snippet found buried in a comment to an answer and then modified for only 1 value.
DOCKER_HOST=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+' | head -1 )
# Perhaps there is a better way...
JSON=/tmp/$$.mrc
cat << EOF > $JSON
{
	"dcaeLocationName": "csit-sanfrancisco",
	"fqdn": "$DOCKER_HOST",
	"topicProtocol" : "http",
	"topicPort": "${MRPORT}"

}
EOF

echo "Initializing /mr_clusters endpoint"
curl ${CURLOPT} -X POST -d @${JSON} -H "Content-Type: application/json" ${PROTO}://$1:${PORT}/webapi/mr_clusters
