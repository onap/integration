#!/bin/bash

#all: clear step_1 step_2 step_3 step_4 step_5 step_6 step_7 step_8 step_9 step_10 step_11 step_12 step_13 step_14 step_15
#.PHONY: all
#Clear certificates
#clear:
#	@echo "Clear certificates"
#	rm -f certServiceClient-keystore.jks certServiceServer-keystore.jks root.crt truststore.jks certServiceServer-keystore.p12 root-keystore.jks
#
echo 'Starting preparation of ejbca certs for the environment'

echo "Removing all generated certificates and directories if exists"

rm -rf $SIM_GROUP/../certservice/certservice-certs || true
rm -rf $SIM_GROUP/../certservice/generated || true
rm -rf $SIM_GROUP/tls/external || true

cd $SIM_GROUP/../certservice

mkdir ./certservice-certs
cd certservice-certs

#Generate root private and public keys
keytool -genkeypair -v -alias root -keyalg RSA -keysize 4096 -validity 3650 -keystore root-keystore.jks \
    -dname "CN=root.com, OU=Root Org, O=Root Company, L=Wroclaw, ST=Dolny Slask, C=PL" -keypass secret \
    -storepass secret -ext BasicConstraints:critical="ca:true"

#Export public key as certificate
keytool -exportcert -alias root -keystore root-keystore.jks -storepass secret -file root.crt -rfc

#Self-signed root (import root certificate into truststore)
keytool -importcert -alias root -keystore truststore.jks -file root.crt -storepass secret -noprompt

#Generate certService's client private and public keys
keytool -genkeypair -v -alias certServiceClient -keyalg RSA -keysize 2048 -validity 730 \
    -keystore certServiceClient-keystore.jks -storetype JKS \
    -dname "CN=certServiceClient.com,OU=certServiceClient company,O=certServiceClient org,L=Wroclaw,ST=Dolny Slask,C=PL" \
    -keypass secret -storepass secret

#Generate certificate signing request for certService's client
keytool -certreq -keystore certServiceClient-keystore.jks -alias certServiceClient -storepass secret -file certServiceClient.csr

#Sign certService's client certificate by root CA
keytool -gencert -v -keystore root-keystore.jks -storepass secret -alias root -infile certServiceClient.csr \
    -outfile certServiceClientByRoot.crt -rfc -ext bc=0  -ext ExtendedkeyUsage="serverAuth,clientAuth"

#Import root certificate into client
cat root.crt >> certServiceClientByRoot.crt

#Import signed certificate into certService's client
keytool -importcert -file certServiceClientByRoot.crt -destkeystore certServiceClient-keystore.jks -alias certServiceClient -storepass secret -noprompt

#Generate certService private and public keys
keytool -genkeypair -v -alias oom-cert-service -keyalg RSA -keysize 2048 -validity 730 \
    -keystore certServiceServer-keystore.jks -storetype JKS \
    -dname "CN=oom-cert-service,OU=certServiceServer company,O=certServiceServer org,L=Wroclaw,ST=Dolny Slask,C=PL" \
    -keypass secret -storepass secret -ext BasicConstraints:critical="ca:false"

#Generate certificate signing request for certService
keytool -certreq -keystore certServiceServer-keystore.jks -alias oom-cert-service -storepass secret -file certServiceServer.csr

#Sign certService certificate by root CA
keytool -gencert -v -keystore root-keystore.jks -storepass secret -alias root -infile certServiceServer.csr \
    -outfile certServiceServerByRoot.crt -rfc -ext bc=0  -ext ExtendedkeyUsage="serverAuth,clientAuth" \
    -ext SubjectAlternativeName:="DNS:oom-cert-service,DNS:localhost"

#Import root certificate into server
cat root.crt >> certServiceServerByRoot.crt

#Import signed certificate into certService
keytool -importcert -file certServiceServerByRoot.crt -destkeystore certServiceServer-keystore.jks -alias oom-cert-service \
    -storepass secret -noprompt

#Convert certServiceServer-keystore(.jks) to PCKS12 format(.p12)
keytool -importkeystore -srckeystore certServiceServer-keystore.jks -srcstorepass secret -destkeystore certServiceServer-keystore.p12 -deststoretype PKCS12 -deststorepass secret

#Clear unused certificates
rm certServiceClientByRoot.crt certServiceClient.csr root-keystore.jks certServiceServerByRoot.crt  certServiceServer.csr

cd .. || exit

docker-compose -f docker-compose-certservice-ejbca.yml up -d
echo 'Waiting for EJBCA... It may take a minute or two'
until docker container inspect oomcert-ejbca | grep '"Status": "healthy"'; do sleep 3; done
docker exec oomcert-ejbca /opt/primekey/scripts/ejbca-configuration.sh

mkdir -p ./generated/dfc-p12 -m 777
mkdir -p ./generated/apache-certs  -m 777

docker-compose -f ./clients/docker-compose-certservice-dfc-p12.yml up -d
until ls -1 ./generated/dfc-p12 | grep "store" 1>/dev/null; do sleep 3; done
docker-compose -f ./clients/docker-compose-certservice-httpd-pem.yml up -d
until ls -1 ./generated/apache-certs | grep "store" 1>/dev/null; do sleep 3; done
