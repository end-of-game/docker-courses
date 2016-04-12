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


