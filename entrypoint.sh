#!/bin/bash

# Create a dev user with GIT/UID mapped to --user gid:uid used when running the the container (should be the current local user)
DEV_GID=$(id -g)
DEV_UID=$(id -u)
if [[ $DEV_GID -eq 0 || $DEV_UID -eq 0 ]]; then
    echo "You can't run this container as root. Pass your local user's gid and uid as --user gid:uid parameter"
    exit 1
fi
getent passwd dev || groupadd dev -g $DEV_GID && useradd -m -u $DEV_UID -g $DEV_GID dev
export HOME=/home/dev

# Reset npm cache ownership and link it to the newly created dev user home
sudo chown dev:dev /srv/.npm
ln -s /srv/.npm /home/dev/.npm

# Add host key(s) to known_hosts (convinient when using private git repos)
if [ -n "$KNOWN_HOSTS" ]; then
    mkdir -p $HOME/.ssh
    echo "$KNOWN_HOSTS" >> $HOME/.ssh/known_hosts
fi

# Add registy auth, etc. to ~/.npmrc
if [ -n "$NPMRC" ]; then
    echo "$NPMRC" > $HOME/.npmrc
fi

# Add registy auth, etc. to ~/.npmrc (from base64)
if [ -n "$NPMRC_BASE64" ]; then
    echo "$NPMRC_BASE64" | base64 -d > $HOME/.npmrc
fi

exec "$@"
