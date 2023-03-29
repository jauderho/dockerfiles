FROM alpine:3.17.3@sha256:124c7d2707904eea7431fffe91522a01e5a861a624ee31d03372cc1d138a3126

WORKDIR /usr/local/bin

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/docker/docker-bench-security/archive/
ARG GIT_URL=https://github.com/docker/docker-bench-security.git

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git iproute2 docker-cli dumb-init \ 
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

