# ========================================
# Data Sources
# ========================================

# Read the existing resource group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Get current Azure subscription details
data "azurerm_subscription" "current" {}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}
