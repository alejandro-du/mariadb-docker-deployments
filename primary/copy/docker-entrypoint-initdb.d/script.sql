CREATE USER 'replication_user'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION REPLICA ON *.* TO 'replication_user'@'%';
RESET MASTER;
