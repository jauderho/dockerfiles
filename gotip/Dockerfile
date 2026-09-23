#FROM ghcr.io/jauderho/golang:1.27.1-alpine3.24@sha256:2b5d01f55ac560830af278b7fa949cbe7a3c8e7711b4c7397fe572f8e9338a50 AS build
FROM ghcr.io/jauderho/alpine:3.24.2@sha256:d7308a9e8d47ee8ada78214e58040511898720b57f2dd32da2003d41c66a790b AS build

ARG BUILD_VERSION

ENV GO111MODULE=on

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
	# the golang.org/dl/gotip launcher is only needed to run "download" above.
	# The image runs the SDK toolchain via /usr/local/bin/gotip, so the launcher
	# is dead weight - and it is built by Alpine's go, so it drags in that
	# toolchain's stdlib CVEs.
	&& rm -rf /root/go \
	&& rm -rf /var/cache/apk/*

RUN gotip version

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/gotip"
LABEL org.opencontainers.image.description="The latest development version of Go updated nightly"

#CMD ["/usr/local/bin/gotip"]
