#!/bin/bash

set -e

AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="654654143187"

BACKEND_REPO="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/backend"
FRONTEND_REPO="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/frontend"

echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "Building backend image..."
docker build -t backend ./server

echo "Tagging backend image..."
docker tag backend:latest $BACKEND_REPO:latest

echo "Pushing backend image..."
docker push $BACKEND_REPO:latest

echo "Building frontend image..."
docker build -t frontend ./client

echo "Tagging frontend image..."
docker tag frontend:latest $FRONTEND_REPO:latest

echo "Pushing frontend image..."
docker push $FRONTEND_REPO:latest

echo "Images pushed successfully to ECR."