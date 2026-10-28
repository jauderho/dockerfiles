FROM ghcr.io/jauderho/alpine:3.24.3@sha256:d73d61c3d73b9dc360093fe38788808f66b47c3e9a187215dc3d90ccb5461aa0

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

