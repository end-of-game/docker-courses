```
docker run -d \ 
  -p 5000:5000 \ 
  --restart=always \  
  --name registry \
  -v `pwd`/data:/var/lib/registry \
  registry:2
```

docker pull ubuntu
docker run --name demo6 -it ubuntu bash
> touch /demo6.txt
> exit
docker commit <containeId> image6
docker tag image6 localhost:5000/image6
docker push localhost:5000/image6
docker rmi -f localhost:5000/image6

docker pull localhost:5000/image6

docker stop registry && docker rm -v registry

MAC
	http://192.168.99.100:5000/v2/_catalog
	http://192.168.99.100:5000/v2/ubuntu/tags/list

LINUX
	http://localhost:5000/v2/_catalog
	http://localhost:5000/v2/ubuntu/tags/list
