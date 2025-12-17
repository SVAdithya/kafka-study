# Cosmos DB Module

This module creates an Azure Cosmos DB account with MongoDB API support.

## Features

- Cosmos DB with MongoDB API
- Serverless configuration
- Configurable consistency levels
- Custom indexing support
- MongoDB database and collection creation

## Usage

```hcl
module "cosmos" {
  source = "./modules/cosmos"

  cosmosdb_account_name = "dev-cosmos"
  location             = "eastus"
  resource_group_name  = "learn-all"
  database_name        = "dev-db"
  collection_name      = "messages"
  
  enable_free_tier = true
  consistency_level = "Session"
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cosmosdb_account_name | Cosmos DB account name | string | - | yes |
| location | Azure region | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| database_name | MongoDB database name | string | - | yes |
| collection_name | Collection name | string | "messages" | no |
| enable_free_tier | Enable free tier | bool | false | no |
| consistency_level | Consistency level | string | "Session" | no |

## Outputs

| Name | Description |
|------|-------------|
| cosmosdb_endpoint | Cosmos DB endpoint URL |
| mongodb_connection_string | MongoDB connection string (sensitive) |
| database_name | Database name |
