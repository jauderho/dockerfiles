FROM ghcr.io/jauderho/golang:1.23.5-alpine3.21@sha256:9d07aef84b1aabde0c5dddd3f6153a09551db52b840749400639398959368561 AS build

WORKDIR /go/src/github.com/wagoodman/dive/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/wagoodman/dive/archive/
ARG GIT_URL=https://github.com/wagoodman/dive.git

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl git gcc musl-dev \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/wagoodman/dive \
	&& cd /go/src/github.com/wagoodman/dive \
	&& go get -u github.com/gdamore/tcell/v2 github.com/docker/docker github.com/docker/cli \
	&& go get -u all \
	&& go mod tidy \
	&& go build -o dive-bin -v -trimpath -ldflags="-s -w" 

WORKDIR /config



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.21.2@sha256:ae4eeb37e8b2b5b3ec8439c2f00f7fdce6939c7f3867a7c3d2a4dddbfa257d34

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

