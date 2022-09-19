docker tag mariadb-replication/single-node thinkpad.local:5000/mariadb-replication/single-node
docker tag mariadb-replication/primary thinkpad.local:5000/mariadb-replication/primary
docker tag mariadb-replication/replica thinkpad.local:5000/mariadb-replication/replica

docker push thinkpad.local:5000/mariadb-replication/single-node
docker push thinkpad.local:5000/mariadb-replication/primary
docker push thinkpad.local:5000/mariadb-replication/replica