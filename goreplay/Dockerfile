FROM golang:1.19.3-alpine3.16@sha256:dc4f4756a4fb91b6f496a958e11e00c0621130c8dfbb31ac0737b0229ad6ad9c AS build

WORKDIR /go/src/github.com/buger/goreplay/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/buger/goreplay/archive/
ARG GIT_URL=https://github.com/buger/goreplay.git

ENV CGO_ENABLED 1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache git gcc musl-dev libpcap-dev linux-headers \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/buger/goreplay \
	&& cd /go/src/github.com/buger/goreplay \
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

