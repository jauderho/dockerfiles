FROM ghcr.io/jauderho/golang:1.22.6-alpine3.20@sha256:7a0ea1962711cbad3a370eaf7cbf6d3216596048746b4ff133f3c27c685ef238 AS build

WORKDIR /go/src/github.com/multiprocessio/dsq/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/multiprocessio/dsq/archive/
ARG GIT_URL=https://github.com/multiprocessio/dsq.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/multiprocessio/dsq \
	&& cd /go/src/github.com/multiprocessio/dsq \
	&& go get -u google.golang.org/protobuf golang.org/x/net \
	&& go get -u github.com/snowflakedb/gosnowflake \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w"

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.20.2@sha256:6f037df56ca0bf09c6854daa341457f5105b1f2ec73b52bc5090026770feb1be

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dsq"
LABEL org.opencontainers.image.description="dsq is a CLI companion to DataStation (a GUI) for running SQL queries against data files"

RUN apk update \
	&& apk upgrade -a

COPY --from=build /go/src/github.com/multiprocessio/dsq/dsq /usr/local/bin/dsq
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/dsq"]

