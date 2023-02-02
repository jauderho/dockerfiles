FROM golang:1.20.0-alpine3.17@sha256:1e2917143ce7e7bf8d1add2ac5c5fa3d358b2b5ddaae2bd6f54169ce68530ef0 AS build

WORKDIR /go/src/github.com/openairplay/goplay2/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/openairplay/goplay2/archive/
ARG GIT_URL=https://github.com/openairplay/goplay2.git

ENV CGO_ENABLED 1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev fdk-aac-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/openairplay/goplay2 \
	&& cd /go/src/github.com/openairplay/goplay2 \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.17.1@sha256:f271e74b17ced29b915d351685fd4644785c6d1559dd1f2d4189a5e851ef753a

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

