#FROM ghcr.io/jauderho/golang:1.23.6-alpine3.21@sha256:ae2a69287cf5fa9c6afaa1e9c5379d797750e65b2374c181c306598b38aac1fc AS build
FROM ghcr.io/jauderho/alpine:3.21.2@sha256:dcf5af7b9d6a9885907097200e7524309d6d8836eb2e46cbaadc945d5b840056 AS build

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
