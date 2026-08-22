FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:7e070021291cfb200a9a7e91029ce5f96b76d1015794fab30882689e4c586d5d AS build

WORKDIR /go/src/github.com/asciimoo/wuzz/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/asciimoo/wuzz/archive/
ARG GIT_URL=https://github.com/jauderho/wuzz.git

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/asciimoo/wuzz \
	&& cd /go/src/github.com/asciimoo/wuzz \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& GOARM="${TARGETVARIANT#v}" go build -v -trimpath -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:ff52f2346776ea44fca133cbd5ec332e5ee10d10cef9c433bbe337e3c31c2a50

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/wuzz"
LABEL org.opencontainers.image.description="wuzz is an interactive cli tool for HTTP inspection"

RUN apk update \
	&& apk upgrade -a 

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/asciimoo/wuzz/wuzz /usr/local/bin/wuzz
COPY --from=build /config /config

#ENTRYPOINT ["/usr/local/bin/wuzz"]

# wuzz does not want to start up consistently unless sleep 1 is used.It would be better if we could just directly enter into the binary
ENTRYPOINT ["sh", "-c", "sleep 1 ; /usr/local/bin/wuzz"]

