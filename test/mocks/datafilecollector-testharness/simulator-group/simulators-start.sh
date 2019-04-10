#!/bin/bash


# Starts all simulators with the test settings
# Intended for CSIT test. For manual start, use the docker-compose-setup.sh

docker-compose -f docker-compose-template.yml config > docker-compose.yml

docker-compose up -d

DR_SIM="$(docker ps -q --filter='name=dfc_dr-sim')"
DR_RD_SIM="$(docker ps -q --filter='name=dfc_dr-redir-sim')"
MR_SIM="$(docker ps -q --filter='name=dfc_mr-sim')"
SFTP_SIM="$(docker ps -q --filter='name=dfc_sftp-server')"
FTPS_SIM="$(docker ps -q --filter='name=dfc_ftpes-server-vsftpd')"

#Wait for initialization of docker containers for all simulators
for i in {1..10}; do
if [ $(docker inspect --format '{{ .State.Running }}' $DR_SIM) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $DR_RD_SIM) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $MR_SIM) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $SFTP_SIM) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $FTPS_SIM) ]
 then
   echo "All simulators Running"
   break
 else
   echo sleep $i
   sleep $i
 fi 
done

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

if [ $FTP_TYPE = "ALL" ] || [ $FTP_TYPE = "SFTP" ]; then
	echo "Creating files for SFTP server, may take time...."
	docker cp setup-ftp-files-for-image.sh $SFTP_SIM:/tmp/
	docker exec -w /home/onap/ $SFTP_SIM /tmp/setup-ftp-files-for-image.sh $NUM_FTPFILES $NUM_PNFS $FILE_SIZE #>/dev/null 2>&1
fi
if [ $FTP_TYPE = "ALL" ] || [ $FTP_TYPE = "FTPS" ]; then
	echo "Creating files for FTPS server, may take time...."
	docker cp setup-ftp-files-for-image.sh $FTPS_SIM:/tmp/setup-ftp-files-for-image.sh
	docker exec -w /srv $FTPS_SIM /tmp/setup-ftp-files-for-image.sh $NUM_FTPFILES $NUM_PNFS $FILE_SIZE #>/dev/null 2>&1
fi
echo "Done: All simulators started and configured"
