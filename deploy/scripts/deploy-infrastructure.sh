#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

ENVIRONMENT="dev"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../azr"

print_message "Deploying infrastructure for environment: $ENVIRONMENT"

# Navigate to Terraform directory
cd "$TERRAFORM_DIR"

# Check if tfvars file exists
TFVARS_FILE="terraform.tfvars.$ENVIRONMENT"
if [ ! -f "$TFVARS_FILE" ]; then
    print_error "Terraform variables file not found: $TFVARS_FILE"
    exit 1
fi

print_message "Using variables file: $TFVARS_FILE"

# Initialize Terraform with Azure backend
print_message "Initializing Terraform..."
terraform init \
  -backend-config="subscription_id=64e6990e-3b3f-4118-a99a-8a77c4f4d968" \
  -backend-config="resource_group_name=rg-terraform_remote_backend" \
  -backend-config="storage_account_name=remotebackendstoragetf" \
  -backend-config="container_name=terraform-remotebackendfiles" \
  -backend-config="key=KAFKA_AKS_${ENVIRONMENT^^}.tfstate" \
  -reconfigure

# Validate Terraform configuration
print_message "Validating Terraform configuration..."
terraform validate

# Plan Terraform changes
print_message "Planning Terraform changes..."
terraform plan -var-file="$TFVARS_FILE" -out="tfplan-$ENVIRONMENT"

# Apply Terraform changes
print_message "Applying Terraform changes..."
terraform apply "tfplan-$ENVIRONMENT"

print_message "Infrastructure deployment completed successfully for $ENVIRONMENT!"

# Get AKS credentials
CLUSTER_NAME="aks-kafka-study-$ENVIRONMENT"
RESOURCE_GROUP="rg-kafka-study-$ENVIRONMENT"

print_message "Fetching AKS credentials..."
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing

print_message "AKS credentials configured. You can now deploy applications using kubectl."
