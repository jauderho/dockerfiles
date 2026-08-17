FROM ghcr.io/jauderho/golang:1.26.6-alpine3.24@sha256:e07200aceb844fea2934eeab605e3461b811fe6ebe719ca2d7594111633cdd75 AS build

WORKDIR /go/src/github.com/projectdiscovery/subfinder/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/projectdiscovery/subfinder/archive/

ENV GO111MODULE=on
ENV CGO_ENABLED=0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/subfinder.tar.gz \
	&& tar xzf /tmp/subfinder.tar.gz --strip 1 -C /go/src/github.com/projectdiscovery/subfinder \
	&& go get -u github.com/quic-go/quic-go \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -o subfinder -v -trimpath -ldflags="-s -w" cmd/subfinder/main.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:e198ded2ad4e953fa5349cd30f01ff6f7d07773254d079df4aca4a6a2dd24bf5

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/subfinder"
LABEL org.opencontainers.image.description="subfinder is a subdomain discovery tool via passive online sources"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache bind-tools ca-certificates

COPY --from=build /go/src/github.com/projectdiscovery/subfinder/subfinder /usr/local/bin/subfinder
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/subfinder"]
#CMD ["-h"]

