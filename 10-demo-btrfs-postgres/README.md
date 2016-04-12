# Docker with BTRFS  support demo

## Introduction

Purpose of this demo:

* Understand ans use BTRFS on Linux
* Learn integration with Docker

## DOCKER MACHINE 

TODO

## DOCKER CONTAINERS

Create a new Postgre Container
```
docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres
```

Connect to it with old school fashion ! 
```
docker run -it  --link some-postgres:postgres --rm \
                -v `pwd`/scripts:/scripts \
                -v /data/bdd:/var/lib/postgresql/data \
                postgres sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
```

Else with the new kids on the block 

```
docker exec -it some-postgres bash
psql -U postgres
```

## CREATE THE USERS

`postgres=# \i /scripts/users.sql`


