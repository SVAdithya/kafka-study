# Key Vault (Secrets) Module

This module creates an Azure Key Vault for securely storing secrets, keys, and certificates.

## Features

- Azure Key Vault creation
- Access policies management
- Secret storage
- Network ACLs
- Soft delete and purge protection
- Integration with other modules

## Usage

```hcl
module "secrets" {
  source = "./modules/secrets"

  keyvault_name       = "dev-kv"
  location           = "eastus"
  resource_group_name = "learn-all"
  tenant_id          = data.azurerm_client_config.current.tenant_id
  admin_object_id    = data.azurerm_client_config.current.object_id
  
  secrets = {
    "cosmos-connection-string" = module.cosmos.mongodb_connection_string
    "servicebus-connection-string" = module.servicebus.primary_connection_string
  }
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| keyvault_name | Key Vault name | string | - | yes |
| location | Azure region | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| tenant_id | Azure tenant ID | string | - | yes |
| admin_object_id | Admin object ID | string | - | yes |
| secrets | Map of secrets | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| keyvault_uri | Key Vault URI |
| keyvault_name | Key Vault name |
| secret_ids | Map of secret IDs |

## Security Considerations

- Enable purge protection in production
- Use network ACLs to restrict access
- Use managed identities for application access
- Regularly rotate secrets
