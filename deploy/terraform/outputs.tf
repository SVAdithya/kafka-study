# ========================================
# Root Module Outputs
# ========================================

# Resource Group Outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.main.location
}

# ========================================
# Cosmos DB Outputs
# ========================================

output "cosmosdb_endpoint" {
  description = "The endpoint for the Cosmos DB account"
  value       = module.cosmos.cosmosdb_endpoint
}

output "cosmosdb_account_name" {
  description = "The name of the Cosmos DB account"
  value       = module.cosmos.cosmosdb_account_name
}

output "cosmosdb_database_name" {
  description = "The name of the MongoDB database"
  value       = module.cosmos.database_name
}

output "cosmosdb_collection_name" {
  description = "The name of the MongoDB collection"
  value       = module.cosmos.collection_name
}

output "cosmosdb_connection_string" {
  description = "MongoDB connection string (sensitive - stored in Key Vault)"
  value       = module.cosmos.mongodb_connection_string
  sensitive   = true
}

# ========================================
# Event Hub Outputs (Kafka-compatible)
# ========================================

output "eventhub_namespace_name" {
  description = "The name of the Event Hub namespace"
  value       = module.eventhub.namespace_name
}

output "eventhub_endpoint" {
  description = "The endpoint URL for the Event Hub namespace"
  value       = module.eventhub.namespace_endpoint
}

output "eventhub_kafka_endpoint" {
  description = "The Kafka-compatible endpoint for Event Hub"
  value       = module.eventhub.kafka_endpoint
}

output "eventhub_connection_string" {
  description = "Event Hub primary connection string (sensitive - stored in Key Vault)"
  value       = module.eventhub.primary_connection_string
  sensitive   = true
}

output "eventhub_names" {
  description = "List of created Event Hub names"
  value       = module.eventhub.eventhub_names
}

output "consumer_group_names" {
  description = "List of created consumer group names"
  value       = module.eventhub.consumer_group_names
}

# ========================================
# Key Vault Outputs
# ========================================

output "keyvault_name" {
  description = "The name of the Key Vault"
  value       = module.keyvault.keyvault_name
}

output "keyvault_uri" {
  description = "The URI of the Key Vault"
  value       = module.keyvault.keyvault_uri
}

output "keyvault_id" {
  description = "The ID of the Key Vault"
  value       = module.keyvault.keyvault_id
}

# ========================================
# App Configuration Outputs
# ========================================

output "appconfig_name" {
  description = "The name of the App Configuration"
  value       = module.appconfig.appconfig_name
}

output "appconfig_endpoint" {
  description = "The endpoint of the App Configuration"
  value       = module.appconfig.appconfig_endpoint
}

output "appconfig_connection_string" {
  description = "App Configuration primary read connection string (sensitive)"
  value       = module.appconfig.appconfig_primary_read_key
  sensitive   = true
}

# ========================================
# Deployment Summary
# ========================================

output "deployment_summary" {
  description = "Summary of all deployed resources"
  value = {
    environment    = var.environment
    resource_group = azurerm_resource_group.main.name
    location       = local.location

    # Resources
    cosmos_db = module.cosmos.cosmosdb_account_name
    eventhub  = module.eventhub.namespace_name
    keyvault  = module.keyvault.keyvault_name
    appconfig = module.appconfig.appconfig_name

    # Counts
    eventhubs_count       = length(module.eventhub.eventhub_names)
    consumer_groups_count = length(module.eventhub.consumer_group_names)
  }
}

# ========================================
# Application Configuration Guide
# ========================================

output "application_config_guide" {
  description = "Guide for application configuration"
  value = {
    message = "All connection strings are stored in Key Vault and App Configuration"

    keyvault_secrets = [
      "cosmos-connection-string",
      "cosmos-primary-key",
      "eventhub-connection-string",
      "eventhub-listen-connection",
      "eventhub-send-connection",
      "eventhub-kafka-endpoint"
    ]

    appconfig_keys = [
      "ConnectionStrings:CosmosDB (Key Vault Reference)",
      "ConnectionStrings:EventHub (Key Vault Reference)",
      "ConnectionStrings:Kafka (Key Vault Reference)",
      "CosmosDB:Endpoint",
      "CosmosDB:DatabaseName",
      "EventHub:Namespace",
      "EventHub:Endpoint",
      "EventHub:KafkaEndpoint"
    ]

    access_methods = {
      cli_keyvault     = "az keyvault secret show --vault-name ${module.keyvault.keyvault_name} --name cosmos-connection-string"
      cli_appconfig    = "az appconfig kv show --name ${module.appconfig.appconfig_name} --key CosmosDB:Endpoint"
      terraform_output = "terraform output -raw cosmosdb_connection_string"
    }
  }
}
