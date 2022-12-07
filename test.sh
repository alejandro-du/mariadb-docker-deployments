#!/bin/bash

echo "************************ test *************************"

./clean.sh
sleep 6
./build.sh
./publish.sh

docker stack deploy -c stacks/replication.stack.yml mariadb
sleep 15

docker exec -it $(docker ps | grep replica.1 | grep -o '[^ ]\+$' | tail -1) mariadb --password=password -e "show replica status\G" | grep 'Slave_IO_Running\|Slave_SQL_Running\|Last_IO_Error\|Last_SQL_Error'
