# Memory

Find out how much memory Docker is using by executing:
`docker system df`

# Reclaim

Reclaim all reclaimable space by using the following command:
`docker system prune`

3. Create a couple of containers with labels (these will exit immediately; why?):
4. Delete only those stopped containers bearing the apple label:
Only the container named clementine should remain after the targeted prune.
5. Finally, prune containers launched before a given timestamp using the until  lter; start by getting the current RFC 3339 time (https://tools.ietf.org/html/rfc3339 - note Docker requires the otherwise optional T separating date and time), then creating a new container:
And use the timestamp returned in a prune:
Note the -f  ag, to suppress the con rmation step. label and until  lters for pruning are also available for networks and images, while data volumes can only be selectively pruned by label;  nally, images can also be pruned by the boolean dangling key, indicating if the image is untagged.
