#FROM golang:1.18.3-alpine3.16@sha256:7cc62574fcf9c5fb87ad42a9789d5539a6a085971d58ee75dd2ee146cb8a8695 AS build
FROM golang:1.18.4-alpine3.16@sha256:46f1fa18ca1ec228f7ea4978ad717f0a8c5e51436e7b8efaf64011f7729886df AS build

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
