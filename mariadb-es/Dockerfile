# Base image
FROM rockylinux:8

# The customer download token from https://customers.mariadb.com/downloads/token
ARG CUSTOMER_DOWNLOAD_TOKEN

# Store the customer dowonload token in an environment variable
ENV CUSTOMER_DOWNLOAD_TOKEN=$CUSTOMER_DOWNLOAD_TOKEN

# Copy files from mariadb-es/copy/ directory to root
COPY shared/ /

# Download the MariaDB Enterprise repository setup script
RUN curl -LsS https://dlm.mariadb.com/enterprise-release-helpers/mariadb_es_repo_setup > mariadb_es_repo_setup && \
	# Set execute permissions for .sh files
	chmod +x /docker-entrypoint-initdb.d/*.sh mariadb_es_repo_setup && \
	# Setup the MariaDB Enterprise repository using the customer download token
	./mariadb_es_repo_setup --token="$CUSTOMER_DOWNLOAD_TOKEN" --apply --skip-maxscale --skip-tools --mariadb-server-version="10.6.18-14" && \
	yum install MariaDB-server MariaDB-backup -y

# Expose MariaDB port
EXPOSE 3306

# Start MariaDB server
CMD ["sh", "-c", "mariadbd --user=root --log-bin=mariadb-bin.log --binlog-format=mixed --gtid-strict-mode=1 --log-slave-updates=1 --skip-name-resolve=1"]

# Set entrypoint script
ENTRYPOINT ["/docker-entrypoint-initdb.d/entrypoint.sh"]
