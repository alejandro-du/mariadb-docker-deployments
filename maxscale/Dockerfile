FROM rockylinux:8
COPY maxscale/copy/ /
RUN curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup > mariadb_repo_setup && \
	chmod +x /usr/local/bin/docker-entrypoint.sh mariadb_repo_setup && \
	./mariadb_repo_setup --mariadb-maxscale-version="24.02.2" && \
	dnf -y install procps-ng maxscale -y

ENTRYPOINT docker-entrypoint.sh && maxscale -U maxscale
EXPOSE 4000 8989 27017
