## Docker ELK with Tomcat and JMX connection demo

This demo use Docker Compose to build the following stack:

- 1 ELK container built with JMX Plugin
- 1 Tomcat container with RMI listen enabled

Please, custom the docker-compose.yml with your Docker host IP:

**-Djava.rmi.server.hostname=192.168.99.100**

You can find all configuration files for each app in the **conf** folder