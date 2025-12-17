# ========================================
# Service Bus Module - Main Resources
# ========================================

# Service Bus Namespace
resource "azurerm_servicebus_namespace" "main" {
  name                = var.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.sku == "Premium" ? var.capacity : null

  tags = var.tags
}

# Service Bus Topics (Kafka-like topics)
resource "azurerm_servicebus_topic" "topics" {
  for_each = var.topics

  name         = each.key
  namespace_id = azurerm_servicebus_namespace.main.id

  enable_partitioning   = lookup(each.value, "enable_partitioning", false)
  max_size_in_megabytes = lookup(each.value, "max_size_in_megabytes", 1024)

  # TTL settings
  default_message_ttl                      = lookup(each.value, "default_message_ttl", null)
  auto_delete_on_idle                      = lookup(each.value, "auto_delete_on_idle", null)
  duplicate_detection_history_time_window  = lookup(each.value, "duplicate_detection_history_time_window", null)

  # Duplicate detection
  requires_duplicate_detection = lookup(each.value, "requires_duplicate_detection", false)
  support_ordering             = lookup(each.value, "support_ordering", false)
}

# Service Bus Subscriptions (Consumer groups)
resource "azurerm_servicebus_subscription" "subscriptions" {
  for_each = var.subscriptions

  name     = each.key
  topic_id = azurerm_servicebus_topic.topics[each.value.topic_name].id

  max_delivery_count                   = lookup(each.value, "max_delivery_count", 10)
  lock_duration                        = lookup(each.value, "lock_duration", "PT1M")
  default_message_ttl                  = lookup(each.value, "default_message_ttl", null)
  dead_lettering_on_message_expiration = lookup(each.value, "dead_lettering_on_message_expiration", true)

  depends_on = [azurerm_servicebus_topic.topics]
}

# Service Bus Queues
resource "azurerm_servicebus_queue" "queues" {
  for_each = var.queues

  name         = each.key
  namespace_id = azurerm_servicebus_namespace.main.id

  enable_partitioning   = lookup(each.value, "enable_partitioning", false)
  max_size_in_megabytes = lookup(each.value, "max_size_in_megabytes", 1024)

  # Message settings
  default_message_ttl = lookup(each.value, "default_message_ttl", null)
  lock_duration       = lookup(each.value, "lock_duration", "PT1M")
  max_delivery_count  = lookup(each.value, "max_delivery_count", 10)

  # Dead letter settings
  dead_lettering_on_message_expiration = lookup(each.value, "dead_lettering_on_message_expiration", true)

  # Duplicate detection
  requires_duplicate_detection             = lookup(each.value, "requires_duplicate_detection", false)
  duplicate_detection_history_time_window  = lookup(each.value, "duplicate_detection_history_time_window", null)

  # Session support
  requires_session = lookup(each.value, "requires_session", false)
}

# ========================================
# Authorization Rules
# ========================================

# Listen-only authorization rule
resource "azurerm_servicebus_namespace_authorization_rule" "listen" {
  name         = "${var.namespace_name}-listen"
  namespace_id = azurerm_servicebus_namespace.main.id

  listen = true
  send   = false
  manage = false
}

# Send-only authorization rule
resource "azurerm_servicebus_namespace_authorization_rule" "send" {
  name         = "${var.namespace_name}-send"
  namespace_id = azurerm_servicebus_namespace.main.id

  listen = false
  send   = true
  manage = false
}

# Manage authorization rule
resource "azurerm_servicebus_namespace_authorization_rule" "manage" {
  name         = "${var.namespace_name}-manage"
  namespace_id = azurerm_servicebus_namespace.main.id

  listen = true
  send   = true
  manage = true
}
