function sql() {
	mariadb -u root --password="$MARIADB_ROOT_PASSWORD" --execute="$1"
}

sql "
	CHANGE MASTER TO
		MASTER_HOST='$MARIADB_PRIMARY_HOST',
		MASTER_PORT=3306,
		MASTER_USER='replication_user',
		MASTER_PASSWORD='password',
		MASTER_LOG_FILE='primary_log_bin.000002',
		MASTER_LOG_POS=334,
		MASTER_USE_GTID=replica_pos;
"
