FROM golang:1.20.5-alpine3.18@sha256:fd9d9d7194ec40a9a6ae89fcaef3e47c47de7746dd5848ab5343695dbbd09f8c AS build

WORKDIR /go/src/github.com/projectdiscovery/httpx/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/projectdiscovery/httpx/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/httpx.tar.gz \
	&& tar xzf /tmp/httpx.tar.gz --strip 1 -C /go/src/github.com/projectdiscovery/httpx \
	&& go build -o httpx -v -trimpath -buildmode=pie -ldflags="-s -w" cmd/httpx/httpx.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.18.0@sha256:02bb6f428431fbc2809c5d1b41eab5a68350194fb508869a33cb1af4444c9b11

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/httpx"
LABEL org.opencontainers.image.description="httpx is a fast and multi-purpose HTTP toolkit"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache bind-tools ca-certificates

COPY --from=build /go/src/github.com/projectdiscovery/httpx/httpx /usr/local/bin/httpx
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/httpx"]
#CMD ["-h"]

