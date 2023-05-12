#!/bin/bash
echo "************************ build *************************"

docker build --file mariadb-es/Dockerfile --build-arg CUSTOMER_DOWNLOAD_TOKEN=$CUSTOMER_DOWNLOAD_TOKEN --tag piserver.local:5000/alejandrodu/mariadb-es .
docker build --file maxscale/Dockerfile --tag piserver.local:5000/alejandrodu/mariadb-maxscale .

#docker build --file single-node/Dockerfile --tag alejandrodu/mariadb-single-node .
#docker build --file primary/Dockerfile --tag alejandrodu/mariadb-primary .
#docker build --file replica/Dockerfile --tag alejandrodu/mariadb-replica .
#docker build --file maxscale/Dockerfile --tag alejandrodu/mariadb-maxscale .

echo
