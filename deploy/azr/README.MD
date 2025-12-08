# Azure AKS Infrastructure - Dev Environment

This directory contains Terraform configuration for provisioning an Azure Kubernetes Service (AKS) cluster for the Kafka
Study application in the **dev** environment.

## Overview

The Terraform configuration creates:

- **Resource Group**: `rg-kafka-study-dev`
- **Virtual Network**: 10.0.0.0/16 CIDR
- **Subnet**: 10.0.1.0/24 for AKS nodes
- **AKS Cluster**: 2-node cluster with Standard_DS2_v2 VMs
- **Network**: Azure CNI with Azure Network Policy

## Files

| File | Purpose |
|------|---------|
| `provider.tf` | Azure provider and backend configuration |
| `resource-group.tf` | Resource group definition |
| `vnet.tf` | Virtual network and subnet configuration |
| `aks.tf` | AKS cluster configuration |
| `variables.tf` | Variable declarations |
| `terraform.tfvars.dev` | Dev environment variable values |
| `outputs.tf` | Terraform outputs (cluster name, kubeconfig, etc.) |

## Prerequisites

1. **Azure CLI**: Installed and logged in
   ```bash
   az login
   az account set --subscription "64e6990e-3b3f-4118-a99a-8a77c4f4d968"
   ```

2. **Terraform**: Version 1.3.0 or higher
   ```bash
   terraform version
   ```

3. **Azure Backend**: Remote state storage must exist
    - Resource Group: `rg-terraform_remote_backend`
    - Storage Account: `remotebackendstoragetf`
    - Container: `terraform-remotebackendfiles`

## Quick Deploy

Use the deployment script:

```bash
cd ../scripts
./deploy-infrastructure.sh
```

## Manual Deployment

### Step 1: Initialize Terraform

```bash
terraform init \
  -backend-config="subscription_id=64e6990e-3b3f-4118-a99a-8a77c4f4d968" \
  -backend-config="resource_group_name=rg-terraform_remote_backend" \
  -backend-config="storage_account_name=remotebackendstoragetf" \
  -backend-config="container_name=terraform-remotebackendfiles" \
  -backend-config="key=KAFKA_AKS_DEV.tfstate" \
  -reconfigure
```

### Step 2: Validate Configuration

```bash
terraform validate
```

### Step 3: Plan Changes

```bash
terraform plan -var-file="terraform.tfvars.dev"
```

### Step 4: Apply Configuration

```bash
terraform apply -var-file="terraform.tfvars.dev" -auto-approve
```

### Step 5: Get AKS Credentials

```bash
az aks get-credentials \
  --resource-group rg-kafka-study-dev \
  --name aks-kafka-study-dev \
  --overwrite-existing
```

## Configuration

### Dev Environment Settings

```hcl
resource_group_name = "rg-kafka-study-dev"
location            = "eastus"
cluster_name        = "aks-kafka-study-dev"
node_count          = 2
node_vm_size        = "Standard_DS2_v2"
dns_prefix          = "kafka-study-dev"
subscription_id     = "64e6990e-3b3f-4118-a99a-8a77c4f4d968"
```

### Network Configuration

- **VNet CIDR**: 10.0.0.0/16
- **Subnet CIDR**: 10.0.1.0/24
- **Service CIDR**: 10.2.0.0/24
- **DNS Service IP**: 10.2.0.10
- **Network Plugin**: Azure CNI
- **Network Policy**: Azure

## Outputs

After successful deployment, Terraform outputs:

- `resource_group_name`: Name of the resource group
- `kubernetes_cluster_name`: Name of the AKS cluster
- `kubernetes_cluster_id`: Full Azure resource ID
- `kube_config`: Raw kubeconfig (sensitive)
- `client_certificate`: Client certificate for authentication (sensitive)
- `host`: AKS API server endpoint (sensitive)

View outputs:

```bash
terraform output
terraform output -json
```

## Verify Deployment

```bash
# Check cluster status
az aks show \
  --resource-group rg-kafka-study-dev \
  --name aks-kafka-study-dev

# Verify kubectl connection
kubectl cluster-info
kubectl get nodes
```

## Update Infrastructure

To modify the infrastructure:

1. Update variables in `terraform.tfvars.dev`
2. Run `terraform plan -var-file="terraform.tfvars.dev"`
3. Review changes
4. Run `terraform apply -var-file="terraform.tfvars.dev"`

## Destroy Infrastructure

⚠️ **Warning**: This will delete all resources including persistent data.

```bash
terraform destroy -var-file="terraform.tfvars.dev"
```

## State Management

- **Backend**: Azure Storage Account (Blob Container)
- **State File**: `KAFKA_AKS_DEV.tfstate`
- **Locking**: Enabled via Azure Storage
- **Encryption**: At rest via Azure Storage encryption

## Cost Estimation

Approximate monthly costs for dev environment:

- AKS Control Plane: Free
- 2x Standard_DS2_v2 VMs: ~$140/month
- Disk Storage: ~$10/month
- Network: ~$5/month
- **Total**: ~$155/month

*Costs are estimates and may vary based on usage and region.*

## Troubleshooting

### Issue: Terraform Init Fails

```bash
# Verify backend exists
az storage account show \
  --name remotebackendstoragetf \
  --resource-group rg-terraform_remote_backend
```

### Issue: Authentication Error

```bash
# Re-authenticate
az login
az account set --subscription "64e6990e-3b3f-4118-a99a-8a77c4f4d968"
```

### Issue: AKS Creation Fails

- Check Azure service quotas
- Verify subscription permissions
- Check region availability for VM size

### Issue: Cannot Connect to Cluster

```bash
# Get fresh credentials
az aks get-credentials \
  --resource-group rg-kafka-study-dev \
  --name aks-kafka-study-dev \
  --overwrite-existing

# Verify context
kubectl config current-context
```

## Best Practices

1. ✅ Always use remote state backend
2. ✅ Use workspace separation for environments
3. ✅ Run `terraform plan` before `apply`
4. ✅ Enable AKS monitoring and logging
5. ✅ Use managed identities (SystemAssigned)
6. ✅ Keep Terraform version consistent
7. ✅ Review cost implications before scaling

## Next Steps

After infrastructure is deployed:

1. Deploy Kubernetes applications: `cd ../scripts && ./deploy-application.sh`
2. Configure monitoring and alerting
3. Set up ingress controller (if needed)
4. Configure DNS (if using custom domain)

## Resources

- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure CNI Networking](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni)
