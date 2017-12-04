#! /bin/bash

# Optional environment variables
# $AUTHORIZED_KEYS
# $MOTD

# Add custom ssh pubkeys. Three options:
# - SSH pubkey: "ssh-rsa AAAF4fxxx...."
# - SSH pubkey file: "/my-id-rsa.pub"
# - Directory with one or more SSH pubkey files: "/my-pubkeys"
if [ ! -z "$AUTHORIZED_KEYS" ]
then
  if [ ! -d /root/.ssh ]
  then
    mkdir -m 700 /root/.ssh
  fi
  
  # Directory with pubkey files
  if [ -d "$AUTHORIZED_KEYS" ]
  then
    cd "$AUTHORIZED_KEYS" && cat * >> /root/.ssh/authorized_keys
  # SSH pubkey file
  elif [ -f "$AUTHORIZED_KEYS" ]
  then
    cat "$AUTHORIZED_KEYS" >> /root/.ssh/authorized_keys
  # SSH pubkey
  else
    echo "$AUTHORIZED_KEYS" >> /root/.ssh/authorized_keys
  fi
fi

# Set permissions
if [ -d /root/.ssh ]
then
  chown -R root:root /root/.ssh
  chmod 700 /root/.ssh
  
  if [ -f /root/.ssh/authorized_keys ]
  then
    chmod 600 /root/.ssh/authorized_keys
  fi
fi

# Custom MOTD
if [ ! -z "$MOTD" ]
then
  echo "$MOTD" > /etc/motd
fi

# Run sshd service
/usr/sbin/sshd -D
