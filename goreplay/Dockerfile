FROM ghcr.io/jauderho/golang:1.25.4-alpine3.22@sha256:142b9d9f4243eae9f378d0d9b3f1a5ebfd7460721d60ec15345084a187b7d246 AS build

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
	&& go get -u golang.org/x/net golang.org/x/crypto github.com/aws/aws-sdk-go \
	&& go mod tidy \
	&& go build -v -o gor -trimpath -ldflags="-s -w -linkmode external -extldflags=-static"

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

