#!/bin/bash

# SCRIPTS
VAULT_INIT_SCRIPT="/home/vault/config/vault_init.sh"

# VAULT CONFIG
CONFIG_PATH="/home/vault/config"
BUILD_FILES="${CONFIG_PATH}/build"
LOG_LEVEL=debug

# CA/TLS CONFIG
export CA_CERTIFICATE="${BUILD_FILES}/certificates/ca/ca.crt"
CA_KEY="${BUILD_FILES}/certificates/ca/ca.key"
VAULT_CSR="${BUILD_FILES}/certificates/csr/vault.csr"
export TLS_CERTIFICATE="${BUILD_FILES}/certificates/tls/tls.crt"
export TLS_KEY="${BUILD_FILES}/certificates/tls/tls.key"

function generate_certificates {

    openssl req -new -sha256 -newkey rsa:2048 -days 365 -nodes -x509 -subj "/C=GR/ST=Attica/L=Athens/O=Vault/CN=localhost" -keyout "${CA_KEY}" -out "${CA_CERTIFICATE}"

    openssl genrsa -out "${TLS_KEY}" 2048

    openssl req -new -key "${TLS_KEY}" -out "${VAULT_CSR}" -config "/home/vault/config/ssl_config/vault.cnf"

    openssl x509 -req -days 365 -in "${VAULT_CSR}" -CA "${CA_CERTIFICATE}" -CAkey "${CA_KEY}" -CAcreateserial -sha256 -out "${TLS_CERTIFICATE}" -extensions v3_req -extfile "/home/vault/config/ssl_config/vault.cnf"

    openssl x509 -in "${TLS_CERTIFICATE}" -text -noout

    chown -R nobody:nobody "${BUILD_FILES}"
    chmod -R 777 "${BUILD_FILES}"
}

function init {
    mkdir -p "${BUILD_FILES}"/certificates/ca
    mkdir -p "${BUILD_FILES}"/certificates/csr
    mkdir -p "${BUILD_FILES}"/certificates/tls

    generate_certificates

    nohup vault server -log-level=${LOG_LEVEL} -config /home/vault/config/vault_config/config.hcl &
    VAULT_PID=$!

    if [ -f "$VAULT_INIT_SCRIPT" ]; then
        /bin/bash $VAULT_INIT_SCRIPT
    fi

    wait $VAULT_PID

}

init
