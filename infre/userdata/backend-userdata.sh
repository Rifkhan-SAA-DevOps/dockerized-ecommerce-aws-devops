#!/bin/bash
set -e

REGION="ap-south-1"
ECR_REPO="backend"
IMAGE_TAG="latest"
CONTAINER_NAME="backend"

LOG_FILE="/var/log/backend-userdata.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "Starting backend user data script..."

dnf update -y
dnf install -y docker awscli

systemctl enable docker
systemctl start docker

dnf install -y amazon-cloudwatch-agent

echo "Reading parameters from SSM Parameter Store..."

ACCOUNT_ID=$(aws ssm get-parameter --name "account_id" --with-decryption --query "Parameter.Value" --output text --region $REGION)
DB_HOST=$(aws ssm get-parameter --name "/docker/db/host" --with-decryption --query "Parameter.Value" --output text --region $REGION)
DB_PORT=$(aws ssm get-parameter --name "/docker/db/port" --query "Parameter.Value" --output text --region $REGION)
DB_NAME=$(aws ssm get-parameter --name "/docker/db/name" --query "Parameter.Value" --output text --region $REGION)
DB_USER=$(aws ssm get-parameter --name "/docker/db/user" --query "Parameter.Value" --output text --region $REGION)
DB_PASSWORD=$(aws ssm get-parameter --name "/docker/db/password" --with-decryption --query "Parameter.Value" --output text --region $REGION)
JWT_SECRET=$(aws ssm get-parameter --name "/docker/jwt/secret" --with-decryption --query "Parameter.Value" --output text --region $REGION)
CORS_ORIGIN=$(aws ssm get-parameter --name "/docker/cors/origin" --query "Parameter.Value" --output text --region $REGION)

echo "Logging in to Amazon ECR..."

aws ecr get-login-password --region $REGION | docker login \
  --username AWS \
  --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "Pulling backend Docker image..."

docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

echo "Removing old container if exists..."

docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

echo "Starting backend container..."

docker run -d \
  --name $CONTAINER_NAME \
  --restart always \
  -p 5000:5000 \
  -e NODE_ENV=production \
  -e PORT=5000 \
  -e DB_HOST="$DB_HOST" \
  -e DB_PORT="$DB_PORT" \
  -e DB_USER="$DB_USER" \
  -e DB_PASSWORD="$DB_PASSWORD" \
  -e DB_NAME="$DB_NAME" \
  -e JWT_SECRET="$JWT_SECRET" \
  -e CORS_ORIGIN="$CORS_ORIGIN" \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

echo "Backend container started."

docker ps