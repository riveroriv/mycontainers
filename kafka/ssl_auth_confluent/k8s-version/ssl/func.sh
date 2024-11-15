#!/bin/bash

# Variables para la CA
CA_PASSWORD="holacomoestas"
CA_KEY="ca-key"
CA_CERT="ca-cert"
OPENSSL_CONF="./openssl.cnf"
VALIDITY=365

# Función para generar una CA (Autoridad Certificadora)
generate_ca() {
  if [[ ! -f ${CA_KEY}.key ]]; then
    openssl req -new -x509 -keyout ${CA_KEY}.key \
     -out ${CA_CERT}.crt -days ${VALIDITY} \
     -passout pass:${CA_PASSWORD} \
     -subj "//Skip=skip/C=US/ST=Test/L=Test/O=Test/OU=Test/CN=TestCA"
  fi
}

# Función para generar un keystore
generate_keystore() {
  local alias=$1
  local dname=$2
  local keystore=$3
  local password=$4

  keytool -genkey -noprompt -alias ${alias} -dname "${dname}" \
   -keystore ${keystore} -keyalg RSA \
   -storepass ${password} -validity ${VALIDITY}
}

# Función para generar una solicitud de certificado (CSR) con SAN
generate_csr() {
  local keystore=$1
  local alias=$2
  local csr=$3
  local password=$4

  keytool -keystore ${keystore} -alias ${alias} \
   -certreq -file ${csr} \
   -storepass ${password}
}

# Función para firmar el CSR con el CA
sign_csr() {
  local csr=$1
  local cert=$2
  openssl x509 -req -CA ${CA_CERT}.crt -CAkey ${CA_KEY}.key \
    -in ${csr} -out ${cert}.crt \
    -days ${VALIDITY} -CAcreateserial -passin pass:${CA_PASSWORD} \
    -extensions req_ext -extfile ${OPENSSL_CONF}
}

# Función para importar certificados en un store (keystore o truststore)
import_to_store() {
  local store=$1
  local alias=$2
  local cert=$3
  local password=$4

  keytool -keystore ${store} -alias ${alias} -import \
  -file ${cert}.crt -storepass ${password} -noprompt
}
