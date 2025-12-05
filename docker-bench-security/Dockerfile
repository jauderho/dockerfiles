FROM ghcr.io/jauderho/alpine:3.23.0@sha256:df8f76a45aada5bde7a3769b5050c0a71bd3a6567acc2db7a8c88ecf95b3255d

WORKDIR /usr/local/bin

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/docker/docker-bench-security/archive/
ARG GIT_URL=https://github.com/docker/docker-bench-security.git

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git iproute2 dumb-init \ 
	&& apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community docker-cli \ 
	&& git clone --depth 1 ${GIT_URL} . \
	&& apk del git

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/docker-bench-security"
LABEL org.opencontainers.image.description="docker-bench-security automates tests based on the CIS Docker Benchmark"

# EXPOSE 8080
# ENV
# STOPSIGNAL
HEALTHCHECK CMD exit 0
# USER

#ENTRYPOINT ["/usr/local/bin/docker-bench-security"]

ENTRYPOINT [ "/usr/bin/dumb-init", "/bin/sh", "docker-bench-security.sh" ]

