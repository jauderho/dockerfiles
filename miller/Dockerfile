FROM ghcr.io/jauderho/golang:1.24.4-alpine3.22@sha256:5527fb3bfaca5aa4409ba4b08b67879e14d786790b4a90ef317b44475f9ebadf AS build

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
FROM ghcr.io/jauderho/alpine:3.22.0@sha256:bcec51c688c49175fe5ab5204735ec7051349ac0e52f115dd8505aa5d0558e74

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

