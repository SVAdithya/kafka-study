#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}================================${NC}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

print_header "Kafka Study - Dev Environment Deployment"

# Check prerequisites
print_step "Checking prerequisites..."

command -v az >/dev/null 2>&1 || { print_error "Azure CLI is required but not installed. Aborting."; exit 1; }
command -v terraform >/dev/null 2>&1 || { print_error "Terraform is required but not installed. Aborting."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { print_error "kubectl is required but not installed. Aborting."; exit 1; }
command -v mvn >/dev/null 2>&1 || { print_error "Maven is required but not installed. Aborting."; exit 1; }
command -v docker >/dev/null 2>&1 || { print_error "Docker is required but not installed. Aborting."; exit 1; }

print_message "All prerequisites are installed."

# Step 1: Build Application
print_header "Step 1: Building Application"
cd "$PROJECT_ROOT"
print_message "Running Maven build..."
mvn clean package -DskipTests

if [ ! -f "target/kafkaStudy-0.0.1-SNAPSHOT.jar" ]; then
    print_error "Build failed: JAR file not found"
    exit 1
fi
print_message "Application built successfully!"

# Step 2: Build Docker Image
print_header "Step 2: Building Docker Image"
print_message "Building Docker image..."
docker build -t kafka-study-app:dev-latest .
print_message "Docker image built successfully!"

# Step 3: Deploy Infrastructure
print_header "Step 3: Deploying AKS Infrastructure"
print_warning "This will create Azure resources which may incur costs."
read -p "Do you want to continue? (yes/no): " CONTINUE

if [ "$CONTINUE" != "yes" ]; then
    print_error "Deployment cancelled."
    exit 1
fi

bash "$SCRIPT_DIR/deploy-infrastructure.sh"

# Step 4: Deploy Application
print_header "Step 4: Deploying Application to AKS"
bash "$SCRIPT_DIR/deploy-application.sh"

# Step 5: Post-deployment checks
print_header "Step 5: Post-Deployment Verification"

print_step "Checking pod status..."
kubectl get pods -n dev

print_step "Checking services..."
kubectl get svc -n dev

print_step "Checking persistent volumes..."
kubectl get pvc -n dev

print_header "Deployment Complete!"

print_message "To view logs for a specific pod:"
echo "  kubectl logs -f <pod-name> -n dev"
echo ""
print_message "To port-forward the application:"
echo "  kubectl port-forward svc/dev-app 8080:8080 -n dev"
echo ""
print_message "To access the cluster:"
echo "  kubectl get all -n dev"
