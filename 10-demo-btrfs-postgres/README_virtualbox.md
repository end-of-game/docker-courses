# Docker and PostgreSQL with BTRFS support demo (Vagrant/Virtualbox version)

## Prerequisites

- [x] Virtualbox 5.x or later
- [x] Vagrant by HashiCorp

## Build your Vagrant/Virtualbox environment

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

## Create the BTRFS volumes

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

We will divide the /dev/sdb drive in two partitions, a dedicated partition for **/var/lib/docker** and a dedicated partition for the PostgreSQL volume **/bdd**

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

# Exit and write partition table
w
```
We can see that we have created two partitions of 10Go each on the **/dev/sdb** drive

Let's convert our new partitions to BTRFS filesystem.

Partition /dev/sdb1:

```{r, engine='bash'}
$ mkfs.btrfs /dev/sdb1
```
Output:

```
btrfs-progs v3.19.1
See http://btrfs.wiki.kernel.org for more information.

Turning ON incompat feature 'extref': increased hardlink limit per file to 65536
Turning ON incompat feature 'skinny-metadata': reduced-size metadata extent refs
fs created label (null) on /dev/sdb1
	nodesize 16384 leafsize 16384 sectorsize 4096 size 10.00GiB
```
Partition /dev/sdb2:

```{r, engine='bash'}
$ mkfs.btrfs /dev/sdb2
```
Output:

```
btrfs-progs v3.19.1
See http://btrfs.wiki.kernel.org for more information.

Turning ON incompat feature 'extref': increased hardlink limit per file to 65536
Turning ON incompat feature 'skinny-metadata': reduced-size metadata extent refs
fs created label (null) on /dev/sdb2
	nodesize 16384 leafsize 16384 sectorsize 4096 size 10.00GiB
```
The command ```btrfs filesystem show``` will print all the BTRFS drive stats.

Create now two directories in order to mount the new partitions:

```{r, engine='bash'}
$ mkdir /bdd
$ mkdir /mnt/docker_tmp
$ mount /dev/sdb1 /bdd
$ mount /dev/sdb2 /mnt/docker_tmp
```
Create a BTRFS subvolume for snapshot needs

```{r, engine='bash'}
$ btrfs subvolume create /bdd/data
```
We are going to migrate the data stored in **/var/lib/docker/** to the dedicated BTRFS partition.

First, we have to stop Docker before migrating

```{r, engine='bash'}
$ systemctl stop docker
```
Copy the old data to the new BTRFS partition

```{r, engine='bash'}
$ cp -aR /var/lib/docker/* /mnt/docker_tmp/
```
Remove the content of /var/lib/docker

```{r, engine='bash'}
$ rm -rf /var/lib/docker/*
```
Unmount the BTRFS partition from the temp folder

```{r, engine='bash'}
$ umount /mnt/docker_tmp
```
Mount the dedicated BTRFS partition to /var/lib/docker

```{r, engine='bash'}
$ mount /dev/sdb2 /var/lib/docker
```
Restore the main Docker directory permissions

```{r, engine='bash'}
$ chmod 700 /var/lib/docker
```
It's time to add two entries in our **/etc/fstab** in order to mount new partitions at startup

```{r, engine='bash'}
$ /dev/sdb1 /bdd btrfs defaults 0 0
$ /dev/sdb2 /var/lib/docker btrfs defaults 0 0
```
We can now start properly the Docker service

```{r, engine='bash'}
$ systemctl start docker
```

### Configure Docker to use BTRFS

A "docker info" print this:

```
...
Storage Driver: devicemapper
...
```
For CentOS 7.x and RHEL 7.x, the best way is to control and configure Docker with systemd.

Create the **/etc/systemd/system/docker.service.d** directory and the conf file.

```{r, engine='bash'}
$ mkdir /etc/systemd/system/docker.service.d
$ vi /etc/systemd/system/docker.service.d/docker.conf
```
Insert in the edited docker.conf this data:

```
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// --storage-driver=btrfs -H tcp://0.0.0.0:2376
```
Save, close, flush changes, and restart the Docker daemon:

```{r, engine='bash'}
$ systemctl daemon-reload
$ systemctl restart docker
```
Verify with a "docker info" command that Btrfs is now activated:

```
...
Storage Driver: btrfs
...
```
In order to tail the Docker daemon logs with systemd, use the following command:

```{r, engine='bash'}
$ journalctl -f -u docker
```

## Deploy PostgreSQL container

In your /home/vagrant directory, download the SQL script for coming tests:

```{r, engine='bash'}
$ cd /home/vagrant/
$ curl -O https://raw.githubusercontent.com/Treeptik/docker-courses/master/10-demo-btrfs-postgres/scripts/users.sql
```
Create a new PostgreSQL container and specify volumes to be mounted and the Postgres password:

```{r, engine='bash'}
$ docker run 	--name postgres-srv \
				-e POSTGRES_PASSWORD=mysecretpassword \
				-v /bdd/data:/var/lib/postgresql/data \
				-v `pwd`/users.sql:/scripts/users.sql \
				-d postgres
```
Connect to it with the old school fashion way ! 

```{r, engine='bash'}
$ docker run	-it --rm \
				--name postgres-cli \
				--link postgres-srv:postgres \
				-v `pwd`/users.sql:/scripts/users.sql \
				postgres \
				sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
```
Else with the way for the new kids on the block ;-)

``` {r, engine='bash'}
$ docker exec -it postgres-srv bash
puis
$ psql -U postgres
```

## Compare the running time of an SQL script (BTRFS vs ext4)

The main goal of this part is to compare insert duration of our SQL script.
This script inserts 10 millions lines in a table.

We need to turn on the timing function of PostrgeSQL

```
postgres=# \timing
Timing is on.
```
Now let's run our script and see the execution time

```
postgres=# \i /scripts/users.sql
psql:/scripts/users.sql:3: NOTICE:  table "users" does not exist, skipping
DROP TABLE
Time: 0.276 ms
CREATE TABLE
Time: 2.566 ms
INSERT 0 10000000
Time: 12691.182 ms
postgres=# \q

$ exit
```

Execution time: **12ms**

### Test with an ext4 bdd volume

Create a second volume directory for the bdd data, create a new Postgres instance using this directory as volume:

```{r, engine='bash'}
$ mkdir /bdd2
$ docker run 	--name postgres-srv2 \
				-e POSTGRES_PASSWORD=mysecretpassword \
				-v /bdd2:/var/lib/postgresql/data \
				-v `pwd`/users.sql:/scripts/users.sql \
				-d postgres
```
Connect to the postgre-srv2 instance:

```{r, engine='bash'}
$ docker run	-it --rm \
				--name postgres-cli2 \
				--link postgres-srv2:postgres \
				-v `pwd`/users.sql:/scripts/users.sql \
				postgres \
				sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
```
Turn on, again, the timing function of PostrgeSQL

```
postgres=# \timing
Timing is on.
```
Now let's run our script on this instance and see the execution time

```
postgres=# \i /scripts/users.sql
psql:/scripts/users.sql:3: NOTICE:  table "users" does not exist, skipping
DROP TABLE
Time: 0.394 ms
CREATE TABLE
Time: 3.996 ms
INSERT 0 10000000
Time: 12034.010 ms
postgres=# \q

$ exit
```

Execution time: **12ms**

As a result, we could say there is no write performance benefits using BTRFS with PostgreSQL databases.

## Backup with BTRFS snapshot system

In this part, we are going to do:

- backup the **/bdd/data** directory with BTRFS snapshot
- simulate a data loss
- restore a snapshot and check consistency of the PostgreSQL data

### Backup the **/bdd/data** directory with BTRFS snapshot

First, we need to create the initial snapshot with the following command:

```{r, engine='bash'}
$ btrfs subvolume snapshot -r /bdd/data /bdd/backup
Create a readonly snapshot of '/bdd/data' in '/bdd/backup'
```
Check the result in the /bdd directory, we can the see the backup directory created by BTRFS snapshot:

```{r, engine='bash'}
$ ll /bdd/
total 0
drwx------. 1 systemd-bus-proxy root 514 13 avril 11:54 backup
drwx------. 1 systemd-bus-proxy root 514 13 avril 11:54 data
```

With the following command, we can see that snapshot previously created is using also BTRFS subvolume:

```{r, engine='bash'}
$ btrfs subvolume list -a /bdd
ID 261 gen 216 top level 5 path data
ID 263 gen 191 top level 5 path backup
```

Just for fun, if we take a look at the docker directory, we will note that the directory is using this snapshot technology for the docker copy-on-write system:

```{r, engine='bash'}
$ btrfs subvolume list -a /var/lib/docker/
ID 258 gen 31 top level 5 path btrfs/subvolumes/5213ae83ed4bc30cf61b3530225c1943ae25b06c8da2571fa6fa79ebd9adc5b2
ID 259 gen 32 top level 5 path btrfs/subvolumes/7951946340dd993fdaf31ed85eaa4bcada4984c8b03702364998798d409ef4c2
ID 260 gen 33 top level 5 path btrfs/subvolumes/b1eaeb0806046837020f2ef275f4a04011a02e540ec19a76f38b1ed0837c2f6c
ID 261 gen 34 top level 5 path btrfs/subvolumes/25e07354cd5324077643078126b7f2da8c7885d2180c940de1e16cc4ed8cc327
ID 262 gen 35 top level 5 path btrfs/subvolumes/f0e4d78411718e7c1abde902cf5475bb06a134ed09ebdca5e66891a774e58545
ID 263 gen 36 top level 5 path btrfs/subvolumes/0d7715fd573b2b64896a428d5f238bf5595e356f8bb550bee5035f8ce93b427c
ID 264 gen 37 top level 5 path btrfs/subvolumes/739cd362647e63661bfc7dd7e9a2a735f1235a0edef60e16f3b1d4232ec3bc76
...
```
### Play a data loss

Connect to your PostgreSQL server and delete the users table previously created:

```{r, engine='bash'}
$ docker run    -it --rm \
                --name postgres-cli \
                --link postgres-srv:postgres \
                -v `pwd`/users.sql:/scripts/users.sql \
                postgres \
                sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'

postgres=# \d
         List of relations
 Schema | Name  | Type  |  Owner   
--------+-------+-------+----------
 public | users | table | postgres
(1 row)

# First, drop the users table previously listed
postgres=# DROP TABLE users;
DROP TABLE
postgres=# \d
No relations found.
postgres=# \q

$ exit
```

We have just simulated an accidental data loss.

### Try to restore the data lost

```{r, engine='bash'}
$ docker stop postgres-srv
$ btrfs subvolume delete /bdd/data
$ btrfs subvolume snapshot /bdd/backup /bdd/data
Create a RW snapshot of '/bdd/backup' in '/bdd/data'
$ docker start postgres-srv
$ docker run    -it --rm \
                --name postgres-cli \
                --link postgres-srv:postgres \
                -v `pwd`/users.sql:/scripts/users.sql \
                postgres \
                sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'

postgres=# \d
         List of relations
 Schema | Name  | Type  |  Owner   
--------+-------+-------+----------
 public | users | table | postgres
(1 row)
```
We can see that the table came back and so the data consitency is good.

## Going further with BTRFS

### Check & repair

BTRFS bring some diagnostic tools such as check function.

You need to stop/delete your docker instance and unmount the filesystem before checking.

```{r, engine='bash'}
$ docker stop postgres-srv
$ docker rm postgres-srv
$ umount /bdd
$ btrfs check --repair /dev/sdb1
```
Output:

```
enabling repair mode
Checking filesystem on /dev/sdb1
UUID: f83c25b2-ac92-418e-bf5e-12983ca823d8
checking extents
Fixed 0 roots.
checking free space cache
cache and super generation don't match, space cache will be invalidated
checking fs roots
checking csums
checking root refs
found 1619521540 bytes used err is 0
total csum bytes: 1575404
total tree bytes: 6307840
total fs tree bytes: 2949120
total extent tree bytes: 933888
btree space waste bytes: 1332675
file data blocks allocated: 984815312896
 referenced 1853227008
btrfs-progs v3.19.1
```
