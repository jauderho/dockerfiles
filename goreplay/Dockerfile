FROM golang:1.21.3-alpine3.18@sha256:96a8a701943e7eabd81ebd0963540ad660e29c3b2dc7fb9d7e06af34409e9ba6 AS build

WORKDIR /go/src/github.com/buger/goreplay/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/buger/goreplay/archive/
ARG GIT_URL=https://github.com/buger/goreplay.git

ENV CGO_ENABLED 1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev libpcap-dev linux-headers \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/buger/goreplay \
	&& cd /go/src/github.com/buger/goreplay \
	&& go get -u golang.org/x/net golang.org/x/crypto \
	&& go mod tidy \
	&& go build -v -o gor -trimpath -buildmode=pie -ldflags="-s -w -linkmode external -extldflags=-static"

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.15.0

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/goreplay"
LABEL org.opencontainers.image.description="goreplay is an open-source network monitoring tool which can record your live traffic for replay later"

COPY --from=build /go/src/github.com/buger/goreplay/gor /usr/local/bin/gor
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/gor"]
CMD ["--help"]

