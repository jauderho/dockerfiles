FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.3-alpine3.24@sha256:912bbb72c34b2da5574157e979ed57dca24dfad4d39f87e19df0db3b6c2008c6 AS build

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
	# sortorder is listed because docker/cli is +incompatible and so declares no
	# requirements of its own. Nothing raises sortorder above the version dive
	# pins, and docker/cli v29 needs sortorder.NaturalCompare, added in v1.2.0.
	&& go get -u github.com/gdamore/tcell/v2 github.com/docker/docker github.com/docker/cli github.com/fvbommel/sortorder golang.org/x/net github.com/go-viper/mapstructure/v2 \
	#&& go get -u ./... \
	#&& go get -u all \
	&& go mod tidy \
	&& GOARM="${TARGETVARIANT#v}" go build -o dive-bin -v -trimpath -ldflags="-s -w" ./cmd/dive 

WORKDIR /config


# ----------------------------------------------------------------------------

# Files the alpine base used to provide (and that scratch lacks)
FROM build AS rootfs
ARG DOCKER_CLI_VERSION
ARG TARGETARCH
ARG TARGETVARIANT
RUN set -e; \
	apk add --no-cache curl; \
	mkdir -p -m 1777 /rootfs/tmp; \
	mkdir -p -m 700 /rootfs/root/.config; \
	case "${TARGETARCH}${TARGETVARIANT}" in amd64*) a=x86_64;; arm64*) a=aarch64;; armv7) a=armhf;; armv6) a=armel;; ppc64le*) a=ppc64le;; s390x*) a=s390x;; *) echo "unsupported arch" >&2; exit 1;; esac; \
	mkdir -p /rootfs/usr/local/bin; \
	curl --proto "=https" --proto-redir "=https" -fsSL "https://download.docker.com/linux/static/stable/${a}/docker-${DOCKER_CLI_VERSION}.tgz" | tar -xzf - -C /rootfs/usr/local/bin --strip-components=1 docker/docker


# ----------------------------------------------------------------------------

FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dive"
LABEL org.opencontainers.image.description="A tool for exploring a docker image, layer contents, and discovering ways to shrink your image size"

COPY --from=rootfs /rootfs/ /
COPY --from=build /etc/ssl/certs /etc/ssl/certs

ENV HOME=/root


COPY --from=build /go/src/github.com/wagoodman/dive/dive-bin /usr/local/bin/dive
COPY --from=build --chown=65534:65534 /config /config

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
USER 0

ENTRYPOINT ["/usr/local/bin/dive"]
CMD ["--help"]
