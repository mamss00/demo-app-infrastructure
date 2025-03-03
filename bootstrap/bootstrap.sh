#!/bin/bash
# scripts/bootstrap.sh
# Creates the necessary AWS resources for Terraform state management
# This script should be run once manually before any Terraform operations

set -euo pipefail
trap 'echo "Error line $LINENO: $BASH_COMMAND"; exit 1' ERR

source "$(dirname "$0")/config.sh"

VALID_ENVIRONMENTS=("dev" "staging" "prod")

usage() {
  echo "Usage: $0 [--help]"
  echo "Create AWS resources for Terraform state management"
  exit 0
}

[[ "$#" -gt 0 && "$1" =~ (-h|--help) ]] && usage

echo "Creating Terraform backend infrastructure for project: ${PROJECT_NAME}"

# Vérification AWS CLI
aws sts get-caller-identity >/dev/null || {
  echo "ERROR: AWS CLI not configured"
  exit 1
}

# Création bucket S3 avec gestion de région
create_bucket() {
  local location_constraint=""
  [[ "$REGION" != "us-east-1" ]] && location_constraint="--create-bucket-configuration LocationConstraint=$REGION"
  
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    $location_constraint
}

if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "Creating S3 bucket..."
  create_bucket

  # Configuration bucket (3 tentatives)
  for i in {1..3}; do
    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled && break
    sleep $((i * 2))
  done

  aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

  aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
fi

# Création table DynamoDB avec reprise sur erreur
create_dynamodb_table() {
  aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"
}

if ! aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$REGION" 2>/dev/null; then
  echo "Creating DynamoDB table..."
  for i in {1..3}; do
    create_dynamodb_table && break
    sleep $((i * 3))
  done

  aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE" --region "$REGION"
fi

echo "Infrastructure created successfully!"