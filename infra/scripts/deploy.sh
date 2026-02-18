#!/bin/bash

APP_NODE="192.168.32.131"
IMAGE_NAME="mini-platform"
TAG=$1

if [ -z "$TAG" ]; then
  echo "Usage: ./deploy.sh <tag>"
  exit 1
fi

echo "Saving image..."
docker save ${IMAGE_NAME}:${TAG} -o ${IMAGE_NAME}.tar

echo "Transferring image to app-node..."
scp ${IMAGE_NAME}.tar devops@${APP_NODE}:/home/devops/

echo "Deploying on app-node..."
ssh devops@${APP_NODE} << EOF
docker load -i ${IMAGE_NAME}.tar
docker stop mini-platform || true
docker rm mini-platform || true
docker run -d --name mini-platform -p 3000:3000 ${IMAGE_NAME}:${TAG}
EOF

echo "Deployment complete."
