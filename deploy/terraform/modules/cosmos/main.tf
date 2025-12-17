# ========================================
# Cosmos DB Module - Main Resources
# ========================================

# Cosmos DB account with MongoDB API
resource "azurerm_cosmosdb_account" "main" {
  name                = var.cosmosdb_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = var.enable_automatic_failover
  enable_free_tier          = var.enable_free_tier

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.consistency_level == "BoundedStaleness" ? 300 : null
    max_staleness_prefix    = var.consistency_level == "BoundedStaleness" ? 100000 : null
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = var.tags
}

# MongoDB database
resource "azurerm_cosmosdb_mongo_database" "main" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
}

# MongoDB collection
resource "azurerm_cosmosdb_mongo_collection" "main" {
  name                = var.collection_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_mongo_database.main.name

  default_ttl_seconds = var.default_ttl_seconds
  shard_key          = var.shard_key

  index {
    keys   = ["_id"]
    unique = true
  }

  dynamic "index" {
    for_each = var.additional_indexes
    content {
      keys   = index.value.keys
      unique = lookup(index.value, "unique", false)
    }
  }
}
