#!/bin/bash
echo 'Generating credetials for FTPES server and DFC client...'

#ganerate certificate&privatekey (vsftpd.crt, vsftpd.key) with password: secret
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout vsftpd.key -out vsftpd.crt -subj "/C=PL/ST=Dolny Slask/L=Wroclaw/O=Root Company/OU=IT Department/CN=Nokia"
#convert crt to pem
openssl x509 -in vsftpd.crt -out vsftpd_crt.pem -outform PEM
#convert key to pem
openssl rsa -in vsftpd.key -out vsftpd_key.pem -outform PEM
#marge key and cert into one pem file
cat vsftpd_key.pem vsftpd_crt.pem > vsftpd.pem

#generate keystore
openssl pkcs12 -export -out cert.pkcs12 -in vsftpd_crt.pem -inkey vsftpd_key.pem
java -cp ./jetty-6.1.26.jar org.mortbay.jetty.security.PKCS12Import cert.pkcs12 keystore.jks

#generate truststore
openssl x509 -in vsftpd_crt.pem -out cert.der -outform der
keytool -importcert -alias cert -file cert.der -keystore truststore.jks

sudo chown root *
sudo chmod 664 *

echo "You have generated your key in the keystore, and your certificate in the truststore."

##WITH PASSPHRASE
#echo 'Generating credetials for FTPES server and DFC client...'
#
##ganerate certificate&privatekey (vsftpd.crt, vsftpd.key) with password: secret
#openssl req -x509 -days 365 -newkey rsa:2048 -keyout vsftpd.key -out vsftpd.crt -subj "/C=PL/ST=Dolny Slask/L=Wroclaw/O=Root Company/OU=IT Department/CN=Nokia" --passout pass:secret
##convert crt to pem
#openssl x509 -in vsftpd.crt -out vsftpd_crt.pem -outform PEM
##convert key to pem
#openssl rsa -in vsftpd.key -out vsftpd_key.pem -outform PEM -passin pass:secret
##marge key and cert into one pem file
#cat vsftpd_key.pem vsftpd_crt.pem > vsftpd.pem
#
##generate keystore
#openssl pkcs12 -export -out cert.pkcs12 -in vsftpd_crt.pem -inkey vsftpd_key.pem -passout pass:secret
#java -cp ./jetty-6.1.26.jar org.mortbay.jetty.security.PKCS12Import cert.pkcs12 keystore.jks
#
##generate truststore
#openssl x509 -in vsftpd_crt.pem -out cert.der -outform der
#keytool -importcert -alias cert -file cert.der -keystore truststore.jks -storepass secret
#
#sudo chown root *
#sudo chmod 664 *
#
#echo "You have generated your key in the keystore, and your certificate in the truststore."