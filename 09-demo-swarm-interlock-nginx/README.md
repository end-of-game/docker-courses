# Docker Swarm + Interlock + Nginx

## Introduction

Purpose of this demo:

* Setup a Swarm Cluster using docker-machine
* Deploy NGINX and Tomcat containers with docker-compose
* Analyze and observe dynamic configuration of NGINX when new instances are added
* Analyze and observe Nginx loadbalancing

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
$ chmod +x init-cluster-swarm.sh
$ ./init-cluster-swarm.sh
```
##Deploy NGINX and Tomcat containers with docker-compose

Once the Swarm Cluster is up let's take a look at our setup:

```{r, engine='bash', count_lines}
$ docker-machine ls
NAME              ACTIVE      DRIVER       STATE     URL                         SWARM              DOCKER    ERRORS
agent1            -           virtualbox   Running   tcp://192.168.99.102:2376   manager            v1.10.3   
agent2            -           virtualbox   Running   tcp://192.168.99.103:2376   manager            v1.10.3   
consul-keystore   -           virtualbox   Running   tcp://192.168.99.100:2376                      v1.10.3   
manager           * (swarm)   virtualbox   Running   tcp://192.168.99.101:2376   manager (master)   v1.10.3
```

We can see the four virtual machines, one as the Consul keystore, one as the Swarm manager and two as Swarm nodes.

Download the Docker Compose file in your project directory:

```{r, engine='bash', count_lines}
$ curl - O https://raw.githubusercontent.com/ehazlett/interlock/master/docs/examples/nginx-swarm-machine/docker-compose.yml
```
We use an environment variable to configure Interlock to your Swarm cluster. Run the following to set it up:

```{r, engine='bash', count_lines}
$ export SWARM_HOST=tcp://$(docker-machine ip manager):3376
```

### Start Interlock

Connect your client shell to the Swarm manager daemon:

```{r, engine='bash', count_lines}
$ eval $(docker-machine env --swarm manager)
```

Bring up our Interlock container:

```{r, engine='bash', count_lines}
$ docker-compose up -d interlock
```

```docker ps``` on the manager print all containers in the cluster:

```
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                            NAMES
6e42cb04960b        ehazlett/interlock:1.0.1   "/bin/interlock -D ru"   3 minutes ago       Up 3 minutes        192.168.99.102:32768->8080/tcp   agent1/dockerswarminterlocknginx_interlock_1
```
```docker ps -a``` on the manager print all containers in the cluster and also the swarm containers such as clients and manager. We can see in the NAMES column the  containers per node dividing.

```
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                            NAMES
6e42cb04960b        ehazlett/interlock:1.0.1   "/bin/interlock -D ru"   3 minutes ago       Up 3 minutes        192.168.99.102:32768->8080/tcp   agent1/dockerswarminterlocknginx_interlock_1
beb0746aeb94        swarm:latest               "/swarm join --advert"   6 minutes ago       Up 6 minutes                                         agent2/swarm-agent
e27396ff7c34        swarm:latest               "/swarm join --advert"   7 minutes ago       Up 7 minutes                                         agent1/swarm-agent
e9c8a853a113        swarm:latest               "/swarm join --advert"   8 minutes ago       Up 8 minutes                                         manager/swarm-agent
0cc6cedf5119        swarm:latest               "/swarm manage --tlsv"   8 minutes ago       Up 8 minutes                                         manager/swarm-agent-master
```

### Start Nginx

Bring up our Nginx container:

```{r, engine='bash', count_lines}
$ docker-compose up -d nginx
```

### Start example App

Run ```docker ps``` and ```docker-machine ls``` to find the Nginx node IP.

Add an entry to your /etc/hosts in order to resolve the name "test.local" to the Nginx node IP, so we will access to the load-balanced app via web-browser.

Bring up the first example app instance:

```{r, engine='bash', count_lines}
$ docker-compose up -d app
```
Open the compose logs in an other shell tab:

```{r, engine='bash', count_lines}
$ export SWARM_HOST=tcp://$(docker-machine ip manager):3376
$ eval $(docker-machine env --swarm manager)
$ docker-compose logs
```
We can see the first app detection in the logs:

```
app_1       | 2016/04/11 21:13:06 listening on :8080
interlock_1 | DEBU[1368] updating load balancers                      
interlock_1 | DEBU[1368] websocket endpoints: []                       ext=nginx
interlock_1 | DEBU[1368] alias domains: []                             ext=nginx
interlock_1 | INFO[1368] test.local: upstream=192.168.99.103:32768     ext=nginx
interlock_1 | INFO[1368] configuration updated                         ext=nginx
interlock_1 | INFO[1368] restarted proxy container: id=9203d9264890 name=/agent1/dockerswarminterlocknginx_nginx_1  ext=nginx
interlock_1 | DEBU[1368] reload duration: 18.07ms                     
```