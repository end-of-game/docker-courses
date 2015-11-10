# #######################################
# WORK WITH CONTAINERS
# #######################################

docker run -it ubuntu bash

> touch /nicolas.txt

> exit

docker ps -a

docker export containerId > export.tar

docker rm -f contanerId

docker import ./export.tar

docker images

# #######################################
# WORK WITH IMAGES
# #######################################

docker run -it ubuntu bash

> touch /nicolas.txt

> exit

docker commit <containerId> imageNicolas

docker save imageNicolas > nicolas.tar

docker load < nicolas.tar



