FROM ghcr.io/jauderho/golang:1.25.1-alpine3.22@sha256:6c605f5c0500f90666d5ef4fe1d47f4bc3cd88cd495a743a8c6ceb3d4c19bcec AS build

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
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w"

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.22.1@sha256:6cedbe16d634f856346fb6224aeddf939413076aaf08bc0216a2ee1759917a56

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

