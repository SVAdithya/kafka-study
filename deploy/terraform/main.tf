# ========================================
# Main Terraform Configuration
# ========================================
# 
# This file orchestrates all infrastructure modules.
# Resources are organized in separate module folders:
# - modules/cosmos: Cosmos DB with MongoDB API
# - modules/servicebus: Azure Service Bus (Kafka alternative)
# - modules/secrets: Azure Key Vault for secrets
# - modules/appconfig: Azure App Configuration
#
# Environment-specific configurations:
# - environments/{environment}.tfvars
#
# Example deployment:
#   terraform init
#   terraform plan -var-file="environments/dev.tfvars"
#   terraform apply -var-file="environments/dev.tfvars"
# ========================================

# ========================================
# Cosmos DB Module
# ========================================
module "cosmos" {
  source = "./modules/cosmos"

  cosmosdb_account_name     = local.cosmosdb_account_name
  location                 = local.location
  resource_group_name      = data.azurerm_resource_group.main.name
  database_name            = local.database_name
  collection_name          = var.collection_name
  enable_automatic_failover = var.enable_automatic_failover
  enable_free_tier         = var.enable_free_tier
  consistency_level        = var.consistency_level
  default_ttl_seconds      = var.default_ttl_seconds
  shard_key               = var.shard_key
  additional_indexes       = var.additional_indexes

  tags = local.common_tags
}

# ========================================
# Service Bus Module
# ========================================
module "servicebus" {
  source = "./modules/servicebus"

  namespace_name      = local.servicebus_namespace
  location           = local.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                = var.servicebus_sku
  capacity           = var.servicebus_capacity

  topics        = local.servicebus_topics_formatted
  subscriptions = local.servicebus_subscriptions_formatted
  queues        = local.servicebus_queues_formatted

  tags = local.common_tags
}

# ========================================
# Key Vault Module (Secrets Storage)
# ========================================
module "keyvault" {
  source = "./modules/secrets"

  keyvault_name       = local.keyvault_name
  location           = local.location
  resource_group_name = data.azurerm_resource_group.main.name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  admin_object_id    = data.azurerm_client_config.current.object_id

  sku_name                   = var.keyvault_sku
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled

  # Store all sensitive connection strings and keys in Key Vault
  secrets = {
    # Cosmos DB secrets
    "cosmos-connection-string"       = module.cosmos.mongodb_connection_string
    "cosmos-endpoint"                = module.cosmos.cosmosdb_endpoint
    "cosmos-primary-key"             = module.cosmos.cosmosdb_primary_key
    "cosmos-secondary-key"           = module.cosmos.cosmosdb_secondary_key
    "cosmos-database-name"           = module.cosmos.database_name
    "cosmos-collection-name"         = module.cosmos.collection_name
    
    # Service Bus secrets
    "servicebus-connection-string"   = module.servicebus.primary_connection_string
    "servicebus-listen-connection"   = module.servicebus.listen_connection_string
    "servicebus-send-connection"     = module.servicebus.send_connection_string
    "servicebus-primary-key"         = module.servicebus.primary_key
    "servicebus-namespace"           = module.servicebus.namespace_name
    "servicebus-endpoint"            = module.servicebus.namespace_endpoint
  }

  tags = local.common_tags

  depends_on = [module.cosmos, module.servicebus]
}

# ========================================
# App Configuration Module
# ========================================
module "appconfig" {
  source = "./modules/appconfig"

  appconfig_name      = local.appconfig_name
  location           = local.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                = var.appconfig_sku

  # Store application configuration values
  config_values = {
    # Environment info
    "App:Environment"                = var.environment
    "App:Project"                    = var.project_name
    
    # Cosmos DB configuration (non-sensitive)
    "CosmosDB:AccountName"           = module.cosmos.cosmosdb_account_name
    "CosmosDB:Endpoint"              = module.cosmos.cosmosdb_endpoint
    "CosmosDB:DatabaseName"          = module.cosmos.database_name
    "CosmosDB:CollectionName"        = module.cosmos.collection_name
    
    # Service Bus configuration (non-sensitive)
    "ServiceBus:Namespace"           = module.servicebus.namespace_name
    "ServiceBus:Endpoint"            = module.servicebus.namespace_endpoint
    "ServiceBus:TopicPrefix"         = var.environment
    
    # Key Vault reference
    "KeyVault:Name"                  = module.keyvault.keyvault_name
    "KeyVault:Uri"                   = module.keyvault.keyvault_uri
  }

  # Reference sensitive values from Key Vault
  keyvault_references = {
    "ConnectionStrings:CosmosDB"     = "${module.keyvault.keyvault_id}/secrets/cosmos-connection-string"
    "ConnectionStrings:ServiceBus"   = "${module.keyvault.keyvault_id}/secrets/servicebus-connection-string"
    "ConnectionStrings:ServiceBusListen" = "${module.keyvault.keyvault_id}/secrets/servicebus-listen-connection"
    "ConnectionStrings:ServiceBusSend" = "${module.keyvault.keyvault_id}/secrets/servicebus-send-connection"
  }

  tags = local.common_tags

  depends_on = [module.keyvault]
}
