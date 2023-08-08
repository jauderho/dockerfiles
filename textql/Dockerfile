FROM golang:1.20.7-alpine3.18@sha256:b255d9352ff4967f0424731acf5a262c3bb4b5bd712e6324ad9ed533c9d2aee7 AS build

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
	&& go build -v -o textql-cli -trimpath -buildmode=pie -ldflags="-s -w" ./textql

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.18.3@sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a

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

