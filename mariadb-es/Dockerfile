FROM rockylinux:8
ARG CUSTOMER_DOWNLOAD_TOKEN
ENV CUSTOMER_DOWNLOAD_TOKEN=$CUSTOMER_DOWNLOAD_TOKEN
COPY mariadb-es/copy/ /
RUN curl -LsS https://dlm.mariadb.com/enterprise-release-helpers/mariadb_es_repo_setup > mariadb_es_repo_setup && \
	chmod +x mariadb_es_repo_setup && \
	./mariadb_es_repo_setup --token="$CUSTOMER_DOWNLOAD_TOKEN" --apply --skip-maxscale --skip-tools --mariadb-server-version="10.6" && \
	yum install MariaDB-server MariaDB-backup procps-ng openssh-server openssh-clients sshpass -y && \
	ssh-keygen -A && \
	echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
	echo 'root:Password123!' | chpasswd && \
	chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT docker-entrypoint.sh
