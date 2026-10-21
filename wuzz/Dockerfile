FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.3-alpine3.24@sha256:eb4fb7ca7697ba2a12c8aa96dab198c419746c269d59a74abc17f53c058a5218 AS build
# Refresh the CA bundle to the latest the distro publishes
RUN apk add --no-cache --upgrade ca-certificates \
	&& update-ca-certificates

WORKDIR /go/src/github.com/asciimoo/wuzz/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/asciimoo/wuzz/archive/
ARG GIT_URL=https://github.com/jauderho/wuzz.git

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/asciimoo/wuzz \
	&& cd /go/src/github.com/asciimoo/wuzz \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& GOARM="${TARGETVARIANT#v}" go build -v -trimpath -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------

# Files the alpine base used to provide (and that scratch lacks)
FROM build AS rootfs
RUN set -e; \
	mkdir -p -m 1777 /rootfs/tmp


# ----------------------------------------------------------------------------

FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/wuzz"
LABEL org.opencontainers.image.description="wuzz is an interactive cli tool for HTTP inspection"

COPY --from=rootfs /rootfs/ /

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/asciimoo/wuzz/wuzz /usr/local/bin/wuzz
COPY --from=build /config /config

#ENTRYPOINT ["/usr/local/bin/wuzz"]

ENTRYPOINT ["/usr/local/bin/wuzz"]
