# Quick Reference Guide - Dev Environment

## 🚀 Quick Commands

### Deploy Everything

```bash
cd deploy/scripts
./deploy-all.sh
```

### Deploy Infrastructure Only

```bash
cd deploy/scripts
./deploy-infrastructure.sh
```

### Deploy Application Only

```bash
cd deploy/scripts
./deploy-application.sh
```

## 🔍 Monitoring

### View All Resources

```bash
kubectl get all -n dev
```

### Check Pod Status

```bash
kubectl get pods -n dev -o wide
```

### View Logs

```bash
# Application
kubectl logs -f deployment/dev-my-app -n dev

# Kafka
kubectl logs -f statefulset/dev-kafka-sfs -n dev

# MongoDB
kubectl logs -f statefulset/dev-mongodb-sfs -n dev
```

### Watch Pods (Real-time)

```bash
watch kubectl get pods -n dev
```

## 🔧 Access Services

### Port Forward Application

```bash
kubectl port-forward svc/dev-app 8080:8080 -n dev
# Access at: http://localhost:8080
```

### Port Forward Kafka

```bash
kubectl port-forward svc/dev-kafka-service 9092:9092 -n dev
```

### Port Forward MongoDB

```bash
kubectl port-forward svc/dev-mongodb-service 27017:27017 -n dev
```

## 🐛 Debugging

### Describe Pod

```bash
kubectl describe pod <pod-name> -n dev
```

### Get Events

```bash
kubectl get events -n dev --sort-by='.lastTimestamp'
```

### Execute Into Pod

```bash
kubectl exec -it <pod-name> -n dev -- /bin/bash
```

### Check Resource Usage

```bash
kubectl top nodes
kubectl top pods -n dev
```

## 📝 Configuration

### View ConfigMaps

```bash
kubectl get configmap -n dev
kubectl describe configmap dev-my-config -n dev
```

### View Secrets

```bash
kubectl get secrets -n dev
kubectl describe secret dev-my-secret -n dev
```

### Edit ConfigMap

```bash
kubectl edit configmap dev-my-config -n dev
```

## 🔄 Updates

### Rebuild and Redeploy Application

```bash
# Build
mvn clean package -DskipTests
docker build -t kafka-study-app:dev-latest .

# Redeploy
cd deploy/scripts
./deploy-application.sh
```

### Restart Deployment

```bash
kubectl rollout restart deployment/dev-my-app -n dev
```

### Check Rollout Status

```bash
kubectl rollout status deployment/dev-my-app -n dev
```

## 🗑️ Cleanup

### Delete Application (Keep Infrastructure)

```bash
kubectl delete namespace dev
```

### Delete Everything

```bash
# Delete namespace
kubectl delete namespace dev

# Destroy infrastructure
cd deploy/azr
terraform destroy -var-file="terraform.tfvars.dev"
```

## 🔐 Azure CLI

### Login

```bash
az login
az account set --subscription "64e6990e-3b3f-4118-a99a-8a77c4f4d968"
```

### Get AKS Credentials

```bash
az aks get-credentials \
  --resource-group rg-kafka-study-dev \
  --name aks-kafka-study-dev \
  --overwrite-existing
```

### View AKS Details

```bash
az aks show \
  --resource-group rg-kafka-study-dev \
  --name aks-kafka-study-dev
```

## 📊 Testing

### Test Kafka Connection

```bash
# From inside kafka pod
kubectl exec -it dev-kafka-sfs-0 -n dev -- /bin/bash

# List topics
kafka-topics.sh --list --bootstrap-server localhost:9092

# Create test topic
kafka-topics.sh --create --topic test --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

# Produce message
echo "test message" | kafka-console-producer.sh --broker-list localhost:9092 --topic test

# Consume message
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```

### Test MongoDB Connection

```bash
# From inside mongodb pod
kubectl exec -it dev-mongodb-sfs-0 -n dev -- mongosh -u root -p example --authenticationDatabase admin

# List databases
show dbs

# Use database
use testMongoDb

# Show collections
show collections
```

### Test Application Health

```bash
# After port-forward
curl http://localhost:8080/actuator/health
curl http://localhost:8080/actuator/info
```

## 🎯 Kustomize

### Preview Generated Manifests

```bash
kubectl kustomize deploy/k8s
```

### Apply with Kustomize

```bash
kubectl apply -k deploy/k8s
```

### Delete with Kustomize

```bash
kubectl delete -k deploy/k8s
```

## 📦 Persistent Volumes

### View PVCs

```bash
kubectl get pvc -n dev
```

### View PVs

```bash
kubectl get pv
```

### Describe PVC

```bash
kubectl describe pvc <pvc-name> -n dev
```

## 🔁 CI/CD

### Trigger GitHub Actions Manually

1. Go to GitHub repository
2. Click "Actions" tab
3. Select "Deploy to Dev Environment"
4. Click "Run workflow"

### View Workflow Status

```bash
# Using GitHub CLI
gh run list --workflow=deploy-dev.yml
gh run view <run-id>
```

## 💡 Tips

- Use `-w` flag for watching: `kubectl get pods -n dev -w`
- Use `--previous` to view previous container logs: `kubectl logs <pod> --previous -n dev`
- Use `-o yaml` for detailed output: `kubectl get pod <pod> -n dev -o yaml`
- Use `--dry-run=client` to preview changes: `kubectl apply -f file.yaml --dry-run=client`

## �� Emergency Commands

### Force Delete Pod

```bash
kubectl delete pod <pod-name> -n dev --grace-period=0 --force
```

### Drain Node (Before Maintenance)

```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

### Cordon Node (Prevent Scheduling)

```bash
kubectl cordon <node-name>
```

### Uncordon Node (Allow Scheduling)

```bash
kubectl uncordon <node-name>
```
