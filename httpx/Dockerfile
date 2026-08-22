FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:acb2ce37623dc9b32cca8e204995298705b7341c4b00bfb9f22db47221ec2927 AS build

WORKDIR /go/src/github.com/projectdiscovery/httpx/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/projectdiscovery/httpx/archive/

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/httpx.tar.gz \
	&& tar xzf /tmp/httpx.tar.gz --strip 1 -C /go/src/github.com/projectdiscovery/httpx \
	&& go get -u github.com/quic-go/quic-go \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& GOARM="${TARGETVARIANT#v}" go build -o httpx -v -trimpath -ldflags="-s -w" cmd/httpx/httpx.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:ff52f2346776ea44fca133cbd5ec332e5ee10d10cef9c433bbe337e3c31c2a50

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

