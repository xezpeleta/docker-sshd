#! /bin/bash

# Optional environment variables
# $AUTHORIZED_KEYS
# $MOTD

# Add custom ssh pubkeys
if [ ! -z "$AUTHORIZED_KEYS" ]
then
  if [ ! -d /root/.ssh ]
  then
    mkdir -m 700 /root/.ssh
  fi
  
  echo "$AUTHORIZED_KEYS" >> /root/.ssh/authorized_keys
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
