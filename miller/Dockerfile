FROM ghcr.io/jauderho/golang:1.22.6-alpine3.20@sha256:1fd3c00db78749fbe841af819e4f52a5f11d23461c939f4615301c6fac412900 AS build

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
FROM ghcr.io/jauderho/alpine:3.20.2@sha256:6f037df56ca0bf09c6854daa341457f5105b1f2ec73b52bc5090026770feb1be

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

