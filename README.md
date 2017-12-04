# Dockerized SSH service

This container helps setting up a jailed SSH service. It can be useful when you need to open SSH/SFTP access to your server, but restricted to some directory.

## How to use this image

```sh
$ docker run --name my-sshd -p 2222:22 -d xezpeleta/sshd
```

Now, access it via SSH: `ssh root@host -p 2222`

The following environment variables are also available:

- `-e AUTHORIZED_KEYS=...` accepted ssh public keys in any of these ways:
  - Public key. Example: *ssh-rsa AAAfafafaf...*
  - Public key file. Example: */my-id-rsa.pub*
  - Public key directory. Example: */pubkeys*
- `-e MOTD=...` change ssh welcome message of the day

Using a `volume` you can specify the directories/files that will be writeable by the ssh users:

```sh
$ docker run --name my-sshd -e "AUTHORIZED_KEYS=ssh-rsa <my-pubkey>" -v /data:/data -p 2222:22 -d xezpeleta/sshd
```

If you prefer, instead of using the `AUTHORIZED_KEYS` envvar, you can use your custom `.ssh/authorized_keys` file overwriting the file `/root/.ssh/authorized_keys`:

```sh
$ docker run --name my-sshd -v /path/authorized_keys:/root/.ssh/authorized_keys -p 2222:22 -d xezpeleta/sshd
```

## ... vía docker-compose

```
version: '2'

services:
  sshd:
    image: xezpeleta/sshd
    volumes:
    - ./pubkeys:/pubkeys
    # - /var/www:/var/www
    environment:
      - AUTHORIZED_KEYS=/pubkeys
      - MOTD=Welcome! You can modify your files at /var/www. More info, sysadmin@mydomain.com
    ports:
      - "2222:22"
```
