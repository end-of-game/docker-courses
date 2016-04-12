# Docker and PostgreSQL with BTRFS support demo (Vagrant/Virtualbox version)

## Introduction

Purpose of this demo:

* Understand and use BTRFS on Linux
* Learn integration with Docker
* Use case with a PostgreSQL container and a BTRFS data volume

## Understand and use BTRFS on Linux

## Learn integration with Docker 

## Use case with a PostgreSQL container and a BTRFS data volume

### Prerequisites

- [x] Virtualbox 5.x or later
- [x] Vagrant by HashiCorp

### Build your Vagrant/Virtualbox environment

Download the sandbox scripts. The Vagrantfile add a 2nd hard drive for creating btrfs partitions, the bootstrap.sh runs some system tasks for the first start.

```{engine='bash'}
$ mkdir sandbox_CentOS && cd sandbox_CentOS
$ curl -O https://raw.githubusercontent.com/Treeptik/docker-courses/master/10-demo-btrfs-postgres/sandbox_CentOS/Vagrantfile
$ curl -O https://raw.githubusercontent.com/Treeptik/docker-courses/master/10-demo-btrfs-postgres/sandbox_CentOS/bootstrap.sh
```
Run your Vagrant Centos sandbox:

```{engine='bash'}
$ vagrant up
```
Wait few minutes... take a coffee

### Create the BTRFS volumes

### Configure Docker to use BTRFS

### Deploy PostgreSQL container

Create a new Postgre Container
```
docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres
```

Connect to it with the old school fashion ! 
```
docker run -it  --link some-postgres:postgres --rm \
                -v `pwd`/scripts:/scripts \
                -v /data/bdd:/var/lib/postgresql/data \
                postgres \
                sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
```

Else with the way for the new kids on the block 

```
docker exec -it some-postgres bash
psql -U postgres
```

### BDD Scalability tests

`postgres=# \i /scripts/users.sql`

#### Compare the running time of an SQL script

#### Benchmark BTRFS snapshot system with this data


