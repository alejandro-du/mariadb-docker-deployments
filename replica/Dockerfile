FROM mariadb
ENV MARIADB_ROOT_PASSWORD="password"
ENV MARIADB_DATABASE="demo"
ENV MARIADB_USER="user"
ENV MARIADB_PASSWORD="password"
COPY replica/copy/ /
EXPOSE 3306
ENTRYPOINT gosu mysql docker-entrypoint.sh --server-id $(shuf -i 2-1000000 -n 1)