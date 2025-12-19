# ========================================
# Cosmos DB Module - Outputs
# ========================================

output "cosmosdb_account_id" {
  description = "The ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.id
}

output "cosmosdb_account_name" {
  description = "The name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmosdb_endpoint" {
  description = "The endpoint for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmosdb_primary_connection_string" {
  description = "The primary MongoDB connection string"
  value       = azurerm_cosmosdb_account.main.primary_mongodb_connection_string
  sensitive   = true
}

output "cosmosdb_primary_key" {
  description = "The primary key"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "cosmosdb_secondary_key" {
  description = "The secondary key"
  value       = azurerm_cosmosdb_account.main.secondary_key
  sensitive   = true
}

output "database_name" {
  description = "The name of the MongoDB database"
  value       = azurerm_cosmosdb_mongo_database.main.name
}

output "collection_name" {
  description = "The name of the MongoDB collection"
  value       = azurerm_cosmosdb_mongo_collection.main.name
}

output "mongodb_connection_string" {
  description = "MongoDB connection string"
  value       = "mongodb://${azurerm_cosmosdb_account.main.name}:${azurerm_cosmosdb_account.main.primary_key}@${azurerm_cosmosdb_account.main.name}.mongo.cosmos.azure.com:10255/${azurerm_cosmosdb_mongo_database.main.name}?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000"
  sensitive   = true
}
