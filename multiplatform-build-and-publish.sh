#!/bin/bash
echo "************************ publish *************************"
host="piserver.local:5000/"

docker buildx build --push --platform linux/amd64,linux/arm64 --file mariadb-es/Dockerfile --tag ${host}alejandrodu/mariadb-es .
docker buildx build --push --platform linux/amd64,linux/arm64 --file maxscale/Dockerfile --tag ${host}alejandrodu/mariadb-maxscale .

echo
