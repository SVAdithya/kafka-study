# Environment Configurations

This directory contains environment-specific configurations.

## Structure

```
environments/
├── dev.tfvars        # Development environment
├── staging.tfvars    # Staging environment  
└── prod.tfvars       # Production environment
```

## Current Environments

### Development
- **File**: `environments/dev.tfvars`
- **Resources**: `dev-cosmos`, `dev-sb`, `dev-kv`, `dev-appconfig`
- **Purpose**: Development and testing

### Staging
- **File**: `environments/staging.tfvars`
- **Resources**: `staging-cosmos`, `staging-sb`, `staging-kv`, `staging-appconfig`
- **Purpose**: Pre-production testing

### Production
- **File**: `environments/prod.tfvars`
- **Resources**: `prod-cosmos`, `prod-sb`, `prod-kv`, `prod-appconfig`
- **Purpose**: Live production environment

## Usage

### Deploy for a specific environment

```bash
# Development
terraform apply -var-file="environments/dev.tfvars"

# Staging
terraform apply -var-file="environments/staging.tfvars"

# Production  
terraform apply -var-file="environments/prod.tfvars"
```

## Adding a New Environment

1. **Create environment file:**
   ```bash
   cp environments/dev.tfvars environments/uat.tfvars
   ```

2. **Update environment name:**
   Edit `environments/uat.tfvars`:
   ```hcl
   environment = "uat"
   ```

3. **Adjust configurations** based on environment needs (SKUs, replicas, etc.)

4. **Deploy:**
   ```bash
   terraform apply -var-file="environments/uat.tfvars"
   ```

## Configuration Guidelines

### Development Environment

Optimize for cost:
- ✅ Use free tiers when available (`enable_free_tier = true`)
- ✅ Use Basic/Standard SKUs
- ✅ Smaller resource sizes
- ✅ Single regions
- ❌ No automatic failover
- ❌ No purge protection

**Example:**
```hcl
environment = "dev"
enable_free_tier = true
servicebus_sku = "Standard"
consistency_level = "Session"
purge_protection_enabled = false
```

### Staging Environment

Balance cost and reliability:
- ✅ Standard SKUs
- ✅ Medium resource sizes
- ✅ Single region
- ❌ No automatic failover
- ❌ No purge protection

**Example:**
```hcl
environment = "staging"
enable_free_tier = false
servicebus_sku = "Standard"
consistency_level = "Session"
purge_protection_enabled = false
```

### Production Environment

Optimize for reliability:
- ✅ Premium SKUs for critical services
- ✅ Automatic failover enabled
- ✅ Purge protection enabled
- ✅ Stronger consistency levels
- ✅ Larger resource sizes
- ✅ Multiple regions (if needed)

**Example:**
```hcl
environment = "prod"
enable_free_tier = false
servicebus_sku = "Premium"
servicebus_capacity = 2
enable_automatic_failover = true
consistency_level = "Strong"
purge_protection_enabled = true
```

## Variable Reference

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `environment` | Environment name | `"dev"`, `"staging"`, `"prod"` |
| `resource_group_name` | Azure resource group | `"learn-all"` |

### Common Customizations

| Variable | Dev Value | Staging Value | Prod Value |
|----------|-----------|---------------|------------|
| `enable_free_tier` | `true` | `false` | `false` |
| `servicebus_sku` | `"Standard"` | `"Standard"` | `"Premium"` |
| `consistency_level` | `"Session"` | `"Session"` | `"Strong"` |
| `purge_protection_enabled` | `false` | `false` | `true` |
| `enable_automatic_failover` | `false` | `false` | `true` |

## Service Bus Topics Configuration

Topics represent message streams (similar to Kafka topics):

```hcl
servicebus_topics = {
  "orders-topic" = {
    enable_partitioning = true
    support_ordering    = true
    max_size_in_megabytes = 1024
    default_message_ttl = "P14D"  # 14 days
  }
  "events-topic" = {
    enable_partitioning = true
  }
}
```

## Service Bus Subscriptions

Subscriptions are like Kafka consumer groups:

```hcl
servicebus_subscriptions = {
  "orders-processor-sub" = {
    topic_name         = "orders-topic"
    max_delivery_count = 10
    lock_duration     = "PT5M"  # 5 minutes
  }
}
```

## Naming Conventions

Resources are automatically named using the pattern:
```
{environment}-{service}
```

Examples:
- **Dev**: `dev-cosmos`, `dev-sb`, `dev-kv`, `dev-orders-topic`
- **Staging**: `staging-cosmos`, `staging-sb`, `staging-kv`
- **Prod**: `prod-cosmos`, `prod-sb`, `prod-kv`

To override, set explicit names in your tfvars:
```hcl
cosmosdb_account_name = "my-custom-name"
```

## Tags

All resources are tagged automatically:
```hcl
tags = {
  Environment = var.environment  # "dev", "staging", or "prod"
  ManagedBy   = "Terraform"
  Project     = var.project_name
  CostCenter  = var.cost_center
}
```

Add custom tags in your tfvars:
```hcl
tags = {
  Owner      = "DevTeam"
  Criticality = "High"
}
```

## Best Practices

1. **Version Control**: Commit environment files to Git (except sensitive values)
2. **Secret Management**: Never put secrets in tfvars - use Key Vault
3. **Consistent Naming**: Follow the environment-service pattern
4. **Documentation**: Document any environment-specific configurations
5. **Review Changes**: Always run `terraform plan` before `apply`
6. **Workspaces**: Consider using Terraform workspaces for additional isolation

## Security Notes

⚠️ **Never commit:**
- Actual passwords or keys
- Production connection strings
- Sensitive configuration values

✅ **Do commit:**
- Structure and configuration patterns
- Non-sensitive default values
- Documentation

## Support

For questions about environment configuration:
- Review the main [README.md](../README.md)
- Check module documentation in `modules/*/README.md`
- See [QUICKSTART.md](../QUICKSTART.md) for deployment examples

---

**Tip**: Use `terraform workspace` for additional isolation between environments!
