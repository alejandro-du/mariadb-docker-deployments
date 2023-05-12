echo
echo "************************ logs 1 ************************"
docker logs mariadb-test-1

echo
echo "************************ logs 2 ************************"
docker logs mariadb-test-2

echo
echo "****************** show binlog status ******************"
docker exec -it mariadb-test-1 mariadb --password='Password123!' --execute='show binlog status\G'

echo
echo "***************** show replica status ******************"
docker exec -it mariadb-test-2 mariadb --password='Password123!' --execute='show replica status\G'

echo
echo "***************** show replica status ******************"
docker exec -it mariadb-test-3 mariadb --password='password' --execute='show replica status\G'

#echo
#echo "**************** show maxscale servers *****************"
#docker exec -it mariadb-maxscale-1 maxctrl list servers
#
#echo
#echo "********************** containers **********************"
#docker container ls -a

echo
echo "Data in mariadb-test1"
docker exec -it mariadb-test-1 mariadb --execute "select * from demo.t"
echo "Data in mariadb-test2"
docker exec -it mariadb-test-2 mariadb --execute "select * from demo.t"
#echo "Data in mariadb-test3"
#docker exec -it mariadb-test-3 mariadb --execute "select * from demo.t"
