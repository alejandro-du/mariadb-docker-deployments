#!/bin/bash
echo "************************ build *************************"

docker build --file mariadb-replication/single-node/Dockerfile --tag mariadb-replication/single-node .
docker build --file mariadb-replication/primary/Dockerfile --tag mariadb-replication/primary .
docker build --file mariadb-replication/replica/Dockerfile --tag mariadb-replication/replica .

echo