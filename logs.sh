echo
echo "************************ logs 1 ************************"
docker logs mariadb-test-1

echo
echo "************************ logs 2 ************************"
docker logs mariadb-test-2

echo
echo "****************** show binlog status ******************"
docker exec -it mariadb-test-1 mariadb --password='password' --execute='show binlog status\G'

echo
echo "***************** show replica status ******************"
docker exec -it mariadb-test-2 mariadb --password='password' --execute='show replica status\G'

echo
echo "********************** containers **********************"
docker container ls -a
