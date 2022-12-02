FROM golang:1.19.3-alpine3.17@sha256:8bd8a4b55b233ea77a81250f83637553ef9e3348c5a0cc3ce440c5d45bf7d51d AS build

WORKDIR /go/src/github.com/containrrr/watchtower/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/containrrr/watchtower/archive/
ARG GIT_URL=https://github.com/jauderho/watchtower.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache git ca-certificates tzdata \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/containrrr/watchtower \
	&& cd /go/src/github.com/containrrr/watchtower \
	&& go build -o watchtower -v -trimpath -ldflags="-s -w -X github.com/containrrr/watchtower/internal/meta.Version=${BUILD_VERSION}" .

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.17.0@sha256:8914eb54f968791faf6a8638949e480fef81e697984fba772b3976835194c6d4

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

