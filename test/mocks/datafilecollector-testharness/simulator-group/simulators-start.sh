#!/bin/bash
#
# Modifications copyright (C) 2021 Nokia. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
set -x
server_check() {
	for i in {1..10}; do
		res=$(curl  -s -o /dev/null -w "%{http_code}" localhost:$2$3)
		if [ $res -gt 199 ] && [ $res -lt 300 ]; then
			echo "Simulator " $1 " on localhost:$2$3 responded ok"
			return
		fi
		sleep 1
	done
	echo "Simulator " $1 " on localhost:$2$3 - no response"
}

http_https_basic_server_check() {
	for i in {1..10}; do
		res=$(curl $4 -s -o /dev/null -w "%{http_code}" "$3"://"$BASIC_AUTH_LOGIN":"$BASIC_AUTH_PASSWORD"@localhost:"$2")
		if [ $res -gt 199 ] && [ $res -lt 300 ]; then
			echo "Simulator " "$1" " on localhost: ""$2"" responded ok"
			return
		fi
		sleep 1
	done
	echo "Simulator " "$1" " on localhost:""$2"" - no response"
}

http_https_server_check() {
	for i in {1..10}; do
		res=$(curl $4 -s -o /dev/null -w "%{http_code}" $3://localhost:$2)
		if [ $res -gt 199 ] && [ $res -lt 300 ]; then
			echo "Simulator " $1 " on localhost:$2 responded ok"
			return
		fi
		sleep 1
	done
	echo "Simulator " $1 " on localhost:$2 - no response"
}

http_https_jwt_server_check() {
	for i in {1..10}; do
		res=$(curl $4 -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkZW1vIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjk5OTk5OTk5OTksIm5iZiI6MTUxNjIzOTAyMH0.vyktOJyCMVvJXEfImBuZCTaEifrvH0kXeAPpnHakffA' -s -o /dev/null -w "%{http_code}" $3://localhost:$2)
		if [ $res -gt 199 ] && [ $res -lt 300 ]; then
			echo "Simulator " $1 " on localhost:$2 responded ok"
			return
		fi
		sleep 1
	done
	echo "Simulator " $1 " on localhost:$2 - no response"
}

server_check_https() {
	for i in {1..10}; do
		res=$(curl  -k -s -o /dev/null -w "%{http_code}" https://localhost:$2$3)
		if [ $res -gt 199 ] && [ $res -lt 300 ]; then
			echo "Simulator " $1 " on https://localhost:$2$3 responded ok"
			return
		fi
		sleep 1
	done
	echo "Simulator " $1 " on https://localhost:$2$3 - no response"
}

ftpes_server_check() {
	for i in {1..10}; do
		res=$(curl --silent --max-time 3 ftp://localhost:$2 --ftp-ssl -v -k 2>&1 | grep vsFTPd)
		if ! [ -z "$res" ]; then
			echo "Simulator " $1 " on localhost:$2 responded ok"
			return
		fi
		sleep 1
	done
	echo "Simulator " $1 " on localhost:$2 - no response"
}

sftp_server_check() {
	for i in {1..10}; do
		res=$(curl --silent --max-time 3 localhost:$2 2>&1 | grep OpenSSH)
		if ! [ -z "$res" ]; then
			echo "Simulator " $1 " on localhost:"$2" responded ok"
			return
		fi
		sleep 1
	done
	echo "Simulator " $1 " on localhost:"$2" - no response"
}

# Starts all simulators with the test settings
# Intended for CSIT test and auto test. For manual start, use the docker-compose-setup.sh

DOCKER_SIM_NWNAME="dfcnet"
echo "Creating docker network $DOCKER_SIM_NWNAME, if needed"
docker network ls| grep $DOCKER_SIM_NWNAME > /dev/null || docker network create $DOCKER_SIM_NWNAME

if [ -z "$SIM_GROUP" ]
 then
 export SIM_GROUP="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi

if [ -z "$NUM_FTP_SERVERS" ]
 then
 export NUM_FTP_SERVERS=1
fi

if [ -z "$NUM_HTTP_SERVERS" ]
 then
 export NUM_HTTP_SERVERS=1
fi

docker-compose -f docker-compose-template.yml config > docker-compose.yml

docker-compose up -d

sudo chown $(id -u):$(id -g) dfc_configs

declare -a SFTP_SIM
declare -a FTPES_SIM
declare -a HTTP_SIM

DR_SIM="$(docker ps -q --filter='name=dfc_dr-sim')"
DR_RD_SIM="$(docker ps -q --filter='name=dfc_dr-redir-sim')"
MR_SIM="$(docker ps -q --filter='name=dfc_mr-sim')"
SFTP_SIM[0]="$(docker ps -q --filter='name=dfc_sftp-server0')"
SFTP_SIM[1]="$(docker ps -q --filter='name=dfc_sftp-server1')"
SFTP_SIM[2]="$(docker ps -q --filter='name=dfc_sftp-server2')"
SFTP_SIM[3]="$(docker ps -q --filter='name=dfc_sftp-server3')"
SFTP_SIM[4]="$(docker ps -q --filter='name=dfc_sftp-server4')"
FTPES_SIM[0]="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd0')"
FTPES_SIM[1]="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd1')"
FTPES_SIM[2]="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd2')"
FTPES_SIM[3]="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd3')"
FTPES_SIM[4]="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd4')"
HTTP_SIM[0]="$(docker ps -q --filter='name=dfc_http-https-server0')"
HTTP_SIM[1]="$(docker ps -q --filter='name=dfc_http-https-server1')"
HTTP_SIM[2]="$(docker ps -q --filter='name=dfc_http-https-server2')"
HTTP_SIM[3]="$(docker ps -q --filter='name=dfc_http-https-server3')"
HTTP_SIM[4]="$(docker ps -q --filter='name=dfc_http-https-server4')"

#Wait for initialization of docker containers for all simulators
for i in {1..10}; do
if [ $(docker inspect --format '{{ .State.Running }}' $DR_SIM) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $DR_RD_SIM) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $MR_SIM) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${SFTP_SIM[0]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${SFTP_SIM[1]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${SFTP_SIM[2]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${SFTP_SIM[3]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${SFTP_SIM[4]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${FTPES_SIM[0]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${FTPES_SIM[1]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${FTPES_SIM[2]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${FTPES_SIM[3]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${FTPES_SIM[4]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${HTTP_SIM[0]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${HTTP_SIM[1]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${HTTP_SIM[2]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${HTTP_SIM[3]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${HTTP_SIM[4]}) ]
 then
   echo "All simulators Started"
   break
 else
   echo sleep $i
   sleep $i
 fi
done

if [ -z "$BASIC_AUTH_LOGIN" ]
 then
 BASIC_AUTH_LOGIN=demo
fi

if [ -z "$BASIC_AUTH_PASSWORD" ]
 then
 BASIC_AUTH_PASSWORD=demo123456!
fi

server_check      "DR sim       " 3906 "/"
server_check      "DR redir sim " 3908 "/"
server_check      "MR sim       " 2222 "/"
server_check_https "DR sim https      " 3907 "/"
server_check_https "DR redir sim https" 3909 "/"
server_check_https "MR sim https      " 2223 "/"
ftpes_server_check "FTPES server 0" 1032
ftpes_server_check "FTPES server 1" 1033
ftpes_server_check "FTPES server 2" 1034
ftpes_server_check "FTPES server 3" 1035
ftpes_server_check "FTPES server 4" 1036
sftp_server_check "SFTP server 0" 1022
sftp_server_check "SFTP server 1" 1023
sftp_server_check "SFTP server 2" 1024
sftp_server_check "SFTP server 3" 1025
sftp_server_check "SFTP server 4" 1026
http_https_basic_server_check "HTTP basic auth server 0" 81 http
http_https_basic_server_check "HTTP basic auth server 1" 82 http
http_https_basic_server_check "HTTP basic auth server 2" 83 http
http_https_basic_server_check "HTTP basic auth server 3" 84 http
http_https_basic_server_check "HTTP basic auth server 4" 85 http
http_https_jwt_server_check "HTTP JWT server 0" 32001 http
http_https_jwt_server_check "HTTP JWT server 1" 32002 http
http_https_jwt_server_check "HTTP JWT server 2" 32003 http
http_https_jwt_server_check "HTTP JWT server 3" 32004 http
http_https_jwt_server_check "HTTP JWT server 4" 32005 http
http_https_basic_server_check "HTTPS basic auth server 0" 444 https -k
http_https_basic_server_check "HTTPS basic auth server 1" 445 https -k
http_https_basic_server_check "HTTPS basic auth server 2" 446 https -k
http_https_basic_server_check "HTTPS basic auth server 3" 447 https -k
http_https_basic_server_check "HTTPS basic auth server 4" 448 https -k
http_https_server_check "HTTPS client certificate authentication server 0" 444 https "-k --cert ../certservice/generated-certs/apache-pem/keystore.pem --key ../certservice/generated-certs/apache-pem/key.pem"
http_https_server_check "HTTPS client certificate authentication server 1" 445 https "-k --cert ../certservice/generated-certs/apache-pem/keystore.pem --key ../certservice/generated-certs/apache-pem/key.pem"
http_https_server_check "HTTPS client certificate authentication server 2" 446 https "-k --cert ../certservice/generated-certs/apache-pem/keystore.pem --key ../certservice/generated-certs/apache-pem/key.pem"
http_https_server_check "HTTPS client certificate authentication server 3" 447 https "-k --cert ../certservice/generated-certs/apache-pem/keystore.pem --key ../certservice/generated-certs/apache-pem/key.pem"
http_https_server_check "HTTPS client certificate authentication server 4" 448 https "-k --cert ../certservice/generated-certs/apache-pem/keystore.pem --key ../certservice/generated-certs/apache-pem/key.pem"
http_https_server_check "HTTPS no auth server 0" 8081 https -k
http_https_server_check "HTTPS no auth server 1" 8082 https -k
http_https_server_check "HTTPS no auth server 2" 8083 https -k
http_https_server_check "HTTPS no auth server 3" 8084 https -k
http_https_server_check "HTTPS no auth server 4" 8085 https -k
http_https_jwt_server_check "HTTPS JWT server 0" 32101 https -k
http_https_jwt_server_check "HTTPS JWT server 1" 32102 https -k
http_https_jwt_server_check "HTTPS JWT server 2" 32103 https -k
http_https_jwt_server_check "HTTPS JWT server 3" 32104 https -k
http_https_jwt_server_check "HTTPS JWT server 4" 32105 https -k

echo ""

#Populate the ftp server with files
if [ -z "$NUM_FTPFILES" ]
 then
 NUM_FTPFILES=200
fi
if [ -z "$NUM_PNFS" ]
 then
 NUM_PNFS=1
fi
if [ -z "$FILE_SIZE" ]
 then
 FILE_SIZE="ALL"
fi
if [ -z "$FTP_TYPE" ]
 then
 FTP_TYPE="ALL"
fi
if [ -z "$FTP_FILE_PREFIXES" ]
 then
 FTP_FILE_PREFIXES="A"
fi



if [ $FTP_TYPE = "ALL" ] || [ $FTP_TYPE = "SFTP" ]; then
	echo "Creating files for SFTP server, may take time...."
	p=0
	while [ $p -lt $NUM_FTP_SERVERS ]; do
		docker cp setup-ftp-files-for-image.sh ${SFTP_SIM[$p]}:/tmp/
		#Double slash needed for docker on win...
		docker exec -w //home/onap/ ${SFTP_SIM[$p]} //tmp/setup-ftp-files-for-image.sh $NUM_FTPFILES $NUM_PNFS $FILE_SIZE $FTP_FILE_PREFIXES $NUM_FTP_SERVERS $p #>/dev/null 2>&1
		let p=p+1
	done
fi
if [ $FTP_TYPE = "ALL" ] || [ $FTP_TYPE = "FTPES" ]; then
	echo "Creating files for FTPES server, may take time...."
	p=0
	while [ $p -lt $NUM_FTP_SERVERS ]; do
		docker cp setup-ftp-files-for-image.sh ${FTPES_SIM[$p]}:/tmp/setup-ftp-files-for-image.sh
		#Double slash needed for docker on win...
		docker exec -w //srv ${FTPES_SIM[$p]} //tmp/setup-ftp-files-for-image.sh $NUM_FTPFILES $NUM_PNFS $FILE_SIZE $FTP_FILE_PREFIXES $NUM_FTP_SERVERS $p #>/dev/null 2>&1
		let p=p+1
	done
fi

#Populate the http server with files. Note some common variables with ftp files!
if [ -z "$NUM_HTTPFILES" ]
 then
 NUM_HTTPFILES=200
fi
if [ -z "$HTTP_TYPE" ]
 then
 HTTP_TYPE="ALL"
fi
if [ -z "$HTTP_FILE_PREFIXES" ]
 then
 HTTP_FILE_PREFIXES="A"
fi

if [ $HTTP_TYPE = "ALL" ] || [ $HTTP_TYPE = "HTTP" ] || [ $HTTP_TYPE = "HTTPS" ]; then
	echo "Creating files for HTTP server, may take time...."
	p=0
	while [ $p -lt $NUM_HTTP_SERVERS ]; do
		docker cp setup-http-files-for-image.sh ${HTTP_SIM[$p]}:/tmp/setup-http-files-for-image.sh
		#Double slash needed for docker on win...
		docker exec -w //usr//local//apache2//htdocs ${HTTP_SIM[$p]} //tmp/setup-http-files-for-image.sh $NUM_HTTPFILES $NUM_PNFS $FILE_SIZE $HTTP_FILE_PREFIXES $NUM_HTTP_SERVERS $p #>/dev/null 2>&1
		let p=p+1
	done
fi
echo "Done: All simulators started and configured"
