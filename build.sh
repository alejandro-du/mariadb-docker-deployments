#!/bin/bash
echo "************************ build *************************"

docker build --file mariadb/Dockerfile --tag alejandrodu/mariadb .
docker build --file maxscale/Dockerfile --tag mariadb-maxscale .

if [ "$1" == "es" ]; then
    docker build --file mariadb-es/Dockerfile --build-arg CUSTOMER_DOWNLOAD_TOKEN=$CUSTOMER_DOWNLOAD_TOKEN --tag alejandrodu/mariadb-es .
fi

echo