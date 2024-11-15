#!/bin/bash
source ./func

# Contraseñas separadas para Keystore y Truststore
KEYSTORE_PASSWORD="kafkauikeystore"
TRUSTSTORE_PASSWORD="dontletmedown"

# Variables del cliente
CLIENT_ALIAS="kafkaui"
CLIENT_DNAME="CN=kafkaui, OU=Test, O=Test, L=Test, S=Test, C=US"

KEYSTORE_DIR="clients"
CLIENT_KEYSTORE="${KEYSTORE_DIR}/${CLIENT_ALIAS}.keystore.jks"
CLIENT_TRUSTSTORE="${KEYSTORE_DIR}/${CLIENT_ALIAS}.truststore.jks"
CLIENT_CERT="${KEYSTORE_DIR}/${CLIENT_ALIAS}-cert"
CLIENT_CSR="${KEYSTORE_DIR}/${CLIENT_ALIAS}.csr"

# Crear directorios para los secretos y salida
mkdir -p ${KEYSTORE_DIR}

# Generar y firmar certificados para el cliente
generate_keystore ${CLIENT_ALIAS} "${CLIENT_DNAME}" ${CLIENT_KEYSTORE} ${KEYSTORE_PASSWORD}
generate_csr ${CLIENT_KEYSTORE} ${CLIENT_ALIAS} ${CLIENT_CSR} ${KEYSTORE_PASSWORD}
sign_csr ${CLIENT_CSR} ${CLIENT_CERT}
import_to_store ${CLIENT_TRUSTSTORE} "CARoot" ${CA_CERT} ${TRUSTSTORE_PASSWORD}
import_to_store ${CLIENT_KEYSTORE} "CARoot" ${CA_CERT} ${KEYSTORE_PASSWORD}
import_to_store ${CLIENT_KEYSTORE} ${CLIENT_ALIAS} ${CLIENT_CERT} ${KEYSTORE_PASSWORD}

# Limpiar archivos temporales
rm ${CLIENT_CSR} ${CLIENT_CERT}.crt
