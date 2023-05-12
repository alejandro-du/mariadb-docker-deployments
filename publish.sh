echo "************************ publish *************************"
host="piserver.local:5000"

docker push ${host}/alejandrodu/mariadb-es
docker push ${host}/alejandrodu/mariadb-maxscale

#docker tag alejandrodu/mariadb-es-single-node ${host}alejandrodu/mariadb-es-single-node
#docker tag alejandrodu/mariadb-es-primary ${host}alejandrodu/mariadb-es-primary
#docker tag alejandrodu/mariadb-es-replica ${host}alejandrodu/mariadb-es-replica

#docker push ${host}alejandrodu/mariadb-es-single-node
#docker push ${host}alejandrodu/mariadb-es-primary
#docker push ${host}alejandrodu/mariadb-es-replica