FROM golang:1.17.7-alpine3.15@sha256:d030a987c28ca403007a69af28ba419fca00fc15f08e7801fc8edee77c00b8ee AS build

WORKDIR /go/src/github.com/moncho/dry/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/moncho/dry/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/dry.tar.gz \
	&& tar xzf /tmp/dry.tar.gz --strip 1 -C /go/src/github.com/moncho/dry \
	&& go get -u github.com/containerd/containerd \
	&& go build -o dry-bin -v -trimpath -buildmode=pie -ldflags="-s -w" 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dry"
LABEL org.opencontainers.image.description="Dry is a terminal application to manage Docker and Docker Swarm."

COPY --from=build /go/src/github.com/moncho/dry/dry-bin /usr/local/bin/dry
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/dry"]

