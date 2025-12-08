#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

VERSION_FILE=".version"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

# Initialize version file if it doesn't exist
if [ ! -f "$VERSION_FILE" ]; then
    echo "1.0.0" > "$VERSION_FILE"
    print_info "Initialized version file with 1.0.0"
fi

# Read current version
CURRENT_VERSION=$(cat "$VERSION_FILE")
print_info "Current version: $CURRENT_VERSION"

# Parse version
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# Determine version bump type
if [ -z "$1" ]; then
    echo ""
    echo "Usage: $0 [major|minor|patch]"
    echo ""
    echo "Current version: $CURRENT_VERSION"
    echo ""
    echo "Options:"
    echo "  major - Increment major version (${MAJOR}.0.0 -> $((MAJOR+1)).0.0)"
    echo "  minor - Increment minor version (${MAJOR}.${MINOR}.0 -> ${MAJOR}.$((MINOR+1)).0)"
    echo "  patch - Increment patch version (${MAJOR}.${MINOR}.${PATCH} -> ${MAJOR}.${MINOR}.$((PATCH+1)))"
    echo ""
    exit 1
fi

BUMP_TYPE=$1

case $BUMP_TYPE in
    major)
        NEW_VERSION="$((MAJOR+1)).0.0"
        ;;
    minor)
        NEW_VERSION="${MAJOR}.$((MINOR+1)).0"
        ;;
    patch)
        NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH+1))"
        ;;
    *)
        print_warning "Invalid bump type. Use: major, minor, or patch"
        exit 1
        ;;
esac

print_info "Bumping version: $CURRENT_VERSION → $NEW_VERSION"

# Update version file
echo "$NEW_VERSION" > "$VERSION_FILE"

# Update pom.xml version
if [ -f "pom.xml" ]; then
    print_info "Updating pom.xml..."
    sed -i.bak "s|<version>.*</version>|<version>$NEW_VERSION</version>|" pom.xml && rm pom.xml.bak
fi

# Update kustomization.yaml with new image tag
KUSTOMIZATION_FILE="deploy/k8s/kustomization.yaml"
if [ -f "$KUSTOMIZATION_FILE" ]; then
    print_info "Updating kustomization.yaml..."
    sed -i.bak "s|value: adithyasv/my-app:.*|value: adithyasv/my-app:$NEW_VERSION|g" "$KUSTOMIZATION_FILE" && rm "${KUSTOMIZATION_FILE}.bak"
fi

# Update app-deployment.yaml
APP_DEPLOYMENT="deploy/k8s/app-deployment.yaml"
if [ -f "$APP_DEPLOYMENT" ]; then
    print_info "Updating app-deployment.yaml..."
    sed -i.bak "s|value: \".*\" # Will be updated|value: \"$NEW_VERSION\" # Will be updated|g" "$APP_DEPLOYMENT" && rm "${APP_DEPLOYMENT}.bak"
fi

print_success "Version bumped to $NEW_VERSION"
echo ""
print_info "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Build with new version: mvn clean package"
echo "  3. Build Docker image: docker build -t adithyasv/my-app:$NEW_VERSION ."
echo "  4. Tag and push: docker tag adithyasv/my-app:$NEW_VERSION adithyasv/my-app:latest"
echo "  5. Deploy: cd deploy/scripts && ./deploy-application.sh"
echo ""
print_info "Or commit and push to trigger CI/CD pipeline"
