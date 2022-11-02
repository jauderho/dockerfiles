#FROM golang:1.19.3-alpine3.16@sha256:8558ae624304387d18694b9ea065cc9813dd4f7f9bd5073edb237541f2d0561b AS build
FROM golang:1.19.3-alpine3.16@sha256:8558ae624304387d18694b9ea065cc9813dd4f7f9bd5073edb237541f2d0561b AS build

ARG BUILD_VERSION

ENV GO111MODULE on

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& build_pkgs="ca-certificates curl gcc build-base git bash" \
	&& apk add --no-cache ${build_pkgs}  \
	&& update-ca-certificates \
	&& go install -ldflags="-s -w" golang.org/dl/gotip@latest \
	&& gotip download \
	&& go clean \
	&& go clean -cache \
	&& go clean -modcache \
	&& gotip clean \
	&& gotip clean -cache \
	&& gotip clean -modcache \
	&& apk del ${build_pkgs} \
	&& rm -rf /root/sdk/gotip/test \
	&& rm -rf /root/sdk/gotip/.git \
	&& rm -rf /var/cache/apk/*

RUN gotip version

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/gotip"
LABEL org.opencontainers.image.description="The latest development version of Go updated nightly"
