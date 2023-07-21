#!/bin/bash
echo "Starting MaxScale..."
maxscale -U maxscale

servers=""
maxscale_user=$(echo $MAXSCALE_USER | cut -d':' -f1)
maxscale_password=$(echo $MAXSCALE_USER | cut -d':' -f2)

for ((n = 1; n <= 100; n++)); do
	host="MARIADB_HOST_$n"
	if ! [[ -z "${!host}" ]]; then
		echo "Creating MariaDB server server-$n..."
		servers="$servers server-$n"
		maxctrl create server server-$n ${!host}
	fi
done

echo "Creating monitor for servers $servers..."
maxctrl create monitor mdb_monitor mariadbmon \
	user="$maxscale_user" password="$maxscale_password" \
	--servers $servers

echo "Creating Read/Write Split Router service for servers $servers..."
maxctrl create service query_router_service readwritesplit \
	user=$maxscale_user \
	password=$maxscale_password \
	--servers $servers

echo "Creating SQL listener sql_listener..."
maxctrl create listener query_router_service sql_listener 4000

if [ -n "$MAXSCALE_CREATE_NOSQL_LISTENER" ]; then
	mariadb_user=$(echo $MAXSCALE_CREATE_NOSQL_LISTENER | cut -d':' -f1)
	mariadb_password=$(echo $MAXSCALE_CREATE_NOSQL_LISTENER | cut -d':' -f2)
	command="maxctrl create listener query_router_service $MAXSCALE_CREATE_NOSQL_LISTENER 27017 protocol=nosqlprotocol 'nosqlprotocol={\"user\":\"$mariadb_user\", \"password\":\"$mariadb_password\"}'"
	echo "Creating NoSQL listener with $command..."
	eval "$command"
	echo "Done creating NoSQL listener $MAXSCALE_CREATE_NOSQL_LISTENER"
fi


echo "Restarting MaxScale..."
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