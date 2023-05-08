#!/bin/bash

run_primary() {
	echo
	echo "********************** run primary *********************"
	docker run --name mariadb-test-1 \
		--detach \
		--publish 3306:3306 \
		alejandrodu/mariadb-primary
	sleep 1
}

run_replica() {
	echo
	echo "********************* run replica $1 ********************"
	primary_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb-test-1)
	docker run --name mariadb-test-$1 \
		--detach \
		--publish $2:3306 \
		--env MARIADB_PRIMARY_HOST=$primary_ip \
		--env MARIADB_PRIMARY_PORT=3306 \
		alejandrodu/mariadb-replica
	sleep 2
}

run_maxscale() {
	echo
	echo "******************** run maxscale $1 ********************"
	host_ip_1=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb-test-1)
	host_ip_2=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb-test-2)
	host_ip_3=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb-test-3)
	docker run --name mariadb-maxscale-1 \
		--detach \
		--publish 4000:4000 \
		--publish 8989:8989 \
		--env MARIADB_HOST_1=$host_ip_1 \
		--env MARIADB_HOST_2=$host_ip_2 \
		--env MARIADB_HOST_3=$host_ip_3 \
		alejandrodu/mariadb-maxscale
	sleep 2
}

./clean.sh
./build.sh

run_primary
run_replica 2 3307
run_replica 3 3308
run_maxscale

echo "Done. Check the logs with ./logs.sh"
