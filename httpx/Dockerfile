FROM ghcr.io/jauderho/golang:1.24.4-alpine3.22@sha256:5527fb3bfaca5aa4409ba4b08b67879e14d786790b4a90ef317b44475f9ebadf AS build

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
	&& go get -u github.com/quic-go/quic-go \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -o httpx -v -trimpath -ldflags="-s -w" cmd/httpx/httpx.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.22.0@sha256:20d4337aed348140c72ea8a8d19a5a64b1a946fc5f5d3071753dc1be9204cc6b

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

