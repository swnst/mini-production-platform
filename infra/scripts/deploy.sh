echo "Deploying on app-node..."

ssh devops@${APP_NODE} << EOF
OLD_IMAGE=\$(docker ps --format "{{.Image}}" | grep mini-platform || true)

docker load -i ${IMAGE_NAME}.tar

docker stop mini-platform || true
docker rm mini-platform || true

docker run -d --name mini-platform -p 3000:3000 ${IMAGE_NAME}:${TAG}

sleep 3

HTTP_CODE=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)

if [ "\$HTTP_CODE" != "200" ]; then
  echo "Health check failed on app-node. Rolling back..."

  docker stop mini-platform || true
  docker rm mini-platform || true

  if [ -n "\$OLD_IMAGE" ]; then
    docker run -d --name mini-platform -p 3000:3000 \$OLD_IMAGE
    echo "Rollback complete."
  else
    echo "No previous image found. Manual intervention required."
  fi

  exit 1
fi

echo "New version healthy."
EOF

