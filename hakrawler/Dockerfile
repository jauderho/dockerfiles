FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:7e070021291cfb200a9a7e91029ce5f96b76d1015794fab30882689e4c586d5d AS build

WORKDIR /go/src/github.com/hakluke/hakrawler/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/hakluke/hakrawler/archive/
ARG GIT_URL=https://github.com/jauderho/hakrawler.git

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/hakluke/hakrawler \
	&& cd /go/src/github.com/hakluke/hakrawler \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& GOARM="${TARGETVARIANT#v}" go build -v -trimpath -ldflags="-s -w"  

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:e198ded2ad4e953fa5349cd30f01ff6f7d07773254d079df4aca4a6a2dd24bf5

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

