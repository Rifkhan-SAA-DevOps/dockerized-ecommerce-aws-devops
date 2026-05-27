

#!/bin/bash

set -euo pipefail

AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="654654143187"

ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo "Checking AWS identity..."
aws sts get-caller-identity

echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "Installing Nginx if missing..."
if ! command -v nginx >/dev/null 2>&1; then
  sudo dnf install nginx -y || sudo yum install nginx -y
fi

echo "Applying Nginx reverse proxy config..."
sudo cp nginx/ec2-reverse-proxy.conf /etc/nginx/conf.d/rifkhan.conf

echo "Testing Nginx config..."
sudo nginx -t

echo "Starting/enabling Nginx..."
sudo systemctl enable nginx
sudo systemctl restart nginx


echo "Pulling latest images from ECR..."
docker compose -f docker-compose.ecr.yml pull

echo "Restarting containers..."
docker compose -f docker-compose.ecr.yml up -d --remove-orphans

echo "Cleaning unused images..."
docker image prune -f

echo "Deployment completed."
docker compose -f docker-compose.ecr.yml ps