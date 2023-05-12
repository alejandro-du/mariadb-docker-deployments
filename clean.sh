echo "************************ clean *************************"

echo "Stopping containers..."
docker stop mariadb-test-1
docker stop mariadb-test-2
docker stop mariadb-test-3
#docker stop mariadb-maxscale-1

echo "Removing containers..."
docker container rm mariadb-test-1 -v
docker container rm mariadb-test-2 -v
docker container rm mariadb-test-3 -v
#docker container rm mariadb-maxscale-1 -v

echo