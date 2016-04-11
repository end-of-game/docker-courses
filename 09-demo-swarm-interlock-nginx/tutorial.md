# Docker Swarm + Interlock + Nginx

## Introduction

Purpose of this demo:

* Setup a Swarm Cluster using docker-machine
* Deploy NGINX and Tomcat containers with docker-compose
* Analyze and observe Nginx loadbalancing
* Analyze and observe dynamic configuration of NGINX when new instances are added

## Setup a Swarm Cluster using docker-machine

In this step we will use this bash script: init-cluster-swarm.sh

This script does the following operations:

- Create a docker-machine host for Consul
- Run a Consul container on the Consul host
- Create a Swarm Master host
- Create a 2nd host Swarm node
- Create a 3rd host Swarm node


Simply run the bash script to build the complete Docker environment:

```bash
chmod +x init-cluster-swarm.sh
./init-cluster-swarm.sh
```
