# Deny access to sensitive data that is below the "AUTHORITY_ATTRIBUTES/" path
path "abe/AUTHORITY_ATTRIBUTES/+/+/PRIVATE_DATA" {
    capabilities = ["deny"]
}

# Allow access to public data that is below the "AUTHORITY_ATTRIBUTES/" path
path "abe/AUTHORITY_ATTRIBUTES/+/+/PUBLIC_DATA" {
    capabilities = ["read"]
}

# Deny access to sensitive data that is below the "COMMON_ATTRIBUTES/" path
path "abe/COMMON_ATTRIBUTES/+/PRIVATE_DATA" {
    capabilities = ["deny"]
}

# Allow access to public data that is below the "COMMON_ATTRIBUTES/" path
path "abe/COMMON_ATTRIBUTES/+/PUBLIC_DATA" {
    capabilities = ["read"]
}

# Deny access to sensitive data that is below the "SYSTEM_ATTRIBUTES/" path
path "abe/SYSTEM_ATTRIBUTES/+/PRIVATE_DATA" {
    capabilities = ["deny"]
}

# Allow access to public data that is below the "SYSTEM_ATTRIBUTES/" path
path "abe/SYSTEM_ATTRIBUTES/+/PUBLIC_DATA" {
    capabilities = ["read"]
}

# Allow a token to add new attributes for the Admin Entity that it was created for
path "abe/{{identity.entity.name}}/addattributes" {
    capabilities = ["create", "update"]
}

# Allow a token to generate new keys for an object (Client Entity)
path "abe/keygen/{{identity.entity.name}}/*" {
    capabilities = ["create", "update"]
}

# Allow a token to access the subjects (Client Entities) of the system - LIST ONLY
path "abe/SUBJECTS/GIDS/+" {
    capabilities = ["list"]
}

# Allow a token to generate SYSTEM ATTRIBUTES for itself
path "abe/syskeygen/+/{{identity.entity.name}}" {
    capabilities = ["create", "update"]
}

# Allow a token to access the encryption mechanism
path "abe/encrypt" {
    capabilities = ["create", "update"]
}

# Allow a token to access the sys-decryption mechanism
path "abe/sysdecrypt/{{identity.entity.name}}/*" {
    capabilities = ["create", "update"]
}

# Allow a token to access the decryption mechanism
path "abe/decrypt/{{identity.entity.name}}" {
    capabilities = ["create", "update"]
}