# ========================================
# Event Hub Module - Main Resources
# ========================================
# Event Hubs provides a Kafka-compatible endpoint for streaming data

# Resource Group (optional - for standalone module testing)
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Use the created or existing resource group name
locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : var.resource_group_name
}

# Event Hub Namespace
resource "azurerm_eventhub_namespace" "main" {
  name                = var.namespace_name
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = var.sku
  capacity            = var.capacity

  # Enable Kafka for compatibility
  auto_inflate_enabled     = var.auto_inflate_enabled
  maximum_throughput_units = var.auto_inflate_enabled ? var.maximum_throughput_units : null

  tags = var.tags
}

# Event Hubs (equivalent to Kafka topics)
resource "azurerm_eventhub" "hubs" {
  for_each = var.event_hubs

  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = local.resource_group_name
  partition_count     = lookup(each.value, "partition_count", 2)
  message_retention   = lookup(each.value, "message_retention", 1)

  # Capture configuration (optional)
  dynamic "capture_description" {
    for_each = lookup(each.value, "capture_enabled", false) ? [1] : []
    content {
      enabled  = true
      encoding = "Avro"
      interval_in_seconds = lookup(each.value, "capture_interval_seconds", 300)
      size_limit_in_bytes = lookup(each.value, "capture_size_limit", 314572800)

      destination {
        name                = "EventHubArchive.AzureBlockBlob"
        archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
        blob_container_name = lookup(each.value, "capture_container", "eventhub-capture")
        storage_account_id  = lookup(each.value, "capture_storage_account_id", "")
      }
    }
  }
}

# Consumer Groups (equivalent to Kafka consumer groups)
resource "azurerm_eventhub_consumer_group" "consumer_groups" {
  for_each = var.consumer_groups

  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.hubs[each.value.eventhub_name].name
  resource_group_name = local.resource_group_name
  user_metadata       = lookup(each.value, "user_metadata", null)

  depends_on = [azurerm_eventhub.hubs]
}

# ========================================
# Authorization Rules
# ========================================

# Listen-only authorization rule
resource "azurerm_eventhub_namespace_authorization_rule" "listen" {
  name                = "${var.namespace_name}-listen"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = local.resource_group_name

  listen = true
  send   = false
  manage = false
}

# Send-only authorization rule
resource "azurerm_eventhub_namespace_authorization_rule" "send" {
  name                = "${var.namespace_name}-send"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = local.resource_group_name

  listen = false
  send   = true
  manage = false
}

# Manage authorization rule (full access)
resource "azurerm_eventhub_namespace_authorization_rule" "manage" {
  name                = "${var.namespace_name}-manage"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = local.resource_group_name

  listen = true
  send   = true
  manage = true
}
