#!/bin/bash
echo "************************ publish *************************"
host=$1

docker buildx build --push --platform linux/amd64,linux/arm64 --file single-node/Dockerfile --tag ${host}alejandrodu/mariadb-single-node .
docker buildx build --push --platform linux/amd64,linux/arm64 --file primary/Dockerfile 	--tag ${host}alejandrodu/mariadb-primary .
docker buildx build --push --platform linux/amd64,linux/arm64 --file replica/Dockerfile 	--tag ${host}alejandrodu/mariadb-replica .
docker buildx build --push --platform linux/amd64,linux/arm64 --file maxscale/Dockerfile 	--tag ${host}alejandrodu/mariadb-maxscale .

echo
