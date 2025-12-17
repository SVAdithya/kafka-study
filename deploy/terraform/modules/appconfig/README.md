# App Configuration Module

This module creates an Azure App Configuration store for centralized configuration management.

## Features

- Azure App Configuration store creation
- Configuration key-value storage
- Key Vault reference support
- Integration with other Azure services
- Free and Standard SKU support

## Usage

```hcl
module "appconfig" {
  source = "./modules/appconfig"

  appconfig_name      = "dev-appconfig"
  location           = "eastus"
  resource_group_name = "learn-all"
  sku                = "free"
  
  config_values = {
    "Database:Name" = "mydb"
    "ServiceBus:TopicPrefix" = "tenant-dev"
  }
  
  keyvault_references = {
    "ConnectionStrings:CosmosDB" = "${keyvault_id}/secrets/cosmos-connection-string"
    "ConnectionStrings:ServiceBus" = "${keyvault_id}/secrets/servicebus-connection-string"
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
| appconfig_name | App Configuration name | string | - | yes |
| location | Azure region | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| sku | SKU (free or standard) | string | "free" | no |
| config_values | Configuration key-value pairs | map(string) | {} | no |
| keyvault_references | Key Vault secret references | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| appconfig_endpoint | App Configuration endpoint |
| appconfig_name | App Configuration name |
| appconfig_primary_read_key | Primary read connection string (sensitive) |

## App Configuration vs Key Vault

**Use App Configuration for:**
- Application settings
- Feature flags
- Non-sensitive configuration
- Configuration that changes frequently

**Use Key Vault for:**
- Secrets and passwords
- Connection strings
- API keys
- Certificates

**Best Practice:** Store secrets in Key Vault, reference them from App Configuration.
