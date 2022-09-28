echo "************************ publish *************************"
host=${1:-thinkpad.local:5000}

docker tag alejandrodu/mariadb-single-node $host/alejandrodu/mariadb-single-node
docker tag alejandrodu/mariadb-primary $host/alejandrodu/mariadb-primary
docker tag alejandrodu/mariadb-replica $host/alejandrodu/mariadb-replica

docker push $host/alejandrodu/mariadb-single-node
docker push $host/alejandrodu/mariadb-primary
docker push $host/alejandrodu/mariadb-replica