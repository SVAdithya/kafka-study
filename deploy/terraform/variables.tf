# ========================================
# Environment Configuration
# ========================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod", "uat", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, uat, test"
  }
}

variable "project_name" {
  description = "Project name for resource grouping and tagging"
  type        = string
  default     = "kafka-study"
}

variable "cost_center" {
  description = "Cost center for billing and chargeback"
  type        = string
  default     = "engineering"
}

# ========================================
# Azure Configuration
# ========================================

variable "resource_group_name" {
  description = "The name of the resource group where resources will be created (will be created if it doesn't exist)"
  type        = string
  default     = "kafka-study-rg"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "southindia"
}

# ========================================
# Cosmos DB Configuration
# ========================================

variable "cosmosdb_account_name" {
  description = "The name of the Cosmos DB account. If empty, uses naming convention: {environment}-cosmos"
  type        = string
  default     = ""
  validation {
    condition     = var.cosmosdb_account_name == "" || can(regex("^[a-z0-9-]{3,44}$", var.cosmosdb_account_name))
    error_message = "Cosmos DB account name must be lowercase, contain only alphanumeric characters and hyphens, and be 3-44 characters long"
  }
}

variable "database_name" {
  description = "The name of the MongoDB database. If empty, uses: {environment}-db"
  type        = string
  default     = ""
}

variable "collection_name" {
  description = "The name of the MongoDB collection to create"
  type        = string
  default     = "messages"
}

variable "enable_automatic_failover" {
  description = "Enable automatic failover for Cosmos DB (not supported in serverless mode)"
  type        = bool
  default     = false
}

variable "enable_free_tier" {
  description = "Enable free tier for Cosmos DB (not supported in serverless mode, only one free tier account per subscription)"
  type        = bool
  default     = false
}

variable "consistency_level" {
  description = "The consistency level for Cosmos DB (Eventual, ConsistentPrefix, Session, BoundedStaleness, Strong)"
  type        = string
  default     = "Session"
  validation {
    condition     = contains(["Eventual", "ConsistentPrefix", "Session", "BoundedStaleness", "Strong"], var.consistency_level)
    error_message = "Consistency level must be one of: Eventual, ConsistentPrefix, Session, BoundedStaleness, Strong"
  }
}

variable "default_ttl_seconds" {
  description = "The default time to live in seconds for documents in the collection"
  type        = number
  default     = -1 # -1 means no TTL
}

variable "shard_key" {
  description = "The shard key for the MongoDB collection"
  type        = string
  default     = "_id"
}

variable "additional_indexes" {
  description = "Additional indexes to create on the collection"
  type = list(object({
    keys   = list(string)
    unique = optional(bool, false)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# ========================================
# Key Vault Variables
# ========================================

variable "keyvault_name" {
  description = "The name of the Key Vault. If empty, uses naming convention: {environment}-kv"
  type        = string
  default     = ""
}

variable "keyvault_sku" {
  description = "The SKU name of the Key Vault (standard, premium)"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.keyvault_sku)
    error_message = "Key Vault SKU must be standard or premium"
  }
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted vaults"
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = false
}

# ========================================
# App Configuration Variables
# ========================================

variable "appconfig_name" {
  description = "The name of the App Configuration. If empty, uses naming convention: {environment}-appconfig"
  type        = string
  default     = ""
}

variable "appconfig_sku" {
  description = "The SKU of the App Configuration"
  type        = string
  default     = "free"
  validation {
    condition     = contains(["free", "standard"], var.appconfig_sku)
    error_message = "App Configuration SKU must be free or standard"
  }
}

# ========================================
# Azure Event Hub Variables (Kafka-compatible)
# ========================================

variable "eventhub_namespace_name" {
  description = "The name of the Event Hub namespace. If empty, uses naming convention: {environment}-eh-{random}"
  type        = string
  default     = ""
  validation {
    condition     = var.eventhub_namespace_name == "" || can(regex("^[a-zA-Z][a-zA-Z0-9-]{4,48}[a-zA-Z0-9]$", var.eventhub_namespace_name))
    error_message = "Event Hub namespace must start with a letter, be 6-50 characters long, and contain only letters, numbers, and hyphens"
  }
}

variable "eventhub_sku" {
  description = "The SKU of the Event Hub namespace (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.eventhub_sku)
    error_message = "Event Hub SKU must be Basic, Standard, or Premium"
  }
}

variable "eventhub_capacity" {
  description = "The capacity/throughput units (1-20 for Basic/Standard, 1-10 for Premium)"
  type        = number
  default     = 1
  validation {
    condition     = var.eventhub_capacity >= 1 && var.eventhub_capacity <= 20
    error_message = "Event Hub capacity must be between 1 and 20"
  }
}

variable "eventhub_auto_inflate_enabled" {
  description = "Enable auto-inflate for throughput units"
  type        = bool
  default     = false
}

variable "eventhub_maximum_throughput_units" {
  description = "Maximum throughput units when auto-inflate is enabled"
  type        = number
  default     = 20
}

variable "event_hubs" {
  description = "Map of Event Hubs to create (Kafka topics)"
  type = map(object({
    partition_count               = optional(number, 2)
    message_retention             = optional(number, 1)
    capture_enabled               = optional(bool, false)
    capture_interval_seconds      = optional(number, 300)
    capture_size_limit            = optional(number, 314572800)
    capture_container             = optional(string, "eventhub-capture")
    capture_storage_account_id    = optional(string, "")
  }))
  default = {}
}

variable "consumer_groups" {
  description = "Map of consumer groups to create (Kafka consumer groups)"
  type = map(object({
    eventhub_name = string
    user_metadata = optional(string, null)
  }))
  default = {}
}
