FROM ghcr.io/jauderho/golang:1.25.5-alpine3.23@sha256:c3e2bd051ea950e5495875ffa78f2a94e1db69513d726b8e2511770c9e17d264 AS build

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
FROM ghcr.io/jauderho/alpine:3.23.0@sha256:19cc27d01fd5f98eadadbd1bcb64568e5f7f1bc7f6d1704102a3af7c0120a33d

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

