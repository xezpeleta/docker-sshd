# Dockerized SSH service

This container helps setting up a jailed SSH service. It can be useful when you need to open SSH/SFTP access to your server, but restricted to some directory.

## How to use this image

```sh
$ docker run --name my-sshd -d xezpeleta/sshd
```

The following environment variables are also available:

- `-e AUTHORIZED_KEYS=...` accepted ssh publick keys
- `-e MOTD=...` change ssh welcome message of the day

Using a `volume` you can specify the directories/files that will be writeable by the ssh users.

## ... vía docker-compose

```
version: '2'

services:
  sshd:
    build: ./sshd
    #volumes:
    # - /var/www:/var/www
    environment:
      - AUTHORIZED_KEYS=ssh-rsa AAAABfsdfdsafafafafafaf... thisismypubkey
      - MOTD=Welcome! You can modify your at /var/www directory. More info, sysadmin@mydomain.com
    ports:
      - "2222:22"
```
