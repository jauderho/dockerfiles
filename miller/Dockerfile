FROM golang:1.18.4-alpine3.16@sha256:d84b1ff3eeb9404e0a7dda7fdc6914cbe657102420529beec62ccb3ef3d143eb AS build

WORKDIR /go/src/github.com/johnkerl/miller/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/johnkerl/miller/archive/
ARG GIT_URL=https://github.com/johnkerl/miller.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/johnkerl/miller \
	&& cd /go/src/github.com/johnkerl/miller \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w" ./cmd/mlr 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.16.1@sha256:7580ece7963bfa863801466c0a488f11c86f85d9988051a9f9c68cb27f6b7872

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/miller"
LABEL org.opencontainers.image.description="Miller is like awk, sed, cut, join, and sort for data formats such as CSV, TSV, tabular JSON and positionally-indexed"

COPY --from=build /go/src/github.com/johnkerl/miller/mlr /usr/local/bin/mlr
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/mlr"]

