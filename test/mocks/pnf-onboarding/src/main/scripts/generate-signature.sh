#!/bin/bash

signingCertificate=$1
signingCertPrivateKey=$2
csarFile=$3
signatureName=$4

echo Creating signature file with following inputs
printf "\t%s = %s\n" "signingCertificate" $signingCertificate
printf "\t%s = %s\n" "signingCertPrivateKey" $signingCertPrivateKey
printf "\t%s = %s\n" "csarFile" $csarFile

openssl cms -sign -signer $signingCertificate -inkey $signingCertPrivateKey -outform pem -binary -nocerts < $csarFile > $signatureName

retVal=$?
if [ $retVal -eq 0 ]; then
    echo Signature file $signatureName created successfully
else
    echo Failed to create Signature file $signatureName
fi

exit $retVal
