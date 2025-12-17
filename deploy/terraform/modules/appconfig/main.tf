# ========================================
# App Configuration Module - Main Resources
# ========================================

# App Configuration Store
resource "azurerm_app_configuration" "main" {
  name                = var.appconfig_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  tags = var.tags
}

# Store configuration values
resource "azurerm_app_configuration_key" "config_values" {
  for_each = var.config_values

  configuration_store_id = azurerm_app_configuration.main.id
  key                    = each.key
  value                  = each.value
  type                   = "kv"

  depends_on = [azurerm_app_configuration.main]
}

# Store Key Vault references
resource "azurerm_app_configuration_key" "keyvault_references" {
  for_each = var.keyvault_references

  configuration_store_id = azurerm_app_configuration.main.id
  key                    = each.key
  type                   = "vault"
  vault_key_reference   = each.value

  depends_on = [azurerm_app_configuration.main]
}
