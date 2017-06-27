# Context

CGroups control how much resources a process can use. By adding restrictions you can deliver a guaranteed Quality of Service to applications by ensuring they have enough space available. It's also possible protect the system from potentially malicious users or applications aiming to perform Denial of Service (DoS) applications via resource exhaustion. This can also help limit applications from memory leaks or other programming bugs by defining upper boundaries.

# Instructions

```
docker run -d --name mb100 --memory 100m alpine top
docker stats --no-stream
```

# Define CPU Shares

```
docker run -d --name c768 --cpuset-cpus 0 --cpu-shares 768 benhall/stress
docker run -d --name c256 --cpuset-cpus 0 --cpu-shares 256 benhall/stress
sleep 5
docker stats --no-stream
docker rm -f c768 c256
```

# Use Network Namespace

While cgroups control how much resources a process can use, Namespaces control what a process and see and access.

When containers are launched, a network interface is defined and create. This gives the container a unique IP address and interface.

```
docker run -it alpine ip addr show
```

By changing the namespace to host, instead of the container's network being isolated with it's own interface, the process will have access to the host machines network interface.

```
docker run -it --net=host alpine ip addr show
```

If the process listens on ports, they'll be listened on the host interface and mapped to the container.

# Use Pid Namespace

As with networks, the processes a container can see depends on which namespace it belongs too. By changing the Pid namespace allows a container to interact with processes beyond it's normal scope.

The first container will run in it's own process namespace. As such the only processes it can access are the ones launched in the container.

```
docker run -it alpine ps aux
```

By changing the namespace to the host, the container can also see all the other processes running on the system.

```
docker run -it --pid=host alpine ps aux
```

Providing containers access to the host namespace is sometimes required, such as for debugging tooling, but is generally regarded as bad practice. This is because you're breaking out of the container security model which may introduce vulnerabilities.

# Sharing Namespaces

Instead of previous case, if it's required, use a shared namespace to provide access to only the namespaces the container requires. 

The first container starts an nginx server. This will define a new network and process namespace. The nginx server will bind itself to port 80 of the newly defined network interface.

```
docker run -d --name http nginx:alpine
```

Other containers can now reuse this namespace using the syntax container:<name>. Below the curl command can access the HTTP server running on localhost because they share the same network interface.

```
docker run --net=container:http benhall/curl curl -s localhost
```
Or

```
docker run --pid=container:http alpine ps aux
```

This is useful for debugging tools, such as strace. This allows you to give more permissions to certain containers without changing or restarting the application.
