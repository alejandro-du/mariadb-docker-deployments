#!/bin/bash
echo "************************ build *************************"

docker build --file mariadb-es/Dockerfile --build-arg CUSTOMER_DOWNLOAD_TOKEN=$CUSTOMER_DOWNLOAD_TOKEN --tag alejandrodu/mariadb-es .
docker build --file maxscale/Dockerfile --tag mariadb-maxscale .

echo