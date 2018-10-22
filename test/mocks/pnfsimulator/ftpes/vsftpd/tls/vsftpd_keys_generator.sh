!/bin/bash
echo 'Generating credetials for FTPES server and DFC client...'

echo 'FTPES'
#ganerate certificate&privatekey
openssl req -x509 -days 365 -newkey rsa:2048 -keyout ftp.key -out ftp.crt -subj "/C=PL/ST=Dolny Slask/L=Wroclaw/O=Root Company/OU=IT Department/CN=Nokia" --passout pass:secret
#create a jks keystore for TrustManager
keytool -keystore ftp.jks -genkey -alias ftp -storepass secret -keypass secret -dname "CN=Nokia, OU=IT Department, O=Root Company, L=Wroclaw, ST=Dolny Slask, C=PL"
#convert your certificate in a DER format :
openssl x509 -outform der -in ftp.crt -out ftp.der
#and after, import it in the keystore :
keytool -import -alias ftep -keystore ftp.jks -file ftp.der -storepass secret -keypass secret -dname "CN=Nokia, OU=IT Department, O=Root Company, L=Wroclaw, ST=Dolny Slask, C=PL"

echo 'DFC client'
#ganerate certificate&privatekey
openssl req -x509 -days 365 -newkey rsa:2048 -keyout dfc.key -out dfc.crt -subj "/C=PL/ST=Dolny Slask/L=Wroclaw/O=Root Company/OU=IT Department/CN=Nokia"
#create a jks keystore for TrustManager
keytool -keystore dfc.jks -genkey -alias dfc -storepass secret -keypass secret -dname "CN=root.com, OU=Root Org, O=Root Company, L=Wroclaw, ST=Dolny Slask, C=PL"
#import client.crt and client.key to p12
openssl pkcs12 -export -in dfc.crt -inkey dfc.key \
               -out dfc.p12 -name dfc
#keystore
keytool -importkeystore \
        -deststorepass secret -destkeypass secret -destkeystore dfc.jks \
        -srckeystore dfc.p12 -srcstoretype PKCS12 -srcstorepass secret \
        -alias dfc     
echo 'Finished'