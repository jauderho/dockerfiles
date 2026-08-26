FROM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:9dbd8d0ab684eeaf65fad01a04ab7aa59a5e690179fe0e6ebf8b935b422d0174 AS build

WORKDIR /go/src/github.com/openairplay/goplay2/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/openairplay/goplay2/archive/
ARG GIT_URL=https://github.com/openairplay/goplay2.git

ENV CGO_ENABLED=1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev fdk-aac-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/openairplay/goplay2 \
	&& cd /go/src/github.com/openairplay/goplay2 \
	&& go get -u golang.org/x/net golang.org/x/crypto \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:f310f8a4fad676899731a97c5eaf004c9cb9e822018a2ad7d23c3aeda3a7d773

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/goplay2"
LABEL org.opencontainers.image.description="goplay2 is an opinionated Airplay 2 speaker implementation"

RUN apk update \
	&& apk upgrade -a
	
COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/openairplay/goplay2/goplay2 /usr/local/bin/goplay2
COPY --from=build /config /config

RUN apk update \
	&& apk add --no-cache fdk-aac-dev

ENTRYPOINT ["/usr/local/bin/goplay2"]

