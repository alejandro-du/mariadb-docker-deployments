host="thinkpad.local:5000"

docker tag mariadb-replication/single-node $host/mariadb-replication/single-node
docker tag mariadb-replication/primary $host/mariadb-replication/primary
docker tag mariadb-replication/replica $host/mariadb-replication/replica

docker push $host/mariadb-replication/single-node
docker push $host/mariadb-replication/primary
docker push $host/mariadb-replication/replica