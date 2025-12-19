# ========================================
# Event Hub Module - Variables
# ========================================

variable "create_resource_group" {
  description = "Whether to create a new resource group (useful for standalone testing)"
  type        = bool
  default     = false
}

variable "namespace_name" {
  description = "The name of the Event Hub namespace"
  type        = string
}

variable "location" {
  description = "The Azure region where Event Hub will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "sku" {
  description = "The SKU of the Event Hub namespace (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium"
  }
}

variable "capacity" {
  description = "The capacity/throughput units for the namespace (1-20 for Basic/Standard, 1-10 for Premium)"
  type        = number
  default     = 1
  validation {
    condition     = var.capacity >= 1 && var.capacity <= 20
    error_message = "Capacity must be between 1 and 20"
  }
}

variable "auto_inflate_enabled" {
  description = "Enable auto-inflate for throughput units"
  type        = bool
  default     = false
}

variable "maximum_throughput_units" {
  description = "Maximum throughput units when auto-inflate is enabled"
  type        = number
  default     = 20
}

variable "event_hubs" {
  description = "Map of Event Hubs to create (equivalent to Kafka topics)"
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
  description = "Map of consumer groups to create (equivalent to Kafka consumer groups)"
  type = map(object({
    eventhub_name = string
    user_metadata = optional(string, null)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to assign to the resources"
  type        = map(string)
  default     = {}
}
