# 🚀 START HERE - Kafka Study Deployment Guide

Welcome! This is your **one-stop guide** to deploying the Kafka Study application to Azure Kubernetes Service (AKS).

## 📖 What You'll Find Here

This deployment setup includes **everything** you need to deploy a production-ready Kafka + Spring Boot + MongoDB
application to Azure AKS in the **dev environment**.

## ✨ What's Included

### 🏗️ Infrastructure as Code

- **Terraform configuration** for AKS cluster provisioning
- **Network setup** with VNet and subnets
- **Remote state management** with Azure Storage
- **Environment-specific** configurations (dev)

### 🎯 Kubernetes Configuration

- **Kustomize-based** deployment structure
- **StatefulSets** for Kafka and MongoDB with persistent storage
- **Deployments** for your Spring Boot application
- **ConfigMaps and Secrets** for configuration management

### 🤖 Automation Scripts

- **One-click deployment** script
- **Individual deployment** scripts for infrastructure and application
- **Pre-deployment validation** to check prerequisites
- **Rollback utility** for quick recovery

### 🔄 CI/CD Pipeline

- **GitHub Actions workflow** for automated deployments
- **Multi-stage pipeline** (build, test, deploy, verify)
- **Azure Container Registry** integration
- **Approval gates** for controlled deployments

### 📚 Comprehensive Documentation

- **Detailed deployment guides**
- **Quick reference** for common commands
- **Architecture diagrams** and flow charts
- **Troubleshooting guides**

## 🎯 Quick Start (3 Steps)

### Step 1: Validate Prerequisites

```bash
cd deploy/scripts
./pre-deploy-check.sh
```

This will check:

- ✅ Required tools (Azure CLI, Terraform, kubectl, Maven, Docker)
- ✅ Azure authentication
- ✅ Project files
- ✅ Network connectivity

### Step 2: Deploy Everything

```bash
./deploy-all.sh
```

This single command will:

1. Build your Java application
2. Create Docker image
3. Provision AKS cluster
4. Deploy Kafka, MongoDB, and your app
5. Verify deployment

**Time:** 15-20 minutes ⏱️

### Step 3: Verify and Access

```bash
# Check status
kubectl get all -n dev

# Port-forward to access locally
kubectl port-forward svc/dev-app 8080:8080 -n dev

# Access application
curl http://localhost:8080/actuator/health
```

## 📁 Documentation Structure

```
deploy/
├── START_HERE.md              ← You are here! 👋
├── README.md                  ← Complete deployment guide
├── QUICK_REFERENCE.md         ← Quick commands cheat sheet
├── DEPLOYMENT_SUMMARY.md      ← Architecture and component details
├── DEPLOYMENT_FLOW.md         ← Visual flow diagrams
└── SETUP_COMPLETE.md          ← What was created overview
```

### 📖 Reading Guide

| If you want to... | Read this document |
|-------------------|-------------------|
| Get started quickly | **START_HERE.md** (this file) |
| Understand architecture | [DEPLOYMENT_SUMMARY.md](./DEPLOYMENT_SUMMARY.md) |
| Follow detailed steps | [README.md](./README.md) |
| Find quick commands | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) |
| Visualize the flow | [DEPLOYMENT_FLOW.md](./DEPLOYMENT_FLOW.md) |
| See what was created | [SETUP_COMPLETE.md](./SETUP_COMPLETE.md) |
| Learn about infrastructure | [azr/README.MD](./azr/README.MD) |

## 🏗️ What Will Be Created

### Azure Resources

- **Resource Group**: `rg-kafka-study-dev` in East US
- **AKS Cluster**: 2-node cluster with Standard_DS2_v2 VMs
- **Virtual Network**: 10.0.0.0/16 with subnet 10.0.1.0/24
- **Load Balancer**: For external traffic
- **Managed Disks**: For persistent storage

### Kubernetes Resources (in `dev` namespace)

- **Application Deployment**: 1 replica of your Spring Boot app
- **Kafka StatefulSet**: 1 broker with 5Gi persistent storage
- **MongoDB StatefulSet**: 1 instance with 1Gi persistent storage
- **Services**: ClusterIP services for internal communication
- **ConfigMaps**: Application and service configurations
- **Secrets**: MongoDB credentials and connection strings

### Estimated Cost

💰 **~$175/month** for the dev environment

## 🎓 Deployment Options

### Option 1: One-Click Deployment (Recommended)

**Best for:** First-time deployment, complete setup

```bash
cd deploy/scripts
./deploy-all.sh
```

**Pros:**

- ✅ Everything automated
- ✅ Pre-flight checks included
- ✅ Post-deployment verification

**Cons:**

- ⚠️ Takes longer (~20 minutes)
- ⚠️ No granular control

### Option 2: Step-by-Step Deployment

**Best for:** Understanding the process, debugging issues

```bash
# Step 1: Build
mvn clean package -DskipTests
docker build -t kafka-study-app:dev-latest .

# Step 2: Infrastructure
cd deploy/scripts
./deploy-infrastructure.sh

# Step 3: Application
./deploy-application.sh
```

**Pros:**

- ✅ Granular control
- ✅ Easy to debug
- ✅ Can skip steps

**Cons:**

- ⚠️ More manual work
- ⚠️ Need to remember order

### Option 3: CI/CD Pipeline

**Best for:** Automated deployments, team collaboration

**Setup:**

1. Configure GitHub secrets
2. Push to `main` or `develop` branch
3. Pipeline automatically deploys

**Pros:**

- ✅ Fully automated
- ✅ Consistent deployments
- ✅ Built-in testing

**Cons:**

- ⚠️ Initial setup required
- ⚠️ Need Azure service principal

## 📋 Prerequisites Checklist

Before you start, ensure you have:

- [ ] **Azure Account** with active subscription
- [ ] **Azure CLI** installed and configured (`az login`)
- [ ] **Terraform** v1.3.0+ installed
- [ ] **kubectl** v1.28+ installed
- [ ] **Maven** v3.8+ installed
- [ ] **Docker** installed and running
- [ ] **Git** for version control
- [ ] **Sufficient Azure quotas** (2x Standard_DS2_v2 VMs)
- [ ] **Remote backend** storage account exists (see below)

### Azure Backend Setup

The Terraform remote backend must exist before deployment:

```bash
# Verify it exists
az storage account show \
  --name remotebackendstoragetf \
  --resource-group rg-terraform_remote_backend
```

If it doesn't exist, create it:

```bash
# Create resource group
az group create \
  --name rg-terraform_remote_backend \
  --location eastus

# Create storage account
az storage account create \
  --name remotebackendstoragetf \
  --resource-group rg-terraform_remote_backend \
  --location eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  --name terraform-remotebackendfiles \
  --account-name remotebackendstoragetf
```

## 🔍 What Happens During Deployment?

### Phase 1: Build (3-5 minutes)

1. Compile Java application with Maven
2. Run unit tests
3. Package into JAR file
4. Create Docker image

### Phase 2: Infrastructure (10-15 minutes)

1. Initialize Terraform
2. Validate configuration
3. Plan changes
4. Create Resource Group
5. Create Virtual Network
6. Provision AKS cluster (longest step)
7. Configure kubectl access

### Phase 3: Application (5-10 minutes)

1. Create Kubernetes namespace
2. Deploy MongoDB with persistent storage
3. Deploy Kafka with persistent storage
4. Deploy Spring Boot application
5. Wait for pods to be ready
6. Verify health

## 🎯 After Deployment

### Verify Everything Works

```bash
# 1. Check all resources
kubectl get all -n dev

# Expected output:
# - 1 app deployment (1/1 ready)
# - 1 kafka statefulset (1/1 ready)
# - 1 mongodb statefulset (1/1 ready)
# - 3 services
# - 3 pods (all running)

# 2. Check logs
kubectl logs -f deployment/dev-my-app -n dev

# 3. Port forward
kubectl port-forward svc/dev-app 8080:8080 -n dev

# 4. Test endpoints
curl http://localhost:8080/actuator/health
curl http://localhost:8080/actuator/info
```

### Common Next Steps

1. **Configure monitoring** (optional)
2. **Set up CI/CD pipeline** (recommended)
3. **Test Kafka producers/consumers**
4. **Verify MongoDB connectivity**
5. **Test application endpoints**
6. **Configure custom domain** (optional)

## 🆘 Troubleshooting

### Issue: Pre-deployment check fails

**Solution:** Install missing tools or fix configuration

```bash
# Run check again to see what's missing
./pre-deploy-check.sh
```

### Issue: Terraform fails

**Solution:** Check Azure permissions and backend

```bash
# Verify login
az login
az account show

# Check backend exists
az storage account show \
  --name remotebackendstoragetf \
  --resource-group rg-terraform_remote_backend
```

### Issue: Pods not starting

**Solution:** Check pod logs and events

```bash
kubectl describe pod <pod-name> -n dev
kubectl logs <pod-name> -n dev
kubectl get events -n dev --sort-by='.lastTimestamp'
```

### Issue: Can't access application

**Solution:** Verify port-forward and service

```bash
kubectl get svc -n dev
kubectl port-forward svc/dev-app 8080:8080 -n dev
```

## 🔄 Making Changes

### Update Application Code

```bash
# 1. Make code changes
# 2. Rebuild
mvn clean package -DskipTests
docker build -t kafka-study-app:dev-latest .

# 3. Redeploy
cd deploy/scripts
./deploy-application.sh
```

### Update Infrastructure

```bash
# 1. Edit Terraform files in deploy/azr/
# 2. Plan changes
cd deploy/azr
terraform plan -var-file="terraform.tfvars.dev"

# 3. Apply changes
terraform apply -var-file="terraform.tfvars.dev"
```

### Rollback Deployment

```bash
cd deploy/scripts
./rollback.sh
# Choose option 1 (rollback to previous revision)
```

## 🗑️ Cleanup

### Delete Everything (including data)

```bash
# Delete Kubernetes resources
kubectl delete namespace dev

# Destroy infrastructure
cd deploy/azr
terraform destroy -var-file="terraform.tfvars.dev"
```

**⚠️ Warning:** This will delete all data and cannot be undone!

## 💡 Tips & Best Practices

1. ✅ **Always run pre-deploy check** before deployment
2. ✅ **Review Terraform plan** before applying
3. ✅ **Check pod logs** if something fails
4. ✅ **Use rollback script** for quick recovery
5. ✅ **Monitor Azure costs** in the portal
6. ✅ **Destroy resources** when not in use
7. ✅ **Keep credentials secure** - never commit to Git
8. ✅ **Document customizations** for team members

## 📞 Getting Help

1. **Check documentation** in the `deploy/` folder
2. **Review logs**: `kubectl logs <pod-name> -n dev`
3. **Check events**: `kubectl get events -n dev`
4. **View Azure portal** for infrastructure issues
5. **Consult** [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) for common commands

## 🎉 Ready to Deploy?

Let's get started! Run these commands:

```bash
cd deploy/scripts
./pre-deploy-check.sh    # Validate prerequisites
./deploy-all.sh          # Deploy everything
```

---

**Good luck with your deployment!** 🚀

For detailed instructions, continue to → [README.md](./README.md)

For quick commands, jump to → [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
