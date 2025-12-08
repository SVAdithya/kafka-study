# Configuration Guide - Service URLs & Versioning

## ✅ Your Questions Answered

### 1. How does the application know Kafka & MongoDB URLs?

**Answer**: Through **Kubernetes Service Discovery** using DNS! No Terraform configuration needed.

### How It Works

```
Your Application Pod
        ↓
  Uses DNS lookup
        ↓
Kubernetes CoreDNS resolves:
  kafka-service.dev.svc.cluster.local → 10.2.0.50:9092
  mongodb-service.dev.svc.cluster.local → 10.2.0.51:27017
        ↓
  Connects to services
```

### Where It's Configured

**File**: `deploy/k8s/app-deployment.yaml`

```yaml
# ConfigMap - Kafka URL
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  spring.kafka.consumer.bootstrap-servers: kafka-service.dev.svc.cluster.local:9092
  spring.kafka.producer.bootstrap-servers: kafka-service.dev.svc.cluster.local:9092

---
# Secret - MongoDB URL
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
stringData:
  spring.data.mongodb.uri: "mongodb://root:example@mongodb-service.dev.svc.cluster.local:27017/testMongoDb?authSource=admin"
```

### DNS Pattern

```
Format: <service-name>.<namespace>.svc.cluster.local:<port>

Examples:
├── kafka-service.dev.svc.cluster.local:9092
├── mongodb-service.dev.svc.cluster.local:27017
└── app.dev.svc.cluster.local:8080
```

### Why No Terraform?

Kubernetes **automatically** provides DNS resolution for all Services. When you create:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kafka-service
  namespace: dev
```

Kubernetes automatically registers:

- `kafka-service` (short form - same namespace)
- `kafka-service.dev` (namespace included)
- `kafka-service.dev.svc` (service domain)
- `kafka-service.dev.svc.cluster.local` (full FQDN)

### How Your App Gets These Values

**Method 1: Environment Variables from ConfigMap**

```yaml
spec:
  containers:
    - name: app
      envFrom:
        - configMapRef:
            name: my-config  # All keys become env vars
```

**Method 2: Environment Variables from Secret**

```yaml
spec:
  containers:
    - name: app
      envFrom:
        - secretRef:
            name: my-secret  # All keys become env vars
```

**Method 3: Specific Environment Variables**

```yaml
spec:
  containers:
    - name: app
      env:
        - name: KAFKA_BOOTSTRAP_SERVERS
          value: "kafka-service.dev.svc.cluster.local:9092"
        - name: MONGODB_URI
          valueFrom:
            secretKeyRef:
              name: my-secret
              key: spring.data.mongodb.uri
```

## 2. Application Versioning

**Answer**: Automated versioning with `version.sh` script!

### Version Management System

```
.version file (1.0.0)
        ↓
Automatically updates:
├── pom.xml → <version>1.0.0</version>
├── kustomization.yaml → image: adithyasv/my-app:1.0.0
├── app-deployment.yaml → APP_VERSION: "1.0.0"
└── Kubernetes labels → app.kubernetes.io/version: "1.0.0"
```

### Usage

```bash
# View current version
cat .version

# Bump patch version (1.0.0 → 1.0.1)
./deploy/scripts/version.sh patch

# Bump minor version (1.0.1 → 1.1.0)
./deploy/scripts/version.sh minor

# Bump major version (1.1.0 → 2.0.0)
./deploy/scripts/version.sh major
```

### Full Deployment with New Version

```bash
# 1. Bump version
./deploy/scripts/version.sh patch

# 2. Build application
mvn clean package -DskipTests

# 3. Build Docker image with new version
VERSION=$(cat .version)
docker build -t adithyasv/my-app:$VERSION .
docker tag adithyasv/my-app:$VERSION adithyasv/my-app:latest

# 4. Push to registry (if using Docker Hub/ACR)
docker push adithyasv/my-app:$VERSION
docker push adithyasv/my-app:latest

# 5. Deploy
cd deploy/scripts
./deploy-application.sh

# 6. Verify version
kubectl get deployment dev-my-app -n dev -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## 📊 Complete Configuration Overview

### Service Discovery Configuration

| Component | ConfigMap/Secret | Key | Value |
|-----------|-----------------|-----|-------|
| **Kafka URL** | ConfigMap: my-config | spring.kafka.consumer.bootstrap-servers | kafka-service.dev.svc.cluster.local:9092 |
| **Kafka Producer** | ConfigMap: my-config | spring.kafka.producer.bootstrap-servers | kafka-service.dev.svc.cluster.local:9092 |
| **MongoDB URL** | Secret: my-secret | spring.data.mongodb.uri | mongodb://root:example@mongodb-service.dev.svc.cluster.local:27017/testMongoDb |
| **Kafka Topic** | ConfigMap: my-config | kafka.regular.topic | my-topic |
| **Consumer Group** | ConfigMap: my-config | spring.kafka.consumer.group-id | demo-3 |

### Application Configuration

| Setting | Source | Value |
|---------|--------|-------|
| **Version** | .version file | 1.0.0 |
| **Image** | Docker registry | adithyasv/my-app:1.0.0 |
| **Replicas** | kustomization.yaml | 1 |
| **Namespace** | kustomization.yaml | dev |
| **Port** | app-deployment.yaml | 8080 |
| **Memory Request** | app-deployment.yaml | 512Mi |
| **Memory Limit** | app-deployment.yaml | 1Gi |
| **CPU Request** | app-deployment.yaml | 250m |
| **CPU Limit** | app-deployment.yaml | 500m |

## 🎯 Key Configuration Files

### 1. Service URLs: `deploy/k8s/app-deployment.yaml`

```yaml
# Kafka Configuration
spring.kafka.consumer.bootstrap-servers: kafka-service.dev.svc.cluster.local:9092
spring.kafka.producer.bootstrap-servers: kafka-service.dev.svc.cluster.local:9092

# MongoDB Configuration
spring.data.mongodb.uri: "mongodb://root:example@mongodb-service.dev.svc.cluster.local:27017/testMongoDb"
```

### 2. Versioning: `.version`

```
1.0.0
```

### 3. Image Version: `deploy/k8s/kustomization.yaml`

```yaml
patches:
  - target:
      kind: Deployment
      name: my-app
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/image
        value: adithyasv/my-app:1.0.0
```

### 4. Maven Version: `pom.xml`

```xml
<version>1.0.0</version>
```

## 🔧 Configuration Changes

### Change Kafka URL

Edit `deploy/k8s/app-deployment.yaml`:

```yaml
data:
  spring.kafka.consumer.bootstrap-servers: new-kafka-service.dev.svc.cluster.local:9092
```

Then apply:

```bash
kubectl apply -k deploy/k8s
```

### Change MongoDB URL

Edit `deploy/k8s/app-deployment.yaml`:

```yaml
stringData:
  spring.data.mongodb.uri: "mongodb://user:pass@new-mongodb-service.dev.svc.cluster.local:27017/db"
```

Then apply:

```bash
kubectl apply -k deploy/k8s
kubectl rollout restart deployment/dev-my-app -n dev
```

### Change Application Version

```bash
# Use version script
./deploy/scripts/version.sh patch

# Or manually edit .version file
echo "1.0.1" > .version

# Then rebuild and redeploy
mvn clean package -DskipTests
docker build -t adithyasv/my-app:$(cat .version) .
cd deploy/scripts
./deploy-application.sh
```

## 🧪 Verify Configuration

### Check Service URLs in Pod

```bash
# Get pod name
POD=$(kubectl get pod -n dev -l app=my-app -o jsonpath='{.items[0].metadata.name}')

# Check environment variables
kubectl exec -it $POD -n dev -- env | grep -E "(KAFKA|MONGODB)"

# Expected output:
# spring.kafka.consumer.bootstrap-servers=kafka-service.dev.svc.cluster.local:9092
# spring.data.mongodb.uri=mongodb://root:example@mongodb-service.dev.svc.cluster.local:27017/testMongoDb
```

### Test DNS Resolution

```bash
# From your app pod
kubectl exec -it $POD -n dev -- nslookup kafka-service.dev.svc.cluster.local
kubectl exec -it $POD -n dev -- nslookup mongodb-service.dev.svc.cluster.local

# Should return IP addresses like:
# Name:   kafka-service.dev.svc.cluster.local
# Address: 10.2.0.50
```

### Check Current Version

```bash
# From version file
cat .version

# From deployment
kubectl get deployment dev-my-app -n dev -o jsonpath='{.spec.template.spec.containers[0].image}'

# From pod labels
kubectl get pod -n dev -l app=my-app -o jsonpath='{.items[0].metadata.labels.app\.kubernetes\.io/version}'

# From environment variable in pod
kubectl exec -it $POD -n dev -- env | grep APP_VERSION
```

## 🚀 Quick Start Checklist

- [x] Service URLs configured in ConfigMap/Secret
- [x] DNS-based service discovery enabled
- [x] Version file created (.version)
- [x] Version script created (version.sh)
- [x] Health checks configured (liveness/readiness probes)
- [x] Resource limits defined
- [x] Environment variables properly injected

## 📚 Related Documentation

- **Service Discovery Details**: [SERVICE_DISCOVERY_AND_VERSIONING.md](./SERVICE_DISCOVERY_AND_VERSIONING.md)
- **Deployment Guide**: [README.md](./README.md)
- **Quick Commands**: [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)

## 💡 Pro Tips

1. ✅ **Always use full DNS names** (with namespace) for clarity
2. ✅ **Store credentials in Secrets**, not ConfigMaps
3. ✅ **Bump version before each deployment**
4. ✅ **Tag Docker images with version numbers**
5. ✅ **Test service connectivity** after changes
6. ✅ **Use ConfigMaps for non-sensitive config**
7. ✅ **Keep .version file in git**
8. ✅ **Document version changes** in commits

---

**Summary:**

- ✅ Service URLs use **Kubernetes DNS** (automatic)
- ✅ Configured in **ConfigMaps and Secrets**
- ✅ Versioning managed by **version.sh script**
- ✅ All files updated **automatically**
- ✅ No Terraform needed for service discovery

🚀 You're all set!
