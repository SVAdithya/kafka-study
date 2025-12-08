# Deployment Summary - Kafka Study Application

## 📋 Overview

This document provides a complete summary of the deployment setup for the Kafka Study application in the **dev**
environment on Azure Kubernetes Service (AKS).

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Azure Cloud                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │         AKS Cluster (aks-kafka-study-dev)         │  │
│  │                                                    │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │          Namespace: dev                     │  │  │
│  │  │                                             │  │  │
│  │  │  ┌──────────────┐  ┌──────────────┐       │  │  │
│  │  │  │ Application  │  │    Kafka     │       │  │  │
│  │  │  │  Deployment  │  │  StatefulSet │       │  │  │
│  │  │  │  (1 replica) │  │  (1 replica) │       │  │  │
│  │  │  └──────┬───────┘  └──────┬───────┘       │  │  │
│  │  │         │                  │               │  │  │
│  │  │         │                  │               │  │  │
│  │  │  ┌──────▼──────────────────▼───────┐      │  │  │
│  │  │  │         MongoDB                 │      │  │  │
│  │  │  │       StatefulSet               │      │  │  │
│  │  │  │       (1 replica)               │      │  │  │
│  │  │  └─────────────────────────────────┘      │  │  │
│  │  │                                             │  │  │
│  │  │  ┌─────────────┐  ┌─────────────┐         │  │  │
│  │  │  │   PVC       │  │   PVC       │         │  │  │
│  │  │  │   (Kafka)   │  │  (MongoDB)  │         │  │  │
│  │  │  │   5Gi       │  │   1Gi       │         │  │  │
│  │  │  └─────────────┘  └─────────────┘         │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │                                                    │  │
│  │  Network: 10.0.0.0/16                             │  │
│  │  Nodes: 2x Standard_DS2_v2                        │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## 📁 File Structure

```
kafka-study/
├── deploy/
│   ├── azr/                                    # Terraform IaC
│   │   ├── provider.tf                         # Azure provider config
│   │   ├── resource-group.tf                   # RG definition
│   │   ├── vnet.tf                             # Network setup
│   │   ├── aks.tf                              # AKS cluster
│   │   ├── variables.tf                        # Variable declarations
│   │   ├── terraform.tfvars.dev                # Dev environment values
│   │   ├── outputs.tf                          # Terraform outputs
│   │   └── README.MD                           # Infrastructure docs
│   │
│   ├── k8s/                                    # Kubernetes manifests
│   │   ├── app-deployment.yaml                 # Spring Boot app
│   │   ├── kafka-deployment.yaml               # Kafka broker
│   │   ├── mongodb-deployment.yaml             # MongoDB database
│   │   └── kustomization.yaml                  # Dev kustomize config
│   │
│   ├── scripts/                                # Deployment scripts
│   │   ├── deploy-all.sh                       # Full deployment
│   │   ├── deploy-infrastructure.sh            # AKS only
│   │   ├── deploy-application.sh               # K8s apps only
│   │   └── rollback.sh                         # Rollback utility
│   │
│   ├── README.md                               # Main deployment guide
│   ├── QUICK_REFERENCE.md                      # Quick commands
│   └── DEPLOYMENT_SUMMARY.md                   # This file
│
├── .github/
│   └── workflows/
│       └── deploy-dev.yml                      # CI/CD pipeline
│
├── Dockerfile                                  # Container image
├── pom.xml                                     # Maven config
└── src/                                        # Application source

```

## 🔧 Components

### Infrastructure (Terraform)

| Component | Configuration |
|-----------|--------------|
| **Resource Group** | `rg-kafka-study-dev` |
| **Region** | East US |
| **AKS Cluster** | `aks-kafka-study-dev` |
| **Kubernetes Version** | Latest stable |
| **Node Count** | 2 |
| **VM Size** | Standard_DS2_v2 (2 vCPU, 7GB RAM) |
| **Network Plugin** | Azure CNI |
| **Network Policy** | Azure |
| **RBAC** | Enabled |
| **Identity** | SystemAssigned |

### Kubernetes Resources

| Resource | Type | Replicas | Storage |
|----------|------|----------|---------|
| **Application** | Deployment | 1 | - |
| **Kafka** | StatefulSet | 1 | 5Gi PVC |
| **MongoDB** | StatefulSet | 1 | 1Gi PVC |

## 🚀 Deployment Methods

### Method 1: One-Click Deployment (Recommended for First Time)

```bash
cd deploy/scripts
./deploy-all.sh
```

**What it does:**

1. ✅ Checks prerequisites (az, terraform, kubectl, maven, docker)
2. 🏗️ Builds Java application with Maven
3. 🐳 Creates Docker image
4. ☁️ Provisions AKS infrastructure with Terraform
5. 🚀 Deploys applications to Kubernetes
6. ✔️ Verifies deployment status

**Duration:** ~15-20 minutes

### Method 2: Step-by-Step Deployment

#### Step 1: Build Application

```bash
mvn clean package -DskipTests
docker build -t kafka-study-app:dev-latest .
```

#### Step 2: Deploy Infrastructure

```bash
cd deploy/scripts
./deploy-infrastructure.sh
```

#### Step 3: Deploy Application

```bash
./deploy-application.sh
```

**Duration:** ~15-20 minutes

### Method 3: CI/CD Pipeline (GitHub Actions)

**Trigger:**

- Push to `main` or `develop` branch
- Manual trigger via GitHub Actions UI

**Pipeline Stages:**

1. Build and Test (Maven)
2. Build Docker Image (Push to ACR)
3. Deploy Infrastructure (Terraform)
4. Deploy Application (Kubectl + Kustomize)
5. Health Check

**Duration:** ~20-25 minutes

## 📊 Resource Specifications

### Dev Environment

```yaml
Application:
  replicas: 1
  image: adithyasv/my-app:dev-latest
  imagePullPolicy: Always
  resources: null  # No limits for dev

Kafka:
  replicas: 1
  image: apache/kafka:latest
  storage: 5Gi
  partitions: 3
  replicationFactor: 1

MongoDB:
  replicas: 1
  image: mongo:latest
  storage: 1Gi
  resources:
    requests:
      memory: 500Mi
      cpu: 250m
    limits:
      memory: 2Gi
      cpu: 500m
```

## 🔐 Secrets and ConfigMaps

### ConfigMaps

- `dev-my-config`: Application configuration
- `dev-kafka-config`: Kafka broker settings
- `dev-env-config`: Environment variables

### Secrets

- `dev-my-secret`: MongoDB connection string
- `dev-mongo-secret`: MongoDB credentials (root/example)

## 🌐 Network Configuration

```yaml
Virtual Network: 10.0.0.0/16
AKS Subnet: 10.0.1.0/24
Service CIDR: 10.2.0.0/24
DNS Service IP: 10.2.0.10

Internal Services:
  - kafka-service.dev.svc.cluster.local:9092
  - mongodb-service.dev.svc.cluster.local:27017
  - app.dev.svc.cluster.local:8080
```

## ✅ Pre-Deployment Checklist

- [ ] Azure CLI installed and configured
- [ ] Terraform installed (v1.3.0+)
- [ ] kubectl installed (v1.28+)
- [ ] Maven installed (v3.8+)
- [ ] Docker installed and running
- [ ] Azure subscription access verified
- [ ] Remote backend storage exists
- [ ] Sufficient Azure quotas (2x DS2_v2 VMs)

## 🎯 Post-Deployment Verification

```bash
# 1. Check AKS cluster
az aks show -g rg-kafka-study-dev -n aks-kafka-study-dev

# 2. Verify kubectl connection
kubectl cluster-info

# 3. Check all resources
kubectl get all -n dev

# 4. Verify pods are running
kubectl get pods -n dev

# 5. Check PVCs
kubectl get pvc -n dev

# 6. View application logs
kubectl logs -f deployment/dev-my-app -n dev

# 7. Port-forward and test
kubectl port-forward svc/dev-app 8080:8080 -n dev
curl http://localhost:8080/actuator/health
```

## 📈 Monitoring Points

### Health Endpoints (After Port-Forward)

- Application: `http://localhost:8080/actuator/health`
- Metrics: `http://localhost:8080/actuator/prometheus`
- Info: `http://localhost:8080/actuator/info`

### Key Metrics to Monitor

- Pod CPU/Memory usage: `kubectl top pods -n dev`
- Node health: `kubectl get nodes`
- PVC status: `kubectl get pvc -n dev`
- Events: `kubectl get events -n dev --sort-by='.lastTimestamp'`

## 🔄 Update Strategy

### Application Update

```bash
# 1. Build new version
mvn clean package -DskipTests
docker build -t kafka-study-app:dev-latest .

# 2. Update image tag in kustomization.yaml
# 3. Apply changes
kubectl apply -k deploy/k8s/overlays/dev

# 4. Monitor rollout
kubectl rollout status deployment/dev-my-app -n dev
```

### Rollback

```bash
cd deploy/scripts
./rollback.sh
```

## 🗑️ Cleanup

### Delete Application Only

```bash
kubectl delete namespace dev
```

### Delete Everything

```bash
# Delete K8s resources
kubectl delete namespace dev

# Destroy infrastructure
cd deploy/azr
terraform destroy -var-file="terraform.tfvars.dev"
```

## 💰 Cost Breakdown (Estimated)

| Resource | Monthly Cost (USD) |
|----------|-------------------|
| AKS Control Plane | Free |
| 2x Standard_DS2_v2 VMs | ~$140 |
| Managed Disks (30GB) | ~$10 |
| Load Balancer | ~$20 |
| Network Traffic | ~$5 |
| **Total** | **~$175** |

*Note: Costs vary by region and usage*

## 🔍 Troubleshooting Guide

### Pod Not Starting

```bash
kubectl describe pod <pod-name> -n dev
kubectl logs <pod-name> -n dev
```

### Deployment Failures

```bash
kubectl rollout status deployment/dev-my-app -n dev
kubectl get events -n dev --sort-by='.lastTimestamp'
```

### Network Issues

```bash
kubectl get svc -n dev
kubectl get endpoints -n dev
```

### Storage Issues

```bash
kubectl get pvc -n dev
kubectl describe pvc <pvc-name> -n dev
```

## 📞 Support Contacts

| Issue Type | Resource |
|------------|----------|
| Infrastructure | Check Terraform logs, Azure Portal |
| Application | Review pod logs, check app configuration |
| Network | Verify service endpoints, DNS resolution |
| Storage | Check PVC status, node storage capacity |

## 🔗 Important Links

- [Main Deployment Guide](./README.md)
- [Quick Reference](./QUICK_REFERENCE.md)
- [Infrastructure Details](./azr/README.MD)
- [GitHub Actions Workflow](../.github/workflows/deploy-dev.yml)

## 📝 Notes

- This is a **dev environment** - not production-ready
- Single replica for all services (no high availability)
- No resource limits on application (for development flexibility)
- Persistent data will be lost if PVCs are deleted
- Always run `terraform plan` before `apply`
- Keep credentials secure and never commit to Git

## ✨ Next Steps

After successful deployment:

1. ✅ Configure application logging
2. ✅ Set up monitoring and alerting
3. ✅ Test Kafka producers/consumers
4. ✅ Verify MongoDB connectivity
5. ✅ Test application endpoints
6. ✅ Document any custom configurations
7. ✅ Set up CI/CD pipeline with GitHub secrets

---

**Last Updated:** December 2024  
**Maintained By:** DevOps Team  
**Environment:** Development Only
