# Docker Datacenter 2 nodes installation (UCP+DTR)

## Prerequisites

- [x] Virtualbox 5.x or later
- [x] Vagrant by HashiCorp

## Build your Vagrant/Virtualbox environment

Download the sandbox scripts. The Vagrantfile will build a controller and a node, the bootstrap.sh install on each VM the docker daemon CS.

### MODIFIER CHEMINS vers les scripts !!!!!!!!

```{r, engine='bash'}
$ mkdir sandbox_DUCP
$ curl -O https://raw.githubusercontent.com/Treeptik/docker-courses/master/12-docker-datacenter-2nodes-install/Vagrantfile
$ curl -O https://raw.githubusercontent.com/Treeptik/docker-courses/master/12-docker-datacenter-2nodes-install/bootstrap.sh
```
Build your 2 nodes:

```{r, engine='bash'}
$ vagrant up
```
Wait few minutes... take a coffee

## Install the UCP controller

Login to your controller VM:

```{r, engine='bash'}
$ vagrant ssh dd-controller
```
In this example we’ll be running the install command interactively, so that the command prompts for the necessary configuration values. You can also use flags to pass values to the install command.

Run the UCP installer with the following command:

```{r, engine='bash'}
$ docker run --rm -it --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp install -i \
  --host-address 192.168.50.10
```

When asking on "Additional aliases", press enter.

After the setup process, you can now login to the UCP dashboard at https://192.168.50.10:443

![UCP Login]
(img/ucp_login.png)

On the next screen upload you Docker Datacenter licence and then you can access for the first time to the DUCP dashboard:

![UCP Dashboard]
(img/ucp_dashboard_1.png)

## Install the UCP node 1

Login to your node1 VM:

```{r, engine='bash'}
vagrant ssh dd-node1
```


