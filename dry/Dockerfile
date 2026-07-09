FROM ghcr.io/jauderho/golang:1.26.4-alpine3.24@sha256:aea122b2bd93a09369064c7b7062c2c61c88b8a9a821256684ac623838e2bdef AS build

WORKDIR /go/src/github.com/moncho/dry/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/moncho/dry/archive/

ENV GO111MODULE=on
ENV CGO_ENABLED=0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/dry.tar.gz \
	&& tar xzf /tmp/dry.tar.gz --strip 1 -C /go/src/github.com/moncho/dry \
	#&& go get -u github.com/containerd/containerd@v1.6.21 \
	#&& go get -u github.com/docker/docker@v25.0.6 github.com/docker/cli@v25.0.6 \
	#&& go get -u github.com/docker/distribution \
	#&& go get -u golang.org/x/net \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	#&& go get -u all \
	&& go build -o dry-bin -v -trimpath -ldflags="-s -w" 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:5c592efde24ef4bd031a296ebb3a61ff6ce3236899e28b68430b7a309481a6e9

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

