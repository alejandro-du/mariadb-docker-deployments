#!/bin/bash
echo "Starting MaxScale..."
service maxscale start

echo "Creating servers..."
maxctrl create server mariadb-1 $MARIADB_HOST_1
maxctrl create server mariadb-2 $MARIADB_HOST_2
maxctrl create server mariadb-3 $MARIADB_HOST_3

echo "Creating monitor..."
maxctrl create monitor mdb_monitor mariadbmon \
      --monitor-user maxscale --monitor-password 'password' \
      --servers mariadb-1 mariadb-2 mariadb-3

echo "Creating Read/Write Split Router service..."
maxctrl create service query_router_service readwritesplit  \
      user=maxscale \
      password=password \
      --servers mariadb-1 mariadb-2 mariadb-3

echo "Creating listener..."
maxctrl create listener query_router_service query_router_listener 4000 \
      --protocol=MariaDBClient

echo "Restarting MaxScale"
service maxscale stop

maxscale -d -U maxscale -l stdout
