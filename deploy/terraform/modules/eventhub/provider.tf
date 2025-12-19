# ========================================
# Provider Requirements for Event Hub Module
# ========================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Provider configuration (for standalone module testing)
provider "azurerm" {
  features {}
}
