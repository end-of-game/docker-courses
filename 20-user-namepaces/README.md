# Create users

The first one
```
useradd -m bozo
grep bozo /etc/passwd
grep bozo /etc/group
cat /etc/setuid
cat /etc/setgid
```

The second one
```
useradd -m aka
grep bozo /etc/passwd
grep bozo /etc/group
cat /etc/setuid
cat /etc/setgid
```

The third
```
useradd -m coco
grep bozo /etc/passwd
grep bozo /etc/group
cat /etc/setuid
cat /etc/setgid
```

The golden rule is 'FIRST_SUB_UID = 100000 + (UID - 1000) * 65536'

```
# Start a container 
docker run -d --name tomcat-userns tomcat

# to see the uid mapping with namespace for the processus tomcat
cat /proc/$(docker inspect -f '{{ .State.Pid }}' tomcat-userns)/uid_map
```

Now we will mount a root dir to this container
```
docker run -d -v /bin:/testing --name tomcat-userns2 tomcat
docker exec -it tomcat-userns2 bash
id
rm -rf testing/*
```

# Create a traefik user

```
groupadd -u traefik
useradd -g traefik traefik
```

Create a friend with
```
usergroup -g 100000 cousin
useradd -u 100000 -g cousin
```

Now start a debian with root usr
```
su - traefik
docker run -it -v /home/traefik/dir:/dir debian bash 
touch /dir/coucou
```
ls -l /home/traefik/dir


