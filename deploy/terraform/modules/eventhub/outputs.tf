# ========================================
# Event Hub Module - Outputs
# ========================================

output "namespace_id" {
  description = "The ID of the Event Hub namespace"
  value       = azurerm_eventhub_namespace.main.id
}

output "namespace_name" {
  description = "The name of the Event Hub namespace"
  value       = azurerm_eventhub_namespace.main.name
}

output "namespace_endpoint" {
  description = "The endpoint URL for the Event Hub namespace"
  value       = "https://${azurerm_eventhub_namespace.main.name}.servicebus.windows.net:443/"
}

output "kafka_endpoint" {
  description = "The Kafka-compatible endpoint for the Event Hub namespace"
  value       = "${azurerm_eventhub_namespace.main.name}.servicebus.windows.net:9093"
}

# Primary connection string (full access)
output "primary_connection_string" {
  description = "Primary connection string for the Event Hub namespace"
  value       = azurerm_eventhub_namespace_authorization_rule.manage.primary_connection_string
  sensitive   = true
}

output "primary_key" {
  description = "Primary key for the Event Hub namespace"
  value       = azurerm_eventhub_namespace_authorization_rule.manage.primary_key
  sensitive   = true
}

output "secondary_key" {
  description = "Secondary key for the Event Hub namespace"
  value       = azurerm_eventhub_namespace_authorization_rule.manage.secondary_key
  sensitive   = true
}

# Listen-only connection string
output "listen_connection_string" {
  description = "Listen-only connection string"
  value       = azurerm_eventhub_namespace_authorization_rule.listen.primary_connection_string
  sensitive   = true
}

# Send-only connection string
output "send_connection_string" {
  description = "Send-only connection string"
  value       = azurerm_eventhub_namespace_authorization_rule.send.primary_connection_string
  sensitive   = true
}

# Event Hub details
output "eventhub_ids" {
  description = "Map of Event Hub names to their IDs"
  value       = { for k, v in azurerm_eventhub.hubs : k => v.id }
}

output "eventhub_names" {
  description = "List of Event Hub names"
  value       = [for hub in azurerm_eventhub.hubs : hub.name]
}

# Consumer group details
output "consumer_group_ids" {
  description = "Map of consumer group names to their IDs"
  value       = { for k, v in azurerm_eventhub_consumer_group.consumer_groups : k => v.id }
}

output "consumer_group_names" {
  description = "List of consumer group names"
  value       = [for cg in azurerm_eventhub_consumer_group.consumer_groups : cg.name]
}
