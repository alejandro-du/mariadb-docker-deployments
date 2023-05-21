#!/bin/bash
echo "************************ build *************************"

if [ "$1" == "es" ]; then
    docker build --file mariadb-es/Dockerfile --build-arg CUSTOMER_DOWNLOAD_TOKEN=$CUSTOMER_DOWNLOAD_TOKEN --tag alejandrodu/mariadb-es .
else
	docker build --file mariadb/Dockerfile --tag alejandrodu/mariadb .
	docker build --file maxscale/Dockerfile --tag alejandrodu/mariadb-maxscale .
fi

echo