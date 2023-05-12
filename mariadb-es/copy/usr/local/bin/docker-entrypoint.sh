#!/bin/bash

echo "Staring sshd..."
/usr/sbin/sshd -D &

echo "Starting mariadbd..."
mariadbd --user=mysql &
sleep 3

until mariadb -u root --execute="SELECT 1"
do
	echo "Waiting for mariadbd..."
	sleep 3
done

echo "Creating demo database and user..."
mariadb -u root --execute="CREATE DATABASE IF NOT EXISTS demo"
mariadb -u root --execute="CREATE USER IF NOT EXISTS 'user'@'%' IDENTIFIED BY 'Password123!'"
mariadb -u root --execute="GRANT ALL PRIVILEGES ON demo.* TO 'user'@'%'"

echo "Creating maxscale user..."
mariadb -u root --execute="CREATE USER 'maxscale'@'%' IDENTIFIED BY 'Password123!'"
mariadb -u root --execute="GRANT SHOW DATABASES ON *.* TO 'maxscale'@'%'"
mariadb -u root --execute="GRANT SELECT ON mysql.columns_priv TO 'maxscale'@'%'"
mariadb -u root --execute="GRANT SELECT ON mysql.db TO 'maxscale'@'%'"
mariadb -u root --execute="GRANT SELECT ON mysql.procs_priv TO 'maxscale'@'%'"
mariadb -u root --execute="GRANT SELECT ON mysql.proxies_priv TO 'maxscale'@'%'"
mariadb -u root --execute="GRANT SELECT ON mysql.roles_mapping TO 'maxscale'@'%'"
mariadb -u root --execute="GRANT SELECT ON mysql.tables_priv TO 'maxscale'@'%'"
mariadb -u root --execute="GRANT SELECT ON mysql.user TO 'maxscale'@'%'"
mariadb -u root --execute="GRANT SUPER, REPLICATION CLIENT, RELOAD, PROCESS, SHOW DATABASES, EVENT ON *.* TO 'maxscale'@'%'"


if [[ ! -z $MARIADB_SETUP_PRIMARY ]]; then
	echo "Setting up primary..."
	mariadb -u root --execute="CREATE USER 'replication_user'@'%' IDENTIFIED BY 'Password123!'"
	mariadb -u root --execute="GRANT REPLICATION REPLICA, REPLICATION CLIENT ON *.* TO replication_user@'%'"
	mariadb -u root --execute="CREATE table demo.t(c text); insert into demo.t values('it works!');"
fi

if [[ ! -z $MARIADB_RESTORE_SSH_HOST ]]; then
	echo "Taking backup from $MARIADB_RESTORE_SSH_HOST..."
	target_dir="/root/backup-$(shuf -i 2-1000000 -n 1)/"
	command="sshpass -p \"$MARIADB_RESTORE_SSH_PASSWORD\" ssh -p 22 -o StrictHostKeyChecking=no $MARIADB_RESTORE_SSH_USER@$MARIADB_RESTORE_SSH_HOST mariadb-backup --backup --user=root --target-dir=$target_dir"
	until eval $command 
	do
		echo "Waiting for primary..."
		sleep 5
	done
	
	echo "Moving backup from $MARIADB_RESTORE_SSH_HOST..."
	mkdir $target_dir
	command="sshpass -p \"$MARIADB_RESTORE_SSH_PASSWORD\" scp -P 22 -o StrictHostKeyChecking=no -r $MARIADB_RESTORE_SSH_USER@$MARIADB_RESTORE_SSH_HOST:$target_dir* $target_dir"
	eval $command
	command="sshpass -p \"$MARIADB_RESTORE_SSH_PASSWORD\" ssh -p 22 -o StrictHostKeyChecking=no $MARIADB_RESTORE_SSH_USER@$MARIADB_RESTORE_SSH_HOST rm -rf $target_dir"
	eval $command
	mariadb-backup --prepare --target-dir=$target_dir

	echo "Stopping mariadbd..."
	PID=$(pgrep -x 'mariadbd')
	if [[ ! -z $PID ]]; then
		echo 'Sending SIGTERM'
		kill $PID 2> /dev/null
		PID=$(pgrep -x 'mariadbd')
		if [[ ! -z $PID ]]; then
			echo 'Sending SIGKILL'
			kill -9 $PID 2> /dev/null
		fi
	fi
	sleep 3

	echo "Restoring backup..."
	rm -rf /var/lib/mysql
	mariadb-backup --copy-back --target-dir=$target_dir
	chown -R mysql:mysql /var/lib/mysql

	echo "Starting mariadbd..."
	mariadbd --user=mysql &
	sleep 3
	
	until mariadb -u root --execute="SELECT 1"
	do
		echo "Waiting for mariadbd..."
		sleep 3
	done

	echo "Starting replication..."
	log_info=($(cat $target_dirxtrabackup_binlog_info))
	log_pos=${log_info[1]}
	sql="CHANGE MASTER TO MASTER_USER=\"replication_user\", MASTER_HOST=\"$MARIADB_RESTORE_SSH_HOST\", MASTER_PASSWORD=\"Password123\!\", MASTER_USE_GTID=slave_pos; START REPLICA;"
	mariadb -u root --execute="$sql"
fi

echo "Restarting mariadbd..."
PID=$(pgrep -x 'mariadbd')
if [[ ! -z $PID ]]; then
	echo 'Sending SIGTERM'
	kill $PID 2> /dev/null
	PID=$(pgrep -x 'mariadbd')
	if [[ ! -z $PID ]]; then
		echo 'Sending SIGKILL'
		kill -9 $PID 2> /dev/null
	fi
fi
sleep 3

mariadbd --user=mysql --log-bin=mariadb-bin.log --server-id=$(shuf -i 2-1000000 -n 1)
