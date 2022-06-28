#!/bin/bash

# VAULT-SPECIFIC CONFIG
export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_CACERT="$CA_CERTIFICATE"

# VARIOUS
VAULT_CONFIG_FILE="/home/vault/other/configs/vault-config.json"
VAULT_POLICIES_DIR="/home/vault/other/policies"

VAULT_OPERATOR_SECRETS_JSON_PATH="/home/vault/config/vault_operator_secrets.json"

# MAIN FUNCTIONS

function init {
    # Initialize Vault
    printf "Initializing Vault...\n"
    while [ -z "$VAULT_OPERATOR_SECRETS" ]; do
        VAULT_OPERATOR_SECRETS=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)
        if [ -z "$VAULT_OPERATOR_SECRETS" ]; then
            printf "Could not initialize Vault. Retrying...\n"
        fi
    done
    # Export Vault operator keys (root_token and unseal keys)
    echo $VAULT_OPERATOR_SECRETS | jq . >$VAULT_OPERATOR_SECRETS_JSON_PATH
    printf "Vault initialized.\n"
}

function unseal {
    # Unseal Vault
    printf "Unsealing Vault...\n"
    VAULT_OPERATOR_SECRETS=$(cat $VAULT_OPERATOR_SECRETS_JSON_PATH)
    VAULT_UNSEAL_KEYS=$(echo $VAULT_OPERATOR_SECRETS | jq -r .unseal_keys_b64[])
    for VAULT_UNSEAL_KEY in $VAULT_UNSEAL_KEYS; do
        vault operator unseal $VAULT_UNSEAL_KEY
    done
}

function authenticate {
    # Authenticate Vault
    printf "Authenticating Vault...\n"
    VAULT_OPERATOR_SECRETS=$(cat $VAULT_OPERATOR_SECRETS_JSON_PATH)
    VAULT_TOKEN=$(echo $VAULT_OPERATOR_SECRETS | jq -r .root_token)
    export VAULT_TOKEN=$VAULT_TOKEN
}

function unauthenticate {
    # Unauthenticate Vault
    printf "Unauthenticating Vault...\n"
    unset VAULT_TOKEN
    printf "Unauthenticated Vault.\n"
}

function abe_init {
    # Initialize the ABE Plugin
    printf "Initializing the ABE Plugin...\n"

    SHA256=$(cat /vault/plugins/SHA256SUMS | cut -d " " -f1)

    # Write the ABE Plugin to the Plugins' Catalog
    vault write sys/plugins/catalog/secret/abe \
        sha_256="$SHA256" \
        command="abe --ca-cert=$CA_CERTIFICATE --client-cert=$TLS_CERTIFICATE --client-key=$TLS_KEY"

    # Enable the ABE Plugin

    # Load the ABE Path from the Config
    VAULT_ABE_PATH=$(cat $VAULT_CONFIG_FILE | jq -r .abe_path)
    vault secrets enable -path=${VAULT_ABE_PATH} abe

    printf "Initialized the ABE Plugin.\n"
}

function load_abe_access_policies {
    # Load the ABE Access Policies
    printf "Loading the ABE Access Policies...\n"

    for file in ${VAULT_POLICIES_DIR}/*.hcl; do

        local policy_name="${file##*/}"
        local policy_data=$(cat ${file} | base64)

        echo "${policy_data}" | base64 -d | vault policy write "${policy_name%.*}" -

    done

    printf "Loaded the ABE Access Policies to Hashicorp Vault.\n"

}

# Helper functions

function vault_status {
    printf "Vault status:\n"
    vault status
}

function vault_health {
    printf "Vault health:\n"
    vault status -format=json
}

if [ -f VAULT_OPERATOR_SECRETS_JSON_PATH ]; then
    # Vault is already initialized
    printf "Vault is already initialized.\n"
    authenticate
    vault_status
    vault_health
    unauthenticate
else
    # Vault is not initialized
    printf "Vault is not initialized.\nStarting the initialization..\n"
    init
    unseal
    authenticate
    vault_status
    vault_health
    load_abe_access_policies
    abe_init
    unauthenticate
fi
