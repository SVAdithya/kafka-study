# ========================================
# Common Configuration
# ========================================
# This file contains common provider configurations and default settings
# that are shared across the entire Terraform project.

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }

    # Uncomment to enable additional features
    # app_configuration {
    #   purge_soft_delete_on_destroy = true
    # }
  }
}

# ========================================
# Common Default Values
# ========================================
# These defaults are used across all environments unless overridden

locals {
  # Common defaults
  defaults = {
    location    = "southindia"
    cost_center = "engineering"
    project     = "kafka-study"

    # Service Bus defaults
    servicebus = {
      sku                          = "Standard"
      capacity                     = 1
      max_size_in_megabytes        = 1024
      max_delivery_count           = 10
      lock_duration                = "PT1M"
      dead_letter_on_expiration    = true
      requires_duplicate_detection = false
      support_ordering             = false
    }

    # Cosmos DB defaults
    cosmosdb = {
      consistency_level         = "Session"
      enable_free_tier          = false
      enable_automatic_failover = false
      default_ttl_seconds       = -1
      shard_key                 = "_id"
    }

    # Key Vault defaults
    keyvault = {
      sku                        = "standard"
      soft_delete_retention_days = 7
      purge_protection_enabled   = false
    }

    # App Configuration defaults
    appconfig = {
      sku = "free"
    }
  }
}
