#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}================================${NC}"
}

print_check() {
    echo -n "Checking $1... "
}

print_success() {
    echo -e "${GREEN}✓ PASS${NC}"
}

print_fail() {
    echo -e "${RED}✗ FAIL${NC}"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING${NC}"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_header "Pre-Deployment Validation for Dev Environment"
echo ""

# Check 1: Azure CLI
print_check "Azure CLI"
if command -v az &> /dev/null; then
    AZ_VERSION=$(az version --query '"azure-cli"' -o tsv 2>/dev/null)
    print_success
    print_info "Version: $AZ_VERSION"
else
    print_fail
    print_info "Install: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
fi

# Check 2: Azure Login
print_check "Azure authentication"
if az account show &> /dev/null; then
    ACCOUNT=$(az account show --query name -o tsv)
    print_success
    print_info "Logged in as: $ACCOUNT"
else
    print_fail
    print_info "Run: az login"
fi

# Check 3: Terraform
print_check "Terraform"
if command -v terraform &> /dev/null; then
    TF_VERSION=$(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
    print_success
    print_info "Version: $TF_VERSION"
else
    print_fail
    print_info "Install from: https://www.terraform.io/downloads"
fi

# Check 4: kubectl
print_check "kubectl"
if command -v kubectl &> /dev/null; then
    KUBECTL_VERSION=$(kubectl version --client -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*' | cut -d'"' -f4)
    print_success
    print_info "Version: $KUBECTL_VERSION"
else
    print_fail
    print_info "Install: brew install kubectl"
fi

# Check 5: Maven
print_check "Maven"
if command -v mvn &> /dev/null; then
    MVN_VERSION=$(mvn -version 2>/dev/null | head -n 1 | awk '{print $3}')
    print_success
    print_info "Version: $MVN_VERSION"
else
    print_fail
    print_info "Install: brew install maven"
fi

# Check 6: Docker
print_check "Docker"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker version --format '{{.Client.Version}}' 2>/dev/null)
    if docker ps &> /dev/null; then
        print_success
        print_info "Version: $DOCKER_VERSION"
    else
        print_fail
        print_info "Docker is installed but not running. Start Docker Desktop."
    fi
else
    print_fail
    print_info "Install Docker Desktop from: https://www.docker.com/products/docker-desktop"
fi

echo ""
print_header "Azure Resources Validation"
echo ""

# Check 7: Subscription
print_check "Azure subscription access"
if az account show &> /dev/null; then
    SUBSCRIPTION=$(az account show --query id -o tsv)
    print_success
    print_info "Subscription ID: $SUBSCRIPTION"
else
    print_fail
fi

# Check 8: Remote Backend
print_check "Terraform remote backend"
if az storage account show --name remotebackendstoragetf --resource-group rg-terraform_remote_backend &> /dev/null; then
    print_success
    print_info "Storage Account: remotebackendstoragetf"
else
    print_warning
    print_info "Remote backend storage account not found. Terraform may fail."
fi

# Check 9: Resource Group quota
print_check "Resource Group creation permission"
TEST_RG="rg-kafka-study-dev"
if az group show -n $TEST_RG &> /dev/null; then
    print_success
    print_info "Resource group '$TEST_RG' already exists"
elif az group create -n test-permission-check-temp -l eastus &> /dev/null 2>&1; then
    print_success
    az group delete -n test-permission-check-temp -y &> /dev/null
    print_info "Permission to create resource groups verified"
else
    print_warning
    print_info "Unable to verify resource group creation permission"
fi

echo ""
print_header "Project Files Validation"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Check 10: POM file
print_check "Maven POM file"
if [ -f "$PROJECT_ROOT/pom.xml" ]; then
    print_success
    print_info "Location: $PROJECT_ROOT/pom.xml"
else
    print_fail
    print_info "pom.xml not found in project root"
fi

# Check 11: Dockerfile
print_check "Dockerfile"
if [ -f "$PROJECT_ROOT/Dockerfile" ]; then
    print_success
    print_info "Location: $PROJECT_ROOT/Dockerfile"
else
    print_fail
    print_info "Dockerfile not found in project root"
fi

# Check 12: Terraform files
print_check "Terraform configuration"
if [ -f "$PROJECT_ROOT/deploy/azr/aks.tf" ] && [ -f "$PROJECT_ROOT/deploy/azr/terraform.tfvars.dev" ]; then
    print_success
    print_info "Location: $PROJECT_ROOT/deploy/azr/"
else
    print_fail
    print_info "Terraform files missing in deploy/azr/"
fi

# Check 13: Kubernetes manifests
print_check "Kubernetes manifests"
if [ -d "$PROJECT_ROOT/deploy/k8s/base" ] && [ -d "$PROJECT_ROOT/deploy/k8s/overlays/dev" ]; then
    print_success
    print_info "Location: $PROJECT_ROOT/deploy/k8s/"
else
    print_fail
    print_info "Kubernetes manifests missing in deploy/k8s/"
fi

# Check 14: Deployment scripts
print_check "Deployment scripts"
if [ -f "$SCRIPT_DIR/deploy-all.sh" ] && [ -x "$SCRIPT_DIR/deploy-all.sh" ]; then
    print_success
    print_info "Scripts are executable"
else
    print_warning
    print_info "Run: chmod +x deploy/scripts/*.sh"
fi

echo ""
print_header "Network Connectivity Check"
echo ""

# Check 15: Azure connectivity
print_check "Azure API connectivity"
if az account show &> /dev/null; then
    print_success
else
    print_fail
    print_info "Cannot connect to Azure. Check internet connection."
fi

# Check 16: Docker Hub connectivity
print_check "Docker Hub connectivity"
if docker pull hello-world &> /dev/null; then
    print_success
    docker rmi hello-world &> /dev/null
else
    print_warning
    print_info "Cannot pull from Docker Hub. Check internet/proxy settings."
fi

echo ""
print_header "Summary"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! You're ready to deploy.${NC}"
    echo ""
    echo "To deploy, run:"
    echo "  cd deploy/scripts"
    echo "  ./deploy-all.sh"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found. Deployment may proceed with caution.${NC}"
    echo ""
    echo "To deploy, run:"
    echo "  cd deploy/scripts"
    echo "  ./deploy-all.sh"
else
    echo -e "${RED}✗ $ERRORS error(s) and $WARNINGS warning(s) found. Please fix errors before deployment.${NC}"
    exit 1
fi

echo ""
print_info "For detailed deployment instructions, see: deploy/README.md"
print_info "For quick commands, see: deploy/QUICK_REFERENCE.md"
