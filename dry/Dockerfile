FROM golang:1.21.2-alpine3.18@sha256:a76f153cff6a59112777c071b0cde1b6e4691ddc7f172be424228da1bfb7bbda AS build

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
	&& go get -u github.com/containerd/containerd@v1.6.21 \
	&& go get -u github.com/docker/docker@v20.10.24 \
	&& go get -u github.com/docker/cli@v20.10.24 \
	&& go get -u github.com/docker/distribution \
	&& go build -o dry-bin -v -trimpath -buildmode=pie -ldflags="-s -w" 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

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

