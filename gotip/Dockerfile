#FROM ghcr.io/jauderho/golang:1.23.1-alpine3.20@sha256:f359bddc4fee0ccaa6ce20e85aa96bb8b4c00382f62ee735c9eecf9897f19c88 AS build
FROM ghcr.io/jauderho/alpine:3.20.3@sha256:7d51dd030c8c83a805f71a1487c8bc5673771985842515dc468ef52ace748ffe AS build

ARG BUILD_VERSION

ENV GO111MODULE on

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& build_pkgs="ca-certificates curl gcc build-base git bash go" \
	&& apk add --no-cache ${build_pkgs}  \
	&& update-ca-certificates \
	&& go install -ldflags="-s -w" golang.org/dl/gotip@latest \
	&& /root/go/bin/gotip download \
	&& ln -s /root/sdk/gotip/bin/go /usr/local/bin/gotip \
	&& ln -s /root/sdk/gotip/bin/gofmt /usr/local/bin/gofmt \
	&& go clean \
	&& go clean -cache \
	&& go clean -modcache \
	&& gotip clean \
	&& gotip clean -cache \
	&& gotip clean -modcache \
	&& apk del ${build_pkgs} \
	&& rm -rf /root/sdk/gotip/test \
	&& rm -rf /root/sdk/gotip/src \
	&& rm -rf /root/sdk/gotip/.git \
	&& rm -rf /usr/local/go \
	&& rm -rf /var/cache/apk/*

RUN gotip version

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/gotip"
LABEL org.opencontainers.image.description="The latest development version of Go updated nightly"

#CMD ["/usr/local/bin/gotip"]
