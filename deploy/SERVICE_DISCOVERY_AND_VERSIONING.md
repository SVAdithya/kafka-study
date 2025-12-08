# Service Discovery and Versioning Guide

## 🌐 Service Discovery in Kubernetes

### How Services Find Each Other

Your application automatically discovers Kafka and MongoDB using **Kubernetes DNS**. No hardcoded IPs needed!

### Kubernetes DNS Pattern

```
<service-name>.<namespace>.svc.cluster.local:<port>
```

### Current Configuration

#### 1. Kafka Service Discovery

**Service Name**: `kafka-service`  
**Namespace**: `dev`  
**Port**: `9092`  
**Full DNS**: `kafka-service.dev.svc.cluster.local:9092`

**Configured in** `deploy/k8s/app-deployment.yaml`:

```yaml
spring.kafka.consumer.bootstrap-servers: kafka-service.dev.svc.cluster.local:9092
spring.kafka.producer.bootstrap-servers: kafka-service.dev.svc.cluster.local:9092
```

#### 2. MongoDB Service Discovery

**Service Name**: `mongodb-service`  
**Namespace**: `dev`  
**Port**: `27017`  
**Full DNS**: `mongodb-service.dev.svc.cluster.local:27017`

**Configured in** `deploy/k8s/app-deployment.yaml`:

```yaml
spring.data.mongodb.uri: "mongodb://root:example@mongodb-service.dev.svc.cluster.local:27017/testMongoDb?authSource=admin"
```

### How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                    │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │          Namespace: dev                         │    │
│  │                                                 │    │
│  │  ┌──────────────┐                              │    │
│  │  │  Your App    │                              │    │
│  │  │  Pod         │                              │    │
│  │  └──────┬───────┘                              │    │
│  │         │                                       │    │
│  │         │ Looks up DNS:                         │    │
│  │         │ "kafka-service.dev.svc.cluster.local" │    │
│  │         │                                       │    │
│  │         ▼                                       │    │
│  │  ┌──────────────┐     ┌────────────────┐      │    │
│  │  │ CoreDNS      │────▶│ kafka-service  │      │    │
│  │  │ (DNS Server) │     │ ClusterIP:     │      │    │
│  │  └──────────────┘     │ 10.2.0.50:9092 │      │    │
│  │                       └────────┬────────┘      │    │
│  │                                │               │    │
│  │                                ▼               │    │
│  │                       ┌────────────────┐       │    │
│  │                       │  Kafka Pod     │       │    │
│  │                       │  10.0.1.15     │       │    │
│  │                       └────────────────┘       │    │
│  └──────────��──────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### Configuration Files

All service URLs are configured in these places:

1. **ConfigMap** (`deploy/k8s/app-deployment.yaml`):
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: my-config
   data:
     spring.kafka.consumer.bootstrap-servers: kafka-service.dev.svc.cluster.local:9092
   ```

2. **Secret** (`deploy/k8s/app-deployment.yaml`):
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: my-secret
   stringData:
     spring.data.mongodb.uri: "mongodb://root:example@mongodb-service.dev.svc.cluster.local:27017/testMongoDb?authSource=admin"
   ```

3. **Environment Variables** (Deployment):
   ```yaml
   env:
     - name: KAFKA_BOOTSTRAP_SERVERS
       value: "kafka-service.dev.svc.cluster.local:9092"
     - name: MONGODB_URI
       valueFrom:
         secretKeyRef:
           name: my-secret
           key: spring.data.mongodb.uri
   ```

### Testing Service Discovery

```bash
# Get into your application pod
kubectl exec -it dev-my-app-<pod-id> -n dev -- /bin/bash

# Test DNS resolution
nslookup kafka-service.dev.svc.cluster.local
nslookup mongodb-service.dev.svc.cluster.local

# Test connectivity
curl -v telnet://kafka-service.dev.svc.cluster.local:9092
curl -v telnet://mongodb-service.dev.svc.cluster.local:27017
```

## 📦 Application Versioning

### Version Management

We use **semantic versioning**: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Current Version System

Version is tracked in multiple places:

1. `.version` file (source of truth)
2. `pom.xml` (Maven version)
3. `deploy/k8s/kustomization.yaml` (Docker image tag)
4. `deploy/k8s/app-deployment.yaml` (APP_VERSION env var)
5. Kubernetes labels and annotations

### Using the Version Script

#### 1. Bump Version

```bash
# Increment patch version (1.0.0 → 1.0.1)
./deploy/scripts/version.sh patch

# Increment minor version (1.0.1 → 1.1.0)
./deploy/scripts/version.sh minor

# Increment major version (1.1.0 → 2.0.0)
./deploy/scripts/version.sh major
```

#### 2. What Gets Updated

The script automatically updates:

- ✅ `.version` file
- ✅ `pom.xml` version tag
- ✅ `deploy/k8s/kustomization.yaml` image tag
- ✅ `deploy/k8s/app-deployment.yaml` APP_VERSION env var
- ✅ Kubernetes labels

#### 3. Build and Deploy with New Version

```bash
# Step 1: Bump version
./deploy/scripts/version.sh patch

# Step 2: Build application
mvn clean package -DskipTests

# Step 3: Build Docker image with version tag
VERSION=$(cat .version)
docker build -t adithyasv/my-app:$VERSION .
docker tag adithyasv/my-app:$VERSION adithyasv/my-app:latest

# Step 4: Push to registry (if using Docker Hub)
docker push adithyasv/my-app:$VERSION
docker push adithyasv/my-app:latest

# Step 5: Deploy
cd deploy/scripts
./deploy-application.sh
```

### Versioning in CI/CD

The GitHub Actions pipeline automatically handles versioning:

```yaml
# .github/workflows/deploy-dev.yml
- name: Get version
  run: echo "VERSION=$(cat .version)" >> $GITHUB_ENV

- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    tags: |
      ${{ secrets.ACR_LOGIN_SERVER }}/kafka-study-app:${{ env.VERSION }}
      ${{ secrets.ACR_LOGIN_SERVER }}/kafka-study-app:${{ github.sha }}
      ${{ secrets.ACR_LOGIN_SERVER }}/kafka-study-app:dev-latest
```

### View Current Version

```bash
# From version file
cat .version

# From deployed pods
kubectl get pods -n dev -o jsonpath='{.items[0].metadata.labels.app\.kubernetes\.io/version}'

# From deployment annotations
kubectl get deployment dev-my-app -n dev -o jsonpath='{.spec.template.metadata.annotations.app\.version}'

# From environment variable in pod
kubectl exec -it dev-my-app-<pod-id> -n dev -- env | grep APP_VERSION
```

### Rollback to Previous Version

```bash
# Using rollback script
cd deploy/scripts
./rollback.sh

# Or manually specify version
kubectl set image deployment/dev-my-app app=adithyasv/my-app:1.0.0 -n dev

# Or rollback to previous revision
kubectl rollout undo deployment/dev-my-app -n dev
```

### Version History

```bash
# View deployment history
kubectl rollout history deployment/dev-my-app -n dev

# View specific revision
kubectl rollout history deployment/dev-my-app -n dev --revision=2
```

## 🔄 Complete Versioned Deployment Workflow

### Manual Workflow

```bash
# 1. Bump version
./deploy/scripts/version.sh patch

# 2. View changes
git diff

# 3. Build and test
mvn clean test
mvn package -DskipTests

# 4. Build Docker image
VERSION=$(cat .version)
docker build -t adithyasv/my-app:$VERSION .

# 5. Push to registry
docker push adithyasv/my-app:$VERSION

# 6. Deploy to cluster
cd deploy/scripts
./deploy-application.sh

# 7. Verify deployment
kubectl get deployment dev-my-app -n dev -o yaml | grep image:

# 8. Commit version bump
git add .version pom.xml deploy/k8s/*.yaml
git commit -m "Bump version to $VERSION"
git push
```

### CI/CD Workflow

```bash
# 1. Bump version locally
./deploy/scripts/version.sh patch

# 2. Commit and push
VERSION=$(cat .version)
git add .version pom.xml deploy/k8s/*.yaml
git commit -m "Bump version to $VERSION"
git push origin main

# 3. GitHub Actions automatically:
#    - Builds application
#    - Creates Docker image with version tag
#    - Pushes to ACR
#    - Deploys to AKS
#    - Verifies deployment
```

## 📊 Service Discovery Configuration Summary

| Component | Service Name | Namespace | Port | Full DNS |
|-----------|-------------|-----------|------|----------|
| **Kafka** | kafka-service | dev | 9092 | kafka-service.dev.svc.cluster.local:9092 |
| **MongoDB** | mongodb-service | dev | 27017 | mongodb-service.dev.svc.cluster.local:27017 |
| **Application** | app | dev | 8080 | app.dev.svc.cluster.local:8080 |

## 🔐 Environment Variables Injected into Application

```yaml
# From ConfigMap (my-config)
kafka.regular.topic: my-topic
spring.kafka.consumer.bootstrap-servers: kafka-service.dev.svc.cluster.local:9092
spring.kafka.consumer.group-id: demo-3

# From Secret (my-secret)
spring.data.mongodb.uri: mongodb://root:example@mongodb-service.dev.svc.cluster.local:27017/testMongoDb

# Additional Environment Variables
APP_VERSION: "1.0.0"
ENVIRONMENT: "dev"
KAFKA_BOOTSTRAP_SERVERS: kafka-service.dev.svc.cluster.local:9092
MONGODB_URI: <from-secret>
```

## 🧪 Testing

### Test Service Discovery

```bash
# Deploy everything
cd deploy/scripts
./deploy-all.sh

# Get pod name
POD=$(kubectl get pod -n dev -l app=my-app -o jsonpath='{.items[0].metadata.name}')

# Test DNS resolution
kubectl exec -it $POD -n dev -- nslookup kafka-service.dev.svc.cluster.local
kubectl exec -it $POD -n dev -- nslookup mongodb-service.dev.svc.cluster.local

# Check environment variables
kubectl exec -it $POD -n dev -- env | grep -E "(KAFKA|MONGODB|VERSION)"
```

### Test Versioning

```bash
# Bump version
./deploy/scripts/version.sh patch

# Check version was updated
cat .version
grep "<version>" pom.xml
grep "app.kubernetes.io/version" deploy/k8s/kustomization.yaml

# Deploy and verify
cd deploy/scripts
./deploy-application.sh

kubectl get deployment dev-my-app -n dev -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## 💡 Best Practices

1. ✅ **Always use DNS names**, never hardcode IPs
2. ✅ **Use ConfigMaps** for non-sensitive configuration
3. ✅ **Use Secrets** for credentials and sensitive data
4. ✅ **Bump version** before each deployment
5. ✅ **Tag Docker images** with version numbers
6. ✅ **Keep version.sh** updated in version control
7. ✅ **Test service connectivity** after deployment
8. ✅ **Document breaking changes** in major version bumps

## 🆘 Troubleshooting

### Service Not Found

```bash
# Check if service exists
kubectl get svc -n dev

# Check DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -n dev -- nslookup kafka-service.dev.svc.cluster.local
```

### Connection Refused

```bash
# Check if pods are running
kubectl get pods -n dev

# Check service endpoints
kubectl get endpoints -n dev

# Check logs
kubectl logs -f dev-kafka-sfs-0 -n dev
```

### Wrong Version Deployed

```bash
# Check current image
kubectl get deployment dev-my-app -n dev -o jsonpath='{.spec.template.spec.containers[0].image}'

# Rollback to previous version
kubectl rollout undo deployment/dev-my-app -n dev

# Or set specific version
kubectl set image deployment/dev-my-app app=adithyasv/my-app:1.0.0 -n dev
```

---

**Now your services can find each other automatically, and you have full version control!** 🚀
