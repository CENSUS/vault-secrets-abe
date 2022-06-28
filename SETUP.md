# Installation Instructions

The _Vault Secrets ABE_ plugin offers a Makefile in order to easily deploy and test it with the [Hashicorp Vault](https://www.vaultproject.io/).

The Makefile offers 6 targets:

|         Target         | Description                                                                  |
| :--------------------: | :--------------------------------------------------------------------------- |
|      _**build**_       | Builds the Docker Image - SA capability **is not** enabled                   |
| _**build-sa-enabled**_ | Builds the Docker Image - SA capability **is** enabled                       |
|       _**run**_        | Deploys the Docker Image (localhost:8200)                                    |
|       _**all**_        | Builds the Docker Image & Deploys it - SA capability **is not** enabled      |
|  _**all-sa-enabled**_  | Builds the Docker Image & Deploys it - SA capability **is** enabled          |
|   _**clean-build**_    | Removes the current configuration data (Certificates, Vault data, keys etc.) |

The **SA Capability** lets the Plugin utilize the System Attribute [SA]. When enabled, the plugin also accepts _POST_ requests at its `/sys-decrypt` endpoint (e.g. `/sys-decrypt/ORGANIZATION/143lokjhcf12417bc7b9z51162r998ew`).

In order to deploy a Docker container with the Hashicorp Vault (_Vault Secrets ABE_ plugin included), make sure that `make` is available on your system and execute:

> $ make [**all** | **all-sa-enabled**]

Upon successful deployment, use the _**root token**_ that is available at:

> vault-secrets-abe/other/docker/vault/config/vault_operator_secrets.json

in order to login to the Hashicorp Vault. Hashicorp Vault should already be unsealed. If Hashicorp Vault is not unsealed, you may use the unseal keys that can be also found in the document that was mentioned above.

# Clients

Before proceeding to the creation of the Clients, you must first deploy an **Authentication Method** and create two (2) **Groups**: `Admin & Client` Groups.

## Authentication Method

Navigate to the [Access](https://localhost:8200/ui/vault/access) menu item and click the [`Enable new method`](https://localhost:8200/ui/vault/settings/auth/enable) button. Then,

- choose the _Username & Password_ authentication method and clict `Next`
- provide a path (e.g. default `userpass`)
- click `Enable Method`
- click `Update Options`

The newly created Authentication Method should be available at the path that you defined.

## Groups

Navigate to the [Groups](https://localhost:8200/ui/vault/access/identity/groups) page of Vault. Then,

- click `Create group`
- provide the name of the Group (e.g. `ABE_ADMINS` or `ABE_CLIENTS`)
- choose the appropriate **Policy** (i.e. **ABE_ADMINS** => `abe-admin-policy`, **ABE_CLIENTS** => `abe-client-policy`)
- click `Create`

Repeat the procedure for both groups' types (Admins & Clients).

## Set up a Client

1. Navigate to the [Entities](https://localhost:8200/ui/vault/access/identity/entities) page of Vault. Then,

- click `Create entity`
- provide a name for the entity
- click `Create`

2. Navigate to the [Auth Methods](https://localhost:8200/ui/vault/access) page of Vault. Then,

- choose the _Username & Password_ authentication method that you created (e.g. `userpass/`)
- click `Create user`
- provide a Username and a Password for the `User object`
- click `Save`

3. Navigate back to the [Entities](https://localhost:8200/ui/vault/access/identity/entities) page of Vault. Then,

- choose the entity that you created
- go to the `aliases` tab and click `Add alias`
- provide the username of the `User object` (Step 3.) and choose the appropriate `Auth Backend` (e.g. `userpass/`)

4. Navigate back to the [Groups](https://localhost:8200/ui/vault/access/identity/groups) page of Vault. Then,

- choose the Group that this Client belongs to (i.e. **ABE_ADMINS** | **ABE_CLIENTS**)
- click `Edit Group`
- scroll to the bottom and at the `Member Entity IDs`, choose the Entity that you created
- click `Save`

Follow the above instructions to create an Admin and a Client.

You should be ready to test the _Vault Secrets ABE_ plugin.

Login to Hashicorp Vault and create some requests to the _Vault Secrets ABE_ plugin.

# Test the _Vault Secrets ABE_ plugin

## Login to Vault

Use one of the clients that you created in order to login with the Hashicorp Vault.

<details>
  <summary>HTTP Login Post request example</summary>

```
curl --location --request POST 'https://localhost:8200/v1/auth/userpass/login/admin1' \
--header 'Content-Type: application/json' \
--data-raw '{
    "password": "admin1pw"
}'
```

</details>

<details>
  <summary>Click to see an example of a valid response</summary>

```yaml
{
  "request_id": "69388d0f-1cb6-839f-8f2c-913645bcdc56",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": null,
  "wrap_info": null,
  "warnings": null,
  "auth":
    {
      "client_token": "s.CTPtEBYPszSDcEsQeaadEzdX",
      "accessor": "TkzhkGdQwZOd02f3koC4yVwj",
      "policies": ["abe-admin-policy", "default"],
      "token_policies": ["default"],
      "identity_policies": ["abe-admin-policy"],
      "metadata": { "username": "admin1" },
      "lease_duration": 86400,
      "renewable": true,
      "entity_id": "6249a490-a784-caa9-8062-7748ed121197",
      "token_type": "service",
      "orphan": true,
    },
}
```

</details>
<br>

You may now use the `client_token` in order to send authenticated requests to the _Vault Secrets ABE_ plugin

### Create ABE Attributes

First, you should login with an Entity that is a member of the `ABE_ADMINS` Group (thus, adopts the `abe-admin-policy`). Then, you should be able to create some ABE attributes.
In this example, we are going to create two (2) ABE attributes:

- An Authority Attribute `auth_abe_attr1`
- A Common Attribute `cmmn_abe_attr2`

<details>
  <summary>HTTP Add Attributes Post request example</summary>

```
curl --location --request POST 'https://localhost:8200/v1/abe/admin1/addattributes' \
--header 'X-Vault-Token: s.CTPtEBYPszSDcEsQeaadEzdX' \
--header 'Content-Type: application/json' \
--data-raw '{
    "authorityAttributes": [
        "auth_abe_attr1"
    ],
    "commonAttributes": [
        "cmmn_abe_attr2"
    ]
}'
```

</details>

<details>
  <summary>Click to see an example of a valid response</summary>

```yaml
{
  "request_id": "f2cfe377-a549-5c65-3fe8-7e0b19b9512e",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data":
    {
      "generated_data":
        {
          "public_segments":
            {
              "authority_attributes":
                [
                  {
                    "Attribute": "AUTH_ABE_ATTR1",
                    "alphai": "[..., ...]",
                    "yi": "[..., ...]",
                  },
                ],
              "common_attributes":
                [
                  {
                    "Attribute": "CMMN_ABE_ATTR2",
                    "alphai": "[..., ...]",
                    "yi": "[..., ...]",
                  },
                ],
            },
        },
    },
  "wrap_info": null,
  "warnings": null,
  "auth": null,
}
```

</details>

<br>

### System Key Generation

First, you should login with an Entity that is a member of the `ABE_ADMINS` Group (thus, adopts the `abe-admin-policy`). Then, you should be able to initialize the System Decryption capabilities for that Entity.

<details>
  <summary>HTTP System Key Generation Post request example</summary>

```
curl --location --request POST 'https://localhost:8200/v1/abe/syskeygen/SA/admin1' \
--header 'X-Vault-Token: s.CTPtEBYPszSDcEsQeaadEzdX' \
--data-raw ''
```

</details>

<details>
  <summary>Click to see an example of a valid response</summary>

```yaml
{
  "request_id": "69388d0f-1cb6-839f-8f2c-913645bcdc56",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": null,
  "wrap_info": null,
  "warnings": null,
  "auth":
    {
      "client_token": "s.CTPtEBYPszSDcEsQeaadEzdX",
      "accessor": "TkzhkGdQwZOd02f3koC4yVwj",
      "policies": ["abe-admin-policy", "default"],
      "token_policies": ["default"],
      "identity_policies": ["abe-admin-policy"],
      "metadata": { "username": "admin1" },
      "lease_duration": 86400,
      "renewable": true,
      "entity_id": "6249a490-a784-caa9-8062-7748ed121197",
      "token_type": "service",
      "orphan": true,
    },
}
```

</details>

<br>

### ABE Keys Generation

First, you should login with a client that its correlated Entity is a member of the `ABE_ADMINS` Group (thus, adopts the `abe-admin-policy`). Then, you should be able to provide a client with ABE Keys (Common or Authority ABE Attributes).

In this example, we will provide **client1** (a Client that adopts the `abe-client-policy`) with ABE Keys (`auth_abe_attr1`, `cmmon_abe_attr2`). **admin1** will provide the client with the keys. `Authority attributes` can only be given by the Entities that own them. I.e. `auth_abe_attr1` can only be given by `admin1` to `client1`.

<details>
  <summary>HTTP System Key Generation Post request example</summary>

```
curl --location --request POST 'https://localhost:8200/v1/abe/keygen/admin1/client1' \
--header 'X-Vault-Token: s.CTPtEBYPszSDcEsQeaadEzdX' \
--header 'Content-Type: application/json' \
--data-raw '{
    "authorityAttributes": [
        "auth_abe_attr1"
    ],
    "commonAttributes": [
        "cmmn_abe_attr2"
    ]
}'
```

</details>

<details>
  <summary>Click to see an example of a valid response</summary>

```yaml
{
  "request_id": "947c6fc4-09c0-7e58-ca40-15d134aba9ae",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data":
    {
      "Authority Keys generated:": ["AUTH_ABE_ATTR1"],
      "Common Keys generated:": ["CMMN_ABE_ATTR2"],
      "Generated for (GID)": "client1",
    },
  "wrap_info": null,
  "warnings": null,
  "auth": null,
}
```

</details>

<br>

### Encryption - Decryption Mechanisms

#### Encryption Mechanism

First, you should login with an Entity (Admin/Client). Then, you should be able to encrypt a message.

We will encrypt a message with ABE Policy: `auth_abe_attr1 or cmmn_abe_attr2 and SA`, meaning that only an entity that owns the ABE attribute _auth_abe_attr1_ **OR** _cmmn_abe_attr2_ should be able to decrypt the message. The encrypted message must be first _system decrypted_ by an entity that owns the _SA system attribute_.

<details>
  <summary>HTTP ABE Encryption Mechanism Post request example</summary>

```
curl --location --request POST 'https://localhost:8200/v1/abe/encrypt' \
--header 'X-Vault-Token: s.CTPtEBYPszSDcEsQeaadEzdX' \
--header 'Content-Type: application/json' \
--data-raw '{
    "message": "Lorem ipsum dolor sit amet.",
    "policy": "auth_abe_attr1 or cmmn_abe_attr2 and SA"
}'
```

</details>

<details>
  <summary>Click to see an example of a valid response</summary>

```yaml
{
  "request_id": "c130a827-5e72-6476-097b-90e365334721",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data":
    {
      "b64_enc_data": "eyJDMCI6IlpaUC9aekpvNTRhSGQwTFg4T05ZT3BBeFBkQW56dm9lN0RRY3JaWmZEZUEwTnZSL09KbStHcHBFUkl1bjVMbjQ3VkRac0NwUm1VSE9ETldHeVZFcGlsWnNiOXAvWXlPNW1ROWQyVnlOVXNjVk9rTUFpMXVCLzRsMVBldkdFKy9SUlFvaDRQUzhCcXFVS0Y2bHpnVVNKWG5EdldxNk4weE9PcmtnNitVUEtHND0iLCJDMSI6eyJBVVRIX0FCRV9BVFRSMSI6Im1paHM2dkgyNmNXeWFYVU1DUDVjZ3k1WmJOU2l5OWFRd0pRY3RpRTVMb1BmYTY3ZmdxQVQ1clp5elhrcmVmZXlkZ0lxUE8zNE5yWWlGUHZzYXVZZG9WbXEzNVRPZUIrTDBpUHJBL3hZc25MbTlRT2QzYnhQalNwQUZFQ051K1ptdldDUlNWR2NYTmQ5MXFCZlhEUldZVXBOWmxWZ0tqYTFrOTkwTTcreDNqMD0iLCJTQSI6ImJTWmxQdDVINkxpanRIalc3YmR6amd0NzI4cDlpbkJTOTNlbmRlSDhEOG0zZVAwOUFHQlJtYWJkZ3dnUFhMOXN6anJtakx3T0ZpZjBsVUp3VFMyNE1od0JmKzhqUXlFREViakxjeVNsZnBKSEE5Yzdld2pycldWZ1hRV0lSdlZGOE81SkhhRU4yd0ViakRDK0Jzb01obEN1d3NPZmhMZ1BraHNSby9SeExSdz0ifSwiQzIiOnsiQVVUSF9BQkVfQVRUUjEiOiJJeEdSQURQZ0NzVjh0c0Z1cmFrKzRENUVPamxqV3UxeTNCOUprbnh5cmoxRkZ2UG9FZ2RIUnluUGxSRm1OTlk0ZWM2K09DV3g2OEdTaTQ5UmQrZGdtMzMwSFJYNlZqNHczcDJZWWkxR0kvV052a0pnYUJidkVxZmFKa0NoT20yRGdSM1pwTmZpUFVKNGdibTJVY2daNjUrbWdoeGUyT2l0QytMRXdyclNRNGM9IiwiU0EiOiJSZFRMS3FpbHdNdC9FYW1tRGsvRzdNZnhkMmU3QjJITVZiQWxvSUNlaDlVazE0T0N2L0pxaE9vUlM5SjUxYzg3MXRhSXFDVzkzbnZkYUNOQ3MybjBkSGRWYjhobFlBQmFmVTZDZElSK1RzTjVpU3dLQ0RCL0paWU1WWnhJZWlMNi9TeFJmcmtwOW5tdXRpajJYSUM0TmpYZktmWGpSanhQcU5CcHhGS1ZxaFE9In0sIkMzIjp7IkFVVEhfQUJFX0FUVFIxIjoiVjBHVUd6c041UzJMQ0ZGc1pTNmtnbTh0NC9nN29yQjArbHVHTS9zcnIvN1hTV1p4K1FHSy9kSGhVdzVmSWtpbENGVUpCSFh0dVk5b3ZmY0N0TkFaV1ZZaC9FeEI4VXZKUHg2NGZmMEUyWnVGc2Y1bW0xSERvU1R2d1ZDRzEzVWZaYVZ0TDdYUmY1cFpCeFh3TXhZL29oUGpsTDhVZmxlSFNiTnV5T2E3aDdVPSIsIlNBIjoiY1BQNmljZUphMUhtOUhnVE4zdFZHb3dKNmtuOVZNUzZtMlcxdFRSSlJ6NklqNVd4cGVwRnZCLysvS2hVWlorcVdFNGE5TzMzWHNYeXNRWGJadE9lMjVPYlR2bHNzQkJpRHBOWnhqSE9LS0ZldXFhTVRSTHZwZ2FESE1nSjhPdnF0NHlhVFN5ckZmTTI2bjV5YzRnMEt5QllWWU50VnJJU3I3dVRSUVFBYUVFPSJ9LCJFbmNyeXB0ZWRNZXNzYWdlIjoieFEwMlM5cXc3c2I0YmVuWTU2WjE1a2VHalZzY2dpS29PckdnTUwyNDhyST0iLCJDaXBoZXJJViI6IjZHSFpFZzFNbTh1MDJvMDJKTVVWbmc9PSIsIlBvbGljeSI6ImF1dGhfYWJlX2F0dHIxIG9yIGNtbW5fYWJlX2F0dHIyIGFuZCBTQSJ9",
    },
  "wrap_info": null,
  "warnings": null,
  "auth": null,
}
```

</details>

<br>

#### System Decryption Mechanism

First, you should login with an Entity that has access to the SA attribute. The procedure will correlate _client1_ with the ABE System Decrypted ciphertext. Only _client1_ will be able to fully decrypt this message. We will use _admin1_ to System Decrypt the ciphertext.

<details>
  <summary>HTTP ABE System Decryption Mechanism Post request example</summary>

```
curl --location --request POST 'https://localhost:8200/v1/abe/sysdecrypt/admin1/client1' \
--header 'X-Vault-Token: s.CTPtEBYPszSDcEsQeaadEzdX' \
--header 'Content-Type: application/json' \
--data-raw '{    "cryptogram":"eyJDMCI6IlpaUC9aekpvNTRhSGQwTFg4T05ZT3BBeFBkQW56dm9lN0RRY3JaWmZEZUEwTnZSL09KbStHcHBFUkl1bjVMbjQ3VkRac0NwUm1VSE9ETldHeVZFcGlsWnNiOXAvWXlPNW1ROWQyVnlOVXNjVk9rTUFpMXVCLzRsMVBldkdFKy9SUlFvaDRQUzhCcXFVS0Y2bHpnVVNKWG5EdldxNk4weE9PcmtnNitVUEtHND0iLCJDMSI6eyJBVVRIX0FCRV9BVFRSMSI6Im1paHM2dkgyNmNXeWFYVU1DUDVjZ3k1WmJOU2l5OWFRd0pRY3RpRTVMb1BmYTY3ZmdxQVQ1clp5elhrcmVmZXlkZ0lxUE8zNE5yWWlGUHZzYXVZZG9WbXEzNVRPZUIrTDBpUHJBL3hZc25MbTlRT2QzYnhQalNwQUZFQ051K1ptdldDUlNWR2NYTmQ5MXFCZlhEUldZVXBOWmxWZ0tqYTFrOTkwTTcreDNqMD0iLCJTQSI6ImJTWmxQdDVINkxpanRIalc3YmR6amd0NzI4cDlpbkJTOTNlbmRlSDhEOG0zZVAwOUFHQlJtYWJkZ3dnUFhMOXN6anJtakx3T0ZpZjBsVUp3VFMyNE1od0JmKzhqUXlFREViakxjeVNsZnBKSEE5Yzdld2pycldWZ1hRV0lSdlZGOE81SkhhRU4yd0ViakRDK0Jzb01obEN1d3NPZmhMZ1BraHNSby9SeExSdz0ifSwiQzIiOnsiQVVUSF9BQkVfQVRUUjEiOiJJeEdSQURQZ0NzVjh0c0Z1cmFrKzRENUVPamxqV3UxeTNCOUprbnh5cmoxRkZ2UG9FZ2RIUnluUGxSRm1OTlk0ZWM2K09DV3g2OEdTaTQ5UmQrZGdtMzMwSFJYNlZqNHczcDJZWWkxR0kvV052a0pnYUJidkVxZmFKa0NoT20yRGdSM1pwTmZpUFVKNGdibTJVY2daNjUrbWdoeGUyT2l0QytMRXdyclNRNGM9IiwiU0EiOiJSZFRMS3FpbHdNdC9FYW1tRGsvRzdNZnhkMmU3QjJITVZiQWxvSUNlaDlVazE0T0N2L0pxaE9vUlM5SjUxYzg3MXRhSXFDVzkzbnZkYUNOQ3MybjBkSGRWYjhobFlBQmFmVTZDZElSK1RzTjVpU3dLQ0RCL0paWU1WWnhJZWlMNi9TeFJmcmtwOW5tdXRpajJYSUM0TmpYZktmWGpSanhQcU5CcHhGS1ZxaFE9In0sIkMzIjp7IkFVVEhfQUJFX0FUVFIxIjoiVjBHVUd6c041UzJMQ0ZGc1pTNmtnbTh0NC9nN29yQjArbHVHTS9zcnIvN1hTV1p4K1FHSy9kSGhVdzVmSWtpbENGVUpCSFh0dVk5b3ZmY0N0TkFaV1ZZaC9FeEI4VXZKUHg2NGZmMEUyWnVGc2Y1bW0xSERvU1R2d1ZDRzEzVWZaYVZ0TDdYUmY1cFpCeFh3TXhZL29oUGpsTDhVZmxlSFNiTnV5T2E3aDdVPSIsIlNBIjoiY1BQNmljZUphMUhtOUhnVE4zdFZHb3dKNmtuOVZNUzZtMlcxdFRSSlJ6NklqNVd4cGVwRnZCLysvS2hVWlorcVdFNGE5TzMzWHNYeXNRWGJadE9lMjVPYlR2bHNzQkJpRHBOWnhqSE9LS0ZldXFhTVRSTHZwZ2FESE1nSjhPdnF0NHlhVFN5ckZmTTI2bjV5YzRnMEt5QllWWU50VnJJU3I3dVRSUVFBYUVFPSJ9LCJFbmNyeXB0ZWRNZXNzYWdlIjoieFEwMlM5cXc3c2I0YmVuWTU2WjE1a2VHalZzY2dpS29PckdnTUwyNDhyST0iLCJDaXBoZXJJViI6IjZHSFpFZzFNbTh1MDJvMDJKTVVWbmc9PSIsIlBvbGljeSI6ImF1dGhfYWJlX2F0dHIxIG9yIGNtbW5fYWJlX2F0dHIyIGFuZCBTQSJ9",
"sub_policy": "SA"
}'
```

</details>

<details>
  <summary>Click to see an example of a valid response</summary>

```yaml
{
  "request_id": "bda33630-033b-b249-64cf-aed3d9399930",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data":
    {
      "b64_enc_data_sysdec": "eyJDMCI6IlpaUC9aekpvNTRhSGQwTFg4T05ZT3BBeFBkQW56dm9lN0RRY3JaWmZEZUEwTnZSL09KbStHcHBFUkl1bjVMbjQ3VkRac0NwUm1VSE9ETldHeVZFcGlsWnNiOXAvWXlPNW1ROWQyVnlOVXNjVk9rTUFpMXVCLzRsMVBldkdFKy9SUlFvaDRQUzhCcXFVS0Y2bHpnVVNKWG5EdldxNk4weE9PcmtnNitVUEtHND0iLCJDMSI6eyJBVVRIX0FCRV9BVFRSMSI6Im1paHM2dkgyNmNXeWFYVU1DUDVjZ3k1WmJOU2l5OWFRd0pRY3RpRTVMb1BmYTY3ZmdxQVQ1clp5elhrcmVmZXlkZ0lxUE8zNE5yWWlGUHZzYXVZZG9WbXEzNVRPZUIrTDBpUHJBL3hZc25MbTlRT2QzYnhQalNwQUZFQ051K1ptdldDUlNWR2NYTmQ5MXFCZlhEUldZVXBOWmxWZ0tqYTFrOTkwTTcreDNqMD0iLCJTQSI6ImJTWmxQdDVINkxpanRIalc3YmR6amd0NzI4cDlpbkJTOTNlbmRlSDhEOG0zZVAwOUFHQlJtYWJkZ3dnUFhMOXN6anJtakx3T0ZpZjBsVUp3VFMyNE1od0JmKzhqUXlFREViakxjeVNsZnBKSEE5Yzdld2pycldWZ1hRV0lSdlZGOE81SkhhRU4yd0ViakRDK0Jzb01obEN1d3NPZmhMZ1BraHNSby9SeExSdz0ifSwiQzIiOnsiQVVUSF9BQkVfQVRUUjEiOiJJeEdSQURQZ0NzVjh0c0Z1cmFrKzRENUVPamxqV3UxeTNCOUprbnh5cmoxRkZ2UG9FZ2RIUnluUGxSRm1OTlk0ZWM2K09DV3g2OEdTaTQ5UmQrZGdtMzMwSFJYNlZqNHczcDJZWWkxR0kvV052a0pnYUJidkVxZmFKa0NoT20yRGdSM1pwTmZpUFVKNGdibTJVY2daNjUrbWdoeGUyT2l0QytMRXdyclNRNGM9IiwiU0EiOiJSZFRMS3FpbHdNdC9FYW1tRGsvRzdNZnhkMmU3QjJITVZiQWxvSUNlaDlVazE0T0N2L0pxaE9vUlM5SjUxYzg3MXRhSXFDVzkzbnZkYUNOQ3MybjBkSGRWYjhobFlBQmFmVTZDZElSK1RzTjVpU3dLQ0RCL0paWU1WWnhJZWlMNi9TeFJmcmtwOW5tdXRpajJYSUM0TmpYZktmWGpSanhQcU5CcHhGS1ZxaFE9In0sIkMzIjp7IkFVVEhfQUJFX0FUVFIxIjoiVjBHVUd6c041UzJMQ0ZGc1pTNmtnbTh0NC9nN29yQjArbHVHTS9zcnIvN1hTV1p4K1FHSy9kSGhVdzVmSWtpbENGVUpCSFh0dVk5b3ZmY0N0TkFaV1ZZaC9FeEI4VXZKUHg2NGZmMEUyWnVGc2Y1bW0xSERvU1R2d1ZDRzEzVWZaYVZ0TDdYUmY1cFpCeFh3TXhZL29oUGpsTDhVZmxlSFNiTnV5T2E3aDdVPSIsIlNBIjoiY1BQNmljZUphMUhtOUhnVE4zdFZHb3dKNmtuOVZNUzZtMlcxdFRSSlJ6NklqNVd4cGVwRnZCLysvS2hVWlorcVdFNGE5TzMzWHNYeXNRWGJadE9lMjVPYlR2bHNzQkJpRHBOWnhqSE9LS0ZldXFhTVRSTHZwZ2FESE1nSjhPdnF0NHlhVFN5ckZmTTI2bjV5YzRnMEt5QllWWU50VnJJU3I3dVRSUVFBYUVFPSJ9LCJTeXNEZWNyeXB0ZWQiOiJCK2MxZC9OV05qMTcrL09SZFpYdDE1ZUhHNUVEY2I5RGtMKytRL1BncHNsc3NlMWUvNGNCckttK1c0c3U4VEpNemVXaXJlSHEwOXNxRjNTM0NZZ1BnR1ZGNzBYcCt1NGRPaWdjeGxoMVljRDV5Mk11aG4wZmNOVnB3cGdaaVBBb2xGd0RNZkRVOUZKWnBoTzg3WE0xd1NPRFAxd0pGY21Ib0oraXBrbjI0b2c9IiwiRW5jcnlwdGVkTWVzc2FnZSI6InhRMDJTOXF3N3NiNGJlblk1NloxNWtlR2pWc2NnaUtvT3JHZ01MMjQ4ckk9IiwiQ2lwaGVySVYiOiI2R0haRWcxTW04dTAybzAySk1VVm5nPT0iLCJQb2xpY3kiOiJhdXRoX2FiZV9hdHRyMSBvciBjbW1uX2FiZV9hdHRyMiBhbmQgU0EifQ==",
    },
  "wrap_info": null,
  "warnings": null,
  "auth": null,
}
```

</details>

<br>

#### Decryption Mechanism

First, you should login with the Entity that the System Decrypted ciphertext was correlated with. In this example, we will login with _client1_. _client1_ has a key for both _auth_abe_attr1_ and _cmmn_abe_attr2_. Our policy is fulfilled if at least one of these ABE attributes are available to the client.

<details>
  <summary>HTTP ABE Decryption Mechanism Post request example</summary>

```
curl --location --request POST 'https://localhost:8200/v1/abe/decrypt/client1' \
--header 'X-Vault-Token: s.kIZgTkazQEtVMM8w2aBI49NI' \
--header 'Content-Type: application/json' \
--data-raw '{
    "cryptogram": "eyJDMCI6IlpaUC9aekpvNTRhSGQwTFg4T05ZT3BBeFBkQW56dm9lN0RRY3JaWmZEZUEwTnZSL09KbStHcHBFUkl1bjVMbjQ3VkRac0NwUm1VSE9ETldHeVZFcGlsWnNiOXAvWXlPNW1ROWQyVnlOVXNjVk9rTUFpMXVCLzRsMVBldkdFKy9SUlFvaDRQUzhCcXFVS0Y2bHpnVVNKWG5EdldxNk4weE9PcmtnNitVUEtHND0iLCJDMSI6eyJBVVRIX0FCRV9BVFRSMSI6Im1paHM2dkgyNmNXeWFYVU1DUDVjZ3k1WmJOU2l5OWFRd0pRY3RpRTVMb1BmYTY3ZmdxQVQ1clp5elhrcmVmZXlkZ0lxUE8zNE5yWWlGUHZzYXVZZG9WbXEzNVRPZUIrTDBpUHJBL3hZc25MbTlRT2QzYnhQalNwQUZFQ051K1ptdldDUlNWR2NYTmQ5MXFCZlhEUldZVXBOWmxWZ0tqYTFrOTkwTTcreDNqMD0iLCJTQSI6ImJTWmxQdDVINkxpanRIalc3YmR6amd0NzI4cDlpbkJTOTNlbmRlSDhEOG0zZVAwOUFHQlJtYWJkZ3dnUFhMOXN6anJtakx3T0ZpZjBsVUp3VFMyNE1od0JmKzhqUXlFREViakxjeVNsZnBKSEE5Yzdld2pycldWZ1hRV0lSdlZGOE81SkhhRU4yd0ViakRDK0Jzb01obEN1d3NPZmhMZ1BraHNSby9SeExSdz0ifSwiQzIiOnsiQVVUSF9BQkVfQVRUUjEiOiJJeEdSQURQZ0NzVjh0c0Z1cmFrKzRENUVPamxqV3UxeTNCOUprbnh5cmoxRkZ2UG9FZ2RIUnluUGxSRm1OTlk0ZWM2K09DV3g2OEdTaTQ5UmQrZGdtMzMwSFJYNlZqNHczcDJZWWkxR0kvV052a0pnYUJidkVxZmFKa0NoT20yRGdSM1pwTmZpUFVKNGdibTJVY2daNjUrbWdoeGUyT2l0QytMRXdyclNRNGM9IiwiU0EiOiJSZFRMS3FpbHdNdC9FYW1tRGsvRzdNZnhkMmU3QjJITVZiQWxvSUNlaDlVazE0T0N2L0pxaE9vUlM5SjUxYzg3MXRhSXFDVzkzbnZkYUNOQ3MybjBkSGRWYjhobFlBQmFmVTZDZElSK1RzTjVpU3dLQ0RCL0paWU1WWnhJZWlMNi9TeFJmcmtwOW5tdXRpajJYSUM0TmpYZktmWGpSanhQcU5CcHhGS1ZxaFE9In0sIkMzIjp7IkFVVEhfQUJFX0FUVFIxIjoiVjBHVUd6c041UzJMQ0ZGc1pTNmtnbTh0NC9nN29yQjArbHVHTS9zcnIvN1hTV1p4K1FHSy9kSGhVdzVmSWtpbENGVUpCSFh0dVk5b3ZmY0N0TkFaV1ZZaC9FeEI4VXZKUHg2NGZmMEUyWnVGc2Y1bW0xSERvU1R2d1ZDRzEzVWZaYVZ0TDdYUmY1cFpCeFh3TXhZL29oUGpsTDhVZmxlSFNiTnV5T2E3aDdVPSIsIlNBIjoiY1BQNmljZUphMUhtOUhnVE4zdFZHb3dKNmtuOVZNUzZtMlcxdFRSSlJ6NklqNVd4cGVwRnZCLysvS2hVWlorcVdFNGE5TzMzWHNYeXNRWGJadE9lMjVPYlR2bHNzQkJpRHBOWnhqSE9LS0ZldXFhTVRSTHZwZ2FESE1nSjhPdnF0NHlhVFN5ckZmTTI2bjV5YzRnMEt5QllWWU50VnJJU3I3dVRSUVFBYUVFPSJ9LCJTeXNEZWNyeXB0ZWQiOiJCK2MxZC9OV05qMTcrL09SZFpYdDE1ZUhHNUVEY2I5RGtMKytRL1BncHNsc3NlMWUvNGNCckttK1c0c3U4VEpNemVXaXJlSHEwOXNxRjNTM0NZZ1BnR1ZGNzBYcCt1NGRPaWdjeGxoMVljRDV5Mk11aG4wZmNOVnB3cGdaaVBBb2xGd0RNZkRVOUZKWnBoTzg3WE0xd1NPRFAxd0pGY21Ib0oraXBrbjI0b2c9IiwiRW5jcnlwdGVkTWVzc2FnZSI6InhRMDJTOXF3N3NiNGJlblk1NloxNWtlR2pWc2NnaUtvT3JHZ01MMjQ4ckk9IiwiQ2lwaGVySVYiOiI2R0haRWcxTW04dTAybzAySk1VVm5nPT0iLCJQb2xpY3kiOiJhdXRoX2FiZV9hdHRyMSBvciBjbW1uX2FiZV9hdHRyMiBhbmQgU0EifQ==",
    "sub_policy": "auth_abe_attr1 or cmmn_abe_attr2"
}'
```

</details>

<details>
  <summary>Click to see an example of a valid response</summary>

```yaml
{
  "request_id": "066c1b6f-5ae4-e06a-a204-4a2578b3b6bd",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": { "decrypted_data": "Lorem ipsum dolor sit amet." },
  "wrap_info": null,
  "warnings": null,
  "auth": null,
}
```

</details>

<br>

# Postman Collection

You may use this [Postman](https://www.postman.com) Collection in order to easily test the _Vault Secrets ABE_ plugin.

<details>
  <summary>Click to view the available Postman Collection</summary>

```yaml
{
  "info":
    {
      "_postman_id": "c9902430-92ce-4cfe-9bce-9c82975ad986",
      "name": "Vault",
      "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
      "_exporter_id": "5500457",
    },
  "item":
    [
      {
        "name": "Encrypt",
        "request":
          {
            "auth":
              {
                "type": "apikey",
                "apikey":
                  [
                    {
                      "key": "key",
                      "value": "X-Vault-Token",
                      "type": "string",
                    },
                    {
                      "key": "value",
                      "value": "{{VAULT_TOKEN}}",
                      "type": "string",
                    },
                  ],
              },
            "method": "POST",
            "header": [],
            "body":
              {
                "mode": "raw",
                "raw": "{\n    \"message\": \"Message to encrypt\",\n    \"policy\": \"Policy to impose - e.g. attr1 or attr2 and SA\"\n}",
                "options": { "raw": { "language": "json" } },
              },
            "url":
              {
                "raw": "{{VAULT_ADDR}}/v1/{{ABE_PLUGIN_PATH}}/encrypt",
                "host": ["{{VAULT_ADDR}}"],
                "path": ["v1", "{{ABE_PLUGIN_PATH}}", "encrypt"],
              },
          },
        "response": [],
      },
      {
        "name": "Add attributes",
        "request":
          {
            "auth":
              {
                "type": "apikey",
                "apikey":
                  [
                    {
                      "key": "key",
                      "value": "X-Vault-Token",
                      "type": "string",
                    },
                    {
                      "key": "value",
                      "value": "{{VAULT_TOKEN}}",
                      "type": "string",
                    },
                  ],
              },
            "method": "POST",
            "header": [],
            "body":
              {
                "mode": "raw",
                "raw": "{\n    \"authorityAttributes\": [],\n    \"commonAttributes\": []\n}",
                "options": { "raw": { "language": "json" } },
              },
            "url":
              {
                "raw": "{{VAULT_ADDR}}/v1/{{ABE_PLUGIN_PATH}}/{{ADMIN_ENTITY}}/addattributes",
                "host": ["{{VAULT_ADDR}}"],
                "path":
                  [
                    "v1",
                    "{{ABE_PLUGIN_PATH}}",
                    "{{ADMIN_ENTITY}}",
                    "addattributes",
                  ],
              },
          },
        "response": [],
      },
      {
        "name": "Key generation",
        "request":
          {
            "auth":
              {
                "type": "apikey",
                "apikey":
                  [
                    {
                      "key": "key",
                      "value": "X-Vault-Token",
                      "type": "string",
                    },
                    {
                      "key": "value",
                      "value": "{{VAULT_TOKEN}}",
                      "type": "string",
                    },
                  ],
              },
            "method": "POST",
            "header": [],
            "body":
              {
                "mode": "raw",
                "raw": "{\n    \"authorityAttributes\": [],\n    \"commonAttributes\": []\n}",
                "options": { "raw": { "language": "json" } },
              },
            "url":
              {
                "raw": "{{VAULT_ADDR}}/v1/{{ABE_PLUGIN_PATH}}/keygen/{{ADMIN_ENTITY}}/{{CLIENT_ENTITY}}",
                "host": ["{{VAULT_ADDR}}"],
                "path":
                  [
                    "v1",
                    "{{ABE_PLUGIN_PATH}}",
                    "keygen",
                    "{{ADMIN_ENTITY}}",
                    "{{CLIENT_ENTITY}}",
                  ],
              },
          },
        "response": [],
      },
      {
        "name": "System Key Generation",
        "request":
          {
            "auth":
              {
                "type": "apikey",
                "apikey":
                  [
                    {
                      "key": "key",
                      "value": "X-Vault-Token",
                      "type": "string",
                    },
                    {
                      "key": "value",
                      "value": "{{VAULT_TOKEN}}",
                      "type": "string",
                    },
                  ],
              },
            "method": "POST",
            "header": [],
            "body": { "mode": "raw", "raw": "" },
            "url":
              {
                "raw": "{{VAULT_ADDR}}/v1/{{ABE_PLUGIN_PATH}}/syskeygen/SA/{{ADMIN_ENTITY}}",
                "host": ["{{VAULT_ADDR}}"],
                "path":
                  [
                    "v1",
                    "{{ABE_PLUGIN_PATH}}",
                    "syskeygen",
                    "SA",
                    "{{ADMIN_ENTITY}}",
                  ],
              },
          },
        "response": [],
      },
      {
        "name": "System Decryption",
        "request":
          {
            "auth":
              {
                "type": "apikey",
                "apikey":
                  [
                    {
                      "key": "key",
                      "value": "X-Vault-Token",
                      "type": "string",
                    },
                    {
                      "key": "value",
                      "value": "{{VAULT_TOKEN}}",
                      "type": "string",
                    },
                  ],
              },
            "method": "POST",
            "header": [],
            "body":
              {
                "mode": "raw",
                "raw": "{\n    \"cryptogram\":\"\",\n    \"sub_policy\": \"SA\"\n    }",
                "options": { "raw": { "language": "json" } },
              },
            "url":
              {
                "raw": "{{VAULT_ADDR}}/v1/{{ABE_PLUGIN_PATH}}/sysdecrypt/{{ADMIN_ENTITY}}/{{CLIENT_ENTITY}}",
                "host": ["{{VAULT_ADDR}}"],
                "path":
                  [
                    "v1",
                    "{{ABE_PLUGIN_PATH}}",
                    "sysdecrypt",
                    "{{ADMIN_ENTITY}}",
                    "{{CLIENT_ENTITY}}",
                  ],
              },
          },
        "response": [],
      },
      {
        "name": "Decryption",
        "request":
          {
            "auth":
              {
                "type": "apikey",
                "apikey":
                  [
                    {
                      "key": "key",
                      "value": "X-Vault-Token",
                      "type": "string",
                    },
                    {
                      "key": "value",
                      "value": "{{VAULT_TOKEN}}",
                      "type": "string",
                    },
                  ],
              },
            "method": "POST",
            "header": [],
            "body":
              {
                "mode": "raw",
                "raw": "{\n    \"cryptogram\": \"The Encrypted or System-Decrypted Ciphertext\",\n    \"sub_policy\": \"Policy to impose - e.g. attr1 or attr2\"\n}",
                "options": { "raw": { "language": "json" } },
              },
            "url":
              {
                "raw": "{{VAULT_ADDR}}/v1/{{ABE_PLUGIN_PATH}}/decrypt/{{CLIENT_ENTITY}}",
                "host": ["{{VAULT_ADDR}}"],
                "path":
                  ["v1", "{{ABE_PLUGIN_PATH}}", "decrypt", "{{CLIENT_ENTITY}}"],
              },
          },
        "response": [],
      },
      {
        "name": "Login Endpoint",
        "request":
          {
            "auth": { "type": "noauth" },
            "method": "POST",
            "header": [],
            "body":
              {
                "mode": "raw",
                "raw": "{\n    \"password\": \"MY_CLIENTS_PASSWORD\"\n}",
                "options": { "raw": { "language": "json" } },
              },
            "url":
              {
                "raw": "{{VAULT_ADDR}}/v1/auth/userpass/login/MY_CLIENT",
                "host": ["{{VAULT_ADDR}}"],
                "path": ["v1", "auth", "userpass", "login", "MY_CLIENT"],
              },
          },
        "response": [],
      },
    ],
}
```

</details>

<br>

Save the above configuration to a JSON file (e.g. `postman_vault_collection.json`) and import it to Postman by navigating to: `File => Import... => Upload Files`

You should also create a Postman `Environment`, to define the variables used by the Postman Collection.

|    Variable     |      Description       |
| :-------------: | :--------------------: |
|   VAULT_ADDR    | https://localhost:8200 |
|   VAULT_TOKEN   |    A Vault _token_     |
| ABE_PLUGIN_PATH |    _abe_ (default)     |
|  ADMIN_ENTITY   |   An _admin_ entity    |
|  CLIENT_ENTITY  |   A _client_ entity    |
