echo "************************ clean *************************"

docker stop mariadb-test-1
docker stop mariadb-test-2
docker system prune --force
docker volume prune --force

echo