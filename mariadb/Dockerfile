# Base image
FROM rockylinux:9.3

# Copy files from mariadb-es/copy/ directory to root
COPY shared/ /

# Download the MariaDB repository setup script
RUN dnf install -y curl --allowerasing && \
	curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup > mariadb_repo_setup && \
	# Set execute permissions for .sh files
		chmod +x /docker-entrypoint-initdb.d/*.sh mariadb_repo_setup && \
	# Setup the MariaDB repository
	./mariadb_repo_setup --mariadb-server-version="mariadb-11.4.2" && \
	dnf -y install MariaDB

# Expose MariaDB port
EXPOSE 3306

# Start MariaDB server
CMD ["sh", "-c", "mariadbd --user=root --log-bin=mariadb-bin.log --binlog-format=mixed --gtid-strict-mode=1 --log-slave-updates=1 --skip-name-resolve=1"]

# Set entrypoint script
ENTRYPOINT ["/docker-entrypoint-initdb.d/entrypoint.sh"]
