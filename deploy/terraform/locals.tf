# ========================================
# Local Values
# ========================================

locals {
  # Location configuration
  location = var.location

  # Naming convention: {environment}-{service}
  resource_prefix = var.environment

  # Resource names following naming convention
  cosmosdb_account_name = var.cosmosdb_account_name != "" ? var.cosmosdb_account_name : "${local.resource_prefix}-cosmos-${random_integer.suffix.result}"
  eventhub_namespace    = var.eventhub_namespace_name != "" ? var.eventhub_namespace_name : "${local.resource_prefix}-eh-${random_integer.suffix.result}"
  database_name         = var.database_name != "" ? var.database_name : "${local.resource_prefix}-db"
  keyvault_name         = var.keyvault_name != "" ? var.keyvault_name : "${local.resource_prefix}-kv-${random_integer.suffix.result}"
  appconfig_name        = var.appconfig_name != "" ? var.appconfig_name : "${local.resource_prefix}-appconfig-${random_integer.suffix.result}"

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

  # Event Hub naming with env prefix
  eventhubs_formatted = {
    for key, value in var.event_hubs : "${var.environment}-${key}" => value
  }

  # Consumer group naming
  consumer_groups_formatted = {
    for key, value in var.consumer_groups : "${var.environment}-${key}" => merge(
      value,
      {
        eventhub_name = "${var.environment}-${value.eventhub_name}"
      }
    )
  }
}
