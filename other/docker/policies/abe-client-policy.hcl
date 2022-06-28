# Deny access to sensitive data that is below the "AUTHORITY_ATTRIBUTES/" path - Accessible is only the "public" data
path "abe/AUTHORITY_ATTRIBUTES/+/+/PRIVATE_DATA" {
    capabilities = ["deny"]
}

# Deny access to sensitive data that is below the "COMMON_ATTRIBUTES/" path - Accessible is only the "public" data
path "abe/COMMON_ATTRIBUTES/+/PRIVATE_DATA" {
    capabilities = ["deny"]
}

# Deny access to sensitive data that is below the "SYSTEM_ATTRIBUTES/" path - Accessible is only the "public" data
path "abe/SYSTEM_ATTRIBUTES/+/PRIVATE_DATA" {
    capabilities = ["deny"]
}

# Deny a token to add new attributes
path "abe/+/addattributes" {
    capabilities = ["deny"]
}

# Deny a token to generate new keys for an object (Client Entity)
path "abe/keygen/+/*" {
    capabilities = ["deny"]
}

# Deny a token to access the subjects (Client Entities) of the system
path "abe/SUBJECTS/GIDS/+" {
    capabilities = ["deny"]
}

# Deny a token to generate SYSTEM ATTRIBUTES
path "abe/syskeygen/+/*" {
    capabilities = ["deny"]
}

# Allow a token to access the encryption mechanism
path "abe/encrypt" {
    capabilities = ["create", "update"]
}

# Deny a token to access the sys-decryption mechanism
path "abe/sysdecrypt" {
    capabilities = ["deny"]
}

# Allow a token to access the decryption mechanism
path "abe/decrypt/{{identity.entity.name}}" {
    capabilities = ["create", "update"]
}