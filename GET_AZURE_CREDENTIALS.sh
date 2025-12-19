#!/bin/bash

# ============================================
# Get Azure Connection Strings from Terraform
# ============================================

echo "=========================================="
echo "Azure Configuration Details"
echo "=========================================="
echo ""

cd deploy/terraform

echo "1. APP CONFIGURATION CONNECTION STRING:"
echo "----------------------------------------"
terraform output -raw appconfig_connection_string
echo ""
echo ""

echo "2. EVENT HUB KAFKA ENDPOINT:"
echo "----------------------------------------"
terraform output -raw eventhub_kafka_endpoint
echo ""
echo ""

echo "3. EVENT HUB CONNECTION STRING (for SASL):"
echo "----------------------------------------"
terraform output -raw eventhub_connection_string
echo ""
echo ""

echo "4. COSMOS DB CONNECTION STRING:"
echo "----------------------------------------"
terraform output -raw cosmosdb_connection_string
echo ""
echo ""

echo "5. COSMOS DB DATABASE NAME:"
echo "----------------------------------------"
echo "dev-db"
echo ""
echo ""

echo "6. KEY VAULT NAME:"
echo "----------------------------------------"
terraform output -raw keyvault_name
echo ""
echo ""

echo "=========================================="
echo "Environment Variables for Application"
echo "=========================================="
echo ""
echo "Copy and paste these into your terminal:"
echo ""
echo "export APPCONFIG_CONNECTION_STRING=\"$(terraform output -raw appconfig_connection_string)\""
echo ""
echo "# Or use direct connection strings:"
echo "export EVENTHUB_KAFKA_ENDPOINT=\"$(terraform output -raw eventhub_kafka_endpoint)\""
echo "export EVENTHUB_CONNECTION_STRING=\"$(terraform output -raw eventhub_connection_string)\""
echo "export COSMOSDB_CONNECTION_STRING=\"$(terraform output -raw cosmosdb_connection_string)\""
echo "export COSMOSDB_DATABASE=\"dev-db\""
echo ""
echo ""

echo "=========================================="
echo "Quick Test Commands"
echo "=========================================="
echo ""
echo "# Test App Configuration:"
echo "az appconfig kv list --connection-string \"\$(terraform output -raw appconfig_connection_string)\" | head -20"
echo ""
echo "# List Key Vault secrets:"
echo "az keyvault secret list --vault-name \$(terraform output -raw keyvault_name) --query \"[].name\" -o table"
echo ""
echo "# Get specific secret from Key Vault:"
echo "az keyvault secret show --vault-name \$(terraform output -raw keyvault_name) --name eventhub-kafka-endpoint --query value -o tsv"
echo ""
