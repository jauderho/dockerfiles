FROM alpine:3.17.2@sha256:ff6bdca1701f3a8a67e328815ff2346b0e4067d32ec36b7992c1fdc001dc8517

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

