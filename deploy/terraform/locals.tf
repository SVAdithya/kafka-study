# ========================================
# Local Values
# ========================================

locals {
  # Location configuration
  location = var.location != "" ? var.location : data.azurerm_resource_group.main.location
  
  # Naming convention: {environment}-{service}
  resource_prefix = var.environment
  
  # Resource names following naming convention
  cosmosdb_account_name = var.cosmosdb_account_name != "" ? var.cosmosdb_account_name : "${local.resource_prefix}-cosmos"
  servicebus_namespace  = var.servicebus_namespace_name != "" ? var.servicebus_namespace_name : "${local.resource_prefix}-sb"
  database_name        = var.database_name != "" ? var.database_name : "${local.resource_prefix}-db"
  keyvault_name        = var.keyvault_name != "" ? var.keyvault_name : "${local.resource_prefix}-kv"
  appconfig_name       = var.appconfig_name != "" ? var.appconfig_name : "${local.resource_prefix}-appconfig"
  
  # Common tags applied to all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
      CostCenter  = var.cost_center
      Workspace   = terraform.workspace
      DeployedAt  = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())
    }
  )
  
  # Service Bus topic naming with env prefix
  servicebus_topics_formatted = {
    for key, value in var.servicebus_topics : "${var.environment}-${key}" => value
  }
  
  # Service Bus subscription naming
  servicebus_subscriptions_formatted = {
    for key, value in var.servicebus_subscriptions : "${var.environment}-${key}" => merge(
      value,
      {
        topic_name = "${var.environment}-${value.topic_name}"
      }
    )
  }
  
  # Service Bus queue naming with env prefix
  servicebus_queues_formatted = {
    for key, value in var.servicebus_queues : "${var.environment}-${key}" => value
  }
}
