# vault-secrets-abe

Unofficial ABE (Attribute Based Encryption) secrets plugin for Hashicorp Vault

|            Plugin Dependencies [Tested with]            |                       OS Dependencies                       |
| :-----------------------------------------------------: | :---------------------------------------------------------: |
| [Hashicorp Vault v. 1.8.0](https://www.vaultproject.io) |       [PBC Library](https://crypto.stanford.edu/pbc/)       |
|       [Docker v. 20.10](https://www.docker.com/)        | flex bison libssl-dev python-dev libgmp-dev build-essential |
|           [Golang v. 1.18.3](https://go.dev/)           |

# Vault Secrets ABE plugin

The following instructions will guide you on how to build the ABE binary and start a Hashicorp Vault server in `dev mode`. For more information and instructions on how to:

- register users
- use the policies
- create requests to the _Vault Secrets ABE_ plugin

kindly read the _SETUP.md_ file. In the _SETUP.md_ file you will find instructions on how to deploy a docker container, as well as a `Postman Collection` in order to easier reach and test out the plugin.

## Instructions

1. Execute:
   > $ go mod tidy
2. Build the ABE Plugin secret engine binary by executing:

   > $ go build -ldflags "-X abe/plugin.sa_enabled=**true**" -o vault/plugins/abe

      <div align="center">

   |                        sa_enabled                        |
   | :------------------------------------------------------: |
   | **true** to enable SA capabilities, **false** to disable |

      </div>

3. Run Hashicorp Vault in `dev mode` to register and test the _Vault Secrets ABE_ plugin:
   > $ vault server -dev -dev-root-token-id=root -dev-plugin-dir=./vault/plugins
4. Export the VAULT_TOKEN & VAULT_ADDR environment variables:
   > $ export VAULT_TOKEN=root && VAULT_ADDR="http://127.0.0.1:8200"
5. Enable the plugin at the specified path:
   > $ vault secrets enable -path=abe abe

You may now load the available policies that can be found at:

> vault-secrets-abe/other/docker/policies

create some clients and use the ABE plugin.

## _Vault Secrets ABE_ plugin _HTTP_ endpoints

| PATH                                           | METHOD | DESCRIPTION                                                                                                 | REQUEST BODY                                                                                           | RESPONSE BODY                                                                                                                                                                                                                                                                                    |
| ---------------------------------------------- | :----: | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| /encrypt                                       |  POST  | Encrypt a message                                                                                           | `{ "message": "Message to encrypt", "policy": "attr1 or attr2 and attr3 and SA" }`                     | `{ ... "data": { "b64_enc_data": "base64 encoded response", }, ... }`                                                                                                                                                                                                                            |
| /**ADMIN_ENTITY**/addattributes                |  POST  | Create ABE attributes and their corresponding keys                                                          | `{ "authorityAttributes": ["auth_abe_attr1"], "commonAttributes": ["cmmn_abe_attr1"] }`                | `{ ... "data": { "generated_data": { "public_segments": { "authority_attributes": [ { "Attribute": "AUTH_ABE_ATTR1", "alphai": "[..., ...]", "yi": "[..., ...]", }, ], "common_attributes": [ { "Attribute": "CMMN_ABE_ATTR1", "alphai": "[..., ...]", "yi": "[..., ...]", }, ], }, }, }, ... }` |
| /keygen/**ADMIN_ENTITY**/**CLIENT_ENTITY**     |  POST  | Generate keys for a Client Entity (by an Admin Entity)                                                      | `{ "authorityAttributes": ["auth_abe_attr1"], "commonAttributes": ["cmmn_abe_attr1"] }`                | `{ ... "data": { "Authority Keys generated:": ["AUTH_ABE_ATTR1"], "Common Keys generated:": ["CMMN_ABE_ATTR2"], "Generated for (GID)": "CLIENT_ENTITY", }, ... }`                                                                                                                                |
| /syskeygen/_SYSTEM_ATTRIBUTE_/**ADMIN_ENTITY** |  POST  | Let an **ADMIN ENTITY** to have access to a system attribute (e.g. _SYSTEM_ATTRIBUTE_ = _SA_)               | `-`                                                                                                    | `{ --- "data": { "Authority:": "ADMIN_ENTITY", "System Attribute": "SA" }, --- }`                                                                                                                                                                                                                |
| /sysdecrypt/**ADMIN_ENTITY**/**CLIENT_ENTITY** |  POST  | System Decrypt an ABE encrypted message and bind the system decrypted ciphertext with the **CLIENT_ENTITY** | `{ "cryptogram":"", "sub_policy": "SA" }`                                                              | `{ --- "data": { "b64_enc_data_sysdec": "base64 encoded response", }, --- }`                                                                                                                                                                                                                     |
| /decrypt/**CLIENT_ENTITY**                     |  POST  | Decrypt an ABE encrypted (or system decrypted) message                                                      | `{ "cryptogram": "encrypted or system decrypted response", "sub_policy": "attr1 or attr2 and attr3" }` | `{ --- "data": { "decrypted_data": "Decrypted message (plaintext)" }, --- }`                                                                                                                                                                                                                     |
