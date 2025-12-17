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
  default     = ""
}

# ========================================
# Azure Configuration
# ========================================

variable "resource_group_name" {
  description = "The name of the existing resource group where resources will be created"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created. If empty, uses the resource group location"
  type        = string
  default     = ""
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
  description = "Enable automatic failover for Cosmos DB"
  type        = bool
  default     = false
}

variable "enable_free_tier" {
  description = "Enable free tier for Cosmos DB (only one free tier account per subscription)"
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
  description = "The SKU name of the Key Vault"
  type        = string
  default     = "standard"
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
# Azure Service Bus Variables
# ========================================

variable "servicebus_namespace_name" {
  description = "The name of the Service Bus namespace. If empty, uses naming convention: {environment}-sb"
  type        = string
  default     = ""
  validation {
    condition     = var.servicebus_namespace_name == "" || can(regex("^[a-zA-Z][a-zA-Z0-9-]{4,48}[a-zA-Z0-9]$", var.servicebus_namespace_name))
    error_message = "Service Bus namespace must start with a letter, be 6-50 characters long, and contain only letters, numbers, and hyphens"
  }
}

variable "servicebus_sku" {
  description = "The SKU of the Service Bus namespace (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.servicebus_sku)
    error_message = "Service Bus SKU must be Basic, Standard, or Premium"
  }
}

variable "servicebus_capacity" {
  description = "The capacity/messaging units for Premium SKU (1, 2, 4, 8, or 16)"
  type        = number
  default     = 1
  validation {
    condition     = contains([1, 2, 4, 8, 16], var.servicebus_capacity)
    error_message = "Service Bus capacity must be 1, 2, 4, 8, or 16"
  }
}

variable "servicebus_topics" {
  description = "Map of Service Bus topics to create"
  type = map(object({
    enable_partitioning                      = optional(bool, false)
    max_size_in_megabytes                   = optional(number, 1024)
    default_message_ttl                      = optional(string, null)
    auto_delete_on_idle                     = optional(string, null)
    duplicate_detection_history_time_window = optional(string, null)
    requires_duplicate_detection            = optional(bool, false)
    support_ordering                        = optional(bool, false)
  }))
  default = {}
}

variable "servicebus_subscriptions" {
  description = "Map of Service Bus subscriptions to create"
  type = map(object({
    topic_name                               = string
    max_delivery_count                       = optional(number, 10)
    lock_duration                           = optional(string, "PT1M")
    default_message_ttl                      = optional(string, null)
    dead_lettering_on_message_expiration    = optional(bool, true)
  }))
  default = {}
}

variable "servicebus_queues" {
  description = "Map of Service Bus queues to create"
  type = map(object({
    enable_partitioning                      = optional(bool, false)
    max_size_in_megabytes                   = optional(number, 1024)
    default_message_ttl                      = optional(string, null)
    lock_duration                           = optional(string, "PT1M")
    max_delivery_count                       = optional(number, 10)
    dead_lettering_on_message_expiration    = optional(bool, true)
    requires_duplicate_detection            = optional(bool, false)
    duplicate_detection_history_time_window = optional(string, null)
    requires_session                        = optional(bool, false)
  }))
  default = {}
}
