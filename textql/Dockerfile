FROM ghcr.io/jauderho/golang:1.27.2-alpine3.24@sha256:ee535094907559d9e9905106dec7d88faa0dba2a99624a99ef6853f7f2a72e3b AS build

WORKDIR /go/src/github.com/dinedal/textql/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/dinedal/textql/archive/
ARG GIT_URL=https://github.com/dinedal/textql.git

ENV CGO_ENABLED=1

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
FROM ghcr.io/jauderho/alpine:3.24.2@sha256:915b1f8d78d9dd6e8cecad779f8cb676ac85dd5f0ae54297e5efab5f93590fdf

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

