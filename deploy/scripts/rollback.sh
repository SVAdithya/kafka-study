#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_warning "This script will rollback the application deployment in $ENVIRONMENT environment"
print_message "Infrastructure (AKS cluster) will NOT be affected"

# Verify kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    print_error "kubectl is not configured or cluster is not reachable"
    exit 1
fi

CURRENT_CONTEXT=$(kubectl config current-context)
print_message "Current kubectl context: $CURRENT_CONTEXT"

# Check if namespace exists
if ! kubectl get namespace $ENVIRONMENT &> /dev/null; then
    print_error "Namespace '$ENVIRONMENT' does not exist"
    exit 1
fi

echo ""
print_step "Current Deployment Status:"
kubectl get deployments -n $ENVIRONMENT

echo ""
print_warning "Choose rollback option:"
echo "1) Rollback to previous revision (recommended)"
echo "2) Rollback to specific revision"
echo "3) Delete all resources and redeploy clean"
echo "4) Cancel"

read -p "Enter choice (1-4): " CHOICE

case $CHOICE in
    1)
        print_message "Rolling back to previous revision..."
        
        # Rollback application deployment
        if kubectl get deployment dev-my-app -n $ENVIRONMENT &> /dev/null; then
            print_step "Rolling back application deployment..."
            kubectl rollout undo deployment/dev-my-app -n $ENVIRONMENT
            kubectl rollout status deployment/dev-my-app -n $ENVIRONMENT
        fi
        
        print_message "Rollback completed!"
        ;;
        
    2)
        print_step "Available revisions for application:"
        kubectl rollout history deployment/dev-my-app -n $ENVIRONMENT
        
        echo ""
        read -p "Enter revision number to rollback to: " REVISION
        
        print_message "Rolling back to revision $REVISION..."
        kubectl rollout undo deployment/dev-my-app -n $ENVIRONMENT --to-revision=$REVISION
        kubectl rollout status deployment/dev-my-app -n $ENVIRONMENT
        
        print_message "Rollback completed!"
        ;;
        
    3)
        print_warning "This will delete all resources in the $ENVIRONMENT namespace!"
        read -p "Are you sure? (yes/no): " CONFIRM
        
        if [ "$CONFIRM" != "yes" ]; then
            print_error "Operation cancelled"
            exit 1
        fi
        
        print_step "Deleting all resources in $ENVIRONMENT namespace..."
        kubectl delete all --all -n $ENVIRONMENT
        
        print_step "Deleting PVCs (persistent data will be lost)..."
        kubectl delete pvc --all -n $ENVIRONMENT
        
        print_message "All resources deleted. You can now redeploy clean."
        echo "Run: ./deploy-application.sh"
        ;;
        
    4)
        print_message "Operation cancelled"
        exit 0
        ;;
        
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_step "Current status after rollback:"
kubectl get all -n $ENVIRONMENT
