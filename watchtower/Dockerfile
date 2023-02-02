FROM golang:1.20.0-alpine3.17@sha256:30a02e0d312773089a592f1d920f4b8dc17fb8c5f6fcced013ce0e162d41b8f1 AS build

WORKDIR /go/src/github.com/containrrr/watchtower/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/containrrr/watchtower/archive/
ARG GIT_URL=https://github.com/jauderho/watchtower.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git ca-certificates tzdata \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/containrrr/watchtower \
	&& cd /go/src/github.com/containrrr/watchtower \
	&& go build -o watchtower -v -trimpath -ldflags="-s -w -X github.com/containrrr/watchtower/internal/meta.Version=${BUILD_VERSION}" .

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.17.1@sha256:f271e74b17ced29b915d351685fd4644785c6d1559dd1f2d4189a5e851ef753a

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/watchtower"
LABEL org.opencontainers.image.description="watchtower is a process for automating Docker container base image updates"

LABEL "com.centurylinklabs.watchtower"="true"

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo

COPY --from=build /go/src/github.com/containrrr/watchtower/watchtower /usr/local/bin/watchtower
COPY --from=build /config /config

EXPOSE 8080
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

ENTRYPOINT ["/usr/local/bin/watchtower"]

