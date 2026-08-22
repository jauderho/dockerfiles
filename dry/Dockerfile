FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:7e070021291cfb200a9a7e91029ce5f96b76d1015794fab30882689e4c586d5d AS build

WORKDIR /go/src/github.com/moncho/dry/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/moncho/dry/archive/

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
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/dry.tar.gz \
	&& tar xzf /tmp/dry.tar.gz --strip 1 -C /go/src/github.com/moncho/dry \
	#&& go get -u github.com/containerd/containerd@v1.6.21 \
	#&& go get -u github.com/docker/docker@v25.0.6 github.com/docker/cli@v25.0.6 \
	#&& go get -u github.com/docker/distribution \
	#&& go get -u golang.org/x/net \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	#&& go get -u all \
	&& GOARM="${TARGETVARIANT#v}" go build -o dry-bin -v -trimpath -ldflags="-s -w" 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:ff52f2346776ea44fca133cbd5ec332e5ee10d10cef9c433bbe337e3c31c2a50

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dry"
LABEL org.opencontainers.image.description="Dry is a terminal application to manage Docker and Docker Swarm."

RUN apk update \
	&& apk upgrade -a

COPY --from=build /go/src/github.com/moncho/dry/dry-bin /usr/local/bin/dry
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/dry"]

