#!/bin/bash
# Create a host for Consul
docker-machine create -d virtualbox consul-keystore
# Setup bash environment on Consul host
eval "$(docker-machine env consul-keystore)"
# Run a Consul container on the Consul host
docker run -d -p 8500:8500 -h consul progrium/consul -server -bootstrap

# Create a host for Swarm Manager
docker-machine create  -d virtualbox --swarm --swarm-master \
				--swarm-discovery="consul://$(docker-machine ip consul-keystore):8500" \
				--engine-opt="cluster-store=consul://$(docker-machine ip consul-keystore):8500" \
				--engine-opt="cluster-advertise=eth1:2376" \
				manager

# Create a 2nd host for Swarm
docker-machine create -d virtualbox --swarm \
				--swarm-discovery="consul://$(docker-machine ip consul-keystore):8500" \
				--engine-opt="cluster-store=consul://$(docker-machine ip consul-keystore):8500" \
				--engine-opt="cluster-advertise=eth1:2376" \
				agent1

# Create a 3rd host for Swarm
docker-machine create -d virtualbox --swarm \
				--swarm-discovery="consul://$(docker-machine ip consul-keystore):8500" \
				--engine-opt="cluster-store=consul://$(docker-machine ip consul-keystore):8500" \
				--engine-opt="cluster-advertise=eth1:2376" \
				agent2

# Setup bash environment on Swarm Manager host
eval $(docker-machine env --swarm manager)
