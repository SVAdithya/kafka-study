# Terraform Infrastructure - Azure Kafka Study

Complete Azure infrastructure with Cosmos DB (MongoDB API), Service Bus (Kafka alternative), Key Vault, and App Configuration.

## 🚀 Quick Start (5 Minutes)

```bash
# 1. Login to Azure
az login

# 2. Navigate to terraform directory
cd deploy/terraform

# 3. Initialize Terraform
terraform init

# 4. Deploy to dev
terraform apply -var-file="environments/dev.tfvars"
```

**That's it!** Resources created:
- ✅ Cosmos DB: `dev-cosmos`
- ✅ Service Bus: `dev-sb` with topics & queues
- ✅ Key Vault: `dev-kv` (all secrets stored automatically)
- ✅ App Configuration: `dev-appconfig`

## 📁 Project Structure

```
terraform/
├── main.tf                      # Orchestrates all modules
├── provider.tf                  # Azure provider config
├── data.tf                      # Data sources
├── locals.tf                    # Naming: {environment}-{service}
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
│
├── modules/                     # Resource modules
│   ├── cosmos/                  # Cosmos DB (MongoDB API)
│   ├── servicebus/              # Service Bus (Kafka alternative)
│   ├── secrets/                 # Key Vault
│   └── appconfig/               # App Configuration
│
└── environments/                # Environment configs
    ├── dev.tfvars              # Development
    ├── staging.tfvars          # Staging
    └── prod.tfvars             # Production
```

## 🎯 Resource Naming

**Pattern**: `{environment}-{service}`

| Environment | Cosmos DB | Service Bus | Key Vault | App Config |
|-------------|-----------|-------------|-----------|------------|
| **dev** | dev-cosmos | dev-sb | dev-kv | dev-appconfig |
| **staging** | staging-cosmos | staging-sb | staging-kv | staging-appconfig |
| **prod** | prod-cosmos | prod-sb | prod-kv | prod-appconfig |

## 🔐 Secrets Management

All connection strings are **automatically stored** in:

### Key Vault Secrets (Sensitive)
- `cosmos-connection-string`
- `cosmos-primary-key`
- `servicebus-connection-string`
- `servicebus-listen-connection`
- `servicebus-send-connection`

### App Configuration (Settings + Key Vault References)
- Non-sensitive: Endpoints, database names
- Sensitive: Key Vault references to secrets above

### Access Secrets

```bash
# Get Key Vault name
KEYVAULT=$(terraform output -raw keyvault_name)

# View secret
az keyvault secret show --vault-name $KEYVAULT --name cosmos-connection-string

# Or from Terraform
terraform output -raw cosmosdb_connection_string
```

## 📝 Deployment

### Development
```bash
terraform apply -var-file="environments/dev.tfvars"
```

### Staging
```bash
terraform apply -var-file="environments/staging.tfvars"
```

### Production
```bash
terraform apply -var-file="environments/prod.tfvars"
```

## 📊 How Environment Works

```
environments/dev.tfvars
  └─ environment = "dev"
       ↓
variables.tf (var.environment)
       ↓
locals.tf (computes names)
  ├─ cosmosdb_account_name = "dev-cosmos"
  ├─ servicebus_namespace = "dev-sb"
  ├─ keyvault_name = "dev-kv"
  └─ appconfig_name = "dev-appconfig"
       ↓
main.tf → modules create resources
       ↓
Azure Resources:
  ✓ dev-cosmos
  ✓ dev-sb
  ✓ dev-kv
  ✓ dev-appconfig
```

## ⚙️ Configuration

### Basic Configuration (dev.tfvars)

```hcl
# Environment
environment = "dev"

# Azure
resource_group_name = "learn-all"

# Cosmos DB
enable_free_tier = true

# Service Bus
servicebus_sku = "Standard"

# Topics (Kafka-like)
servicebus_topics = {
  "orders-topic" = {
    enable_partitioning = true
    support_ordering    = true
  }
}

# Subscriptions (Consumer groups)
servicebus_subscriptions = {
  "orders-processor-sub" = {
    topic_name = "orders-topic"
  }
}
```

## 📤 Outputs

```bash
# View deployment summary
terraform output deployment_summary

# View configuration guide
terraform output application_config_guide

# Get specific values
terraform output cosmosdb_endpoint
terraform output servicebus_namespace_name
terraform output keyvault_name
terraform output appconfig_name

# Get sensitive values
terraform output -raw cosmosdb_connection_string
terraform output -raw servicebus_connection_string
```

## 🔌 Connect Your Application

### Spring Boot - application.properties

```properties
# MongoDB
spring.data.mongodb.uri=${COSMOS_CONNECTION_STRING}
spring.data.mongodb.database=dev-db

# Service Bus
spring.cloud.azure.servicebus.connection-string=${SERVICEBUS_CONNECTION_STRING}
```

### Environment Variables

```bash
export COSMOS_CONNECTION=$(terraform output -raw cosmosdb_connection_string)
export SERVICEBUS_CONNECTION=$(terraform output -raw servicebus_connection_string)
export KEYVAULT_NAME=$(terraform output -raw keyvault_name)
```

### Using App Configuration

```properties
# Spring Boot
azure.appconfiguration.stores[0].connection-string=${APPCONFIG_CONNECTION_STRING}

# App Config automatically provides:
# - CosmosDB:Endpoint
# - ServiceBus:Namespace
# - ConnectionStrings:CosmosDB (Key Vault reference)
# - ConnectionStrings:ServiceBus (Key Vault reference)
```

## 📊 Service Bus vs Kafka

| Kafka Concept | Service Bus Equivalent |
|---------------|------------------------|
| Topic | Topic |
| Partition | Partitioning (enable_partitioning) |
| Consumer Group | Subscription |
| Producer | Sender |
| Consumer | Receiver |
| Offset | Sequence Number |

## 🏗️ Modules

### Cosmos DB (`modules/cosmos`)
- MongoDB API compatible
- Serverless or provisioned throughput
- Free tier available
- Configurable consistency levels

### Service Bus (`modules/servicebus`)
- Topics (pub/sub messaging)
- Queues (point-to-point)
- Subscriptions (consumer groups)
- Dead-letter queues
- Authorization rules (Listen, Send, Manage)

### Key Vault (`modules/secrets`)
- Secure secret storage
- Access policies
- Soft delete & purge protection
- Network ACLs

### App Configuration (`modules/appconfig`)
- Centralized configuration
- Key Vault references
- Feature flags support
- Free and Standard tiers

## 🎛️ Environment Comparison

| Feature | Dev | Staging | Prod |
|---------|-----|---------|------|
| **Cosmos DB** | Free tier | Standard | Standard |
| **Service Bus** | Standard | Standard | Premium |
| **Failover** | ❌ | ❌ | ✅ |
| **Purge Protection** | ❌ | ❌ | ✅ |
| **App Config** | Free | Free | Standard |
| **Topic Size** | 1 GB | 2 GB | 5 GB |

## 🔧 Advanced

### Add New Environment

```bash
# Copy existing config
cp environments/dev.tfvars environments/uat.tfvars

# Edit environment name
# environment = "uat"

# Deploy
terraform apply -var-file="environments/uat.tfvars"
```

### Use Terraform Workspaces

```bash
# Create workspace
terraform workspace new dev

# Switch workspace
terraform workspace select dev

# Deploy
terraform apply -var-file="environments/dev.tfvars"
```

### Enable Remote State

Uncomment in `provider.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "terraform-state-rg"
  storage_account_name = "tfstatestorage"
  container_name       = "tfstate"
  key                  = "${var.environment}/terraform.tfstate"
}
```

## 🧹 Cleanup

```bash
# Destroy specific environment
terraform destroy -var-file="environments/dev.tfvars"
```

**⚠️ Warning:** This permanently deletes all resources and data!

## 🔍 Troubleshooting

### Resource Group Not Found
```bash
# Check if exists
az group show --name learn-all

# Create if needed
az group create --name learn-all --location southindia
```

### Name Already Exists
Cosmos DB and Service Bus names must be globally unique. Change in tfvars:
```hcl
cosmosdb_account_name = "my-unique-name-cosmos"
servicebus_namespace_name = "my-unique-name-sb"
```

### Authentication Failed
```bash
az login
az account set --subscription "your-subscription-id"
az account show
```

### Key Vault Access Denied
```bash
az keyvault set-policy --name $(terraform output -raw keyvault_name) \
  --upn $(az account show --query user.name -o tsv) \
  --secret-permissions get list
```

### App Config Access Denied
```bash
# Grant Data Reader role
az role assignment create \
  --assignee $(az account show --query user.name -o tsv) \
  --role "App Configuration Data Reader" \
  --scope $(terraform output -raw appconfig_id)
```

## ✨ Features

✅ **4 Azure Services**: Cosmos DB, Service Bus, Key Vault, App Configuration  
✅ **Automatic Secrets**: All connection strings stored in Key Vault  
✅ **App Configuration**: Settings + Key Vault references  
✅ **Environment-based**: Simple dev/staging/prod structure  
✅ **Kafka Alternative**: Service Bus with topics & subscriptions  
✅ **MongoDB Compatible**: Cosmos DB with MongoDB API  
✅ **Modular Design**: Each service in separate module  
✅ **Clean Naming**: `{environment}-{service}` pattern  

## 📚 Additional Info

### Module Documentation
- [Cosmos DB Module](./modules/cosmos/README.md)
- [Service Bus Module](./modules/servicebus/README.md)
- [Key Vault Module](./modules/secrets/README.md)
- [App Configuration Module](./modules/appconfig/README.md)

### Prerequisites
- Azure CLI (`az`) installed and logged in
- Terraform >= 1.0
- Existing Azure Resource Group

### Cost Optimization
- **Dev**: Use free tiers (`enable_free_tier = true`)
- **Staging**: Standard SKUs
- **Prod**: Premium SKUs with failover

### Best Practices
1. Always run `terraform plan` before `apply`
2. Use workspaces for isolation
3. Enable remote state for teams
4. Never commit secrets or tfvars files
5. Tag all resources properly
6. Enable purge protection in production

## 🆘 Support

- **Terraform Docs**: https://www.terraform.io/docs
- **Azure Provider**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **Azure Cosmos DB**: https://docs.microsoft.com/azure/cosmos-db/
- **Azure Service Bus**: https://docs.microsoft.com/azure/service-bus-messaging/

---

**Version**: 1.0  
**Last Updated**: December 2025  
**Pattern**: `{environment}-{service}`  
**Secrets**: Fully automated! ✨
