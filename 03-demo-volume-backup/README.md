docker build -t=image3 .

docker run -d --name database image3 tail -f /dev/null
docker run -d --link=database:db --name application ubuntu tail -f /dev/null
docker inspect application
docker exec -it application env | grep DB

---------------------------------------

docker create -v /dbdata --name dbdata ubuntu
docker run -d --volumes-from dbdata --name db1 ubuntu tail -f /dev/null
docker run -d --volumes-from dbdata --name db2 ubuntu tail -f /dev/null 

docker exec db1 touch /dbdata/bonjour1.txt
docker exec db2 touch /dbdata/bonjour2.txt

docker run --volumes-from dbdata -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata
