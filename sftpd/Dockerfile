FROM ghcr.io/jauderho/alpine:3.24.2@sha256:d7308a9e8d47ee8ada78214e58040511898720b57f2dd32da2003d41c66a790b

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
