echo "************************ clean *************************"

docker stop mariadb-test-1
docker stop mariadb-test-2
docker stop mariadb-test-3
docker container rm mariadb-test-1 -v
docker container rm mariadb-test-2 -v
docker container rm mariadb-test-3 -v

echo