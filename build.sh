#!/bin/bash
echo "************************ build *************************"

docker build --file single-node/Dockerfile --tag alejandrodu/mariadb-single-node .
docker build --file primary/Dockerfile --tag alejandrodu/mariadb-primary .
docker build --file replica/Dockerfile --tag alejandrodu/mariadb-replica .

echo