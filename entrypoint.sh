#! /bin/bash

# Supported environment variables:
#  $MOTD
#  $SSH_USER
#  $SSH_PASSWORD
#  $SSH_HOME
#  $SSH_SHELL
#  $AUTHORIZED_KEYS

# Default user = root
if [ -z "$SSH_USER" ]
then
  SSH_USER="root"
else
  # Create user $SSH_USER (only if it does not exist)
  id "$SSH_USER" > /dev/null 2> /dev/null || adduser "$SSH_USER" -s /bin/bash -D -g ""
  # Disable password (unlocked)
  usermod -p '*' "$SSH_USER"
fi

# Set password (disabled by default)
if [ ! -z "$SSH_PASSWORD" ]
then
   # Change root password and allow SSH root login
   if [ "$SSH_USER" == "root" ]
   then
     echo -e "$SSH_PASSWORD\n$SSH_PASSWORD" |passwd root
     sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config
   # Change user password
   else
     echo -e "$SSH_PASSWORD\n$SSH_PASSWORD" |passwd $SSH_USER
   fi
fi

# Set home
if [ -z "$SSH_HOME" ]
then
  # Read the default home
  SSH_HOME=$( getent passwd "$SSH_USER" | cut -d: -f6 )
else
  # Change/move home directory
  usermod -m -d "$SSH_HOME" "$SSH_USER"
fi

# Set shell
if [ -z "$SSH_SHELL" ]
then
  # Read the default shell
  SSH_SHELL=$( getent passwd "$SSH_USER" | cut -d: -f7 )
else
  # Set custom shell
  usermod -s "$SSH_SHELL" "$SSH_USER"
fi

# Add custom ssh pubkeys. Three options:
# - SSH pubkey: "ssh-rsa AAAF4fxxx...."
# - SSH pubkey file: "/my-id-rsa.pub"
# - Directory with one or more SSH pubkey files: "/my-pubkeys"
if [ ! -z "$AUTHORIZED_KEYS" ]
then
  # Check if .ssh directory exists
  if [ ! -d "$SSH_HOME/.ssh" ]
  then
    mkdir -p -m 700 $SSH_HOME/.ssh
  fi

  # Directory with pubkey files
  if [ -d "$AUTHORIZED_KEYS" ]
  then
    cd "$AUTHORIZED_KEYS" && cat * > $SSH_HOME/.ssh/authorized_keys
  # SSH pubkey file
  elif [ -f "$AUTHORIZED_KEYS" ]
  then
    cat "$AUTHORIZED_KEYS" > $SSH_HOME/.ssh/authorized_keys
  # SSH pubkey
  else
    echo "$AUTHORIZED_KEYS" > $SSH_HOME/.ssh/authorized_keys
  fi
fi

# Set permissions
if [ -d "$SSH_HOME/.ssh" ]
then
  chown -R $SSH_USER:$SSH_USER $SSH_HOME/.ssh
  chmod 700 $SSH_HOME/.ssh

  if [ -f "$SSH_HOME/.ssh/authorized_keys" ]
  then
    chmod 600 $SSH_HOME/.ssh/authorized_keys
  fi
fi

# Custom MOTD
if [ ! -z "$MOTD" ]
then
  echo "$MOTD" > /etc/motd
fi

# Run sshd service
/usr/sbin/sshd -Dd
