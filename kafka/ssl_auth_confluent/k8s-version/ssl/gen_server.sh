#!/bin/bash
source ./func

# Contraseñas separadas para Keystore y Truststore
KEYSTORE_PASSWORD="${CA_PASSWORD}"
TRUSTSTORE_PASSWORD="lalaland"

# Variables del servidor Kafka
SERVER_ALIAS="kafka-server"
SERVER_DNAME="CN=kafka-server, OU=Test, O=Test, L=Test, S=Test, C=US"

KEYSTORE_DIR="./secrets"
SERVER_KEYSTORE="${KEYSTORE_DIR}/${SERVER_ALIAS}.keystore.jks"
SERVER_TRUSTSTORE="${KEYSTORE_DIR}/${SERVER_ALIAS}.truststore.jks"
SERVER_CERT="${KEYSTORE_DIR}/${SERVER_ALIAS}-cert"
SERVER_CSR="${KEYSTORE_DIR}/${SERVER_ALIAS}.csr"

# Crear directorios para los secretos y salida
mkdir -p ${KEYSTORE_DIR}

# Generar CA
generate_ca

# Generar y firmar certificados para el servidor
generate_keystore ${SERVER_ALIAS} "${SERVER_DNAME}" ${SERVER_KEYSTORE} ${KEYSTORE_PASSWORD}
generate_csr ${SERVER_KEYSTORE} ${SERVER_ALIAS} ${SERVER_CSR} ${KEYSTORE_PASSWORD}
sign_csr ${SERVER_CSR} ${SERVER_CERT}
import_to_store  ${SERVER_TRUSTSTORE} "CARoot" ${CA_CERT} ${TRUSTSTORE_PASSWORD}
import_to_store  ${SERVER_KEYSTORE} "CARoot" ${CA_CERT} ${KEYSTORE_PASSWORD}
import_to_store  ${SERVER_KEYSTORE} ${SERVER_ALIAS} ${SERVER_CERT} ${KEYSTORE_PASSWORD}

# Limpiar archivos temporales
rm ${SERVER_CSR} ${SERVER_CERT}.crt

# Guardar las contraseñas en los archivos correspondientes
echo ${CA_PASSWORD} > ${KEYSTORE_DIR}/key.credentials
echo ${TRUSTSTORE_PASSWORD} > ${KEYSTORE_DIR}/truststore.credentials
echo ${KEYSTORE_PASSWORD} > ${KEYSTORE_DIR}/keystore.credentials

SERVER_KEYSTORE_B64=$(base64 -w 0 ${SERVER_KEYSTORE})
SERVER_TRUSTSTORE_B64=$(base64 -w 0 ${SERVER_TRUSTSTORE})

cat <<EOF > ${SECRET_FILE}
apiVersion: v1
kind: Secret
metadata:
  name: kafka-jks-secret
  namespace: kafka-ssl
type: Opaque
data:
  keystore.credentials: $(echo -n "${KEYSTORE_PASSWORD}" | base64)
  key.credentials: $(echo -n "${KEY_PASSWORD}" | base64)
  truststore.credentials: $(echo -n "${TRUSTSTORE_PASSWORD}" | base64)
  kafka.server.keystore.jks: ${SERVER_KEYSTORE_B64}
  kafka.server.truststore.jks: ${SERVER_TRUSTSTORE_B64}
EOF

echo "Secreto generado en ${SECRET_FILE}"
