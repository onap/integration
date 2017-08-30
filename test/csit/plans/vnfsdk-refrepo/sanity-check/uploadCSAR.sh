#!/usr/bin/env bash
###############################################################################
# Copyright 2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $SCRIPT_DIR

#CHECK IF MSB_ADDR IS GIVEN IN COMMAND
if [ -z "$1" ]
then
   echo "There is no MSB_ADDR"
   exit 1
fi
MSB_ADDR=$1
CSAR_NAME=$2
echo $MSB_ADDR
echo $CSAR_NAME

# Wait for MSB initialization
echo Wait for MSB initialization
for i in {1..20}; do
    curl -sS -m 1 $MSB_ADDR > /dev/null && break
    sleep $i
done
#MSB initialized 
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
############UOLOAD PACKAGE to MARKET PLACE######################
echo
echo "############## UOLOAD PACKAGE to MARKET PLACE STARTED ##############";
UploadPackageResponse=$(curl -sS -X POST -H "Content-Type: multipart/form-data;" -F "file=@$CSAR_NAME"  http://$MSB_ADDR/openoapi/vnfsdk-marketplace/v1/PackageResource/csars)
if echo "$UploadPackageResponse" | grep -q "\"csarId\""; then
	echo "UOLOAD PACKAGE TO MARKET PLACE SUCSSS !!!";
else
	echo "UploadPackageResponse :$UploadPackageResponse"
	echo "UOLOAD PACKAGE TO MARKET PLACE FAILED !!!";
	exit 1;
fi
UploadCsarId=$(echo ${UploadPackageResponse:11:36})
echo "PACKAGE ID:$UploadCsarId"
echo "############## UOLOAD PACKAGE to MARKET PLACE END ##################";
#######UOLOAD PACKAGE to MARKET PLACE END#############
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
################GET ON BOARD STATUS########
echo
echo "####################### GETTING ON-BOARDING STATUS ##################";
#sleeping for 10 sec so thate ON Boarding operation should be happened at backend
for pc in $(seq 1 10); do
	status=$((${pc}*10));
    echo -ne "ON_BOARDING Status (%): $status\033[0K\r"
    sleep 1
done
echo

#Three Retries for getting On Boarding Result
#count=0
#while [ $count -lt 3 ]
#do
#	OnBoardStatusResponse=$(curl -sS -X GET  "http://$MSB_ADDR/openoapi/vnfsdk-marketplace/v1/PackageResource/csars/$UploadCsarId/onboardstatus?operTypeId=functiontest&operId=functestexec" -H "Accept: application/json" -H "Content-Type: application/json")
#	echo $OnBoardStatusResponse	
#	if echo "$OnBoardStatusResponse" | grep -q "\"status\":0"; then
#		break;
#	else
#		if [ $count -eq 3 ]
#		then
#			echo "ON-BOARDING OPERATION FAILED !!!";
#		fi
#		count=`expr $count + 1`;
#		sleep 3;
#	fi
#done
echo "GET ON-BOARDING RESULT OPERATION SUCESS ";
echo "##################### GETTING ON-BOARDING STATUS END #################";
####################GET ON BOARD STATUS END############
##########################################
##########################################
##########################################
##########################################
##########################################
#################DOWNLOAD PACKAGE#########
echo
echo "############## DOWNLOADED PACKAGE FROM MARKET STARTED #################";
PACKAGE_NAME=market_temp.csar
curl -sS -X GET  "http://$MSB_ADDR/openoapi/vnfsdk-marketplace/v1/PackageResource/csars/$UploadCsarId/files" > $PACKAGE_NAME
fileSize=$(du  -b $PACKAGE_NAME | cut -f 1)
if [ $fileSize -eq 0 ]
then
	echo "DOWNLOADED PACKAGE FROM MARKET NOT PROPER, ON-BOARDING OPERATION FAILED !!!";
	exit 1;
fi
echo "DOWNLOADED PACKAGE FROM MARKET OPERATION SUCESS !!!";
echo "MARKET PACKAGE NAME:$PACKAGE_NAME"
echo "##################### DOWNLOADED PACKAGE FROM MARKET ##################";
###################DOWNLOAD PACKAGE END#####################
##########################################
##########################################
##########################################
##########################################
##########CATALOUGE START#################
echo
PACKAGE_NAME=$CSAR_NAME
#Check if common-tosca-catalog  is registered with MSB or not
#curl -sS -X GET http://$MSB_ADDR/api/microservices/v1/services/catalog/version/v1 -H "Accept: application/json" -H "Content-Type: application/json" 
#check if common-tosca-aria is registered with MSB or not 
#curl -sS -X GET http://$MSB_ADDR/api/microservices/v1/services/tosca/version/v1 -H "Accept: application/json" -H "Content-Type: application/json"
#echo Sending POST request to Catalog
CsarIdString=$(curl -sS -X POST -H "Content-Type: multipart/form-data; boundary=-WebKitFormBoundary7MA4YWxkTrZu0gW" -H "Cache-Control: no-cache" -H "Postman-Token: abcb6497-b225-c592-01be-e9ff460ca188" -F "file=@$PACKAGE_NAME" http://$MSB_ADDR/openoapi/catalog/v1/csars)
#getting csarId from the output of curl request
CsarId=$(echo ${CsarIdString:11:36})
echo $CsarId
echo $CsarIdString
#csarid is sucessfully stored in CsarId variable
echo "====finished======"
##########CATALOUGE END############
echo "DELETING PACAKE LOCAL COPY:$PACKAGE_NAME";
#rm $PACKAGE_NAME;
