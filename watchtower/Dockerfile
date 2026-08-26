FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:75f8f4b30907514de96c51f951d84d51160d66fdf51c2e1017e620b8e0207a4a AS build

WORKDIR /go/src/github.com/nicholas-fedor/watchtower/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/nicholas-fedor/watchtower/archive/
ARG GIT_URL=https://github.com/nicholas-fedor/watchtower.git

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git ca-certificates tzdata \ 
	&& git clone --depth 1 --branch ${BUILD_VERSION} ${GIT_URL} /go/src/github.com/nicholas-fedor/watchtower \
	&& cd /go/src/github.com/nicholas-fedor/watchtower \
	# Upstream tracks the moby modules. Only docker/cli is left to upgrade here.
	&& go get -u google.golang.org/protobuf github.com/docker/cli golang.org/x/net \
	&& go mod tidy \
	&& GOARM="${TARGETVARIANT#v}" go build -o watchtower -v -trimpath -ldflags="-s -w -X github.com/nicholas-fedor/watchtower/internal/meta.Version=${BUILD_VERSION}" .

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/watchtower"
LABEL org.opencontainers.image.description="watchtower is a process for automating Docker container base image updates"

LABEL "com.centurylinklabs.watchtower"="true"

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo

COPY --from=build /go/src/github.com/nicholas-fedor/watchtower/watchtower /usr/local/bin/watchtower
COPY --from=build /config /config

EXPOSE 8080
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

ENTRYPOINT ["/usr/local/bin/watchtower"]

