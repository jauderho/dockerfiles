FROM ghcr.io/jauderho/golang:1.24.0-alpine3.21@sha256:3e7233b32f33ae1988d5638262ddcd27411022fcbecbfaf00ee40f9eb09e7167 AS build

WORKDIR /go/src/github.com/moncho/dry/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/moncho/dry/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/dry.tar.gz \
	&& tar xzf /tmp/dry.tar.gz --strip 1 -C /go/src/github.com/moncho/dry \
	#&& go get -u github.com/containerd/containerd@v1.6.21 \
	&& go get -u github.com/docker/docker@v25.0.6 github.com/docker/cli@v25.0.6 \
	#&& go get -u github.com/docker/distribution \
	&& go get -u golang.org/x/net \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	#&& go get -u all \
	&& go build -o dry-bin -v -trimpath -ldflags="-s -w" 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.21.3@sha256:8139b5dd95ef46202c45b611a4b7e972defda480df2e058b95b6a07b4f2e96c4

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

