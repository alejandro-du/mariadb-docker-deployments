#!/bin/bash

if [ "$1" == "es" ]; then
	image="mariadb-es"
else
	image="mariadb"
fi

run_primary() {
	echo
	echo "********************** run primary *********************"
	docker run --name mariadb-test-1 \
		--detach \
		--publish 3306:3306 \
		--env MARIADB_CREATE_DATABASE=demo \
		--env MARIADB_CREATE_USER=user:Password123! \
		--env MARIADB_CREATE_REPLICATION_USER=replication_user:ReplicationPassword123! \
		--env MARIADB_CREATE_MAXSCALE_USER=maxscale_user:MaxScalePassword123! \
		alejandrodu/$image
		#--env MARIADB_CREATE_BACKUP_USER=backup_user:BackupPassword123! \
}

run_replica() {
	echo
	echo "********************* run replica $1 ********************"
	primary_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb-test-1)
	docker run --name mariadb-test-$1 \
		--detach \
		--publish $2:3306 \
		--env MARIADB_REPLICATE_FROM=replication_user:ReplicationPassword123!@$primary_ip:3306 \
		alejandrodu/$image
		#--env MARIADB_RESTORE_FROM=backup_user:BackupPassword123!@$primary_ip:3306 \
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
		--publish 27017:27017 \
		--env MAXSCALE_USER=maxscale_user:MaxScalePassword123! \
		--env MARIADB_HOST_1=$host_ip_1 \
		--env MARIADB_HOST_2=$host_ip_2 \
		--env MARIADB_HOST_3=$host_ip_3 \
		--env MAXSCALE_CREATE_NOSQL_LISTENER=user:Password123! \
		alejandrodu/mariadb-maxscale
}

./clean.sh
./build.sh $1

run_primary
run_replica 2 3307
run_replica 3 3308
run_maxscale

echo "Done. Check the logs with ./logs.sh"
