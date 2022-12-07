#!/bin/bash
echo "************************ build *************************"

docker build --platform linux/arm --file primary/Dockerfile --tag alejandrodu/mariadb-arm-primary .
docker build --platform linux/arm --file replica/Dockerfile --tag alejandrodu/mariadb-arm-replica .
#docker build --file maxscale/Dockerfile --tag alejandrodu/mariadb-arm-maxscale .

echo