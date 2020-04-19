#!/bin/bash

set -euo pipefail

BASE_DN="/C=US/ST=Acme State/L=Acme City/O=Acme Inc."

WORKDIR=$(mktemp -d)
trap "rm -rf $WORKDIR" EXIT

CA_DAYS=$((3652 * 2))
PEER_DAYS=$((3652 * 1))

CONFIG_FILE=$WORKDIR/openssl.cnf
CA_SERIAL_FILE=$WORKDIR/ca.srl
echo 01 > $CA_SERIAL_FILE

cat > $CONFIG_FILE <<EOL
[req]
default_bits       = 2048
distinguished_name = req_distinguised_name
prompt             = no
serial             = $CA_SERIAL_FILE
default_md         = sha256

[req_distinguised_name]
C  = US
ST = Acme State
L  = Acme City
O  = Acme Inc.
CN = example.com

[ca]
basicConstraints     = critical, CA:TRUE
keyUsage             = critical, keyCertSign
subjectKeyIdentifier = hash

[peer]
basicConstraints     = critical, CA:FALSE
keyUsage             = critical, digitalSignature, keyEncipherment
subjectKeyIdentifier = hash
EOL

# Generate a self signed certificate for the CA along with a key.
# NOTE: I'm using -nodes, this means that once anybody gets
# their hands on this particular key, they can become this CA.
openssl req \
    -x509 \
    -nodes \
    -days $CA_DAYS \
    -newkey rsa:2048 \
    -keyout ca_key.pem \
    -out ca.pem \
    -config $CONFIG_FILE \
    -extensions ca

# Create server private key and certificate request
openssl genrsa -out server_key.pem 2048
openssl req -new \
    -key server_key.pem \
    -out $WORKDIR/server.csr \
    -subj "$BASE_DN/CN=server.example.com"

# Create client private key and certificate request
openssl genrsa -out client_key.pem 2048
openssl req -new \
    -key client_key.pem \
    -out $WORKDIR/client.csr \
    -subj "$BASE_DN/CN=client.example.com"

# Generate certificates
openssl x509 -req -days $PEER_DAYS -in $WORKDIR/server.csr \
    -CA ca.pem -CAkey ca_key.pem \
    -out server_cert.pem \
    -sha256 \
    -CAserial $CA_SERIAL_FILE \
    -extfile $CONFIG_FILE \
    -extensions peer
openssl x509 -req -days $PEER_DAYS -in $WORKDIR/client.csr \
    -CA ca.pem -CAkey ca_key.pem \
    -out client_cert.pem \
    -sha256 \
    -CAserial $CA_SERIAL_FILE \
    -extfile $CONFIG_FILE \
    -extensions peer
