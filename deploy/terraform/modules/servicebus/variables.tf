# ========================================
# Service Bus Module - Variables
# ========================================

variable "namespace_name" {
  description = "The name of the Service Bus namespace"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "sku" {
  description = "The SKU of the Service Bus namespace (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium"
  }
}

variable "capacity" {
  description = "The capacity/messaging units for Premium SKU"
  type        = number
  default     = 1
  validation {
    condition     = contains([1, 2, 4, 8, 16], var.capacity)
    error_message = "Capacity must be 1, 2, 4, 8, or 16"
  }
}

variable "topics" {
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

variable "subscriptions" {
  description = "Map of Service Bus subscriptions"
  type = map(object({
    topic_name                               = string
    max_delivery_count                       = optional(number, 10)
    lock_duration                           = optional(string, "PT1M")
    default_message_ttl                      = optional(string, null)
    dead_lettering_on_message_expiration    = optional(bool, true)
  }))
  default = {}
}

variable "queues" {
  description = "Map of Service Bus queues"
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

variable "tags" {
  description = "Tags to assign to resources"
  type        = map(string)
  default     = {}
}
