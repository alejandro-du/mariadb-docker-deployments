echo "************************ publish *************************"
host=${1:-thinkpad.local:5000}

docker tag alejandrodu/mariadb-arm-primary $host/alejandrodu/mariadb-arm-primary
docker tag alejandrodu/mariadb-arm-replica $host/alejandrodu/mariadb-arm-replica

docker push $host/alejandrodu/mariadb-arm-primary
docker push $host/alejandrodu/mariadb-arm-replica