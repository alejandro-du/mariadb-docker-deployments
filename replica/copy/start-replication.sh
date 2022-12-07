#!/bin/bash

mariadb --password=$MYSQL_ROOT_PASSWORD -e "RESET REPLICA; START REPLICA;"
