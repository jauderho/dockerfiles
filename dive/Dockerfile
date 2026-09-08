FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.1-alpine3.24@sha256:c0602f4fc233e306e5a48560962564d65a31c537161ed479c630c99d1d2b9898 AS build

WORKDIR /go/src/github.com/wagoodman/dive/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/wagoodman/dive/archive/
ARG GIT_URL=https://github.com/wagoodman/dive.git

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
	&& apk add --no-cache curl git gcc musl-dev \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/wagoodman/dive \
	&& cd /go/src/github.com/wagoodman/dive \
	&& go get -u github.com/gdamore/tcell/v2 github.com/docker/docker github.com/docker/cli golang.org/x/net github.com/go-viper/mapstructure/v2 \
	#&& go get -u ./... \
	#&& go get -u all \
	&& go mod tidy \
	&& GOARM="${TARGETVARIANT#v}" go build -o dive-bin -v -trimpath -ldflags="-s -w" ./cmd/dive 

WORKDIR /config



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:0ede9dec8b92b515c2eebc035955744607e98ca598dd98b20b828532e0e99877

ARG DOCKER_CLI_VERSION

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dive"
LABEL org.opencontainers.image.description="A tool for exploring a docker image, layer contents, and discovering ways to shrink your image size"

RUN apk update \
	&& apk upgrade -a

#RUN echo $(uname -m)
#RUN echo ${DOCKER_CLI_VERSION}

# Include a workaround for arch naming mismatch
RUN wget -O- https://download.docker.com/linux/static/stable/$(uname -m | sed -e s/armv7l/armhf/)/docker-${DOCKER_CLI_VERSION}.tgz | \
	tar -xzf - docker/docker --strip-component=1 && \
	mv docker /usr/local/bin

COPY --from=build /go/src/github.com/wagoodman/dive/dive-bin /usr/local/bin/dive
COPY --from=build --chown=nobody:nogroup /config /config

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
USER root

ENTRYPOINT ["/usr/local/bin/dive"]
CMD ["--help"]

