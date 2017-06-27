# Creating Secrets

Create a new secret named my-secret with the value some sensitive value byusing the following command to pipe STDIN to the secret value:

```
echo 'my sensitive value' | docker secret create my-secret -
```

Alternatively, secret values can be read from a file.
In the current directory create a file called mysql-password.txt and add the value 1PaSsw0rd2 to it.
Create a secret with this value:

```
docker secret create mysql-password ./mysql-password.txt
```

# Managing Secrets

The Docker CLI provides API objects for managing secrets similar to all other Docker assets:
```
echo 'my sensitive value' | docker secret create foo-secret -
```

List your current secrets:
```
docker secret ls
```

Print secret metadata:
```
docker secret inspect foo-secret
```

Delete a secret
```
docker secret rm foo-secret
```

# Using Secrets

Create a service authorized to use the secrets my-secret and mysql-password secret

```
docker service create \
    --name demo \
    --secret my-secret \
    --secret mysql-password \
    alpine:latest ping 8.8.8.8
```

Be smart and determine what node your container is running on.

```
docker container exec -it <container ID> sh
```

Inspect the secrets in this container where they are mounted, at /run/secrets:    

```
cd /run/secrets
ls
cat my-secret
exit
```

# Updating a Secret

YOU CANNOT DO IT ! Only ADD or REMOVE it.

Create a new version of the my-secret secret

```
echo 'updated value v2' | docker secret create my-secret-v2 -
```

Update our demo service first by deleting the old secret:

```
docker service update --secret-rm my-secret demo
```

Assign the new value of the secret to the service, using source and target to alias the my-secret-v2
the container as my-secret inside:

```
docker service update --secret-add source=my-secret-v2,target=my-secret demo
```

exec into the running container and demonstrate that the value of the my-secret secret has changed.


# Preparing an image for use of secrets

Create a new directory to build the docker images
```
import os
print '***** DOCKER Secrets ******'
print 'USERNAME: {0}'.format(os.environ['USERNAME'])

fname = os.environ['PASSWORD_FILE']
with open(fname) as f:
  content = f.readlines()

print 'PASSWORD_FILE: {0}'.format(fname)
print 'PASSWORD: {0}'.format(content[0])
```

With this *Dockerfile* :

```
FROM python:2.7
RUN mkdir -p /app
WORKDIR /app
COPY . /app
CMD python ./app.py && sleep 1000
```

Build it and push it on DockerHub

```
docker image build -t <username>/secret:1.0 .
docker image push <username>/secret:1.0
```

Then create a new service

```
docker service create \
    --name secrets-demo \
    --replicas=1 \
    --secret source=mysql-password,target=db_password,mode=0400 \
    -e USERNAME="jdoe" \
-e PASSWORD_FILE="/run/secrets/db_password" \ <username>/secret:1.0
```

Todo : use a docker-compose.yml to do same thing :)
