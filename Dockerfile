FROM node:9

RUN apt-get update && \
    apt-get install -y --force-yes bash-completion less sudo socat netcat && \
    apt-get clean

# Pre-create npm cache for later volume binding. See entrypoint.sh.
RUN mkdir /srv/.npm && \ 
    npm i -g gulp

# "node" colides with some local UIDs, "dialout" collides with osx default user group
RUN deluser --remove-home node && \
    delgroup dialout

# Allow these binaries to be executed with root privileges to be able map the local user in the entrypoint (Don't you dare use this in prod image!)
RUN chmod u+s /usr/sbin/useradd && \
    chmod u+s /usr/sbin/groupadd

# ssh-agent socket should be bound to this path as a volume to enable authorization to private GIT repos
ENV SSH_AUTH_SOCK=/tmp/ssh-agent

# sudo for dev user
RUN echo "dev ALL=NOPASSWD: ALL" > /etc/sudoers.d/dev

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

WORKDIR /code

CMD npm start
