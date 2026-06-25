FROM ghcr.io/jauderho/alpine:3.24.1@sha256:fc6aa8bd54b01bbe7fd9e2d2e79c87837ab82abf83387a0dbb16fb6c7b17997d

ARG BUILD_VERSION

#RUN apk --no-cache add unbound=${BUILD_VERSION} --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main
RUN apk update \
	&& apk upgrade -a \
    && apk --no-cache add unbound

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/unbound"
LABEL org.opencontainers.image.description="Unbound is a validating, recursive, caching DNS resolver"

#EXPOSE 53 53/udp
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

ENTRYPOINT ["unbound"]

