FROM alpine:3.18.3@sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a

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

