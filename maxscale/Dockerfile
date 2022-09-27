FROM ubuntu
COPY maxscale/copy/ /
RUN apt-get update; apt-get install curl -y && \
	curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash && \
	apt-get update -y && \
	apt-get install maxscale -y && \
	chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

