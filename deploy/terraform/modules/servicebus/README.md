# Service Bus Module

This module creates an Azure Service Bus namespace with topics, queues, and subscriptions.

## Features

- Service Bus namespace with configurable SKU
- Topics (similar to Kafka topics)
- Subscriptions (similar to Kafka consumer groups)
- Queues for point-to-point messaging
- Authorization rules (Listen, Send, Manage)
- Partitioning support
- Dead-letter queues
- Duplicate detection

## Usage

```hcl
module "servicebus" {
  source = "./modules/servicebus"

  namespace_name      = "dev-sb"
  location           = "eastus"
  resource_group_name = "learn-all"
  sku                = "Standard"
  
  topics = {
    "orders-topic" = {
      enable_partitioning = true
      support_ordering    = true
    }
    "events-topic" = {
      enable_partitioning = true
    }
  }
  
  subscriptions = {
    "orders-processor" = {
      topic_name         = "orders-topic"
      max_delivery_count = 10
    }
  }
  
  queues = {
    "priority-queue" = {
      enable_partitioning = true
      max_delivery_count  = 10
    }
  }
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| namespace_name | Service Bus namespace name | string | - | yes |
| location | Azure region | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| sku | Service Bus SKU | string | "Standard" | no |
| topics | Map of topics to create | map | {} | no |
| subscriptions | Map of subscriptions | map | {} | no |
| queues | Map of queues | map | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace_endpoint | Service Bus endpoint URL |
| primary_connection_string | Primary connection string (sensitive) |
| listen_connection_string | Listen-only connection string |
| send_connection_string | Send-only connection string |
