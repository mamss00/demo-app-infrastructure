#!/bin/bash
# scripts/config.sh
export PROJECT_NAME="demo-app"
export REGION="eu-west-1"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export BUCKET_NAME="${PROJECT_NAME}-terraform-state-${AWS_ACCOUNT_ID}"
export DYNAMODB_TABLE="${PROJECT_NAME}-terraform-locks"