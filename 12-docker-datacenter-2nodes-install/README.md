# Docker Datacenter 2 nodes installation (UCP+DTR)

## Prerequisites

- [x] Virtualbox 5.x or later
- [x] Vagrant by HashiCorp

## Build your Vagrant/Virtualbox environment

Download the sandbox scripts. The Vagrantfile will build a controller and a node, the bootstrap.sh install on each VM the docker daemon CS.

### MODIFIER CHEMINS vers les scripts !!!!!!!!

```{r, engine='bash'}
$ mkdir sandbox_DUCP && cd sandbox_DUCP
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

To finish the setup process, restart the docker daemon:

```{r, engine='bash'}
service docker restart
```

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
Run the second node UCP installer:

```{r, engine='bash'}
docker run --rm -it --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp join -i \
  --host-address 192.168.50.11
```
To finish the setup process, restart the docker daemon:

```{r, engine='bash'}
service docker restart
```
The Dashboard page of UCP should list all your controller nodes now:

![UCP Dashboard]
(img/ucp_dashboard_2.png)

## Download a client certificate bundle

> THIS STEP CONNECT YOUR DOCKER CLIENT TO THE UCP CLUSTER

To download a client certificate bundle, log into UCP, and navigate to your profile page.

Click the Create a Client Bundle button to download the certificate bundle and save it in our vagrant project directory in order to grant access inside the two VMs.

On the host shell, inside the vagrant project directory:

```{r, engine='bash'}
$ unzip ucp-bundle-admin.zip
```
Login to your controller VM:

```{r, engine='bash'}
$ vagrant ssh dd-controller
```
Navigate to the directory where you downloaded the bundle. Then run the env.sh script to start using the client certificates.

```{r, engine='bash'}
$ cd /vagrant/ucp-bundle-admin
$ eval $(<env.sh)
```

The env.sh script updates the DOCKER_HOST and DOCKER_CERT_PATH environment variables to use the certificates you downloaded.

From now on, when you use the Docker CLI client, it includes your client certificates as part of the request to the Docker Engine. You can now use the docker info command to see if the certificates are being sent to the Docker Engine.