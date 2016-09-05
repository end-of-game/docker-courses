#!/bin/bash

## ###############################
## NETTOYAGE
## ###############################

docker rm -f $(docker ps -aq)
docker rmi demo/tomcat-data

## ###############################
## BUILD IMAGE DATE
## ###############################

cd tomcat-data
docker build --tag="demo/tomcat-data" .

## ###############################
## RUN DATA CONTAINER
## ###############################
docker run -it --name=tdata demo/tomcat-data bash
exit

## ##################################### ##
## RUN TOMCAT CONTAINER WITH ASSOCIATION ##
## ##################################### ##
docker run --name=tomcat81 -d --volumes-from tdata tutum/tomcat:8.0
docker run --name=tomcat82 -d -p 8080 --volumes-from tdata tutum/tomcat:8.0
docker run --name=tomcat83 -d -p 8080:8080 --volumes-from tdata tutum/tomcat:8.0

