# ========================================
# Data Sources
# ========================================

# Get current Azure subscription details
data "azurerm_subscription" "current" {}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Random suffix for globally unique names
resource "random_integer" "suffix" {
  min = 1000000000
  max = 9999999999

  keepers = {
    resource_group = var.resource_group_name
  }
}
