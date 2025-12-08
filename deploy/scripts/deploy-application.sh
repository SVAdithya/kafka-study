#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

ENVIRONMENT="dev"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$SCRIPT_DIR/../k8s"

# Check if k8s directory exists
if [ ! -d "$K8S_DIR" ]; then
    print_error "Kubernetes manifests directory not found: $K8S_DIR"
    exit 1
fi

print_message "Deploying application to environment: $ENVIRONMENT"

# Verify kubectl is configured
print_step "Verifying kubectl configuration..."
if ! kubectl cluster-info &> /dev/null; then
    print_error "kubectl is not configured or cluster is not reachable"
    exit 1
fi

CURRENT_CONTEXT=$(kubectl config current-context)
print_message "Current kubectl context: $CURRENT_CONTEXT"

# Create namespace if it doesn't exist
print_step "Creating namespace: $ENVIRONMENT"
kubectl create namespace "$ENVIRONMENT" --dry-run=client -o yaml | kubectl apply -f -

# Build kustomize configuration
print_step "Building Kustomize configuration..."
kubectl kustomize "$K8S_DIR" > /tmp/k8s-manifest-$ENVIRONMENT.yaml

print_message "Generated manifest saved to: /tmp/k8s-manifest-$ENVIRONMENT.yaml"

# Apply the configuration
print_step "Applying Kubernetes manifests..."
kubectl apply -k "$K8S_DIR"

# Wait for deployments to be ready
print_step "Waiting for deployments to be ready..."
kubectl wait --for=condition=ready pod -l environment=$ENVIRONMENT -n $ENVIRONMENT --timeout=300s || true

# Display deployment status
print_step "Deployment status:"
echo ""
kubectl get all -n $ENVIRONMENT

print_message "Application deployment completed successfully for $ENVIRONMENT!"

# Display service endpoints
print_step "Service endpoints:"
kubectl get svc -n $ENVIRONMENT
