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
