#!/bin/bash

# Start mariadbd in the background
echo "Starting mariadbd in the background..."
mariadbd --user=root --skip-networking &
mariadbd_pid=$!

# Wait for the server to start
echo "Waiting for the server to start..."
while ! mariadb-admin ping -u root --silent; do
	sleep 1
done

# Wait for the server to become available
echo "Waiting for the server to become available..."
while ! mariadb -u root -e "select version()"; do
	sleep 5
done
echo "Server started and available."

# If MARIADB_CREATE_BACKUP_USER is specified, create backup user for backup operations
if [ -n "$MARIADB_CREATE_BACKUP_USER" ]; then
	echo "Creating backup user..."
    # Extract backup user credentials from MARIADB_CREATE_BACKUP_USER variable
    BACKUP_USER=$(echo $MARIADB_CREATE_BACKUP_USER | cut -d':' -f1)
    BACKUP_PASSWORD=$(echo $MARIADB_CREATE_BACKUP_USER | cut -d':' -f2)

    # Create backup user
    mariadb -e "CREATE USER '$BACKUP_USER'@'%' IDENTIFIED BY '$BACKUP_PASSWORD';"
    mariadb -e "GRANT RELOAD, PROCESS, LOCK TABLES, BINLOG MONITOR ON *.* TO '$BACKUP_USER'@'%';"
fi

# If MARIADB_CREATE_REPLICATION_USER is specified, create user for replication
if [ -n "$MARIADB_CREATE_REPLICATION_USER" ]; then
	echo "Creating replication user..."
    # Extract replication user credentials from MARIADB_CREATE_REPLICATION_USER variable
    REPLICATION_USER=$(echo $MARIADB_CREATE_REPLICATION_USER | cut -d':' -f1)
    REPLICATION_PASSWORD=$(echo $MARIADB_CREATE_REPLICATION_USER | cut -d':' -f2)

    # Create replication user
    mariadb -e "CREATE USER '$REPLICATION_USER'@'%' IDENTIFIED BY '$REPLICATION_PASSWORD';"
	mariadb -e "GRANT REPLICATION REPLICA ON *.* TO '$REPLICATION_USER'@'%';"
fi

# If MARIADB_CREATE_MAXSCALE_USER is specified, create user for MaxScale
if [ -n "$MARIADB_CREATE_MAXSCALE_USER" ]; then
	echo "Creating MaxScale user..."
    # Extract MaxScale user credentials from MARIADB_CREATE_MAXSCALE_USER variable
    MAXSCALE_USER=$(echo $MARIADB_CREATE_MAXSCALE_USER | cut -d':' -f1)
    MAXSCALE_PASSWORD=$(echo $MARIADB_CREATE_MAXSCALE_USER | cut -d':' -f2)

    # Create MaxScale user
    mariadb -e "CREATE USER '$MAXSCALE_USER'@'%' IDENTIFIED BY '$MAXSCALE_PASSWORD';"
	mariadb -e "GRANT SHOW DATABASES, SUPER, REPLICATION CLIENT, RELOAD, PROCESS, SHOW DATABASES, EVENT ON *.* TO '$MAXSCALE_USER'@'%';"
	mariadb -e "GRANT SELECT ON mysql.columns_priv TO '$MAXSCALE_USER'@'%';"
	mariadb -e "GRANT SELECT ON mysql.db TO '$MAXSCALE_USER'@'%';"
	mariadb -e "GRANT SELECT ON mysql.procs_priv TO '$MAXSCALE_USER'@'%';"
	mariadb -e "GRANT SELECT ON mysql.proxies_priv TO '$MAXSCALE_USER'@'%';"
	mariadb -e "GRANT SELECT ON mysql.roles_mapping TO '$MAXSCALE_USER'@'%';"
	mariadb -e "GRANT SELECT ON mysql.tables_priv TO '$MAXSCALE_USER'@'%';"
	mariadb -e "GRANT SELECT ON mysql.user TO '$MAXSCALE_USER'@'%';"
fi

# If MARIADB_RESTORE_FROM is specified, create backup and restore it
if [ -n "$MARIADB_RESTORE_FROM" ]; then
	echo "Restoring database..."

    # Extract backup server credentials from MARIADB_RESTORE_FROM variable
    BACKUP_USER=$(echo $MARIADB_RESTORE_FROM | cut -d':' -f1)
    BACKUP_PASSWORD=$(echo $MARIADB_RESTORE_FROM | cut -d':' -f2 | cut -d'@' -f1)
    BACKUP_HOST=$(echo $MARIADB_RESTORE_FROM | cut -d':' -f2 | cut -d'@' -f2)
    BACKUP_PORT=$(echo $MARIADB_RESTORE_FROM | cut -d':' -f3)

	# Wait for the backup server to become available
	echo "Waiting for backup server to become available..."
	while ! mariadb --user=$BACKUP_USER --password=$BACKUP_PASSWORD --host=$BACKUP_HOST --port=$BACKUP_PORT -e "select version()"; do
		sleep 5
	done
	echo "Backup server available."

    # Take a backup using mariadb-backup
    mariadb-backup --backup --innodb-use-native-aio --parallel=4 --rsync --safe-slave-backup --user=$BACKUP_USER --password=$BACKUP_PASSWORD --host=$BACKUP_HOST --port=$BACKUP_PORT --target-dir=/tmp/backup/

    # Restore the backup in the container
	echo "Preparing backup..."
	mariadb-backup --prepare --target-dir=/tmp/backup/
	echo "Stopping server..."
	kill $mariadbd_pid
	echo "Restoring backup..."
	mariadb-backup --move-back --force-non-empty-directories --datadir=/var/lib/mysql/ --target-dir=/tmp/backup/
	chown -R mysql:mysql /var/lib/mysql
	echo "Restarting mariadbd in the background..."
	mariadbd --user=root --skip-networking &
	mariadbd_pid=$!

	# Wait for the server to start
	echo "Waiting for the server to restart..."
	while ! mariadb-admin ping -u root --silent; do
		sleep 1
	done

	# Wait for the server to become available
	echo "Waiting for the server to become available..."
	while ! mariadb -u root -e "select version()"; do
		sleep 5
	done
	echo "Server restarted and available."
fi

# If MARIADB_REPLICATE_FROM is specified, configure replication
if [ -n "$MARIADB_REPLICATE_FROM" ]; then
	echo "Setting up replication..."
    # Extract primary server credentials from MARIADB_REPLICATE_FROM variable
    PRIMARY_USER=$(echo $MARIADB_REPLICATE_FROM | cut -d':' -f1)
    PRIMARY_PASSWORD=$(echo $MARIADB_REPLICATE_FROM | cut -d':' -f2 | cut -d'@' -f1)
    PRIMARY_HOST=$(echo $MARIADB_REPLICATE_FROM | cut -d':' -f2 | cut -d'@' -f2)
    PRIMARY_PORT=$(echo $MARIADB_REPLICATE_FROM | cut -d':' -f3)

    # Setup replication with primary server
	echo "Setting GTID replica position..."
	log_info=($(cat /tmp/backup/xtrabackup_binlog_info))
	log_pos=${log_info[1]}
	mariadb -e "SET GLOBAL gtid_slave_pos=$log_pos;"
	echo "Changing MASTER..."
	mariadb -e "CHANGE MASTER TO MASTER_HOST='$PRIMARY_HOST', MASTER_PORT=$PRIMARY_PORT, MASTER_USER='$PRIMARY_USER', MASTER_PASSWORD='$PRIMARY_PASSWORD'"
	echo "Starting replica..."
	mariadb -e "START REPLICA;"
fi

echo "Restarting mariadbd..."
kill $mariadbd_pid

exec "$@"