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
# Resource Group
# ========================================
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

# ========================================
# Cosmos DB Module
# ========================================
module "cosmos" {
  source = "./modules/cosmos"

  cosmosdb_account_name     = local.cosmosdb_account_name
  location                  = local.location
  resource_group_name       = azurerm_resource_group.main.name
  database_name             = local.database_name
  collection_name           = var.collection_name
  enable_automatic_failover = var.enable_automatic_failover
  enable_free_tier          = var.enable_free_tier
  consistency_level         = var.consistency_level
  default_ttl_seconds       = var.default_ttl_seconds
  shard_key                 = var.shard_key
  additional_indexes        = var.additional_indexes

  tags = local.common_tags
}

# ========================================
# Event Hub Module (Kafka-compatible streaming)
# ========================================
module "eventhub" {
  source = "./modules/eventhub"

  namespace_name      = local.eventhub_namespace
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.eventhub_sku
  capacity            = var.eventhub_capacity

  auto_inflate_enabled     = var.eventhub_auto_inflate_enabled
  maximum_throughput_units = var.eventhub_maximum_throughput_units

  event_hubs      = local.eventhubs_formatted
  consumer_groups = local.consumer_groups_formatted

  tags = local.common_tags
}

# ========================================
# Key Vault Module (Secrets Storage)
# ========================================
module "keyvault" {
  source = "./modules/secrets"

  keyvault_name       = local.keyvault_name
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  admin_object_id     = data.azurerm_client_config.current.object_id

  sku_name                   = var.keyvault_sku
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled

  # Store all sensitive connection strings and keys in Key Vault
  secrets = {
    # Cosmos DB secrets
    "cosmos-connection-string" = module.cosmos.mongodb_connection_string
    "cosmos-endpoint"          = module.cosmos.cosmosdb_endpoint
    "cosmos-primary-key"       = module.cosmos.cosmosdb_primary_key
    "cosmos-secondary-key"     = module.cosmos.cosmosdb_secondary_key
    "cosmos-database-name"     = module.cosmos.database_name
    "cosmos-collection-name"   = module.cosmos.collection_name

    # Event Hub secrets
    "eventhub-connection-string" = module.eventhub.primary_connection_string
    "eventhub-listen-connection" = module.eventhub.listen_connection_string
    "eventhub-send-connection"   = module.eventhub.send_connection_string
    "eventhub-primary-key"       = module.eventhub.primary_key
    "eventhub-namespace"         = module.eventhub.namespace_name
    "eventhub-endpoint"          = module.eventhub.namespace_endpoint
    "eventhub-kafka-endpoint"    = module.eventhub.kafka_endpoint
  }

  tags = local.common_tags

  depends_on = [module.cosmos, module.eventhub]
}

# ========================================
# App Configuration Module
# ========================================
module "appconfig" {
  source = "./modules/appconfig"

  appconfig_name      = local.appconfig_name
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.appconfig_sku

  # Store application configuration values
  config_values = {
    # Environment info
    "App:Environment" = var.environment
    "App:Project"     = var.project_name

    # Cosmos DB configuration (non-sensitive)
    "CosmosDB:AccountName"    = module.cosmos.cosmosdb_account_name
    "CosmosDB:Endpoint"       = module.cosmos.cosmosdb_endpoint
    "CosmosDB:DatabaseName"   = module.cosmos.database_name
    "CosmosDB:CollectionName" = module.cosmos.collection_name

    # Event Hub configuration (non-sensitive)
    "EventHub:Namespace"     = module.eventhub.namespace_name
    "EventHub:Endpoint"      = module.eventhub.namespace_endpoint
    "EventHub:KafkaEndpoint" = module.eventhub.kafka_endpoint
    "EventHub:TopicPrefix"   = var.environment

    # Key Vault reference
    "KeyVault:Name" = module.keyvault.keyvault_name
    "KeyVault:Uri"  = module.keyvault.keyvault_uri
  }

  # Reference sensitive values from Key Vault
  keyvault_references = {
    "ConnectionStrings:CosmosDB"        = "${module.keyvault.keyvault_id}/secrets/cosmos-connection-string"
    "ConnectionStrings:EventHub"        = "${module.keyvault.keyvault_id}/secrets/eventhub-connection-string"
    "ConnectionStrings:EventHubListen"  = "${module.keyvault.keyvault_id}/secrets/eventhub-listen-connection"
    "ConnectionStrings:EventHubSend"    = "${module.keyvault.keyvault_id}/secrets/eventhub-send-connection"
    "ConnectionStrings:Kafka"           = "${module.keyvault.keyvault_id}/secrets/eventhub-kafka-endpoint"
  }

  tags = local.common_tags

  depends_on = [module.keyvault]
}
