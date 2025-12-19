# ========================================
# App Configuration Module - Outputs
# ========================================

output "appconfig_id" {
  description = "The ID of the App Configuration"
  value       = azurerm_app_configuration.main.id
}

output "appconfig_name" {
  description = "The name of the App Configuration"
  value       = azurerm_app_configuration.main.name
}

output "appconfig_endpoint" {
  description = "The endpoint of the App Configuration"
  value       = azurerm_app_configuration.main.endpoint
}

output "appconfig_primary_read_key" {
  description = "The primary read key"
  value       = azurerm_app_configuration.main.primary_read_key[0].connection_string
  sensitive   = true
}

output "appconfig_primary_write_key" {
  description = "The primary write key"
  value       = azurerm_app_configuration.main.primary_write_key[0].connection_string
  sensitive   = true
}
