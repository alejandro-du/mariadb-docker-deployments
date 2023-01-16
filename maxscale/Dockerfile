FROM rockylinux:8
COPY maxscale/copy/ /
RUN curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash && \
	dnf -y install procps-ng maxscale -y && \
	chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT docker-entrypoint.sh && maxscale -U maxscale
