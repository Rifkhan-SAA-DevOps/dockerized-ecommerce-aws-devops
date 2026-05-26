#!/bin/bash

set -e

AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="654654143187"

echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "Pulling latest images from ECR..."
docker compose -f docker-compose.ecr.yml pull

echo "Restarting containers..."
docker compose -f docker-compose.ecr.yml up -d

echo "Checking containers..."
docker compose -f docker-compose.ecr.yml ps

echo "Deployment from ECR completed."
