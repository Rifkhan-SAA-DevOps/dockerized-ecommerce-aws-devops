#!/bin/bash

set -e

echo "🚀 Deploying frontend container..."

cd ~/YOUR_REPO

echo "📥 Pulling latest code..."
git pull origin main

echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com

echo "📦 Pulling latest frontend image..."
docker compose -f docker-compose.frontend.yml pull

echo "🔁 Restarting frontend..."
docker compose -f docker-compose.frontend.yml up -d

echo "🧹 Cleaning unused images..."
docker image prune -f

echo "✅ Frontend deployment completed!"