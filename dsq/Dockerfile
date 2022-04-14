FROM golang:1.18.1-alpine3.15@sha256:42d35674864fbb577594b60b84ddfba1be52b4d4298c961b46ba95e9fb4712e8 AS build

WORKDIR /go/src/github.com/multiprocessio/dsq/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/multiprocessio/dsq/archive/
ARG GIT_URL=https://github.com/multiprocessio/dsq.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/multiprocessio/dsq \
	&& cd /go/src/github.com/multiprocessio/dsq \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w"

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.15.4@sha256:4edbd2beb5f78b1014028f4fbb99f3237d9561100b6881aabbf5acce2c4f9454

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dsq"
LABEL org.opencontainers.image.description="dsq is a CLI companion to DataStation (a GUI) for running SQL queries against data files"

COPY --from=build /go/src/github.com/multiprocessio/dsq/dsq /usr/local/bin/dsq
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/dsq"]

