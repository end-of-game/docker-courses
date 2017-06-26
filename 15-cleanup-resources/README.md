# Memory

Find out how much memory Docker is using by executing:
`docker system df`

# Reclaim

Reclaim all reclaimable space by using the following command:
`docker system prune`

# Filter with tags

Create a couple of containers with labels (these will exit immediately; why?):
```
docker container run --label apple --name fuji -d alpine
docker container run --label orange --name clementine -d alpine
```

Try to delete only those stopped containers bearing the apple label:
```
docker container ls -a
docker container prune --filter 'label=apple'
docker container ls -a
```
