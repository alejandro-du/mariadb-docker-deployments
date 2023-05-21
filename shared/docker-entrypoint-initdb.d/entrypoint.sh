#!/bin/bash

cmd="$3"
set -m
server_id=0

####################################################################################################################################################
# Start mariadbd process
####################################################################################################################################################
start_mariadbd() {
	echo "Starting mariadbd..."
	echo "Using server_id=$server_id"
	$cmd --server_id=$server_id &

	# Wait for the server to start
	echo "Pinging server..."
	while ! mariadb-admin ping -u root --silent; do
		echo "Waiting for the server to start..."
		sleep 1
	done

	# Wait for the server to become available
	echo "Querying server..."
	while ! mariadb -u root -e "select version()"; do
		echo "Waiting for the server to become available..."
		sleep 5
	done

	echo "Done starting mariadbd"
}

####################################################################################################################################################
# Secure installation
####################################################################################################################################################
secure_installation() {
	echo "Securing installation..."
	# don't remove the empty line after echo!
	echo "

	n n y y y y" | mariadb-secure-installation

	echo "Done securing installation"
}

####################################################################################################################################################
# If MARIADB_RESTORE_FROM is specified, take a backup and restore it
####################################################################################################################################################
restore() {
	if [ -n "$MARIADB_RESTORE_FROM" ]; then
		echo "Restoring database from $MARIADB_RESTORE_FROM..."

		# Extract backup server credentials from the MARIADB_RESTORE_FROM variable
		BACKUP_USER=$(echo $MARIADB_RESTORE_FROM | cut -d':' -f1)
		BACKUP_PASSWORD=$(echo $MARIADB_RESTORE_FROM | cut -d':' -f2 | cut -d'@' -f1)
		BACKUP_HOST=$(echo $MARIADB_RESTORE_FROM | cut -d':' -f2 | cut -d'@' -f2)
		BACKUP_PORT=$(echo $MARIADB_RESTORE_FROM | cut -d':' -f3)

		# Wait for the backup server to become available
		echo "Querying backup server..."
		while ! mariadb --user=$BACKUP_USER --password=$BACKUP_PASSWORD --host=$BACKUP_HOST --port=$BACKUP_PORT -e "select version()"; do
			echo "Waiting for backup server to become available..."
			sleep 5
		done
		echo "Backup server available"

		# Take a backup using mariadb-backup
		echo "Taking backup..."
		mariadb-backup --backup --innodb-use-native-aio --parallel=4 --rsync --user=$BACKUP_USER --password=$BACKUP_PASSWORD --host=$BACKUP_HOST --port=$BACKUP_PORT --target-dir=/tmp/backup/

		if [ $? == "0" ]; then
			echo "Getting GTID replica position..."
			log_info=($(cat /tmp/backup/xtrabackup_binlog_info))
			log_pos=${log_info[1]}
			echo "Using log_pos=$log_pos"

			# Restore the backup in the container
			echo "Preparing backup..."
			mariadb-backup --prepare --target-dir=/tmp/backup/

			echo "Restoring backup..."
			mariadb-backup --move-back --force-non-empty-directories --datadir=/var/lib/mysql/ --target-dir=/tmp/backup/
			#chown -R mysql:mysql /var/lib/mysql
			start_mariadbd

			echo "Done restoring database from $MARIADB_RESTORE_FROM"
		else
			echo "Error taking backup"
		fi
	fi
}

####################################################################################################################################################
# If MARIADB_CREATE_DATABASE is specified, create database
####################################################################################################################################################
create_database() {
	if [ -n "$MARIADB_CREATE_DATABASE" ]; then
		echo "Creating database $MARIADB_CREATE_DATABASE..."
		# Create database
		mariadb -e "CREATE DATABASE $MARIADB_CREATE_DATABASE;"
		echo "Done creating database $MARIADB_CREATE_DATABASE"
	fi
}

####################################################################################################################################################
# If MARIADB_CREATE_USER is specified, create user
####################################################################################################################################################
create_user() {
	if [ -n "$MARIADB_CREATE_USER" ]; then
		echo "Creating user $MARIADB_CREATE_USER..."
		# Extract user credentials from the MARIADB_CREATE_USER variable
		USER=$(echo $MARIADB_CREATE_USER | cut -d':' -f1)
		PASSWORD=$(echo $MARIADB_CREATE_USER | cut -d':' -f2)

		# Create user
		mariadb -e "CREATE USER '$USER'@'%' IDENTIFIED BY '$PASSWORD';"
		if [ -n "$MARIADB_CREATE_DATABASE" ]; then
			echo "Granting privileges to user..."
			mariadb -e "GRANT ALL PRIVILEGES ON $MARIADB_CREATE_DATABASE.* TO '$USER'@'%';"
		fi
		echo "Done creating user $MARIADB_CREATE_USER"
	fi
}

####################################################################################################################################################
# If MARIADB_CREATE_BACKUP_USER is specified, create backup user for backup operations
####################################################################################################################################################
create_backup_user() {
	if [ -n "$MARIADB_CREATE_BACKUP_USER" ]; then
		echo "Creating backup user $MARIADB_CREATE_BACKUP_USER..."
		# Extract backup user credentials from the MARIADB_CREATE_BACKUP_USER variable
		BACKUP_USER=$(echo $MARIADB_CREATE_BACKUP_USER | cut -d':' -f1)
		BACKUP_PASSWORD=$(echo $MARIADB_CREATE_BACKUP_USER | cut -d':' -f2)

		# Create backup user
		mariadb -e "CREATE USER '$BACKUP_USER'@'%' IDENTIFIED BY '$BACKUP_PASSWORD';"
		mariadb -e "GRANT RELOAD, PROCESS, LOCK TABLES, BINLOG MONITOR, SLAVE MONITOR, CONNECTION ADMIN ON *.* TO '$BACKUP_USER'@'%';"
		echo "Done creating backup user $MARIADB_CREATE_BACKUP_USER"
	fi
}

####################################################################################################################################################
# If MARIADB_CREATE_REPLICATION_USER is specified, create user for replication
####################################################################################################################################################
create_replication_user() {
	if [ -n "$MARIADB_CREATE_REPLICATION_USER" ]; then
		echo "Creating replication user $MARIADB_CREATE_REPLICATION_USER..."
		# Extract replication user credentials from the MARIADB_CREATE_REPLICATION_USER variable
		REPLICATION_USER=$(echo $MARIADB_CREATE_REPLICATION_USER | cut -d':' -f1)
		REPLICATION_PASSWORD=$(echo $MARIADB_CREATE_REPLICATION_USER | cut -d':' -f2)

		# Create replication user
		mariadb -e "CREATE USER '$REPLICATION_USER'@'%' IDENTIFIED BY '$REPLICATION_PASSWORD';"
		mariadb -e "GRANT REPLICATION SLAVE ON *.* TO '$REPLICATION_USER'@'%';"
		echo "Done creating replication user $MARIADB_CREATE_REPLICATION_USER"
	fi
}

####################################################################################################################################################
# If MARIADB_CREATE_MAXSCALE_USER is specified, create user for MaxScale
####################################################################################################################################################
create_maxscale_user() {
	if [ -n "$MARIADB_CREATE_MAXSCALE_USER" ]; then
		echo "Creating MaxScale user $MARIADB_CREATE_MAXSCALE_USER..."
		# Extract MaxScale user credentials from the MARIADB_CREATE_MAXSCALE_USER variable
		MAXSCALE_USER=$(echo $MARIADB_CREATE_MAXSCALE_USER | cut -d':' -f1)
		MAXSCALE_PASSWORD=$(echo $MARIADB_CREATE_MAXSCALE_USER | cut -d':' -f2)

		# Create MaxScale user
		mariadb -e "CREATE USER '$MAXSCALE_USER'@'%' IDENTIFIED BY '$MAXSCALE_PASSWORD';"
		mariadb -e "GRANT SHOW DATABASES, SUPER, REPLICATION CLIENT, REPLICATION REPLICA, RELOAD, PROCESS, EVENT, READ_ONLY ADMIN ON *.* TO '$MAXSCALE_USER'@'%';"
		mariadb -e "GRANT SELECT ON mysql.columns_priv TO '$MAXSCALE_USER'@'%';"
		mariadb -e "GRANT SELECT ON mysql.db TO '$MAXSCALE_USER'@'%';"
		mariadb -e "GRANT SELECT ON mysql.procs_priv TO '$MAXSCALE_USER'@'%';"
		mariadb -e "GRANT SELECT ON mysql.proxies_priv TO '$MAXSCALE_USER'@'%';"
		mariadb -e "GRANT SELECT ON mysql.roles_mapping TO '$MAXSCALE_USER'@'%';"
		mariadb -e "GRANT SELECT ON mysql.tables_priv TO '$MAXSCALE_USER'@'%';"
		mariadb -e "GRANT SELECT ON mysql.user TO '$MAXSCALE_USER'@'%';"
		echo "Done creating MaxScale user $MARIADB_CREATE_MAXSCALE_USER"
	fi
}

####################################################################################################################################################
# If MARIADB_REPLICATE_FROM is specified, configure replication
####################################################################################################################################################
replicate() {
	if [ -n "$MARIADB_REPLICATE_FROM" ]; then
		echo "Setting up replication from $MARIADB_REPLICATE_FROM..."
		# Extract primary server credentials from the MARIADB_REPLICATE_FROM variable
		PRIMARY_USER=$(echo $MARIADB_REPLICATE_FROM | cut -d':' -f1)
		PRIMARY_PASSWORD=$(echo $MARIADB_REPLICATE_FROM | cut -d':' -f2 | cut -d'@' -f1)
		PRIMARY_HOST=$(echo $MARIADB_REPLICATE_FROM | cut -d':' -f2 | cut -d'@' -f2)
		PRIMARY_PORT=$(echo $MARIADB_REPLICATE_FROM | cut -d':' -f3)

		# Wait for the primary server to become available
		echo "Querying primary server..."
		while ! mariadb --user=$PRIMARY_USER --password=$PRIMARY_PASSWORD --host=$PRIMARY_HOST --port=$PRIMARY_PORT -e "select version()"; do
			echo "Waiting for primary server to become available..."
			sleep 5
		done
		echo "Primary server available"

		# Setup replication with primary server
		echo "Changing MASTER..."
		mariadb -e "CHANGE MASTER TO MASTER_HOST='$PRIMARY_HOST', MASTER_PORT=$PRIMARY_PORT, MASTER_USER='$PRIMARY_USER', MASTER_PASSWORD='$PRIMARY_PASSWORD', MASTER_LOG_FILE='mariadb-bin.000002', MASTER_LOG_POS=344, MASTER_USE_GTID=replica_pos"
		echo "Starting replica..."
		mariadb -e "START REPLICA;"
		echo "Done setting up replication from $MARIADB_REPLICATE_FROM"
	fi
}


####################################################################################################################################################
# Script entry point
####################################################################################################################################################

restore

if [ ! -f /server_id ]; then
	echo "Generating new server_id..."
	server_id=`shuf -i 2-1000000 -n 1`
	start_mariadbd
	secure_installation
	mariadb -u root -e "RESET MASTER"
	create_database
	create_user
	create_backup_user
	create_replication_user
	create_maxscale_user
	replicate
	echo $server_id> /server_id
	echo
	echo "Script completed!"
	echo
else
	server_id=$(cat /server_id)
	echo "Using existing server_id..."
	start_mariadbd $server_id
fi

fg
