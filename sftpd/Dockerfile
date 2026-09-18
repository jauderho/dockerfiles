FROM ghcr.io/jauderho/alpine:3.24.2@sha256:a1192a21955909e6f8d3ad5fe9b24c5c848c2567809d543e18e09ab68881bfea

# Steps done in one RUN layer:
# - Install packages
# - Fix default group (1000 does not exist)
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN apk update \
    && apk upgrade -a \
    && apk add --no-cache bash shadow openssh openssh-sftp-server \
    #&& sed -i 's/GROUP=1000/GROUP=100/' /etc/pam.d/useradd \
    && mkdir -p /var/run/sshd \
    && rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/entrypoint /

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/sftpd"
LABEL org.opencontainers.image.description="A minimal sftpd docker container"

EXPOSE 2222
#EXPOSE 22

ENTRYPOINT ["/entrypoint"]
