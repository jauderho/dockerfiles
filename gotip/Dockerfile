#FROM golang:1.19.4-alpine3.17@sha256:cf3f282dc9d14653ee9df26ab220a3d3aedd6ae0bffb718c76daacc07667a1c4 AS build
FROM golang:1.19.4-alpine3.17@sha256:cf3f282dc9d14653ee9df26ab220a3d3aedd6ae0bffb718c76daacc07667a1c4 AS build

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
