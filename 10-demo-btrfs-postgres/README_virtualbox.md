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

```{r, engine='bash'}
$ mkdir sandbox_CentOS && cd sandbox_CentOS
$ curl -O https://raw.githubusercontent.com/Treeptik/docker-courses/master/10-demo-btrfs-postgres/sandbox_CentOS/Vagrantfile
$ curl -O https://raw.githubusercontent.com/Treeptik/docker-courses/master/10-demo-btrfs-postgres/sandbox_CentOS/bootstrap.sh
```
Run your Vagrant Centos sandbox:

```{r, engine='bash'}
$ vagrant up
```
Wait few minutes... take a coffee

### Create the BTRFS volumes

Connect to your freshly started Vagrant sandbox, and become root:

```{r, engine='bash'}
$ vagrant ssh
$ sudo su
```
Use fdisk to see all the partitions and disk available:

```{r, engine='bash'}
$ fdisk -l
```
Output:

```
Disque /dev/sda : 42.9 Go, 42949672960 octets, 83886080 secteurs
Unités = secteur de 1 × 512 = 512 octets
Taille de secteur (logique / physique) : 512 octets / 512 octets
taille d'E/S (minimale / optimale) : 512 octets / 512 octets
Type d'étiquette de disque : dos
Identifiant de disque : 0x000c71f0

Périphérique Amorçage  Début         Fin      Blocs    Id. Système
/dev/sda1            2048        4095        1024   83  Linux
/dev/sda2   *        4096      413695      204800   83  Linux
/dev/sda3          413696    83886079    41736192   8e  Linux LVM

Disque /dev/sdb : 21.5 Go, 21474836480 octets, 41943040 secteurs
Unités = secteur de 1 × 512 = 512 octets
Taille de secteur (logique / physique) : 512 octets / 512 octets
taille d'E/S (minimale / optimale) : 512 octets / 512 octets


Disque /dev/mapper/VolGroup00-LogVol00 : 40.8 Go, 40768634880 octets, 79626240 secteurs
Unités = secteur de 1 × 512 = 512 octets
Taille de secteur (logique / physique) : 512 octets / 512 octets
taille d'E/S (minimale / optimale) : 512 octets / 512 octets


Disque /dev/mapper/VolGroup00-LogVol01 : 1610 Mo, 1610612736 octets, 3145728 secteurs
Unités = secteur de 1 × 512 = 512 octets
Taille de secteur (logique / physique) : 512 octets / 512 octets
taille d'E/S (minimale / optimale) : 512 octets / 512 octets


Disque /dev/mapper/docker-253:0-394543-pool : 107.4 Go, 107374182400 octets, 209715200 secteurs
Unités = secteur de 1 × 512 = 512 octets
Taille de secteur (logique / physique) : 512 octets / 512 octets
taille d'E/S (minimale / optimale) : 65536 octets / 65536 octets

```
We can see that:

- /dev/sda is used for system and LVM partitioning
- /dev/sdb is the second disk added in the Vagrantfile (the real size is 21.5Go)

We will divide the /dev/sdb drive in two partitions, a dedicated partition for **/var/lib/docker** and a dedicated partition for the PostgreSQL volume **/data**

```{r, engine='bash'}
$ fdisk /dev/sdb
```

```
# first partition setup
n (new partition)
p (primary)
1 (number of this partition)
[enter] (default first sector)
+10G (last sector)

# second partition setup
n (new partition)
p (primary)
2 (number of this partition)
[enter] (default first sector)
[enter] (default last sector)

# let's print the partition table
p (print the partition table)

Disque /dev/sdb : 21.5 Go, 21474836480 octets, 41943040 secteurs
Unités = secteur de 1 × 512 = 512 octets
Taille de secteur (logique / physique) : 512 octets / 512 octets
taille d'E/S (minimale / optimale) : 512 octets / 512 octets
Type d'étiquette de disque : dos
Identifiant de disque : 0xb6a76dca

Périphérique Amorçage  Début         Fin      Blocs    Id. Système
/dev/sdb1            2048    20973567    10485760   83  Linux
/dev/sdb2        20973568    41943039    10484736   83  Linux
```
We can see that we have created two partitions of 10Go each on the **/dev/sdb** drive

Let's convert our new partitions to BTRFS filesystem:

```{r, engine='bash'}
$ mkfs.btrfs /dev/sdb1
btrfs-progs v3.19.1
See http://btrfs.wiki.kernel.org for more information.

Turning ON incompat feature 'extref': increased hardlink limit per file to 65536
Turning ON incompat feature 'skinny-metadata': reduced-size metadata extent refs
fs created label (null) on /dev/sdb1
	nodesize 16384 leafsize 16384 sectorsize 4096 size 10.00GiB
```


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


