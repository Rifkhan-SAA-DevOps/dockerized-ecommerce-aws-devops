#!/bin/bash
set -e

REGION="ap-south-1"
ECR_REPO="frontend"
IMAGE_TAG="latest"
CONTAINER_NAME="frontend"

yum update -y
yum install -y docker awscli

systemctl enable docker
systemctl start docker


echo "Reading parameters from SSM Parameter Store..."

ACCOUNT_ID=$(aws ssm get-parameter --name "account_id" --with-decryption --query "Parameter.Value" --output text --region $REGION)

echo "Logging in to Amazon ECR..."

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "Pulling frontend Docker image..."

docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

echo "Removing old frontend container if exists..."

docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

echo "Starting frontend container..."

docker run -d \
  --name $CONTAINER_NAME \
  --restart always \
  -p 80:80 \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

echo "Frontend container started."

docker ps