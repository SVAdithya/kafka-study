# ========================================
# Key Vault Module - Outputs
# ========================================

output "keyvault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "keyvault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "keyvault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "secret_ids" {
  description = "Map of secret names to their IDs"
  value = {
    for name, secret in azurerm_key_vault_secret.secrets : name => secret.id
  }
}
