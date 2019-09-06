#!/bin/bash
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

ftps_server_check() {
	for i in {1..10}; do
		res=$(curl --silent --max-time 3 localhost:$2 2>&1 | grep vsFTPd)
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

docker-compose -f docker-compose-template.yml config > docker-compose.yml

docker-compose up -d

sudo chown $(id -u):$(id -g) consul
sudo chown $(id -u):$(id -g) consul/consul/

declare -a SFTP_SIM
declare -a FTPS_SIM

DR_SIM="$(docker ps -q --filter='name=dfc_dr-sim')"
DR_RD_SIM="$(docker ps -q --filter='name=dfc_dr-redir-sim')"
MR_SIM="$(docker ps -q --filter='name=dfc_mr-sim')"
SFTP_SIM[0]="$(docker ps -q --filter='name=dfc_sftp-server0')"
SFTP_SIM[1]="$(docker ps -q --filter='name=dfc_sftp-server1')"
SFTP_SIM[2]="$(docker ps -q --filter='name=dfc_sftp-server2')"
SFTP_SIM[3]="$(docker ps -q --filter='name=dfc_sftp-server3')"
SFTP_SIM[4]="$(docker ps -q --filter='name=dfc_sftp-server4')"
FTPS_SIM[0]="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd0')"
FTPS_SIM[1]="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd1')"
FTPS_SIM[2]="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd2')"
FTPS_SIM[3]="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd3')"
FTPS_SIM[4]="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd4')"
CBS_SIM="$(docker ps -q --filter='name=dfc_cbs')"
CONSUL_SIM="$(docker ps -q --filter='name=dfc_consul')"

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
[ $(docker inspect --format '{{ .State.Running }}' ${FTPS_SIM[0]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${FTPS_SIM[1]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${FTPS_SIM[2]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${FTPS_SIM[3]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' ${FTPS_SIM[4]}) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $CBS_SIM) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $CONSUL_SIM) ]
 then
   echo "All simulators Started"
   break
 else
   echo sleep $i
   sleep $i
 fi
done

server_check      "cbs          " 10000 "/healthcheck"
server_check      "consul       " 8500 "/v1/catalog/service/agent"
server_check      "DR sim       " 3906 "/"
server_check      "DR redir sim " 3908 "/"
server_check      "MR sim       " 2222 "/"
server_check_https "DR sim https      " 3907 "/"
server_check_https "DR redir sim https" 3909 "/"
server_check_https "MR sim https      " 2223 "/"
ftps_server_check "FTPS server 0" 1032
ftps_server_check "FTPS server 1" 1033
ftps_server_check "FTPS server 2" 1034
ftps_server_check "FTPS server 3" 1035
ftps_server_check "FTPS server 4" 1036
sftp_server_check "SFTP server 0" 1022
sftp_server_check "SFTP server 1" 1023
sftp_server_check "SFTP server 2" 1024
sftp_server_check "SFTP server 3" 1025
sftp_server_check "SFTP server 4" 1026

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

if [ -z "$NUM_FTP_SERVERS" ]
 then
 NUM_FTP_SERVERS=1
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
if [ $FTP_TYPE = "ALL" ] || [ $FTP_TYPE = "FTPS" ]; then
	echo "Creating files for FTPS server, may take time...."
	p=0
	while [ $p -lt $NUM_FTP_SERVERS ]; do
		docker cp setup-ftp-files-for-image.sh ${FTPS_SIM[$p]}:/tmp/setup-ftp-files-for-image.sh
		#Double slash needed for docker on win...
		docker exec -w //srv ${FTPS_SIM[$p]} //tmp/setup-ftp-files-for-image.sh $NUM_FTPFILES $NUM_PNFS $FILE_SIZE $FTP_FILE_PREFIXES $NUM_FTP_SERVERS $p #>/dev/null 2>&1
		let p=p+1
	done
fi
echo "Done: All simulators started and configured"
