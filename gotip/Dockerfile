#FROM ghcr.io/jauderho/golang:1.24.0-alpine3.21@sha256:157489c5bfe3d9b577009dcc142e1323666ea25d42353d9adabdd434c8a0a007 AS build
FROM ghcr.io/jauderho/alpine:3.21.2@sha256:e7f3117165afa2d56675922cdb717f94b22f724b385e07bfa096ede4ee58c323 AS build

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
