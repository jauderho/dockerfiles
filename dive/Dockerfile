FROM ghcr.io/jauderho/golang:1.26.4-alpine3.24@sha256:0fc2a4e9c3497e5987b36b7530c2fa80206456ec6b3b456a1f63b20b558fc2a4 AS build

WORKDIR /go/src/github.com/wagoodman/dive/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/wagoodman/dive/archive/
ARG GIT_URL=https://github.com/wagoodman/dive.git

ENV GO111MODULE=on
ENV CGO_ENABLED=0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl git gcc musl-dev \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/wagoodman/dive \
	&& cd /go/src/github.com/wagoodman/dive \
	&& go get -u github.com/gdamore/tcell/v2 github.com/docker/docker github.com/docker/cli \
	#&& go get -u ./... \
	#&& go get -u all \
	&& go mod tidy \
	&& go build -o dive-bin -v -trimpath -ldflags="-s -w" ./cmd/dive 

WORKDIR /config



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:c43ea832c5e5df2adadaec0a6487e5939c7080376ed831db9d422067519e86d8

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

