# Base image
FROM rockylinux:8

# Copy files from mariadb-es/copy/ directory to root
COPY shared/ /

# Download the MariaDB repository setup script
RUN curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup > mariadb_repo_setup && \
	# Set execute permissions for .sh files
	chmod +x /docker-entrypoint-initdb.d/*.sh mariadb_repo_setup && \
	# Setup the MariaDB repository
	./mariadb_repo_setup --mariadb-server-version="mariadb-10.11" && \
	yum install MariaDB-server MariaDB-backup -y

# Expose MariaDB port
EXPOSE 3306

# Start MariaDB server
CMD ["sh", "-c", "mariadbd --user=root --log-bin=mariadb-bin.log --binlog-format=mixed --gtid-strict-mode=1 --log-slave-updates=1 --skip-name-resolve=1"]

# Set entrypoint script
ENTRYPOINT ["/docker-entrypoint-initdb.d/entrypoint.sh"]
