FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.26.6-alpine3.24@sha256:e07200aceb844fea2934eeab605e3461b811fe6ebe719ca2d7594111633cdd75 AS build

WORKDIR /go/src/github.com/tomnomnom/httprobe/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/tomnomnom/httprobe/archive/
ARG GIT_URL=https://github.com/tomnomnom/httprobe.git

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/tomnomnom/httprobe \
	&& cd /go/src/github.com/tomnomnom/httprobe \
	&& GOARM="${TARGETVARIANT#v}" go build -o httprobe -v -trimpath -ldflags="-s -w" main.go  

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:e198ded2ad4e953fa5349cd30f01ff6f7d07773254d079df4aca4a6a2dd24bf5

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/httprobe"
LABEL org.opencontainers.image.description="httprobe probes for working http and https servers"

RUN apk update \
	&& apk upgrade -a

COPY --from=build /go/src/github.com/tomnomnom/httprobe/httprobe /usr/local/bin/httprobe
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/httprobe"]

