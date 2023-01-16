#!/bin/bash
echo "Starting MaxScale..."
maxscale -U maxscale

servers=""

for ((n = 1; n <= 100; n++)); do
	host="MARIADB_HOST_$n"
	if ! [[ -z "${!host}" ]]; then
		echo "Creating server mariadb-$n..."
		servers="$servers mariadb-$n"
		maxctrl create server mariadb-$n ${!host}
	fi
done

echo "Creating monitor for servers $servers..."
maxctrl create monitor mdb_monitor mariadbmon \
	--monitor-user maxscale --monitor-password 'password' \
	--servers $servers

echo "Creating Read/Write Split Router service for servers $servers..."
maxctrl create service query_router_service readwritesplit \
	user=maxscale \
	password=password \
	--servers $servers

echo "Creating SQL listener..."
maxctrl create listener query_router_service sql_listener 4000 \
	--protocol=MariaDBClient

echo "Restarting MaxScale"
PID=$(pgrep -x 'maxscale')
if [[ ! -z $PID ]]; then
    echo 'Sending SIGTERM'
    kill $PID 2> /dev/null
    PID=$(pgrep -x 'maxscale')
    if [[ ! -z $PID ]]; then
        echo 'Sending SIGKILL'
        kill -9 $PID 2> /dev/null
    fi
fi

maxscale -U maxscale -d -l stdout