FROM golang:1.18.0-alpine3.15@sha256:9efe6b075e2bd5eff0fae9ce2961897ac339ef31eec24732691e15be0a154eec AS build

WORKDIR /go/src/github.com/openairplay/goplay2/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/openairplay/goplay2/archive/
ARG GIT_URL=https://github.com/openairplay/goplay2

ENV CGO_ENABLED 1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev fdk-aac-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/openairplay/goplay2 \
	&& cd /go/src/github.com/openairplay/goplay2 \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/goplay2"
LABEL org.opencontainers.image.description="goplay2 is an opinionated Airplay 2 speaker implementation"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/openairplay/goplay2/goplay2 /usr/local/bin/goplay2
COPY --from=build /config /config

RUN apk update \
	&& apk add --no-cache fdk-aac-dev

ENTRYPOINT ["/usr/local/bin/goplay2"]

