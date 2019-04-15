# To verify the certificate expiration dates:

openssl x509 -enddate -noout -in dfc.crt
openssl x509 -enddate -noout -in ftp.crt
