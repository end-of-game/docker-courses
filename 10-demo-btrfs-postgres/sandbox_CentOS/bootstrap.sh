#!/bin/bash

sudo setenforce 0
sudo yum -y install bridge-utils nmap
sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
sudo yum -y install -y docker-engine
sudo systemctl enable docker.service 
sudo usermod vagrant -aG docker
sudo reboot
