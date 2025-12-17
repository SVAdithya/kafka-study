# ========================================
# Service Bus Module - Outputs
# ========================================

output "namespace_id" {
  description = "The ID of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.id
}

output "namespace_name" {
  description = "The name of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.name
}

output "namespace_endpoint" {
  description = "The endpoint URL for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.endpoint
}

output "primary_connection_string" {
  description = "Primary connection string (Manage policy)"
  value       = azurerm_servicebus_namespace_authorization_rule.manage.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "Secondary connection string (Manage policy)"
  value       = azurerm_servicebus_namespace_authorization_rule.manage.secondary_connection_string
  sensitive   = true
}

output "listen_connection_string" {
  description = "Connection string with Listen permissions"
  value       = azurerm_servicebus_namespace_authorization_rule.listen.primary_connection_string
  sensitive   = true
}

output "send_connection_string" {
  description = "Connection string with Send permissions"
  value       = azurerm_servicebus_namespace_authorization_rule.send.primary_connection_string
  sensitive   = true
}

output "primary_key" {
  description = "Primary access key"
  value       = azurerm_servicebus_namespace_authorization_rule.manage.primary_key
  sensitive   = true
}

output "topics" {
  description = "Map of created topics"
  value = {
    for name, topic in azurerm_servicebus_topic.topics : name => {
      id   = topic.id
      name = topic.name
    }
  }
}

output "queues" {
  description = "Map of created queues"
  value = {
    for name, queue in azurerm_servicebus_queue.queues : name => {
      id   = queue.id
      name = queue.name
    }
  }
}

output "subscriptions" {
  description = "Map of created subscriptions"
  value = {
    for name, sub in azurerm_servicebus_subscription.subscriptions : name => {
      id         = sub.id
      name       = sub.name
      topic_name = sub.topic_id
    }
  }
}
