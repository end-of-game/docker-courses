# Docker Swarm + Interlock + Nginx

## Introduction

Purpose of this demo:

* Setup a Swarm Cluster using docker-machine
* Deploy NGINX and Tomcat containers with docker-compose
* Analyze and observe Nginx loadbalancing
* Analyze and observe dynamic configuration of NGINX when new instances are added

This demo was made from Evan Hazlett examples using its Interlock extension developed for Docker:

**https://github.com/ehazlett/interlock**

## Setup a Swarm Cluster using docker-machine

In this step we will use this bash script:

**https://github.com/Treeptik/docker-courses/blob/master/09-demo-swarm-interlock-nginx/init-cluster-swarm.sh**

This script does the following operations:

- Create a docker-machine host for Consul
- Run a Consul container on the Consul host
- Create a Swarm Master host
- Create a 2nd host Swarm node
- Create a 3rd host Swarm node


Simply run the bash script to build the complete Docker environment:

```{r, engine='bash', count_lines}
$chmod +x init-cluster-swarm.sh
$./init-cluster-swarm.sh
```
##Deploy NGINX and Tomcat containers with docker-compose

Once the Swarm Cluster is up let's take a look at our setup:

```{r, engine='bash', count_lines}
$docker-machine ls
NAME              ACTIVE      DRIVER       STATE     URL                         SWARM              DOCKER    ERRORS
agent1            -           virtualbox   Running   tcp://192.168.99.102:2376   manager            v1.10.3   
agent2            -           virtualbox   Running   tcp://192.168.99.103:2376   manager            v1.10.3   
consul-keystore   -           virtualbox   Running   tcp://192.168.99.100:2376                      v1.10.3   
manager           * (swarm)   virtualbox   Running   tcp://192.168.99.101:2376   manager (master)   v1.10.3
```

We can see the four virtual machines, one as the Consul keystore, one as the Swarm manager and two as the Swarm nodes.

Download the Docker Compose file in your project directory:

```{r, engine='bash', count_lines}
$curl - O https://raw.githubusercontent.com/ehazlett/interlock/master/docs/examples/nginx-swarm-machine/docker-compose.yml
```
We use an environment variable to configure Interlock to your Swarm cluster. Run the following to set it up:

```{r, engine='bash', count_lines}
$export SWARM_HOST=tcp://$(docker-machine ip manager):3376
```

### Start Interlock

Connect your shell to th Swarm Manager host:

```{r, engine='bash', count_lines}
$echo $(docker-machine ip manager)
```

Bring up our Interlock container:

```{r, engine='bash', count_lines}
$docker-compose up -d interlock
```

