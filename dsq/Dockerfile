FROM ghcr.io/jauderho/golang:1.26.0-alpine3.23@sha256:3c6dcf80ba83ce8f7622e61118cedbef38353daf78d524342ea12b385f931e63 AS build

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
FROM ghcr.io/jauderho/alpine:3.23.3@sha256:350bc73d1a938d40605f8ecd1009be511e61804d8452af018d63b8eac931fe33

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

