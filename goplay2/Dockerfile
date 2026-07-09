FROM ghcr.io/jauderho/golang:1.26.5-alpine3.24@sha256:7a896e7d5dc894edf994a27fede0415020e62cdb7652c6fea4f81fed9acad0b0 AS build

WORKDIR /go/src/github.com/openairplay/goplay2/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/openairplay/goplay2/archive/
ARG GIT_URL=https://github.com/openairplay/goplay2.git

ENV CGO_ENABLED=1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev fdk-aac-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/openairplay/goplay2 \
	&& cd /go/src/github.com/openairplay/goplay2 \
	&& go get -u golang.org/x/net golang.org/x/crypto \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:5c592efde24ef4bd031a296ebb3a61ff6ce3236899e28b68430b7a309481a6e9

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/goplay2"
LABEL org.opencontainers.image.description="goplay2 is an opinionated Airplay 2 speaker implementation"

RUN apk update \
	&& apk upgrade -a
	
COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/openairplay/goplay2/goplay2 /usr/local/bin/goplay2
COPY --from=build /config /config

RUN apk update \
	&& apk add --no-cache fdk-aac-dev

ENTRYPOINT ["/usr/local/bin/goplay2"]

