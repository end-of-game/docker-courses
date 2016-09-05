#!/bin/bash

# #########################################################
# REINIT THE ENVIRONMENT
# #########################################################
docker kill $(docker ps -aq)
docker rm $(docker ps -aq)
# docker rmi $(docker images -q)

# #########################################################
# PULL THE IMAGES 
# #########################################################
docker pull ubuntu:saucy
docker pull ubuntu:latest
docker pull ubuntu
docker pull mysql

# #########################################################
# LIST THE IMAGES
# #########################################################
docker images

# #########################################################
# TIMEX : PIANO
# #########################################################
time docker run -d ubuntu sh -c 'while true ; do echo hello world ; sleep 1 ; done'

# #########################################################
# DOCKER RUN (with error)
# #########################################################
docker run --name demo1 -d ubuntu sh -c 'while true ; do echo hello world ; sleep 1 ; done'
docker run --name demo1 -d ubuntu sh -c 'while true ; do echo hello world ; sleep 1 ; done'

# #########################################################
# DOCKER COMMANDS
# #########################################################
docker ps
docker logs --tail 10 --follow $(docker ps -aql)
docker stop <containerId>
docker ps
docker ps -a

# #########################################################
# DOCKER CONTAINERS PERSISTENCE
# #########################################################
docker rm -f $(docker ps -aq)
docker run --name demo1 -it ubuntu bash
touch /file1.txt
exit # container is dead
docker ps -a 
docker start demo
docker exec -it demo1 ls -la
docker inspect demo1
# show the persistance files
vm-docke-rmachine-with-root> find /mnt -name file1.txt
	
# #########################################################
# DOCKER COMMIT EXAMPLES
# #########################################################
docker rm -f $(docker ps -aq)
docker run -i -t ubuntu bash
touch /custom.txt
exit
docker ps -a
docker commit <containerId> demojug/ubuntu-custom
docker run -it demojug/ubuntu-custom bash
ls -la
exit

# #########################################################
# DOCKER VOLUMES EXAMPLES
# #########################################################
docker run -v /Users/nicolas/demojug:/transfert -it ubuntu bash
touch /transfert/joueur.txt
exit
#aller dans /Users/nicolas/demojug et creer un nouveau fichier
docker ps -aq
docker start -a $(docker ps -aql)



