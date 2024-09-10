#!/bin/bash

# Variables
PASSWORD="changeit"
DNAME="CN=kafka-server, OU=Test, O=Test, L=Test, S=Test, C=US"
VALIDITY=365
KEYSTORE_PATH="./secrets/kafka.server.keystore.jks"
TRUSTSTORE_PATH="./secrets/kafka.server.truststore.jks"
CA_KEY="ca-key"
CA_CERT="ca-cert"
KAFKA_CERT="kafka-server-cert"
CLIENT_KEYSTORE_PATH="./secrets/client.keystore.jks"
CLIENT_TRUSTSTORE_PATH="./secrets/client.truststore.jks"
CLIENT_CERT="client-cert"
CLIENT_CSR="client.csr"
OPENSSL_CONF="openssl.cnf"

# Crear directorio para los secretos
mkdir -p secrets

# Generar el CA (Autoridad Certificadora)
openssl req -new -x509 -keyout ${CA_KEY}.key -out ${CA_CERT}.crt -days ${VALIDITY} -passout pass:${PASSWORD} -subj "//Skip=sip/CN=TestCA/OU=Test/O=Test/L=Test/S=Test/C=US"

# Crear el Keystore
keytool -genkey -noprompt -alias kafka-server -dname "${DNAME}" -keystore ${KEYSTORE_PATH} -keyalg RSA -storepass ${PASSWORD} -keypass ${PASSWORD} -validity ${VALIDITY}

# Crear una solicitud de certificado (CSR) con SAN
openssl req -new -key ${KEYSTORE_PATH} -out ${KAFKA_CERT}.csr -config ${OPENSSL_CONF}

# Firmar el CSR con el CA
openssl x509 -req -CA ${CA_CERT}.crt -CAkey ${CA_KEY}.key -in ${KAFKA_CERT}.csr -out ${KAFKA_CERT}.crt -days ${VALIDITY} -CAcreateserial -passin pass:${PASSWORD} -extensions req_ext -extfile ${OPENSSL_CONF}

# Importar el certificado del CA al Truststore
keytool -keystore ${TRUSTSTORE_PATH} -alias CARoot -import -file ${CA_CERT}.crt -storepass ${PASSWORD} -noprompt

# Importar el certificado del CA al Keystore (además de al Truststore)
keytool -keystore ${KEYSTORE_PATH} -alias CARoot -import -file ${CA_CERT}.crt -storepass ${PASSWORD} -noprompt

# Importar el certificado firmado al Keystore
keytool -keystore ${KEYSTORE_PATH} -alias kafka-server -import -file ${KAFKA_CERT}.crt -storepass ${PASSWORD} -keypass ${PASSWORD} -noprompt

# Generar el Keystore y Truststore del Cliente
# Crear el Keystore para el Cliente
keytool -genkey -noprompt -alias client -dname "CN=client, OU=Test, O=Test, L=Test, S=Test, C=US" -keystore ${CLIENT_KEYSTORE_PATH} -keyalg RSA -storepass ${PASSWORD} -keypass ${PASSWORD} -validity ${VALIDITY}

# Crear una solicitud de certificado (CSR) para el Cliente
keytool -keystore ${CLIENT_KEYSTORE_PATH} -alias client -certreq -file ${CLIENT_CSR} -storepass ${PASSWORD} -keypass ${PASSWORD}

# Firmar el CSR del Cliente con el CA
openssl x509 -req -CA ${CA_CERT}.crt -CAkey ${CA_KEY}.key -in ${CLIENT_CSR} -out ${CLIENT_CERT}.crt -days ${VALIDITY} -CAcreateserial -passin pass:${PASSWORD}

# Importar el certificado del CA al Truststore del Cliente
keytool -keystore ${CLIENT_TRUSTSTORE_PATH} -alias CARoot -import -file ${CA_CERT}.crt -storepass ${PASSWORD} -noprompt

# Importar el certificado del CA al Keystore (además de al Truststore)
keytool -keystore ${CLIENT_KEYSTORE_PATH} -alias CARoot -import -file ${CA_CERT}.crt -storepass ${PASSWORD} -noprompt

# Importar el certificado del Cliente al Keystore
keytool -keystore ${CLIENT_KEYSTORE_PATH} -alias client -import -file ${CLIENT_CERT}.crt -storepass ${PASSWORD} -keypass ${PASSWORD} -noprompt

# Limpiar archivos temporales
rm ${KAFKA_CERT}.csr ${CA_KEY}.key ${KAFKA_CERT}.crt ${CLIENT_CSR} ${CLIENT_CERT}.crt
