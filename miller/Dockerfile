FROM ghcr.io/jauderho/golang:1.23.1-alpine3.20@sha256:f359bddc4fee0ccaa6ce20e85aa96bb8b4c00382f62ee735c9eecf9897f19c88 AS build

WORKDIR /go/src/github.com/johnkerl/miller/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/johnkerl/miller/archive/
ARG GIT_URL=https://github.com/johnkerl/miller.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/johnkerl/miller \
	&& cd /go/src/github.com/johnkerl/miller \
	&& go build -v -trimpath -ldflags="-s -w" ./cmd/mlr 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.20.3@sha256:7d51dd030c8c83a805f71a1487c8bc5673771985842515dc468ef52ace748ffe

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/miller"
LABEL org.opencontainers.image.description="Miller is like awk, sed, cut, join, and sort for data formats such as CSV, TSV, tabular JSON and positionally-indexed"

RUN apk update \
	&& apk upgrade -a
	
COPY --from=build /go/src/github.com/johnkerl/miller/mlr /usr/local/bin/mlr
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/mlr"]

