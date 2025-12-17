# ========================================
# App Configuration Module - Variables
# ========================================

variable "appconfig_name" {
  description = "The name of the App Configuration store"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{5,50}$", var.appconfig_name))
    error_message = "App Configuration name must be 5-50 characters and contain only alphanumeric characters and hyphens"
  }
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
  description = "The SKU of the App Configuration (free or standard)"
  type        = string
  default     = "free"
  validation {
    condition     = contains(["free", "standard"], var.sku)
    error_message = "SKU must be free or standard"
  }
}

variable "config_values" {
  description = "Map of configuration key-value pairs to store"
  type        = map(string)
  default     = {}
}

variable "keyvault_references" {
  description = "Map of Key Vault secret references"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to assign to resources"
  type        = map(string)
  default     = {}
}
