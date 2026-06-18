FROM ghcr.io/jauderho/golang:1.26.4-alpine3.24@sha256:9589588fd5fda0a4aba042a5ce52f4fe60778929c29efcf70106de10cf9af8bc AS build

WORKDIR /go/src/github.com/hakluke/hakrawler/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/hakluke/hakrawler/archive/
ARG GIT_URL=https://github.com/jauderho/hakrawler.git

ENV CGO_ENABLED=0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/hakluke/hakrawler \
	&& cd /go/src/github.com/hakluke/hakrawler \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go build -v -trimpath -ldflags="-s -w"  

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:c43ea832c5e5df2adadaec0a6487e5939c7080376ed831db9d422067519e86d8

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/hakrawler"
LABEL org.opencontainers.image.description="hakrawler is a fast golang web crawler for gathering URLs and Javascript file locations"

RUN apk update \
	&& apk upgrade -a

COPY --from=build /go/src/github.com/hakluke/hakrawler/hakrawler /usr/local/bin/hakrawler
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/hakrawler"]

