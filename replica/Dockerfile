FROM linuxserver/mariadb
ENV MYSQL_ROOT_PASSWORD="password"
ENV MYSQL_DATABASE="demo"
ENV MYSQL_USER="user"
ENV MYSQL_PASSWORD="password"
COPY replica/copy/ /
RUN echo "*/1 * * * * /bin/bash /start-replication.sh && crontab -r" >> /var/spool/cron/crontabs/root \
	&& chmod +x /start-replication.sh
ENTRYPOINT crond \
	&& echo "server_id = $RANDOM" >> /config/custom.cnf \
	&& /init
