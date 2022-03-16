FROM golang:1.18.0-alpine3.15@sha256:9efe6b075e2bd5eff0fae9ce2961897ac339ef31eec24732691e15be0a154eec AS build

WORKDIR /go/src/github.com/wagoodman/dive/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/wagoodman/dive/archive/
ARG GIT_URL=https://github.com/jauderho/dive.git

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache curl git gcc musl-dev \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/wagoodman/dive \
	&& cd /go/src/github.com/wagoodman/dive \
	&& go build -o dive-bin -v -trimpath -buildmode=pie -ldflags="-s -w" 

WORKDIR /config



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300

ARG DOCKER_CLI_VERSION

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dive"
LABEL org.opencontainers.image.description="A tool for exploring a docker image, layer contents, and discovering ways to shrink your image size"

RUN echo $(uname -m)
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

