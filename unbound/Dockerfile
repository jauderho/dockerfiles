FROM alpine:3.16.0@sha256:7e108d9e8120d2d2ce8292780c8c36505226051610e4ac9de28d506289fa0f5e

ARG BUILD_VERSION

RUN apk --no-cache add unbound=${BUILD_VERSION} --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main

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

