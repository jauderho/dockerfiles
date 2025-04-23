FROM ghcr.io/jauderho/golang:1.24.2-alpine3.21@sha256:846548c5c614369b58b16ad8ea1fd4574949f078d7d32e731c9114b717eacc13 AS build

WORKDIR /go/src/github.com/openairplay/goplay2/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/openairplay/goplay2/archive/
ARG GIT_URL=https://github.com/openairplay/goplay2.git

ENV CGO_ENABLED 1

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
FROM ghcr.io/jauderho/alpine:3.21.3@sha256:4d30faf9002da9de8e2b91f6c1fadd20d55377434596e161fa014a72a3cf4dd1

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

