#!/bin/bash

run_primary() {
	echo
	echo "********************** run primary *********************"
	docker run --detach --name mariadb-test-1 --publish 3306:3306 mariadb-replication/primary
	sleep 1
}

run_replica() {
	echo
	echo "********************** run replica *********************"
	primary_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb-test-1)
	docker run --detach --name mariadb-test-2 --publish 3307:3306 --env MARIADB_PRIMARY_HOST=$primary_ip mariadb-replication/replica
	sleep 2
}

./clean.sh
./build.sh

run_primary
run_replica

echo "Done. Check the logs with ./logs.sh"
