# Docker Datacenter two nodes installation (UCP+DTR)

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

## Install the Universal Control Pane "controller"

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

## Install the Universal Control Pane "node 1"

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

From now on, when you use the Docker CLI client, it includes your client certificates as part of the request to the Docker Engine. You can now use the docker info command to see if you can see the cluster infos:

```
$ docker info
Containers: 12
 Running: 12
 Paused: 0
 Stopped: 0
Images: 20
Server Version: swarm/1.2.3
Role: primary
Strategy: spread
Filters: health, port, containerslots, dependency, affinity, constraint
Nodes: 2
 dd-controller: 192.168.50.10:12376
  └ ID: KRVM:ZT23:EP6M:EV5Z:BOLL:6GVU:7YZV:RMGG:RCHN:MW72:GEXF:3WJW
  └ Status: Healthy
  └ Containers: 10
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 3.086 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-87-generic, operatingsystem=Ubuntu 14.04.4 LTS, storagedriver=aufs
  └ UpdatedAt: 2016-06-10T12:53:43Z
  └ ServerVersion: 1.10.3-cs3
 dd-node1: 192.168.50.11:12376
...
...
```

## Install Docker Trusted Registry (DTR)

Login on a cluster node and setup your CLI to use the Client Bundle as explained before, and run:

```{r, engine='bash'}
$ curl -k https://192.168.50.10/ca > ucp-ca.pem
$ docker run -it --rm \
  docker/dtr install \
  --ucp-url https://192.168.50.10 \
  --dtr-external-url 192.168.50.10 \
  --ucp-ca "$(cat ucp-ca.pem)"
```

### Check that DTR is running

In your browser, navigate to the the Docker Universal Control Plane web UI, and navigate to the Applications screen. DTR should be listed as an application.

You can also access the DTR web UI, to make sure it is working. In your browser, navigate to the address were you installed DTR (https://192.168.50.11)

![UCP Dashboard]
(img/dtr_dashboard_1.png)