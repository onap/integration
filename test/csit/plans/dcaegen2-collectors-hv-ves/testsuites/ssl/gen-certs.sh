#!/usr/bin/env bash

set -eu -o pipefail -o xtrace

STORE_PASS=onaponap
CN_PREFIX=dcaegen2-hvves
DNAME_PREFIX="C=PL,ST=DL,L=Wroclaw,O=Nokia,OU=MANO,CN=${CN_PREFIX}"
TRUST=trust

store_opts="-storetype PKCS12 -storepass ${STORE_PASS} -noprompt"

function gen_key() {
  local key_name="$1"
  local ca="$2"
  local keystore="-keystore ${key_name}.p12 ${store_opts}"
  keytool -genkey -alias ${key_name} \
      ${keystore} \
      -keyalg RSA \
      -validity 730 \
      -keysize 2048 \
      -dname "${DNAME_PREFIX}-${key_name}"
  keytool -import -trustcacerts -alias ${ca} -file ${ca}.crt ${keystore}

  keytool -certreq -alias ${key_name} -keyalg RSA ${keystore} | \
      keytool -alias ${ca} -gencert -ext "san=dns:${CN_PREFIX}-${ca}" ${store_opts} -keystore ${ca}.p12 | \
      keytool -alias ${key_name} -importcert ${keystore}
}


function gen_ca() {
  local ca="$1"
  keytool -genkeypair ${store_opts} -alias ${ca} -dname "${DNAME_PREFIX}-${ca}" -keystore ${ca}.p12
  keytool -export -alias ${ca} -file ${ca}.crt ${store_opts} -keystore ${ca}.p12
}

function gen_truststore() {
  local trusted_ca="$1"
  keytool -import -trustcacerts -alias ca -file ${trusted_ca}.crt ${store_opts} -keystore ${TRUST}.p12
}

function clean() {
  rm -f *.crt *.p12
}

if [[ $# -eq 0 ]]; then
  gen_ca ca
  gen_ca untrustedca
  gen_truststore ca
  gen_key client ca
  gen_key server ca
  gen_key untrustedclient untrustedca
elif [[ $1 == "clean" ]]; then
  clean
else
  echo "usage: $0 [clean]"
  exit 1
fi

