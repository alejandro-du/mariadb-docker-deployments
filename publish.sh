echo "************************ publish *************************"
host="piserver.local:5000/"


docker tag alejandrodu/mariadb-es ${host}alejandrodu/mariadb-es
docker tag alejandrodu/mariadb-maxscale ${host}alejandrodu/mariadb-maxscale

docker push ${host}alejandrodu/mariadb-es
docker push ${host}alejandrodu/mariadb-maxscale

echo