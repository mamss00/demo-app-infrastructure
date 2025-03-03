#!/bin/bash
# scripts/tf-init.sh
# Initializes Terraform with the correct backend configuration for a specific environment and component
# Usage: ./tf-init.sh <environment> <component>
# Example: ./tf-init.sh dev networking

set -euo pipefail
trap 'echo "Error line $LINENO: $BASH_COMMAND"; exit 1' ERR

source "$(dirname "$0")/config.sh"

usage() {
  echo "Usage: $0 <environment> <component>"
  echo "Environments: dev, staging, prod"
  echo "Components: networking, database, app"
  exit 1
}

[[ "$#" -lt 2 || "$1" =~ (-h|--help) ]] && usage

ENV=$1
COMPONENT=$2
VALID_COMPONENTS=("networking" "database" "app")

# Validation des entrées
[[ ! " ${VALID_ENVIRONMENTS[@]} " =~ " ${ENV} " ]] && {
  echo "Invalid environment! Valid values: ${VALID_ENVIRONMENTS[@]}"
  exit 1
}

[[ ! " ${VALID_COMPONENTS[@]} " =~ " ${COMPONENT} " ]] && {
  echo "Invalid component! Valid values: ${VALID_COMPONENTS[@]}"
  exit 1
}

STATE_KEY="${ENV}/${COMPONENT}/terraform.tfstate"

echo "Initializing Terraform for ${ENV}/${COMPONENT}"
terraform init \
  -backend-config="bucket=${BUCKET_NAME}" \
  -backend-config="key=${STATE_KEY}" \
  -backend-config="region=${REGION}" \
  -backend-config="dynamodb_table=${DYNAMODB_TABLE}" \
  -backend-config="encrypt=true"

echo "Initialization complete!"