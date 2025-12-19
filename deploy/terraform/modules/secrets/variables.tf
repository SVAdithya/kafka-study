# ========================================
# Key Vault Module - Variables
# ========================================

variable "keyvault_name" {
  description = "The name of the Key Vault (3-24 characters)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.keyvault_name))
    error_message = "Key Vault name must be 3-24 characters and contain only alphanumeric characters and hyphens"
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

variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}

variable "admin_object_id" {
  description = "The object ID of the admin user/service principal"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Key Vault (standard or premium)"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be standard or premium"
  }
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted vaults"
  type        = number
  default     = 7
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Retention days must be between 7 and 90"
  }
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Allow Azure Virtual Machines to retrieve certificates"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Allow Azure Disk Encryption to retrieve secrets"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Allow Azure Resource Manager to retrieve secrets"
  type        = bool
  default     = false
}

variable "network_acls_bypass" {
  description = "Network ACLs bypass setting"
  type        = string
  default     = "AzureServices"
}

variable "network_acls_default_action" {
  description = "Default network ACL action"
  type        = string
  default     = "Allow"
  validation {
    condition     = contains(["Allow", "Deny"], var.network_acls_default_action)
    error_message = "Default action must be Allow or Deny"
  }
}

variable "network_acls_ip_rules" {
  description = "List of IP addresses or CIDR blocks to allow"
  type        = list(string)
  default     = []
}

variable "secrets" {
  description = "Map of secrets to store in Key Vault"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "Tags to assign to resources"
  type        = map(string)
  default     = {}
}
