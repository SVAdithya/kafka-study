# Kafka Study - Deployment Guide

This document provides comprehensive instructions for deploying the Kafka Study application to Azure Kubernetes
Service (AKS) in the **dev** environment.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Manual Deployment](#manual-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)

## Architecture Overview

The deployment consists of:

- **Azure Kubernetes Service (AKS)** - Managed Kubernetes cluster
- **Application Pod** - Spring Boot application with Kafka and MongoDB integration
- **Kafka StatefulSet** - Apache Kafka broker
- **MongoDB StatefulSet** - MongoDB database with persistent storage
- **Persistent Volumes** - For Kafka and MongoDB data persistence

## Prerequisites

### Required Tools

- **Azure CLI** (v2.50+)
  ```bash
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  ```
- **Terraform** (v1.6.0+)
  ```bash
  brew install terraform  # macOS
  # or download from https://www.terraform.io/downloads
  ```
- **kubectl** (v1.28+)
  ```bash
  brew install kubectl  # macOS
  # or az aks install-cli
  ```
- **Maven** (v3.8+)
  ```bash
  brew install maven  # macOS
  ```
- **Docker** (v24+)
  ```bash
  # Install Docker Desktop for Mac/Windows
  # https://www.docker.com/products/docker-desktop
  ```

### Azure Setup

1. **Login to Azure**:
   ```bash
   az login
   ```

2. **Set subscription**:
   ```bash
   az account set --subscription "64e6990e-3b3f-4118-a99a-8a77c4f4d968"
   ```

3. **Verify Terraform backend exists**:
   ```bash
   az storage account show --name remotebackendstoragetf --resource-group rg-terraform_remote_backend
   ```

## Project Structure

```
deploy/
├── azr/                          # Azure infrastructure (Terraform)
│   ├── provider.tf               # Azure provider configuration
│   ├── resource-group.tf         # Resource group definition
│   ├── vnet.tf                   # Virtual network configuration
│   ├── aks.tf                    # AKS cluster configuration
│   ├── variables.tf              # Variable declarations
│   ├── terraform.tfvars.dev      # Dev environment variables
│   └── outputs.tf                # Terraform outputs
├── k8s/                          # Kubernetes manifests
│   ├── app-deployment.yaml       # Application deployment
│   ├── kafka-deployment.yaml     # Kafka StatefulSet
│   ├── mongodb-deployment.yaml   # MongoDB StatefulSet
│   └── kustomization.yaml        # Kustomize configuration for dev
└── scripts/                      # Deployment scripts
    ├── deploy-all.sh             # Complete deployment orchestration
    ├── deploy-infrastructure.sh  # AKS infrastructure deployment
    └── deploy-application.sh     # K8s application deployment
```

## Quick Start

Deploy everything with a single command:

```bash
cd deploy/scripts
./deploy-all.sh
```

This script will:

1. ✅ Check prerequisites
2. 🏗️ Build the Java application
3. 🐳 Build Docker image
4. ☁️ Deploy AKS infrastructure
5. 🚀 Deploy application to Kubernetes
6. ✔️ Verify deployment

## Manual Deployment

### Step 1: Build Application

```bash
# From project root
mvn clean package -DskipTests
```

### Step 2: Build Docker Image

```bash
docker build -t kafka-study-app:dev-latest .
```

### Step 3: Deploy Infrastructure

```bash
cd deploy/scripts
./deploy-infrastructure.sh
```

This will:

- Initialize Terraform with Azure remote backend
- Create AKS cluster with 2 nodes (Standard_DS2_v2)
- Configure virtual network and subnets
- Set up RBAC and system-assigned identity

### Step 4: Deploy Application

```bash
./deploy-application.sh
```

This will:

- Create `dev` namespace
- Deploy Kafka StatefulSet with persistent storage
- Deploy MongoDB StatefulSet with persistent storage
- Deploy the application with ConfigMaps and Secrets
- Wait for all pods to be ready

## CI/CD Pipeline

### GitHub Actions Workflow

The repository includes a complete CI/CD pipeline (`.github/workflows/deploy-dev.yml`) that runs on:

- Push to `main` or `develop` branches
- Manual trigger via workflow_dispatch

### Pipeline Stages

1. **Build and Test**
    - Checkout code
    - Set up Java 21
    - Run Maven tests
    - Build JAR artifact

2. **Build Docker Image**
    - Build Docker image
    - Push to Azure Container Registry
    - Tag with commit SHA and `dev-latest`

3. **Deploy Infrastructure**
    - Run Terraform to provision AKS
    - Idempotent - safe to run multiple times

4. **Deploy Application**
    - Apply Kubernetes manifests using Kustomize
    - Wait for pods to be ready

5. **Health Check**
    - Verify all pods are running
    - Display deployment status

### Required Secrets

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

```
AZURE_CREDENTIALS          # Service Principal JSON
AZURE_SUBSCRIPTION_ID      # Azure Subscription ID
ACR_NAME                   # Azure Container Registry name
ACR_LOGIN_SERVER           # ACR login server (e.g., myacr.azurecr.io)
ACR_USERNAME               # ACR username
ACR_PASSWORD               # ACR password
```

#### Create Azure Service Principal:

```bash
az ad sp create-for-rbac --name "kafka-study-github" \
  --role contributor \
  --scopes /subscriptions/64e6990e-3b3f-4118-a99a-8a77c4f4d968 \
  --sdk-auth
```

## Monitoring and Troubleshooting

### View Resources

```bash
# All resources in dev namespace
kubectl get all -n dev

# Pods with details
kubectl get pods -n dev -o wide

# Services
kubectl get svc -n dev

# Persistent Volume Claims
kubectl get pvc -n dev
```

### Check Pod Logs

```bash
# Application logs
kubectl logs -f deployment/dev-my-app -n dev

# Kafka logs
kubectl logs -f statefulset/dev-kafka-sfs -n dev

# MongoDB logs
kubectl logs -f statefulset/dev-mongodb-sfs -n dev
```

### Access Application

```bash
# Port forward to access locally
kubectl port-forward svc/dev-app 8080:8080 -n dev

# Then access at: http://localhost:8080
```

### Debug Pod Issues

```bash
# Describe pod
kubectl describe pod <pod-name> -n dev

# Get pod events
kubectl get events -n dev --sort-by='.lastTimestamp'

# Execute into pod
kubectl exec -it <pod-name> -n dev -- /bin/bash
```

### Check ConfigMaps and Secrets

```bash
# View ConfigMaps
kubectl get configmap -n dev
kubectl describe configmap dev-my-config -n dev

# View Secrets (decoded)
kubectl get secret dev-my-secret -n dev -o jsonpath='{.data.spring\.data\.mongodb\.uri}' | base64 -d
```

### Resource Utilization

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -n dev
```

### Clean Up

```bash
# Delete Kubernetes resources
kubectl delete namespace dev

# Destroy infrastructure
cd deploy/azr
terraform destroy -var-file="terraform.tfvars.dev"
```

## Configuration

### Environment Variables (Dev)

The dev environment uses the following configuration in `deploy/k8s/kustomization.yaml`:

- **Replicas**:
    - Application: 1
    - Kafka: 1
    - MongoDB: 1
- **Image**: `adithyasv/my-app:dev-latest`
- **Namespace**: `dev`
- **Resources**: No limits (for development flexibility)

### Kafka Configuration

- **Bootstrap Server**: `kafka-service.dev.svc.cluster.local:9092`
- **Partitions**: 3
- **Replication Factor**: 1
- **Storage**: 5Gi persistent volume

### MongoDB Configuration

- **Host**: `mongodb-service.dev.svc.cluster.local:27017`
- **Database**: `testMongoDb`
- **Credentials**: Stored in Kubernetes Secret
- **Storage**: 1Gi persistent volume

## Support

For issues or questions:

1. Check pod logs: `kubectl logs <pod-name> -n dev`
2. Review events: `kubectl get events -n dev`
3. Verify AKS cluster: `az aks show -g rg-kafka-study-dev -n aks-kafka-study-dev`

## Additional Resources

- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Kustomize Documentation](https://kustomize.io/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
