# ========================================
# Cosmos DB Module - Variables
# ========================================

variable "cosmosdb_account_name" {
  description = "The name of the Cosmos DB account"
  type        = string
}

variable "location" {
  description = "The Azure region where Cosmos DB will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "database_name" {
  description = "The name of the MongoDB database"
  type        = string
}

variable "collection_name" {
  description = "The name of the MongoDB collection"
  type        = string
  default     = "messages"
}

variable "enable_automatic_failover" {
  description = "Enable automatic failover for Cosmos DB"
  type        = bool
  default     = false
}

variable "enable_free_tier" {
  description = "Enable free tier for Cosmos DB"
  type        = bool
  default     = false
}

variable "consistency_level" {
  description = "The consistency level for Cosmos DB"
  type        = string
  default     = "Session"
  validation {
    condition     = contains(["Eventual", "ConsistentPrefix", "Session", "BoundedStaleness", "Strong"], var.consistency_level)
    error_message = "Consistency level must be one of: Eventual, ConsistentPrefix, Session, BoundedStaleness, Strong"
  }
}

variable "default_ttl_seconds" {
  description = "The default time to live in seconds for documents"
  type        = number
  default     = -1
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
  description = "Tags to assign to the resources"
  type        = map(string)
  default     = {}
}
