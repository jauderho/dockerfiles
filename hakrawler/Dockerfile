FROM golang:1.18.0-alpine3.15@sha256:9efe6b075e2bd5eff0fae9ce2961897ac339ef31eec24732691e15be0a154eec AS build

WORKDIR /go/src/github.com/hakluke/hakrawler/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/hakluke/hakrawler/archive/
ARG GIT_URL=https://github.com/hakluke/hakrawler.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/hakluke/hakrawler \
	&& cd /go/src/github.com/hakluke/hakrawler \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w"  

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.15.1@sha256:d6d0a0eb4d40ef96f2310ead734848b9c819bb97c9d846385c4aca1767186cd4

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/hakrawler"
LABEL org.opencontainers.image.description="hakrawler is a fast golang web crawler for gathering URLs and Javascript file locations"

COPY --from=build /go/src/github.com/hakluke/hakrawler/hakrawler /usr/local/bin/hakrawler
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/hakrawler"]

