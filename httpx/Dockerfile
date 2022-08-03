FROM golang:alpine3.16@sha256:9c621254fe1ff5a00291eb689b1be2ce4744eee678e33189f2fd7b4fc726cff4 AS build

WORKDIR /go/src/github.com/projectdiscovery/httpx/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/projectdiscovery/httpx/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/httpx.tar.gz \
	&& tar xzf /tmp/httpx.tar.gz --strip 1 -C /go/src/github.com/projectdiscovery/httpx \
	&& go build -o httpx -v -trimpath -buildmode=pie -ldflags="-s -w" cmd/httpx/httpx.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.16.1@sha256:7580ece7963bfa863801466c0a488f11c86f85d9988051a9f9c68cb27f6b7872

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/httpx"
LABEL org.opencontainers.image.description="httpx is a fast and multi-purpose HTTP toolkit"

RUN apk add --no-cache bind-tools ca-certificates

COPY --from=build /go/src/github.com/projectdiscovery/httpx/httpx /usr/local/bin/httpx
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/httpx"]
#CMD ["-h"]

