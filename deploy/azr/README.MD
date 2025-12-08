Step1: Files Used for AKS Cluster Deployment

The following Terraform files are involved in provisioning the AKS cluster:

    provider.tf – Configures the Azure provider
    resource-group.tf – Creates the required resource group
    vnet.tf – Configures the virtual network and subnets
    aks.tf – Defines the AKS cluster configuration
    variables.tf – Declares input variables
    terraform.tfvars – Contains variable values


Step2: Initialize Terraform Using Azure Remote Backend

The following command initializes Terraform and sets up the Azure Storage account - blob container backend where the Terraform state file will be stored.
It provides the necessary backend configuration parameters, including the subscription ID, resource group, storage account, container name, and the name of the remote state file.

terraform init `
  -backend-config="subscription_id=64e6990e-3b3f-4118-a99a-8a77c4f4d968" `
  -backend-config="resource_group_name=rg-terraform_remote_backend" `
  -backend-config="storage_account_name=remotebackendstoragetf" `
  -backend-config="container_name=terraform-remotebackendfiles" `
  -backend-config="key=KAFKA_AKS_Cluster.tfstate"


Step3: Executes the Terraform apply process and deploys the defined infrastructure resources.
The --auto-approve flag skips the interactive approval prompt, allowing the changes to be applied automatically.

terraform apply --auto-approve

