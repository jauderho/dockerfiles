FROM ghcr.io/jauderho/golang:1.23.2-alpine3.20@sha256:b65012bef5b3e0a603c0479da8f799f385448f031f0f38d90f8b9634737c2f92 AS build

WORKDIR /go/src/github.com/dinedal/textql/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/dinedal/textql/archive/
ARG GIT_URL=https://github.com/dinedal/textql.git

ENV CGO_ENABLED 1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev sqlite-dev \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/dinedal/textql \
	&& cd /go/src/github.com/dinedal/textql \
	&& CGO_CFLAGS="-D_LARGEFILE64_SOURCE" go build -v -o textql-cli -trimpath -ldflags="-s -w" ./textql

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.20.3@sha256:7d51dd030c8c83a805f71a1487c8bc5673771985842515dc468ef52ace748ffe

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/textql"
LABEL org.opencontainers.image.description="textql allows you to easily execute SQL against structured text like CSV or TSV"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache sqlite

COPY --from=build /go/src/github.com/dinedal/textql/textql-cli /usr/local/bin/textql
COPY --from=build /config /config

WORKDIR /tmp

ENTRYPOINT ["/usr/local/bin/textql"]

